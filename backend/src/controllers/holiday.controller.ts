import { Response } from "express";
import { AuthenticatedRequest } from "../middlewares/auth";
import prisma from "../config/db";

export async function createHoliday(req: AuthenticatedRequest, res: Response) {
  try {
    const { title, date, type = "HOLIDAY" } = req.body;
    const schoolId = req.user?.schoolId;
    const userId = req.user?.id;

    if (!title || !date || !schoolId || !userId) {
      return res.status(400).json({ error: "Missing required fields: title, date" });
    }

    if (type !== "HOLIDAY") {
      return res.status(400).json({ error: "Invalid type. Dynamically scheduled records must be type: HOLIDAY" });
    }

    // Normalize date to start of UTC day
    const dateOnly = date.split("T")[0];
    const holidayDate = new Date(`${dateOnly}T00:00:00.000Z`);

    // Check if a holiday already exists for this date and school
    const existing = await prisma.schoolHoliday.findUnique({
      where: {
        schoolId_date: {
          schoolId,
          date: holidayDate,
        },
      },
    });

    if (existing) {
      return res.status(400).json({ error: "A holiday or weekly off is already scheduled for this date" });
    }

    const holiday = await prisma.schoolHoliday.create({
      data: {
        schoolId,
        title,
        date: holidayDate,
        type,
        createdById: userId,
      },
    });

    res.status(201).json({ message: "Holiday scheduled successfully", holiday });
  } catch (error: any) {
    res.status(500).json({ error: error.message || "Failed to schedule holiday" });
  }
}

export async function getHolidays(req: AuthenticatedRequest, res: Response) {
  try {
    const schoolId = req.user?.schoolId;
    if (!schoolId) {
      return res.status(400).json({ error: "Missing school context" });
    }

    const holidays = await prisma.schoolHoliday.findMany({
      where: { schoolId },
      orderBy: { date: "asc" },
    });

    res.json(holidays);
  } catch (error: any) {
    res.status(500).json({ error: error.message || "Failed to retrieve holidays" });
  }
}

export async function deleteHoliday(req: AuthenticatedRequest, res: Response) {
  try {
    const { id } = req.params;

    const existing = await prisma.schoolHoliday.findUnique({
      where: { id },
    });

    if (!existing) {
      return res.status(404).json({ error: "Holiday record not found" });
    }

    await prisma.schoolHoliday.delete({
      where: { id },
    });

    res.json({ message: "Holiday record deleted successfully" });
  } catch (error: any) {
    res.status(500).json({ error: error.message || "Failed to delete holiday" });
  }
}
