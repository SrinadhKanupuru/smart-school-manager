import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/admin_provider.dart';
import '../../core/theme.dart';

class NoticeView extends StatefulWidget {
  const NoticeView({super.key});

  @override
  State<NoticeView> createState() => _NoticeViewState();
}

class _NoticeViewState extends State<NoticeView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final admin = Provider.of<AdminProvider>(context, listen: false);
      admin.fetchNotices();
      admin.fetchReceivedMessages();
    });
  }

  @override
  Widget build(BuildContext context) {
    final admin = Provider.of<AdminProvider>(context);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Inbox & Announcements',
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
          ),
          bottom: TabBar(
            labelStyle: GoogleFonts.outfit(fontWeight: FontWeight.bold),
            unselectedLabelStyle: GoogleFonts.outfit(),
            tabs: const [
              Tab(text: 'School Notices', icon: Icon(Icons.campaign)),
              Tab(text: 'Personal Messages', icon: Icon(Icons.mail)),
            ],
          ),
        ),
        body: SafeArea(
          child: TabBarView(
            children: [
              // Tab 1: School Notices
              RefreshIndicator(
                onRefresh: () => admin.fetchNotices(),
                child: admin.isLoading && admin.notices.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : admin.notices.isEmpty
                        ? ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: [
                              SizedBox(height: MediaQuery.of(context).size.height * 0.3),
                              Center(
                                child: Text(
                                  'No announcements posted.',
                                  style: GoogleFonts.outfit(color: AppTheme.textSecondaryColor),
                                ),
                              ),
                            ],
                          )
                        : ListView.builder(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.all(16),
                            itemCount: admin.notices.length,
                            itemBuilder: (context, index) {
                              final notice = admin.notices[index];
                              return Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: BorderSide(color: Colors.grey.shade200),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      Row(
                                        children: [
                                          CircleAvatar(
                                            backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                                            child: const Icon(Icons.campaign, color: AppTheme.primaryColor),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              notice['title'] ?? '',
                                              style: GoogleFonts.outfit(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                                color: AppTheme.textPrimaryColor,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const Divider(height: 24),
                                      Text(
                                        notice['description'] ?? '',
                                        style: GoogleFonts.outfit(
                                          fontSize: 14,
                                          color: AppTheme.textSecondaryColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
              ),

              // Tab 2: Personal Messages
              RefreshIndicator(
                onRefresh: () => admin.fetchReceivedMessages(),
                child: admin.isLoading && admin.messages.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : admin.messages.isEmpty
                        ? ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: [
                              SizedBox(height: MediaQuery.of(context).size.height * 0.3),
                              Center(
                                child: Text(
                                  'No personal messages.',
                                  style: GoogleFonts.outfit(color: AppTheme.textSecondaryColor),
                                ),
                              ),
                            ],
                          )
                        : ListView.builder(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.all(16),
                            itemCount: admin.messages.length,
                            itemBuilder: (context, index) {
                              final msg = admin.messages[index];
                              final senderName = msg['sender']?['fullName'] ?? 'System';
                              final senderRole = msg['sender']?['role'] ?? 'Admin';
                              final isReminder = msg['type'] == 'REMINDER';

                              return Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: BorderSide(
                                    color: isReminder ? Colors.orange.shade300 : Colors.grey.shade200,
                                  ),
                                ),
                                color: isReminder ? Colors.orange.shade50.withOpacity(0.3) : Colors.white,
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      Row(
                                        children: [
                                          CircleAvatar(
                                            backgroundColor: isReminder
                                                ? Colors.orange.withOpacity(0.1)
                                                : AppTheme.primaryColor.withOpacity(0.1),
                                            child: Icon(
                                              isReminder ? Icons.notification_important : Icons.mail,
                                              color: isReminder ? Colors.orange.shade800 : AppTheme.primaryColor,
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
                                                        msg['title'] ?? '',
                                                        style: GoogleFonts.outfit(
                                                          fontWeight: FontWeight.bold,
                                                          fontSize: 16,
                                                          color: AppTheme.textPrimaryColor,
                                                        ),
                                                        maxLines: 1,
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 8),
                                                    if (isReminder)
                                                      Container(
                                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                                        decoration: BoxDecoration(
                                                          color: Colors.orange.shade100,
                                                          borderRadius: BorderRadius.circular(8),
                                                        ),
                                                        child: Text(
                                                          'DUE REMINDER',
                                                          style: GoogleFonts.outfit(
                                                            fontSize: 9,
                                                            fontWeight: FontWeight.bold,
                                                            color: Colors.orange.shade900,
                                                          ),
                                                        ),
                                                      ),
                                                  ],
                                                ),
                                                const SizedBox(height: 2),
                                                Text(
                                                  'From: $senderName ($senderRole)',
                                                  style: GoogleFonts.outfit(
                                                    fontSize: 12,
                                                    color: AppTheme.textSecondaryColor,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      const Divider(height: 24),
                                      Text(
                                        msg['content'] ?? '',
                                        style: GoogleFonts.outfit(
                                          fontSize: 14,
                                          color: AppTheme.textSecondaryColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
