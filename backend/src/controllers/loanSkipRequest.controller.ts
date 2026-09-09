import { Response } from "express";
import { AuthenticatedRequest } from "../middlewares/auth";
import prisma from "../config/db";

export async function createSkipRequest(req: AuthenticatedRequest, res: Response) {
  try {
    const { loanId, fromMonth, fromYear, toMonth, toYear, reason } = req.body;
    const userId = req.user?.id;
    const schoolId = req.user?.schoolId;

    if (!userId || !schoolId) {
      return res.status(400).json({ error: "Missing identity context" });
    }

    if (!loanId || !fromMonth || !fromYear || !toMonth || !toYear) {
      return res.status(400).json({ error: "Missing required fields: loanId, fromMonth, fromYear, toMonth, toYear" });
    }

    const startM = parseInt(fromMonth);
    const startY = parseInt(fromYear);
    const endM = parseInt(toMonth);
    const endY = parseInt(toYear);

    if (startM < 1 || startM > 12 || endM < 1 || endM > 12) {
      return res.status(400).json({ error: "Months must be between 1 and 12" });
    }

    const numberOfMonths = (endY - startY) * 12 + (endM - startM) + 1;
    if (numberOfMonths <= 0) {
      return res.status(400).json({ error: "Invalid date range: end date must be after or equal to start date" });
    }

    // Verify loan existence and ownership
    const loan = await prisma.loanRequest.findUnique({
      where: { id: loanId },
    });

    if (!loan) {
      return res.status(404).json({ error: "Loan not found" });
    }

    if (loan.userId !== userId) {
      return res.status(403).json({ error: "You can only request skips for your own loans" });
    }

    if (loan.status !== "APPROVED") {
      return res.status(400).json({ error: "Cannot request skips for unapproved loans" });
    }

    const remaining = loan.amount - loan.repaidAmount;
    if (remaining <= 0) {
      return res.status(400).json({ error: "This loan is already fully repaid" });
    }

    // Check for overlapping pending or approved skip requests
    const overlapping = await prisma.loanSkipRequest.findFirst({
      where: {
        loanId,
        status: { in: ["PENDING", "APPROVED"] },
        OR: [
          // request start is within existing range
          {
            fromYear: { lte: startY },
            toYear: { gte: startY },
            // simpler check: let's match ranges
          }
        ],
      },
    });

    // Let's do a more precise month-by-month range overlap check
    const existingSkips = await prisma.loanSkipRequest.findMany({
      where: {
        loanId,
        status: { in: ["PENDING", "APPROVED"] },
      },
    });

    const requestedMonths: number[] = [];
    for (let y = startY; y <= endY; y++) {
      const mStart = y === startY ? startM : 1;
      const mEnd = y === endY ? endM : 12;
      for (let m = mStart; m <= mEnd; m++) {
        requestedMonths.push(y * 12 + m);
      }
    }

    for (const skip of existingSkips) {
      const skipMonths: number[] = [];
      for (let y = skip.fromYear; y <= skip.toYear; y++) {
        const mStart = y === skip.fromYear ? skip.fromMonth : 1;
        const mEnd = y === skip.toYear ? skip.toMonth : 12;
        for (let m = mStart; m <= mEnd; m++) {
          skipMonths.push(y * 12 + m);
        }
      }

      const hasOverlap = requestedMonths.some(val => skipMonths.includes(val));
      if (hasOverlap) {
        return res.status(400).json({ error: "Requested skip range overlaps with an existing pending or approved skip request" });
      }
    }

    const skipRequest = await prisma.loanSkipRequest.create({
      data: {
        loanId,
        userId,
        schoolId,
        fromMonth: startM,
        fromYear: startY,
        toMonth: endM,
        toYear: endY,
        numberOfMonths,
        reason,
        status: "PENDING",
      },
    });

    res.status(201).json({ message: "Loan skip request submitted successfully", skipRequest });
  } catch (error: any) {
    res.status(500).json({ error: error.message || "Failed to submit loan skip request" });
  }
}

export async function approveSkipRequest(req: AuthenticatedRequest, res: Response) {
  try {
    const { id } = req.params;
    const { approvalComment } = req.body;
    const approverId = req.user?.id;
    const role = req.user?.role;
    const schoolId = req.user?.schoolId;

    if (!approverId || !schoolId) {
      return res.status(400).json({ error: "Missing identity context" });
    }

    if (role !== "CORRESPONDENT" && role !== "PRINCIPAL" && role !== "HM") {
      return res.status(403).json({ error: "Unauthorized to approve loan skip requests" });
    }

    const existing = await prisma.loanSkipRequest.findUnique({
      where: { id },
    });

    if (!existing || existing.schoolId !== schoolId) {
      return res.status(404).json({ error: "Skip request not found" });
    }

    if (existing.status !== "PENDING") {
      return res.status(400).json({ error: `Cannot approve skip request with status: ${existing.status}` });
    }

    // Set skip request to APPROVED and toggle loan's isPaused to true
    const updated = await prisma.$transaction([
      prisma.loanSkipRequest.update({
        where: { id },
        data: {
          status: "APPROVED",
          approvedById: approverId,
          approvedAt: new Date(),
          approvalComment,
        },
      }),
      prisma.loanRequest.update({
        where: { id: existing.loanId },
        data: {
          isPaused: true,
        },
      }),
    ]);

    res.json({ message: "Loan skip request approved successfully", skipRequest: updated[0] });
  } catch (error: any) {
    res.status(500).json({ error: error.message || "Failed to approve loan skip request" });
  }
}

export async function rejectSkipRequest(req: AuthenticatedRequest, res: Response) {
  try {
    const { id } = req.params;
    const { rejectionReason } = req.body;
    const rejectorId = req.user?.id;
    const role = req.user?.role;
    const schoolId = req.user?.schoolId;

    if (!rejectorId || !schoolId) {
      return res.status(400).json({ error: "Missing identity context" });
    }

    if (role !== "CORRESPONDENT" && role !== "PRINCIPAL" && role !== "HM") {
      return res.status(403).json({ error: "Unauthorized to reject loan skip requests" });
    }

    if (!rejectionReason) {
      return res.status(400).json({ error: "Rejection reason is required" });
    }

    const existing = await prisma.loanSkipRequest.findUnique({
      where: { id },
    });

    if (!existing || existing.schoolId !== schoolId) {
      return res.status(404).json({ error: "Skip request not found" });
    }

    if (existing.status !== "PENDING") {
      return res.status(400).json({ error: `Cannot reject skip request with status: ${existing.status}` });
    }

    const updated = await prisma.loanSkipRequest.update({
      where: { id },
      data: {
        status: "REJECTED",
        rejectedById: rejectorId,
        rejectedAt: new Date(),
        rejectionReason,
      },
    });

    res.json({ message: "Loan skip request rejected successfully", skipRequest: updated });
  } catch (error: any) {
    res.status(500).json({ error: error.message || "Failed to reject loan skip request" });
  }
}

export async function cancelSkipRequest(req: AuthenticatedRequest, res: Response) {
  try {
    const { id } = req.params;
    const userId = req.user?.id;

    if (!userId) {
      return res.status(400).json({ error: "Missing identity context" });
    }

    const existing = await prisma.loanSkipRequest.findUnique({
      where: { id },
    });

    if (!existing) {
      return res.status(404).json({ error: "Skip request not found" });
    }

    // Only owner can cancel pending request
    if (existing.userId !== userId) {
      return res.status(403).json({ error: "You can only cancel your own skip requests" });
    }

    if (existing.status !== "PENDING") {
      return res.status(400).json({ error: "Can only cancel skip requests that are PENDING" });
    }

    const updated = await prisma.loanSkipRequest.update({
      where: { id },
      data: {
        status: "CANCELLED",
      },
    });

    res.json({ message: "Loan skip request cancelled successfully", skipRequest: updated });
  } catch (error: any) {
    res.status(500).json({ error: error.message || "Failed to cancel loan skip request" });
  }
}

export async function getSkipRequests(req: AuthenticatedRequest, res: Response) {
  try {
    const schoolId = req.user?.schoolId;
    const userId = req.user?.id;
    const role = req.user?.role;

    if (!schoolId || !userId) {
      return res.status(400).json({ error: "Missing identity context" });
    }

    let skipRequests;
    if (role === "CORRESPONDENT" || role === "PRINCIPAL" || role === "HM") {
      skipRequests = await prisma.loanSkipRequest.findMany({
        where: { schoolId },
        include: {
          user: { select: { fullName: true, role: true } },
          loan: { select: { amount: true, installments: true } },
        },
        orderBy: { createdAt: "desc" },
      });
    } else {
      skipRequests = await prisma.loanSkipRequest.findMany({
        where: { userId },
        include: {
          loan: { select: { amount: true, installments: true } },
        },
        orderBy: { createdAt: "desc" },
      });
    }

    res.json(skipRequests);
  } catch (error: any) {
    res.status(500).json({ error: error.message || "Failed to retrieve skip requests" });
  }
}
