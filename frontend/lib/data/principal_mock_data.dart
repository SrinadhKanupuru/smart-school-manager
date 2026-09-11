import 'package:flutter/material.dart';

class PrincipalMockData {
  // Principal Profile Details
  static const String principalName = 'Dr. Rajeshwari Raman';
  static const String principalTitle = 'Principal & Academic Director';
  static const String schoolName = 'Smart School International (Main City Campus)';
  static const String principalEmail = 'principal.main@smartschool.edu';

  // Academic Performance By Class
  static final List<Map<String, dynamic>> classPerformance = [
    {'class': 'Grade 6', 'avgScore': 81.2, 'passRate': 96.0, 'color': const Color(0xFF3B82F6)},
    {'class': 'Grade 7', 'avgScore': 83.5, 'passRate': 97.5, 'color': const Color(0xFF0EA5E9)},
    {'class': 'Grade 8', 'avgScore': 85.0, 'passRate': 98.0, 'color': const Color(0xFF10B981)},
    {'class': 'Grade 9', 'avgScore': 82.4, 'passRate': 95.2, 'color': const Color(0xFFF59E0B)},
    {'class': 'Grade 10', 'avgScore': 89.8, 'passRate': 99.4, 'color': const Color(0xFF8B5CF6)},
    {'class': 'Grade 11', 'avgScore': 84.1, 'passRate': 96.8, 'color': const Color(0xFFEC4899)},
    {'class': 'Grade 12', 'avgScore': 88.5, 'passRate': 99.1, 'color': const Color(0xFF1E40AF)},
  ];

  // School Circulars & Notices (Principal's desk)
  static final List<Map<String, dynamic>> principalNotices = [
    {
      'id': 'NTC-501',
      'title': 'Mid-Term Summative Assessment Guidelines',
      'audience': 'All Faculty & Exam Supervisors',
      'date': '11 Sep 2026',
      'priority': 'High',
      'status': 'Published',
      'content': 'Question paper submission deadline is 13th September. Exam invigilation rosters are posted on the notice board.',
    },
    {
      'id': 'NTC-502',
      'title': 'Annual Science & Tech Exhibition Planning',
      'audience': 'Science & Computer Dept Heads',
      'date': '10 Sep 2026',
      'priority': 'Medium',
      'status': 'Published',
      'content': 'Project registrations for students from Grade 6 to 12 open till 16th September. Auditorium layout allocated.',
    },
    {
      'id': 'NTC-503',
      'title': 'Faculty Development Workshop on AI in Education',
      'audience': 'All Teaching Staff',
      'date': '08 Sep 2026',
      'priority': 'Normal',
      'status': 'Draft',
      'content': 'Mandatory session scheduled for Saturday 26th September at 02:00 PM in the AV Conference Hall.',
    },
  ];
}
