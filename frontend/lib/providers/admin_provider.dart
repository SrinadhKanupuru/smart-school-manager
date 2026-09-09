import 'dart:convert';
import 'package:flutter/material.dart';
import '../core/api_client.dart';
import '../core/constants.dart';

class AdminProvider extends ChangeNotifier {
  List<dynamic> _leaves = [];
  List<dynamic> _salaries = [];
  List<dynamic> _expenses = [];
  List<dynamic> _events = [];
  List<dynamic> _notices = [];
  List<dynamic> _routes = [];
  List<dynamic> _complaints = [];
  List<dynamic> _childrenDashboardData = [];
  List<dynamic> _messages = [];
  List<dynamic> _holidays = [];
  List<dynamic> _loans = [];
  List<dynamic> _leaveTypes = [];
  List<dynamic> _loanSkips = [];
  List<dynamic> _loanForeclosures = [];
  List<dynamic> _rectifications = [];
  List<dynamic> _salaryComponents = [];
  List<dynamic> _salaryTemplates = [];
  List<String> _salaryCategories = [];
  List<dynamic> _variablePays = [];
  bool _isLoading = false;

  List<dynamic> get leaves => _leaves;
  List<dynamic> get salaries => _salaries;
  List<dynamic> get expenses => _expenses;
  List<dynamic> get events => _events;
  List<dynamic> get notices => _notices;
  List<dynamic> get routes => _routes;
  List<dynamic> get complaints => _complaints;
  List<dynamic> get childrenDashboardData => _childrenDashboardData;
  List<dynamic> get messages => _messages;
  List<dynamic> get holidays => _holidays;
  List<dynamic> get loans => _loans;
  List<dynamic> get leaveTypes => _leaveTypes;
  List<dynamic> get loanSkips => _loanSkips;
  List<dynamic> get loanForeclosures => _loanForeclosures;
  List<dynamic> get rectifications => _rectifications;
  List<dynamic> get salaryComponents => _salaryComponents;
  List<dynamic> get salaryTemplates => _salaryTemplates;
  List<String> get salaryCategories => _salaryCategories;
  List<dynamic> get variablePays => _variablePays;
  bool get isLoading => _isLoading;

  Map<String, dynamic>? _myLeaveSummary;

  Map<String, dynamic>? get myLeaveSummary => _myLeaveSummary;

  // Leaves
  Future<void> fetchLeaves() async {
    try {
      final response = await ApiClient.instance.get(ApiConstants.leaves);
      if (response.statusCode == 200) {
        _leaves = jsonDecode(response.body);
        notifyListeners();
      }
    } catch (e) {
      print('Fetch leaves error: $e');
    }
  }

  Future<void> fetchMyLeaveSummary() async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await ApiClient.instance.get('/admin/leaves/my-summary');
      if (response.statusCode == 200) {
        _myLeaveSummary = jsonDecode(response.body);
      }
    } catch (e) {
      print('Fetch my leave summary error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> applyLeave({
    required String leaveType,
    String? leaveTypeId,
    required String fromDate,
    required String toDate,
    required String reason,
    String? attachmentUrl,
  }) async {
    try {
      final response = await ApiClient.instance.post(ApiConstants.leave, {
        'leaveType': leaveType,
        if (leaveTypeId != null) 'leaveTypeId': leaveTypeId,
        'fromDate': fromDate,
        'toDate': toDate,
        'reason': reason,
        'attachmentUrl': attachmentUrl,
      });
      if (response.statusCode == 201) {
        return null;
      }
      try {
        final body = jsonDecode(response.body);
        return body['error'] ?? 'Failed to file leave request';
      } catch (_) {
        return 'Failed to file leave request: Code ${response.statusCode}';
      }
    } catch (e) {
      print('Apply leave error: $e');
      return e.toString();
    }
  }

  Future<String?> withdrawLeave(String leaveId) async {
    try {
      final response = await ApiClient.instance.put('${ApiConstants.leaves}/$leaveId/withdraw', {});
      if (response.statusCode == 200) {
        await fetchLeaves();
        await fetchMyLeaveSummary();
        await fetchChildrenDashboard();
        return null;
      }
      try {
        final body = jsonDecode(response.body);
        return body['error'] ?? 'Failed to withdraw leave request';
      } catch (_) {
        return 'Failed to withdraw leave request: Code ${response.statusCode}';
      }
    } catch (e) {
      print('Withdraw leave error: $e');
      return e.toString();
    }
  }

  Future<bool> updateLeaveStatus(String leaveId, String status) async {
    try {
      final response = await ApiClient.instance.put('${ApiConstants.leaves}/$leaveId', {
        'status': status,
      });
      if (response.statusCode == 200) {
        await fetchLeaves();
        return true;
      }
      return false;
    } catch (e) {
      print('Update leave error: $e');
      return false;
    }
  }

  // Salaries
  Future<void> fetchSalaries() async {
    try {
      final response = await ApiClient.instance.get(ApiConstants.salaries);
      if (response.statusCode == 200) {
        _salaries = jsonDecode(response.body);
        notifyListeners();
      }
    } catch (e) {
      print('Fetch salaries error: $e');
    }
  }

  Future<bool> generateSalaries(String month, int year, {List<Map<String, dynamic>>? adjustments}) async {
    try {
      final response = await ApiClient.instance.post(ApiConstants.generateSalaries, {
        'month': month,
        'year': year,
        if (adjustments != null) 'adjustments': adjustments,
      });
      if (response.statusCode == 200) {
        await fetchSalaries();
        return true;
      }
      return false;
    } catch (e) {
      print('Generate salaries error: $e');
      return false;
    }
  }

  Future<bool> paySalary(String salaryRecordId) async {
    try {
      final response = await ApiClient.instance.put('${ApiConstants.paySalary}/$salaryRecordId', {});
      if (response.statusCode == 200) {
        await fetchSalaries();
        return true;
      }
      return false;
    } catch (e) {
      print('Pay salary error: $e');
      return false;
    }
  }

  Future<bool> updateSalaryRecord(
    String salaryRecordId, {
    double? bonus,
    double? allowances,
    double? loanDeduction,
    String? remarks,
  }) async {
    try {
      final response = await ApiClient.instance.put(
        '${ApiConstants.salaries}/$salaryRecordId',
        {
          if (bonus != null) 'bonus': bonus,
          if (allowances != null) 'allowances': allowances,
          if (loanDeduction != null) 'loanDeduction': loanDeduction,
          if (remarks != null) 'remarks': remarks,
        },
      );
      if (response.statusCode == 200) {
        await fetchSalaries();
        return true;
      }
      return false;
    } catch (e) {
      print('Update salary record error: $e');
      return false;
    }
  }

  // Salary Component & Template Management
  Future<void> fetchSalaryComponents() async {
    try {
      final response = await ApiClient.instance.get(ApiConstants.salaryComponents);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is Map) {
          _salaryCategories = List<String>.from(data['categories'] ?? []);
          _salaryComponents = data['components'] ?? [];
        } else {
          _salaryComponents = data;
        }
        notifyListeners();
      }
    } catch (e) {
      print('Fetch salary components error: $e');
    }
  }

  Future<bool> createSalaryComponent({
    required String name,
    required String category,
    bool isTaxable = true,
    bool isProrated = true,
  }) async {
    try {
      final response = await ApiClient.instance.post(ApiConstants.salaryComponents, {
        'name': name,
        'category': category,
        'isTaxable': isTaxable,
        'isProrated': isProrated,
      });
      if (response.statusCode == 201) {
        await fetchSalaryComponents();
        return true;
      }
      return false;
    } catch (e) {
      print('Create salary component error: $e');
      return false;
    }
  }

  Future<bool> deleteSalaryComponent(String id) async {
    try {
      final response = await ApiClient.instance.delete('${ApiConstants.salaryComponents}/$id');
      if (response.statusCode == 200) {
        await fetchSalaryComponents();
        return true;
      }
      return false;
    } catch (e) {
      print('Delete salary component error: $e');
      return false;
    }
  }

  Future<void> fetchSalaryTemplates() async {
    try {
      final response = await ApiClient.instance.get(ApiConstants.salaryTemplates);
      if (response.statusCode == 200) {
        _salaryTemplates = jsonDecode(response.body);
        notifyListeners();
      }
    } catch (e) {
      print('Fetch salary templates error: $e');
    }
  }

  Future<bool> createSalaryTemplate({
    required String name,
    String? description,
    required List<Map<String, dynamic>> components,
    double? overtimeMultiplier,
  }) async {
    try {
      final response = await ApiClient.instance.post(ApiConstants.salaryTemplates, {
        'name': name,
        if (description != null) 'description': description,
        'components': components,
        if (overtimeMultiplier != null) 'overtimeMultiplier': overtimeMultiplier,
      });
      if (response.statusCode == 201) {
        await fetchSalaryTemplates();
        return true;
      }
      return false;
    } catch (e) {
      print('Create salary template error: $e');
      return false;
    }
  }

  Future<bool> updateSalaryTemplate(
    String id, {
    String? name,
    String? description,
    List<Map<String, dynamic>>? components,
    double? overtimeMultiplier,
  }) async {
    try {
      final response = await ApiClient.instance.put('${ApiConstants.salaryTemplates}/$id', {
        if (name != null) 'name': name,
        if (description != null) 'description': description,
        if (components != null) 'components': components,
        if (overtimeMultiplier != null) 'overtimeMultiplier': overtimeMultiplier,
      });
      if (response.statusCode == 200) {
        await fetchSalaryTemplates();
        return true;
      }
      return false;
    } catch (e) {
      print('Update salary template error: $e');
      return false;
    }
  }

  Future<bool> deleteSalaryTemplate(String id) async {
    try {
      final response = await ApiClient.instance.delete('${ApiConstants.salaryTemplates}/$id');
      if (response.statusCode == 200) {
        await fetchSalaryTemplates();
        return true;
      }
      return false;
    } catch (e) {
      print('Delete salary template error: $e');
      return false;
    }
  }

  Future<bool> assignSalaryTemplate(String teacherId, String? salaryTemplateId) async {
    try {
      final response = await ApiClient.instance.put(
        '${ApiConstants.assignSalaryTemplate}/$teacherId/salary-template',
        {
          'salaryTemplateId': salaryTemplateId,
        },
      );
      if (response.statusCode == 200) {
        return true;
      }
      return false;
    } catch (e) {
      print('Assign salary template error: $e');
      return false;
    }
  }

  // Variable Pays
  Future<void> fetchVariablePays(String teacherId, {String? month, int? year}) async {
    try {
      final queryParams = StringBuffer('teacherId=$teacherId');
      if (month != null) queryParams.write('&month=$month');
      if (year != null) queryParams.write('&year=$year');

      final response = await ApiClient.instance.get('/school/variable-pay?${queryParams.toString()}');
      if (response.statusCode == 200) {
        _variablePays = jsonDecode(response.body);
        notifyListeners();
      }
    } catch (e) {
      print('Fetch variable pays error: $e');
    }
  }

  Future<bool> createVariablePay({
    required String teacherId,
    required String componentId,
    required String month,
    required int year,
    required double amount,
    String? remarks,
    bool isArrear = false,
  }) async {
    try {
      final response = await ApiClient.instance.post('/school/variable-pay', {
        'teacherId': teacherId,
        'componentId': componentId,
        'month': month,
        'year': year,
        'amount': amount,
        if (remarks != null) 'remarks': remarks,
        'isArrear': isArrear,
      });
      if (response.statusCode == 201) {
        await fetchVariablePays(teacherId, month: month, year: year);
        return true;
      }
      return false;
    } catch (e) {
      print('Create variable pay error: $e');
      return false;
    }
  }

  Future<bool> deleteVariablePay(String id, String teacherId, {String? month, int? year}) async {
    try {
      final response = await ApiClient.instance.delete('/school/variable-pay/$id');
      if (response.statusCode == 200) {
        await fetchVariablePays(teacherId, month: month, year: year);
        return true;
      }
      return false;
    } catch (e) {
      print('Delete variable pay error: $e');
      return false;
    }
  }

  // Bulk Status Advancement
  Future<bool> advanceSalaryStatus(List<String> ids, String nextStatus) async {
    try {
      final response = await ApiClient.instance.put('/admin/salaries/advance-status', {
        'ids': ids,
        'nextStatus': nextStatus,
      });
      if (response.statusCode == 200) {
        await fetchSalaries();
        return true;
      }
      return false;
    } catch (e) {
      print('Advance salary status error: $e');
      return false;
    }
  }

  // Expenses
  Future<void> fetchExpenses() async {
    try {
      final response = await ApiClient.instance.get(ApiConstants.expenses);
      if (response.statusCode == 200) {
        _expenses = jsonDecode(response.body);
        notifyListeners();
      }
    } catch (e) {
      print('Fetch expenses error: $e');
    }
  }

  Future<bool> addExpense({
    required String category,
    required double amount,
    required String description,
    String? date,
  }) async {
    try {
      final response = await ApiClient.instance.post(ApiConstants.expenses, {
        'category': category,
        'amount': amount,
        'description': description,
        'date': date,
      });
      if (response.statusCode == 201) {
        await fetchExpenses();
        return true;
      }
      return false;
    } catch (e) {
      print('Add expense error: $e');
      return false;
    }
  }

  // Events & Notices
  Future<void> fetchEvents() async {
    try {
      final response = await ApiClient.instance.get(ApiConstants.events);
      if (response.statusCode == 200) {
        _events = jsonDecode(response.body);
        notifyListeners();
      }
    } catch (e) {
      print('Fetch events error: $e');
    }
  }

  Future<bool> createEvent({
    required String title,
    required String description,
    required String date,
    required String type,
    String? targetAudience,
  }) async {
    try {
      final response = await ApiClient.instance.post(ApiConstants.events, {
        'title': title,
        'description': description,
        'date': date,
        'type': type,
        'targetAudience': targetAudience ?? 'ALL',
      });
      if (response.statusCode == 201) {
        await fetchEvents();
        return true;
      }
      return false;
    } catch (e) {
      print('Create event error: $e');
      return false;
    }
  }

  Future<bool> deleteEvent(String id) async {
    try {
      final response = await ApiClient.instance.delete('${ApiConstants.events}/$id');
      if (response.statusCode == 200) {
        await fetchEvents();
        return true;
      }
      return false;
    } catch (e) {
      print('Delete event error: $e');
      return false;
    }
  }

  Future<void> fetchNotices() async {
    try {
      final response = await ApiClient.instance.get(ApiConstants.notices);
      if (response.statusCode == 200) {
        _notices = jsonDecode(response.body);
        notifyListeners();
      }
    } catch (e) {
      print('Fetch notices error: $e');
    }
  }

  Future<bool> createNotice({
    required String title,
    required String description,
    String? attachmentUrl,
  }) async {
    try {
      final response = await ApiClient.instance.post(ApiConstants.notices, {
        'title': title,
        'description': description,
        'attachmentUrl': attachmentUrl,
      });
      if (response.statusCode == 201) {
        await fetchNotices();
        return true;
      }
      return false;
    } catch (e) {
      print('Create notice error: $e');
      return false;
    }
  }

  // Bus Routes
  Future<void> fetchBusRoutes() async {
    try {
      final response = await ApiClient.instance.get(ApiConstants.routes);
      if (response.statusCode == 200) {
        _routes = jsonDecode(response.body);
        notifyListeners();
      }
    } catch (e) {
      print('Fetch bus routes error: $e');
    }
  }

  Future<bool> createBusRoute({
    required String routeName,
    required String busNo,
    required String driverName,
    required String driverContact,
    required List<Map<String, dynamic>> stops,
    required List<String> studentIds,
  }) async {
    try {
      final response = await ApiClient.instance.post(ApiConstants.routes, {
        'routeName': routeName,
        'busNo': busNo,
        'driverName': driverName,
        'driverContact': driverContact,
        'stops': stops,
        'studentIds': studentIds,
      });
      if (response.statusCode == 201) {
        await fetchBusRoutes();
        return true;
      }
      return false;
    } catch (e) {
      print('Create bus route error: $e');
      return false;
    }
  }

  // Complaints
  Future<void> fetchComplaints() async {
    try {
      final response = await ApiClient.instance.get(ApiConstants.complaint);
      if (response.statusCode == 200) {
        _complaints = jsonDecode(response.body);
        notifyListeners();
      }
    } catch (e) {
      print('Fetch complaints error: $e');
    }
  }

  Future<bool> raiseComplaint({
    required String category,
    required String description,
  }) async {
    try {
      final response = await ApiClient.instance.post(ApiConstants.complaint, {
        'category': category,
        'description': description,
      });
      if (response.statusCode == 201) {
        await fetchComplaints();
        return true;
      }
      return false;
    } catch (e) {
      print('Raise complaint error: $e');
      return false;
    }
  }

  Future<bool> resolveComplaint(String complaintId) async {
    try {
      final response = await ApiClient.instance.put('${ApiConstants.complaint}/$complaintId/resolve', {});
      if (response.statusCode == 200) {
        await fetchComplaints();
        return true;
      }
      return false;
    } catch (e) {
      print('Resolve complaint error: $e');
      return false;
    }
  }

  // Parent dashboard child loader
  Future<void> fetchChildrenDashboard() async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await ApiClient.instance.get(ApiConstants.children);
      if (response.statusCode == 200) {
        _childrenDashboardData = jsonDecode(response.body);
      }
    } catch (e) {
      print('Fetch children dashboard error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> requestChildLeave({
    required String studentId,
    required String fromDate,
    required String toDate,
    required String reason,
    String? leaveType,
  }) async {
    try {
      final response = await ApiClient.instance.post(ApiConstants.childLeave, {
        'studentId': studentId,
        'fromDate': fromDate,
        'toDate': toDate,
        'reason': reason,
        if (leaveType != null) 'leaveType': leaveType,
      });
      if (response.statusCode == 201) {
        return null;
      }
      try {
        final body = jsonDecode(response.body);
        return body['error'] ?? 'Failed to submit child leave request';
      } catch (_) {
        return 'Failed to submit child leave request: Code ${response.statusCode}';
      }
    } catch (e) {
      print('Request child leave error: $e');
      return e.toString();
    }
  }

  Future<bool> payFeeSimulated(String feeRecordId) async {
    try {
      final response = await ApiClient.instance.post('${ApiConstants.payFee}/$feeRecordId', {});
      if (response.statusCode == 200) {
        await fetchChildrenDashboard();
        return true;
      }
      return false;
    } catch (e) {
      print('Pay fee error: $e');
      return false;
    }
  }

  Future<bool> createFeeRecord({
    required String studentId,
    required String category,
    required double amount,
    required String dueDate,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await ApiClient.instance.post('/admin/fees', {
        'studentId': studentId,
        'category': category,
        'amount': amount,
        'dueDate': dueDate,
      });
      return response.statusCode == 201;
    } catch (e) {
      print('Create fee record error: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateFeeRecord({
    required String feeRecordId,
    double? paidAmount,
    double? amount,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await ApiClient.instance.put('/admin/fees/$feeRecordId', {
        if (paidAmount != null) 'paidAmount': paidAmount,
        if (amount != null) 'amount': amount,
      });
      return response.statusCode == 200;
    } catch (e) {
      print('Update fee record error: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Messages / Reminders
  Future<void> fetchReceivedMessages() async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await ApiClient.instance.get('/parent/messages');
      if (response.statusCode == 200) {
        _messages = jsonDecode(response.body);
      }
    } catch (e) {
      print('Fetch received messages error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> sendMessageToParents({
    required String studentId,
    required String title,
    required String content,
    String? type,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await ApiClient.instance.post('/admin/messages', {
        'studentId': studentId,
        'title': title,
        'content': content,
        'type': type ?? 'GENERAL',
      });
      return response.statusCode == 201;
    } catch (e) {
      print('Send message to parents error: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // School Holidays & Weekoffs
  Future<void> fetchHolidays() async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await ApiClient.instance.get(ApiConstants.holidays);
      if (response.statusCode == 200) {
        _holidays = jsonDecode(response.body);
      }
    } catch (e) {
      print('Fetch holidays error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addHoliday({
    required String title,
    required String date,
    required String type,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await ApiClient.instance.post(ApiConstants.holidays, {
        'title': title,
        'date': date,
        'type': type,
      });
      if (response.statusCode == 201) {
        await fetchHolidays();
        return true;
      }
      return false;
    } catch (e) {
      print('Add holiday error: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteHoliday(String holidayId) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await ApiClient.instance.delete('${ApiConstants.holidays}/$holidayId');
      if (response.statusCode == 200) {
        await fetchHolidays();
        return true;
      }
      return false;
    } catch (e) {
      print('Delete holiday error: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Loans & Advances
  Future<void> fetchLoans() async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await ApiClient.instance.get(ApiConstants.loans);
      if (response.statusCode == 200) {
        _loans = jsonDecode(response.body);
      }
    } catch (e) {
      print('Fetch loans error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> applyLoan({
    required double amount,
    required int installments,
    required String reason,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await ApiClient.instance.post(ApiConstants.loans, {
        'amount': amount,
        'installments': installments,
        'reason': reason,
      });
      if (response.statusCode == 201) {
        await fetchLoans();
        return true;
      }
      return false;
    } catch (e) {
      print('Apply loan error: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateLoanStatus(String loanId, String status) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await ApiClient.instance.put('${ApiConstants.loans}/$loanId/status', {
        'status': status,
      });
      if (response.statusCode == 200) {
        await fetchLoans();
        return true;
      }
      return false;
    } catch (e) {
      print('Update loan status error: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Leave Types Configuration
  Future<void> fetchLeaveTypes() async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await ApiClient.instance.get(ApiConstants.leaveTypes);
      if (response.statusCode == 200) {
        _leaveTypes = jsonDecode(response.body);
      }
    } catch (e) {
      print('Fetch leave types error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createLeaveType({
    required String name,
    required String code,
    required bool isPaid,
    required bool isUnpaid,
    required int maxDays,
    required String period,
    int? maxDaysMid,
    int? maxDaysSenior,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await ApiClient.instance.post(ApiConstants.leaveTypes, {
        'name': name,
        'code': code,
        'isPaid': isPaid,
        'isUnpaid': isUnpaid,
        'maxDays': maxDays,
        'period': period,
        if (maxDaysMid != null) 'maxDaysMid': maxDaysMid,
        if (maxDaysSenior != null) 'maxDaysSenior': maxDaysSenior,
      });
      if (response.statusCode == 201) {
        await fetchLeaveTypes();
        return true;
      }
      return false;
    } catch (e) {
      print('Create leave type error: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateLeaveType(
    String id, {
    String? name,
    String? code,
    bool? isPaid,
    bool? isUnpaid,
    int? maxDays,
    String? period,
    int? maxDaysMid,
    int? maxDaysSenior,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await ApiClient.instance.put('${ApiConstants.leaveTypes}/$id', {
        if (name != null) 'name': name,
        if (code != null) 'code': code,
        if (isPaid != null) 'isPaid': isPaid,
        if (isUnpaid != null) 'isUnpaid': isUnpaid,
        if (maxDays != null) 'maxDays': maxDays,
        if (period != null) 'period': period,
        'maxDaysMid': maxDaysMid,
        'maxDaysSenior': maxDaysSenior,
      });
      if (response.statusCode == 200) {
        await fetchLeaveTypes();
        return true;
      }
      return false;
    } catch (e) {
      print('Update leave type error: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteLeaveType(String id) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await ApiClient.instance.delete('${ApiConstants.leaveTypes}/$id');
      if (response.statusCode == 200) {
        await fetchLeaveTypes();
        return true;
      }
      return false;
    } catch (e) {
      print('Delete leave type error: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Loan Skip Requests
  Future<void> fetchLoanSkips() async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await ApiClient.instance.get(ApiConstants.loanSkips);
      if (response.statusCode == 200) {
        _loanSkips = jsonDecode(response.body);
      }
    } catch (e) {
      print('Fetch loan skips error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> applyLoanSkip({
    required String loanId,
    required int fromMonth,
    required int fromYear,
    required int toMonth,
    required int toYear,
    String? reason,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await ApiClient.instance.post(ApiConstants.loanSkips, {
        'loanId': loanId,
        'fromMonth': fromMonth,
        'fromYear': fromYear,
        'toMonth': toMonth,
        'toYear': toYear,
        'reason': reason,
      });
      if (response.statusCode == 201) {
        await fetchLoanSkips();
        await fetchLoans(); // Refresh loan list to reflect pause request/state
        return true;
      }
      return false;
    } catch (e) {
      print('Apply loan skip error: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> approveLoanSkip(String id, {String? approvalComment}) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await ApiClient.instance.put('${ApiConstants.loanSkips}/$id/approve', {
        if (approvalComment != null) 'approvalComment': approvalComment,
      });
      if (response.statusCode == 200) {
        await fetchLoanSkips();
        await fetchLoans();
        return true;
      }
      return false;
    } catch (e) {
      print('Approve loan skip error: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> rejectLoanSkip(String id, {required String rejectionReason}) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await ApiClient.instance.put('${ApiConstants.loanSkips}/$id/reject', {
        'rejectionReason': rejectionReason,
      });
      if (response.statusCode == 200) {
        await fetchLoanSkips();
        await fetchLoans();
        return true;
      }
      return false;
    } catch (e) {
      print('Reject loan skip error: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> cancelLoanSkip(String id) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await ApiClient.instance.put('${ApiConstants.loanSkips}/$id/cancel', {});
      if (response.statusCode == 200) {
        await fetchLoanSkips();
        await fetchLoans();
        return true;
      }
      return false;
    } catch (e) {
      print('Cancel loan skip error: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Loan Foreclosures
  Future<void> fetchLoanForeclosures() async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await ApiClient.instance.get(ApiConstants.loanForeclosures);
      if (response.statusCode == 200) {
        _loanForeclosures = jsonDecode(response.body);
      }
    } catch (e) {
      print('Fetch loan foreclosures error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> initiateLoanForeclosure({
    required String loanId,
    double? processingFee,
    required String deductionMethod,
    String? salaryDeductionMonth,
    int? salaryDeductionYear,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await ApiClient.instance.post(ApiConstants.loanForeclosures, {
        'loanId': loanId,
        'processingFee': processingFee ?? 0.0,
        'deductionMethod': deductionMethod,
        if (salaryDeductionMonth != null) 'salaryDeductionMonth': salaryDeductionMonth,
        if (salaryDeductionYear != null) 'salaryDeductionYear': salaryDeductionYear,
      });
      if (response.statusCode == 201) {
        await fetchLoanForeclosures();
        await fetchLoans();
        return true;
      }
      return false;
    } catch (e) {
      print('Initiate loan foreclosure error: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> approveLoanForeclosure(String id) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await ApiClient.instance.put('${ApiConstants.loanForeclosures}/$id/approve', {});
      if (response.statusCode == 200) {
        await fetchLoanForeclosures();
        await fetchLoans();
        return true;
      }
      return false;
    } catch (e) {
      print('Approve loan foreclosure error: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> rejectLoanForeclosure(String id) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await ApiClient.instance.put('${ApiConstants.loanForeclosures}/$id/reject', {});
      if (response.statusCode == 200) {
        await fetchLoanForeclosures();
        await fetchLoans();
        return true;
      }
      return false;
    } catch (e) {
      print('Reject loan foreclosure error: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> settleManualLoanForeclosure(
    String id, {
    String? referenceId,
    String? remarks,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await ApiClient.instance.put('${ApiConstants.loanForeclosures}/$id/settle', {
        if (referenceId != null) 'referenceId': referenceId,
        if (remarks != null) 'remarks': remarks,
      });
      if (response.statusCode == 200) {
        await fetchLoanForeclosures();
        await fetchLoans();
        return true;
      }
      return false;
    } catch (e) {
      print('Settle manual foreclosure error: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> sendBulkFeeReminders() async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await ApiClient.instance.post('/admin/messages/bulk-fee-reminders', {});
      final data = jsonDecode(response.body);
      return {
        'success': response.statusCode == 200,
        'message': data['message'] ?? 'Fee reminders sent.',
        'count': data['count'] ?? 0,
      };
    } catch (e) {
      print('Send bulk fee reminders error: $e');
      return {
        'success': false,
        'message': 'Failed to send bulk reminders.',
        'count': 0,
      };
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchRectifications() async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await ApiClient.instance.get(ApiConstants.rectifications);
      if (response.statusCode == 200) {
        _rectifications = jsonDecode(response.body);
      }
    } catch (e) {
      print('Fetch rectifications error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> applyRectification({
    required String date,
    required String checkInTime,
    required String checkOutTime,
    required String reason,
  }) async {
    try {
      final response = await ApiClient.instance.post(ApiConstants.rectifications, {
        'date': date,
        'checkInTime': checkInTime,
        'checkOutTime': checkOutTime,
        'reason': reason,
      });
      if (response.statusCode == 201) {
        return null;
      }
      try {
        final body = jsonDecode(response.body);
        return body['error'] ?? 'Failed to submit rectification request';
      } catch (_) {
        return 'Failed to submit rectification request: Code ${response.statusCode}';
      }
    } catch (e) {
      print('Apply rectification error: $e');
      return e.toString();
    }
  }

  Future<bool> updateRectificationStatus(String id, String status, {String? rejectionReason}) async {
    try {
      final response = await ApiClient.instance.put('${ApiConstants.rectifications}/$id', {
        'status': status,
        if (rejectionReason != null) 'rejectionReason': rejectionReason,
      });
      if (response.statusCode == 200) {
        await fetchRectifications();
        return true;
      }
      return false;
    } catch (e) {
      print('Update rectification status error: $e');
      return false;
    }
  }
}
