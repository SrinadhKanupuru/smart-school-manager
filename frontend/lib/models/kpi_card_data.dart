import 'package:flutter/material.dart';

class KpiCardData {
  final String title;
  final String value;
  final String changePercentage;
  final bool isPositive;
  final String comparisonPeriod;
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final List<double> sparklineData;

  const KpiCardData({
    required this.title,
    required this.value,
    required this.changePercentage,
    required this.isPositive,
    required this.comparisonPeriod,
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    required this.sparklineData,
  });
}
