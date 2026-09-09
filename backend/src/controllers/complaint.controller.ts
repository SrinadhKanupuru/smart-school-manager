import { Response } from "express";
import { AuthenticatedRequest } from "../middlewares/auth";
import prisma from "../config/db";

export async function raiseComplaint(req: AuthenticatedRequest, res: Response) {
  try {
    const { category, description } = req.body;
    const schoolId = req.user?.schoolId;
    const userId = req.user?.id;

    if (!category || !description || !schoolId || !userId) {
      return res.status(400).json({ error: "Category and description are required" });
    }

    const complaint = await prisma.complaint.create({
      data: {
        schoolId,
        creatorId: userId,
        category,
        description,
        status: "PENDING"
      }
    });

    res.status(201).json({ message: "Complaint submitted successfully", complaint });
  } catch (error: any) {
    res.status(500).json({ error: error.message || "Failed to submit complaint" });
  }
}

export async function getComplaints(req: AuthenticatedRequest, res: Response) {
  try {
    const schoolId = req.user?.schoolId;
    const userId = req.user?.id;
    const role = req.user?.role;

    if (!schoolId || !userId) {
      return res.status(400).json({ error: "Missing identity context" });
    }

    let complaints;
    // Admins see everything
    if (role === "CORRESPONDENT" || role === "PRINCIPAL" || role === "HM") {
      complaints = await prisma.complaint.findMany({
        where: { schoolId },
        include: {
          creator: { select: { fullName: true, role: true } },
          resolver: { select: { fullName: true } }
        },
        orderBy: { createdAt: "desc" }
      });
    } else {
      // User only sees their own complaints
      complaints = await prisma.complaint.findMany({
        where: { creatorId: userId },
        include: {
          creator: { select: { fullName: true, role: true } },
          resolver: { select: { fullName: true } }
        },
        orderBy: { createdAt: "desc" }
      });
    }

    res.json(complaints);
  } catch (error: any) {
    res.status(500).json({ error: error.message || "Failed to retrieve complaints list" });
  }
}

export async function resolveComplaint(req: AuthenticatedRequest, res: Response) {
  try {
    const { complaintId } = req.params;
    const resolverId = req.user?.id;

    if (!resolverId) {
      return res.status(400).json({ error: "Missing resolver ID" });
    }

    const complaint = await prisma.complaint.update({
      where: { id: complaintId },
      data: {
        status: "RESOLVED",
        resolvedById: resolverId
      }
    });

    res.json({ message: "Complaint marked as RESOLVED", complaint });
  } catch (error: any) {
    res.status(500).json({ error: error.message || "Failed to resolve complaint" });
  }
}
