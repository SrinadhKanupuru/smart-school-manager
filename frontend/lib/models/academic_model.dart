class ClassSectionModel {
  final String id;
  final String className;
  final String section;
  final String classTeacher;
  final int totalStudents;
  final int capacity;
  final String roomNo;

  const ClassSectionModel({
    required this.id,
    required this.className,
    required this.section,
    required this.classTeacher,
    required this.totalStudents,
    required this.capacity,
    required this.roomNo,
  });
}

class SubjectModel {
  final String id;
  final String code;
  final String name;
  final String department;
  final int weeklyPeriods;
  final String leadTeacher;

  const SubjectModel({
    required this.id,
    required this.code,
    required this.name,
    required this.department,
    required this.weeklyPeriods,
    required this.leadTeacher,
  });
}

class ExamModel {
  final String id;
  final String title;
  final String examType; // Mid Term, Final, Unit Test, Practical
  final String startDate;
  final String endDate;
  final String applicableClasses;
  final String status; // Upcoming, Ongoing, Completed, Results Published

  const ExamModel({
    required this.id,
    required this.title,
    required this.examType,
    required this.startDate,
    required this.endDate,
    required this.applicableClasses,
    required this.status,
  });
}

class TimetableSlot {
  final String period;
  final String time;
  final String subject;
  final String teacher;
  final String room;

  const TimetableSlot({
    required this.period,
    required this.time,
    required this.subject,
    required this.teacher,
    required this.room,
  });
}
