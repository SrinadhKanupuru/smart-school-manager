import { Response } from "express";
import { AuthenticatedRequest } from "../middlewares/auth";
import prisma from "../config/db";

export async function createLeaveType(req: AuthenticatedRequest, res: Response) {
  try {
    const { name, code, isPaid = true, isUnpaid = false, maxDays = 12, period = "YEARLY", maxDaysMid = null, maxDaysSenior = null } = req.body;
    const schoolId = req.user?.schoolId;
    const role = req.user?.role;

    if (!schoolId) {
      return res.status(400).json({ error: "Missing school context" });
    }

    if (role !== "CORRESPONDENT" && role !== "PRINCIPAL" && role !== "HM") {
      return res.status(403).json({ error: "Unauthorized to create leave configurations" });
    }

    if (!name || !code) {
      return res.status(400).json({ error: "Missing required fields: name, code" });
    }

    if (period && !["MONTHLY", "YEARLY"].includes(period)) {
      return res.status(400).json({ error: "Period must be either 'MONTHLY' or 'YEARLY'" });
    }

    const upperCode = code.toUpperCase().trim();

    // Check if code already exists for this school
    const existing = await prisma.leaveType.findUnique({
      where: {
        schoolId_code: {
          schoolId,
          code: upperCode,
        },
      },
    });

    if (existing) {
      return res.status(400).json({ error: `Leave type with code '${upperCode}' already exists for this school` });
    }

    const leaveType = await prisma.leaveType.create({
      data: {
        schoolId,
        name: name.trim(),
        code: upperCode,
        isPaid: Boolean(isPaid),
        isUnpaid: Boolean(isUnpaid),
        maxDays: Number(maxDays),
        period: period,
        maxDaysMid: maxDaysMid !== null ? Number(maxDaysMid) : null,
        maxDaysSenior: maxDaysSenior !== null ? Number(maxDaysSenior) : null,
      },
    });

    res.status(201).json({ message: "Leave type created successfully", leaveType });
  } catch (error: any) {
    res.status(500).json({ error: error.message || "Failed to create leave type" });
  }
}

export async function getLeaveTypes(req: AuthenticatedRequest, res: Response) {
  try {
    const schoolId = req.user?.schoolId;
    if (!schoolId) {
      return res.status(400).json({ error: "Missing school context" });
    }

    const leaveTypes = await prisma.leaveType.findMany({
      where: { schoolId },
      orderBy: { createdAt: "asc" },
    });

    res.json(leaveTypes);
  } catch (error: any) {
    res.status(500).json({ error: error.message || "Failed to retrieve leave types" });
  }
}

export async function updateLeaveType(req: AuthenticatedRequest, res: Response) {
  try {
    const { id } = req.params;
    const { name, code, isPaid, isUnpaid, maxDays, period, maxDaysMid, maxDaysSenior } = req.body;
    const schoolId = req.user?.schoolId;
    const role = req.user?.role;

    if (!schoolId) {
      return res.status(400).json({ error: "Missing school context" });
    }

    if (role !== "CORRESPONDENT" && role !== "PRINCIPAL" && role !== "HM") {
      return res.status(403).json({ error: "Unauthorized to update leave configurations" });
    }

    const existing = await prisma.leaveType.findUnique({
      where: { id },
    });

    if (!existing || existing.schoolId !== schoolId) {
      return res.status(404).json({ error: "Leave type not found" });
    }

    const updateData: any = {};
    if (name !== undefined) updateData.name = name.trim();
    if (isPaid !== undefined) updateData.isPaid = Boolean(isPaid);
    if (isUnpaid !== undefined) updateData.isUnpaid = Boolean(isUnpaid);
    if (maxDays !== undefined) updateData.maxDays = Number(maxDays);
    if (period !== undefined) {
      if (!["MONTHLY", "YEARLY"].includes(period)) {
        return res.status(400).json({ error: "Period must be either 'MONTHLY' or 'YEARLY'" });
      }
      updateData.period = period;
    }
    if (maxDaysMid !== undefined) updateData.maxDaysMid = maxDaysMid !== null ? Number(maxDaysMid) : null;
    if (maxDaysSenior !== undefined) updateData.maxDaysSenior = maxDaysSenior !== null ? Number(maxDaysSenior) : null;

    if (code !== undefined) {
      const upperCode = code.toUpperCase().trim();
      if (upperCode !== existing.code) {
        // Verify code uniqueness
        const codeConflict = await prisma.leaveType.findUnique({
          where: {
            schoolId_code: {
              schoolId,
              code: upperCode,
            },
          },
        });
        if (codeConflict) {
          return res.status(400).json({ error: `Leave type with code '${upperCode}' already exists` });
        }
        updateData.code = upperCode;
      }
    }

    const updated = await prisma.leaveType.update({
      where: { id },
      data: updateData,
    });

    res.json({ message: "Leave type updated successfully", leaveType: updated });
  } catch (error: any) {
    res.status(500).json({ error: error.message || "Failed to update leave type" });
  }
}

export async function deleteLeaveType(req: AuthenticatedRequest, res: Response) {
  try {
    const { id } = req.params;
    const schoolId = req.user?.schoolId;
    const role = req.user?.role;

    if (!schoolId) {
      return res.status(400).json({ error: "Missing school context" });
    }

    if (role !== "CORRESPONDENT" && role !== "PRINCIPAL" && role !== "HM") {
      return res.status(403).json({ error: "Unauthorized to delete leave configurations" });
    }

    const existing = await prisma.leaveType.findUnique({
      where: { id },
    });

    if (!existing || existing.schoolId !== schoolId) {
      return res.status(404).json({ error: "Leave type not found" });
    }

    await prisma.leaveType.delete({
      where: { id },
    });

    res.json({ message: "Leave type deleted successfully" });
  } catch (error: any) {
    res.status(500).json({ error: error.message || "Failed to delete leave type" });
  }
}
