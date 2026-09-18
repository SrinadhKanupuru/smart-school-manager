import 'package:flutter/material.dart';
import '../../models/parent_portal_models.dart';
import '../../data/parent_mock_data.dart';

class ParentDataProvider with ChangeNotifier {
  late List<ChildStudent> _children;
  late ChildStudent _selectedChild;
  late List<ParentLeaveItem> _leaves;
  late List<ParentMessageItem> _messages;
  late List<ParentNotificationItem> _notifications;
  late Map<String, ChildFeeSummary> _feeSummaries;

  ParentDataProvider() {
    _children = List.from(ParentMockData.children);
    _selectedChild = _children.first;
    _leaves = List.from(ParentMockData.initialLeaves);
    _messages = List.from(ParentMockData.messages);
    _notifications = List.from(ParentMockData.notifications);
    _feeSummaries = {
      'STU1024': ParentMockData.getFeeSummary('STU1024'),
      'STU1089': ParentMockData.getFeeSummary('STU1089'),
    };
  }

  // Getters
  List<ChildStudent> get children => _children;
  ChildStudent get selectedChild => _selectedChild;
  List<ParentLeaveItem> get leaves => _leaves;
  List<ParentMessageItem> get messages => _messages;
  List<ParentNotificationItem> get notifications => _notifications;
  int get unreadNotificationsCount => _notifications.where((n) => !n.isRead).length;
  int get unreadMessagesCount => _messages.where((m) => m.isUnread).length;

  ChildFeeSummary get currentFeeSummary =>
      _feeSummaries[_selectedChild.id] ?? ParentMockData.getFeeSummary(_selectedChild.id);

  ChildAttendanceSummary get currentAttendance =>
      ParentMockData.getAttendanceForChild(_selectedChild.id);

  List<ChildHomework> get currentHomeworks =>
      ParentMockData.getHomeworkForChild(_selectedChild.id);

  List<ChildAssignment> get currentAssignments =>
      ParentMockData.getAssignmentsForChild(_selectedChild.id);

  List<ChildExam> get currentUpcomingExams =>
      ParentMockData.getUpcomingExams(_selectedChild.id);

  List<ChildResult> get currentResults =>
      ParentMockData.getPreviousResults(_selectedChild.id);

  List<ChildTimetableSlot> get currentTimetable =>
      ParentMockData.getTimetable(_selectedChild.id);

  List<ParentNoticeItem> get notices => ParentMockData.notices;

  // Actions
  void selectChild(ChildStudent child) {
    if (_selectedChild.id != child.id) {
      _selectedChild = child;
      notifyListeners();
    }
  }

  void selectChildById(String id) {
    final found = _children.firstWhere(
      (c) => c.id == id,
      orElse: () => _children.first,
    );
    selectChild(found);
  }

  void submitLeaveRequest({
    required String childId,
    required String childName,
    required String leaveType,
    required DateTime startDate,
    required DateTime endDate,
    required String reason,
  }) {
    final days = endDate.difference(startDate).inDays + 1;
    final newLeave = ParentLeaveItem(
      id: 'LV-${DateTime.now().millisecondsSinceEpoch % 10000}',
      childId: childId,
      childName: childName,
      leaveType: leaveType,
      startDate: startDate,
      endDate: endDate,
      daysCount: days > 0 ? days : 1,
      reason: reason,
      status: 'Pending',
      appliedDate: DateTime.now(),
      approverRemarks: 'Awaiting review from Class Teacher / Academic Coordinator',
    );

    _leaves.insert(0, newLeave);
    _notifications.insert(
      0,
      ParentNotificationItem(
        id: 'NOT-${DateTime.now().millisecondsSinceEpoch % 10000}',
        title: 'Leave Request Submitted',
        description: '$leaveType for $childName ($days day${days > 1 ? 's' : ''}) is under review.',
        timeAgo: 'Just now',
        icon: Icons.hourglass_top_rounded,
        iconColor: const Color(0xFFF59E0B),
        type: 'leave',
      ),
    );
    notifyListeners();
  }

  bool processFeePayment({
    required double amount,
    required String paymentMethod,
    required String description,
  }) {
    final currentSummary = currentFeeSummary;
    final newPaid = currentSummary.paidFees + amount;
    final newPending = (currentSummary.pendingFees - amount).clamp(0.0, currentSummary.totalFees);

    final newReceipt = FeePaymentReceipt(
      id: 'REC-${DateTime.now().millisecondsSinceEpoch % 10000}',
      receiptNo: 'REC-${DateTime.now().millisecondsSinceEpoch % 10000}',
      paymentDate: DateTime.now(),
      amount: amount,
      paymentMethod: paymentMethod,
      description: description,
      status: 'Paid',
    );

    final updatedReceipts = [newReceipt, ...currentSummary.receipts];

    // Update installments status if paid
    final updatedInstallments = currentSummary.installments.map((inst) {
      if (inst.status == 'Pending' && amount >= inst.amount) {
        return FeeInstallmentItem(
          title: inst.title,
          amount: inst.amount,
          dueDate: inst.dueDate,
          status: 'Paid',
        );
      }
      return inst;
    }).toList();

    _feeSummaries[_selectedChild.id] = ChildFeeSummary(
      childId: _selectedChild.id,
      totalFees: currentSummary.totalFees,
      paidFees: newPaid,
      pendingFees: newPending,
      overdueFees: currentSummary.overdueFees,
      nextDueDate: newPending == 0 ? 'All Cleared' : currentSummary.nextDueDate,
      installments: updatedInstallments,
      receipts: updatedReceipts,
    );

    _notifications.insert(
      0,
      ParentNotificationItem(
        id: 'NOT-${DateTime.now().millisecondsSinceEpoch % 10000}',
        title: 'Fee Payment Successful',
        description: 'Payment of ₹${amount.toStringAsFixed(0)} received. Receipt ${newReceipt.receiptNo} generated.',
        timeAgo: 'Just now',
        icon: Icons.check_circle_rounded,
        iconColor: const Color(0xFF10B981),
        type: 'fees',
      ),
    );

    notifyListeners();
    return true;
  }

  void markMessageAsRead(String messageId) {
    final index = _messages.indexWhere((m) => m.id == messageId);
    if (index != -1 && _messages[index].isUnread) {
      _messages[index] = _messages[index].copyWith(isUnread: false);
      notifyListeners();
    }
  }

  void sendReplyToMessage(String messageId, String replyText) {
    final index = _messages.indexWhere((m) => m.id == messageId);
    if (index != -1) {
      final updatedReplies = List<String>.from(_messages[index].replies)..add(replyText);
      _messages[index] = _messages[index].copyWith(
        replies: updatedReplies,
        isUnread: false,
      );
      notifyListeners();
    }
  }

  void markNotificationAsRead(String notificationId) {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      notifyListeners();
    }
  }

  void markAllNotificationsAsRead() {
    _notifications = _notifications.map((n) => n.copyWith(isRead: true)).toList();
    notifyListeners();
  }
}
