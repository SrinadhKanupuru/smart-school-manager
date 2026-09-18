import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../widgets/parent/parent_ui_components.dart';
import 'parent_data_provider.dart';
import 'parent_navigation_provider.dart';
import '../../models/parent_portal_models.dart';

class ParentChildrenScreen extends StatelessWidget {
  const ParentChildrenScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final data = Provider.of<ParentDataProvider>(context);
    final nav = Provider.of<ParentNavigationProvider>(context, listen: false);
    final children = data.children;
    final selected = data.selectedChild;
    final isDesktop = MediaQuery.of(context).size.width >= 960;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          ParentAnimatedEntrance(
            index: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Enrolled Children Profiles',
                        style: GoogleFonts.inter(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: ParentDesignTokens.textPrimary,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Academic profiles and institution registrations linked to your parent account',
                        style: GoogleFonts.inter(
                          fontSize: 13.5,
                          color: ParentDesignTokens.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                ParentBadge.info(label: '${children.length} Enrolled Students', icon: Icons.family_restroom_rounded),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Children Cards
          isDesktop
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: children.map((child) {
                    final isSelected = child.id == selected.id;
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: _buildChildProfileCard(context, child, isSelected, data, nav),
                      ),
                    );
                  }).toList(),
                )
              : Column(
                  children: children.map((child) {
                    final isSelected = child.id == selected.id;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: _buildChildProfileCard(context, child, isSelected, data, nav),
                    );
                  }).toList(),
                ),
        ],
      ),
    );
  }

  Widget _buildChildProfileCard(
    BuildContext context,
    ChildStudent child,
    bool isSelected,
    ParentDataProvider data,
    ParentNavigationProvider nav,
  ) {
    return ParentCard(
      padding: const EdgeInsets.all(24),
      border: Border.all(
        color: isSelected ? ParentDesignTokens.brand : ParentDesignTokens.border,
        width: isSelected ? 2 : 1,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: isSelected ? ParentDesignTokens.brand : const Color(0xFFFEF3C7),
                    child: Text(
                      child.name.substring(0, 1),
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: isSelected ? Colors.white : const Color(0xFFB45309),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        child.name,
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: ParentDesignTokens.textPrimary,
                        ),
                      ),
                      Text(
                        'Grade ${child.grade} • Section ${child.section}',
                        style: GoogleFonts.inter(fontSize: 13, color: ParentDesignTokens.textSecondary),
                      ),
                    ],
                  ),
                ],
              ),
              if (isSelected)
                ParentBadge.info(label: 'Active Context', icon: Icons.check_circle_rounded)
              else
                ParentButton(
                  label: 'Switch to Child',
                  variant: ParentButtonVariant.outline,
                  fontSize: 12,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  onPressed: () => data.selectChild(child),
                ),
            ],
          ),

          const SizedBox(height: 20),
          const Divider(height: 1, color: ParentDesignTokens.borderSubtle),
          const SizedBox(height: 18),

          // Key Metrics Row
          Row(
            children: [
              Expanded(
                child: _buildMetricTile(
                  label: 'Attendance',
                  value: '${child.attendanceRate}%',
                  color: ParentDesignTokens.emerald,
                  bg: ParentDesignTokens.emeraldLight,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildMetricTile(
                  label: 'Academic Avg',
                  value: '${child.academicAverage}%',
                  color: ParentDesignTokens.brand,
                  bg: ParentDesignTokens.brandTint,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildMetricTile(
                  label: 'Student ID',
                  value: child.rollNo,
                  color: ParentDesignTokens.warmAccentDark,
                  bg: ParentDesignTokens.warmAccentLight,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Info Table
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: ParentDesignTokens.surfaceMuted,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: ParentDesignTokens.border),
            ),
            child: Column(
              children: [
                _buildInfoRow('Official Student ID', child.id),
                const Divider(height: 16, color: ParentDesignTokens.borderSubtle),
                _buildInfoRow('Class Teacher', child.classTeacher),
                const Divider(height: 16, color: ParentDesignTokens.borderSubtle),
                _buildInfoRow('Bus Route Allocation', child.busRoute),
                const Divider(height: 16, color: ParentDesignTokens.borderSubtle),
                _buildInfoRow('Blood Group', child.bloodGroup),
                const Divider(height: 16, color: ParentDesignTokens.borderSubtle),
                _buildInfoRow('Emergency Phone', child.emergencyContact),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Quick Action Buttons
          Row(
            children: [
              Expanded(
                child: ParentButton(
                  label: 'View Attendance',
                  icon: Icons.fact_check_rounded,
                  variant: ParentButtonVariant.secondary,
                  onPressed: () {
                    data.selectChild(child);
                    nav.setModule(ParentModule.attendance);
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ParentButton(
                  label: 'View Results',
                  icon: Icons.emoji_events_rounded,
                  variant: ParentButtonVariant.primary,
                  onPressed: () {
                    data.selectChild(child);
                    nav.setModule(ParentModule.exams);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricTile({
    required String label,
    required String value,
    required Color color,
    required Color bg,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: GoogleFonts.inter(fontSize: 10.5, fontWeight: FontWeight.w700, color: color)),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w800, color: ParentDesignTokens.textPrimary),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.inter(fontSize: 12.5, color: ParentDesignTokens.textSecondary)),
        Text(value, style: GoogleFonts.inter(fontSize: 12.5, fontWeight: FontWeight.w700, color: ParentDesignTokens.textPrimary)),
      ],
    );
  }
}
