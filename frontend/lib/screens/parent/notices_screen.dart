import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../widgets/parent/parent_ui_components.dart';
import 'parent_data_provider.dart';
import '../../models/parent_portal_models.dart';

class ParentNoticesScreen extends StatefulWidget {
  const ParentNoticesScreen({super.key});

  @override
  State<ParentNoticesScreen> createState() => _ParentNoticesScreenState();
}

class _ParentNoticesScreenState extends State<ParentNoticesScreen> {
  String _selectedCategory = 'All';
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final data = Provider.of<ParentDataProvider>(context);
    final allNotices = data.notices;

    final filtered = allNotices.where((n) {
      final matchesCategory = _selectedCategory == 'All' || n.category == _selectedCategory;
      final matchesSearch = n.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          n.shortDescription.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();

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
                        'Official Circulars & Notices',
                        style: GoogleFonts.inter(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: ParentDesignTokens.textPrimary,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Administrative circulars, event announcements, and calendar advisories',
                        style: GoogleFonts.inter(
                          fontSize: 13.5,
                          color: ParentDesignTokens.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                ParentBadge.info(label: '${allNotices.length} Published Notices', icon: Icons.campaign_rounded),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Search and Category Filter Bar
          ParentAnimatedEntrance(
            index: 1,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: (val) => setState(() => _searchQuery = val),
                    decoration: InputDecoration(
                      hintText: 'Search circulars by keyword or subject...',
                      hintStyle: GoogleFonts.inter(fontSize: 13, color: ParentDesignTokens.textMuted),
                      prefixIcon: const Icon(Icons.search_rounded, size: 18, color: ParentDesignTokens.textMuted),
                      fillColor: ParentDesignTokens.surface,
                      filled: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: ParentDesignTokens.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: ParentDesignTokens.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: ParentDesignTokens.brand, width: 1.5),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: ParentDesignTokens.surfaceMuted,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: ParentDesignTokens.border),
                  ),
                  child: Row(
                    children: ['All', 'Meeting', 'Academic', 'Event', 'Holiday'].map((cat) {
                      final isSelected = _selectedCategory == cat;
                      return InkWell(
                        onTap: () => setState(() => _selectedCategory = cat),
                        borderRadius: BorderRadius.circular(8),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.white : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: isSelected ? ParentDesignTokens.shadowSm : null,
                          ),
                          child: Text(
                            cat,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                              color: isSelected ? ParentDesignTokens.brand : ParentDesignTokens.textSecondary,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Notices List
          if (filtered.isEmpty)
            ParentAnimatedEntrance(
              index: 2,
              child: ParentEmptyState(
                icon: Icons.notifications_none_rounded,
                title: 'No notices found',
                description: 'No announcements matched your search or filter criteria.',
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filtered.length,
              separatorBuilder: (context, index) => const SizedBox(height: 14),
              itemBuilder: (context, index) {
                final notice = filtered[index];
                return ParentAnimatedEntrance(
                  index: index + 2,
                  child: _buildNoticeCard(context, notice),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildNoticeCard(BuildContext context, ParentNoticeItem n) {
    Color catFg;
    Color catBg;

    switch (n.category) {
      case 'Meeting':
        catFg = ParentDesignTokens.warmAccentDark;
        catBg = ParentDesignTokens.warmAccentLight;
        break;
      case 'Academic':
        catFg = ParentDesignTokens.brand;
        catBg = ParentDesignTokens.brandTint;
        break;
      case 'Event':
        catFg = ParentDesignTokens.emerald;
        catBg = ParentDesignTokens.emeraldLight;
        break;
      case 'Holiday':
      default:
        catFg = ParentDesignTokens.purple;
        catBg = ParentDesignTokens.purpleLight;
        break;
    }

    return ParentCard(
      padding: const EdgeInsets.all(22),
      onTap: () => _showNoticeModal(context, n),
      border: Border.all(
        color: n.isImportant ? const Color(0xFFFDE68A) : ParentDesignTokens.border,
        width: n.isImportant ? 1.5 : 1,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: catBg,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      n.category,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: catFg,
                      ),
                    ),
                  ),
                  if (n.isImportant) ...[
                    const SizedBox(width: 8),
                    ParentBadge.warning(label: 'Important Advisory', icon: Icons.priority_high_rounded),
                  ],
                ],
              ),
              Text(
                '${n.date.day} Sep 2026',
                style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: ParentDesignTokens.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            n.title,
            style: GoogleFonts.inter(
              fontSize: 16.5,
              fontWeight: FontWeight.w800,
              color: ParentDesignTokens.textPrimary,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            n.shortDescription,
            style: GoogleFonts.inter(fontSize: 13, color: ParentDesignTokens.textSecondary, height: 1.4),
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: ParentDesignTokens.borderSubtle),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Issued by: ${n.issuedBy}',
                style: GoogleFonts.inter(fontSize: 11.5, color: ParentDesignTokens.textMuted),
              ),
              Row(
                children: [
                  Text(
                    'Read Circular',
                    style: GoogleFonts.inter(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: ParentDesignTokens.brand,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.arrow_forward_rounded, size: 14, color: ParentDesignTokens.brand),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showNoticeModal(BuildContext context, ParentNoticeItem n) {
    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 580),
            child: Padding(
              padding: const EdgeInsets.all(26),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: ParentDesignTokens.brandTint,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          n.category.toUpperCase(),
                          style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w800, color: ParentDesignTokens.brand),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        icon: const Icon(Icons.close_rounded, size: 20),
                        tooltip: 'Close',
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    n.title,
                    style: GoogleFonts.inter(
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                      color: ParentDesignTokens.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Published on ${n.date.day} September 2026 • Issued by ${n.issuedBy}',
                    style: GoogleFonts.inter(fontSize: 12, color: ParentDesignTokens.textSecondary),
                  ),
                  const SizedBox(height: 16),
                  const Divider(height: 1, color: ParentDesignTokens.border),
                  const SizedBox(height: 16),
                  Text(
                    n.fullContent,
                    style: GoogleFonts.inter(
                      fontSize: 13.5,
                      color: ParentDesignTokens.textPrimary,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ParentButton(
                        label: 'Download Attachment',
                        icon: Icons.attach_file_rounded,
                        variant: ParentButtonVariant.secondary,
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Downloading circular document PDF...')),
                          );
                        },
                      ),
                      ParentButton(
                        label: 'Close',
                        variant: ParentButtonVariant.primary,
                        onPressed: () => Navigator.of(ctx).pop(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
