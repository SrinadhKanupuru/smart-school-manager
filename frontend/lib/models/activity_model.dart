import 'package:flutter/material.dart';

class ActivityItem {
  final String id;
  final String title;
  final String description;
  final String time;
  final IconData icon;
  final Color statusColor;

  const ActivityItem({
    required this.id,
    required this.title,
    required this.description,
    required this.time,
    required this.icon,
    required this.statusColor,
  });
}
