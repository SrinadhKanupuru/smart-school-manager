import { Response } from "express";
import { AuthenticatedRequest } from "../middlewares/auth";
import { registerStaffWithFaceService, verifyAndMarkStaffAttendanceService, syncAbsentAndLeaveAttendanceRecords } from "../services/face.service";
import prisma from "../config/db";

export const registerStaffController = async (req: AuthenticatedRequest, res: Response) => {
  try {
    const admin = req.user;
    if (!admin || !admin.schoolId) {
      return res.status(400).json({ error: "Missing admin session context or schoolId" });
    }

    const { email, fullName, role } = req.body;
    if (!email || !fullName || !role) {
      return res.status(400).json({ error: "Required fields: email, password, fullName, role" });
    }

    // Role hierarchy authorization check
    const creatorRole = admin.role;
    if (creatorRole !== "CORRESPONDENT" && creatorRole !== "PRINCIPAL" && creatorRole !== "HM") {
      return res.status(403).json({ error: "Permission denied: only Correspondent, Principal, or HM can register staff" });
    }

    if ((role === "PRINCIPAL" || role === "HM") && creatorRole !== "CORRESPONDENT") {
      return res.status(403).json({ error: "Only the Correspondent can register Principal or HM roles" });
    }

    if (!req.file) {
      return res.status(400).json({ error: "Face image file is required for registration" });
    }

    const result = await registerStaffWithFaceService(
      { schoolId: admin.schoolId, id: admin.id },
      req.body,
      req.file.buffer
    );

    return res.status(201).json({
      message: `${role} staff registered successfully with biometric face profile`,
      user: {
        id: result.id,
        fullName: result.fullName,
        email: result.email,
        role: result.role,
      },
    });
  } catch (err: any) {
    console.error("[REGISTER_STAFF_CONTROLLER_ERROR]:", err);
    return res.status(400).json({ error: err.message || "Failed to process staff registration" });
  }
};

export const verifyAttendanceController = async (req: AuthenticatedRequest, res: Response) => {
  try {
    const user = req.user;
    if (!user || !user.schoolId) {
      return res.status(400).json({ error: "Missing user session context or schoolId" });
    }

    if (!req.file) {
      return res.status(400).json({ error: "Face image file is required for verification" });
    }

    const { latitude, longitude } = req.body;
    const location = latitude && longitude
      ? { latitude: Number(latitude), longitude: Number(longitude) }
      : undefined;

    const result = await verifyAndMarkStaffAttendanceService(
      { id: user.id, schoolId: user.schoolId },
      req.file.buffer,
      location
    );

    return res.status(200).json({
      message: `${result.type} attendance recorded successfully`,
      data: {
        attendance: result.attendance,
        type: result.type,
        confidence: result.confidence,
        isInsideGeo: result.isInsideGeo,
      },
    });
  } catch (err: any) {
    console.error("[VERIFY_ATTENDANCE_CONTROLLER_ERROR]:", err);
    return res.status(400).json({ error: err.message || "Face attendance verification failed" });
  }
};

export const getStaffAttendanceHistoryController = async (req: AuthenticatedRequest, res: Response) => {
  try {
    const user = req.user;
    if (!user) {
      return res.status(401).json({ error: "Unauthorized" });
    }

    let targetUserId = user.id;

    // Sync attendance in background/sync for the current user's school
    const today = new Date();
    const monthNames = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];
    try {
      await syncAbsentAndLeaveAttendanceRecords(user.schoolId, monthNames[today.getMonth()], today.getFullYear());
      if (today.getDate() <= 7) {
        const prevDate = new Date(today.getFullYear(), today.getMonth() - 1, 1);
        await syncAbsentAndLeaveAttendanceRecords(user.schoolId, monthNames[prevDate.getMonth()], prevDate.getFullYear());
      }
    } catch (e) {
      console.error("[ATTENDANCE_SYNC_ERROR]:", e);
    }

    // If an administrator requests a specific user's history, check credentials and allow it
    const { userId } = req.query;
    if (userId && typeof userId === "string" && userId !== user.id) {
      if (user.role !== "CORRESPONDENT" && user.role !== "PRINCIPAL" && user.role !== "HM") {
        return res.status(403).json({ error: "Permission denied to view other user's attendance" });
      }
      targetUserId = userId;
    }

    const history = await prisma.staffAttendance.findMany({
      where: { userId: targetUserId },
      orderBy: { date: "desc" },
    });

    return res.json(history);
  } catch (err: any) {
    console.error("[GET_STAFF_ATTENDANCE_HISTORY_ERROR]:", err);
    return res.status(500).json({ error: err.message || "Failed to fetch staff attendance history" });
  }
};

