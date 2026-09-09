import { Request, Response } from "express";
import { AuthenticatedRequest } from "../middlewares/auth";
import prisma from "../config/db";

// Strict Date Validator: YYYY-MM-DD and year within 2020-2035
export function isValidISODate(dateStr: string): boolean {
  if (!dateStr || typeof dateStr !== "string") return false;
  const regex = /^\d{4}-(0[1-9]|1[0-2])-(0[1-9]|[12]\d|3[01])$/;
  if (!regex.test(dateStr)) return false;

  const [yearStr, monthStr, dayStr] = dateStr.split("-");
  const year = parseInt(yearStr, 10);
  const month = parseInt(monthStr, 10);
  const day = parseInt(dayStr, 10);

  if (year < 2020 || year > 2035) return false;

  const dateObj = new Date(Date.UTC(year, month - 1, day));
  return (
    dateObj.getUTCFullYear() === year &&
    dateObj.getUTCMonth() === month - 1 &&
    dateObj.getUTCDate() === day
  );
}

// Calculate days between two YYYY-MM-DD dates inclusive
export function calculateLeaveDays(startDateStr: string, endDateStr: string): number {
  const start = new Date(startDateStr + "T00:00:00.000Z");
  const end = new Date(endDateStr + "T00:00:00.000Z");
  const diffTime = end.getTime() - start.getTime();
  if (diffTime < 0) return 0;
  return Math.floor(diffTime / (1000 * 60 * 60 * 24)) + 1;
}

// Helper: Format date for readable UI display (e.g. 07 Sep 2026)
export function formatReadableDate(date: Date | string): string {
  const d = typeof date === "string" ? new Date(date) : date;
  if (isNaN(d.getTime())) return "";
  const months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
  const day = d.getUTCDate().toString().padStart(2, "0");
  const month = months[d.getUTCMonth()];
  const year = d.getUTCFullYear();
  return `${day} ${month} ${year}`;
}

// Helper: Create an audit log record
export async function createAuditLog(data: {
  schoolId?: string;
  userId?: string;
  userFullName?: string;
  userRole?: string;
  action: string;
  entityType: string;
  entityId: string;
  previousValue?: string;
  newValue?: string;
  reason?: string;
  ipAddress?: string;
}) {
  try {
    return await prisma.auditLog.create({
      data: {
        schoolId: data.schoolId || null,
        userId: data.userId || null,
        userFullName: data.userFullName || null,
        userRole: data.userRole || null,
        action: data.action,
        entityType: data.entityType,
        entityId: data.entityId,
        previousValue: data.previousValue || null,
        newValue: data.newValue || null,
        reason: data.reason || null,
        ipAddress: data.ipAddress || null,
      },
    });
  } catch (err: any) {
    console.warn("[AUDIT_LOG_ERROR]: Could not write audit log:", err.message);
    return null;
  }
}

// Helper: Create notification
export async function createNotification(data: {
  userId: string;
  title: string;
  message: string;
  type?: string;
}) {
  try {
    return await prisma.notification.create({
      data: {
        userId: data.userId,
        title: data.title,
        message: data.message,
        type: data.type || "LEAVE",
      },
    });
  } catch (err: any) {
    console.warn("[NOTIFICATION_ERROR]: Could not create notification:", err.message);
    return null;
  }
}

// ==========================================
// 1. LEAVE REQUESTS CONTROLLER
// ==========================================

export async function getLeaves(req: AuthenticatedRequest, res: Response) {
  try {
    const schoolId = req.user?.schoolId;
    const { status, leaveType, department, search, dateFilter, startDate, endDate } = req.query;

    const whereClause: any = {};
    if (schoolId) {
      whereClause.user = { schoolId };
    }

    if (status && status !== "ALL") {
      whereClause.status = String(status).toUpperCase();
    }

    if (leaveType && leaveType !== "ALL") {
      whereClause.OR = [
        { leaveType: { contains: String(leaveType), mode: "insensitive" } },
        { leaveTypeRel: { code: String(leaveType).toUpperCase() } }
      ];
    }

    // Date filtering
    const now = new Date();
    if (dateFilter === "TODAY") {
      const todayStr = now.toISOString().split("T")[0];
      const todayStart = new Date(todayStr + "T00:00:00.000Z");
      const todayEnd = new Date(todayStr + "T23:59:59.999Z");
      whereClause.fromDate = { lte: todayEnd };
      whereClause.toDate = { gte: todayStart };
    } else if (dateFilter === "THIS_WEEK") {
      const firstDay = new Date(now.setDate(now.getDate() - now.getDay()));
      firstDay.setUTCHours(0, 0, 0, 0);
      const lastDay = new Date(firstDay);
      lastDay.setDate(lastDay.getDate() + 6);
      lastDay.setUTCHours(23, 59, 59, 999);
      whereClause.fromDate = { lte: lastDay };
      whereClause.toDate = { gte: firstDay };
    } else if (dateFilter === "THIS_MONTH") {
      const startOfMonth = new Date(now.getFullYear(), now.getMonth(), 1);
      const endOfMonth = new Date(now.getFullYear(), now.getMonth() + 1, 0, 23, 59, 59, 999);
      whereClause.fromDate = { lte: endOfMonth };
      whereClause.toDate = { gte: startOfMonth };
    } else if (startDate && endDate && isValidISODate(String(startDate)) && isValidISODate(String(endDate))) {
      whereClause.fromDate = { lte: new Date(String(endDate) + "T23:59:59.999Z") };
      whereClause.toDate = { gte: new Date(String(startDate) + "T00:00:00.000Z") };
    }

    const leaves = await prisma.leaveRequest.findMany({
      where: whereClause,
      include: {
        user: {
          select: {
            id: true,
            fullName: true,
            role: true,
            email: true,
            phoneNumber: true,
            profileImage: true,
            teacherProfile: {
              select: {
                id: true,
                qualification: true,
                experienceYears: true,
                workingStatus: true,
              }
            }
          }
        },
        approver: {
          select: {
            id: true,
            fullName: true,
            role: true,
          }
        },
        leaveTypeRel: true,
      },
      orderBy: { createdAt: "desc" }
    });

    // Transform and map fields cleanly for frontend
    const mapped = leaves.map(l => {
      const startStr = l.fromDate.toISOString().split("T")[0];
      const endStr = l.toDate.toISOString().split("T")[0];
      const days = l.daysCount || calculateLeaveDays(startStr, endStr);
      
      // Determine department & designation
      let department = "Teaching";
      let designation = "Faculty Member";
      if (l.user.role === "PRINCIPAL") {
        department = "Administration";
        designation = "Principal / Headmaster";
      } else if (l.user.role === "CORRESPONDENT") {
        department = "Executive Directorate";
        designation = "Super Admin";
      } else if (l.user.role === "STAFF_HEAD") {
        department = "Administration";
        designation = "Staff Head";
      } else if (l.user.role === "PT") {
        department = "Physical Education";
        designation = "PT Instructor";
      }

      // Generate consistent Employee ID
      const empId = `EMP-${l.user.id.slice(0, 4).toUpperCase()}`;

      return {
        id: l.id,
        applicant: l.user.fullName,
        applicantPhoto: l.user.profileImage || (l.user.role === "PRINCIPAL" ? "/assets/principal_hero.jpg" : "/assets/teacher_hero.jpg"),
        employeeId: empId,
        userId: l.user.id,
        designation,
        department,
        email: l.user.email,
        phone: l.user.phoneNumber,
        leaveType: l.leaveType,
        leaveTypeId: l.leaveTypeId,
        startDate: startStr,
        endDate: endStr,
        formattedStartDate: formatReadableDate(l.fromDate),
        formattedEndDate: formatReadableDate(l.toDate),
        days: days,
        reason: l.reason,
        appliedOn: l.createdAt.toISOString().split("T")[0],
        formattedAppliedOn: formatReadableDate(l.createdAt),
        status: l.status,
        isEmergency: l.isEmergency,
        attachmentUrl: l.attachmentUrl,
        rejectionReason: l.rejectionReason,
        approverName: l.approver?.fullName || null,
        approvedAt: l.approvedAt ? formatReadableDate(l.approvedAt) : null,
        rejectedAt: l.rejectedAt ? formatReadableDate(l.rejectedAt) : null,
      };
    });

    // In-memory filter for department & search if requested
    let result = mapped;
    if (department && department !== "ALL") {
      result = result.filter(r => r.department.toLowerCase().includes(String(department).toLowerCase()));
    }
    if (search && String(search).trim()) {
      const q = String(search).toLowerCase().trim();
      result = result.filter(r =>
        r.applicant.toLowerCase().includes(q) ||
        r.employeeId.toLowerCase().includes(q) ||
        r.department.toLowerCase().includes(q) ||
        r.leaveType.toLowerCase().includes(q) ||
        r.reason.toLowerCase().includes(q)
      );
    }

    res.json(result);
  } catch (error: any) {
    console.error("[GET_LEAVES_ERROR]:", error);
    res.status(500).json({ error: error.message || "Failed to retrieve leave entries" });
  }
}

export async function getLeaveById(req: AuthenticatedRequest, res: Response) {
  try {
    const { id } = req.params;
    const leave = await prisma.leaveRequest.findUnique({
      where: { id },
      include: {
        user: {
          include: {
            teacherProfile: true,
            leaveBalances: true,
          }
        },
        approver: true,
        leaveTypeRel: true,
      }
    });

    if (!leave) {
      return res.status(404).json({ error: "Leave request not found" });
    }

    const startStr = leave.fromDate.toISOString().split("T")[0];
    const endStr = leave.toDate.toISOString().split("T")[0];
    const days = leave.daysCount || calculateLeaveDays(startStr, endStr);

    res.json({
      ...leave,
      startDate: startStr,
      endDate: endStr,
      days,
      formattedStartDate: formatReadableDate(leave.fromDate),
      formattedEndDate: formatReadableDate(leave.toDate),
      formattedAppliedOn: formatReadableDate(leave.createdAt),
    });
  } catch (error: any) {
    res.status(500).json({ error: error.message || "Failed to retrieve leave details" });
  }
}

export async function applyLeave(req: AuthenticatedRequest, res: Response) {
  try {
    const {
      employeeId,
      userId: targetUserId,
      leaveType,
      leaveTypeId,
      startDate,
      endDate,
      fromDate,
      toDate,
      reason,
      attachmentUrl,
      isEmergency = false,
      overrideBalance = false
    } = req.body;

    const startStr = startDate || fromDate;
    const endStr = endDate || toDate;
    const applicantUserId = targetUserId || employeeId || req.user?.id;
    const schoolId = req.user?.schoolId;

    if (!applicantUserId) {
      return res.status(400).json({ error: "Missing applicant employee context" });
    }

    if (!startStr || !endStr || !reason || (!leaveType && !leaveTypeId)) {
      return res.status(400).json({ error: "Missing required fields: Leave Type, Start Date, End Date, Reason" });
    }

    // 1. Strict Date Validation
    if (!isValidISODate(startStr)) {
      return res.status(400).json({ error: `Invalid start date: "${startStr}". Must be a valid date in YYYY-MM-DD format between 2020 and 2035.` });
    }
    if (!isValidISODate(endStr)) {
      return res.status(400).json({ error: `Invalid end date: "${endStr}". Must be a valid date in YYYY-MM-DD format between 2020 and 2035.` });
    }

    const startObj = new Date(startStr + "T00:00:00.000Z");
    const endObj = new Date(endStr + "T00:00:00.000Z");

    if (startObj.getTime() > endObj.getTime()) {
      return res.status(400).json({ error: "End date cannot be before start date." });
    }

    const totalDays = calculateLeaveDays(startStr, endStr);
    if (totalDays <= 0) {
      return res.status(400).json({ error: "Invalid date range." });
    }

    // 2. Prevent duplicate overlapping active leave requests
    const overlapping = await prisma.leaveRequest.findFirst({
      where: {
        userId: applicantUserId,
        status: { in: ["PENDING", "APPROVED"] },
        fromDate: { lte: endObj },
        toDate: { gte: startObj }
      }
    });

    if (overlapping) {
      return res.status(400).json({
        error: `An active leave request already exists for this employee overlapping with ${formatReadableDate(overlapping.fromDate)} - ${formatReadableDate(overlapping.toDate)} (${overlapping.status}).`
      });
    }

    // 3. Resolve leave type name and code
    let finalLeaveType = leaveType || "Casual Leave";
    let finalLeaveTypeId = leaveTypeId || null;
    let leaveCode = "CASUAL";

    if (leaveTypeId) {
      const lt = await prisma.leaveType.findUnique({ where: { id: leaveTypeId } });
      if (lt) {
        finalLeaveType = lt.name;
        leaveCode = lt.code;
      }
    } else if (leaveType) {
      if (leaveType.includes("Sick") || leaveType.includes("Medical") || leaveType === "SL") leaveCode = "SICK";
      else if (leaveType.includes("Earned") || leaveType === "EL") leaveCode = "EARNED";
      else if (leaveType.includes("Emergency")) leaveCode = "EMERGENCY";
      else if (leaveType.includes("Maternity")) leaveCode = "MATERNITY";
      else if (leaveType.includes("Paternity")) leaveCode = "PATERNITY";
      else if (leaveType.includes("Permission")) leaveCode = "PERMISSION";
      else leaveCode = "CASUAL";
    }

    // 4. Balance check if not overridden
    if (!overrideBalance && !isEmergency) {
      const balance = await prisma.leaveBalance.findFirst({
        where: {
          userId: applicantUserId,
          leaveTypeCode: leaveCode,
          year: startObj.getUTCFullYear()
        }
      });

      if (balance && balance.remaining < totalDays) {
        return res.status(400).json({
          error: `Insufficient leave balance. Requested ${totalDays} day(s), but only ${balance.remaining} day(s) remaining for ${finalLeaveType}. Super Admin can override if necessary.`
        });
      }
    }

    // 5. Create Leave Request
    const leave = await prisma.leaveRequest.create({
      data: {
        userId: applicantUserId,
        leaveType: finalLeaveType,
        leaveTypeId: finalLeaveTypeId,
        fromDate: startObj,
        toDate: endObj,
        daysCount: totalDays,
        reason: reason.trim(),
        attachmentUrl: attachmentUrl || null,
        isEmergency: Boolean(isEmergency),
        status: "PENDING",
      }
    });

    // 6. Audit Log
    const applicantUser = await prisma.user.findUnique({ where: { id: applicantUserId } });
    await createAuditLog({
      schoolId: schoolId || undefined,
      userId: req.user?.id,
      userFullName: req.user?.fullName || req.user?.email || "Super Admin",
      userRole: req.user?.role,
      action: "APPLY_LEAVE",
      entityType: "LEAVE_REQUEST",
      entityId: leave.id,
      newValue: JSON.stringify({
        applicant: applicantUser?.fullName,
        leaveType: finalLeaveType,
        startDate: startStr,
        endDate: endStr,
        days: totalDays,
        isEmergency
      }),
      reason: reason
    });

    res.status(201).json({
      message: "Leave application submitted successfully",
      leave: {
        ...leave,
        startDate: startStr,
        endDate: endStr,
        formattedStartDate: formatReadableDate(startObj),
        formattedEndDate: formatReadableDate(endObj),
      }
    });
  } catch (error: any) {
    console.error("[APPLY_LEAVE_ERROR]:", error);
    res.status(500).json({ error: error.message || "Failed to submit leave request" });
  }
}

export async function updateLeave(req: AuthenticatedRequest, res: Response) {
  try {
    const { id } = req.params;
    const { startDate, endDate, reason, leaveType, attachmentUrl, isEmergency } = req.body;

    const existing = await prisma.leaveRequest.findUnique({ where: { id } });
    if (!existing) {
      return res.status(404).json({ error: "Leave request not found" });
    }

    if (existing.status !== "PENDING") {
      return res.status(400).json({ error: "Cannot edit a leave request that has already been processed." });
    }

    const data: any = {};
    if (reason !== undefined) data.reason = reason.trim();
    if (leaveType !== undefined) data.leaveType = leaveType;
    if (attachmentUrl !== undefined) data.attachmentUrl = attachmentUrl;
    if (isEmergency !== undefined) data.isEmergency = Boolean(isEmergency);

    if (startDate || endDate) {
      const s = startDate || existing.fromDate.toISOString().split("T")[0];
      const e = endDate || existing.toDate.toISOString().split("T")[0];
      if (!isValidISODate(s) || !isValidISODate(e)) {
        return res.status(400).json({ error: "Dates must be valid YYYY-MM-DD between 2020 and 2035" });
      }
      data.fromDate = new Date(s + "T00:00:00.000Z");
      data.toDate = new Date(e + "T00:00:00.000Z");
      data.daysCount = calculateLeaveDays(s, e);
    }

    const updated = await prisma.leaveRequest.update({
      where: { id },
      data
    });

    res.json({ message: "Leave request updated successfully", leave: updated });
  } catch (error: any) {
    res.status(500).json({ error: error.message || "Failed to update leave request" });
  }
}

export async function deleteLeave(req: AuthenticatedRequest, res: Response) {
  try {
    const { id } = req.params;
    const existing = await prisma.leaveRequest.findUnique({ where: { id } });
    if (!existing) {
      return res.status(404).json({ error: "Leave request not found" });
    }

    await prisma.leaveRequest.delete({ where: { id } });

    await createAuditLog({
      schoolId: req.user?.schoolId,
      userId: req.user?.id,
      userFullName: req.user?.fullName || req.user?.email || "Super Admin",
      userRole: req.user?.role,
      action: "DELETE_LEAVE",
      entityType: "LEAVE_REQUEST",
      entityId: id,
      previousValue: JSON.stringify(existing)
    });

    res.json({ message: "Leave request deleted successfully" });
  } catch (error: any) {
    res.status(500).json({ error: error.message || "Failed to delete leave request" });
  }
}

// ==========================================
// 2. APPROVAL & REJECTION WORKFLOWS
// ==========================================

export async function approveLeave(req: AuthenticatedRequest, res: Response) {
  try {
    const { id } = req.params;
    const approverId = req.user?.id;
    const approverName = req.user?.fullName || "Super Admin";

    if (!approverId) {
      return res.status(401).json({ error: "Unauthorized" });
    }

    const leave = await prisma.leaveRequest.findUnique({
      where: { id },
      include: { user: true }
    });

    if (!leave) {
      return res.status(404).json({ error: "Leave request not found" });
    }

    // Do NOT allow the same request to be approved twice
    if (leave.status === "APPROVED") {
      return res.status(400).json({ error: "This leave request has already been approved." });
    }

    const startStr = leave.fromDate.toISOString().split("T")[0];
    const endStr = leave.toDate.toISOString().split("T")[0];
    const days = leave.daysCount || calculateLeaveDays(startStr, endStr);
    const now = new Date();

    // 1. Update status to APPROVED
    const updatedLeave = await prisma.leaveRequest.update({
      where: { id },
      data: {
        status: "APPROVED",
        approvedById: approverId,
        approvedAt: now,
        rejectionReason: null,
      }
    });

    // 2. Update employee leave balance
    let leaveCode = "CASUAL";
    if (leave.leaveType.includes("Sick") || leave.leaveType.includes("Medical") || leave.leaveType === "SL") leaveCode = "SICK";
    else if (leave.leaveType.includes("Earned") || leave.leaveType === "EL") leaveCode = "EARNED";
    else if (leave.leaveType.includes("Emergency")) leaveCode = "EMERGENCY";

    const year = leave.fromDate.getUTCFullYear();
    const existingBalance = await prisma.leaveBalance.findUnique({
      where: {
        userId_leaveTypeCode_year: {
          userId: leave.userId,
          leaveTypeCode: leaveCode,
          year: year
        }
      }
    });

    if (existingBalance) {
      const newUsed = existingBalance.used + days;
      const newRemaining = Math.max(0, existingBalance.allocated + existingBalance.adjusted - newUsed);
      await prisma.leaveBalance.update({
        where: { id: existingBalance.id },
        data: {
          used: newUsed,
          remaining: newRemaining
        }
      });
    } else {
      // Create initial balance ledger record
      await prisma.leaveBalance.create({
        data: {
          userId: leave.userId,
          leaveTypeCode: leaveCode,
          allocated: 12.0,
          used: days,
          remaining: Math.max(0, 12.0 - days),
          year: year
        }
      });
    }

    // 3. Mark staff attendance as LEAVE for the approved dates
    let currentScan = new Date(leave.fromDate);
    while (currentScan.getTime() <= leave.toDate.getTime()) {
      const curDateStr = currentScan.toISOString().split("T")[0];
      try {
        await prisma.staffAttendance.upsert({
          where: {
            userId_date: {
              userId: leave.userId,
              date: curDateStr
            }
          },
          update: { status: "LEAVE" },
          create: {
            userId: leave.userId,
            date: curDateStr,
            status: "LEAVE"
          }
        });
      } catch (attErr) {
        // Continue loop
      }
      currentScan.setDate(currentScan.getDate() + 1);
    }

    // 4. Create Audit Log
    await createAuditLog({
      schoolId: req.user?.schoolId,
      userId: approverId,
      userFullName: approverName,
      userRole: req.user?.role,
      action: "APPROVE_LEAVE",
      entityType: "LEAVE_REQUEST",
      entityId: id,
      previousValue: JSON.stringify({ status: leave.status }),
      newValue: JSON.stringify({ status: "APPROVED", approver: approverName, approvedAt: now, days }),
      reason: "Super Admin Approval"
    });

    // 5. Create Notification for employee
    const formattedFrom = formatReadableDate(leave.fromDate);
    const formattedTo = formatReadableDate(leave.toDate);
    await createNotification({
      userId: leave.userId,
      title: "Leave Request Approved",
      message: `Your leave request from ${formattedFrom} to ${formattedTo} (${days} day${days > 1 ? "s" : ""}) has been approved by ${approverName}.`,
      type: "LEAVE"
    });

    res.json({
      message: `Leave request approved successfully for ${leave.user.fullName}`,
      leave: updatedLeave
    });
  } catch (error: any) {
    console.error("[APPROVE_LEAVE_ERROR]:", error);
    res.status(500).json({ error: error.message || "Failed to approve leave request" });
  }
}

export async function rejectLeave(req: AuthenticatedRequest, res: Response) {
  try {
    const { id } = req.params;
    const { reason, rejectionReason } = req.body;
    const finalReason = (rejectionReason || reason || "").trim();
    const rejectorId = req.user?.id;
    const rejectorName = req.user?.fullName || "Super Admin";

    if (!finalReason) {
      return res.status(400).json({ error: "A valid reason for rejection is required." });
    }

    const leave = await prisma.leaveRequest.findUnique({
      where: { id },
      include: { user: true }
    });

    if (!leave) {
      return res.status(404).json({ error: "Leave request not found" });
    }

    const now = new Date();
    const updatedLeave = await prisma.leaveRequest.update({
      where: { id },
      data: {
        status: "REJECTED",
        rejectionReason: finalReason,
        approvedById: rejectorId,
        rejectedAt: now,
      }
    });

    // Create Audit Log
    await createAuditLog({
      schoolId: req.user?.schoolId,
      userId: rejectorId,
      userFullName: rejectorName,
      userRole: req.user?.role,
      action: "REJECT_LEAVE",
      entityType: "LEAVE_REQUEST",
      entityId: id,
      previousValue: JSON.stringify({ status: leave.status }),
      newValue: JSON.stringify({ status: "REJECTED", rejectedBy: rejectorName, rejectedAt: now, reason: finalReason }),
      reason: finalReason
    });

    // Create Notification for employee
    const formattedFrom = formatReadableDate(leave.fromDate);
    const formattedTo = formatReadableDate(leave.toDate);
    await createNotification({
      userId: leave.userId,
      title: "Leave Request Rejected",
      message: `Your leave request from ${formattedFrom} to ${formattedTo} has been rejected. Reason: ${finalReason}`,
      type: "LEAVE"
    });

    res.json({
      message: `Leave request rejected successfully`,
      leave: updatedLeave
    });
  } catch (error: any) {
    console.error("[REJECT_LEAVE_ERROR]:", error);
    res.status(500).json({ error: error.message || "Failed to reject leave request" });
  }
}

// ==========================================
// 3. ATTENDANCE RECTIFICATIONS
// ==========================================

export async function getAttendanceRectifications(req: AuthenticatedRequest, res: Response) {
  try {
    const schoolId = req.user?.schoolId;
    const rectifications = await prisma.attendanceRectification.findMany({
      where: schoolId ? { user: { schoolId } } : {},
      include: {
        user: {
          select: {
            id: true,
            fullName: true,
            role: true,
            email: true,
            profileImage: true,
          }
        },
        approvedBy: {
          select: {
            id: true,
            fullName: true,
            role: true,
          }
        }
      },
      orderBy: { createdAt: "desc" }
    });

    const mapped = rectifications.map(r => {
      let dept = "Teaching";
      if (r.user.role === "PRINCIPAL") dept = "Administration";
      else if (r.user.role === "PT") dept = "Physical Education";

      return {
        id: r.id,
        employee: r.user.fullName,
        employeePhoto: r.user.profileImage || "/assets/teacher_hero.jpg",
        employeeId: `EMP-${r.user.id.slice(0, 4).toUpperCase()}`,
        userId: r.user.id,
        department: dept,
        date: r.date,
        formattedDate: formatReadableDate(new Date(r.date + "T00:00:00.000Z")),
        originalAttendance: r.originalAttendance || (r.checkInTime ? "Late Punch (09:45 AM)" : "Absent"),
        requestedAttendance: r.requestedAttendance || (r.checkInTime ? `Present (${r.checkInTime})` : "Present"),
        checkInTime: r.checkInTime,
        checkOutTime: r.checkOutTime,
        reason: r.reason,
        submittedOn: r.createdAt.toISOString().split("T")[0],
        formattedSubmittedOn: formatReadableDate(r.createdAt),
        status: r.status,
        rejectionReason: r.rejectionReason,
        approverName: r.approvedBy?.fullName || null,
        approvedAt: r.approvedAt ? formatReadableDate(r.approvedAt) : null,
      };
    });

    res.json(mapped);
  } catch (error: any) {
    res.status(500).json({ error: error.message || "Failed to retrieve attendance rectifications" });
  }
}

export async function approveAttendanceRectification(req: AuthenticatedRequest, res: Response) {
  try {
    const { id } = req.params;
    const approverId = req.user?.id;
    const approverName = req.user?.fullName || "Super Admin";

    const rect = await prisma.attendanceRectification.findUnique({
      where: { id },
      include: { user: true }
    });

    if (!rect) {
      return res.status(404).json({ error: "Attendance rectification request not found" });
    }

    if (rect.status === "APPROVED") {
      return res.status(400).json({ error: "This rectification request has already been approved." });
    }

    const now = new Date();
    const updated = await prisma.attendanceRectification.update({
      where: { id },
      data: {
        status: "APPROVED",
        approvedById: approverId,
        approvedAt: now,
        rejectionReason: null
      }
    });

    // Update the actual staff attendance record
    try {
      await prisma.staffAttendance.upsert({
        where: {
          userId_date: {
            userId: rect.userId,
            date: rect.date
          }
        },
        update: {
          status: "PRESENT",
          totalHours: 8.0,
        },
        create: {
          userId: rect.userId,
          date: rect.date,
          status: "PRESENT",
          totalHours: 8.0
        }
      });
    } catch (attErr) {
      // Continue
    }

    // Create Audit Log
    await createAuditLog({
      schoolId: req.user?.schoolId,
      userId: approverId,
      userFullName: approverName,
      userRole: req.user?.role,
      action: "APPROVE_RECTIFICATION",
      entityType: "ATTENDANCE_RECTIFICATION",
      entityId: id,
      previousValue: JSON.stringify({ status: rect.status }),
      newValue: JSON.stringify({ status: "APPROVED", approver: approverName, approvedAt: now }),
      reason: "Super Admin Rectification Approval"
    });

    // Create Notification
    await createNotification({
      userId: rect.userId,
      title: "Attendance Rectification Approved",
      message: `Your attendance correction request for ${formatReadableDate(new Date(rect.date + "T00:00:00.000Z"))} has been approved.`,
      type: "RECTIFICATION"
    });

    res.json({ message: "Attendance rectification approved successfully", rectification: updated });
  } catch (error: any) {
    res.status(500).json({ error: error.message || "Failed to approve attendance rectification" });
  }
}

export async function rejectAttendanceRectification(req: AuthenticatedRequest, res: Response) {
  try {
    const { id } = req.params;
    const { reason, rejectionReason } = req.body;
    const finalReason = (rejectionReason || reason || "").trim();
    const rejectorId = req.user?.id;
    const rejectorName = req.user?.fullName || "Super Admin";

    if (!finalReason) {
      return res.status(400).json({ error: "A valid reason for rejection is required." });
    }

    const rect = await prisma.attendanceRectification.findUnique({
      where: { id },
      include: { user: true }
    });

    if (!rect) {
      return res.status(404).json({ error: "Attendance rectification request not found" });
    }

    const now = new Date();
    const updated = await prisma.attendanceRectification.update({
      where: { id },
      data: {
        status: "REJECTED",
        rejectionReason: finalReason,
        approvedById: rejectorId,
        rejectedAt: now,
      }
    });

    // Audit Log
    await createAuditLog({
      schoolId: req.user?.schoolId,
      userId: rejectorId,
      userFullName: rejectorName,
      userRole: req.user?.role,
      action: "REJECT_RECTIFICATION",
      entityType: "ATTENDANCE_RECTIFICATION",
      entityId: id,
      previousValue: JSON.stringify({ status: rect.status }),
      newValue: JSON.stringify({ status: "REJECTED", reason: finalReason }),
      reason: finalReason
    });

    // Notification
    await createNotification({
      userId: rect.userId,
      title: "Attendance Rectification Rejected",
      message: `Your attendance correction request for ${formatReadableDate(new Date(rect.date + "T00:00:00.000Z"))} has been rejected. Reason: ${finalReason}`,
      type: "RECTIFICATION"
    });

    res.json({ message: "Attendance rectification rejected successfully", rectification: updated });
  } catch (error: any) {
    res.status(500).json({ error: error.message || "Failed to reject attendance rectification" });
  }
}

// ==========================================
// 4. LEAVE BALANCES & ADJUSTMENTS
// ==========================================

export async function getLeaveBalances(req: AuthenticatedRequest, res: Response) {
  try {
    const schoolId = req.user?.schoolId;
    const users = await prisma.user.findMany({
      where: {
        schoolId: schoolId || undefined,
        role: { in: ["PRINCIPAL", "HM", "TEACHER", "PT", "STAFF_HEAD", "CORRESPONDENT"] }
      },
      include: {
        leaveBalances: true,
        teacherProfile: true,
      },
      orderBy: { fullName: "asc" }
    });

    const currentYear = new Date().getFullYear();

    const results = users.map(u => {
      const getBal = (code: string, defAlloc: number) => {
        const b = u.leaveBalances.find(lb => lb.leaveTypeCode === code && lb.year === currentYear);
        if (b) return { allocated: b.allocated, used: b.used, adjusted: b.adjusted, remaining: b.remaining };
        return { allocated: defAlloc, used: 0, adjusted: 0, remaining: defAlloc };
      };

      const casual = getBal("CASUAL", 12);
      const sick = getBal("SICK", 10);
      const earned = getBal("EARNED", 15);
      const emergency = getBal("EMERGENCY", 5);

      const totalUsed = casual.used + sick.used + earned.used + emergency.used;
      const totalRemaining = casual.remaining + sick.remaining + earned.remaining + emergency.remaining;

      let dept = "Teaching";
      if (u.role === "PRINCIPAL") dept = "Administration";
      else if (u.role === "PT") dept = "Physical Education";
      else if (u.role === "STAFF_HEAD") dept = "Administration";
      else if (u.role === "CORRESPONDENT") dept = "Executive Directorate";

      return {
        userId: u.id,
        employee: u.fullName,
        employeeId: `EMP-${u.id.slice(0, 4).toUpperCase()}`,
        employeePhoto: u.profileImage || (u.role === "PRINCIPAL" ? "/assets/principal_hero.jpg" : "/assets/teacher_hero.jpg"),
        role: u.role,
        department: dept,
        casualLeave: casual,
        sickLeave: sick,
        earnedLeave: earned,
        emergencyLeave: emergency,
        totalUsed,
        totalRemaining,
      };
    });

    res.json(results);
  } catch (error: any) {
    res.status(500).json({ error: error.message || "Failed to retrieve leave balances" });
  }
}

export async function adjustLeaveBalance(req: AuthenticatedRequest, res: Response) {
  try {
    const { employeeId } = req.params;
    const { leaveTypeCode, adjustmentType, days, reason } = req.body;
    const adminId = req.user?.id;
    const adminName = req.user?.fullName || "Super Admin";

    if (!leaveTypeCode || !adjustmentType || !days || !reason) {
      return res.status(400).json({ error: "Missing required fields: leaveTypeCode, adjustmentType (CREDIT/DEBIT), days, reason" });
    }

    const numDays = parseFloat(days);
    if (isNaN(numDays) || numDays <= 0) {
      return res.status(400).json({ error: "Days must be a positive number" });
    }

    // Find target user by ID or prefix
    let targetUser = await prisma.user.findUnique({ where: { id: employeeId } });
    if (!targetUser) {
      const cleanId = employeeId.replace("EMP-", "").toLowerCase();
      const allUsers = await prisma.user.findMany();
      targetUser = allUsers.find(u => u.id.toLowerCase().startsWith(cleanId)) || null;
    }

    if (!targetUser) {
      return res.status(404).json({ error: "Employee not found" });
    }

    const currentYear = new Date().getFullYear();
    const code = leaveTypeCode.toUpperCase().trim();

    const existingBalance = await prisma.leaveBalance.findUnique({
      where: {
        userId_leaveTypeCode_year: {
          userId: targetUser.id,
          leaveTypeCode: code,
          year: currentYear
        }
      }
    });

    let beforeVal = 12.0;
    let afterVal = 12.0;
    let adjustedRec: any;

    if (existingBalance) {
      beforeVal = existingBalance.remaining;
      const adjustDelta = adjustmentType === "CREDIT" ? numDays : -numDays;
      const newAdjusted = existingBalance.adjusted + adjustDelta;
      const newRemaining = Math.max(0, existingBalance.allocated + newAdjusted - existingBalance.used);
      afterVal = newRemaining;

      adjustedRec = await prisma.leaveBalance.update({
        where: { id: existingBalance.id },
        data: {
          adjusted: newAdjusted,
          remaining: newRemaining
        }
      });
    } else {
      const defAlloc = 12.0;
      beforeVal = defAlloc;
      const adjustDelta = adjustmentType === "CREDIT" ? numDays : -numDays;
      const newRemaining = Math.max(0, defAlloc + adjustDelta);
      afterVal = newRemaining;

      adjustedRec = await prisma.leaveBalance.create({
        data: {
          userId: targetUser.id,
          leaveTypeCode: code,
          allocated: defAlloc,
          adjusted: adjustDelta,
          used: 0.0,
          remaining: newRemaining,
          year: currentYear
        }
      });
    }

    // Create Audit Log
    const actionDesc = `${adjustmentType === "CREDIT" ? "Added" : "Deducted"} ${numDays} ${code} day(s) for ${targetUser.fullName}`;
    await createAuditLog({
      schoolId: req.user?.schoolId,
      userId: adminId,
      userFullName: adminName,
      userRole: req.user?.role,
      action: "ADJUST_BALANCE",
      entityType: "LEAVE_BALANCE",
      entityId: adjustedRec.id,
      previousValue: `Remaining: ${beforeVal} days`,
      newValue: `Remaining: ${afterVal} days (${actionDesc})`,
      reason: reason.trim()
    });

    // Create Notification
    await createNotification({
      userId: targetUser.id,
      title: "Leave Balance Adjusted",
      message: `Your ${code} balance was updated by ${adminName}: ${actionDesc}. Reason: ${reason}`,
      type: "LEAVE"
    });

    res.json({
      message: `Successfully updated ${code} balance for ${targetUser.fullName}`,
      balance: adjustedRec
    });
  } catch (error: any) {
    console.error("[ADJUST_BALANCE_ERROR]:", error);
    res.status(500).json({ error: error.message || "Failed to adjust leave balance" });
  }
}

// ==========================================
// 5. LEAVE POLICIES
// ==========================================

export async function getLeavePolicies(req: AuthenticatedRequest, res: Response) {
  try {
    const schoolId = req.user?.schoolId;
    const policies = await prisma.leaveType.findMany({
      where: schoolId ? { schoolId } : {},
      orderBy: { createdAt: "asc" }
    });

    // Default institutional policies if none created yet
    if (policies.length === 0 && schoolId) {
      const defaults = [
        { name: "Casual Leave (CL)", code: "CASUAL", maxDays: 12, maxConsecutiveDays: 3, minNoticePeriodDays: 2, carryForwardAllowed: false, requiresAttachment: false, description: "For routine personal commitments and short planned leaves." },
        { name: "Sick Leave (SL)", code: "SICK", maxDays: 10, maxConsecutiveDays: 5, minNoticePeriodDays: 0, carryForwardAllowed: false, requiresAttachment: true, attachmentAfterDays: 2, description: "Medical absence; doctor certificate required for > 2 consecutive days." },
        { name: "Earned Leave (EL)", code: "EARNED", maxDays: 15, maxConsecutiveDays: 10, minNoticePeriodDays: 7, carryForwardAllowed: true, maxCarryForwardDays: 30, requiresAttachment: false, description: "Accrued vacation leave for tenure-based staff." },
        { name: "Emergency Leave", code: "EMERGENCY", maxDays: 5, maxConsecutiveDays: 3, minNoticePeriodDays: 0, carryForwardAllowed: false, requiresAttachment: false, description: "Immediate unforeseen family or personal emergencies." },
        { name: "Maternity Leave", code: "MATERNITY", maxDays: 90, maxConsecutiveDays: 90, minNoticePeriodDays: 30, carryForwardAllowed: false, requiresAttachment: true, description: "Full statutory maternity benefit for eligible female staff." },
        { name: "Paternity Leave", code: "PATERNITY", maxDays: 10, maxConsecutiveDays: 10, minNoticePeriodDays: 14, carryForwardAllowed: false, requiresAttachment: true, description: "Statutory paternity support leave." },
        { name: "Permission / Short Leave", code: "PERMISSION", maxDays: 12, maxConsecutiveDays: 1, minNoticePeriodDays: 1, carryForwardAllowed: false, requiresAttachment: false, description: "Up to 2 hours official mid-day gate pass." }
      ];

      for (const d of defaults) {
        try {
          await prisma.leaveType.create({
            data: {
              schoolId,
              name: d.name,
              code: d.code,
              maxDays: d.maxDays,
              maxConsecutiveDays: d.maxConsecutiveDays,
              minNoticePeriodDays: d.minNoticePeriodDays,
              carryForwardAllowed: d.carryForwardAllowed,
              maxCarryForwardDays: d.maxCarryForwardDays || 0,
              requiresAttachment: d.requiresAttachment,
              attachmentAfterDays: d.attachmentAfterDays || 2,
              requiresApproval: true,
              isActive: true,
              description: d.description
            }
          });
        } catch (e) {}
      }

      const refreshed = await prisma.leaveType.findMany({ where: { schoolId }, orderBy: { createdAt: "asc" } });
      return res.json(refreshed);
    }

    res.json(policies);
  } catch (error: any) {
    res.status(500).json({ error: error.message || "Failed to retrieve leave policies" });
  }
}

export async function createLeavePolicy(req: AuthenticatedRequest, res: Response) {
  try {
    const schoolId = req.user?.schoolId;
    const {
      name,
      code,
      annualAllocation,
      maxDays,
      maxConsecutiveDays,
      minNoticePeriodDays,
      carryForwardAllowed,
      maxCarryForwardDays,
      requiresAttachment,
      attachmentAfterDays,
      requiresApproval = true,
      description
    } = req.body;

    if (!schoolId) {
      return res.status(400).json({ error: "Missing school context" });
    }

    if (!name || !code) {
      return res.status(400).json({ error: "Policy name and unique code are required." });
    }

    const upperCode = code.toUpperCase().trim();
    const policy = await prisma.leaveType.create({
      data: {
        schoolId,
        name: name.trim(),
        code: upperCode,
        maxDays: parseInt(annualAllocation || maxDays || 12, 10),
        maxConsecutiveDays: maxConsecutiveDays ? parseInt(maxConsecutiveDays, 10) : 5,
        minNoticePeriodDays: minNoticePeriodDays ? parseInt(minNoticePeriodDays, 10) : 2,
        carryForwardAllowed: Boolean(carryForwardAllowed),
        maxCarryForwardDays: maxCarryForwardDays ? parseInt(maxCarryForwardDays, 10) : 0,
        requiresAttachment: Boolean(requiresAttachment),
        attachmentAfterDays: attachmentAfterDays ? parseInt(attachmentAfterDays, 10) : 2,
        requiresApproval: Boolean(requiresApproval),
        isActive: true,
        description: description || null,
      }
    });

    await createAuditLog({
      schoolId,
      userId: req.user?.id,
      userFullName: req.user?.fullName,
      userRole: req.user?.role,
      action: "CREATE_POLICY",
      entityType: "LEAVE_POLICY",
      entityId: policy.id,
      newValue: JSON.stringify(policy)
    });

    res.status(201).json({ message: "Leave policy created successfully", policy });
  } catch (error: any) {
    res.status(500).json({ error: error.message || "Failed to create leave policy" });
  }
}

export async function updateLeavePolicy(req: AuthenticatedRequest, res: Response) {
  try {
    const { id } = req.params;
    const {
      name,
      annualAllocation,
      maxDays,
      maxConsecutiveDays,
      minNoticePeriodDays,
      carryForwardAllowed,
      maxCarryForwardDays,
      requiresAttachment,
      attachmentAfterDays,
      requiresApproval,
      isActive,
      description
    } = req.body;

    const data: any = {};
    if (name !== undefined) data.name = name.trim();
    if (annualAllocation !== undefined || maxDays !== undefined) data.maxDays = parseInt(annualAllocation || maxDays, 10);
    if (maxConsecutiveDays !== undefined) data.maxConsecutiveDays = parseInt(maxConsecutiveDays, 10);
    if (minNoticePeriodDays !== undefined) data.minNoticePeriodDays = parseInt(minNoticePeriodDays, 10);
    if (carryForwardAllowed !== undefined) data.carryForwardAllowed = Boolean(carryForwardAllowed);
    if (maxCarryForwardDays !== undefined) data.maxCarryForwardDays = parseInt(maxCarryForwardDays, 10);
    if (requiresAttachment !== undefined) data.requiresAttachment = Boolean(requiresAttachment);
    if (attachmentAfterDays !== undefined) data.attachmentAfterDays = parseInt(attachmentAfterDays, 10);
    if (requiresApproval !== undefined) data.requiresApproval = Boolean(requiresApproval);
    if (isActive !== undefined) data.isActive = Boolean(isActive);
    if (description !== undefined) data.description = description;

    const updated = await prisma.leaveType.update({
      where: { id },
      data
    });

    await createAuditLog({
      schoolId: req.user?.schoolId,
      userId: req.user?.id,
      userFullName: req.user?.fullName,
      userRole: req.user?.role,
      action: "UPDATE_POLICY",
      entityType: "LEAVE_POLICY",
      entityId: id,
      newValue: JSON.stringify(updated)
    });

    res.json({ message: "Leave policy updated successfully", policy: updated });
  } catch (error: any) {
    res.status(500).json({ error: error.message || "Failed to update leave policy" });
  }
}

export async function deleteLeavePolicy(req: AuthenticatedRequest, res: Response) {
  try {
    const { id } = req.params;
    await prisma.leaveType.delete({ where: { id } });

    await createAuditLog({
      schoolId: req.user?.schoolId,
      userId: req.user?.id,
      userFullName: req.user?.fullName,
      userRole: req.user?.role,
      action: "DELETE_POLICY",
      entityType: "LEAVE_POLICY",
      entityId: id
    });

    res.json({ message: "Leave policy deleted successfully" });
  } catch (error: any) {
    res.status(500).json({ error: error.message || "Failed to delete leave policy" });
  }
}

// ==========================================
// 6. STATISTICS & HISTORY
// ==========================================

export async function getLeaveStatistics(req: AuthenticatedRequest, res: Response) {
  try {
    const schoolId = req.user?.schoolId;
    const leaves = await prisma.leaveRequest.findMany({
      where: schoolId ? { user: { schoolId } } : {}
    });

    const pending = leaves.filter(l => l.status === "PENDING").length;
    const approved = leaves.filter(l => l.status === "APPROVED").length;
    const rejected = leaves.filter(l => l.status === "REJECTED").length;

    const rectifications = await prisma.attendanceRectification.count({
      where: {
        ...(schoolId ? { user: { schoolId } } : {}),
        status: "PENDING"
      }
    });

    res.json({
      pendingRequests: pending,
      approvedRequests: approved,
      rejectedRequests: rejected,
      pendingRectifications: rectifications,
    });
  } catch (error: any) {
    res.status(500).json({ error: error.message || "Failed to retrieve statistics" });
  }
}

export async function getEmployeeLeaveHistory(req: AuthenticatedRequest, res: Response) {
  try {
    const { employeeId } = req.params;

    let targetUser = await prisma.user.findUnique({
      where: { id: employeeId },
      include: { teacherProfile: true }
    });
    if (!targetUser) {
      const cleanId = employeeId.replace("EMP-", "").toLowerCase();
      const all = await prisma.user.findMany({ include: { teacherProfile: true } });
      targetUser = all.find(u => u.id.toLowerCase().startsWith(cleanId)) || null;
    }

    if (!targetUser) {
      return res.status(404).json({ error: "Employee not found" });
    }

    const leaveRequests = await prisma.leaveRequest.findMany({
      where: { userId: targetUser.id },
      include: { approver: true },
      orderBy: { createdAt: "desc" }
    });

    const rectifications = await prisma.attendanceRectification.findMany({
      where: { userId: targetUser.id },
      include: { approvedBy: true },
      orderBy: { date: "desc" }
    });

    const balances = await prisma.leaveBalance.findMany({
      where: { userId: targetUser.id }
    });

    const auditLogs = await prisma.auditLog.findMany({
      where: {
        OR: [
          { entityId: targetUser.id },
          { newValue: { contains: targetUser.fullName } }
        ]
      },
      orderBy: { createdAt: "desc" },
      take: 20
    });

    res.json({
      employee: {
        id: targetUser.id,
        employeeId: `EMP-${targetUser.id.slice(0, 4).toUpperCase()}`,
        fullName: targetUser.fullName,
        email: targetUser.email,
        role: targetUser.role,
        photo: targetUser.profileImage || "/assets/teacher_hero.jpg",
      },
      leaveRequests: leaveRequests.map(l => ({
        ...l,
        startDate: l.fromDate.toISOString().split("T")[0],
        endDate: l.toDate.toISOString().split("T")[0],
        formattedStartDate: formatReadableDate(l.fromDate),
        formattedEndDate: formatReadableDate(l.toDate),
        formattedAppliedOn: formatReadableDate(l.createdAt),
      })),
      rectifications: rectifications.map(r => ({
        ...r,
        formattedDate: formatReadableDate(new Date(r.date + "T00:00:00.000Z")),
      })),
      balances,
      auditLogs
    });
  } catch (error: any) {
    res.status(500).json({ error: error.message || "Failed to retrieve employee history" });
  }
}

export async function getAuditLogs(req: AuthenticatedRequest, res: Response) {
  try {
    const schoolId = req.user?.schoolId;
    const logs = await prisma.auditLog.findMany({
      where: schoolId ? { schoolId } : {},
      orderBy: { createdAt: "desc" },
      take: 50
    });
    res.json(logs);
  } catch (error: any) {
    res.status(500).json({ error: error.message || "Failed to retrieve audit logs" });
  }
}
