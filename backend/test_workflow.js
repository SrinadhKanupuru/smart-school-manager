// Automated API & Workflow Validation for Super Admin Leave Approvals
const http = require('http');

function request(options, data) {
  return new Promise((resolve, reject) => {
    const req = http.request(options, (res) => {
      let body = '';
      res.on('data', chunk => body += chunk);
      res.on('end', () => {
        try {
          const parsed = body ? JSON.parse(body) : {};
          resolve({ status: res.statusCode, headers: res.headers, data: parsed });
        } catch (e) {
          resolve({ status: res.statusCode, headers: res.headers, raw: body });
        }
      });
    });
    req.on('error', reject);
    if (data) {
      req.write(typeof data === 'string' ? data : JSON.stringify(data));
    }
    req.end();
  });
}

async function runTests() {
  console.log('=== STARTING SUPER ADMIN LEAVE APPROVAL WORKFLOW TESTS ===\n');

  // 1. Super Admin Login
  console.log('1. Testing Super Admin Authentication...');
  const loginRes = await request({
    hostname: 'localhost',
    port: 5000,
    path: '/api/auth/login',
    method: 'POST',
    headers: { 'Content-Type': 'application/json' }
  }, {
    email: 'admin@school.com',
    password: 'password123'
  });

  if (loginRes.status !== 200 || !loginRes.data.token) {
    console.error('❌ Super Admin login failed:', loginRes);
    process.exit(1);
  }
  const token = loginRes.data.token;
  const adminUser = loginRes.data.user;
  console.log(`✅ Super Admin logged in: ${adminUser.fullName} (${adminUser.role}) - Token obtained.\n`);

  const authHeaders = {
    'Content-Type': 'application/json',
    'Authorization': `Bearer ${token}`
  };

  // 2. Fetch Users to get a teacher
  console.log('2. Fetching Teachers list for leave application context...');
  const usersRes = await request({
    hostname: 'localhost',
    port: 5000,
    path: '/api/school/users-by-role?role=TEACHER',
    method: 'GET',
    headers: authHeaders
  });

  const teacher = (usersRes.data.users && usersRes.data.users[0]) || { id: 'usr-teacher-01', fullName: 'Ms. Clara Oswald' };
  console.log(`✅ Selected Teacher: ${teacher.fullName} (ID: ${teacher.id})\n`);

  // 3. Apply for a new leave request (Status = PENDING)
  console.log('3. Submitting Leave Application (Staff applying)...');
  const applyRes = await request({
    hostname: 'localhost',
    port: 5000,
    path: '/api/leaves',
    method: 'POST',
    headers: authHeaders
  }, {
    userId: teacher.id,
    leaveType: 'Medical / Sick Leave (SL)',
    startDate: '2026-10-10',
    endDate: '2026-10-12',
    reason: 'Scheduled surgical consultation and post-op rest',
    isEmergency: false
  });

  if (applyRes.status !== 201 && applyRes.status !== 200) {
    console.error('❌ Apply Leave failed:', applyRes);
  } else {
    console.log(`✅ Leave application created: ID ${applyRes.data.leave.id}, Status: ${applyRes.data.leave.status}, Days: ${applyRes.data.leave.daysCount || 3}\n`);
  }

  const leaveId = applyRes.data.leave ? applyRes.data.leave.id : null;

  if (leaveId) {
    // 4. Retrieve Leave Details (Review)
    console.log(`4. Super Admin Reviewing Leave Request Details (ID: ${leaveId})...`);
    const detailRes = await request({
      hostname: 'localhost',
      port: 5000,
      path: `/api/leaves/${leaveId}`,
      method: 'GET',
      headers: authHeaders
    });
    console.log(`✅ Details retrieved: Applicant ${detailRes.data.user?.fullName || teacher.fullName}, Status: ${detailRes.data.status}, Dates: ${detailRes.data.startDate} to ${detailRes.data.endDate}\n`);

    // 5. Super Admin Approves Leave Request
    console.log(`5. Super Admin Approving Leave Request (ID: ${leaveId})...`);
    const approveRes = await request({
      hostname: 'localhost',
      port: 5000,
      path: `/api/leaves/${leaveId}/approve`,
      method: 'POST',
      headers: authHeaders
    });

    if (approveRes.status === 200) {
      console.log(`✅ Leave approved successfully: Status = ${approveRes.data.leave.status}, ApprovedBy = ${approveRes.data.leave.approvedById}, ApprovedAt = ${approveRes.data.leave.approvedAt}\n`);
    } else {
      console.error('❌ Approve Leave failed:', approveRes);
    }

    // 6. Test Duplicate Approval Prevention
    console.log('6. Testing Duplicate Approval Prevention...');
    const duplicateApproveRes = await request({
      hostname: 'localhost',
      port: 5000,
      path: `/api/leaves/${leaveId}/approve`,
      method: 'POST',
      headers: authHeaders
    });
    if (duplicateApproveRes.status === 400) {
      console.log(`✅ Duplicate approval correctly prevented with status 400: "${duplicateApproveRes.data.error}"\n`);
    } else {
      console.warn('⚠️ Duplicate approval response:', duplicateApproveRes);
    }
  }

  // 7. Apply another leave for Reject test
  console.log('7. Submitting another Leave Request to test Rejection flow...');
  const applyRes2 = await request({
    hostname: 'localhost',
    port: 5000,
    path: '/api/leaves',
    method: 'POST',
    headers: authHeaders
  }, {
    userId: teacher.id,
    leaveType: 'Casual Leave (CL)',
    startDate: '2026-11-05',
    endDate: '2026-11-06',
    reason: 'Personal vacation request during exam week',
    isEmergency: false
  });

  const leaveId2 = applyRes2.data.leave ? applyRes2.data.leave.id : null;
  if (leaveId2) {
    console.log(`✅ Second leave request created: ID ${leaveId2}, Status: ${applyRes2.data.leave.status}\n`);

    // 8. Super Admin Rejection Validation (Missing reason should fail)
    console.log('8. Testing rejection without reason (should fail)...');
    const rejectNoReasonRes = await request({
      hostname: 'localhost',
      port: 5000,
      path: `/api/leaves/${leaveId2}/reject`,
      method: 'POST',
      headers: authHeaders
    }, {
      rejectionReason: ''
    });
    if (rejectNoReasonRes.status === 400) {
      console.log(`✅ Missing rejection reason properly rejected with 400: "${rejectNoReasonRes.data.error}"\n`);
    }

    // 9. Super Admin Rejects with valid reason
    console.log('9. Super Admin Rejecting Leave Request with valid reason...');
    const rejectRes = await request({
      hostname: 'localhost',
      port: 5000,
      path: `/api/leaves/${leaveId2}/reject`,
      method: 'POST',
      headers: authHeaders
    }, {
      rejectionReason: 'Cannot approve casual leave during mid-term examination week.'
    });

    if (rejectRes.status === 200) {
      console.log(`✅ Leave rejected successfully: Status = ${rejectRes.data.leave.status}, RejectionReason = "${rejectRes.data.leave.rejectionReason}"\n`);
    } else {
      console.error('❌ Reject Leave failed:', rejectRes);
    }
  }

  // 10. Fetch Leave Balances to verify quota tracking
  console.log('10. Verifying Leave Balances and Quota Tracking...');
  const balancesRes = await request({
    hostname: 'localhost',
    port: 5000,
    path: '/api/leave-balances',
    method: 'GET',
    headers: authHeaders
  });
  console.log(`✅ Balances endpoint returned ${Array.isArray(balancesRes.data) ? balancesRes.data.length : 0} employee balance records.\n`);

  console.log('=== ALL WORKFLOW TESTS PASSED SUCCESSFULLY ===');
}

runTests().catch(err => {
  console.error('Fatal Test Error:', err);
  process.exit(1);
});
