import { Response } from "express";
import { AuthenticatedRequest } from "../middlewares/auth";
import prisma from "../config/db";
import { syncAbsentAndLeaveAttendanceRecords } from "../services/face.service";
import { ComponentCategory, CalculationType } from "@prisma/client";

export async function applyLeave(req: AuthenticatedRequest, res: Response) {
  try {
    const { leaveType, leaveTypeId, fromDate, toDate, reason, attachmentUrl } = req.body;
    const userId = req.user?.id;

    if ((!leaveType && !leaveTypeId) || !fromDate || !toDate || !reason || !userId) {
      return res.status(400).json({ error: "Missing required leave request properties" });
    }

    const start = new Date(fromDate);
    const end = new Date(toDate);
    start.setUTCHours(0, 0, 0, 0);
    end.setUTCHours(0, 0, 0, 0);

    if (start.getTime() > end.getTime()) {
      return res.status(400).json({ error: "Start date must be before or equal to end date" });
    }

    const today = new Date();
    today.setUTCHours(0, 0, 0, 0);
    if (start.getTime() < today.getTime()) {
      return res.status(400).json({ error: "Cannot apply for leave on past dates." });
    }

    // Check if staff has already checked in or been marked as PRESENT/HALF_DAY on any dates in the range
    const dateStrings: string[] = [];
    let tempCheck = new Date(start);
    while (tempCheck.getTime() <= end.getTime()) {
      dateStrings.push(tempCheck.toISOString().split("T")[0]);
      tempCheck.setUTCDate(tempCheck.getUTCDate() + 1);
    }

    const existingStaffAttendance = await prisma.staffAttendance.findFirst({
      where: {
        userId,
        date: { in: dateStrings },
        OR: [
          { status: { in: ["PRESENT", "HALF_DAY"] } },
          { firstCheckIn: { not: null } }
        ]
      }
    });
    if (existingStaffAttendance) {
      return res.status(400).json({
        error: `Cannot apply for leave on ${existingStaffAttendance.date} because you have already checked in or been marked as present/half-day on that date.`
      });
    }

    const existingApproved = await prisma.leaveRequest.findFirst({
      where: {
        userId,
        studentId: null,
        status: "APPROVED",
        OR: [
          {
            fromDate: { lte: end },
            toDate: { gte: start }
          }
        ]
      }
    });
    if (existingApproved) {
      return res.status(400).json({ error: "You already have an approved leave request that overlaps with this date range." });
    }

    const schoolId = req.user?.schoolId;
    if (!schoolId) {
      return res.status(400).json({ error: "Missing school context for validation" });
    }

    const school = await prisma.school.findUnique({ where: { id: schoolId } });
    if (!school) {
      return res.status(404).json({ error: "School context not found" });
    }

    const offs = school.weeklyOffs ? school.weeklyOffs.split(",") : ["0"];
    const weekdayNames = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"];

    const scheduledHolidays = await prisma.schoolHoliday.findMany({
      where: {
        schoolId,
        date: {
          gte: start,
          lte: end
        }
      }
    });

    const holidayDatesSet = new Set(
      scheduledHolidays.map(h => h.date.toISOString().split("T")[0])
    );

    let temp = new Date(start);
    while (temp.getTime() <= end.getTime()) {
      const dayOfWeek = temp.getUTCDay().toString();
      const dateStr = temp.toISOString().split("T")[0];

      if (offs.includes(dayOfWeek)) {
        return res.status(400).json({
          error: `Cannot apply for leave on ${dateStr} (${weekdayNames[parseInt(dayOfWeek)]}) because it is a weekly off.`
        });
      }

      if (holidayDatesSet.has(dateStr)) {
        const holidayRecord = scheduledHolidays.find(h => h.date.toISOString().split("T")[0] === dateStr);
        return res.status(400).json({
          error: `Cannot apply for leave on ${dateStr} because it is a scheduled school holiday: ${holidayRecord?.title || "Holiday"}.`
        });
      }

      temp.setUTCDate(temp.getUTCDate() + 1);
    }

    let finalLeaveType = leaveType;
    let finalLeaveTypeId = leaveTypeId || null;

    if (leaveTypeId) {
      const lt = await prisma.leaveType.findUnique({
        where: { id: leaveTypeId }
      });
      if (lt) {
        finalLeaveType = lt.name;
      }
    } else if (leaveType) {
      const ltCode = leaveType === "Casual Leave" ? "CASUAL" : (leaveType === "Sick Leave" ? "SICK" : null);
      if (ltCode) {
        const lt = await prisma.leaveType.findFirst({
          where: { schoolId, code: ltCode }
        });
        if (lt) {
          finalLeaveTypeId = lt.id;
        }
      }
    }

    let limit = 0;
    let isUnpaid = false;

    if (finalLeaveTypeId) {
      const lt = await prisma.leaveType.findUnique({
        where: { id: finalLeaveTypeId }
      });
      if (lt) {
        isUnpaid = lt.isUnpaid;
        const teacherProfile = await prisma.teacherProfile.findUnique({
          where: { userId }
        });
        const exp = teacherProfile?.experienceYears ?? 0;
        if (exp < 2) {
          limit = lt.maxDays;
        } else if (exp <= 5) {
          limit = lt.maxDaysMid ?? lt.maxDays;
        } else {
          limit = lt.maxDaysSenior ?? lt.maxDays;
        }
      }
    } else {
      if (finalLeaveType === "Casual Leave") {
        limit = school.casualLeaveLimit ?? 12;
      } else if (finalLeaveType === "Sick Leave") {
        limit = school.sickLeaveLimit ?? 10;
      }
    }

    if (!isUnpaid && limit > 0) {
      // Calculate working days requested
      let requestedWorkingDays = 0;
      let tempCheck = new Date(start);
      while (tempCheck.getTime() <= end.getTime()) {
        const dayOfWeek = tempCheck.getUTCDay().toString();
        const dateStr = tempCheck.toISOString().split("T")[0];
        if (!offs.includes(dayOfWeek) && !holidayDatesSet.has(dateStr)) {
          requestedWorkingDays++;
        }
        tempCheck.setUTCDate(tempCheck.getUTCDate() + 1);
      }

      // Calculate approved leaves of this type this year
      const startOfYear = new Date(new Date().getFullYear(), 0, 1);
      const approvedLeavesThisYear = await prisma.leaveRequest.findMany({
        where: {
          userId,
          studentId: null,
          status: "APPROVED",
          fromDate: { gte: startOfYear },
          OR: [
            finalLeaveTypeId ? { leaveTypeId: finalLeaveTypeId } : { leaveType: finalLeaveType }
          ]
        }
      });

      let approvedDaysUsed = 0;
      for (const approvedLeave of approvedLeavesThisYear) {
        const leaveStart = new Date(approvedLeave.fromDate);
        const leaveEnd = new Date(approvedLeave.toDate);
        leaveStart.setUTCHours(0, 0, 0, 0);
        leaveEnd.setUTCHours(0, 0, 0, 0);
        let temp2 = new Date(leaveStart);
        while (temp2.getTime() <= leaveEnd.getTime()) {
          const dayOfWeek = temp2.getUTCDay().toString();
          const dateStr = temp2.toISOString().split("T")[0];
          if (!offs.includes(dayOfWeek) && !holidayDatesSet.has(dateStr)) {
            approvedDaysUsed++;
          }
          temp2.setUTCDate(temp2.getUTCDate() + 1);
        }
      }

      const remaining = limit - approvedDaysUsed;
      if (requestedWorkingDays > remaining) {
        return res.status(400).json({
          error: `Insufficient leave balance. You requested ${requestedWorkingDays} days but only have ${remaining} days remaining for ${finalLeaveType}.`
        });
      }
    }

    const leave = await prisma.leaveRequest.create({
      data: {
        userId,
        leaveType: finalLeaveType || "Leave Request",
        leaveTypeId: finalLeaveTypeId,
        fromDate: new Date(fromDate),
        toDate: new Date(toDate),
        reason,
        attachmentUrl,
        status: "PENDING"
      }
    });

    res.status(201).json({ message: "Leave applied successfully", leave });
  } catch (error: any) {
    res.status(500).json({ error: error.message || "Failed to submit leave request" });
  }
}

export async function getMyLeaveSummary(req: AuthenticatedRequest, res: Response) {
  try {
    const userId = req.user?.id;
    const schoolId = req.user?.schoolId;

    if (!userId || !schoolId) {
      return res.status(400).json({ error: "Missing identity context" });
    }

    // Get counts
    const leaveRequests = await prisma.leaveRequest.findMany({
      where: { userId, studentId: null }
    });

    const pendingCount = leaveRequests.filter(l => l.status === "PENDING").length;
    const approvedCount = leaveRequests.filter(l => l.status === "APPROVED").length;
    const rejectedCount = leaveRequests.filter(l => l.status === "REJECTED").length;

    // Get school info
    const school = await prisma.school.findUnique({ where: { id: schoolId } });
    if (!school) {
      return res.status(404).json({ error: "School not found" });
    }

    const offs = school.weeklyOffs ? school.weeklyOffs.split(",") : ["0"];
    const startOfYear = new Date(new Date().getFullYear(), 0, 1);
    const endOfYear = new Date(new Date().getFullYear(), 11, 31);

    const scheduledHolidays = await prisma.schoolHoliday.findMany({
      where: {
        schoolId,
        date: { gte: startOfYear, lte: endOfYear }
      }
    });
    const holidayDatesSet = new Set(
      scheduledHolidays.map(h => h.date.toISOString().split("T")[0])
    );

    // Get teacher profile for experience years
    const teacherProfile = await prisma.teacherProfile.findUnique({
      where: { userId }
    });
    const exp = teacherProfile?.experienceYears ?? 0;

    // Get all custom leave types of the school
    const customLeaveTypes = await prisma.leaveType.findMany({
      where: { schoolId }
    });

    // We build a list of policies
    const policies = [];

    // Add default policies if they aren't overridden by custom codes (e.g. CASUAL, SICK)
    const hasCustomCasual = customLeaveTypes.some(lt => lt.code === "CASUAL");
    const hasCustomSick = customLeaveTypes.some(lt => lt.code === "SICK");

    if (!hasCustomCasual) {
      policies.push({
        id: null,
        code: "CASUAL",
        name: "Casual Leave",
        maxDays: school.casualLeaveLimit ?? 12,
        isUnpaid: false
      });
    }
    if (!hasCustomSick) {
      policies.push({
        id: null,
        code: "SICK",
        name: "Sick Leave",
        maxDays: school.sickLeaveLimit ?? 10,
        isUnpaid: false
      });
    }

    for (const lt of customLeaveTypes) {
      let maxDays = lt.maxDays;
      if (exp >= 2 && exp <= 5) {
        maxDays = lt.maxDaysMid ?? lt.maxDays;
      } else if (exp > 5) {
        maxDays = lt.maxDaysSenior ?? lt.maxDays;
      }
      policies.push({
        id: lt.id,
        code: lt.code,
        name: lt.name,
        maxDays: maxDays,
        isUnpaid: lt.isUnpaid
      });
    }

    // Now calculate used days for each policy
    const approvedLeavesThisYear = leaveRequests.filter(
      l => l.status === "APPROVED" && new Date(l.fromDate).getFullYear() === new Date().getFullYear()
    );

    const balances = [];
    for (const policy of policies) {
      let usedDays = 0;
      const matchingLeaves = approvedLeavesThisYear.filter(l => 
        policy.id ? l.leaveTypeId === policy.id : l.leaveType === policy.name
      );

      for (const leave of matchingLeaves) {
        const leaveStart = new Date(leave.fromDate);
        const leaveEnd = new Date(leave.toDate);
        leaveStart.setUTCHours(0, 0, 0, 0);
        leaveEnd.setUTCHours(0, 0, 0, 0);
        let temp = new Date(leaveStart);
        while (temp.getTime() <= leaveEnd.getTime()) {
          const dayOfWeek = temp.getUTCDay().toString();
          const dateStr = temp.toISOString().split("T")[0];
          if (!offs.includes(dayOfWeek) && !holidayDatesSet.has(dateStr)) {
            usedDays++;
          }
          temp.setUTCDate(temp.getUTCDate() + 1);
        }
      }

      balances.push({
        leaveTypeId: policy.id,
        leaveType: policy.name,
        code: policy.code,
        maxDays: policy.maxDays,
        usedDays: usedDays,
        balance: policy.isUnpaid ? 999 : Math.max(0, policy.maxDays - usedDays),
        isUnpaid: policy.isUnpaid
      });
    }

    res.json({
      summary: {
        pending: pendingCount,
        approved: approvedCount,
        rejected: rejectedCount
      },
      balances
    });
  } catch (error: any) {
    res.status(500).json({ error: error.message || "Failed to retrieve leave summary" });
  }
}


export async function getLeaves(req: AuthenticatedRequest, res: Response) {
  try {
    const schoolId = req.user?.schoolId;
    const userId = req.user?.id;
    const role = req.user?.role;

    if (!schoolId || !userId) {
      return res.status(400).json({ error: "Missing identity context" });
    }

    let leaves;
    // Correspondent, Principal, HM can see all leaves in the school
    if (role === "CORRESPONDENT" || role === "PRINCIPAL" || role === "HM") {
      leaves = await prisma.leaveRequest.findMany({
        where: {
          user: { schoolId },
          studentId: null
        },
        include: {
          user: { select: { fullName: true, role: true } },
          student: { include: { classSection: { include: { class: true } } } }
        },
        orderBy: { createdAt: "desc" }
      });
    } else if (role === "TEACHER") {
      // Find if this teacher is a class teacher of any section
      const teacherProfile = await prisma.teacherProfile.findUnique({
        where: { userId }
      });
      
      let classSectionId: string | null = null;
      if (teacherProfile) {
        const classSection = await prisma.classSection.findFirst({
          where: { classTeacherId: teacherProfile.id }
        });
        if (classSection) {
          classSectionId = classSection.id;
        }
      }

      // Teachers see their own leaves AND leaves of students in the class section they are class teacher of
      leaves = await prisma.leaveRequest.findMany({
        where: {
          OR: [
            { userId }, // Teacher's own leaves
            classSectionId ? {
              student: { classSectionId },
              leaveType: "CHILD_SICK_LEAVE"
            } : null
          ].filter(Boolean) as any
        },
        include: {
          user: { select: { fullName: true, role: true } },
          student: { include: { classSection: { include: { class: true } } } }
        },
        orderBy: { createdAt: "desc" }
      });
    } else {
      // Parents only see their own leave requests (which they applied for their children)
      leaves = await prisma.leaveRequest.findMany({
        where: { userId },
        include: {
          user: { select: { fullName: true, role: true } },
          student: { include: { classSection: { include: { class: true } } } }
        },
        orderBy: { createdAt: "desc" }
      });
    }

    res.json(leaves);
  } catch (error: any) {
    res.status(500).json({ error: error.message || "Failed to retrieve leave entries" });
  }
}

export async function updateLeaveStatus(req: AuthenticatedRequest, res: Response) {
  try {
    const { leaveId } = req.params;
    const { status } = req.body; // APPROVED or REJECTED
    const approverId = req.user?.id;

    if (!status || !["APPROVED", "REJECTED"].includes(status)) {
      return res.status(400).json({ error: "Valid status (APPROVED or REJECTED) is required" });
    }

    const leaveRecord = await prisma.leaveRequest.findUnique({
      where: { id: leaveId }
    });

    if (!leaveRecord) {
      return res.status(404).json({ error: "Leave request not found" });
    }

    const userRole = req.user?.role;
    const userId = req.user?.id;

    if (userRole === "TEACHER") {
      if (!leaveRecord.studentId) {
        return res.status(403).json({ error: "Teachers are only authorized to approve student leave requests." });
      }

      const teacherProfile = await prisma.teacherProfile.findUnique({
        where: { userId }
      });
      if (!teacherProfile) {
        return res.status(403).json({ error: "Teacher profile not found." });
      }

      // Check if student belongs to the section where this teacher is the class teacher
      const student = await prisma.student.findUnique({
        where: { id: leaveRecord.studentId },
        include: { classSection: true }
      });

      if (!student || !student.classSection || student.classSection.classTeacherId !== teacherProfile.id) {
        return res.status(403).json({ error: "Unauthorized. You are not the class teacher for this student." });
      }
    }

    const leave = await prisma.leaveRequest.update({
      where: { id: leaveId },
      data: {
        status,
        approvedById: approverId
      }
    });

    // If it is a student leave and status is APPROVED, insert/upsert attendance records as LEAVE for the leave dates
    if (status === "APPROVED" && leave.studentId) {
      const start = new Date(leave.fromDate);
      const end = new Date(leave.toDate);
      start.setUTCHours(0, 0, 0, 0);
      end.setUTCHours(0, 0, 0, 0);

      let temp = new Date(start);
      while (temp.getTime() <= end.getTime()) {
        const currentDate = new Date(temp);
        
        await prisma.attendance.upsert({
          where: {
            date_studentId: {
              date: currentDate,
              studentId: leave.studentId
            }
          },
          update: {
            status: "LEAVE",
            markedById: approverId!
          },
          create: {
            date: currentDate,
            studentId: leave.studentId,
            status: "LEAVE",
            markedById: approverId!
          }
        });

        temp.setDate(temp.getDate() + 1);
      }
    }

    res.json({ message: `Leave status updated to ${status}`, leave });
  } catch (error: any) {
    res.status(500).json({ error: error.message || "Failed to update leave request status" });
  }
}

export async function withdrawLeave(req: AuthenticatedRequest, res: Response) {
  try {
    const { leaveId } = req.params;
    const userId = req.user?.id;

    if (!userId) {
      return res.status(401).json({ error: "Unauthorized" });
    }

    const leave = await prisma.leaveRequest.findUnique({
      where: { id: leaveId }
    });

    if (!leave) {
      return res.status(404).json({ error: "Leave request not found" });
    }

    // Verify if it is in PENDING stage
    if (leave.status !== "PENDING") {
      return res.status(400).json({ error: "Only pending leave requests can be withdrawn." });
    }

    // Authorization checks:
    // If the leave belongs to a student (child leave), the applicant must be the parent who created it
    if (leave.studentId) {
      if (leave.userId !== userId) {
        return res.status(403).json({ error: "Unauthorized to withdraw this child's leave request." });
      }
    } else {
      // If it is a staff leave, the applicant must be the staff user
      if (leave.userId !== userId) {
        return res.status(403).json({ error: "Unauthorized to withdraw this leave request." });
      }
    }

    // Update status to WITHDRAWN
    const updatedLeave = await prisma.leaveRequest.update({
      where: { id: leaveId },
      data: { status: "WITHDRAWN" }
    });

    res.json({ message: "Leave request withdrawn successfully", leave: updatedLeave });
  } catch (error: any) {
    res.status(500).json({ error: error.message || "Failed to withdraw leave request" });
  }
}

export async function getSalaryRecords(req: AuthenticatedRequest, res: Response) {
  try {
    const schoolId = req.user?.schoolId;
    const role = req.user?.role;
    const userId = req.user?.id;

    if (!schoolId) {
      return res.status(400).json({ error: "Missing school context" });
    }

    let salaries;
    if (role === "CORRESPONDENT" || role === "PRINCIPAL" || role === "HM") {
      salaries = await prisma.salaryRecord.findMany({
        where: {
          teacher: {
            user: { schoolId }
          }
        },
        include: {
          teacher: {
            include: { user: { select: { fullName: true } } }
          },
          components: true
        },
        orderBy: { generatedAt: "desc" }
      });
    } else {
      salaries = await prisma.salaryRecord.findMany({
        where: {
          teacher: { userId }
        },
        include: {
          teacher: {
            include: { user: { select: { fullName: true } } }
          },
          components: true
        },
        orderBy: { generatedAt: "desc" }
      });
    }

    res.json(salaries);
  } catch (error: any) {
    res.status(500).json({ error: error.message || "Failed to retrieve salary records" });
  }
}

async function seedDefaultSalarySettings(schoolId: string) {
  const existingComponentsCount = await prisma.salaryComponent.count({
    where: { schoolId }
  });
  if (existingComponentsCount > 0) {
    return;
  }

  const componentsData = [
    { name: "Basic Pay", category: ComponentCategory.FIXED_EARNING, isTaxable: true },
    { name: "House Rent Allowance (HRA)", category: ComponentCategory.FIXED_EARNING, isTaxable: true },
    { name: "Special Allowance", category: ComponentCategory.FIXED_EARNING, isTaxable: true },
    { name: "Provident Fund (PF)", category: ComponentCategory.STATUTORY_DEDUCTION, isTaxable: false },
    { name: "Employee State Insurance (ESI)", category: ComponentCategory.STATUTORY_DEDUCTION, isTaxable: false },
    { name: "Professional Tax (PT)", category: ComponentCategory.STATUTORY_DEDUCTION, isTaxable: false }
  ];

  const componentMap = new Map<string, string>();
  for (const comp of componentsData) {
    const created = await prisma.salaryComponent.create({
      data: {
        schoolId,
        name: comp.name,
        category: comp.category,
        isTaxable: comp.isTaxable,
        isProrated: true,
        isActive: true
      }
    });
    componentMap.set(comp.name, created.id);
  }

  const template = await prisma.salaryTemplate.create({
    data: {
      schoolId,
      name: "Standard CTC Template",
      description: "Default salary template with standard statutory components (Basic 50%, HRA 40%, PF 12%, ESI 0.75%, PT slab-based)",
      overtimeMultiplier: 1.5
    }
  });

  const templateComponents = [
    {
      componentId: componentMap.get("Basic Pay")!,
      calculationType: CalculationType.PERCENTAGE_OF_CTC,
      value: 50.0
    },
    {
      componentId: componentMap.get("House Rent Allowance (HRA)")!,
      calculationType: CalculationType.PERCENTAGE_OF_BASIC,
      value: 40.0
    },
    {
      componentId: componentMap.get("Special Allowance")!,
      calculationType: CalculationType.FLAT_AMOUNT,
      value: 0.0
    },
    {
      componentId: componentMap.get("Provident Fund (PF)")!,
      calculationType: CalculationType.PERCENTAGE_OF_BASIC,
      value: 12.0,
      calculateOnMax: 15000.0
    },
    {
      componentId: componentMap.get("Employee State Insurance (ESI)")!,
      calculationType: CalculationType.PERCENTAGE_OF_GROSS,
      value: 0.75,
      activeOnlyIfGrossLessThan: 21000.0
    },
    {
      componentId: componentMap.get("Professional Tax (PT)")!,
      calculationType: CalculationType.SLAB_BASED,
      value: 0.0
    }
  ];

  for (const tc of templateComponents) {
    await prisma.templateComponent.create({
      data: {
        templateId: template.id,
        componentId: tc.componentId,
        calculationType: tc.calculationType,
        value: tc.value,
        calculateOnMax: tc.calculateOnMax || null,
        activeOnlyIfGrossLessThan: tc.activeOnlyIfGrossLessThan || null
      }
    });
  }
}

export async function generateSalaries(req: AuthenticatedRequest, res: Response) {
  try {
    const { month, year, adjustments } = req.body;
    const schoolId = req.user?.schoolId;

    if (!month || !year || !schoolId) {
      return res.status(400).json({ error: "Month, year, and school details are required" });
    }

    const school = await prisma.school.findUnique({
      where: { id: schoolId },
      include: { holidays: true }
    });

    if (!school) {
      return res.status(404).json({ error: "School context not found" });
    }

    // Auto-seed default components & template if none exist
    await seedDefaultSalarySettings(schoolId);

    // 1. Sync attendance records first
    await syncAbsentAndLeaveAttendanceRecords(schoolId, month, parseInt(year));

    const teachers = await prisma.teacherProfile.findMany({
      where: {
        user: { schoolId }
      },
      include: {
        user: true,
        salaryTemplate: {
          include: {
            components: {
              include: {
                component: true
              }
            }
          }
        }
      }
    });

    if (teachers.length === 0) {
      return res.status(400).json({ error: "No teachers found in this school to generate salary" });
    }

    const monthNames = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];
    const monthIndex = monthNames.indexOf(month);
    if (monthIndex === -1) {
      return res.status(400).json({ error: "Invalid month name" });
    }

    // 2. Count working days in the month
    const startDate = new Date(Date.UTC(parseInt(year), monthIndex, 1));
    const endDate = new Date(Date.UTC(parseInt(year), monthIndex + 1, 0)); // last day of month

    const holidaysSet = new Set(
      school.holidays.map(h => h.date.toISOString().split("T")[0])
    );
    const offs = school.weeklyOffs ? school.weeklyOffs.split(",") : ["0"];

    let workingDays = 0;
    let temp = new Date(startDate);
    while (temp.getTime() <= endDate.getTime()) {
      const dateStr = temp.toISOString().split("T")[0];
      const dayOfWeek = temp.getUTCDay().toString();
      
      if (!offs.includes(dayOfWeek) && !holidaysSet.has(dateStr)) {
        workingDays++;
      }
      temp.setUTCDate(temp.getUTCDate() + 1);
    }
    if (workingDays === 0) workingDays = 30;

    const monthStr = (monthIndex + 1).toString().padStart(2, "0");
    const datePrefix = `${year}-${monthStr}`;

    const adjustmentsMap = new Map<string, any>();
    if (adjustments && Array.isArray(adjustments)) {
      for (const adj of adjustments) {
        adjustmentsMap.set(adj.teacherId, adj);
      }
    }

    const salaryOps = [];

    for (const teacher of teachers) {
      // Delete any existing unfinalized salary records for this month/year
      await prisma.salaryRecord.deleteMany({
        where: {
          teacherId: teacher.id,
          month,
          year: parseInt(year),
          status: { in: ["PENDING", "DRAFT", "PROCESSED", "APPROVED"] }
        }
      });

      // Fetch dynamic VariablePay records for this month/year
      const variablePays = await prisma.variablePay.findMany({
        where: {
          teacherId: teacher.id,
          month,
          year: parseInt(year)
        },
        include: {
          component: true
        }
      });

      // Calculate attendance statistics
      const attendances = await prisma.staffAttendance.findMany({
        where: {
          userId: teacher.userId,
          date: {
            startsWith: datePrefix
          }
        }
      });

      let presentDays = 0.0;
      let halfDays = 0.0;
      let absentDays = 0.0;
      let leaveDays = 0.0;

      for (const att of attendances) {
        if (att.status === "PRESENT") presentDays++;
        else if (att.status === "HALF_DAY") halfDays++;
        else if (att.status === "ABSENT") absentDays++;
        else if (att.status === "LEAVE") leaveDays++;
      }

      // Calculate unpaid leave days
      const startOfYear = new Date(Date.UTC(parseInt(year), 0, 1));
      const endOfTargetMonth = new Date(Date.UTC(parseInt(year), monthIndex + 1, 0, 23, 59, 59, 999));

      const approvedLeaves = await prisma.leaveRequest.findMany({
        where: {
          userId: teacher.userId,
          status: "APPROVED",
          fromDate: {
            gte: startOfYear,
            lte: endOfTargetMonth
          }
        },
        include: {
          leaveTypeRel: true
        },
        orderBy: { fromDate: "asc" }
      });

      const leaveTypeDaysUsed = new Map<string, number>();
      let unpaidLeaveDaysInTargetMonth = 0;

      for (const leave of approvedLeaves) {
        const leaveStart = new Date(leave.fromDate);
        const leaveEnd = new Date(leave.toDate);
        leaveStart.setUTCHours(0, 0, 0, 0);
        leaveEnd.setUTCHours(0, 0, 0, 0);

        // Determine key, limit, and whether it's unpaid by default
        const key = leave.leaveTypeId || (leave.leaveType === "Casual Leave" ? "CASUAL" : (leave.leaveType === "Sick Leave" ? "SICK" : "OTHER"));
        let limit = 0;
        let isUnpaid = false;
        const period = leave.leaveTypeRel?.period || "YEARLY";

        if (leave.leaveTypeRel) {
          const lt = leave.leaveTypeRel;
          isUnpaid = lt.isUnpaid;
          const exp = teacher.experienceYears ?? 0;
          if (exp < 2) {
            limit = lt.maxDays;
          } else if (exp <= 5) {
            limit = lt.maxDaysMid ?? lt.maxDays;
          } else {
            limit = lt.maxDaysSenior ?? lt.maxDays;
          }
        } else {
          if (leave.leaveType === "Casual Leave") {
            limit = school.casualLeaveLimit ?? 12;
          } else if (leave.leaveType === "Sick Leave") {
            limit = school.sickLeaveLimit ?? 10;
          }
        }

        const leaveTemp = new Date(leaveStart);
        while (leaveTemp.getTime() <= leaveEnd.getTime()) {
          const leaveDateStr = leaveTemp.toISOString().split("T")[0];
          const dayOfWeek = leaveTemp.getUTCDay().toString();
          
          if (!offs.includes(dayOfWeek) && !holidaysSet.has(leaveDateStr)) {
            const isInTargetMonth = leaveTemp.getUTCMonth() === monthIndex && leaveTemp.getUTCFullYear() === parseInt(year);

            if (isUnpaid) {
              if (isInTargetMonth) unpaidLeaveDaysInTargetMonth++;
            } else {
              // Determine unique key based on period
              let trackingKey = key;
              if (period === "MONTHLY") {
                trackingKey = `${key}_${leaveTemp.getUTCFullYear()}_${leaveTemp.getUTCMonth()}`;
              }

              const currentUsed = leaveTypeDaysUsed.get(trackingKey) || 0;
              const nextUsed = currentUsed + 1;
              leaveTypeDaysUsed.set(trackingKey, nextUsed);

              if (nextUsed > limit) {
                if (isInTargetMonth) unpaidLeaveDaysInTargetMonth++;
              }
            }
          }
          leaveTemp.setUTCDate(leaveTemp.getUTCDate() + 1);
        }
      }

      // Calculate LOP days: sum of absents + unpaid leaves + 0.5 * half days (if half days are unpaid/no leave)
      const lopDays = absentDays + unpaidLeaveDaysInTargetMonth + 0.5 * halfDays;
      const baseSalary = teacher.salaryAmount;
      const lopDeduction = Math.min(baseSalary, Number(((baseSalary / workingDays) * lopDays).toFixed(2)));

      // Calculate Loan Repayment
      const activeLoans = await prisma.loanRequest.findMany({
        where: {
          userId: teacher.userId,
          status: "APPROVED",
        },
        include: {
          skipRequests: {
            where: { status: { in: ["APPROVED", "COMPLETED"] } }
          },
          foreclosure: {
            where: { status: "APPROVED" }
          }
        }
      });

      let calculatedLoanDeduction = 0.0;
      for (const loan of activeLoans) {
        const remaining = loan.amount - loan.repaidAmount;
        if (remaining <= 0) continue;

        // Check if there is an approved skip request covering target month/year
        const targetScore = parseInt(year) * 12 + (monthIndex + 1);
        const hasSkip = loan.skipRequests.some(skip => {
          const startScore = skip.fromYear * 12 + skip.fromMonth;
          const endScore = skip.toYear * 12 + skip.toMonth;
          return targetScore >= startScore && targetScore <= endScore;
        });

        if (hasSkip) {
          continue; // Skip EMI recovery
        }

        // Check if there is an approved foreclosure request for this loan and month/year
        const approvedForeclosure = loan.foreclosure;
        if (approvedForeclosure && 
            approvedForeclosure.deductionMethod === "SALARY_DEDUCTION" &&
            approvedForeclosure.salaryDeductionMonth === month &&
            approvedForeclosure.salaryDeductionYear === parseInt(year)) {
          calculatedLoanDeduction += approvedForeclosure.totalPayableAmount;
        } else {
          const emi = loan.amount / loan.installments;
          calculatedLoanDeduction += Math.min(emi, remaining);
        }
      }

      // Look up adjustments from req.body if provided
      const adj = adjustmentsMap.get(teacher.id) ?? {};
      const bonus = adj.bonus !== undefined ? parseFloat(adj.bonus) : 0.0;
      const allowances = adj.allowances !== undefined ? parseFloat(adj.allowances) : 0.0;
      const loanDeduction = adj.loanDeduction !== undefined ? parseFloat(adj.loanDeduction) : calculatedLoanDeduction;
      const remarks = adj.remarks ?? null;

      let finalNetSalary = 0.0;
      const recordComponents: any[] = [];

      if (teacher.salaryTemplate) {
        // Dynamic dynamic calculations based on Template
        const earnedMonthlyCTCBase = Math.max(0.0, baseSalary - lopDeduction);
        const templateComps = teacher.salaryTemplate.components;

        // 1. Basic Pay Component
        const basicTC = templateComps.find(tc => tc.component.name.toLowerCase().includes("basic"));
        let basicAmount = 0.0;
        if (basicTC) {
          if (basicTC.calculationType === CalculationType.PERCENTAGE_OF_CTC) {
            basicAmount = earnedMonthlyCTCBase * (basicTC.value / 100);
          } else {
            const factor = basicTC.component.isProrated ? (workingDays - lopDays) / workingDays : 1.0;
            basicAmount = basicTC.value * factor;
          }
        } else {
          // Default Basic to 50%
          basicAmount = earnedMonthlyCTCBase * 0.50;
        }
        basicAmount = Math.max(0.0, Number(basicAmount.toFixed(2)));
        let grossEarnings = basicAmount;

        recordComponents.push({
          name: basicTC?.component.name || "Basic Pay",
          amount: basicAmount,
          category: basicTC?.component.category || ComponentCategory.FIXED_EARNING
        });

        // 2. Calculate non-basic earnings (excluding Special Allowance balancing figure)
        const specialAllowanceTC = templateComps.find(tc => tc.component.name.toLowerCase().includes("special allowance"));
        for (const tc of templateComps) {
          if (tc.component.category.includes("DEDUCTION")) continue;
          if (tc.id === basicTC?.id || tc.id === specialAllowanceTC?.id) continue;

          let compAmount = 0.0;
          if (tc.calculationType === CalculationType.PERCENTAGE_OF_BASIC) {
            compAmount = basicAmount * (tc.value / 100);
          } else if (tc.calculationType === CalculationType.PERCENTAGE_OF_CTC) {
            compAmount = earnedMonthlyCTCBase * (tc.value / 100);
          } else {
            const factor = tc.component.isProrated ? (workingDays - lopDays) / workingDays : 1.0;
            compAmount = tc.value * factor;
          }
          compAmount = Math.max(0.0, Number(compAmount.toFixed(2)));
          if (compAmount > 0) {
            grossEarnings += compAmount;
            recordComponents.push({
              name: tc.component.name,
              amount: compAmount,
              category: tc.component.category
            });
          }
        }

        // 3. Compute balancing Special Allowance
        if (specialAllowanceTC) {
          const specialAllowanceAmount = Math.max(0.0, Number((earnedMonthlyCTCBase - grossEarnings).toFixed(2)));
          if (specialAllowanceAmount > 0) {
            grossEarnings += specialAllowanceAmount;
            recordComponents.push({
              name: specialAllowanceTC.component.name,
              amount: specialAllowanceAmount,
              category: specialAllowanceTC.component.category
            });
          }
        }

        // 4. Add dynamic Monthly Variable Pay (Earnings)
        for (const vp of variablePays) {
          if (vp.component.category.includes("DEDUCTION")) continue;
          grossEarnings += vp.amount;
          recordComponents.push({
            name: vp.isArrear ? `Arrear - ${vp.component.name}` : vp.component.name,
            amount: vp.amount,
            category: vp.component.category
          });
        }

        // 5. Compute statutory and regular deductions (PF, ESI, PT)
        let totalDeductions = 0.0;
        for (const tc of templateComps) {
          if (!tc.component.category.includes("DEDUCTION")) continue;

          // ESI or other threshold check
          if (tc.activeOnlyIfGrossLessThan && grossEarnings > tc.activeOnlyIfGrossLessThan) {
            continue; // skipped
          }

          let dedAmount = 0.0;
          if (tc.calculationType === CalculationType.PERCENTAGE_OF_BASIC) {
            const base = tc.calculateOnMax ? Math.min(basicAmount, tc.calculateOnMax) : basicAmount;
            dedAmount = base * (tc.value / 100);
          } else if (tc.calculationType === CalculationType.PERCENTAGE_OF_GROSS) {
            const base = tc.calculateOnMax ? Math.min(grossEarnings, tc.calculateOnMax) : grossEarnings;
            dedAmount = base * (tc.value / 100);
          } else if (tc.calculationType === CalculationType.SLAB_BASED) {
            if (tc.component.name.toLowerCase().includes("professional tax") || tc.component.name.toLowerCase().includes("pt")) {
              dedAmount = grossEarnings > 20000 ? 200 : grossEarnings >= 15000 ? 150 : 0;
            } else {
              dedAmount = 0.0;
            }
          } else if (tc.calculationType === CalculationType.FLAT_AMOUNT) {
            const factor = tc.component.isProrated ? (workingDays - lopDays) / workingDays : 1.0;
            dedAmount = tc.value * factor;
          }

          dedAmount = Math.max(0.0, Number(dedAmount.toFixed(2)));
          if (dedAmount > 0) {
            totalDeductions += dedAmount;
            recordComponents.push({
              name: tc.component.name,
              amount: dedAmount,
              category: tc.component.category
            });
          }
        }

        // 6. Add dynamic Monthly Variable Pay (Deductions)
        for (const vp of variablePays) {
          if (!vp.component.category.includes("DEDUCTION")) continue;
          totalDeductions += vp.amount;
          recordComponents.push({
            name: vp.isArrear ? `Arrear - ${vp.component.name}` : vp.component.name,
            amount: vp.amount,
            category: vp.component.category
          });
        }

        finalNetSalary = Math.max(0.0, Number((grossEarnings - totalDeductions - loanDeduction + bonus + allowances).toFixed(2)));

      } else {
        // Fallback backward compatible calculation
        const basicSalaryAmount = Math.max(0.0, Number((baseSalary - lopDeduction).toFixed(2)));
        recordComponents.push({
          name: "Basic Salary",
          amount: basicSalaryAmount,
          category: ComponentCategory.FIXED_EARNING
        });

        let grossEarnings = basicSalaryAmount;
        let totalDeductions = 0.0;

        // Add dynamic Variable Pays to fallback too!
        for (const vp of variablePays) {
          if (vp.component.category.includes("DEDUCTION")) {
            totalDeductions += vp.amount;
          } else {
            grossEarnings += vp.amount;
          }
          recordComponents.push({
            name: vp.isArrear ? `Arrear - ${vp.component.name}` : vp.component.name,
            amount: vp.amount,
            category: vp.component.category
          });
        }

        finalNetSalary = Math.max(0.0, Number((grossEarnings - totalDeductions - loanDeduction + bonus + allowances).toFixed(2)));
      }

      // Add adjustments to component line items for UI detailed viewing
      if (bonus > 0) {
        recordComponents.push({
          name: "Bonus",
          amount: bonus,
          category: "EARNING"
        });
      }
      if (allowances > 0) {
        recordComponents.push({
          name: "Additional Allowance",
          amount: allowances,
          category: "EARNING"
        });
      }
      if (loanDeduction > 0) {
        recordComponents.push({
          name: "Loan Repayment Recovery",
          amount: loanDeduction,
          category: "DEDUCTION"
        });
      }

      salaryOps.push(
        prisma.salaryRecord.create({
          data: {
            teacherId: teacher.id,
            month,
            year: parseInt(year),
            amount: finalNetSalary,
            status: "PENDING",
            baseSalary,
            workingDays,
            presentDays,
            halfDays,
            absentDays,
            leaveDays: leaveDays - unpaidLeaveDaysInTargetMonth, // paid leaves count
            lopDeduction,
            loanDeduction,
            bonus,
            allowances,
            remarks,
            components: {
              createMany: {
                data: recordComponents
              }
            }
          }
        })
      );
    }

    const createdSalaries = await prisma.$transaction(salaryOps);
    res.json({ message: "Salaries generated successfully for " + month + " " + year, salaries: createdSalaries });
  } catch (error: any) {
    console.error("[GENERATE_SALARIES_ERROR]:", error);
    res.status(500).json({ error: error.message || "Failed to generate monthly payroll" });
  }
}

export async function paySalary(req: AuthenticatedRequest, res: Response) {
  try {
    const { salaryRecordId } = req.params;

    const record = await prisma.salaryRecord.findUnique({
      where: { id: salaryRecordId },
      include: { teacher: { include: { user: true } } }
    });

    if (!record) {
      return res.status(404).json({ error: "Salary record not found" });
    }

    if (record.status === "PAID") {
      return res.status(400).json({ error: "Salary has already been disbursed" });
    }

    // Process loan repayment if loanDeduction > 0
    if (record.loanDeduction > 0) {
      let remainingDeduction = record.loanDeduction;
      
      // Find active loans for this teacher
      const activeLoans = await prisma.loanRequest.findMany({
        where: {
          userId: record.teacher.userId,
          status: "APPROVED",
        },
        include: {
          skipRequests: {
            where: { status: "APPROVED" }
          },
          foreclosure: {
            where: { status: "APPROVED" }
          }
        },
        orderBy: { createdAt: "asc" }
      });

      const monthNames = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];
      const recordMonthIndex = monthNames.indexOf(record.month);
      const targetScore = record.year * 12 + (recordMonthIndex + 1);

      for (const loan of activeLoans) {
        const unpaid = loan.amount - loan.repaidAmount;
        if (unpaid <= 0) continue;

        // Check if skip is active for this month/year
        const skip = loan.skipRequests.find(s => {
          const startScore = s.fromYear * 12 + s.fromMonth;
          const endScore = s.toYear * 12 + s.toMonth;
          return targetScore >= startScore && targetScore <= endScore;
        });

        if (skip) {
          // If this is the last month of the skip, set status to COMPLETED
          const endScore = skip.toYear * 12 + skip.toMonth;
          if (targetScore === endScore) {
            await prisma.loanSkipRequest.update({
              where: { id: skip.id },
              data: { status: "COMPLETED" }
            });
            // Update loan isPaused to false if there are no other active skip requests
            const otherSkipsCount = await prisma.loanSkipRequest.count({
              where: {
                loanId: loan.id,
                status: "APPROVED"
              }
            });
            if (otherSkipsCount === 0) {
              await prisma.loanRequest.update({
                where: { id: loan.id },
                data: { isPaused: false }
              });
            }
          }
          continue; // skipped
        }

        // Check if foreclosure is active for this month/year
        const fc = loan.foreclosure;
        const isForeclosureMonth = fc && 
          fc.deductionMethod === "SALARY_DEDUCTION" &&
          fc.salaryDeductionMonth === record.month &&
          fc.salaryDeductionYear === record.year;

        if (isForeclosureMonth && fc) {
          const repaymentAmount = Math.min(remainingDeduction, fc.totalPayableAmount);
          if (repaymentAmount > 0) {
            await prisma.loanRequest.update({
              where: { id: loan.id },
              data: {
                repaidAmount: loan.amount, // fully repaid
                remainingBalance: 0,
                isPaused: false
              }
            });

            await prisma.loanForeclosure.update({
              where: { id: fc.id },
              data: { status: "SETTLED" }
            });

            await prisma.loanRepayment.create({
              data: {
                loanId: loan.id,
                repaymentType: "MANUAL_FORECLOSURE",
                salaryRecordId: record.id,
                amount: repaymentAmount,
                month: recordMonthIndex + 1,
                year: record.year,
                remarks: "Salary deduction foreclosure settlement"
              }
            });

            remainingDeduction -= repaymentAmount;
          }
        } else {
          // Regular EMI repayment
          const emi = loan.amount / loan.installments;
          const repayment = Math.min(remainingDeduction, unpaid, emi);
          if (repayment > 0) {
            const nextRepaidAmount = loan.repaidAmount + repayment;
            await prisma.loanRequest.update({
              where: { id: loan.id },
              data: {
                repaidAmount: nextRepaidAmount,
                remainingBalance: Math.max(0.0, loan.amount - nextRepaidAmount)
              }
            });

            await prisma.loanRepayment.create({
              data: {
                loanId: loan.id,
                repaymentType: "PAYROLL_DEDUCTION",
                salaryRecordId: record.id,
                amount: repayment,
                month: recordMonthIndex + 1,
                year: record.year,
                remarks: "Regular payroll deduction (EMI)"
              }
            });

            remainingDeduction -= repayment;
          }
        }

        if (remainingDeduction <= 0) break;
      }
    }

    const updated = await prisma.salaryRecord.update({
      where: { id: salaryRecordId },
      data: { status: "PAID" }
    });

    res.json({ message: "Salary marked as PAID and loan repayments recorded", record: updated });
  } catch (error: any) {
    res.status(500).json({ error: error.message || "Failed to record payroll payment" });
  }
}

export async function updateSalaryRecord(req: AuthenticatedRequest, res: Response) {
  try {
    const { salaryRecordId } = req.params;
    const { bonus, allowances, remarks, loanDeduction } = req.body;

    const record = await prisma.salaryRecord.findUnique({
      where: { id: salaryRecordId }
    });

    if (!record) {
      return res.status(404).json({ error: "Salary record not found" });
    }

    if (record.status === "PAID") {
      return res.status(400).json({ error: "Cannot modify a disbursed salary record" });
    }

    const updatedBonus = bonus !== undefined ? parseFloat(bonus) : record.bonus;
    const updatedAllowances = allowances !== undefined ? parseFloat(allowances) : record.allowances;
    const updatedLoanDeduction = loanDeduction !== undefined ? parseFloat(loanDeduction) : record.loanDeduction;
    const updatedRemarks = remarks !== undefined ? remarks : record.remarks;

    const netSalary = Math.max(0.0, Number((record.baseSalary - record.lopDeduction - updatedLoanDeduction + updatedBonus + updatedAllowances).toFixed(2)));

    const updated = await prisma.salaryRecord.update({
      where: { id: salaryRecordId },
      data: {
        bonus: updatedBonus,
        allowances: updatedAllowances,
        loanDeduction: updatedLoanDeduction,
        remarks: updatedRemarks,
        amount: netSalary
      }
    });

    res.json({ message: "Salary adjustments saved successfully", record: updated });
  } catch (error: any) {
    res.status(500).json({ error: error.message || "Failed to update salary record" });
  }
}

export async function advanceSalaryStatus(req: AuthenticatedRequest, res: Response) {
  try {
    const { ids, nextStatus } = req.body;
    if (!ids || !Array.isArray(ids) || !nextStatus) {
      return res.status(400).json({ error: "Missing ids or nextStatus in request body" });
    }

    const validStatuses = ["PENDING", "DRAFT", "PROCESSED", "APPROVED", "PAID"];
    if (!validStatuses.includes(nextStatus)) {
      return res.status(400).json({ error: `Invalid status: \${nextStatus}. Must be one of \${validStatuses.join(", ")}` });
    }

    if (nextStatus === "PAID") {
      let count = 0;
      for (const salaryRecordId of ids) {
        const record = await prisma.salaryRecord.findUnique({
          where: { id: salaryRecordId },
          include: { teacher: { include: { user: true } } }
        });

        if (!record || record.status === "PAID") continue;

        if (record.loanDeduction > 0) {
          let remainingDeduction = record.loanDeduction;
          const activeLoans = await prisma.loanRequest.findMany({
            where: {
              userId: record.teacher.userId,
              status: "APPROVED",
            },
            include: {
              skipRequests: {
                where: { status: "APPROVED" }
              },
              foreclosure: {
                where: { status: "APPROVED" }
              }
            },
            orderBy: { createdAt: "asc" }
          });

          const monthNames = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];
          const recordMonthIndex = monthNames.indexOf(record.month);
          const targetScore = record.year * 12 + (recordMonthIndex + 1);

          for (const loan of activeLoans) {
            const unpaid = loan.amount - loan.repaidAmount;
            if (unpaid <= 0) continue;

            const skip = loan.skipRequests.find(s => {
              const startScore = s.fromYear * 12 + s.fromMonth;
              const endScore = s.toYear * 12 + s.toMonth;
              return targetScore >= startScore && targetScore <= endScore;
            });

            if (skip) {
              const endScore = skip.toYear * 12 + skip.toMonth;
              if (targetScore === endScore) {
                await prisma.loanSkipRequest.update({
                  where: { id: skip.id },
                  data: { status: "COMPLETED" }
                });
                const otherSkipsCount = await prisma.loanSkipRequest.count({
                  where: { loanId: loan.id, status: "APPROVED" }
                });
                if (otherSkipsCount === 0) {
                  await prisma.loanRequest.update({
                    where: { id: loan.id },
                    data: { isPaused: false }
                  });
                }
              }
              continue;
            }

            const fc = loan.foreclosure;
            const isForeclosureMonth = fc && 
              fc.deductionMethod === "SALARY_DEDUCTION" &&
              fc.salaryDeductionMonth === record.month &&
              fc.salaryDeductionYear === record.year;

            if (isForeclosureMonth && fc) {
              const repaymentAmount = Math.min(remainingDeduction, fc.totalPayableAmount);
              if (repaymentAmount > 0) {
                await prisma.loanRequest.update({
                  where: { id: loan.id },
                  data: {
                    repaidAmount: loan.amount,
                    remainingBalance: 0,
                    isPaused: false
                  }
                });

                await prisma.loanForeclosure.update({
                  where: { id: fc.id },
                  data: { status: "SETTLED" }
                });

                await prisma.loanRepayment.create({
                  data: {
                    loanId: loan.id,
                    repaymentType: "MANUAL_FORECLOSURE",
                    salaryRecordId: record.id,
                    amount: repaymentAmount,
                    month: recordMonthIndex + 1,
                    year: record.year,
                    remarks: "Salary deduction foreclosure settlement"
                  }
                });

                remainingDeduction -= repaymentAmount;
              }
            } else {
              const emi = loan.amount / loan.installments;
              const repayment = Math.min(remainingDeduction, unpaid, emi);
              if (repayment > 0) {
                const nextRepaidAmount = loan.repaidAmount + repayment;
                await prisma.loanRequest.update({
                  where: { id: loan.id },
                  data: {
                    repaidAmount: nextRepaidAmount,
                    remainingBalance: Math.max(0.0, loan.amount - nextRepaidAmount)
                  }
                });

                await prisma.loanRepayment.create({
                  data: {
                    loanId: loan.id,
                    repaymentType: "PAYROLL_DEDUCTION",
                    salaryRecordId: record.id,
                    amount: repayment,
                    month: recordMonthIndex + 1,
                    year: record.year,
                    remarks: "Regular payroll deduction (EMI)"
                  }
                });

                remainingDeduction -= repayment;
              }
            }

            if (remainingDeduction <= 0) break;
          }
        }

        await prisma.salaryRecord.update({
          where: { id: salaryRecordId },
          data: { status: "PAID" }
        });
        count++;
      }
      res.json({ message: `Successfully updated \${count} salary records to PAID`, count });
    } else {
      const updated = await prisma.salaryRecord.updateMany({
        where: { id: { in: ids } },
        data: { status: nextStatus }
      });
      res.json({ message: `Successfully updated \${updated.count} salary records to \${nextStatus}`, count: updated.count });
    }
  } catch (error: any) {
    res.status(500).json({ error: error.message || "Failed to advance salary status" });
  }
}

export async function getExpenses(req: AuthenticatedRequest, res: Response) {
  try {
    const schoolId = req.user?.schoolId;
    if (!schoolId) {
      return res.status(400).json({ error: "Missing school context" });
    }

    const expenses = await prisma.expense.findMany({
      where: { schoolId },
      include: {
        recordedBy: { select: { fullName: true } }
      },
      orderBy: { date: "desc" }
    });

    res.json(expenses);
  } catch (error: any) {
    res.status(500).json({ error: error.message || "Failed to fetch expense records" });
  }
}

export async function addExpense(req: AuthenticatedRequest, res: Response) {
  try {
    const { category, amount, description, date } = req.body;
    const schoolId = req.user?.schoolId;
    const userId = req.user?.id;

    if (!category || !amount || !description || !schoolId || !userId) {
      return res.status(400).json({ error: "Missing required expense details" });
    }

    const expense = await prisma.expense.create({
      data: {
        schoolId,
        category,
        amount: parseFloat(amount),
        description,
        date: date ? new Date(date) : new Date(),
        recordedById: userId
      }
    });

    res.status(201).json({ message: "Expense logged successfully", expense });
  } catch (error: any) {
    res.status(500).json({ error: error.message || "Failed to log school expense" });
  }
}

export async function getEvents(req: AuthenticatedRequest, res: Response) {
  try {
    const schoolId = req.user?.schoolId;
    if (!schoolId) {
      return res.status(400).json({ error: "Missing school context" });
    }

    const userRole = req.user?.role;
    let audienceFilter: string[] = ["ALL"];

    if (userRole === "PARENT") {
      audienceFilter.push("PARENT", "PARENTS");
    } else if (
      userRole === "TEACHER" ||
      userRole === "PT" ||
      userRole === "STAFF_HEAD" ||
      userRole === "PRINCIPAL" ||
      userRole === "HM"
    ) {
      audienceFilter.push("TEACHER", "TEACHERS");
    } else if (userRole === "CORRESPONDENT") {
      audienceFilter.push("PARENT", "PARENTS", "TEACHER", "TEACHERS");
    }

    const events = await prisma.event.findMany({
      where: {
        schoolId,
        targetAudience: { in: audienceFilter }
      },
      orderBy: { date: "asc" }
    });

    res.json(events);
  } catch (error: any) {
    res.status(500).json({ error: error.message || "Failed to load events" });
  }
}

export async function createEvent(req: AuthenticatedRequest, res: Response) {
  try {
    const { title, description, date, type, targetAudience } = req.body;
    const schoolId = req.user?.schoolId;

    if (!title || !description || !date || !type || !schoolId) {
      return res.status(400).json({ error: "Missing event registration details" });
    }

    const dateOnly = date.split("T")[0];
    const eventDate = new Date(`${dateOnly}T00:00:00.000Z`);

    const event = await prisma.event.create({
      data: {
        schoolId,
        title,
        description,
        date: eventDate,
        type,
        targetAudience: targetAudience || "ALL"
      }
    });

    res.status(201).json({ message: "Event scheduled successfully", event });
  } catch (error: any) {
    res.status(500).json({ error: error.message || "Failed to register event" });
  }
}

export async function deleteEvent(req: AuthenticatedRequest, res: Response) {
  try {
    const { id } = req.params;
    const schoolId = req.user?.schoolId;

    if (!schoolId) {
      return res.status(400).json({ error: "Missing school context" });
    }

    const existing = await prisma.event.findUnique({
      where: { id }
    });

    if (!existing || existing.schoolId !== schoolId) {
      return res.status(404).json({ error: "Event not found" });
    }

    await prisma.event.delete({
      where: { id }
    });

    res.json({ message: "Event cancelled successfully" });
  } catch (error: any) {
    res.status(500).json({ error: error.message || "Failed to cancel event" });
  }
}

export async function getNotices(req: AuthenticatedRequest, res: Response) {
  try {
    const schoolId = req.user?.schoolId;
    if (!schoolId) {
      return res.status(400).json({ error: "Missing school context" });
    }

    const notices = await prisma.notice.findMany({
      where: { schoolId },
      orderBy: { date: "desc" }
    });

    res.json(notices);
  } catch (error: any) {
    res.status(500).json({ error: error.message || "Failed to retrieve notice board items" });
  }
}

export async function createNotice(req: AuthenticatedRequest, res: Response) {
  try {
    const { title, description, attachmentUrl } = req.body;
    const schoolId = req.user?.schoolId;

    if (!title || !description || !schoolId) {
      return res.status(400).json({ error: "Notice title and description are required" });
    }

    const notice = await prisma.notice.create({
      data: {
        schoolId,
        title,
        description,
        attachmentUrl
      }
    });

    res.status(201).json({ message: "Notice posted successfully", notice });
  } catch (error: any) {
    res.status(500).json({ error: error.message || "Failed to upload notice" });
  }
}

export async function createFeeRecord(req: AuthenticatedRequest, res: Response) {
  try {
    const { studentId, category, amount, dueDate } = req.body;

    if (!studentId || !category || amount === undefined || !dueDate) {
      return res.status(400).json({ error: "Required fields: studentId, category, amount, dueDate" });
    }

    const feeRecord = await prisma.feeRecord.create({
      data: {
        studentId,
        category,
        amount: parseFloat(amount),
        paidAmount: 0.0,
        status: "PENDING",
        dueDate: new Date(dueDate)
      }
    });

    res.status(201).json({ message: "Fee record created successfully", feeRecord });
  } catch (error: any) {
    res.status(500).json({ error: error.message || "Failed to create fee record" });
  }
}

export async function updateFeeRecord(req: AuthenticatedRequest, res: Response) {
  try {
    const { feeRecordId } = req.params;
    const { paidAmount, amount } = req.body;

    const existing = await prisma.feeRecord.findUnique({ where: { id: feeRecordId } });
    if (!existing) {
      return res.status(404).json({ error: "Fee record not found" });
    }

    const newAmount = amount !== undefined ? parseFloat(amount) : existing.amount;
    const newPaidAmount = paidAmount !== undefined ? parseFloat(paidAmount) : existing.paidAmount;

    let status = "PENDING";
    if (newPaidAmount >= newAmount) {
      status = "PAID";
    } else if (newPaidAmount > 0) {
      status = "PARTIAL";
    }

    const updated = await prisma.feeRecord.update({
      where: { id: feeRecordId },
      data: {
        amount: newAmount,
        paidAmount: newPaidAmount,
        status
      }
    });

    res.json({ message: "Fee record updated successfully", feeRecord: updated });
  } catch (error: any) {
    res.status(500).json({ error: error.message || "Failed to update fee record" });
  }
}

export async function sendMessageToParents(req: AuthenticatedRequest, res: Response) {
  try {
    const { studentId, title, content, type } = req.body;
    const senderId = req.user?.id;

    if (!senderId) {
      return res.status(401).json({ error: "Unauthorized" });
    }

    if (!studentId || !title || !content) {
      return res.status(400).json({ error: "Missing required fields (studentId, title, content)" });
    }

    // Find all parents of the student
    const studentParents = await prisma.parentToStudent.findMany({
      where: { studentId },
      include: {
        parent: true
      }
    });

    if (studentParents.length === 0) {
      return res.status(404).json({ error: "No parent profile found for this student" });
    }

    // Create a message for each parent user
    const messageOps = studentParents.map((sp) => {
      return prisma.message.create({
        data: {
          senderId,
          receiverId: sp.parent.userId,
          title,
          content,
          type: type || "GENERAL"
        }
      });
    });

    const messages = await prisma.$transaction(messageOps);

    res.status(201).json({ message: "Messages sent to parents successfully", messages });
  } catch (error: any) {
    res.status(500).json({ error: error.message || "Failed to send message to parents" });
  }
}

export async function getReceivedMessages(req: AuthenticatedRequest, res: Response) {
  try {
    const userId = req.user?.id;

    if (!userId) {
      return res.status(401).json({ error: "Unauthorized" });
    }

    const messages = await prisma.message.findMany({
      where: { receiverId: userId },
      include: {
        sender: {
          select: {
            fullName: true,
            role: true,
            profileImage: true
          }
        }
      },
      orderBy: { createdAt: "desc" }
    });

    res.json(messages);
  } catch (error: any) {
    res.status(500).json({ error: error.message || "Failed to fetch messages" });
  }
}

export async function sendBulkFeeReminders(req: AuthenticatedRequest, res: Response) {
  try {
    const schoolId = req.user?.schoolId;
    const senderId = req.user?.id;

    if (!schoolId || !senderId) {
      return res.status(400).json({ error: "Missing school or user context" });
    }

    // Find all students in this school with pending/partial fee records
    const studentsWithPendingFees = await prisma.student.findMany({
      where: {
        schoolId,
        feeRecords: {
          some: {
            status: { in: ["PENDING", "PARTIAL"] }
          }
        }
      },
      include: {
        parents: {
          include: {
            parent: true
          }
        },
        feeRecords: {
          where: {
            status: { in: ["PENDING", "PARTIAL"] }
          }
        }
      }
    });

    if (studentsWithPendingFees.length === 0) {
      return res.json({ message: "No students with outstanding fees found.", count: 0 });
    }

    let messagesSentCount = 0;
    const messageOps: any[] = [];

    for (const student of studentsWithPendingFees) {
      // Calculate total outstanding amount for this student
      const outstandingAmount = student.feeRecords.reduce(
        (sum, record) => sum + (record.amount - record.paidAmount),
        0
      );

      if (outstandingAmount <= 0) continue;

      const title = "Urgent: Fee Payment Reminder";
      const content = `Dear Parent, this is a reminder that your child ${student.fullName} has an outstanding fee balance of ₹${outstandingAmount.toFixed(0)}. Please clear the dues at your earliest convenience. Thank you.`;

      for (const sp of student.parents) {
        messageOps.push(
          prisma.message.create({
            data: {
              senderId,
              receiverId: sp.parent.userId,
              title,
              content,
              type: "REMINDER"
            }
          })
        );
        messagesSentCount++;
      }
    }

    if (messageOps.length > 0) {
      await prisma.$transaction(messageOps);
    }

    res.json({
      message: `Fee reminders sent successfully to ${messagesSentCount} parents.`,
      count: messagesSentCount
    });
  } catch (error: any) {
    res.status(500).json({ error: error.message || "Failed to send bulk fee reminders" });
  }
}

export async function applyRectification(req: AuthenticatedRequest, res: Response) {
  try {
    const { date, checkInTime, checkOutTime, reason } = req.body;
    const userId = req.user?.id;
    const schoolId = req.user?.schoolId;

    if (!date || !reason || !userId || !schoolId) {
      return res.status(400).json({ error: "Missing required rectification properties" });
    }

    const todayStr = new Date().toISOString().split("T")[0];
    if (date > todayStr) {
      return res.status(400).json({ error: "Cannot apply for rectification on future dates." });
    }

    // Check if the user is on approved leave for that date
    const checkDate = new Date(date + "T00:00:00.000Z");
    const approvedLeave = await prisma.leaveRequest.findFirst({
      where: {
        userId,
        status: "APPROVED",
        fromDate: { lte: checkDate },
        toDate: { gte: checkDate }
      }
    });
    if (approvedLeave) {
      return res.status(400).json({ error: "Cannot apply for rectification on a day you were on approved leave." });
    }

    // Check if weekend or school holiday
    const school = await prisma.school.findUnique({
      where: { id: schoolId },
      include: { holidays: true }
    });

    if (!school) {
      return res.status(404).json({ error: "School context not found" });
    }

    const offs = school.weeklyOffs ? school.weeklyOffs.split(",") : ["0"];
    const dayOfWeek = checkDate.getUTCDay().toString();
    const isWeekend = offs.includes(dayOfWeek);
    const isHoliday = school.holidays.some(h => h.date.toISOString().split("T")[0] === date);

    if (isWeekend || isHoliday) {
      return res.status(400).json({ error: "Cannot apply for rectification on leave, weekends or holidays." });
    }

    // Check monthly limit
    const [yearStr, monthStr] = date.split("-");
    const startOfMonth = `${yearStr}-${monthStr}-01`;
    const year = parseInt(yearStr);
    const month = parseInt(monthStr);
    const lastDay = new Date(year, month, 0).getDate();
    const endOfMonth = `${yearStr}-${monthStr}-${lastDay.toString().padStart(2, "0")}`;

    const count = await prisma.attendanceRectification.count({
      where: {
        userId,
        date: {
          gte: startOfMonth,
          lte: endOfMonth
        },
        status: { in: ["APPROVED", "PENDING"] }
      }
    });

    const limit = school.rectificationLimit ?? 3;
    if (count >= limit) {
      return res.status(400).json({
        error: `Monthly rectification request limit exceeded. You are allowed only ${limit} rectifications per month.`
      });
    }

    const rectification = await prisma.attendanceRectification.upsert({
      where: {
        userId_date: {
          userId,
          date
        }
      },
      update: {
        checkInTime,
        checkOutTime,
        reason,
        status: "PENDING",
        rejectionReason: null,
        approvedById: null
      },
      create: {
        userId,
        date,
        checkInTime,
        checkOutTime,
        reason,
        status: "PENDING"
      }
    });

    res.status(201).json({ message: "Attendance rectification request submitted successfully", rectification });
  } catch (error: any) {
    res.status(500).json({ error: error.message || "Failed to submit rectification request" });
  }
}

export async function getRectifications(req: AuthenticatedRequest, res: Response) {
  try {
    const userId = req.user?.id;
    const role = req.user?.role;
    const schoolId = req.user?.schoolId;

    if (!userId || !schoolId) {
      return res.status(400).json({ error: "Missing identity context" });
    }

    let rectifications;
    if (role === "CORRESPONDENT" || role === "PRINCIPAL" || role === "HM") {
      rectifications = await prisma.attendanceRectification.findMany({
        where: {
          user: { schoolId }
        },
        include: {
          user: { select: { fullName: true, role: true } },
          approvedBy: { select: { fullName: true, role: true } }
        },
        orderBy: { date: "desc" }
      });
    } else {
      rectifications = await prisma.attendanceRectification.findMany({
        where: { userId },
        include: {
          user: { select: { fullName: true, role: true } },
          approvedBy: { select: { fullName: true, role: true } }
        },
        orderBy: { date: "desc" }
      });
    }

    res.json(rectifications);
  } catch (error: any) {
    res.status(500).json({ error: error.message || "Failed to retrieve rectification requests" });
  }
}

export async function updateRectificationStatus(req: AuthenticatedRequest, res: Response) {
  try {
    const { id } = req.params;
    const { status, rejectionReason } = req.body;
    const approverId = req.user?.id;
    const approverRole = req.user?.role;
    const schoolId = req.user?.schoolId;

    if (!approverId || !schoolId || !approverRole) {
      return res.status(401).json({ error: "Unauthorized" });
    }

    if (!["CORRESPONDENT", "PRINCIPAL", "HM"].includes(approverRole)) {
      return res.status(403).json({ error: "Only Correspondent, Principal, or HM can approve/reject rectification requests." });
    }

    if (!status || !["APPROVED", "REJECTED"].includes(status)) {
      return res.status(400).json({ error: "Valid status (APPROVED or REJECTED) is required" });
    }

    const rectification = await prisma.attendanceRectification.findUnique({
      where: { id },
      include: { user: true }
    });

    if (!rectification) {
      return res.status(404).json({ error: "Rectification request not found" });
    }

    if (rectification.user.schoolId !== schoolId) {
      return res.status(403).json({ error: "Unauthorized: Request belongs to a different school." });
    }

    if (status === "APPROVED") {
      const inTime = rectification.checkInTime || "09:00 AM";
      const outTime = rectification.checkOutTime || "05:00 PM";

      const [year, month, day] = rectification.date.split("-").map(Number);
      
      const parseTime = (timeStr: string): Date => {
        let hours = 0;
        let minutes = 0;
        const match = timeStr.match(/^(\d{1,2}):(\d{2})\s*(AM|PM)?$/i);
        if (match) {
          hours = parseInt(match[1]);
          minutes = parseInt(match[2]);
          const ampm = match[3];
          if (ampm) {
            if (ampm.toUpperCase() === "PM" && hours < 12) {
              hours += 12;
            } else if (ampm.toUpperCase() === "AM" && hours === 12) {
              hours = 0;
            }
          }
        } else {
          const parts = timeStr.split(":");
          hours = parseInt(parts[0]) || 0;
          minutes = parseInt(parts[1]) || 0;
        }
        return new Date(year, month - 1, day, hours, minutes, 0, 0);
      };

      const checkInDate = parseTime(inTime);
      const checkOutDate = parseTime(outTime);

      const totalHours = (checkOutDate.getTime() - checkInDate.getTime()) / (1000 * 60 * 60);

      const schoolInfo = await prisma.school.findUnique({ where: { id: schoolId } });
      const halfDayThreshold = schoolInfo?.halfDayThreshold ?? 4.0;
      const fullDayThreshold = schoolInfo?.fullDayThreshold ?? 8.0;

      let attendanceStatus = "PRESENT";
      if (totalHours < halfDayThreshold) {
        attendanceStatus = "ABSENT";
      } else if (totalHours < fullDayThreshold) {
        attendanceStatus = "HALF_DAY";
      }

      await prisma.staffAttendance.upsert({
        where: {
          userId_date: {
            userId: rectification.userId,
            date: rectification.date
          }
        },
        update: {
          firstCheckIn: checkInDate,
          lastCheckOut: checkOutDate,
          totalHours: Number(totalHours.toFixed(2)),
          status: attendanceStatus
        },
        create: {
          userId: rectification.userId,
          date: rectification.date,
          firstCheckIn: checkInDate,
          lastCheckOut: checkOutDate,
          totalHours: Number(totalHours.toFixed(2)),
          status: attendanceStatus
        }
      });
    }

    const updated = await prisma.attendanceRectification.update({
      where: { id },
      data: {
        status,
        approvedById: approverId,
        rejectionReason: status === "REJECTED" ? rejectionReason : null
      }
    });

    res.json({ message: `Rectification request ${status.toLowerCase()} successfully`, rectification: updated });
  } catch (error: any) {
    res.status(500).json({ error: error.message || "Failed to update rectification request" });
  }
}

function numberToWords(amount: number): string {
  const sglDigit = ["Zero", "One", "Two", "Three", "Four", "Five", "Six", "Seven", "Eight", "Nine"],
    dblDigit = ["Ten", "Eleven", "Twelve", "Thirteen", "Fourteen", "Fifteen", "Sixteen", "Seventeen", "Eighteen", "Nineteen"],
    tensPlace = ["", "Ten", "Twenty", "Thirty", "Forty", "Fifty", "Sixty", "Seventy", "Eighty", "Ninety"],
    handle_tens = (num: number) => {
      if (num < 10) return sglDigit[num];
      else if (num < 20) return dblDigit[num - 10];
      else {
        let ten = Math.floor(num / 10);
        let one = num % 10;
        if (one > 0) return tensPlace[ten] + " " + sglDigit[one];
        return tensPlace[ten];
      }
    };
  
  const intVal = Math.floor(amount);
  const decVal = Math.round((amount - intVal) * 100);
  
  let str = "";
  if (intVal === 0) str = "Zero";
  else {
    let crores = Math.floor(intVal / 10000000);
    let remainder = intVal % 10000000;
    let lakhs = Math.floor(remainder / 100000);
    remainder = remainder % 100000;
    let thousands = Math.floor(remainder / 1000);
    remainder = remainder % 1000;
    let hundreds = Math.floor(remainder / 100);
    let tens = remainder % 100;
    
    if (crores > 0) str += handle_tens(crores) + " Crore ";
    if (lakhs > 0) str += handle_tens(lakhs) + " Lakh ";
    if (thousands > 0) str += handle_tens(thousands) + " Thousand ";
    if (hundreds > 0) str += handle_tens(hundreds) + " Hundred ";
    if (tens > 0) {
      if (str !== "") str += "and ";
      str += handle_tens(tens);
    }
  }
  str += " Rupees";
  if (decVal > 0) {
    str += " and " + handle_tens(decVal) + " Paise";
  }
  return str + " Only";
}

export async function printPayslip(req: AuthenticatedRequest, res: Response) {
  try {
    const { salaryRecordId } = req.params;
    const userId = req.user?.id;
    const role = req.user?.role;
    const schoolId = req.user?.schoolId;

    if (!userId || !schoolId) {
      return res.status(401).json({ error: "Unauthorized" });
    }

    const record = await prisma.salaryRecord.findUnique({
      where: { id: salaryRecordId },
      include: {
        teacher: {
          include: {
            user: {
              include: {
                school: true
              }
            }
          }
        },
        components: true
      }
    });

    if (!record) {
      return res.status(404).send("<h3>Salary record not found</h3>");
    }

    // Security check
    if (record.teacher.user.schoolId !== schoolId) {
      return res.status(403).send("<h3>Access denied: School mismatch</h3>");
    }

    if (role !== "CORRESPONDENT" && role !== "PRINCIPAL" && role !== "HM") {
      if (record.teacher.userId !== userId) {
        return res.status(403).send("<h3>Access denied: This is not your payslip</h3>");
      }
    }

    const school = record.teacher.user.school;
    const teacherUser = record.teacher.user;
    const teacherProfile = record.teacher;

    // Filter components to avoid duplicates of adjusted fields
    const filteredComponents = record.components.filter(c => {
      const nameLower = c.name.toLowerCase();
      return !nameLower.includes("bonus") && 
             !nameLower.includes("allowance") && 
             !nameLower.includes("loan repayment") && 
             !nameLower.includes("recovery") && 
             !nameLower.includes("loss of pay") && 
             !nameLower.includes("lop");
    });

    // Classify earnings and deductions
    const earnings: { name: string; amount: number }[] = [];
    const deductions: { name: string; amount: number }[] = [];

    // Add filtered components
    for (const comp of filteredComponents) {
      const item = { name: comp.name, amount: comp.amount };
      if (comp.category.includes("DEDUCTION")) {
        deductions.push(item);
      } else {
        earnings.push(item);
      }
    }

    // If components is empty, add Base Salary as fallback
    if (earnings.length === 0) {
      earnings.push({ name: "Base Salary", amount: record.baseSalary });
    }

    // Append record level values if they are greater than 0
    if (record.bonus > 0) {
      earnings.push({ name: "Bonus", amount: record.bonus });
    }
    if (record.allowances > 0) {
      earnings.push({ name: "Allowances", amount: record.allowances });
    }
    if (record.lopDeduction > 0) {
      deductions.push({ name: "Loss of Pay (LOP)", amount: record.lopDeduction });
    }
    if (record.loanDeduction > 0) {
      deductions.push({ name: "Loan Repayment Recovery", amount: record.loanDeduction });
    }

    // Totals
    const totalEarnings = earnings.reduce((sum, item) => sum + item.amount, 0);
    const totalDeductions = deductions.reduce((sum, item) => sum + item.amount, 0);
    const netSalaryWords = numberToWords(record.amount);

    // Render beautiful premium HTML page
    const html = `
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Payslip - \${teacherUser.fullName} - \${record.month} \${record.year}</title>
  <style>
    body {
      font-family: 'Outfit', 'Inter', -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif;
      color: #333;
      margin: 0;
      padding: 40px;
      font-size: 14px;
      line-height: 1.5;
      background-color: #fff;
    }
    .payslip-container {
      max-width: 800px;
      margin: 0 auto;
      border: 1px solid #e0e0e0;
      padding: 30px;
      background: #fff;
      box-shadow: 0 4px 6px rgba(0, 0, 0, 0.05);
      border-radius: 8px;
    }
    .header {
      display: flex;
      justify-content: space-between;
      align-items: center;
      border-bottom: 2px solid #2b5c8f;
      padding-bottom: 20px;
      margin-bottom: 25px;
    }
    .school-info h1 {
      margin: 0 0 5px 0;
      font-size: 24px;
      color: #2b5c8f;
      font-weight: 700;
      text-transform: uppercase;
      letter-spacing: 0.5px;
    }
    .school-info p {
      margin: 2px 0;
      color: #666;
      font-size: 13px;
    }
    .payslip-title {
      text-align: right;
    }
    .payslip-title h2 {
      margin: 0 0 5px 0;
      font-size: 20px;
      color: #2b5c8f;
      font-weight: 600;
    }
    .payslip-title p {
      margin: 0;
      color: #777;
      font-weight: 500;
      font-size: 14px;
    }
    .meta-table {
      width: 100%;
      border-collapse: collapse;
      margin-bottom: 30px;
    }
    .meta-table td {
      padding: 8px 12px;
      vertical-align: top;
      border-bottom: 1px solid #f0f0f0;
    }
    .meta-table td.label {
      font-weight: 600;
      color: #555;
      width: 20%;
      background-color: #fafafa;
    }
    .meta-table td.value {
      color: #333;
      width: 30%;
    }
    .salary-table {
      width: 100%;
      border-collapse: collapse;
      margin-bottom: 25px;
    }
    .salary-table th {
      background-color: #2b5c8f;
      color: #fff;
      text-align: left;
      padding: 10px 15px;
      font-weight: 600;
      text-transform: uppercase;
      font-size: 13px;
      letter-spacing: 0.5px;
    }
    .salary-table td {
      padding: 10px 15px;
      border-bottom: 1px solid #e0e0e0;
      vertical-align: top;
    }
    .salary-table tr:last-child td {
      border-bottom: 2px solid #2b5c8f;
    }
    .column-title {
      font-weight: 700;
      background-color: #f5f8fa;
      border-bottom: 2px solid #e0e0e0 !important;
    }
    .item-row td {
      border-bottom: 1px solid #f0f0f0;
    }
    .amount {
      text-align: right;
    }
    .total-row {
      font-weight: 700;
      background-color: #f9f9f9;
    }
    .total-row td {
      border-top: 1px solid #e0e0e0;
      border-bottom: 2px solid #2b5c8f !important;
      padding: 12px 15px;
    }
    .net-salary-block {
      background-color: #f5f8fa;
      border: 1px solid #e0e8f0;
      border-radius: 6px;
      padding: 20px;
      margin-bottom: 35px;
      display: flex;
      justify-content: space-between;
      align-items: center;
    }
    .net-salary-title {
      font-size: 16px;
      font-weight: 700;
      color: #2b5c8f;
    }
    .net-salary-amount {
      font-size: 22px;
      font-weight: 700;
      color: #2b5c8f;
    }
    .net-salary-words {
      margin-top: 5px;
      font-style: italic;
      color: #666;
      font-size: 13px;
    }
    .signatures {
      display: flex;
      justify-content: space-between;
      margin-top: 60px;
      padding-top: 20px;
    }
    .signature-block {
      text-align: center;
      width: 200px;
      border-top: 1px solid #999;
      padding-top: 8px;
      font-weight: 500;
      color: #555;
      font-size: 13px;
    }
    .no-print-btn {
      display: block;
      margin: 0 auto 20px auto;
      padding: 10px 20px;
      background-color: #2b5c8f;
      color: #fff;
      border: none;
      border-radius: 4px;
      cursor: pointer;
      font-size: 15px;
      font-weight: 600;
      box-shadow: 0 2px 4px rgba(0,0,0,0.1);
    }
    .no-print-btn:hover {
      background-color: #1e436b;
    }
    @media print {
      body {
        padding: 0;
        background-color: #fff;
      }
      .payslip-container {
        border: none;
        box-shadow: none;
        padding: 0;
        max-width: 100%;
      }
      .no-print {
        display: none !important;
      }
    }
  </style>
</head>
<body>
  <button class="no-print-btn no-print" onclick="window.print()">Print / Save PDF</button>

  <div class="payslip-container">
    <div class="header">
      <div class="school-info">
        <h1>\${school.name}</h1>
        <p>\${school.address}, \${school.city}</p>
        <p>\${school.state} - \${school.pinCode} | Tel: \${school.contactNumber}</p>
      </div>
      <div class="payslip-title">
        <h2>PAYSLIP</h2>
        <p>\${record.month} \${record.year}</p>
      </div>
    </div>

    <table class="meta-table">
      <tr>
        <td class="label">Employee Name</td>
        <td class="value">\${teacherUser.fullName}</td>
        <td class="label">Employee ID</td>
        <td class="value">\${teacherProfile.id.substring(0, 8).toUpperCase()}</td>
      </tr>
      <tr>
        <td class="label">Designation</td>
        <td class="value">Teacher</td>
        <td class="label">Working Status</td>
        <td class="value">\${teacherProfile.workingStatus}</td>
      </tr>
      <tr>
        <td class="label">Bank Name</td>
        <td class="value">\${teacherProfile.bankName || 'N/A'}</td>
        <td class="label">Account No</td>
        <td class="value">\${teacherProfile.bankAccountNo || 'N/A'}</td>
      </tr>
      <tr>
        <td class="label">Bank IFSC</td>
        <td class="value">\${teacherProfile.bankIfsc || 'N/A'}</td>
        <td class="label">Days Worked</td>
        <td class="value">\${record.presentDays + record.halfDays * 0.5} / \${record.workingDays} Days</td>
      </tr>
    </table>

    <table class="salary-table">
      <thead>
        <tr>
          <th style="width: 50%;">Earnings</th>
          <th style="width: 50%;">Deductions</th>
        </tr>
      </thead>
      <tbody>
        <tr class="column-title">
          <td>Earning Head &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Amount</td>
          <td>Deduction Head &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Amount</td>
        </tr>
        \${
          Array.from({ length: Math.max(earnings.length, deductions.length) }).map((_, index) => {
            const earn = earnings[index];
            const ded = deductions[index];
            return \`
            <tr class="item-row">
              <td>
                \\\${earn ? \`<div style="display:flex; justify-content:space-between;"><span>\\\${earn.name}</span><span>₹\\\${earn.amount.toFixed(2)}</span></div>\` : ''}
              </td>
              <td>
                \\\${ded ? \`<div style="display:flex; justify-content:space-between;"><span>\\\${ded.name}</span><span>₹\\\${ded.amount.toFixed(2)}</span></div>\` : ''}
              </td>
            </tr>
            \`;
          }).join('')
        }
        <tr class="total-row">
          <td>
            <div style="display:flex; justify-content:space-between;">
              <span>Total Earnings</span>
              <span>₹\${totalEarnings.toFixed(2)}</span>
            </div>
          </td>
          <td>
            <div style="display:flex; justify-content:space-between;">
              <span>Total Deductions</span>
              <span>₹\${totalDeductions.toFixed(2)}</span>
            </div>
          </td>
        </tr>
      </tbody>
    </table>

    <div class="net-salary-block">
      <div>
        <div class="net-salary-title">Net Salary Payable</div>
        <div class="net-salary-words">In Words: <strong>\${netSalaryWords}</strong></div>
      </div>
      <div class="net-salary-amount">₹\${record.amount.toFixed(2)}</div>
    </div>

    <div class="signatures">
      <div class="signature-block">
        Employer Signature
      </div>
      <div class="signature-block">
        Employee Signature
      </div>
    </div>
  </div>

  <script>
    window.onload = function() {
      setTimeout(function() {
        window.print();
      }, 500);
    };
  </script>
</body>
</html>
    `;

    res.setHeader("Content-Type", "text/html");
    res.send(html);
  } catch (error: any) {
    console.error("[PRINT_PAYSLIP_ERROR]:", error);
    res.status(500).send(`<h3>Failed to generate printable payslip: \${error.message || error}</h3>`);
  }
}
