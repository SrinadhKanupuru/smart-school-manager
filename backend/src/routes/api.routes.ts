import { Router } from "express";
import multer from "multer";
import { authenticateToken, requireRoles } from "../middlewares/auth";
import { registerSchool, login, getCurrentUser } from "../controllers/auth.controller";
import { registerStaffController, verifyAttendanceController, getStaffAttendanceHistoryController } from "../controllers/face.controller";
import { addUser, getSchools, getUsersByRole, addParentAndAssignStudents, updateSchool, deleteSchool, createSchool, quickAddTeacher, getTeachersList } from "../controllers/school.controller";
import {
  getClassesAndSections,
  markAttendance,
  getAttendanceHistory,
  uploadHomework,
  getHomework,
  addDiary,
  getDiary,
  enterMarks,
  getExamMarks,
  getTimetable,
  updateTimetable,
  updateTimetableSlot,
  deleteTimetableSlot,
  addStudent,
  getStudents,
  uploadResource,
  getResources,
  fileUploadMiddleware,
  uploadFileController,
  createClass,
  createClassSection,
  assignStudentsToClassSection,
  assignClassTeacher
} from "../controllers/academic.controller";
import {
  applyLeave,
  getLeaves,
  getMyLeaveSummary,
  updateLeaveStatus,
  withdrawLeave,
  applyRectification,
  getRectifications,
  updateRectificationStatus,
  getSalaryRecords,
  generateSalaries,
  paySalary,
  updateSalaryRecord,
  advanceSalaryStatus,
  printPayslip,
  getExpenses,
  addExpense,
  getEvents,
  createEvent,
  deleteEvent,
  getNotices,
  createNotice,
  createFeeRecord,
  updateFeeRecord,
  sendMessageToParents,
  getReceivedMessages,
  sendBulkFeeReminders
} from "../controllers/administrative.controller";
import { getBusRoutes, createOrUpdateRoute, updateBusLocation } from "../controllers/transport.controller";
import { raiseComplaint, getComplaints, resolveComplaint } from "../controllers/complaint.controller";
import { getChildrenDashboard, requestChildLeave, payFeeSimulated } from "../controllers/parent.controller";
import { createHoliday, getHolidays, deleteHoliday } from "../controllers/holiday.controller";
import { requestLoan, getLoans, updateLoanStatus } from "../controllers/loan.controller";
import { createLeaveType, getLeaveTypes, updateLeaveType, deleteLeaveType } from "../controllers/leaveType.controller";
import { createSkipRequest, approveSkipRequest, rejectSkipRequest, cancelSkipRequest, getSkipRequests } from "../controllers/loanSkipRequest.controller";
import { initiateForeclosure, approveForeclosure, rejectForeclosure, settleManualForeclosure, getForeclosures } from "../controllers/loanForeclosure.controller";
import {
  getSalaryComponents,
  createSalaryComponent,
  deleteSalaryComponent,
  getSalaryTemplates,
  createSalaryTemplate,
  updateSalaryTemplate,
  deleteSalaryTemplate,
  assignSalaryTemplate,
  getVariablePays,
  createVariablePay,
  deleteVariablePay
} from "../controllers/salaryTemplate.controller";
import {
  getLeaves as getLeavesV2,
  getLeaveById,
  applyLeave as applyLeaveV2,
  updateLeave as updateLeaveV2,
  deleteLeave as deleteLeaveV2,
  approveLeave as approveLeaveV2,
  rejectLeave as rejectLeaveV2,
  getAttendanceRectifications as getAttendanceRectificationsV2,
  approveAttendanceRectification as approveAttendanceRectificationV2,
  rejectAttendanceRectification as rejectAttendanceRectificationV2,
  getLeaveBalances as getLeaveBalancesV2,
  adjustLeaveBalance,
  getLeavePolicies as getLeavePoliciesV2,
  createLeavePolicy as createLeavePolicyV2,
  updateLeavePolicy as updateLeavePolicyV2,
  deleteLeavePolicy as deleteLeavePolicyV2,
  getLeaveStatistics,
  getEmployeeLeaveHistory,
  getAuditLogs
} from "../controllers/leave.controller";

const router = Router();
const memoryUpload = multer({ storage: multer.memoryStorage() });

// Authentication
router.post("/auth/register", registerSchool);
router.post("/auth/login", login);
router.get("/auth/me", authenticateToken, getCurrentUser);

// User and school onboarding
router.post("/school/users", authenticateToken, requireRoles(["CORRESPONDENT", "PRINCIPAL", "HM"]), addUser);
router.post("/school/parents", authenticateToken, requireRoles(["CORRESPONDENT", "PRINCIPAL", "HM"]), addParentAndAssignStudents);
router.post("/school/register-staff-with-face", authenticateToken, memoryUpload.single("file"), registerStaffController);
router.post("/school/verify-attendance", authenticateToken, memoryUpload.single("file"), verifyAttendanceController);
router.get("/school/my-attendance", authenticateToken, getStaffAttendanceHistoryController);
router.get("/school/schools", getSchools);
router.post("/school/schools", authenticateToken, requireRoles(["CORRESPONDENT"]), createSchool);
router.put("/school/schools/:schoolId", authenticateToken, requireRoles(["CORRESPONDENT"]), updateSchool);
router.delete("/school/schools/:schoolId", authenticateToken, requireRoles(["CORRESPONDENT"]), deleteSchool);
router.post("/school/quick-teacher", quickAddTeacher);
router.get("/school/teachers", getTeachersList);
router.post("/teachers", quickAddTeacher);
router.get("/teachers", getTeachersList);
router.get("/school/users-by-role", authenticateToken, getUsersByRole);

// Salary Component & Template Management
router.get("/school/salary-components", authenticateToken, requireRoles(["CORRESPONDENT", "PRINCIPAL", "HM"]), getSalaryComponents);
router.post("/school/salary-components", authenticateToken, requireRoles(["CORRESPONDENT", "PRINCIPAL", "HM"]), createSalaryComponent);
router.delete("/school/salary-components/:id", authenticateToken, requireRoles(["CORRESPONDENT", "PRINCIPAL", "HM"]), deleteSalaryComponent);
router.get("/school/salary-templates", authenticateToken, requireRoles(["CORRESPONDENT", "PRINCIPAL", "HM"]), getSalaryTemplates);
router.post("/school/salary-templates", authenticateToken, requireRoles(["CORRESPONDENT", "PRINCIPAL", "HM"]), createSalaryTemplate);
router.put("/school/salary-templates/:id", authenticateToken, requireRoles(["CORRESPONDENT", "PRINCIPAL", "HM"]), updateSalaryTemplate);
router.delete("/school/salary-templates/:id", authenticateToken, requireRoles(["CORRESPONDENT", "PRINCIPAL", "HM"]), deleteSalaryTemplate);
router.put("/school/teachers/:teacherId/salary-template", authenticateToken, requireRoles(["CORRESPONDENT", "PRINCIPAL", "HM"]), assignSalaryTemplate);
router.get("/school/variable-pay", authenticateToken, requireRoles(["CORRESPONDENT", "PRINCIPAL", "HM"]), getVariablePays);
router.post("/school/variable-pay", authenticateToken, requireRoles(["CORRESPONDENT", "PRINCIPAL", "HM"]), createVariablePay);
router.delete("/school/variable-pay/:id", authenticateToken, requireRoles(["CORRESPONDENT", "PRINCIPAL", "HM"]), deleteVariablePay);

// School Holidays & Weekoffs
router.post("/school/holidays", authenticateToken, requireRoles(["CORRESPONDENT", "PRINCIPAL", "HM"]), createHoliday);
router.get("/school/holidays", authenticateToken, getHolidays);
router.delete("/school/holidays/:id", authenticateToken, requireRoles(["CORRESPONDENT", "PRINCIPAL", "HM"]), deleteHoliday);

// Academic management
router.get("/academic/classes", authenticateToken, getClassesAndSections);
router.post("/academic/classes", authenticateToken, requireRoles(["CORRESPONDENT", "PRINCIPAL", "HM"]), createClass);
router.post("/academic/classes/sections", authenticateToken, requireRoles(["CORRESPONDENT", "PRINCIPAL", "HM"]), createClassSection);
router.put("/academic/classes/sections/:sectionId/class-teacher", authenticateToken, requireRoles(["CORRESPONDENT", "PRINCIPAL", "HM"]), assignClassTeacher);
router.post("/academic/students/assign-class", authenticateToken, requireRoles(["CORRESPONDENT", "PRINCIPAL", "HM"]), assignStudentsToClassSection);
router.post("/academic/students", authenticateToken, requireRoles(["CORRESPONDENT", "PRINCIPAL", "HM"]), addStudent);
router.get("/academic/students", authenticateToken, requireRoles(["CORRESPONDENT", "PRINCIPAL", "HM", "TEACHER"]), getStudents);
router.post("/academic/attendance", authenticateToken, markAttendance);
router.get("/academic/attendance-history", authenticateToken, getAttendanceHistory);
router.post("/academic/homework", authenticateToken, uploadHomework);
router.get("/academic/homework-list", authenticateToken, getHomework);
router.post("/academic/diary", authenticateToken, addDiary);
router.get("/academic/diary-list", authenticateToken, getDiary);
router.post("/academic/marks", authenticateToken, enterMarks);
router.get("/academic/marks-list", authenticateToken, getExamMarks);
router.get("/academic/timetable", authenticateToken, getTimetable);
router.post("/academic/timetable", authenticateToken, requireRoles(["CORRESPONDENT", "PRINCIPAL", "HM", "STAFF_HEAD"]), updateTimetable);
router.put("/academic/timetable/:id", authenticateToken, requireRoles(["CORRESPONDENT", "PRINCIPAL", "HM", "STAFF_HEAD"]), updateTimetableSlot);
router.delete("/academic/timetable/:id", authenticateToken, requireRoles(["CORRESPONDENT", "PRINCIPAL", "HM", "STAFF_HEAD"]), deleteTimetableSlot);
router.post("/academic/resources", authenticateToken, requireRoles(["CORRESPONDENT", "PRINCIPAL", "HM", "TEACHER"]), uploadResource);
router.get("/academic/resources", authenticateToken, getResources);
router.post("/academic/upload-file", authenticateToken, requireRoles(["CORRESPONDENT", "PRINCIPAL", "HM", "TEACHER"]), fileUploadMiddleware.single("file"), uploadFileController);

// Administrative operations
router.post("/admin/leave", authenticateToken, applyLeave);
router.put("/admin/leaves/:leaveId/withdraw", authenticateToken, withdrawLeave);
router.get("/admin/leaves", authenticateToken, getLeaves);
router.post("/admin/rectifications", authenticateToken, applyRectification);
router.get("/admin/rectifications", authenticateToken, getRectifications);
router.put("/admin/rectifications/:id", authenticateToken, requireRoles(["CORRESPONDENT", "PRINCIPAL", "HM"]), updateRectificationStatus);
router.get("/admin/leaves/my-summary", authenticateToken, getMyLeaveSummary);
router.put("/admin/leaves/:leaveId", authenticateToken, requireRoles(["CORRESPONDENT", "PRINCIPAL", "HM", "TEACHER"]), updateLeaveStatus);
router.get("/admin/salaries", authenticateToken, getSalaryRecords);
router.get("/admin/salaries/:salaryRecordId/print", authenticateToken, printPayslip);
router.post("/admin/generate-salaries", authenticateToken, requireRoles(["CORRESPONDENT", "PRINCIPAL", "HM"]), generateSalaries);
router.put("/admin/pay-salary/:salaryRecordId", authenticateToken, requireRoles(["CORRESPONDENT", "PRINCIPAL", "HM"]), paySalary);
router.put("/admin/salaries/:salaryRecordId", authenticateToken, requireRoles(["CORRESPONDENT", "PRINCIPAL", "HM"]), updateSalaryRecord);
router.put("/admin/salaries/advance-status", authenticateToken, requireRoles(["CORRESPONDENT", "PRINCIPAL", "HM"]), advanceSalaryStatus);
router.get("/admin/expenses", authenticateToken, getExpenses);
router.post("/admin/expenses", authenticateToken, requireRoles(["CORRESPONDENT", "PRINCIPAL", "HM"]), addExpense);
router.get("/admin/events", authenticateToken, getEvents);
router.post("/admin/events", authenticateToken, requireRoles(["CORRESPONDENT"]), createEvent);
router.delete("/admin/events/:id", authenticateToken, requireRoles(["CORRESPONDENT"]), deleteEvent);
router.get("/admin/notices", authenticateToken, getNotices);
router.post("/admin/notices", authenticateToken, requireRoles(["CORRESPONDENT", "PRINCIPAL", "HM"]), createNotice);
router.post("/admin/fees", authenticateToken, requireRoles(["CORRESPONDENT", "PRINCIPAL", "HM"]), createFeeRecord);
router.put("/admin/fees/:feeRecordId", authenticateToken, requireRoles(["CORRESPONDENT", "PRINCIPAL", "HM"]), updateFeeRecord);
router.post("/admin/messages", authenticateToken, requireRoles(["CORRESPONDENT", "PRINCIPAL", "HM"]), sendMessageToParents);
router.post("/admin/messages/bulk-fee-reminders", authenticateToken, requireRoles(["CORRESPONDENT", "PRINCIPAL", "HM"]), sendBulkFeeReminders);

// Loans & Advances
router.post("/admin/loans", authenticateToken, requestLoan);
router.get("/admin/loans", authenticateToken, getLoans);
router.put("/admin/loans/:id/status", authenticateToken, requireRoles(["CORRESPONDENT", "PRINCIPAL", "HM"]), updateLoanStatus);

// Leave Types configuration
router.post("/admin/leave-types", authenticateToken, requireRoles(["CORRESPONDENT", "PRINCIPAL", "HM"]), createLeaveType);
router.get("/admin/leave-types", authenticateToken, getLeaveTypes);
router.put("/admin/leave-types/:id", authenticateToken, requireRoles(["CORRESPONDENT", "PRINCIPAL", "HM"]), updateLeaveType);
router.delete("/admin/leave-types/:id", authenticateToken, requireRoles(["CORRESPONDENT", "PRINCIPAL", "HM"]), deleteLeaveType);

// Loan Skip Requests
router.post("/admin/loan-skips", authenticateToken, createSkipRequest);
router.get("/admin/loan-skips", authenticateToken, getSkipRequests);
router.put("/admin/loan-skips/:id/approve", authenticateToken, requireRoles(["CORRESPONDENT", "PRINCIPAL", "HM"]), approveSkipRequest);
router.put("/admin/loan-skips/:id/reject", authenticateToken, requireRoles(["CORRESPONDENT", "PRINCIPAL", "HM"]), rejectSkipRequest);
router.put("/admin/loan-skips/:id/cancel", authenticateToken, cancelSkipRequest);

// Loan Foreclosures
router.post("/admin/loan-foreclosures", authenticateToken, initiateForeclosure);
router.get("/admin/loan-foreclosures", authenticateToken, getForeclosures);
router.put("/admin/loan-foreclosures/:id/approve", authenticateToken, requireRoles(["CORRESPONDENT", "PRINCIPAL", "HM"]), approveForeclosure);
router.put("/admin/loan-foreclosures/:id/reject", authenticateToken, requireRoles(["CORRESPONDENT", "PRINCIPAL", "HM"]), rejectForeclosure);
router.put("/admin/loan-foreclosures/:id/settle", authenticateToken, requireRoles(["CORRESPONDENT", "PRINCIPAL", "HM"]), settleManualForeclosure);

// Transport Coordination
router.get("/transport/routes", authenticateToken, getBusRoutes);
router.post("/transport/routes", authenticateToken, requireRoles(["CORRESPONDENT", "PRINCIPAL", "HM"]), createOrUpdateRoute);
router.post("/transport/driver/update-location", authenticateToken, updateBusLocation);

// Complaints system
router.post("/complaint", authenticateToken, raiseComplaint);
router.get("/complaint", authenticateToken, getComplaints);
router.put("/complaint/:complaintId/resolve", authenticateToken, requireRoles(["CORRESPONDENT", "PRINCIPAL", "HM"]), resolveComplaint);

// Parent portal
router.get("/parent/children", authenticateToken, requireRoles(["PARENT"]), getChildrenDashboard);
router.post("/parent/child-leave", authenticateToken, requireRoles(["PARENT"]), requestChildLeave);
router.post("/parent/pay-fee/:feeRecordId", authenticateToken, requireRoles(["PARENT"]), payFeeSimulated);
router.get("/parent/messages", authenticateToken, getReceivedMessages);

// =========================================================================
// LEAVES & APPROVALS ENTERPRISE REST APIS
// =========================================================================

// Leaves
router.get("/leaves", authenticateToken, getLeavesV2);
router.post("/leaves", authenticateToken, applyLeaveV2);
router.get("/leaves/statistics", authenticateToken, getLeaveStatistics);
router.get("/leaves/history/:employeeId", authenticateToken, getEmployeeLeaveHistory);
router.get("/leaves/:id", authenticateToken, getLeaveById);
router.put("/leaves/:id", authenticateToken, updateLeaveV2);
router.delete("/leaves/:id", authenticateToken, deleteLeaveV2);
router.post("/leaves/:id/approve", authenticateToken, requireRoles(["CORRESPONDENT", "PRINCIPAL", "HM"]), approveLeaveV2);
router.post("/leaves/:id/reject", authenticateToken, requireRoles(["CORRESPONDENT", "PRINCIPAL", "HM"]), rejectLeaveV2);

// Attendance Rectifications
router.get("/attendance-rectifications", authenticateToken, getAttendanceRectificationsV2);
router.post("/attendance-rectifications/:id/approve", authenticateToken, requireRoles(["CORRESPONDENT", "PRINCIPAL", "HM"]), approveAttendanceRectificationV2);
router.post("/attendance-rectifications/:id/reject", authenticateToken, requireRoles(["CORRESPONDENT", "PRINCIPAL", "HM"]), rejectAttendanceRectificationV2);

// Leave Balances
router.get("/leave-balances", authenticateToken, getLeaveBalancesV2);
router.put("/leave-balances/:employeeId", authenticateToken, requireRoles(["CORRESPONDENT", "PRINCIPAL", "HM"]), adjustLeaveBalance);
router.post("/leave-balances/:employeeId/adjust", authenticateToken, requireRoles(["CORRESPONDENT", "PRINCIPAL", "HM"]), adjustLeaveBalance);

// Leave Policies
router.get("/leave-policies", authenticateToken, getLeavePoliciesV2);
router.post("/leave-policies", authenticateToken, requireRoles(["CORRESPONDENT", "PRINCIPAL", "HM"]), createLeavePolicyV2);
router.put("/leave-policies/:id", authenticateToken, requireRoles(["CORRESPONDENT", "PRINCIPAL", "HM"]), updateLeavePolicyV2);
router.delete("/leave-policies/:id", authenticateToken, requireRoles(["CORRESPONDENT", "PRINCIPAL", "HM"]), deleteLeavePolicyV2);

// Audit Logs
router.get("/audit-logs", authenticateToken, requireRoles(["CORRESPONDENT", "PRINCIPAL", "HM"]), getAuditLogs);

export default router;
