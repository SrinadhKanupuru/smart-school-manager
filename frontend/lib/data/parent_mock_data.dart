import 'package:flutter/material.dart';
import '../models/parent_portal_models.dart';

class ParentMockData {
  static const String parentName = 'Mr. Rajesh Varma';
  static const String parentId = 'PAR001';
  static const String parentEmail = 'parent.rajesh@smartschool.edu';
  static const String parentPhone = '+91 98450 67890';
  static const String parentAddress = 'Flat 402, Sunshine Meadows, Green Glen Layout, Bengaluru - 560103';
  static const String parentOccupation = 'Senior Software Architect';

  // 1. Linked Children
  static final List<ChildStudent> children = [
    const ChildStudent(
      id: 'STU1024',
      name: 'Rahul Varma',
      grade: 'Grade 8',
      section: 'Section A',
      rollNo: '24',
      classTeacher: 'Ms. Kavya Sharma',
      avatarUrl: '',
      dob: '14 Aug 2012',
      bloodGroup: 'O+',
      gender: 'Male',
      emergencyContact: '+91 98450 67890 (Father)',
      attendancePercentage: 96.4,
      averageScore: 87.0,
      feeStatus: '₹12,500 Pending',
      pendingFees: 12500,
      totalFees: 60000,
      subjects: [
        'Mathematics',
        'Science (Physics & Chem)',
        'English Language & Lit',
        'Social Studies',
        'Computer Applications',
        'Hindi'
      ],
      academicYear: '2025-2026',
      houseName: 'Tagore House (Blue)',
    ),
    const ChildStudent(
      id: 'STU1089',
      name: 'Ananya Varma',
      grade: 'Grade 5',
      section: 'Section B',
      rollNo: '12',
      classTeacher: 'Mr. Arun Patel',
      avatarUrl: '',
      dob: '02 Mar 2015',
      bloodGroup: 'A+',
      gender: 'Female',
      emergencyContact: '+91 98450 67890 (Father)',
      attendancePercentage: 98.2,
      averageScore: 92.5,
      feeStatus: 'Fully Paid',
      pendingFees: 0,
      totalFees: 52000,
      subjects: [
        'Mathematics',
        'Environmental Science',
        'English',
        'Visual Arts',
        'Computer Fundamentals',
        'Hindi'
      ],
      academicYear: '2025-2026',
      houseName: 'Raman House (Yellow)',
    ),
  ];

  // 2. Attendance Data
  static ChildAttendanceSummary getAttendanceForChild(String childId) {
    if (childId == 'STU1089') {
      return ChildAttendanceSummary(
        presentDays: 24,
        absentDays: 0,
        lateDays: 1,
        leaveDays: 0,
        totalWorkingDays: 25,
        percentage: 98.2,
        dailyRecords: _generateDailyRecords(isHigh: true),
      );
    }
    // Default Rahul
    return ChildAttendanceSummary(
      presentDays: 22,
      absentDays: 1,
      lateDays: 2,
      leaveDays: 1,
      totalWorkingDays: 26,
      percentage: 96.4,
      dailyRecords: _generateDailyRecords(isHigh: false),
    );
  }

  static List<ChildAttendanceDay> _generateDailyRecords({required bool isHigh}) {
    final List<ChildAttendanceDay> list = [];
    final now = DateTime.now();

    for (int i = 1; i <= 28; i++) {
      final dayDate = DateTime(now.year, now.month, i);
      final weekday = dayDate.weekday;

      if (weekday == DateTime.sunday) {
        list.add(ChildAttendanceDay(
          date: dayDate,
          status: AttendanceStatus.weekend,
          remarks: 'Sunday',
        ));
      } else if (i == 2) {
        list.add(ChildAttendanceDay(
          date: dayDate,
          status: AttendanceStatus.holiday,
          remarks: 'Gandhi Jayanti / Public Holiday',
        ));
      } else if (i == 14 && !isHigh) {
        list.add(ChildAttendanceDay(
          date: dayDate,
          status: AttendanceStatus.leave,
          remarks: 'Approved Sick Leave',
        ));
      } else if (i == 8 && !isHigh) {
        list.add(ChildAttendanceDay(
          date: dayDate,
          status: AttendanceStatus.absent,
          remarks: 'Uninformed Absence',
        ));
      } else if (i == 5 || (i == 19 && !isHigh)) {
        list.add(ChildAttendanceDay(
          date: dayDate,
          status: AttendanceStatus.late,
          timeIn: '08:42 AM',
          timeOut: '03:30 PM',
          remarks: 'Late Entry (School bus delay)',
        ));
      } else {
        list.add(ChildAttendanceDay(
          date: dayDate,
          status: AttendanceStatus.present,
          timeIn: '08:20 AM',
          timeOut: '03:30 PM',
          remarks: 'On time',
        ));
      }
    }
    return list;
  }

  // 3. Homework Data
  static List<ChildHomework> getHomeworkForChild(String childId) {
    if (childId == 'STU1089') {
      return [
        ChildHomework(
          id: 'HW-501',
          childId: 'STU1089',
          subject: 'Mathematics',
          title: 'Fractions & Decimals Practice',
          description: 'Complete workbook pages 34 to 36 and solve real-world word problems.',
          assignedDate: DateTime.now().subtract(const Duration(days: 1)),
          dueDate: DateTime.now().add(const Duration(days: 1)),
          status: 'Pending',
          teacherName: 'Mr. Arun Patel',
          attachmentsCount: 1,
        ),
        ChildHomework(
          id: 'HW-502',
          childId: 'STU1089',
          subject: 'EVS Science',
          title: 'Plant Kingdom Scrapbook',
          description: 'Collect 4 distinct types of fallen leaves and label their veins and stems.',
          assignedDate: DateTime.now().subtract(const Duration(days: 2)),
          dueDate: DateTime.now().add(const Duration(days: 2)),
          status: 'Completed',
          teacherName: 'Mrs. Deepa Menon',
          attachmentsCount: 2,
        ),
      ];
    }

    return [
      ChildHomework(
        id: 'HW-801',
        childId: 'STU1024',
        subject: 'Mathematics',
        title: 'Chapter 5: Algebraic Expressions',
        description: 'Solve Exercise 5.2 Questions 1 to 15 in the homework notebook. Show complete step-by-step factoring.',
        assignedDate: DateTime.now().subtract(const Duration(days: 1)),
        dueDate: DateTime.now(),
        status: 'Pending',
        teacherName: 'Ms. Kavya Sharma',
        attachmentsCount: 2,
      ),
      ChildHomework(
        id: 'HW-802',
        childId: 'STU1024',
        subject: 'Science (Physics)',
        title: 'Read Chapter 3: Force and Pressure',
        description: 'Review Pascal law diagrams on page 48 and prepare answers for review questions 1-5.',
        assignedDate: DateTime.now().subtract(const Duration(days: 2)),
        dueDate: DateTime.now().add(const Duration(days: 1)),
        status: 'Completed',
        teacherName: 'Dr. Sunil Rao',
        attachmentsCount: 1,
      ),
      ChildHomework(
        id: 'HW-803',
        childId: 'STU1024',
        subject: 'English',
        title: 'Argumentative Essay Writing',
        description: 'Write a 350-word essay on "Artificial Intelligence in Modern Education: Boon or Bane".',
        assignedDate: DateTime.now().subtract(const Duration(days: 1)),
        dueDate: DateTime.now().add(const Duration(days: 2)),
        status: 'Pending',
        teacherName: 'Mrs. Sarah Thomas',
        attachmentsCount: 1,
      ),
      ChildHomework(
        id: 'HW-804',
        childId: 'STU1024',
        subject: 'Computer Science',
        title: 'Python Loops & Conditional Logic',
        description: 'Write a Python program to calculate fibonacci sequence up to N terms and upload screenshot.',
        assignedDate: DateTime.now().subtract(const Duration(days: 3)),
        dueDate: DateTime.now().add(const Duration(days: 3)),
        status: 'Pending',
        teacherName: 'Mr. Vivek Nambiar',
        attachmentsCount: 3,
      ),
    ];
  }

  // 4. Assignments Data
  static List<ChildAssignment> getAssignmentsForChild(String childId) {
    if (childId == 'STU1089') {
      return [
        ChildAssignment(
          id: 'ASG-501',
          childId: 'STU1089',
          subject: 'Mathematics',
          title: 'Geometry & Angles Measurement',
          description: 'Construct acute, obtuse and right angles using protractor and ruler.',
          assignedDate: DateTime.now().subtract(const Duration(days: 4)),
          dueDate: DateTime.now().add(const Duration(days: 2)),
          submissionStatus: 'Submitted',
          marksObtained: 24,
          maxMarks: 25,
          feedback: 'Neat construction and accurate measurements. Well done!',
          teacherName: 'Mr. Arun Patel',
        ),
      ];
    }

    return [
      ChildAssignment(
        id: 'ASG-801',
        childId: 'STU1024',
        subject: 'Mathematics',
        title: 'Linear Equations & Factorization Project',
        description: 'Solve real-world speed/distance modeling problems with graphs.',
        assignedDate: DateTime.now().subtract(const Duration(days: 5)),
        dueDate: DateTime.now().add(const Duration(days: 2)),
        submissionStatus: 'Pending',
        maxMarks: 25,
        teacherName: 'Ms. Kavya Sharma',
      ),
      ChildAssignment(
        id: 'ASG-802',
        childId: 'STU1024',
        subject: 'Science (Physics)',
        title: 'Hydraulic Lift Working Model & Report',
        description: 'Submit lab project writeup describing Pascal fluid dynamics principle.',
        assignedDate: DateTime.now().subtract(const Duration(days: 10)),
        dueDate: DateTime.now().subtract(const Duration(days: 2)),
        submissionStatus: 'Graded',
        marksObtained: 23,
        maxMarks: 25,
        feedback: 'Excellent experimental diagram and clear mathematical derivations.',
        teacherName: 'Dr. Sunil Rao',
      ),
      ChildAssignment(
        id: 'ASG-803',
        childId: 'STU1024',
        subject: 'Social Science',
        title: 'Indian Constitution & Fundamental Rights',
        description: 'Case study analysis on Article 21 and right to education in rural zones.',
        assignedDate: DateTime.now().subtract(const Duration(days: 7)),
        dueDate: DateTime.now().subtract(const Duration(days: 1)),
        submissionStatus: 'Submitted',
        marksObtained: null,
        maxMarks: 20,
        feedback: 'Under evaluation by department',
        teacherName: 'Mrs. Rekha V',
      ),
    ];
  }

  // 5. Exams & Results Data
  static List<ChildExam> getUpcomingExams(String childId) {
    return [
      ChildExam(
        id: 'EX-01',
        childId: childId,
        examName: 'Mid-Term Examination 2026',
        subject: 'Mathematics',
        date: DateTime.now().add(const Duration(days: 2)),
        time: '10:00 AM - 01:00 PM',
        room: 'Hall B (Block 2)',
        totalMarks: 100,
        syllabus: 'Chapters 1 to 6 (Rational Numbers, Linear Equations, Quadrilaterals, Factorization)',
      ),
      ChildExam(
        id: 'EX-02',
        childId: childId,
        examName: 'Mid-Term Examination 2026',
        subject: 'Science (Physics & Chem)',
        date: DateTime.now().add(const Duration(days: 4)),
        time: '10:00 AM - 01:00 PM',
        room: 'Hall B (Block 2)',
        totalMarks: 100,
        syllabus: 'Force, Pressure, Sound, Synthetic Fibres & Chemical Reactions',
      ),
      ChildExam(
        id: 'EX-03',
        childId: childId,
        examName: 'Mid-Term Examination 2026',
        subject: 'English Language & Lit',
        date: DateTime.now().add(const Duration(days: 6)),
        time: '10:00 AM - 01:00 PM',
        room: 'Hall A (Main Block)',
        totalMarks: 100,
        syllabus: 'Reading Comprehension, Formal Letter, Grammar Editing, Prose Units 1-4',
      ),
      ChildExam(
        id: 'EX-04',
        childId: childId,
        examName: 'Mid-Term Examination 2026',
        subject: 'Social Science',
        date: DateTime.now().add(const Duration(days: 8)),
        time: '10:00 AM - 01:00 PM',
        room: 'Hall A (Main Block)',
        totalMarks: 100,
        syllabus: 'Resources, The Constitution, Colonial Rule & Map Skills',
      ),
    ];
  }

  static List<ChildResult> getPreviousResults(String childId) {
    if (childId == 'STU1089') {
      return [
        const ChildResult(
          id: 'RES-501',
          childId: 'STU1089',
          examName: 'Unit Assessment 1 (2025-26)',
          subject: 'Mathematics',
          marksObtained: 95,
          totalMarks: 100,
          grade: 'A+',
          percentage: 95.0,
          classAverage: 78.5,
          remarks: 'Outstanding logical reasoning and quick calculations.',
        ),
        const ChildResult(
          id: 'RES-502',
          childId: 'STU1089',
          examName: 'Unit Assessment 1 (2025-26)',
          subject: 'Environmental Science',
          marksObtained: 92,
          totalMarks: 100,
          grade: 'A+',
          percentage: 92.0,
          classAverage: 81.0,
          remarks: 'Very observant and thorough with ecosystem concepts.',
        ),
        const ChildResult(
          id: 'RES-503',
          childId: 'STU1089',
          examName: 'Unit Assessment 1 (2025-26)',
          subject: 'English Language',
          marksObtained: 90,
          totalMarks: 100,
          grade: 'A+',
          percentage: 90.0,
          classAverage: 79.2,
          remarks: 'Fluent expressive handwriting and rich vocabulary.',
        ),
      ];
    }

    return [
      const ChildResult(
        id: 'RES-801',
        childId: 'STU1024',
        examName: 'Unit Assessment 1 (2025-26)',
        subject: 'Mathematics',
        marksObtained: 87,
        totalMarks: 100,
        grade: 'A',
        percentage: 87.0,
        classAverage: 74.2,
        remarks: 'Strong problem solving skills in algebra. Pay closer attention to geometry proofs.',
      ),
      const ChildResult(
        id: 'RES-802',
        childId: 'STU1024',
        examName: 'Unit Assessment 1 (2025-26)',
        subject: 'Science',
        marksObtained: 91,
        totalMarks: 100,
        grade: 'A+',
        percentage: 91.0,
        classAverage: 76.5,
        remarks: 'Excellent understanding of physical concepts and lab apparatus.',
      ),
      const ChildResult(
        id: 'RES-803',
        childId: 'STU1024',
        examName: 'Unit Assessment 1 (2025-26)',
        subject: 'English',
        marksObtained: 84,
        totalMarks: 100,
        grade: 'A',
        percentage: 84.0,
        classAverage: 78.0,
        remarks: 'Good creative narrative writing. Can improve on formal grammar structure.',
      ),
      const ChildResult(
        id: 'RES-804',
        childId: 'STU1024',
        examName: 'Unit Assessment 1 (2025-26)',
        subject: 'Social Studies',
        marksObtained: 86,
        totalMarks: 100,
        grade: 'A',
        percentage: 86.0,
        classAverage: 73.8,
        remarks: 'High grasp of constitutional history and resource mapping.',
      ),
      const ChildResult(
        id: 'RES-805',
        childId: 'STU1024',
        examName: 'Unit Assessment 1 (2025-26)',
        subject: 'Computer Science',
        marksObtained: 96,
        totalMarks: 100,
        grade: 'A+',
        percentage: 96.0,
        classAverage: 80.4,
        remarks: 'Top performer in Python programming lab.',
      ),
    ];
  }

  // 6. Fee Summaries & Receipts
  static ChildFeeSummary getFeeSummary(String childId) {
    if (childId == 'STU1089') {
      return ChildFeeSummary(
        childId: 'STU1089',
        totalFees: 52000,
        paidFees: 52000,
        pendingFees: 0,
        overdueFees: 0,
        nextDueDate: 'All Cleared for Academic Year 2025-26',
        installments: [
          const FeeInstallmentItem(title: 'Term 1 Tuition & Annual Development', amount: 26000, dueDate: '15 Jun 2025', status: 'Paid'),
          const FeeInstallmentItem(title: 'Term 2 Tuition, Activity & Computer Lab', amount: 26000, dueDate: '15 Oct 2025', status: 'Paid'),
        ],
        receipts: [
          FeePaymentReceipt(
            id: 'REC-5001',
            receiptNo: 'REC-5001',
            paymentDate: DateTime(2025, 6, 12),
            amount: 26000,
            paymentMethod: 'UPI (GPay - HDFC Bank)',
            description: 'Term 1 Tuition & Development Fee',
          ),
          FeePaymentReceipt(
            id: 'REC-5002',
            receiptNo: 'REC-5002',
            paymentDate: DateTime(2025, 9, 2),
            amount: 26000,
            paymentMethod: 'HDFC NetBanking',
            description: 'Term 2 Tuition & Activity Fee',
          ),
        ],
      );
    }

    return ChildFeeSummary(
      childId: 'STU1024',
      totalFees: 60000,
      paidFees: 47500,
      pendingFees: 12500,
      overdueFees: 0,
      nextDueDate: '30 Sep 2026',
      installments: [
        const FeeInstallmentItem(title: 'Term 1 Tuition Fee', amount: 25000, dueDate: '15 Jun 2025', status: 'Paid'),
        const FeeInstallmentItem(title: 'Transportation & Bus Pass (Term 1 & 2)', amount: 15000, dueDate: '15 Jul 2025', status: 'Paid'),
        const FeeInstallmentItem(title: 'Science Lab & Tech Infrastructure', amount: 7500, dueDate: '10 Aug 2025', status: 'Paid'),
        const FeeInstallmentItem(title: 'Term 2 Tuition & Sports Fee (Final)', amount: 12500, dueDate: '30 Sep 2026', status: 'Pending'),
      ],
      receipts: [
        FeePaymentReceipt(
          id: 'REC-1024',
          receiptNo: 'REC-1024',
          paymentDate: DateTime(2025, 8, 10),
          amount: 7500,
          paymentMethod: 'UPI - Google Pay (HDFC)',
          description: 'Science Lab & Tech Infrastructure Fee',
        ),
        FeePaymentReceipt(
          id: 'REC-1011',
          receiptNo: 'REC-1011',
          paymentDate: DateTime(2025, 7, 14),
          amount: 15000,
          paymentMethod: 'Credit Card (ICICI Visa)',
          description: 'Annual Transportation Pass',
        ),
        FeePaymentReceipt(
          id: 'REC-0988',
          receiptNo: 'REC-0988',
          paymentDate: DateTime(2025, 6, 10),
          amount: 25000,
          paymentMethod: 'Net Banking (Axis Bank)',
          description: 'Term 1 Tuition & Registration Fee',
        ),
      ],
    );
  }

  // 7. Timetable Slots
  static List<ChildTimetableSlot> getTimetable(String childId) {
    return [
      // Monday
      const ChildTimetableSlot(day: 'Monday', time: '09:00 AM - 09:45 AM', subject: 'Mathematics', teacher: 'Ms. Kavya Sharma', room: 'Room 201', color: Color(0xFF3B82F6)),
      const ChildTimetableSlot(day: 'Monday', time: '09:45 AM - 10:30 AM', subject: 'Science (Physics)', teacher: 'Dr. Sunil Rao', room: 'Physics Lab', color: Color(0xFF10B981)),
      const ChildTimetableSlot(day: 'Monday', time: '10:45 AM - 11:30 AM', subject: 'English', teacher: 'Mrs. Sarah Thomas', room: 'Room 201', color: Color(0xFF8B5CF6)),
      const ChildTimetableSlot(day: 'Monday', time: '11:30 AM - 12:15 PM', subject: 'Social Studies', teacher: 'Mrs. Rekha V', room: 'Room 201', color: Color(0xFFF59E0B)),
      const ChildTimetableSlot(day: 'Monday', time: '01:00 PM - 01:45 PM', subject: 'Computer Science', teacher: 'Mr. Vivek Nambiar', room: 'Computer Lab 1', color: Color(0xFF0EA5E9)),
      const ChildTimetableSlot(day: 'Monday', time: '01:45 PM - 02:30 PM', subject: 'Physical Education', teacher: 'Coach Rakesh', room: 'Main Sports Ground', color: Color(0xFFEC4899)),

      // Tuesday
      const ChildTimetableSlot(day: 'Tuesday', time: '09:00 AM - 09:45 AM', subject: 'Science (Chemistry)', teacher: 'Dr. Neha Sen', room: 'Chemistry Lab', color: Color(0xFF10B981)),
      const ChildTimetableSlot(day: 'Tuesday', time: '09:45 AM - 10:30 AM', subject: 'Mathematics', teacher: 'Ms. Kavya Sharma', room: 'Room 201', color: Color(0xFF3B82F6)),
      const ChildTimetableSlot(day: 'Tuesday', time: '10:45 AM - 11:30 AM', subject: 'Hindi Literature', teacher: 'Mr. Ramanuj Shastri', room: 'Room 201', color: Color(0xFFD97706)),
      const ChildTimetableSlot(day: 'Tuesday', time: '11:30 AM - 12:15 PM', subject: 'English Grammar', teacher: 'Mrs. Sarah Thomas', room: 'Room 201', color: Color(0xFF8B5CF6)),
      const ChildTimetableSlot(day: 'Tuesday', time: '01:00 PM - 01:45 PM', subject: 'Library & Reading', teacher: 'Ms. Geeta K', room: 'Central Library', color: Color(0xFF6366F1)),
      const ChildTimetableSlot(day: 'Tuesday', time: '01:45 PM - 02:30 PM', subject: 'Art & Craft', teacher: 'Mrs. Shalini Rao', room: 'Art Studio', color: Color(0xFF14B8A6)),

      // Wednesday
      const ChildTimetableSlot(day: 'Wednesday', time: '09:00 AM - 09:45 AM', subject: 'Mathematics', teacher: 'Ms. Kavya Sharma', room: 'Room 201', color: Color(0xFF3B82F6)),
      const ChildTimetableSlot(day: 'Wednesday', time: '09:45 AM - 10:30 AM', subject: 'Social Studies', teacher: 'Mrs. Rekha V', room: 'Room 201', color: Color(0xFFF59E0B)),
      const ChildTimetableSlot(day: 'Wednesday', time: '10:45 AM - 11:30 AM', subject: 'Science (Biology)', teacher: 'Dr. Sunil Rao', room: 'Biology Lab', color: Color(0xFF10B981)),
      const ChildTimetableSlot(day: 'Wednesday', time: '11:30 AM - 12:15 PM', subject: 'Computer Coding', teacher: 'Mr. Vivek Nambiar', room: 'Computer Lab 1', color: Color(0xFF0EA5E9)),
      const ChildTimetableSlot(day: 'Wednesday', time: '01:00 PM - 01:45 PM', subject: 'English Lit', teacher: 'Mrs. Sarah Thomas', room: 'Room 201', color: Color(0xFF8B5CF6)),
      const ChildTimetableSlot(day: 'Wednesday', time: '01:45 PM - 02:30 PM', subject: 'Music & Choir', teacher: 'Mr. Augustine', room: 'Music Room', color: Color(0xFFF43F5E)),

      // Thursday
      const ChildTimetableSlot(day: 'Thursday', time: '09:00 AM - 09:45 AM', subject: 'English', teacher: 'Mrs. Sarah Thomas', room: 'Room 201', color: Color(0xFF8B5CF6)),
      const ChildTimetableSlot(day: 'Thursday', time: '09:45 AM - 10:30 AM', subject: 'Mathematics', teacher: 'Ms. Kavya Sharma', room: 'Room 201', color: Color(0xFF3B82F6)),
      const ChildTimetableSlot(day: 'Thursday', time: '10:45 AM - 11:30 AM', subject: 'Science Practical', teacher: 'Dr. Sunil Rao', room: 'Physics Lab', color: Color(0xFF10B981)),
      const ChildTimetableSlot(day: 'Thursday', time: '11:30 AM - 12:15 PM', subject: 'Hindi', teacher: 'Mr. Ramanuj Shastri', room: 'Room 201', color: Color(0xFFD97706)),
      const ChildTimetableSlot(day: 'Thursday', time: '01:00 PM - 01:45 PM', subject: 'Social Studies', teacher: 'Mrs. Rekha V', room: 'Room 201', color: Color(0xFFF59E0B)),
      const ChildTimetableSlot(day: 'Thursday', time: '01:45 PM - 02:30 PM', subject: 'Sports / Football', teacher: 'Coach Rakesh', room: 'Football Turf', color: Color(0xFFEC4899)),

      // Friday
      const ChildTimetableSlot(day: 'Friday', time: '09:00 AM - 09:45 AM', subject: 'Science (Physics)', teacher: 'Dr. Sunil Rao', room: 'Room 201', color: Color(0xFF10B981)),
      const ChildTimetableSlot(day: 'Friday', time: '09:45 AM - 10:30 AM', subject: 'Mathematics Quiz', teacher: 'Ms. Kavya Sharma', room: 'Room 201', color: Color(0xFF3B82F6)),
      const ChildTimetableSlot(day: 'Friday', time: '10:45 AM - 11:30 AM', subject: 'English Essay', teacher: 'Mrs. Sarah Thomas', room: 'Room 201', color: Color(0xFF8B5CF6)),
      const ChildTimetableSlot(day: 'Friday', time: '11:30 AM - 12:15 PM', subject: 'Robotics & AI', teacher: 'Mr. Vivek Nambiar', room: 'Innovation Hub', color: Color(0xFF0EA5E9)),
      const ChildTimetableSlot(day: 'Friday', time: '01:00 PM - 01:45 PM', subject: 'Social History', teacher: 'Mrs. Rekha V', room: 'Room 201', color: Color(0xFFF59E0B)),
      const ChildTimetableSlot(day: 'Friday', time: '01:45 PM - 02:30 PM', subject: 'Club Activity', teacher: 'Faculty In-Charge', room: 'Auditorium', color: Color(0xFF8B5CF6)),

      // Saturday (Half Day)
      const ChildTimetableSlot(day: 'Saturday', time: '09:00 AM - 09:45 AM', subject: 'Math Doubt Clearing', teacher: 'Ms. Kavya Sharma', room: 'Room 201', color: Color(0xFF3B82F6)),
      const ChildTimetableSlot(day: 'Saturday', time: '09:45 AM - 10:30 AM', subject: 'Science Quiz & Demo', teacher: 'Dr. Sunil Rao', room: 'Science Centre', color: Color(0xFF10B981)),
      const ChildTimetableSlot(day: 'Saturday', time: '10:45 AM - 11:30 AM', subject: 'General Knowledge', teacher: 'Mrs. Sarah Thomas', room: 'Room 201', color: Color(0xFF8B5CF6)),
      const ChildTimetableSlot(day: 'Saturday', time: '11:30 AM - 12:30 PM', subject: 'Inter-House Sports', teacher: 'PE Department', room: 'Sports Complex', color: Color(0xFFEC4899)),
    ];
  }

  // 8. Notices Data
  static final List<ParentNoticeItem> notices = [
    ParentNoticeItem(
      id: 'NTC-01',
      title: 'Parent-Teacher Meeting (PTM) - Term 1 Progress',
      date: DateTime.now().add(const Duration(days: 2)),
      category: 'Meeting',
      shortDescription: 'Quarterly review session to discuss student academic performance, attendance, and holistic development.',
      fullContent: 'Dear Parents & Guardians,\n\nYou are cordially invited to the Term 1 Parent-Teacher Meeting on Saturday from 09:30 AM to 01:00 PM in your child\'s respective classroom.\n\nIndividual time slots have been sent via messaging. Kindly bring your child\'s diary and progress tracker.',
      issuedBy: 'Office of Campus Principal',
      isImportant: true,
    ),
    ParentNoticeItem(
      id: 'NTC-02',
      title: 'Mid-Term Examination Schedule & Hall Tickets',
      date: DateTime.now().add(const Duration(days: 4)),
      category: 'Academic',
      shortDescription: 'The comprehensive examination timetable for Grades 1 to 12 is released. Hall tickets will be issued in class.',
      fullContent: 'Mid-term examinations will commence next week. Students are required to be seated 15 minutes before the exam start time.\n\nCalculators and smart watches are strictly prohibited in the exam hall. Please review the detailed syllabus posted in the Exams tab.',
      issuedBy: 'Academic Examination Board',
      isImportant: true,
    ),
    ParentNoticeItem(
      id: 'NTC-03',
      title: 'Annual Inter-School Sports Meet 2026',
      date: DateTime.now().add(const Duration(days: 10)),
      category: 'Event',
      shortDescription: 'Join us at the Main Athletic Ground for athletics, relay races, and championship trophy presentations.',
      fullContent: 'We invite all parents to cheer for our young athletes at the 14th Annual Sports Meet. Track and field events start at 08:30 AM.\n\nFood stalls and student band performances will be open throughout the day.',
      issuedBy: 'Department of Physical Education',
      isImportant: false,
    ),
    ParentNoticeItem(
      id: 'NTC-04',
      title: 'Gandhi Jayanti Public Holiday Declaration',
      date: DateTime.now().add(const Duration(days: 14)),
      category: 'Holiday',
      shortDescription: 'School campus and administrative offices will remain closed in observance of Gandhi Jayanti.',
      fullContent: 'Please note that the school will remain closed on October 2nd in honor of Gandhi Jayanti. Normal classroom operations will resume the following working day.',
      issuedBy: 'Administrative Registry',
      isImportant: false,
    ),
  ];

  // 9. Messages Data
  static final List<ParentMessageItem> messages = [
    ParentMessageItem(
      id: 'MSG-01',
      senderName: 'Ms. Kavya Sharma',
      senderRole: 'Class Teacher (Grade 8-A)',
      avatarInitials: 'KS',
      subject: 'Academic commendation in Algebra & Physics practicals',
      message: 'Hello Mr. Rajesh, I would like to appreciate Rahul\'s proactive participation in yesterday\'s Science lab. He assisted his team in measuring hydrostatic pressure with great accuracy. Please encourage him to keep up the consistency!',
      timestamp: DateTime.now().subtract(const Duration(hours: 3)),
      isUnread: true,
      replies: [
        'Thank you Ms. Kavya for the kind words! We are constantly encouraging him at home as well.'
      ],
    ),
    ParentMessageItem(
      id: 'MSG-02',
      senderName: 'Office of Campus Principal',
      senderRole: 'Principal (Dr. Rajeshwari Raman)',
      avatarInitials: 'RR',
      subject: 'Upcoming PTM Schedule & Slot Confirmation',
      message: 'Dear Parent, your one-on-one discussion slot for the upcoming PTM has been confirmed for 10:45 AM with Ms. Kavya Sharma. Please arrive 10 minutes prior to ensure smooth flow.',
      timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
      isUnread: false,
      replies: [],
    ),
    ParentMessageItem(
      id: 'MSG-03',
      senderName: 'School Accounts Office',
      senderRole: 'Finance & Accounts',
      avatarInitials: 'AC',
      subject: 'Term 2 Fee Installment Due Reminder',
      message: 'This is a gentle reminder that the Term 2 tuition fee installment of ₹12,500 is due on September 30. You may conveniently pay online using the Pay Fees portal with 0% transaction charges.',
      timestamp: DateTime.now().subtract(const Duration(days: 2)),
      isUnread: false,
      replies: [],
    ),
  ];

  // 10. Leave Requests Data
  static final List<ParentLeaveItem> initialLeaves = [
    ParentLeaveItem(
      id: 'LV-101',
      childId: 'STU1024',
      childName: 'Rahul Varma',
      leaveType: 'Sick Leave',
      startDate: DateTime(2025, 9, 14),
      endDate: DateTime(2025, 9, 14),
      daysCount: 1,
      reason: 'Suffering from viral fever and seasonal cold. Doctor advised complete bed rest for 24 hours.',
      status: 'Approved',
      appliedDate: DateTime(2025, 9, 13),
      approverRemarks: 'Approved by Ms. Kavya Sharma (Class Teacher). Please submit medical note upon return.',
    ),
    ParentLeaveItem(
      id: 'LV-102',
      childId: 'STU1024',
      childName: 'Rahul Varma',
      leaveType: 'Family Function',
      startDate: DateTime(2025, 8, 20),
      endDate: DateTime(2025, 8, 22),
      daysCount: 3,
      reason: 'Attending elder cousin\'s wedding ceremony out of town.',
      status: 'Approved',
      appliedDate: DateTime(2025, 8, 15),
      approverRemarks: 'Sanctioned by Principal. Advised to complete pending chapter assignments in advance.',
    ),
  ];

  // 11. Notifications Data
  static final List<ParentNotificationItem> notifications = [
    const ParentNotificationItem(
      id: 'NOT-01',
      title: 'New Homework Assigned',
      description: 'Mathematics: Chapter 5 Factoring Exercises due tomorrow.',
      timeAgo: '25m ago',
      icon: Icons.menu_book_rounded,
      iconColor: Color(0xFF3B82F6),
      type: 'homework',
    ),
    const ParentNotificationItem(
      id: 'NOT-02',
      title: 'Attendance Marked Today',
      description: 'Rahul Varma checked in on time at 08:20 AM.',
      timeAgo: '2h ago',
      icon: Icons.check_circle_rounded,
      iconColor: Color(0xFF10B981),
      type: 'attendance',
    ),
    const ParentNotificationItem(
      id: 'NOT-03',
      title: 'Fee Payment Received',
      description: 'Receipt REC-1024 for ₹7,500 has been verified & archived.',
      timeAgo: '1d ago',
      icon: Icons.receipt_long_rounded,
      iconColor: Color(0xFF8B5CF6),
      type: 'fees',
    ),
    const ParentNotificationItem(
      id: 'NOT-04',
      title: 'Parent-Teacher Meeting Notice',
      description: 'PTM scheduled for Sep 20. Your slot is 10:45 AM.',
      timeAgo: '2d ago',
      icon: Icons.event_available_rounded,
      iconColor: Color(0xFFF59E0B),
      type: 'notice',
    ),
    const ParentNotificationItem(
      id: 'NOT-05',
      title: 'New Message from Teacher',
      description: 'Ms. Kavya Sharma sent a commendation note for Physics practical.',
      timeAgo: '3d ago',
      icon: Icons.chat_bubble_outline_rounded,
      iconColor: Color(0xFF0EA5E9),
      type: 'message',
    ),
  ];
}
