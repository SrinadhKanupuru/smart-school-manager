import 'package:flutter/material.dart';

/// Represents a student/child in the Parent Portal
class ChildStudent {
  final String id;
  final String name;
  final String grade;
  final String section;
  final String rollNo;
  final String classTeacher;
  final String avatarUrl;
  final String dob;
  final String bloodGroup;
  final String gender;
  final String emergencyContact;
  final double attendancePercentage;
  final double averageScore;
  final String feeStatus;
  final double pendingFees;
  final double totalFees;
  final List<String> subjects;
  final String academicYear;
  final String houseName;

  const ChildStudent({
    required this.id,
    required this.name,
    required this.grade,
    required this.section,
    required this.rollNo,
    required this.classTeacher,
    required this.avatarUrl,
    required this.dob,
    required this.bloodGroup,
    this.gender = 'Male',
    required this.emergencyContact,
    required this.attendancePercentage,
    required this.averageScore,
    required this.feeStatus,
    required this.pendingFees,
    required this.totalFees,
    required this.subjects,
    this.academicYear = '2025-2026',
    this.houseName = 'Tagore House (Blue)',
  });

  String get classAndSection => '$grade - Section $section';
  String get shortClass => '$grade - $section';
  double get attendanceRate => attendancePercentage;
  double get academicAverage => averageScore;
  String get busRoute => 'Route #4 (Bus 12 - Driver: Ramesh)';
}

/// Represents attendance overview and calendar logs for a child
class ChildAttendanceSummary {
  final int presentDays;
  final int absentDays;
  final int lateDays;
  final int leaveDays;
  final int totalWorkingDays;
  final double percentage;
  final List<ChildAttendanceDay> dailyRecords;

  const ChildAttendanceSummary({
    required this.presentDays,
    required this.absentDays,
    required this.lateDays,
    required this.leaveDays,
    required this.totalWorkingDays,
    required this.percentage,
    required this.dailyRecords,
  });

  int get totalDays => totalWorkingDays;
}

enum AttendanceStatus {
  present,
  absent,
  late,
  leave,
  holiday,
  weekend,
}

class ChildAttendanceDay {
  final DateTime date;
  final AttendanceStatus status;
  final String? timeIn;
  final String? timeOut;
  final String? remarks;

  const ChildAttendanceDay({
    required this.date,
    required this.status,
    this.timeIn,
    this.timeOut,
    this.remarks,
  });

  String get statusLabel {
    switch (status) {
      case AttendanceStatus.present:
        return 'Present';
      case AttendanceStatus.absent:
        return 'Absent';
      case AttendanceStatus.late:
        return 'Late';
      case AttendanceStatus.leave:
        return 'Leave';
      case AttendanceStatus.holiday:
        return 'Holiday';
      case AttendanceStatus.weekend:
        return 'Weekend';
    }
  }

  Color get statusColor {
    switch (status) {
      case AttendanceStatus.present:
        return const Color(0xFF10B981);
      case AttendanceStatus.absent:
        return const Color(0xFFEF4444);
      case AttendanceStatus.late:
        return const Color(0xFFF59E0B);
      case AttendanceStatus.leave:
        return const Color(0xFF8B5CF6);
      case AttendanceStatus.holiday:
        return const Color(0xFF0EA5E9);
      case AttendanceStatus.weekend:
        return const Color(0xFF94A3B8);
    }
  }
}

/// Homework assigned to a child
class ChildHomework {
  final String id;
  final String childId;
  final String subject;
  final String title;
  final String description;
  final DateTime assignedDate;
  final DateTime dueDate;
  final String status; // 'Pending' | 'Completed'
  final String teacherName;
  final int attachmentsCount;

  const ChildHomework({
    required this.id,
    required this.childId,
    required this.subject,
    required this.title,
    required this.description,
    required this.assignedDate,
    required this.dueDate,
    required this.status,
    required this.teacherName,
    this.attachmentsCount = 1,
  });

  bool get isPending => status == 'Pending';
  bool get isCompleted => status == 'Completed';
}

/// Assignment for child
class ChildAssignment {
  final String id;
  final String childId;
  final String subject;
  final String title;
  final String description;
  final DateTime assignedDate;
  final DateTime dueDate;
  final String submissionStatus; // 'Pending' | 'Submitted' | 'Graded'
  final int? marksObtained;
  final int maxMarks;
  final String? feedback;
  final String teacherName;

  const ChildAssignment({
    required this.id,
    required this.childId,
    required this.subject,
    required this.title,
    required this.description,
    required this.assignedDate,
    required this.dueDate,
    required this.submissionStatus,
    this.marksObtained,
    this.maxMarks = 25,
    this.feedback,
    required this.teacherName,
  });

  bool get isGraded => submissionStatus == 'Graded';
  bool get isSubmitted => submissionStatus == 'Submitted';
  bool get isPending => submissionStatus == 'Pending';
}

/// Upcoming Exam and Syllabus
class ChildExam {
  final String id;
  final String childId;
  final String examName;
  final String subject;
  final DateTime date;
  final String time;
  final String room;
  final int totalMarks;
  final String syllabus;

  const ChildExam({
    required this.id,
    required this.childId,
    required this.examName,
    required this.subject,
    required this.date,
    required this.time,
    required this.room,
    this.totalMarks = 100,
    required this.syllabus,
  });
}

/// Exam result of a child
class ChildResult {
  final String id;
  final String childId;
  final String examName;
  final String subject;
  final int marksObtained;
  final int totalMarks;
  final String grade;
  final double percentage;
  final double classAverage;
  final String remarks;

  const ChildResult({
    required this.id,
    required this.childId,
    required this.examName,
    required this.subject,
    required this.marksObtained,
    required this.totalMarks,
    required this.grade,
    required this.percentage,
    required this.classAverage,
    required this.remarks,
  });
}

/// Fees and receipt models
class ChildFeeSummary {
  final String childId;
  final double totalFees;
  final double paidFees;
  final double pendingFees;
  final double overdueFees;
  final String nextDueDate;
  final List<FeeInstallmentItem> installments;
  final List<FeePaymentReceipt> receipts;

  const ChildFeeSummary({
    required this.childId,
    required this.totalFees,
    required this.paidFees,
    required this.pendingFees,
    required this.overdueFees,
    required this.nextDueDate,
    required this.installments,
    required this.receipts,
  });
}

class FeeInstallmentItem {
  final String title;
  final double amount;
  final String dueDate;
  final String status; // 'Paid' | 'Pending' | 'Overdue'

  const FeeInstallmentItem({
    required this.title,
    required this.amount,
    required this.dueDate,
    required this.status,
  });
}

class FeePaymentReceipt {
  final String id;
  final String receiptNo;
  final DateTime paymentDate;
  final double amount;
  final String paymentMethod;
  final String description;
  final String status; // 'Paid' | 'Processing'

  const FeePaymentReceipt({
    required this.id,
    required this.receiptNo,
    required this.paymentDate,
    required this.amount,
    required this.paymentMethod,
    required this.description,
    this.status = 'Paid',
  });
}

/// Timetable Slot
class ChildTimetableSlot {
  final String day; // 'Monday', 'Tuesday', etc.
  final String time; // '09:00 AM - 09:45 AM'
  final String subject;
  final String teacher;
  final String room;
  final Color color;

  const ChildTimetableSlot({
    required this.day,
    required this.time,
    required this.subject,
    required this.teacher,
    required this.room,
    required this.color,
  });
}

/// School Notice
class ParentNoticeItem {
  final String id;
  final String title;
  final DateTime date;
  final String category; // 'Academic', 'Event', 'Holiday', 'Meeting'
  final String shortDescription;
  final String fullContent;
  final String issuedBy;
  final bool isImportant;

  const ParentNoticeItem({
    required this.id,
    required this.title,
    required this.date,
    required this.category,
    required this.shortDescription,
    required this.fullContent,
    required this.issuedBy,
    this.isImportant = false,
  });
}

/// Communication message
class ParentMessageItem {
  final String id;
  final String senderName;
  final String senderRole; // 'Class Teacher', 'Principal Office', 'Administration'
  final String avatarInitials;
  final String subject;
  final String message;
  final DateTime timestamp;
  final bool isUnread;
  final List<String> replies;

  const ParentMessageItem({
    required this.id,
    required this.senderName,
    required this.senderRole,
    required this.avatarInitials,
    required this.subject,
    required this.message,
    required this.timestamp,
    this.isUnread = false,
    this.replies = const [],
  });

  ParentMessageItem copyWith({
    bool? isUnread,
    List<String>? replies,
  }) {
    return ParentMessageItem(
      id: id,
      senderName: senderName,
      senderRole: senderRole,
      avatarInitials: avatarInitials,
      subject: subject,
      message: message,
      timestamp: timestamp,
      isUnread: isUnread ?? this.isUnread,
      replies: replies ?? this.replies,
    );
  }
}

/// Leave request model
class ParentLeaveItem {
  final String id;
  final String childId;
  final String childName;
  final String leaveType; // 'Sick Leave', 'Personal Leave', 'Family Function', 'Other'
  final DateTime startDate;
  final DateTime endDate;
  final int daysCount;
  final String reason;
  final String status; // 'Pending' | 'Approved' | 'Rejected'
  final DateTime appliedDate;
  final String? approverRemarks;

  const ParentLeaveItem({
    required this.id,
    required this.childId,
    required this.childName,
    required this.leaveType,
    required this.startDate,
    required this.endDate,
    required this.daysCount,
    required this.reason,
    required this.status,
    required this.appliedDate,
    this.approverRemarks,
  });
}

/// Parent notification item
class ParentNotificationItem {
  final String id;
  final String title;
  final String description;
  final String timeAgo;
  final bool isRead;
  final IconData icon;
  final Color iconColor;
  final String type;

  const ParentNotificationItem({
    required this.id,
    required this.title,
    required this.description,
    required this.timeAgo,
    this.isRead = false,
    required this.icon,
    required this.iconColor,
    required this.type,
  });

  ParentNotificationItem copyWith({bool? isRead}) {
    return ParentNotificationItem(
      id: id,
      title: title,
      description: description,
      timeAgo: timeAgo,
      isRead: isRead ?? this.isRead,
      icon: icon,
      iconColor: iconColor,
      type: type,
    );
  }
}
