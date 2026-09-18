import { Response } from "express";
import prisma from "../config/db";

export async function getFeeRecords(req: any, res: Response) {
  try {
    const fees = await prisma.feeRecord.findMany({
      include: {
        student: {
          include: {
            classSection: {
              include: { class: true }
            }
          }
        }
      },
      orderBy: { dueDate: "desc" }
    });

    res.json({ count: fees.length, fees });
  } catch (error: any) {
    res.status(500).json({ error: error.message || "Failed to fetch fee records" });
  }
}

export async function payFee(req: any, res: Response) {
  try {
    const { feeId, amount, paymentMode } = req.body;

    if (!feeId || !amount) {
      return res.status(400).json({ error: "feeId and amount are required" });
    }

    const fee = await prisma.feeRecord.findUnique({ where: { id: feeId } });
    if (!fee) {
      return res.status(404).json({ error: "Fee record not found" });
    }

    const newPaidAmount = (fee.paidAmount || 0) + parseFloat(amount);
    const newStatus = newPaidAmount >= fee.amount ? "PAID" : "PARTIAL";

    const updated = await prisma.feeRecord.update({
      where: { id: feeId },
      data: {
        paidAmount: newPaidAmount,
        status: newStatus
      }
    });

    res.json({ message: "Fee payment recorded successfully", fee: updated });
  } catch (error: any) {
    res.status(500).json({ error: error.message || "Failed to process fee payment" });
  }
}
