import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../widgets/parent/parent_ui_components.dart';
import 'parent_data_provider.dart';
import '../../models/parent_portal_models.dart';

class ParentMessagesScreen extends StatefulWidget {
  const ParentMessagesScreen({super.key});

  @override
  State<ParentMessagesScreen> createState() => _ParentMessagesScreenState();
}

class _ParentMessagesScreenState extends State<ParentMessagesScreen> {
  String _searchQuery = '';
  String? _selectedMessageId;
  final TextEditingController _replyController = TextEditingController();

  @override
  void dispose() {
    _replyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final data = Provider.of<ParentDataProvider>(context);
    final messages = data.messages;
    final isDesktop = MediaQuery.of(context).size.width >= 900;

    final filtered = messages.where((m) {
      final query = _searchQuery.toLowerCase();
      return m.senderName.toLowerCase().contains(query) ||
          m.subject.toLowerCase().contains(query) ||
          m.message.toLowerCase().contains(query);
    }).toList();

    // Default select first message if on desktop and none selected
    if (_selectedMessageId == null && filtered.isNotEmpty) {
      _selectedMessageId = filtered.first.id;
    }

    final selectedMessage = filtered.firstWhere(
      (m) => m.id == _selectedMessageId,
      orElse: () => filtered.isNotEmpty ? filtered.first : messages.first,
    );

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
                        'Direct Communications',
                        style: GoogleFonts.inter(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: ParentDesignTokens.textPrimary,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Direct messaging channel with Class Teachers, Principal Office, and Administration',
                        style: GoogleFonts.inter(
                          fontSize: 13.5,
                          color: ParentDesignTokens.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                if (data.unreadMessagesCount > 0)
                  ParentBadge.warning(label: '${data.unreadMessagesCount} Unread Message(s)', icon: Icons.mail_rounded),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // 2-Pane Conversation View (Desktop) or List (Mobile)
          if (isDesktop)
            ParentAnimatedEntrance(
              index: 1,
              child: ParentCard(
                padding: EdgeInsets.zero,
                child: SizedBox(
                  height: 640,
                  child: Row(
                    children: [
                      // Left: Master Conversations List
                      SizedBox(
                        width: 340,
                        child: _buildConversationsList(filtered, data),
                      ),
                      const VerticalDivider(width: 1, color: ParentDesignTokens.border),
                      // Right: Active Conversation Detail & Thread
                      Expanded(
                        child: _buildConversationDetail(selectedMessage, data),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else ...[
            // Mobile: If a message is selected, show detail view with back button; else show list
            if (_selectedMessageId != null)
              ParentCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_rounded),
                          onPressed: () => setState(() => _selectedMessageId = null),
                        ),
                        Text('Back to Messages', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
                      ],
                    ),
                    const Divider(height: 1, color: ParentDesignTokens.border),
                    _buildConversationDetail(selectedMessage, data),
                  ],
                ),
              )
            else
              ParentCard(
                padding: EdgeInsets.zero,
                child: SizedBox(
                  height: 580,
                  child: _buildConversationsList(filtered, data),
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildConversationsList(List<ParentMessageItem> list, ParentDataProvider data) {
    return Column(
      children: [
        // Search header
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            onChanged: (val) => setState(() => _searchQuery = val),
            decoration: InputDecoration(
              hintText: 'Search communications...',
              hintStyle: GoogleFonts.inter(fontSize: 12.5, color: ParentDesignTokens.textMuted),
              prefixIcon: const Icon(Icons.search_rounded, size: 18, color: ParentDesignTokens.textMuted),
              fillColor: ParentDesignTokens.surfaceMuted,
              filled: true,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        const Divider(height: 1, color: ParentDesignTokens.border),
        Expanded(
          child: list.isEmpty
              ? const Center(
                  child: Text('No conversations found', style: TextStyle(color: ParentDesignTokens.textMuted)),
                )
              : ListView.separated(
                  itemCount: list.length,
                  separatorBuilder: (context, index) => const Divider(height: 1, color: ParentDesignTokens.borderSubtle),
                  itemBuilder: (context, index) {
                    final msg = list[index];
                    final isSelected = msg.id == _selectedMessageId;

                    return InkWell(
                      onTap: () {
                        setState(() => _selectedMessageId = msg.id);
                        if (msg.isUnread) {
                          data.markMessageAsRead(msg.id);
                        }
                      },
                      child: Container(
                        color: isSelected
                            ? ParentDesignTokens.brandTint
                            : (msg.isUnread ? const Color(0xFFFFFBEB) : Colors.transparent),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              radius: 18,
                              backgroundColor: isSelected ? ParentDesignTokens.brand : const Color(0xFFFEF3C7),
                              child: Text(
                                msg.avatarInitials,
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: isSelected ? Colors.white : const Color(0xFFB45309),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          msg.senderName,
                                          style: GoogleFonts.inter(
                                            fontSize: 13,
                                            fontWeight: msg.isUnread ? FontWeight.w800 : FontWeight.w600,
                                            color: ParentDesignTokens.textPrimary,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Text(
                                        '${msg.timestamp.day} Sep',
                                        style: GoogleFonts.inter(
                                          fontSize: 10.5,
                                          color: ParentDesignTokens.textMuted,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    msg.subject,
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: isSelected ? ParentDesignTokens.brand : ParentDesignTokens.textPrimary,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    msg.message,
                                    style: GoogleFonts.inter(
                                      fontSize: 11.5,
                                      color: ParentDesignTokens.textSecondary,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            if (msg.isUnread) ...[
                              const SizedBox(width: 6),
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: ParentDesignTokens.rose,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildConversationDetail(ParentMessageItem msg, ParentDataProvider data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Thread Top Bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: const Color(0xFFFEF3C7),
                child: Text(
                  msg.avatarInitials,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFFB45309),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      msg.senderName,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: ParentDesignTokens.textPrimary,
                      ),
                    ),
                    Text(
                      '${msg.senderRole} • Official Communication Channel',
                      style: GoogleFonts.inter(fontSize: 12, color: ParentDesignTokens.textSecondary),
                    ),
                  ],
                ),
              ),
              ParentBadge.info(label: 'Verified Faculty', icon: Icons.verified_user_rounded),
            ],
          ),
        ),
        const Divider(height: 1, color: ParentDesignTokens.border),

        // Message Thread Body
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Text(
                msg.subject,
                style: GoogleFonts.inter(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: ParentDesignTokens.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Received: ${msg.timestamp.day} September 2026 at 09:30 AM',
                style: GoogleFonts.inter(fontSize: 11.5, color: ParentDesignTokens.textMuted),
              ),
              const SizedBox(height: 16),
              // Incoming Message bubble
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: ParentDesignTokens.surfaceMuted,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: ParentDesignTokens.border),
                ),
                child: Text(
                  msg.message,
                  style: GoogleFonts.inter(
                    fontSize: 13.5,
                    color: ParentDesignTokens.textPrimary,
                    height: 1.5,
                  ),
                ),
              ),

              // Replies
              if (msg.replies.isNotEmpty) ...[
                const SizedBox(height: 20),
                ...msg.replies.map((replyText) {
                  return Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      constraints: const BoxConstraints(maxWidth: 420),
                      decoration: BoxDecoration(
                        color: ParentDesignTokens.brand,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.reply_rounded, size: 12, color: Colors.white70),
                              const SizedBox(width: 4),
                              Text(
                                'You (Parent):',
                                style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white70),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            replyText,
                            style: GoogleFonts.inter(fontSize: 13, color: Colors.white, height: 1.4),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ],
          ),
        ),

        const Divider(height: 1, color: ParentDesignTokens.border),

        // Reply Composer Box
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _replyController,
                  decoration: InputDecoration(
                    hintText: 'Type your reply to ${msg.senderName}...',
                    hintStyle: GoogleFonts.inter(fontSize: 13, color: ParentDesignTokens.textMuted),
                    fillColor: ParentDesignTokens.surfaceMuted,
                    filled: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: ParentDesignTokens.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: ParentDesignTokens.border),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ParentButton(
                label: 'Send Reply',
                icon: Icons.send_rounded,
                variant: ParentButtonVariant.primary,
                onPressed: () {
                  final text = _replyController.text.trim();
                  if (text.isNotEmpty) {
                    data.sendReplyToMessage(msg.id, text);
                    _replyController.clear();
                    setState(() {});
                  }
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
