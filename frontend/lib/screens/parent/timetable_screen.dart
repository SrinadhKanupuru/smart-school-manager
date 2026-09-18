import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../widgets/parent/parent_ui_components.dart';
import 'parent_data_provider.dart';
import '../../models/parent_portal_models.dart';

class ParentTimetableScreen extends StatefulWidget {
  const ParentTimetableScreen({super.key});

  @override
  State<ParentTimetableScreen> createState() => _ParentTimetableScreenState();
}

class _ParentTimetableScreenState extends State<ParentTimetableScreen> {
  String _selectedDay = 'Monday';
  bool _isWeeklyGrid = true;
  final List<String> _days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];

  @override
  Widget build(BuildContext context) {
    final data = Provider.of<ParentDataProvider>(context);
    final child = data.selectedChild;
    final allSlots = data.currentTimetable;
    final isDesktop = MediaQuery.of(context).size.width >= 1024;

    final effectiveWeeklyView = isDesktop && _isWeeklyGrid;

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
                        'Class Schedule & Timetable',
                        style: GoogleFonts.inter(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: ParentDesignTokens.textPrimary,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Weekly periods, faculty sessions, and lab timings for ${child.name} (${child.grade} - ${child.section})',
                        style: GoogleFonts.inter(
                          fontSize: 13.5,
                          color: ParentDesignTokens.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                if (isDesktop)
                  Container(
                    decoration: BoxDecoration(
                      color: ParentDesignTokens.surfaceMuted,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: ParentDesignTokens.border),
                    ),
                    padding: const EdgeInsets.all(3),
                    child: Row(
                      children: [
                        _buildViewToggle(
                          label: 'Weekly Grid',
                          icon: Icons.grid_view_rounded,
                          isSelected: _isWeeklyGrid,
                          onTap: () => setState(() => _isWeeklyGrid = true),
                        ),
                        _buildViewToggle(
                          label: 'Daily View',
                          icon: Icons.view_day_rounded,
                          isSelected: !_isWeeklyGrid,
                          onTap: () => setState(() => _isWeeklyGrid = false),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Weekly Grid View or Daily Tab View
          if (effectiveWeeklyView)
            ParentAnimatedEntrance(
              index: 1,
              child: _buildWeeklyGrid(allSlots, child),
            )
          else ...[
            // Day selector tabs
            ParentAnimatedEntrance(
              index: 1,
              child: Container(
                decoration: BoxDecoration(
                  color: ParentDesignTokens.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: ParentDesignTokens.border),
                  boxShadow: ParentDesignTokens.shadowSm,
                ),
                padding: const EdgeInsets.all(6),
                child: Row(
                  children: _days.map((day) {
                    final isSelected = _selectedDay == day;

                    return Expanded(
                      child: InkWell(
                        onTap: () => setState(() => _selectedDay = day),
                        borderRadius: BorderRadius.circular(10),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected ? ParentDesignTokens.brand : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Text(
                              day,
                              style: GoogleFonts.inter(
                                fontSize: 12.5,
                                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                color: isSelected ? Colors.white : ParentDesignTokens.textSecondary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Day periods list
            ParentAnimatedEntrance(
              index: 2,
              child: _buildDailyScheduleCard(allSlots, child),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildViewToggle({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: isSelected ? ParentDesignTokens.shadowSm : null,
        ),
        child: Row(
          children: [
            Icon(icon, size: 14, color: isSelected ? ParentDesignTokens.brand : ParentDesignTokens.textSecondary),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? ParentDesignTokens.brand : ParentDesignTokens.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyGrid(List<ChildTimetableSlot> slots, ChildStudent child) {
    return ParentCard(
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Weekly Master Schedule (${child.grade} - ${child.section})',
                style: GoogleFonts.inter(
                  fontSize: 16.5,
                  fontWeight: FontWeight.w800,
                  color: ParentDesignTokens.textPrimary,
                ),
              ),
              ParentBadge.info(label: 'Room 201 • Main Academic Wing', icon: Icons.room_rounded),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: _days.map((day) {
              final daySlots = slots.where((s) => s.day == day).toList();

              return Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: ParentDesignTokens.surfaceMuted,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: ParentDesignTokens.border),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(12),
                            topRight: Radius.circular(12),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            day,
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: ParentDesignTokens.textPrimary,
                            ),
                          ),
                        ),
                      ),
                      const Divider(height: 1, color: ParentDesignTokens.border),
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          children: daySlots.map((slot) {
                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: slot.color.withValues(alpha: 0.25)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: slot.color.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      slot.subject,
                                      style: GoogleFonts.inter(
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.w800,
                                        color: slot.color,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    slot.teacher,
                                    style: GoogleFonts.inter(fontSize: 10.5, color: ParentDesignTokens.textSecondary),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    slot.time,
                                    style: GoogleFonts.inter(fontSize: 9.5, fontWeight: FontWeight.w600, color: ParentDesignTokens.textMuted),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyScheduleCard(List<ChildTimetableSlot> slots, ChildStudent child) {
    final daySlots = slots.where((s) => s.day == _selectedDay).toList();

    return ParentCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$_selectedDay Schedule (${daySlots.length} Periods)',
                  style: GoogleFonts.inter(
                    fontSize: 16.5,
                    fontWeight: FontWeight.w800,
                    color: ParentDesignTokens.textPrimary,
                  ),
                ),
                Text(
                  'Class Teacher: ${child.classTeacher}',
                  style: GoogleFonts.inter(fontSize: 12, color: ParentDesignTokens.textSecondary),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: ParentDesignTokens.border),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: daySlots.length,
            separatorBuilder: (context, index) => const Divider(height: 1, color: ParentDesignTokens.borderSubtle),
            itemBuilder: (context, index) {
              final slot = daySlots[index];

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: slot.color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Period ${index + 1}',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: slot.color,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 2,
                      child: Text(
                        slot.time,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: ParentDesignTokens.textPrimary,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            slot.subject,
                            style: GoogleFonts.inter(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w800,
                              color: ParentDesignTokens.textPrimary,
                            ),
                          ),
                          Text(
                            slot.teacher,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: ParentDesignTokens.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: ParentDesignTokens.surfaceMuted,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: ParentDesignTokens.border),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.room_outlined, size: 12, color: ParentDesignTokens.textMuted),
                          const SizedBox(width: 4),
                          Text(
                            slot.room,
                            style: GoogleFonts.inter(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: ParentDesignTokens.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
