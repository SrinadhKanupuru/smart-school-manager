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

  factory FeeTransaction.fromJson(Map<String, dynamic> json) {
    String sName = json['studentName']?.toString() ?? '';
    String sClass = json['studentClass']?.toString() ?? 'Class 10-A';
    if (json['student'] != null && json['student'] is Map) {
      sName = json['student']['fullName']?.toString() ?? sName;
      if (json['student']['classSection'] != null && json['student']['classSection'] is Map) {
        final cs = json['student']['classSection'];
        sClass = '${cs['class']?['name'] ?? 'Class 10'}-${cs['name'] ?? 'A'}';
      }
    }

    final amt = (json['amount'] as num?)?.toDouble() ?? (json['totalAmount'] as num?)?.toDouble() ?? 25000.0;
    final paid = (json['paidAmount'] as num?)?.toDouble() ?? (json['amountPaid'] as num?)?.toDouble() ?? 0.0;
    final pending = (amt - paid) > 0 ? (amt - paid) : 0.0;

    return FeeTransaction(
      id: json['id']?.toString() ?? '',
      receiptNo: json['receiptNo']?.toString() ?? (json['id'] != null ? 'REC-${json['id'].toString().substring(0, 4).toUpperCase()}' : 'REC-1001'),
      studentName: sName.isNotEmpty ? sName : 'Student',
      studentClass: sClass,
      feeType: json['category']?.toString() ?? json['feeType']?.toString() ?? 'Tuition Fee (Q2)',
      totalAmount: amt,
      paidAmount: paid,
      pendingAmount: pending,
      dueDate: json['dueDate'] != null ? json['dueDate'].toString().split('T')[0] : '30 Sep 2026',
      paymentDate: json['paymentDate']?.toString() ?? (paid > 0 ? (json['updatedAt'] != null ? json['updatedAt'].toString().split('T')[0] : '15 Sep 2026') : '—'),
      status: json['status']?.toString() ?? (pending == 0 ? 'Paid' : (paid > 0 ? 'Partial' : 'Pending')),
      paymentMode: json['paymentMode']?.toString() ?? (paid > 0 ? 'UPI / Online' : '—'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'receiptNo': receiptNo,
      'studentName': studentName,
      'studentClass': studentClass,
      'category': feeType,
      'amount': totalAmount,
      'paidAmount': paidAmount,
      'pendingAmount': pendingAmount,
      'dueDate': dueDate,
      'paymentDate': paymentDate,
      'status': status,
      'paymentMode': paymentMode,
    };
  }
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

  factory SchoolNotification.fromJson(Map<String, dynamic> json) {
    return SchoolNotification(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Notification',
      message: json['message']?.toString() ?? json['description']?.toString() ?? '',
      time: json['createdAt'] != null ? json['createdAt'].toString().split('T')[0] : 'Just now',
      category: json['type']?.toString() ?? 'Notice',
      icon: Icons.notifications_active_rounded,
      color: const Color(0xFF2563EB),
      isRead: json['isRead'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'type': category,
      'isRead': isRead,
    };
  }
}
