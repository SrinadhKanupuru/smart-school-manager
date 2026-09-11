import 'package:flutter/material.dart';

class FeeTransaction {
  final String id;
  final String receiptNo;
  final String studentName;
  final String studentClass;
  final String feeType; // Tuition, Transport, Lab, Library, Annual
  final double totalAmount;
  final double paidAmount;
  final double pendingAmount;
  final String dueDate;
  final String paymentDate;
  final String status; // Paid, Partial, Pending, Overdue
  final String paymentMode; // UPI, Net Banking, Card, Cash

  const FeeTransaction({
    required this.id,
    required this.receiptNo,
    required this.studentName,
    required this.studentClass,
    required this.feeType,
    required this.totalAmount,
    required this.paidAmount,
    required this.pendingAmount,
    required this.dueDate,
    required this.paymentDate,
    required this.status,
    required this.paymentMode,
  });
}

class SchoolNotification {
  final String id;
  final String title;
  final String message;
  final String time;
  final String category; // Notice, Fee, Attendance, Exam
  final IconData icon;
  final Color color;
  bool isRead;

  SchoolNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.time,
    required this.category,
    required this.icon,
    required this.color,
    this.isRead = false,
  });
}
