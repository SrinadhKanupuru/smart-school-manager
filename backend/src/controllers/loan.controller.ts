import { Response } from "express";
import { AuthenticatedRequest } from "../middlewares/auth";
import prisma from "../config/db";

export async function requestLoan(req: AuthenticatedRequest, res: Response) {
  try {
    const { amount, installments, reason } = req.body;
    const userId = req.user?.id;

    if (!amount || !installments || !reason || !userId) {
      return res.status(400).json({ error: "Missing required loan request properties" });
    }

    const loanAmount = parseFloat(amount);
    const loanInstallments = parseInt(installments);

    if (isNaN(loanAmount) || loanAmount <= 0) {
      return res.status(400).json({ error: "Loan amount must be a positive number" });
    }

    if (isNaN(loanInstallments) || loanInstallments <= 0) {
      return res.status(400).json({ error: "Repayment installments count must be at least 1" });
    }

    const loan = await prisma.loanRequest.create({
      data: {
        userId,
        amount: loanAmount,
        installments: loanInstallments,
        reason,
        status: "PENDING",
      },
    });

    res.status(201).json({ message: "Loan application submitted successfully", loan });
  } catch (error: any) {
    res.status(500).json({ error: error.message || "Failed to submit loan request" });
  }
}

export async function getLoans(req: AuthenticatedRequest, res: Response) {
  try {
    const schoolId = req.user?.schoolId;
    const userId = req.user?.id;
    const role = req.user?.role;

    if (!schoolId || !userId) {
      return res.status(400).json({ error: "Missing identity context" });
    }

    let loans;
    if (role === "CORRESPONDENT" || role === "PRINCIPAL" || role === "HM") {
      // Admins can see all loan requests from users of their school
      loans = await prisma.loanRequest.findMany({
        where: {
          user: { schoolId },
        },
        include: {
          user: { select: { fullName: true, role: true } },
        },
        orderBy: { createdAt: "desc" },
      });
    } else {
      // Employees see their own requests
      loans = await prisma.loanRequest.findMany({
        where: { userId },
        orderBy: { createdAt: "desc" },
      });
    }

    res.json(loans);
  } catch (error: any) {
    res.status(500).json({ error: error.message || "Failed to retrieve loan requests" });
  }
}

export async function updateLoanStatus(req: AuthenticatedRequest, res: Response) {
  try {
    const { id } = req.params;
    const { status } = req.body; // APPROVED or REJECTED
    const approverId = req.user?.id;

    if (!status || !["APPROVED", "REJECTED"].includes(status)) {
      return res.status(400).json({ error: "Valid status (APPROVED or REJECTED) is required" });
    }

    const existing = await prisma.loanRequest.findUnique({
      where: { id },
    });

    if (!existing) {
      return res.status(404).json({ error: "Loan request not found" });
    }

    const loan = await prisma.loanRequest.update({
      where: { id },
      data: {
        status,
        approvedById: approverId,
      },
    });

    res.json({ message: `Loan request status updated to ${status}`, loan });
  } catch (error: any) {
    res.status(500).json({ error: error.message || "Failed to update loan request status" });
  }
}
