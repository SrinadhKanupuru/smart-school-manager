import { Response } from "express";
import { AuthenticatedRequest } from "../middlewares/auth";
import prisma from "../config/db";

export async function getChildrenDashboard(req: AuthenticatedRequest, res: Response) {
  try {
    const userId = req.user?.id;
    if (!userId) {
      return res.status(401).json({ error: "Unauthorized" });
    }

    const parentProfile = await prisma.parentProfile.findUnique({
      where: { userId },
      include: {
        students: {
          include: {
            student: {
              include: {
                classSection: {
                  include: {
                    class: true
                  }
                },
                feeRecords: true,
                marks: {
                  include: {
                    exam: true
                  }
                },
                attendance: true
              }
            }
          }
        }
      }
    });

    if (!parentProfile) {
      return res.status(404).json({ error: "Parent profile not found" });
    }

    const childrenData = await Promise.all(
      parentProfile.students.map(async (link) => {
        const student = link.student;
        const totalDays = student.attendance.length;
        const presentDays = student.attendance.filter(a => a.status === "PRESENT" || a.status === "LEAVE").length;
        const attendancePercentage = totalDays > 0 ? Math.round((presentDays / totalDays) * 100) : 100;

        const homework = student.classSectionId
            ? await prisma.homework.findMany({
                where: { classSectionId: student.classSectionId },
                orderBy: { dueDate: "asc" },
                take: 5
              })
            : [];

        const diaries = student.classSectionId
            ? await prisma.learningDiary.findMany({
                where: { classSectionId: student.classSectionId },
                orderBy: { date: "desc" },
                take: 5
              })
            : [];

        const busRoute = student.busRouteId
            ? await prisma.busRoute.findUnique({
                where: { id: student.busRouteId },
                include: { stops: { orderBy: { sequenceNo: "asc" } } }
              })
            : await prisma.busRoute.findFirst({
                where: { schoolId: student.schoolId },
                include: { stops: { orderBy: { sequenceNo: "asc" } } }
              });

        const resources = student.classSectionId
            ? await prisma.classResource.findMany({
                where: { classSectionId: student.classSectionId },
                orderBy: { createdAt: "desc" }
              })
            : [];

        return {
          id: student.id,
          fullName: student.fullName,
          rollNo: student.rollNo,
          classSection: student.classSection,
          attendancePercentage,
          attendanceCount: totalDays,
          attendance: student.attendance,
          feeRecords: student.feeRecords,
          marks: student.marks,
          homework,
          diaries,
          busRoute,
          resources
        };
      })
    );

    res.json(childrenData);
  } catch (error: any) {
    res.status(500).json({ error: error.message || "Failed to load children dashboard data" });
  }
}

export async function requestChildLeave(req: AuthenticatedRequest, res: Response) {
  try {
    const { studentId, fromDate, toDate, reason, leaveType } = req.body;
    const userId = req.user?.id;

    if (!studentId || !fromDate || !toDate || !reason || !userId) {
      return res.status(400).json({ error: "Missing leave registration values" });
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
      return res.status(400).json({ error: "Cannot apply for child leave on past dates." });
    }

    // Check if student is already marked as PRESENT on any of the dates in the range
    const existingStudentAttendance = await prisma.attendance.findFirst({
      where: {
        studentId,
        date: {
          gte: start,
          lte: end
        },
        status: "PRESENT"
      }
    });
    if (existingStudentAttendance) {
      const dateStr = existingStudentAttendance.date.toISOString().split("T")[0];
      return res.status(400).json({
        error: `Cannot apply for child leave because the student has already been marked as PRESENT on ${dateStr}.`
      });
    }

    const existingApprovedOrPending = await prisma.leaveRequest.findFirst({
      where: {
        studentId,
        status: { in: ["APPROVED", "PENDING"] },
        OR: [
          {
            fromDate: { lte: end },
            toDate: { gte: start }
          }
        ]
      }
    });
    if (existingApprovedOrPending) {
      return res.status(400).json({ error: "This student already has a pending or approved leave request that overlaps with this date range." });
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

    const leave = await prisma.leaveRequest.create({
      data: {
        userId, // Parent user creates the leave request
        leaveType: leaveType || "CHILD_SICK_LEAVE",
        fromDate: new Date(fromDate),
        toDate: new Date(toDate),
        reason: reason,
        status: "PENDING",
        studentId: studentId
      }
    });

    res.status(201).json({ message: "Sick leave permission requested for child", leave });
  } catch (error: any) {
    res.status(500).json({ error: error.message || "Failed to submit child leave request" });
  }
}

export async function payFeeSimulated(req: AuthenticatedRequest, res: Response) {
  try {
    const { feeRecordId } = req.params;

    const record = await prisma.feeRecord.findUnique({ where: { id: feeRecordId } });
    if (!record) {
      return res.status(404).json({ error: "Fee record not found" });
    }

    const updated = await prisma.feeRecord.update({
      where: { id: feeRecordId },
      data: {
        status: "PAID",
        paidAmount: record.amount
      }
    });

    res.json({ message: "Fee payment successful (Simulated)", record: updated });
  } catch (error: any) {
    res.status(500).json({ error: error.message || "Failed to complete transaction" });
  }
}
