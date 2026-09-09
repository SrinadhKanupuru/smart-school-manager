import { Response } from "express";
import { AuthenticatedRequest } from "../middlewares/auth";
import prisma from "../config/db";

export async function initiateForeclosure(req: AuthenticatedRequest, res: Response) {
  try {
    const { loanId, processingFee = 0, deductionMethod = "SALARY_DEDUCTION", salaryDeductionMonth, salaryDeductionYear } = req.body;
    const userId = req.user?.id;
    const schoolId = req.user?.schoolId;

    if (!userId || !schoolId) {
      return res.status(400).json({ error: "Missing identity context" });
    }

    if (!loanId) {
      return res.status(400).json({ error: "Missing required field: loanId" });
    }

    const loan = await prisma.loanRequest.findUnique({
      where: { id: loanId },
      include: { foreclosure: true },
    });

    if (!loan) {
      return res.status(404).json({ error: "Loan not found" });
    }

    if (loan.userId !== userId) {
      return res.status(403).json({ error: "You can only request foreclosure for your own loans" });
    }

    if (loan.status !== "APPROVED") {
      return res.status(400).json({ error: "Cannot request foreclosure on an unapproved loan" });
    }

    const outstandingBalance = loan.amount - loan.repaidAmount;
    if (outstandingBalance <= 0) {
      return res.status(400).json({ error: "This loan is already fully repaid" });
    }

    // Check if there is already an active foreclosure request
    if (loan.foreclosure) {
      const status = loan.foreclosure.status;
      if (status !== "REJECTED" && status !== "CANCELLED") {
        return res.status(400).json({ error: `A foreclosure request already exists with status: ${status}` });
      }
    }

    const fee = parseFloat(processingFee);
    const totalPayableAmount = outstandingBalance + (isNaN(fee) ? 0 : fee);

    // If SALARY_DEDUCTION, validate or set month/year
    let deductionMonth = salaryDeductionMonth;
    let deductionYear = salaryDeductionYear ? parseInt(salaryDeductionYear) : undefined;

    if (deductionMethod === "SALARY_DEDUCTION" && (!deductionMonth || !deductionYear)) {
      return res.status(400).json({ error: "Salary deduction month and year are required for salary deduction method" });
    }

    // Create or update (overwrite) foreclosure
    const foreclosure = await prisma.loanForeclosure.upsert({
      where: { loanId },
      create: {
        loanId,
        userId,
        schoolId,
        outstandingBalance,
        processingFee: isNaN(fee) ? 0 : fee,
        totalPayableAmount,
        status: "REQUESTED",
        deductionMethod,
        salaryDeductionMonth: deductionMonth,
        salaryDeductionYear: deductionYear,
      },
      update: {
        outstandingBalance,
        processingFee: isNaN(fee) ? 0 : fee,
        totalPayableAmount,
        status: "REQUESTED",
        deductionMethod,
        salaryDeductionMonth: deductionMonth,
        salaryDeductionYear: deductionYear,
      },
    });

    res.status(201).json({ message: "Loan foreclosure initiated successfully", foreclosure });
  } catch (error: any) {
    res.status(500).json({ error: error.message || "Failed to initiate loan foreclosure" });
  }
}

export async function approveForeclosure(req: AuthenticatedRequest, res: Response) {
  try {
    const { id } = req.params;
    const role = req.user?.role;
    const schoolId = req.user?.schoolId;

    if (!schoolId) {
      return res.status(400).json({ error: "Missing school context" });
    }

    if (role !== "CORRESPONDENT" && role !== "PRINCIPAL" && role !== "HM") {
      return res.status(403).json({ error: "Unauthorized to approve loan foreclosures" });
    }

    const existing = await prisma.loanForeclosure.findUnique({
      where: { id },
    });

    if (!existing || existing.schoolId !== schoolId) {
      return res.status(404).json({ error: "Foreclosure request not found" });
    }

    if (existing.status !== "REQUESTED") {
      return res.status(400).json({ error: `Cannot approve foreclosure with status: ${existing.status}` });
    }

    // If deductionMethod is MANUAL_SETTLEMENT, change to SETTLEMENT_PENDING.
    // If SALARY_DEDUCTION, change to APPROVED.
    const newStatus = existing.deductionMethod === "MANUAL_SETTLEMENT" ? "SETTLEMENT_PENDING" : "APPROVED";

    const updated = await prisma.loanForeclosure.update({
      where: { id },
      data: {
        status: newStatus,
      },
    });

    res.json({ message: `Foreclosure request approved. Status set to: ${newStatus}`, foreclosure: updated });
  } catch (error: any) {
    res.status(500).json({ error: error.message || "Failed to approve foreclosure request" });
  }
}

export async function rejectForeclosure(req: AuthenticatedRequest, res: Response) {
  try {
    const { id } = req.params;
    const role = req.user?.role;
    const schoolId = req.user?.schoolId;

    if (!schoolId) {
      return res.status(400).json({ error: "Missing school context" });
    }

    if (role !== "CORRESPONDENT" && role !== "PRINCIPAL" && role !== "HM") {
      return res.status(403).json({ error: "Unauthorized to reject loan foreclosures" });
    }

    const existing = await prisma.loanForeclosure.findUnique({
      where: { id },
    });

    if (!existing || existing.schoolId !== schoolId) {
      return res.status(404).json({ error: "Foreclosure request not found" });
    }

    if (existing.status !== "REQUESTED" && existing.status !== "SETTLEMENT_PENDING") {
      return res.status(400).json({ error: `Cannot reject foreclosure with status: ${existing.status}` });
    }

    const updated = await prisma.loanForeclosure.update({
      where: { id },
      data: {
        status: "REJECTED",
      },
    });

    res.json({ message: "Foreclosure request rejected successfully", foreclosure: updated });
  } catch (error: any) {
    res.status(500).json({ error: error.message || "Failed to reject foreclosure request" });
  }
}

export async function settleManualForeclosure(req: AuthenticatedRequest, res: Response) {
  try {
    const { id } = req.params;
    const { referenceId, remarks } = req.body;
    const role = req.user?.role;
    const schoolId = req.user?.schoolId;

    if (!schoolId) {
      return res.status(400).json({ error: "Missing school context" });
    }

    if (role !== "CORRESPONDENT" && role !== "PRINCIPAL" && role !== "HM") {
      return res.status(403).json({ error: "Unauthorized to settle loan foreclosures" });
    }

    const foreclosure = await prisma.loanForeclosure.findUnique({
      where: { id },
      include: { loan: true },
    });

    if (!foreclosure || foreclosure.schoolId !== schoolId) {
      return res.status(404).json({ error: "Foreclosure request not found" });
    }

    if (foreclosure.status !== "SETTLEMENT_PENDING") {
      return res.status(400).json({ error: "Foreclosure status must be SETTLEMENT_PENDING for manual settlement" });
    }

    // Execute settlement: update LoanForeclosure to SETTLED, record LoanRepayment, and complete LoanRequest
    const result = await prisma.$transaction(async (tx) => {
      const updatedForeclosure = await tx.loanForeclosure.update({
        where: { id },
        data: { status: "SETTLED" },
      });

      const repayment = await tx.loanRepayment.create({
        data: {
          loanId: foreclosure.loanId,
          repaymentType: "MANUAL_FORECLOSURE",
          amount: foreclosure.outstandingBalance, // the remaining balance
          referenceId,
          remarks: remarks || "Manual foreclosure settlement",
        },
      });

      const updatedLoan = await tx.loanRequest.update({
        where: { id: foreclosure.loanId },
        data: {
          repaidAmount: foreclosure.loan.amount, // fully repaid
          remainingBalance: 0,
        },
      });

      return { updatedForeclosure, repayment, updatedLoan };
    });

    res.json({ message: "Manual foreclosure settled successfully", result });
  } catch (error: any) {
    res.status(500).json({ error: error.message || "Failed to settle manual foreclosure" });
  }
}

export async function getForeclosures(req: AuthenticatedRequest, res: Response) {
  try {
    const schoolId = req.user?.schoolId;
    const userId = req.user?.id;
    const role = req.user?.role;

    if (!schoolId || !userId) {
      return res.status(400).json({ error: "Missing identity context" });
    }

    let foreclosures;
    if (role === "CORRESPONDENT" || role === "PRINCIPAL" || role === "HM") {
      foreclosures = await prisma.loanForeclosure.findMany({
        where: { schoolId },
        include: {
          user: { select: { fullName: true, role: true } },
          loan: { select: { amount: true, repaidAmount: true, remainingBalance: true } },
        },
        orderBy: { createdAt: "desc" },
      });
    } else {
      foreclosures = await prisma.loanForeclosure.findMany({
        where: { userId },
        include: {
          loan: { select: { amount: true, repaidAmount: true, remainingBalance: true } },
        },
        orderBy: { createdAt: "desc" },
      });
    }

    res.json(foreclosures);
  } catch (error: any) {
    res.status(500).json({ error: error.message || "Failed to retrieve foreclosures" });
  }
}
