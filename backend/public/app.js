/**
 * SMART SCHOOL MANAGER - CLIENT APPLICATION & MULTI-ROLE ENGINE
 */

// Global Application State
const state = {
  currentRole: 'CORRESPONDENT',
  activeTab: 'dashboard',
  serverOnline: false,
  isBusSimulating: true,
  busInterval: null,
  webcamStream: null,
  chartInstance: null,
  students: [
    { roll: '10-A-01', name: 'Sophia Chen', class: 'Grade 10', section: 'A', parent: 'David Chen', phone: '+1 555-0121', attendance: '98%', feeStatus: 'PAID', avatar: '/assets/student_girl.jpg', badge: '🏆 Top Scholar (98.6%)', club: 'Robotics Team' },
    { roll: '10-A-02', name: 'Marcus Vance', class: 'Grade 10', section: 'A', parent: 'Elena Vance', phone: '+1 555-0122', attendance: '94%', feeStatus: 'PAID', avatar: '/assets/student_boy.jpg', badge: '⭐ Science Olympiad', club: 'Astronomy Club' },
    { roll: '10-A-03', name: 'Aria Sharma', class: 'Grade 10', section: 'A', parent: 'Rajesh Sharma', phone: '+1 555-0123', attendance: '91%', feeStatus: 'PARTIAL', avatar: '/assets/student_girl.jpg', badge: '🎨 Arts Lead', club: 'Design Guild' },
    { roll: '10-B-01', name: 'Liam Wilson', class: 'Grade 10', section: 'B', parent: 'Sarah Wilson', phone: '+1 555-0124', attendance: '88%', feeStatus: 'PENDING', avatar: '/assets/student_boy.jpg', badge: '⚽ Sports Captain', club: 'Athletics' },
    { roll: '09-A-01', name: 'Zoe Martinez', class: 'Grade 9', section: 'A', parent: 'Carlos Martinez', phone: '+1 555-0125', attendance: '96%', feeStatus: 'PAID', avatar: '/assets/student_girl.jpg', badge: '📚 Math Whiz', club: 'Chess Club' },
    { roll: '09-B-01', name: 'Ethan Taylor', class: 'Grade 9', section: 'B', parent: 'Amanda Taylor', phone: '+1 555-0126', attendance: '93%', feeStatus: 'PAID', avatar: '/assets/student_boy.jpg', badge: '🎵 Music Club', club: 'Orchestra' },
    { roll: '08-A-01', name: 'Chloe Dubois', class: 'Grade 8', section: 'A', parent: 'Jean Dubois', phone: '+1 555-0127', attendance: '99%', feeStatus: 'PAID', avatar: '/assets/student_girl.jpg', badge: '🌿 Eco Club Lead', club: 'Green Campus' }
  ],
  staff: [
    { name: 'Dr. Arthur Pendelton', role: 'Headmaster / Dean', dept: 'Administration', email: 'a.pendelton@stjude.edu', avatar: '/assets/principal_hero.jpg', status: 'PRESENT' },
    { name: 'Ms. Clara Oswald', role: 'Senior Faculty', dept: 'Mathematics', email: 'c.oswald@stjude.edu', avatar: '/assets/teacher_hero.jpg', status: 'PRESENT' },
    { name: 'Prof. Julian Bashir', role: 'Associate Professor', dept: 'Physics & Lab', email: 'j.bashir@stjude.edu', avatar: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=120&h=120&q=80', status: 'PRESENT' },
    { name: 'Mrs. Rebecca Sterling', role: 'Lead Instructor', dept: 'English Literature', email: 'r.sterling@stjude.edu', avatar: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?auto=format&fit=crop&w=120&h=120&q=80', status: 'ON LEAVE' }
  ],
  notices: [
    { title: 'Annual Inter-School Science & Tech Expo 2026', audience: 'ALL', date: 'Sept 15, 2026', author: 'Principal Office', desc: 'All students from Grade 8-12 are invited to submit experimental project abstracts by Friday.' },
    { title: 'Staff Development Workshop on Modern Pedagogy', audience: 'STAFF', date: 'Sept 18, 2026', author: 'Academic Dean', desc: 'Mandatory continuous professional development seminar in Main Auditorium at 3:30 PM.' },
    { title: 'Term-1 Tuition Fee Reminders', audience: 'PARENTS', date: 'Sept 10, 2026', author: 'Accounts Dept', desc: 'Kindly clear remaining term dues before mid-term examination hall tickets are released.' }
  ],
  leaves: [
    { applicant: 'Mrs. Rebecca Sterling', type: 'Medical (SL)', start: '2026-09-07', end: '2026-09-09', reason: 'Viral fever recuperation', status: 'APPROVED' },
    { applicant: 'Mr. David Vance (Driver)', type: 'Casual (CL)', start: '2026-09-11', end: '2026-09-12', reason: 'Personal family ceremony', status: 'PENDING' },
    { applicant: 'Ms. Helena Troy (Lab Asst)', type: 'Earned (EL)', start: '2026-09-15', end: '2026-09-16', reason: 'University certification exam', status: 'PENDING' }
  ],
  activities: [
    { icon: 'fa-camera', bg: 'bg-role-accent', text: 'Ms. Clara Oswald verified via AI Face Scanner (99.4%)', time: '2 mins ago' },
    { icon: 'fa-sack-dollar', bg: 'bg-emerald', text: 'Tuition payment of $1,450 received from David Chen', time: '14 mins ago' },
    { icon: 'fa-bus', bg: 'bg-amber', text: 'Bus #04 reached North Ring Road Stop 3 on schedule', time: '22 mins ago' },
    { icon: 'fa-file-signature', bg: 'bg-indigo', text: 'New homework assigned in Physics 10-A by Prof. Bashir', time: '45 mins ago' }
  ],
  leavesState: {
    activeSubTab: 'requests',
    leaveRequests: [],
    filteredRequests: [],
    rectifications: [],
    filteredRectifications: [],
    balances: [],
    filteredBalances: [],
    policies: [],
    searchQuery: '',
    statusFilter: 'ALL',
    typeFilter: 'ALL',
    deptFilter: 'ALL',
    dateFilter: 'ALL',
    customStartDate: '',
    customEndDate: '',
    selectedLeave: null,
    selectedRectification: null,
    selectedBalanceEmployee: null,
    editingPolicyId: null,
    stats: {
      pending: 0,
      approved: 0,
      rejected: 0,
      rectifications: 0,
    }
  }
};

// Initialize Application
document.addEventListener('DOMContentLoaded', () => {
  initNavigation();
  initThemeToggle();
  setRole('CORRESPONDENT'); // Default starting role
  startServerHealthPolling();
  startBusSimulation();
  initFaceScannerEvents();
  initLeavesModule();
});

// Navigation Handling
function initNavigation() {
  const navItems = document.querySelectorAll('.nav-item');
  navItems.forEach(item => {
    item.addEventListener('click', (e) => {
      e.preventDefault();
      const tab = item.getAttribute('data-tab');
      switchTab(tab);
    });
  });

  // Mobile menu toggle
  const menuToggle = document.getElementById('menuToggle');
  const sidebar = document.getElementById('sidebar');
  if (menuToggle && sidebar) {
    menuToggle.addEventListener('click', () => {
      sidebar.classList.toggle('open');
    });
  }
}

function switchTab(tabId) {
  state.activeTab = tabId;
  
  // Update Nav items
  document.querySelectorAll('.nav-item').forEach(item => {
    item.classList.toggle('active', item.getAttribute('data-tab') === tabId);
  });

  // Update Content views
  document.querySelectorAll('.content-view').forEach(view => {
    view.classList.toggle('active', view.id === `view-${tabId}`);
  });

  if (tabId === 'leaves') {
    initLeavesModule();
  }

  // Close mobile sidebar if open
  document.getElementById('sidebar')?.classList.remove('open');
  window.scrollTo({ top: 0, behavior: 'smooth' });
}

// Persona Configuration Database
const PERSONA_CONFIG = {
  CORRESPONDENT: {
    role: 'CORRESPONDENT',
    name: 'Dr. Evelyn Vance',
    title: 'Correspondent (Super Admin)',
    badge: 'SUPER ADMIN',
    email: 'admin@smartschool.edu',
    password: 'password123',
    avatar: '/assets/admin_hero.jpg',
    desc: 'Full institutional command, financial ERP, staff payroll & multi-campus analytics.'
  },
  PRINCIPAL: {
    role: 'PRINCIPAL',
    name: 'Dr. Arthur Pendelton',
    title: 'Principal & Headmaster',
    badge: 'DEAN / HM',
    email: 'principal@smartschool.edu',
    password: 'password123',
    avatar: '/assets/principal_hero.jpg',
    desc: 'Academic oversight, staff leave approvals, master timetables & institutional discipline.'
  },
  TEACHER: {
    role: 'TEACHER',
    name: 'Ms. Clara Oswald',
    title: 'Mathematics Faculty',
    badge: 'CLASS 10-A',
    email: 'clara.teacher@smartschool.edu',
    password: 'password123',
    avatar: '/assets/teacher_hero.jpg',
    desc: 'AI face roll call scanner, homework assignments, student gradebooks & parent messaging.'
  },
  PARENT: {
    role: 'PARENT',
    name: 'David Chen',
    title: 'Parent of Sophia Chen',
    badge: 'PARENT PORTAL',
    email: 'david.parent@smartschool.edu',
    password: 'password123',
    avatar: '/assets/parent_hero.jpg',
    desc: 'Live GPS school bus tracking, instant fee payments, homework diary & digital report cards.'
  }
};

let modalSelectedRole = 'CORRESPONDENT';

function openLoginModal(preselectRole) {
  const role = preselectRole || state.currentRole || 'CORRESPONDENT';
  selectLoginRole(role);
  openModal('roleLoginModal');
}

function selectLoginRole(role) {
  modalSelectedRole = role;
  const config = PERSONA_CONFIG[role];
  if (!config) return;

  // Update tabs active styling
  ['Correspondent', 'Principal', 'Teacher', 'Parent'].forEach(r => {
    const tab = document.getElementById(`tabRole${r}`);
    if (tab) {
      tab.classList.toggle('active', r.toUpperCase() === role);
    }
  });

  // Update Persona Preview Card
  const previewImg = document.getElementById('loginPreviewImg');
  const previewBadge = document.getElementById('loginPreviewRoleBadge');
  const previewName = document.getElementById('loginPreviewName');
  const previewDesc = document.getElementById('loginPreviewDesc');
  const emailInput = document.getElementById('loginEmailInput');
  const passwordInput = document.getElementById('loginPasswordInput');

  if (previewImg) previewImg.src = config.avatar;
  if (previewBadge) previewBadge.textContent = config.badge;
  if (previewName) previewName.textContent = config.name;
  if (previewDesc) previewDesc.textContent = config.desc;
  if (emailInput) emailInput.value = config.email;
  if (passwordInput) passwordInput.value = config.password;
}

function toggleLoginPassword() {
  const pwInput = document.getElementById('loginPasswordInput');
  const pwIcon = document.getElementById('pwToggleIcon');
  if (!pwInput || !pwIcon) return;
  
  if (pwInput.type === 'password') {
    pwInput.type = 'text';
    pwIcon.classList.remove('fa-eye');
    pwIcon.classList.add('fa-eye-slash');
  } else {
    pwInput.type = 'password';
    pwIcon.classList.remove('fa-eye-slash');
    pwIcon.classList.add('fa-eye');
  }
}

function handleLoginFormSubmit(event) {
  if (event) event.preventDefault();
  const btn = document.getElementById('loginSubmitBtn');
  
  if (btn) {
    btn.disabled = true;
    btn.innerHTML = '<i class="fa-solid fa-circle-notch fa-spin"></i> <span>Authenticating credentials...</span>';
  }

  setTimeout(() => {
    const role = modalSelectedRole || 'CORRESPONDENT';
    const config = PERSONA_CONFIG[role];
    setRole(role);
    closeModal('roleLoginModal');
    
    if (btn) {
      btn.disabled = false;
      btn.innerHTML = '<i class="fa-solid fa-arrow-right-to-bracket"></i> <span id="loginSubmitText">Log In to Portal</span>';
    }
    
    showToast(`✨ Login Successful! Welcome, ${config ? config.name : role} (${getRoleNiceName(role)})`, 'success');
  }, 350);
}

function handleLogout() {
  showToast('Logged out of active session.', 'info');
  openLoginModal('CORRESPONDENT');
}

// Multi-Role Switching Engine
function setRole(role) {
  state.currentRole = role;
  
  // Update body theme attribute
  document.body.setAttribute('data-role', role);

  // Update Profile & Dashboard UI
  updateRolePersonaUI(role);
  renderAllViews();
  updateChartForRole(role);
}

function loginAsRole(role) {
  selectLoginRole(role);
  handleLoginFormSubmit();
}

function getRoleNiceName(role) {
  switch (role) {
    case 'CORRESPONDENT': return 'Correspondent (Admin)';
    case 'PRINCIPAL': return 'Principal (Dean)';
    case 'TEACHER': return 'Faculty Teacher';
    case 'PARENT': return 'Parent Portal';
    default: return role;
  }
}

function updateRolePersonaUI(role) {
  const userName = document.getElementById('userName');
  const userTitle = document.getElementById('userTitle');
  const userAvatar = document.getElementById('userAvatar');
  const sidebarUserName = document.getElementById('sidebarUserName');
  const sidebarUserRole = document.getElementById('sidebarUserRole');
  const sidebarUserAvatar = document.getElementById('sidebarUserAvatar');
  const brandRoleBadge = document.getElementById('brandRoleBadge');
  const activeRoleFooter = document.getElementById('activeRoleFooter');
  const rolePillFloating = document.getElementById('rolePillFloating');
  const welcomeTitle = document.getElementById('welcomeTitle');
  const welcomeSubtitle = document.getElementById('welcomeSubtitle');
  const bannerTags = document.getElementById('bannerTags');
  const welcomeActions = document.getElementById('welcomeActions');
  const approvalBoxTitle = document.getElementById('approvalBoxTitle');
  const hero3DImg = document.getElementById('hero3DImg');
  const hero3DBadgeText = document.getElementById('hero3DBadgeText');

  switch (role) {
    case 'CORRESPONDENT':
      brandRoleBadge.textContent = 'SUPER ADMIN ERP';
      activeRoleFooter.textContent = 'Theme: Royal Violet Admin';
      userName.textContent = 'Dr. Evelyn Vance';
      userTitle.textContent = 'Correspondent (Super Admin)';
      userAvatar.src = '/assets/admin_hero.jpg';
      if (sidebarUserName) sidebarUserName.textContent = 'Dr. Evelyn Vance';
      if (sidebarUserRole) sidebarUserRole.textContent = 'Super Admin / Director';
      if (sidebarUserAvatar) sidebarUserAvatar.src = '/assets/admin_hero.jpg';
      if (hero3DImg) hero3DImg.src = '/assets/admin_hero.jpg';
      if (hero3DBadgeText) hero3DBadgeText.textContent = 'Live: Correspondent Command';
      
      rolePillFloating.innerHTML = '<i class="fa-solid fa-crown"></i> SUPER ADMIN COMMAND';
      welcomeTitle.innerHTML = 'Welcome to <span class="gradient-text">St. Jude International School</span>';
      welcomeSubtitle.textContent = 'Academic Year 2026-2027 • All 14 institutional departments reporting normal operations with automated geofencing.';
      bannerTags.innerHTML = `
        <span class="tag"><i class="fa-solid fa-school"></i> Code: <strong>SJIS-8821</strong></span>
        <span class="tag"><i class="fa-solid fa-location-dot"></i> Bengaluru Campus</span>
        <span class="tag tag-success"><i class="fa-solid fa-circle-check"></i> System Operational</span>
      `;
      welcomeActions.innerHTML = `
        <button class="btn btn-primary" onclick="switchTab('face-attendance')"><i class="fa-solid fa-camera"></i> Kiosk Mode</button>
        <button class="btn btn-secondary" onclick="openModal('addStudentModal')"><i class="fa-solid fa-user-plus"></i> Enroll Student</button>
      `;
      approvalBoxTitle.textContent = 'Pending Staff Leaves & Skips';
      break;

    case 'PRINCIPAL':
      brandRoleBadge.textContent = 'ACADEMIC DEAN';
      activeRoleFooter.textContent = 'Theme: Cyber Emerald Dean';
      userName.textContent = 'Dr. Arthur Pendelton';
      userTitle.textContent = 'Principal / Headmaster';
      userAvatar.src = '/assets/principal_hero.jpg';
      if (sidebarUserName) sidebarUserName.textContent = 'Dr. Arthur Pendelton';
      if (sidebarUserRole) sidebarUserRole.textContent = 'Principal & Headmaster';
      if (sidebarUserAvatar) sidebarUserAvatar.src = '/assets/principal_hero.jpg';
      if (hero3DImg) hero3DImg.src = '/assets/principal_hero.jpg';
      if (hero3DBadgeText) hero3DBadgeText.textContent = 'Live: Principal Suite';
      
      rolePillFloating.innerHTML = '<i class="fa-solid fa-user-tie"></i> PRINCIPAL EXECUTIVE SUITE';
      welcomeTitle.innerHTML = 'Good Morning, <span class="gradient-text">Principal Pendelton</span>';
      welcomeSubtitle.textContent = 'Campus-wide attendance is at 97.6% today. 3 faculty leave requests and 2 bus route dispatches require your review.';
      bannerTags.innerHTML = `
        <span class="tag"><i class="fa-solid fa-users"></i> 85 Faculty Active</span>
        <span class="tag"><i class="fa-solid fa-bell"></i> 3 Pending Approvals</span>
        <span class="tag tag-success"><i class="fa-solid fa-shield"></i> Campus Secure</span>
      `;
      welcomeActions.innerHTML = `
        <button class="btn btn-primary" onclick="switchTab('leaves')"><i class="fa-solid fa-check-double"></i> Review Leaves</button>
        <button class="btn btn-secondary" onclick="switchTab('timetable')"><i class="fa-solid fa-calendar-days"></i> Master Timetable</button>
      `;
      approvalBoxTitle.textContent = 'Faculty Approvals Required';
      break;

    case 'TEACHER':
      brandRoleBadge.textContent = 'CLASS 10-A TEACHER';
      activeRoleFooter.textContent = 'Theme: Sunburst Amber Faculty';
      userName.textContent = 'Ms. Clara Oswald';
      userTitle.textContent = 'Senior Mathematics Faculty';
      userAvatar.src = '/assets/teacher_hero.jpg';
      if (sidebarUserName) sidebarUserName.textContent = 'Ms. Clara Oswald';
      if (sidebarUserRole) sidebarUserRole.textContent = 'Class 10-A Faculty';
      if (sidebarUserAvatar) sidebarUserAvatar.src = '/assets/teacher_hero.jpg';
      if (hero3DImg) hero3DImg.src = '/assets/teacher_hero.jpg';
      if (hero3DBadgeText) hero3DBadgeText.textContent = 'Live: Class 10-A Mentor';
      
      rolePillFloating.innerHTML = '<i class="fa-solid fa-chalkboard-user"></i> CLASSROOM TEACHER HUB';
      welcomeTitle.innerHTML = 'Hello, <span class="gradient-text">Ms. Clara Oswald</span>';
      welcomeSubtitle.textContent = 'Class 10-A: 28 of 30 students checked in today. Next period: Advanced Calculus in Room 204 at 10:30 AM.';
      bannerTags.innerHTML = `
        <span class="tag"><i class="fa-solid fa-graduation-cap"></i> Class 10-A Mentor</span>
        <span class="tag"><i class="fa-solid fa-book"></i> 2 Homeworks Active</span>
        <span class="tag tag-success"><i class="fa-solid fa-circle-check"></i> Biometric Verified</span>
      `;
      welcomeActions.innerHTML = `
        <button class="btn btn-primary" onclick="switchTab('homework')"><i class="fa-solid fa-file-arrow-up"></i> Assign Homework</button>
        <button class="btn btn-secondary" onclick="switchTab('exams')"><i class="fa-solid fa-pen-to-square"></i> Enter Marks</button>
      `;
      approvalBoxTitle.textContent = 'Class 10-A Student Requests';
      break;

    case 'PARENT':
      brandRoleBadge.textContent = 'PARENT PORTAL';
      activeRoleFooter.textContent = 'Theme: Radiant Rose Family';
      userName.textContent = 'David Chen';
      userTitle.textContent = 'Parent of Sophia Chen (Grade 10-A)';
      userAvatar.src = '/assets/parent_hero.jpg';
      if (sidebarUserName) sidebarUserName.textContent = 'David Chen';
      if (sidebarUserRole) sidebarUserRole.textContent = 'Parent of Sophia (10-A)';
      if (sidebarUserAvatar) sidebarUserAvatar.src = '/assets/parent_hero.jpg';
      if (hero3DImg) hero3DImg.src = '/assets/parent_hero.jpg';
      if (hero3DBadgeText) hero3DBadgeText.textContent = 'Live: Sophia (10-A) Hub';
      
      rolePillFloating.innerHTML = '<i class="fa-solid fa-hands-holding-child"></i> PARENT & GUARDIAN DASHBOARD';
      welcomeTitle.innerHTML = 'Welcome, <span class="gradient-text">David Chen</span>';
      welcomeSubtitle.textContent = 'Sophia Chen (Grade 10-A) has arrived at school on Bus #04. Term 1 fees are fully settled. Attendance: 98% (Exemplary).';
      bannerTags.innerHTML = `
        <span class="tag"><i class="fa-solid fa-user-graduate"></i> Student: <strong>Sophia Chen</strong></span>
        <span class="tag"><i class="fa-solid fa-bus"></i> Bus #04 • Safe Arrival</span>
        <span class="tag tag-success"><i class="fa-solid fa-check"></i> Term-1 Fee Paid</span>
      `;
      welcomeActions.innerHTML = `
        <button class="btn btn-primary" onclick="switchTab('transport')"><i class="fa-solid fa-map-pin"></i> Track Bus #04</button>
        <button class="btn btn-secondary" onclick="switchTab('homework')"><i class="fa-solid fa-book-open"></i> Sophia\'s Homework</button>
      `;
      approvalBoxTitle.textContent = 'Recent Messages from School';
      break;
  }
}

// Theme Toggle
function initThemeToggle() {
  const btn = document.getElementById('btnThemeToggle');
  if (!btn) return;

  btn.addEventListener('click', () => {
    document.body.classList.toggle('light-theme');
    const isLight = document.body.classList.contains('light-theme');
    btn.innerHTML = isLight ? '<i class="fa-solid fa-sun"></i>' : '<i class="fa-solid fa-moon"></i>';
    if (state.chartInstance) updateChartForRole(state.currentRole);
  });
}

// Render All Dynamic Views
function renderAllViews() {
  renderMetricsGrid();
  renderActivityFeed();
  renderPendingApprovals();
  renderBusMiniList();
  renderStudentsTable();
  renderStaffGrid();
  renderTimetableGrid();
  renderHomeworkGrid();
  renderExamMarks();
  renderFinanceTables();
  renderNotices();
  renderLeaves();
  renderRecentScans();
  renderRouteDetails();
}

// Role-Specific Metrics Grid
function renderMetricsGrid() {
  const container = document.getElementById('metricsGrid');
  if (!container) return;

  const role = state.currentRole;
  let cards = [];

  if (role === 'CORRESPONDENT') {
    cards = [
      { title: 'Total Enrolled Students', value: '1,248', icon: 'fa-user-graduate', trend: '+4.2% vs last term', trendClass: 'trend-up', trendIcon: 'fa-arrow-trend-up' },
      { title: 'Staff Present Today', value: '96.8%', icon: 'fa-user-tie', trend: '82/85 Checked In', trendClass: 'trend-up', trendIcon: 'fa-check-double' },
      { title: 'Monthly Fee Collection', value: '$184,250', icon: 'fa-sack-dollar', trend: '88% target achieved', trendClass: 'trend-up', trendIcon: 'fa-arrow-trend-up' },
      { title: 'Active Bus Fleet', value: '12 / 12', icon: 'fa-bus-simple', trend: 'GPS Telemetry Active', trendClass: 'trend-neutral', trendIcon: 'fa-satellite-dish' }
    ];
  } else if (role === 'PRINCIPAL') {
    cards = [
      { title: 'Campus Attendance Rate', value: '97.6%', icon: 'fa-school', trend: '1,218 students present', trendClass: 'trend-up', trendIcon: 'fa-check-double' },
      { title: 'Pending Staff Requests', value: '3 Pending', icon: 'fa-clock-rotate-left', trend: '2 Leaves, 1 Rectification', trendClass: 'trend-neutral', trendIcon: 'fa-bell' },
      { title: 'Academic Syllabus Covered', value: '74.2%', icon: 'fa-chart-pie', trend: 'On track for Mid-Terms', trendClass: 'trend-up', trendIcon: 'fa-arrow-trend-up' },
      { title: 'Disciplinary Cases', value: '0 Active', icon: 'fa-shield-halved', trend: 'Exemplary Conduct', trendClass: 'trend-up', trendIcon: 'fa-circle-check' }
    ];
  } else if (role === 'TEACHER') {
    cards = [
      { title: 'Class 10-A Present', value: '28 / 30', icon: 'fa-chalkboard-user', trend: '93.3% attendance today', trendClass: 'trend-up', trendIcon: 'fa-check-double' },
      { title: 'Active Homeworks', value: '3 Active', icon: 'fa-book-open', trend: '24 submissions received', trendClass: 'trend-neutral', trendIcon: 'fa-file-signature' },
      { title: 'Class Average Marks', value: '88.4%', icon: 'fa-award', trend: 'Rank 1 across Grade 10', trendClass: 'trend-up', trendIcon: 'fa-trophy' },
      { title: 'My Teaching Hours', value: '5.5 Hrs', icon: 'fa-stopwatch', trend: '4 Periods scheduled', trendClass: 'trend-neutral', trendIcon: 'fa-calendar-check' }
    ];
  } else if (role === 'PARENT') {
    cards = [
      { title: 'Sophia\'s Attendance', value: '98.0%', icon: 'fa-user-graduate', trend: '54 / 55 Days Present', trendClass: 'trend-up', trendIcon: 'fa-circle-check' },
      { title: 'Live Bus #04 ETA', value: '4 Mins', icon: 'fa-bus', trend: 'Near Green Valley Stop', trendClass: 'trend-neutral', trendIcon: 'fa-location-dot' },
      { title: 'Term-1 Tuition Fee', value: '$1,450', icon: 'fa-receipt', trend: 'Status: Fully Paid', trendClass: 'trend-up', trendIcon: 'fa-circle-check' },
      { title: 'Overall Academic Grade', value: 'A+ (96.3%)', icon: 'fa-star', trend: 'Top 3 in Class 10-A', trendClass: 'trend-up', trendIcon: 'fa-award' }
    ];
  }

  container.innerHTML = cards.map(c => `
    <div class="metric-card">
      <div class="metric-header">
        <span class="metric-title">${c.title}</span>
        <div class="metric-icon" style="background: var(--role-gradient);">
          <i class="fa-solid ${c.icon}"></i>
        </div>
      </div>
      <div class="metric-body">
        <h3 class="metric-value">${c.value}</h3>
        <div class="metric-trend ${c.trendClass}">
          <i class="fa-solid ${c.trendIcon}"></i> ${c.trend}
        </div>
      </div>
    </div>
  `).join('');
}

// Activity Feed Rendering
function renderActivityFeed() {
  const container = document.getElementById('activityFeed');
  if (!container) return;

  container.innerHTML = state.activities.map(act => `
    <div class="activity-item">
      <div class="activity-icon" style="background: var(--role-gradient);">
        <i class="fa-solid ${act.icon}"></i>
      </div>
      <div class="activity-content">
        <p class="activity-text">${act.text}</p>
        <span class="activity-time">${act.time}</span>
      </div>
    </div>
  `).join('');
}

// Pending Approvals
function renderPendingApprovals() {
  const container = document.getElementById('pendingApprovalsList');
  if (!container) return;

  const pending = state.leaves.filter(l => l.status === 'PENDING');
  container.innerHTML = pending.map((item, idx) => `
    <div class="scan-item" style="margin-bottom: 8px;">
      <div>
        <strong>${item.applicant}</strong>
        <div style="font-size:0.75rem; color: var(--text-muted);">${item.type} • ${item.reason}</div>
      </div>
      <div style="display:flex; gap:6px;">
        <button class="btn btn-sm btn-primary" onclick="approveLeave(${idx})"><i class="fa-solid fa-check"></i></button>
        <button class="btn btn-sm btn-secondary" onclick="rejectLeave(${idx})"><i class="fa-solid fa-xmark"></i></button>
      </div>
    </div>
  `).join('');
}

function approveLeave(idx) {
  state.leaves[idx].status = 'APPROVED';
  renderPendingApprovals();
  renderLeaves();
  showToast('Leave request approved successfully', 'success');
}

function rejectLeave(idx) {
  state.leaves[idx].status = 'REJECTED';
  renderPendingApprovals();
  renderLeaves();
  showToast('Leave request rejected', 'info');
}

// Mini Bus List in Dashboard
function renderBusMiniList() {
  const container = document.getElementById('busMiniList');
  if (!container) return;

  container.innerHTML = `
    <div class="scan-item" style="margin-bottom: 8px;">
      <div style="display:flex; align-items:center; gap:10px;">
        <i class="fa-solid fa-bus" style="color: var(--primary)"></i>
        <div>
          <strong>Bus #04 - North Ring Route</strong>
          <div style="font-size:0.75rem; color:var(--text-muted)">Driver: Marcus Sterling • Speed: 38 km/h</div>
        </div>
      </div>
      <span class="badge badge-success">On Schedule</span>
    </div>
    <div class="scan-item">
      <div style="display:flex; align-items:center; gap:10px;">
        <i class="fa-solid fa-bus" style="color: var(--primary)"></i>
        <div>
          <strong>Bus #09 - Central Metro Express</strong>
          <div style="font-size:0.75rem; color:var(--text-muted)">Driver: Liam Brody • Speed: 42 km/h</div>
        </div>
      </div>
      <span class="badge badge-info">En Route</span>
    </div>
  `;
}

// Students Table & Filtering
function filterStudents() {
  const cls = document.getElementById('filterClass')?.value || 'ALL';
  const sec = document.getElementById('filterSection')?.value || 'ALL';
  const fee = document.getElementById('filterFeeStatus')?.value || 'ALL';
  const query = document.getElementById('studentSearchInput')?.value.toLowerCase() || '';

  const filtered = state.students.filter(s => {
    const matchClass = (cls === 'ALL' || s.class === cls);
    const matchSec = (sec === 'ALL' || s.section === sec);
    const matchFee = (fee === 'ALL' || s.feeStatus === fee);
    const matchQuery = (!query || s.name.toLowerCase().includes(query) || s.roll.toLowerCase().includes(query));
    return matchClass && matchSec && matchFee && matchQuery;
  });

  const tbody = document.getElementById('studentsTableBody');
  if (!tbody) return;

  tbody.innerHTML = filtered.map(s => `
    <tr class="student-table-row">
      <td><code>${s.roll}</code></td>
      <td>
        <div class="student-cell-info">
          <div class="student-mini-avatar">
            <img src="${s.avatar}" alt="${s.name}">
            <span class="student-status-dot"></span>
          </div>
          <div>
            <strong class="student-cell-name">${s.name}</strong>
            <div class="student-cell-badge">${s.badge || s.club}</div>
          </div>
        </div>
      </td>
      <td><span class="badge badge-info">${s.class} - ${s.section}</span></td>
      <td>
        <div style="font-size:0.84rem; font-weight:600;">${s.parent}</div>
        <small style="color:var(--text-muted)"><i class="fa-solid fa-phone" style="font-size:0.68rem;"></i> ${s.phone}</small>
      </td>
      <td>
        <div class="attendance-progress-cell">
          <div class="progress-bar-wrap">
            <div class="progress-bar-fill" style="width: ${s.attendance}"></div>
          </div>
          <strong>${s.attendance}</strong>
        </div>
      </td>
      <td>
        <span class="badge ${s.feeStatus === 'PAID' ? 'badge-success' : (s.feeStatus === 'PARTIAL' ? 'badge-warning' : 'badge-danger')}">
          <i class="fa-solid ${s.feeStatus === 'PAID' ? 'fa-circle-check' : 'fa-clock'}"></i> ${s.feeStatus}
        </span>
      </td>
      <td>
        <button class="btn btn-sm btn-secondary" onclick="showToast('Viewing academic portfolio for ${s.name}', 'info')">
          <i class="fa-solid fa-graduation-cap"></i> Profile
        </button>
      </td>
    </tr>
  `).join('');
}

function renderStudentsTable() {
  filterStudents();
}

// Staff Directory Grid
function renderStaffGrid() {
  const container = document.getElementById('staffGrid');
  if (!container) return;

  container.innerHTML = state.staff.map(st => `
    <div class="staff-card">
      <img src="${st.avatar}" alt="${st.name}" class="staff-avatar">
      <h3 class="staff-name">${st.name}</h3>
      <span class="staff-role-badge">${st.role}</span>
      <div class="staff-meta">
        <span><i class="fa-solid fa-building-columns"></i> ${st.dept}</span>
        <span><i class="fa-solid fa-envelope"></i> ${st.email}</span>
      </div>
      <div style="display: flex; justify-content: center; gap: 8px;">
        <span class="badge ${st.status === 'PRESENT' ? 'badge-success' : 'badge-warning'}">${st.status}</span>
        <button class="btn btn-sm btn-secondary" onclick="showToast('Payslip generated for ${st.name}', 'success')">
          <i class="fa-solid fa-receipt"></i> Payslip
        </button>
      </div>
    </div>
  `).join('');
}

// Timetable Grid
function renderTimetableGrid() {
  const container = document.getElementById('timetableGrid');
  if (!container) return;

  const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'];
  const times = ['08:30 - 09:20', '09:25 - 10:15', '10:30 - 11:20', '11:25 - 12:15', '01:00 - 01:50'];
  const subjects = [
    ['Mathematics (Oswald)', 'Physics (Bashir)', 'Chemistry (Sterling)', 'English Lit', 'Physical Ed'],
    ['Physics Lab', 'Physics Lab', 'Mathematics', 'Computer Sci', 'History'],
    ['English Lit', 'Chemistry Lab', 'Chemistry Lab', 'Biology', 'Library Period'],
    ['Computer Sci', 'Mathematics', 'Physics', 'Social Studies', 'Art & Design'],
    ['Biology Lab', 'Biology Lab', 'Mathematics', 'Economics', 'Weekly Assembly']
  ];

  let html = `<div class="timetable-header">Time</div>`;
  days.forEach(d => html += `<div class="timetable-header">${d}</div>`);

  times.forEach((t, timeIdx) => {
    html += `<div class="timetable-time">${t}</div>`;
    days.forEach((d, dayIdx) => {
      const subj = subjects[timeIdx][dayIdx];
      html += `
        <div class="timetable-slot">
          <div class="slot-subject">${subj}</div>
          <div class="slot-teacher">Room 204 • Academic Wing</div>
        </div>
      `;
    });
  });

  container.innerHTML = html;
}

// Homework Grid
function renderHomeworkGrid() {
  const container = document.getElementById('homeworkList');
  if (!container) return;

  const list = [
    { subject: 'Physics 10-A', title: 'Thermodynamics & Carnot Engine Worksheet', due: 'Tomorrow, 9:00 AM', desc: 'Complete problem sets 4.1 through 4.8 from Chapter 4 and upload scanned solution.' },
    { subject: 'Mathematics 10-A', title: 'Quadratic Polynomial Factorization', due: 'Sept 10, 2026', desc: 'Exercise 3.4 problems #1 to #20 with step-by-step discriminant verification.' },
    { subject: 'English Lit 10-A', title: 'Essay: The Renaissance Influence on Poetry', due: 'Sept 12, 2026', desc: '500-word critical evaluation of Elizabethan lyrical structures with 2 citation references.' }
  ];

  container.innerHTML = list.map(hw => `
    <div class="homework-card">
      <div>
        <div class="hw-header">
          <span class="hw-subject">${hw.subject}</span>
          <span class="badge badge-warning"><i class="fa-solid fa-clock"></i> Due: ${hw.due}</span>
        </div>
        <h3 class="hw-title">${hw.title}</h3>
        <p class="hw-desc">${hw.desc}</p>
      </div>
      <div style="display: flex; gap: 8px;">
        <button class="btn btn-sm btn-primary" onclick="showToast('Attachment downloaded', 'info')"><i class="fa-solid fa-paperclip"></i> Download PDF</button>
        <button class="btn btn-sm btn-secondary" onclick="showToast('Submissions view opened', 'info')"><i class="fa-solid fa-users"></i> 24 Submitted</button>
      </div>
    </div>
  `).join('');
}

// Exam Marks Table
function renderExamMarks() {
  const tbody = document.getElementById('examMarksBody');
  if (!tbody) return;

  const marks = [
    { roll: '10-A-01', name: 'Sophia Chen', math: 98, phys: 95, chem: 96, pct: '96.3%', grade: 'A+' },
    { roll: '10-A-02', name: 'Marcus Vance', math: 91, phys: 88, chem: 92, pct: '90.3%', grade: 'A' },
    { roll: '10-A-03', name: 'Aria Sharma', math: 85, phys: 89, chem: 84, pct: '86.0%', grade: 'B+' },
    { roll: '10-B-01', name: 'Liam Wilson', math: 74, phys: 78, chem: 80, pct: '77.3%', grade: 'B' },
    { roll: '09-A-01', name: 'Zoe Martinez', math: 94, phys: 96, chem: 91, pct: '93.6%', grade: 'A+' }
  ];

  tbody.innerHTML = marks.map(m => `
    <tr>
      <td><code>${m.roll}</code></td>
      <td><strong>${m.name}</strong></td>
      <td>${m.math} / 100</td>
      <td>${m.phys} / 100</td>
      <td>${m.chem} / 100</td>
      <td><strong>${m.pct}</strong></td>
      <td><span class="badge badge-success">${m.grade}</span></td>
      <td>
        <button class="btn btn-sm btn-secondary" onclick="showToast('Generating report card for ${m.name}', 'success')">
          <i class="fa-solid fa-print"></i> Report
        </button>
      </td>
    </tr>
  `).join('');
}

// Finance Tables
function renderFinanceTables() {
  const feeBody = document.getElementById('feesTableBody');
  if (feeBody) {
    const fees = [
      { id: 'INV-2026-881', student: 'Sophia Chen', class: 'Grade 10-A', term: 'Term 1 (2026)', total: '$1,450', paid: '$1,450', due: '2026-09-15', status: 'PAID' },
      { id: 'INV-2026-882', student: 'Aria Sharma', class: 'Grade 10-A', term: 'Term 1 (2026)', total: '$1,450', paid: '$750', due: '2026-09-15', status: 'PARTIAL' },
      { id: 'INV-2026-883', student: 'Liam Wilson', class: 'Grade 10-B', term: 'Term 1 (2026)', total: '$1,450', paid: '$0', due: '2026-09-10', status: 'PENDING' }
    ];
    feeBody.innerHTML = fees.map(f => `
      <tr>
        <td><code>${f.id}</code></td>
        <td><strong>${f.student}</strong></td>
        <td>${f.class}</td>
        <td>${f.term}</td>
        <td>${f.total}</td>
        <td><strong style="color:var(--success)">${f.paid}</strong></td>
        <td>${f.due}</td>
        <td><span class="badge ${f.status === 'PAID' ? 'badge-success' : (f.status === 'PARTIAL' ? 'badge-warning' : 'badge-danger')}">${f.status}</span></td>
        <td>
          <button class="btn btn-sm btn-primary" onclick="showToast('Simulated receipt issued for ${f.student}', 'success')">
            <i class="fa-solid fa-receipt"></i> Receipt
          </button>
        </td>
      </tr>
    `).join('');
  }

  const payrollBody = document.getElementById('payrollTableBody');
  if (payrollBody) {
    payrollBody.innerHTML = `
      <tr>
        <td><strong>Dr. Arthur Pendelton</strong></td>
        <td>Principal / Dean</td>
        <td>August 2026</td>
        <td>$5,200.00</td>
        <td>$320.00</td>
        <td><strong>$4,880.00</strong></td>
        <td><span class="badge badge-success">DISBURSED</span></td>
        <td><button class="btn btn-sm btn-secondary" onclick="showToast('Payslip printed', 'info')"><i class="fa-solid fa-file-pdf"></i></button></td>
      </tr>
      <tr>
        <td><strong>Ms. Clara Oswald</strong></td>
        <td>Senior Faculty</td>
        <td>August 2026</td>
        <td>$3,800.00</td>
        <td>$210.00</td>
        <td><strong>$3,590.00</strong></td>
        <td><span class="badge badge-success">DISBURSED</span></td>
        <td><button class="btn btn-sm btn-secondary" onclick="showToast('Payslip printed', 'info')"><i class="fa-solid fa-file-pdf"></i></button></td>
      </tr>
    `;
  }

  const expBody = document.getElementById('expensesTableBody');
  if (expBody) {
    expBody.innerHTML = `
      <tr>
        <td>2026-09-04</td>
        <td>Laboratory Supplies</td>
        <td>Chemistry & Physics glassware and titration reagents</td>
        <td><strong>$1,240.00</strong></td>
        <td>Dean Pendelton</td>
      </tr>
      <tr>
        <td>2026-09-02</td>
        <td>Fleet Maintenance</td>
        <td>Bus #04 brake pad replacement & diesel refill</td>
        <td><strong>$680.00</strong></td>
        <td>Transport Head</td>
      </tr>
    `;
  }

  const loanBody = document.getElementById('loansTableBody');
  if (loanBody) {
    loanBody.innerHTML = `
      <tr>
        <td><strong>Prof. Julian Bashir</strong></td>
        <td>$6,000.00</td>
        <td>$500.00 / mo</td>
        <td>12 Months</td>
        <td><span class="badge badge-success">ACTIVE (8/12 Paid)</span></td>
        <td><button class="btn btn-sm btn-secondary" onclick="showToast('Foreclosure simulated', 'info')">Foreclose</button></td>
      </tr>
    `;
  }

  document.querySelectorAll('.tab-btn').forEach(btn => {
    btn.addEventListener('click', () => {
      document.querySelectorAll('.tab-btn').forEach(b => b.classList.remove('active'));
      document.querySelectorAll('.subtab-content').forEach(c => c.classList.remove('active'));
      
      btn.classList.add('active');
      const target = btn.getAttribute('data-subtab');
      document.getElementById(`subtab-${target}`)?.classList.add('active');
    });
  });
}

// Notices & Events
function renderNotices() {
  const container = document.getElementById('noticesContainer');
  if (!container) return;

  container.innerHTML = state.notices.map(n => `
    <div class="card" style="margin-bottom: 16px;">
      <div class="card-header">
        <div class="card-title">
          <i class="fa-solid fa-bullhorn text-role"></i>
          <h3>${n.title}</h3>
        </div>
        <span class="badge badge-info">${n.audience}</span>
      </div>
      <div class="card-body">
        <p style="color:var(--text-secondary); margin-bottom: 14px;">${n.desc}</p>
        <div style="font-size:0.75rem; color:var(--text-muted); display:flex; justify-content:space-between;">
          <span><i class="fa-solid fa-user-pen"></i> By: ${n.author}</span>
          <span><i class="fa-solid fa-calendar"></i> ${n.date}</span>
        </div>
      </div>
    </div>
  `).join('');
}

// ==========================================================================
// LEAVES & APPROVALS ENTERPRISE CLIENT MODULE (ROYAL VIOLET ADMIN)
// ==========================================================================

// Initial realistic institutional staff and leave dataset
const DEFAULT_LEAVES_DATA = [
  {
    id: "LR-1024",
    applicant: "Mrs. Rebecca Sterling",
    applicantPhoto: "https://images.unsplash.com/photo-1544005313-94ddf0286df2?auto=format&fit=crop&w=120&h=120&q=80",
    employeeId: "EMP-1024",
    userId: "usr-sterling-1024",
    designation: "Senior Faculty • English",
    department: "Teaching",
    email: "r.sterling@stjude.edu",
    phone: "+1 555-0134",
    leaveType: "Sick Leave (SL)",
    startDate: "2026-09-07",
    endDate: "2026-09-09",
    formattedStartDate: "07 Sep 2026",
    formattedEndDate: "09 Sep 2026",
    days: 3,
    reason: "Viral fever and acute throat infection recuperation under doctor's advice.",
    appliedOn: "2026-09-05",
    formattedAppliedOn: "05 Sep 2026",
    status: "APPROVED",
    isEmergency: false,
    attachmentUrl: "Medical_Certificate_Sterling.pdf",
    rejectionReason: null,
    approverName: "Dr. Evelyn Vance",
    approvedAt: "06 Sep 2026",
  },
  {
    id: "LR-1025",
    applicant: "Mr. David Vance",
    applicantPhoto: "https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?auto=format&fit=crop&w=120&h=120&q=80",
    employeeId: "EMP-1025",
    userId: "usr-vance-1025",
    designation: "Fleet Transport Driver",
    department: "Transport",
    email: "d.vance@stjude.edu",
    phone: "+1 555-0188",
    leaveType: "Casual Leave (CL)",
    startDate: "2026-09-11",
    endDate: "2026-09-12",
    formattedStartDate: "11 Sep 2026",
    formattedEndDate: "12 Sep 2026",
    days: 2,
    reason: "Attending sister's marriage ceremony and family travel out of station.",
    appliedOn: "2026-09-06",
    formattedAppliedOn: "06 Sep 2026",
    status: "PENDING",
    isEmergency: false,
    attachmentUrl: null,
    rejectionReason: null,
    approverName: null,
  },
  {
    id: "LR-1026",
    applicant: "Ms. Helena Troy",
    applicantPhoto: "https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?auto=format&fit=crop&w=120&h=120&q=80",
    employeeId: "EMP-1026",
    userId: "usr-troy-1026",
    designation: "Head Lab Demonstrator",
    department: "Laboratory",
    email: "h.troy@stjude.edu",
    phone: "+1 555-0142",
    leaveType: "Earned Leave (EL)",
    startDate: "2026-09-15",
    endDate: "2026-09-18",
    formattedStartDate: "15 Sep 2026",
    formattedEndDate: "18 Sep 2026",
    days: 4,
    reason: "Appearing for University Masters Laboratory Accreditation examination.",
    appliedOn: "2026-09-06",
    formattedAppliedOn: "06 Sep 2026",
    status: "PENDING",
    isEmergency: false,
    attachmentUrl: "Exam_Hall_Ticket_Troy.pdf",
    rejectionReason: null,
    approverName: null,
  },
  {
    id: "LR-1027",
    applicant: "Prof. Julian Bashir",
    applicantPhoto: "https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=120&h=120&q=80",
    employeeId: "EMP-1027",
    userId: "usr-bashir-1027",
    designation: "Associate Professor • Physics",
    department: "Teaching",
    email: "j.bashir@stjude.edu",
    phone: "+1 555-0136",
    leaveType: "Emergency Leave",
    startDate: "2026-09-02",
    endDate: "2026-09-03",
    formattedStartDate: "02 Sep 2026",
    formattedEndDate: "03 Sep 2026",
    days: 2,
    reason: "Urgent home plumbing flooding crisis requiring immediate municipal presence.",
    appliedOn: "2026-09-02",
    formattedAppliedOn: "02 Sep 2026",
    status: "APPROVED",
    isEmergency: true,
    attachmentUrl: null,
    rejectionReason: null,
    approverName: "Dr. Arthur Pendelton",
    approvedAt: "02 Sep 2026",
  },
  {
    id: "LR-1028",
    applicant: "Mr. Arthur Pendelton",
    applicantPhoto: "/assets/principal_hero.jpg",
    employeeId: "EMP-1002",
    userId: "usr-pendelton-1002",
    designation: "Principal & Headmaster",
    department: "Administration",
    email: "principal@smartschool.edu",
    phone: "+1 555-0102",
    leaveType: "Casual Leave (CL)",
    startDate: "2026-09-22",
    endDate: "2026-09-23",
    formattedStartDate: "22 Sep 2026",
    formattedEndDate: "23 Sep 2026",
    days: 2,
    reason: "Attending National CBSE Deans Conference in New Delhi as regional panelist.",
    appliedOn: "2026-09-07",
    formattedAppliedOn: "07 Sep 2026",
    status: "PENDING",
    isEmergency: false,
    attachmentUrl: "Conference_Invitation_2026.pdf",
    rejectionReason: null,
    approverName: null,
  },
  {
    id: "LR-1029",
    applicant: "Ms. Clara Oswald",
    applicantPhoto: "/assets/teacher_hero.jpg",
    employeeId: "EMP-1029",
    userId: "usr-oswald-1029",
    designation: "Senior Mathematics Faculty",
    department: "Teaching",
    email: "clara.teacher@smartschool.edu",
    phone: "+1 555-0128",
    leaveType: "Permission / Short Leave",
    startDate: "2026-09-08",
    endDate: "2026-09-08",
    formattedStartDate: "08 Sep 2026",
    formattedEndDate: "08 Sep 2026",
    days: 1,
    reason: "Attending child's dental clinic appointment during afternoon free period.",
    appliedOn: "2026-09-08",
    formattedAppliedOn: "08 Sep 2026",
    status: "PENDING",
    isEmergency: false,
    attachmentUrl: null,
    rejectionReason: null,
    approverName: null,
  }
];

const DEFAULT_RECTIFICATIONS_DATA = [
  {
    id: "RECT-201",
    employee: "Prof. Julian Bashir",
    employeePhoto: "https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=120&h=120&q=80",
    employeeId: "EMP-1027",
    userId: "usr-bashir-1027",
    department: "Teaching",
    date: "2026-09-04",
    formattedDate: "04 Sep 2026",
    originalAttendance: "Absent (Missed Kiosk Check-in)",
    requestedAttendance: "Present (08:30 AM - 04:30 PM)",
    checkInTime: "08:30 AM",
    checkOutTime: "04:30 PM",
    reason: "Faculty shuttle bus arrived during AI kiosk software update; attended 4 lecture periods verified by HM.",
    submittedOn: "2026-09-05",
    formattedSubmittedOn: "05 Sep 2026",
    status: "PENDING",
    rejectionReason: null,
    approverName: null,
  },
  {
    id: "RECT-202",
    employee: "Mr. David Vance",
    employeePhoto: "https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?auto=format&fit=crop&w=120&h=120&q=80",
    employeeId: "EMP-1025",
    userId: "usr-vance-1025",
    department: "Transport",
    date: "2026-09-03",
    formattedDate: "03 Sep 2026",
    originalAttendance: "Late Punch (09:45 AM)",
    requestedAttendance: "On-Time Present (07:15 AM)",
    checkInTime: "07:15 AM",
    checkOutTime: "04:00 PM",
    reason: "Early student bus dispatch route 1 executed on time; phone biometric battery drained before gate sync.",
    submittedOn: "2026-09-04",
    formattedSubmittedOn: "04 Sep 2026",
    status: "APPROVED",
    rejectionReason: null,
    approverName: "Dr. Evelyn Vance",
    approvedAt: "04 Sep 2026",
  }
];

const DEFAULT_BALANCES_DATA = [
  {
    userId: "usr-oswald-1029",
    employee: "Ms. Clara Oswald",
    employeeId: "EMP-1029",
    employeePhoto: "/assets/teacher_hero.jpg",
    department: "Teaching",
    casualLeave: { allocated: 12, used: 2, remaining: 10 },
    sickLeave: { allocated: 10, used: 1, remaining: 9 },
    earnedLeave: { allocated: 15, used: 0, remaining: 15 },
    emergencyLeave: { allocated: 5, used: 0, remaining: 5 },
    totalUsed: 3,
    totalRemaining: 39,
  },
  {
    userId: "usr-sterling-1024",
    employee: "Mrs. Rebecca Sterling",
    employeeId: "EMP-1024",
    employeePhoto: "https://images.unsplash.com/photo-1544005313-94ddf0286df2?auto=format&fit=crop&w=120&h=120&q=80",
    department: "Teaching",
    casualLeave: { allocated: 12, used: 4, remaining: 8 },
    sickLeave: { allocated: 10, used: 3, remaining: 7 },
    earnedLeave: { allocated: 15, used: 2, remaining: 13 },
    emergencyLeave: { allocated: 5, used: 0, remaining: 5 },
    totalUsed: 9,
    totalRemaining: 33,
  },
  {
    userId: "usr-bashir-1027",
    employee: "Prof. Julian Bashir",
    employeeId: "EMP-1027",
    employeePhoto: "https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=120&h=120&q=80",
    department: "Teaching",
    casualLeave: { allocated: 12, used: 1, remaining: 11 },
    sickLeave: { allocated: 10, used: 0, remaining: 10 },
    earnedLeave: { allocated: 15, used: 3, remaining: 12 },
    emergencyLeave: { allocated: 5, used: 2, remaining: 3 },
    totalUsed: 6,
    totalRemaining: 36,
  },
  {
    userId: "usr-vance-1025",
    employee: "Mr. David Vance",
    employeeId: "EMP-1025",
    employeePhoto: "https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?auto=format&fit=crop&w=120&h=120&q=80",
    department: "Transport",
    casualLeave: { allocated: 12, used: 3, remaining: 9 },
    sickLeave: { allocated: 10, used: 2, remaining: 8 },
    earnedLeave: { allocated: 15, used: 0, remaining: 15 },
    emergencyLeave: { allocated: 5, used: 1, remaining: 4 },
    totalUsed: 6,
    totalRemaining: 36,
  },
  {
    userId: "usr-troy-1026",
    employee: "Ms. Helena Troy",
    employeeId: "EMP-1026",
    employeePhoto: "https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?auto=format&fit=crop&w=120&h=120&q=80",
    department: "Laboratory",
    casualLeave: { allocated: 12, used: 2, remaining: 10 },
    sickLeave: { allocated: 10, used: 1, remaining: 9 },
    earnedLeave: { allocated: 15, used: 0, remaining: 15 },
    emergencyLeave: { allocated: 5, used: 0, remaining: 5 },
    totalUsed: 3,
    totalRemaining: 39,
  },
  {
    userId: "usr-pendelton-1002",
    employee: "Dr. Arthur Pendelton",
    employeeId: "EMP-1002",
    employeePhoto: "/assets/principal_hero.jpg",
    department: "Administration",
    casualLeave: { allocated: 14, used: 2, remaining: 12 },
    sickLeave: { allocated: 12, used: 0, remaining: 12 },
    earnedLeave: { allocated: 20, used: 4, remaining: 16 },
    emergencyLeave: { allocated: 5, used: 0, remaining: 5 },
    totalUsed: 6,
    totalRemaining: 45,
  }
];

const DEFAULT_POLICIES_DATA = [
  {
    id: "POL-1",
    name: "Casual Leave (CL)",
    code: "CASUAL",
    maxDays: 12,
    maxConsecutiveDays: 3,
    minNoticePeriodDays: 2,
    carryForwardAllowed: false,
    maxCarryForwardDays: 0,
    requiresAttachment: false,
    description: "Granted for unforeseen personal matters, short family commitments, or urgent personal work."
  },
  {
    id: "POL-2",
    name: "Medical & Sick Leave (SL)",
    code: "SICK",
    maxDays: 10,
    maxConsecutiveDays: 5,
    minNoticePeriodDays: 0,
    carryForwardAllowed: false,
    maxCarryForwardDays: 0,
    requiresAttachment: true,
    description: "Granted on grounds of illness. Doctor certificate mandatory for leave exceeding 2 consecutive days."
  },
  {
    id: "POL-3",
    name: "Earned Vacation Leave (EL)",
    code: "EARNED",
    maxDays: 15,
    maxConsecutiveDays: 10,
    minNoticePeriodDays: 7,
    carryForwardAllowed: true,
    maxCarryForwardDays: 30,
    requiresAttachment: false,
    description: "Annual vacation entitlement accrued per tenure semester. Requires prior departmental schedule approval."
  },
  {
    id: "POL-4",
    name: "Emergency & Compassionate Leave",
    code: "EMERGENCY",
    maxDays: 5,
    maxConsecutiveDays: 3,
    minNoticePeriodDays: 0,
    carryForwardAllowed: false,
    maxCarryForwardDays: 0,
    requiresAttachment: false,
    description: "Immediate absence authorization for urgent family crises, accidents, or critical contingencies."
  },
  {
    id: "POL-5",
    name: "Maternity Statutory Leave",
    code: "MATERNITY",
    maxDays: 90,
    maxConsecutiveDays: 90,
    minNoticePeriodDays: 30,
    carryForwardAllowed: false,
    maxCarryForwardDays: 0,
    requiresAttachment: true,
    description: "Full statutory paid maternity benefit for eligible female academic and administrative employees."
  },
  {
    id: "POL-6",
    name: "Paternity Support Leave",
    code: "PATERNITY",
    maxDays: 10,
    maxConsecutiveDays: 10,
    minNoticePeriodDays: 14,
    carryForwardAllowed: false,
    maxCarryForwardDays: 0,
    requiresAttachment: true,
    description: "Statutory support leave for new fathers upon childbirth documentation."
  },
  {
    id: "POL-7",
    name: "Short Gate Pass / Permission",
    code: "PERMISSION",
    maxDays: 12,
    maxConsecutiveDays: 1,
    minNoticePeriodDays: 1,
    carryForwardAllowed: false,
    maxCarryForwardDays: 0,
    requiresAttachment: false,
    description: "Up to 2-hour official midday gate leave without daily salary deduction."
  }
];

// Helper: Format Date nicely
function formatClientDate(dateStr) {
  if (!dateStr) return '';
  const d = new Date(dateStr + (dateStr.length === 10 ? 'T00:00:00.000Z' : ''));
  if (isNaN(d.getTime())) return dateStr;
  const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  return `${String(d.getUTCDate()).padStart(2, '0')} ${months[d.getUTCMonth()]} ${d.getUTCFullYear()}`;
}

// 1. Initialize Leaves Module
async function initLeavesModule() {
  state.leavesState.leaveRequests = [...DEFAULT_LEAVES_DATA];
  state.leavesState.rectifications = [...DEFAULT_RECTIFICATIONS_DATA];
  state.leavesState.balances = [...DEFAULT_BALANCES_DATA];
  state.leavesState.policies = [...DEFAULT_POLICIES_DATA];

  await fetchLeavesData();
  applyLeavesFilters();
  renderLeaveRectificationsTable();
  renderLeaveBalancesTable();
  renderLeavePoliciesGrid();
  populateApplicantDropdown();
}

// 2. Refresh Data from Server
async function refreshLeavesData() {
  const icon = document.getElementById('refreshIconLeaves');
  if (icon) icon.classList.add('fa-spin');

  await fetchLeavesData();
  applyLeavesFilters();
  renderLeaveRectificationsTable();
  renderLeaveBalancesTable();
  renderLeavePoliciesGrid();

  setTimeout(() => {
    if (icon) icon.classList.remove('fa-spin');
    showToast('Leaves and attendance data refreshed', 'success');
  }, 400);
}

// 3. Fetch from Server with graceful fallback
async function fetchLeavesData() {
  try {
    const res = await fetch('/api/leaves');
    if (res.ok) {
      const data = await res.json();
      if (Array.isArray(data) && data.length > 0) {
        state.leavesState.leaveRequests = data;
      }
    }
  } catch (e) {
    // Keep mock data
  }

  try {
    const rectRes = await fetch('/api/attendance-rectifications');
    if (rectRes.ok) {
      const data = await rectRes.json();
      if (Array.isArray(data) && data.length > 0) {
        state.leavesState.rectifications = data;
      }
    }
  } catch (e) {}

  try {
    const balRes = await fetch('/api/leave-balances');
    if (balRes.ok) {
      const data = await balRes.json();
      if (Array.isArray(data) && data.length > 0) {
        state.leavesState.balances = data;
      }
    }
  } catch (e) {}

  try {
    const polRes = await fetch('/api/leave-policies');
    if (polRes.ok) {
      const data = await polRes.json();
      if (Array.isArray(data) && data.length > 0) {
        state.leavesState.policies = data;
      }
    }
  } catch (e) {}
}

// 4. Tab Switching
function switchLeavesTab(tabName) {
  state.leavesState.activeSubTab = tabName;

  document.querySelectorAll('.leaves-tab-btn').forEach(btn => btn.classList.remove('active'));
  document.querySelectorAll('.leaves-tab-panel').forEach(p => p.classList.remove('active'));

  const toolbar = document.getElementById('leavesFilterToolbar');

  if (tabName === 'requests') {
    document.getElementById('tabBtnLeaveRequests')?.classList.add('active');
    document.getElementById('panelLeaveRequests')?.classList.add('active');
    if (toolbar) toolbar.style.display = 'flex';
  } else if (tabName === 'rectifications') {
    document.getElementById('tabBtnRectifications')?.classList.add('active');
    document.getElementById('panelRectifications')?.classList.add('active');
    if (toolbar) toolbar.style.display = 'none';
  } else if (tabName === 'balances') {
    document.getElementById('tabBtnLeaveBalances')?.classList.add('active');
    document.getElementById('panelLeaveBalances')?.classList.add('active');
    if (toolbar) toolbar.style.display = 'none';
  } else if (tabName === 'policies') {
    document.getElementById('tabBtnLeavePolicies')?.classList.add('active');
    document.getElementById('panelLeavePolicies')?.classList.add('active');
    if (toolbar) toolbar.style.display = 'none';
  }
}

// 5. Update Summary Cards & Badges
function updateLeaveSummaryCards() {
  const allReqs = state.leavesState.leaveRequests || [];
  const allRects = state.leavesState.rectifications || [];

  const pendingCount = allReqs.filter(l => l.status === 'PENDING').length;
  const approvedCount = allReqs.filter(l => l.status === 'APPROVED').length;
  const rejectedCount = allReqs.filter(l => l.status === 'REJECTED').length;
  const rectPendingCount = allRects.filter(r => r.status === 'PENDING').length;

  const statPending = document.getElementById('statPendingLeaves');
  const statApproved = document.getElementById('statApprovedLeaves');
  const statRejected = document.getElementById('statRejectedLeaves');
  const statRect = document.getElementById('statPendingRectifications');
  const tabBadgeReq = document.getElementById('tabBadgeRequests');
  const tabBadgeRect = document.getElementById('tabBadgeRectifications');

  if (statPending) statPending.textContent = pendingCount;
  if (statApproved) statApproved.textContent = approvedCount;
  if (statRejected) statRejected.textContent = rejectedCount;
  if (statRect) statRect.textContent = rectPendingCount;
  if (tabBadgeReq) tabBadgeReq.textContent = pendingCount;
  if (tabBadgeRect) tabBadgeRect.textContent = rectPendingCount;
}

// 6. Search & Filter Handlers
function handleLeavesSearchInput() {
  const input = document.getElementById('leavesSearchInput');
  const clearBtn = document.getElementById('btnClearLeavesSearch');
  state.leavesState.searchQuery = input.value.trim().toLowerCase();

  if (clearBtn) {
    clearBtn.style.display = state.leavesState.searchQuery ? 'block' : 'none';
  }
  applyLeavesFilters();
}

function clearLeavesSearch() {
  const input = document.getElementById('leavesSearchInput');
  const clearBtn = document.getElementById('btnClearLeavesSearch');
  if (input) input.value = '';
  if (clearBtn) clearBtn.style.display = 'none';
  state.leavesState.searchQuery = '';
  applyLeavesFilters();
}

function setLeaveStatusFilter(status) {
  switchTab('leaves');
  switchLeavesTab('requests');
  const select = document.getElementById('filterLeaveStatus');
  if (select) select.value = status;
  applyLeavesFilters();
  if (status === 'PENDING') {
    showToast('Filtered to Pending Leave Requests awaiting Super Admin review', 'info');
  }
}

function handleDateFilterChange() {
  const val = document.getElementById('filterLeaveDate')?.value;
  const box = document.getElementById('customDateRangeBox');
  if (box) {
    box.style.display = val === 'CUSTOM' ? 'flex' : 'none';
  }
  applyLeavesFilters();
}

function resetLeavesFilters() {
  const statusSel = document.getElementById('filterLeaveStatus');
  const typeSel = document.getElementById('filterLeaveType');
  const deptSel = document.getElementById('filterLeaveDept');
  const dateSel = document.getElementById('filterLeaveDate');
  const customBox = document.getElementById('customDateRangeBox');

  if (statusSel) statusSel.value = 'ALL';
  if (typeSel) typeSel.value = 'ALL';
  if (deptSel) deptSel.value = 'ALL';
  if (dateSel) dateSel.value = 'ALL';
  if (customBox) customBox.style.display = 'none';

  clearLeavesSearch();
  applyLeavesFilters();
  showToast('All leave filters have been reset', 'info');
}

function applyLeavesFilters() {
  const statusVal = document.getElementById('filterLeaveStatus')?.value || 'ALL';
  const typeVal = document.getElementById('filterLeaveType')?.value || 'ALL';
  const deptVal = document.getElementById('filterLeaveDept')?.value || 'ALL';
  const dateVal = document.getElementById('filterLeaveDate')?.value || 'ALL';
  const query = state.leavesState.searchQuery || '';

  let filtered = [...state.leavesState.leaveRequests];

  // 1. Status Filter
  if (statusVal !== 'ALL') {
    filtered = filtered.filter(l => l.status === statusVal);
  }

  // 2. Type Filter
  if (typeVal !== 'ALL') {
    filtered = filtered.filter(l => {
      const t = (l.leaveType || '').toUpperCase();
      if (typeVal === 'CASUAL') return t.includes('CASUAL') || t.includes('(CL)');
      if (typeVal === 'SICK') return t.includes('SICK') || t.includes('MEDICAL') || t.includes('(SL)');
      if (typeVal === 'EARNED') return t.includes('EARNED') || t.includes('(EL)');
      if (typeVal === 'EMERGENCY') return t.includes('EMERGENCY');
      if (typeVal === 'MATERNITY') return t.includes('MATERNITY');
      if (typeVal === 'PATERNITY') return t.includes('PATERNITY');
      if (typeVal === 'PERMISSION') return t.includes('PERMISSION');
      if (typeVal === 'OTHER') return t.includes('OTHER');
      return true;
    });
  }

  // 3. Department Filter
  if (deptVal !== 'ALL') {
    filtered = filtered.filter(l => (l.department || '').toLowerCase().includes(deptVal.toLowerCase()));
  }

  // 4. Date Filter
  const now = new Date();
  const todayStr = now.toISOString().split('T')[0];
  if (dateVal === 'TODAY') {
    filtered = filtered.filter(l => l.startDate <= todayStr && l.endDate >= todayStr);
  } else if (dateVal === 'THIS_WEEK') {
    const firstDay = new Date(now.setDate(now.getDate() - now.getDay()));
    const lastDay = new Date(firstDay);
    lastDay.setDate(lastDay.getDate() + 6);
    const fStr = firstDay.toISOString().split('T')[0];
    const lStr = lastDay.toISOString().split('T')[0];
    filtered = filtered.filter(l => l.startDate <= lStr && l.endDate >= fStr);
  } else if (dateVal === 'THIS_MONTH') {
    const curYearMonth = todayStr.substring(0, 7);
    filtered = filtered.filter(l => l.startDate.startsWith(curYearMonth) || l.endDate.startsWith(curYearMonth));
  } else if (dateVal === 'CUSTOM') {
    const cStart = document.getElementById('filterCustomStartDate')?.value;
    const cEnd = document.getElementById('filterCustomEndDate')?.value;
    if (cStart && cEnd) {
      filtered = filtered.filter(l => l.startDate <= cEnd && l.endDate >= cStart);
    }
  }

  // 5. Search query
  if (query) {
    filtered = filtered.filter(l =>
      (l.applicant || '').toLowerCase().includes(query) ||
      (l.employeeId || '').toLowerCase().includes(query) ||
      (l.department || '').toLowerCase().includes(query) ||
      (l.leaveType || '').toLowerCase().includes(query) ||
      (l.reason || '').toLowerCase().includes(query)
    );
  }

  state.leavesState.filteredRequests = filtered;
  renderLeaveRequestsTable();
  updateLeaveSummaryCards();

  const countSubtitle = document.getElementById('tableLeavesCountSubtitle');
  if (countSubtitle) {
    countSubtitle.textContent = `Showing ${filtered.length} of ${state.leavesState.leaveRequests.length} leave records`;
  }
  const badge = document.getElementById('activeFilterBadge');
  if (badge) {
    badge.textContent = `Filter: ${statusVal !== 'ALL' ? statusVal : 'All'} • ${filtered.length} records`;
  }
}

// Helper: Get Dynamic Logged-in Super Admin Approver
function getActiveApprover() {
  const currentRole = state.currentRole || 'CORRESPONDENT';
  const persona = PERSONA_CONFIG[currentRole] || PERSONA_CONFIG.CORRESPONDENT;
  return {
    id: state.currentUser?.id || (currentRole === 'CORRESPONDENT' ? 'usr-admin-01' : (currentRole === 'PRINCIPAL' ? 'usr-principal-01' : 'usr-staff-01')),
    name: state.currentUser?.fullName || persona.name,
    role: currentRole,
    title: persona.title || 'Super Admin / Director',
    email: state.currentUser?.email || persona.email
  };
}

// 7. Render Leave Requests Table
function renderLeaveRequestsTable() {
  const tbody = document.getElementById('leavesTableBody');
  const emptyState = document.getElementById('leavesEmptyState');
  const dataTable = document.getElementById('leavesDataTable');
  if (!tbody) return;

  const records = state.leavesState.filteredRequests;

  if (records.length === 0) {
    tbody.innerHTML = '';
    if (emptyState) emptyState.style.display = 'block';
    if (dataTable) dataTable.style.display = 'none';
    return;
  }

  if (emptyState) emptyState.style.display = 'none';
  if (dataTable) dataTable.style.display = 'table';

  tbody.innerHTML = records.map((l) => {
    let statusBadgeClass = 'badge-warning';
    let statusIcon = '<i class="fa-solid fa-hourglass-half"></i>';
    if (l.status === 'APPROVED') {
      statusBadgeClass = 'badge-success';
      statusIcon = '<i class="fa-solid fa-circle-check"></i>';
    } else if (l.status === 'REJECTED') {
      statusBadgeClass = 'badge-danger';
      statusIcon = '<i class="fa-solid fa-circle-xmark"></i>';
    } else if (l.status === 'CANCELLED') {
      statusBadgeClass = 'badge-secondary';
      statusIcon = '<i class="fa-solid fa-ban"></i>';
    }

    let leaveTypeBadgeClass = 'badge-info';
    if (l.leaveType.includes('Sick') || l.leaveType.includes('SL')) leaveTypeBadgeClass = 'badge-warning';
    else if (l.leaveType.includes('Earned') || l.leaveType.includes('EL')) leaveTypeBadgeClass = 'badge-role';
    else if (l.leaveType.includes('Emergency')) leaveTypeBadgeClass = 'badge-danger';

    const isPending = l.status === 'PENDING';

    return `
      <tr class="leave-row-${l.id}">
        <td>
          <div class="applicant-cell">
            <img src="${l.applicantPhoto || '/assets/teacher_hero.jpg'}" alt="${l.applicant}" class="applicant-cell-avatar">
            <div class="applicant-cell-details">
              <span class="applicant-name">${l.applicant}</span>
              <span class="applicant-designation">${l.designation || 'Staff Faculty'}</span>
            </div>
          </div>
        </td>
        <td><code>${l.employeeId || 'EMP-1000'}</code></td>
        <td><span class="dept-tag">${l.department || 'Teaching'}</span></td>
        <td>
          <span class="badge ${leaveTypeBadgeClass}">
            ${l.isEmergency ? '<i class="fa-solid fa-bolt text-amber"></i> ' : ''}${l.leaveType}
          </span>
        </td>
        <td><strong>${l.formattedStartDate || formatClientDate(l.startDate)}</strong></td>
        <td><strong>${l.formattedEndDate || formatClientDate(l.endDate)}</strong></td>
        <td>
          <span class="badge badge-secondary" style="font-weight:700;">
            ${l.days} Day${l.days > 1 ? 's' : ''}
          </span>
        </td>
        <td>
          <span class="reason-cell-preview" title="${l.reason}">${l.reason}</span>
        </td>
        <td><span style="font-size:0.76rem; color:var(--text-muted); white-space:nowrap;">${l.formattedAppliedOn || formatClientDate(l.appliedOn)}</span></td>
        <td>
          <span class="badge ${statusBadgeClass}">
            ${statusIcon} ${l.status}
          </span>
        </td>
        <td class="col-action" style="text-align:center; white-space:nowrap;">
          <div class="actions-buttons-wrap">
            <button class="btn btn-sm btn-action-view" onclick="openReviewLeaveModal('${l.id}')" title="View Leave Request Details">
              <i class="fa-solid fa-eye"></i> View
            </button>
            ${isPending ? `
              <button class="btn btn-sm btn-action-approve" onclick="openApproveModal('${l.id}')" title="Approve Request">
                <i class="fa-solid fa-check"></i> Approve
              </button>
              <button class="btn btn-sm btn-action-reject" onclick="openRejectModal('${l.id}')" title="Reject Request">
                <i class="fa-solid fa-xmark"></i> Reject
              </button>
            ` : ''}
            <button class="btn btn-sm btn-action-more" onclick="openEmployeeHistoryModal('${l.userId}', '${l.applicant}')" title="More Leave History">
              <i class="fa-solid fa-ellipsis"></i> More
            </button>
          </div>
        </td>
      </tr>
    `;
  }).join('');
}

// 8. Render Attendance Rectifications Table
function renderLeaveRectificationsTable() {
  const tbody = document.getElementById('rectificationsTableBody');
  const emptyState = document.getElementById('rectificationsEmptyState');
  const dataTable = document.getElementById('rectificationsDataTable');
  if (!tbody) return;

  const rects = state.leavesState.rectifications;

  if (rects.length === 0) {
    tbody.innerHTML = '';
    if (emptyState) emptyState.style.display = 'block';
    if (dataTable) dataTable.style.display = 'none';
    return;
  }

  if (emptyState) emptyState.style.display = 'none';
  if (dataTable) dataTable.style.display = 'table';

  tbody.innerHTML = rects.map(r => {
    let badgeClass = 'badge-warning';
    if (r.status === 'APPROVED') badgeClass = 'badge-success';
    else if (r.status === 'REJECTED') badgeClass = 'badge-danger';

    return `
      <tr>
        <td>
          <div class="applicant-cell">
            <img src="${r.employeePhoto || '/assets/teacher_hero.jpg'}" alt="${r.employee}" class="applicant-cell-avatar">
            <div class="applicant-cell-details">
              <span class="applicant-name">${r.employee}</span>
              <span class="applicant-designation">${r.department || 'Teaching'}</span>
            </div>
          </div>
        </td>
        <td><code>${r.employeeId || 'EMP-1000'}</code></td>
        <td><strong>${r.formattedDate || formatClientDate(r.date)}</strong></td>
        <td>
          <span class="badge badge-danger" title="${r.originalAttendance}">
            <i class="fa-solid fa-clock-rotate-left"></i> ${r.originalAttendance}
          </span>
        </td>
        <td>
          <span class="badge badge-success" title="${r.requestedAttendance}">
            <i class="fa-solid fa-circle-check"></i> ${r.requestedAttendance}
          </span>
        </td>
        <td><span class="reason-cell-preview" title="${r.reason}">${r.reason}</span></td>
        <td><span style="font-size:0.76rem; color:var(--text-muted); white-space:nowrap;">${r.formattedSubmittedOn || formatClientDate(r.submittedOn)}</span></td>
        <td><span class="badge ${badgeClass}">${r.status}</span></td>
        <td style="text-align:right; white-space:nowrap;">
          <div style="display:inline-flex; gap:6px; align-items:center;">
            <button class="btn btn-sm btn-secondary" onclick="openRectificationReviewModal('${r.id}')" title="Review Punch Claim">
              <i class="fa-solid fa-eye"></i> View
            </button>
            ${r.status === 'PENDING' ? `
              <button class="btn btn-sm btn-success" onclick="quickApproveRectification('${r.id}')" title="Approve Punch">
                <i class="fa-solid fa-check"></i> Approve
              </button>
            ` : ''}
          </div>
        </td>
      </tr>
    `;
  }).join('');
}

// 9. Render Leave Balances Table
function renderLeaveBalancesTable() {
  const tbody = document.getElementById('leaveBalancesTableBody');
  if (!tbody) return;

  tbody.innerHTML = state.leavesState.balances.map(b => `
    <tr>
      <td>
        <div class="applicant-cell">
          <img src="${b.employeePhoto || '/assets/teacher_hero.jpg'}" alt="${b.employee}" class="applicant-cell-avatar">
          <div class="applicant-cell-details">
            <span class="applicant-name">${b.employee}</span>
            <span class="applicant-designation">${b.department || 'Teaching'}</span>
          </div>
        </div>
      </td>
      <td><code>${b.employeeId}</code></td>
      <td><span class="dept-tag">${b.department}</span></td>
      <td>
        <span class="quota-pill" title="${b.casualLeave.used} used / ${b.casualLeave.allocated} total">
          <strong class="text-role">${b.casualLeave.remaining}</strong> <span style="font-size:0.7rem; color:var(--text-muted);">/ ${b.casualLeave.allocated}</span>
        </span>
      </td>
      <td>
        <span class="quota-pill" title="${b.sickLeave.used} used / ${b.sickLeave.allocated} total">
          <strong class="text-amber">${b.sickLeave.remaining}</strong> <span style="font-size:0.7rem; color:var(--text-muted);">/ ${b.sickLeave.allocated}</span>
        </span>
      </td>
      <td>
        <span class="quota-pill" title="${b.earnedLeave.used} used / ${b.earnedLeave.allocated} total">
          <strong class="text-emerald">${b.earnedLeave.remaining}</strong> <span style="font-size:0.7rem; color:var(--text-muted);">/ ${b.earnedLeave.allocated}</span>
        </span>
      </td>
      <td>
        <span class="quota-pill" title="${b.emergencyLeave.used} used / ${b.emergencyLeave.allocated} total">
          <strong class="text-rose">${b.emergencyLeave.remaining}</strong> <span style="font-size:0.7rem; color:var(--text-muted);">/ ${b.emergencyLeave.allocated}</span>
        </span>
      </td>
      <td><span class="badge badge-warning" style="font-weight:700;">${b.totalUsed} Days</span></td>
      <td><span class="badge badge-success" style="font-weight:700;">${b.totalRemaining} Days</span></td>
      <td style="text-align:right; white-space:nowrap;">
        <div style="display:inline-flex; gap:6px; align-items:center;">
          <button class="btn btn-sm btn-primary" onclick="openAdjustBalanceModal('${b.userId}', '${b.employee}')" title="Adjust Quota">
            <i class="fa-solid fa-sliders"></i> Adjust
          </button>
          <button class="btn btn-sm btn-secondary" onclick="openEmployeeHistoryModal('${b.userId}', '${b.employee}')" title="View Full History">
            <i class="fa-solid fa-clock-rotate-left"></i> History
          </button>
        </div>
      </td>
    </tr>
  `).join('');
}

function filterBalanceTable() {
  const q = (document.getElementById('balanceSearchInput')?.value || '').toLowerCase().trim();
  const rows = document.querySelectorAll('#leaveBalancesTableBody tr');
  rows.forEach(r => {
    const text = r.textContent.toLowerCase();
    r.style.display = text.includes(q) ? '' : 'none';
  });
}

// 10. Render Leave Policies Grid
function renderLeavePoliciesGrid() {
  const container = document.getElementById('leavePoliciesContainer');
  if (!container) return;

  container.innerHTML = state.leavesState.policies.map(p => `
    <div class="policy-card">
      <div class="policy-card-top">
        <h4 class="policy-name">${p.name}</h4>
        <span class="policy-code-pill">${p.code}</span>
      </div>

      <div class="policy-meta-grid">
        <div class="policy-meta-item">
          <span>Annual Quota</span>
          <strong class="text-role">${p.maxDays} Days</strong>
        </div>
        <div class="policy-meta-item">
          <span>Max Consecutive</span>
          <strong>${p.maxConsecutiveDays || 5} Days</strong>
        </div>
        <div class="policy-meta-item">
          <span>Notice Period</span>
          <strong>${p.minNoticePeriodDays || 0} Days</strong>
        </div>
        <div class="policy-meta-item">
          <span>Carry Forward</span>
          <strong>${p.carryForwardAllowed ? `Yes (${p.maxCarryForwardDays}d)` : 'No'}</strong>
        </div>
      </div>

      <p class="policy-desc">${p.description || 'Statutory school leave entitlement rules.'}</p>

      <div class="policy-card-actions">
        <span class="badge ${p.requiresAttachment ? 'badge-warning' : 'badge-secondary'}" style="margin-right:auto;">
          ${p.requiresAttachment ? '<i class="fa-solid fa-paperclip"></i> Certificate Required' : 'No Certificate'}
        </span>
        <button class="btn btn-sm btn-secondary" onclick="openEditPolicyModal('${p.id}')">
          <i class="fa-solid fa-pen-to-square"></i> Edit
        </button>
        <button class="btn btn-sm btn-icon" onclick="deletePolicy('${p.id}')" title="Delete Policy">
          <i class="fa-solid fa-trash text-rose"></i>
        </button>
      </div>
    </div>
  `).join('');
}

// 11. Populate Employee Selector in Apply Modal
function populateApplicantDropdown() {
  const select = document.getElementById('applyLeaveEmployeeSelect');
  if (!select) return;

  const users = [
    { id: 'usr-oswald-1029', name: 'Ms. Clara Oswald (Senior Faculty • Mathematics)' },
    { id: 'usr-sterling-1024', name: 'Mrs. Rebecca Sterling (Senior Faculty • English)' },
    { id: 'usr-bashir-1027', name: 'Prof. Julian Bashir (Associate Professor • Physics)' },
    { id: 'usr-vance-1025', name: 'Mr. David Vance (Fleet Driver • Transport)' },
    { id: 'usr-troy-1026', name: 'Ms. Helena Troy (Lab Demonstrator • Science)' },
    { id: 'usr-pendelton-1002', name: 'Dr. Arthur Pendelton (Principal & Headmaster)' }
  ];

  select.innerHTML = users.map(u => `<option value="${u.id}">${u.name}</option>`).join('');
}

// 12. Apply Modal Calculation and Logic
function openApplyLeaveModal() {
  const startInput = document.getElementById('applyLeaveStartDate');
  const endInput = document.getElementById('applyLeaveEndDate');
  const today = new Date().toISOString().split('T')[0];

  if (startInput) {
    startInput.value = today;
    startInput.min = '2020-01-01';
    startInput.max = '2035-12-31';
  }
  if (endInput) {
    endInput.value = today;
    endInput.min = '2020-01-01';
    endInput.max = '2035-12-31';
  }

  const errAlert = document.getElementById('applyLeaveErrorAlert');
  if (errAlert) errAlert.style.display = 'none';

  calculateApplyLeaveDays();
  openModal('applyLeaveModal');
}

function handleApplicantChange() {
  calculateApplyLeaveDays();
}

function handleLeaveTypeChange() {
  calculateApplyLeaveDays();
}

function calculateApplyLeaveDays() {
  const startStr = document.getElementById('applyLeaveStartDate')?.value;
  const endStr = document.getElementById('applyLeaveEndDate')?.value;
  const badge = document.getElementById('calcTotalDaysBadge');
  const balBadge = document.getElementById('calcAvailableBalanceBadge');
  const errAlert = document.getElementById('applyLeaveErrorAlert');

  if (errAlert) errAlert.style.display = 'none';

  if (!startStr || !endStr) {
    if (badge) badge.textContent = '0 Days';
    return;
  }

  // Validate YYYY-MM-DD
  const regex = /^\d{4}-\d{2}-\d{2}$/;
  if (!regex.test(startStr) || !regex.test(endStr)) {
    if (badge) badge.textContent = 'Invalid Date';
    return;
  }

  const startYear = parseInt(startStr.split('-')[0], 10);
  const endYear = parseInt(endStr.split('-')[0], 10);
  if (startYear < 2020 || startYear > 2035 || endYear < 2020 || endYear > 2035) {
    if (badge) badge.textContent = 'Year out of range (2020-2035)';
    return;
  }

  const s = new Date(startStr + 'T00:00:00.000Z');
  const e = new Date(endStr + 'T00:00:00.000Z');
  const diffTime = e.getTime() - s.getTime();

  if (diffTime < 0) {
    if (badge) badge.textContent = 'Invalid Range (End < Start)';
    return;
  }

  const days = Math.floor(diffTime / (1000 * 60 * 60 * 24)) + 1;
  if (badge) badge.textContent = `${days} Day${days > 1 ? 's' : ''}`;

  // Find balance for selected user & type
  const userId = document.getElementById('applyLeaveEmployeeSelect')?.value;
  const typeStr = document.getElementById('applyLeaveTypeSelect')?.value || '';
  const empBal = state.leavesState.balances.find(b => b.userId === userId);

  let remaining = 12.0;
  if (empBal) {
    if (typeStr.includes('Sick')) remaining = empBal.sickLeave.remaining;
    else if (typeStr.includes('Earned')) remaining = empBal.earnedLeave.remaining;
    else if (typeStr.includes('Emergency')) remaining = empBal.emergencyLeave.remaining;
    else remaining = empBal.casualLeave.remaining;
  }

  if (balBadge) {
    balBadge.textContent = `${remaining} Days`;
    balBadge.className = remaining >= days ? 'calc-value text-emerald' : 'calc-value text-rose';
  }
}

function handleAttachmentFileChange(e) {
  const label = document.getElementById('fileUploadLabelText');
  if (e.target.files && e.target.files[0]) {
    label.innerHTML = `<i class="fa-solid fa-circle-check text-emerald"></i> <span>Selected: <strong>${e.target.files[0].name}</strong></span>`;
  }
}

async function handleApplyLeaveSubmit(e) {
  e.preventDefault();
  const userId = document.getElementById('applyLeaveEmployeeSelect').value;
  const leaveType = document.getElementById('applyLeaveTypeSelect').value;
  const startDate = document.getElementById('applyLeaveStartDate').value;
  const endDate = document.getElementById('applyLeaveEndDate').value;
  const reason = document.getElementById('applyLeaveReason').value.trim();
  const isEmergency = document.getElementById('applyLeaveIsEmergency').checked;
  const overrideBalance = document.getElementById('applyLeaveOverrideBalance').checked;
  const errAlert = document.getElementById('applyLeaveErrorAlert');

  // Strict Validations
  if (!startDate || !endDate || !reason) {
    if (errAlert) {
      errAlert.textContent = 'Please fill out all required fields.';
      errAlert.style.display = 'block';
    }
    return;
  }

  const startYear = parseInt(startDate.split('-')[0], 10);
  const endYear = parseInt(endDate.split('-')[0], 10);
  if (startYear < 2020 || startYear > 2035 || endYear < 2020 || endYear > 2035) {
    if (errAlert) {
      errAlert.textContent = 'Invalid date range: Year must be between 2020 and 2035.';
      errAlert.style.display = 'block';
    }
    return;
  }

  if (startDate > endDate) {
    if (errAlert) {
      errAlert.textContent = 'End date cannot be prior to start date.';
      errAlert.style.display = 'block';
    }
    return;
  }

  const s = new Date(startDate + 'T00:00:00.000Z');
  const eDate = new Date(endDate + 'T00:00:00.000Z');
  const days = Math.floor((eDate.getTime() - s.getTime()) / (1000 * 60 * 60 * 24)) + 1;

  // Overlap verification
  const duplicate = state.leavesState.leaveRequests.find(l =>
    l.userId === userId &&
    l.status !== 'REJECTED' &&
    l.status !== 'CANCELLED' &&
    l.startDate <= endDate &&
    l.endDate >= startDate
  );

  if (duplicate) {
    if (errAlert) {
      errAlert.textContent = `Overlap Conflict: Employee already has an active request (${duplicate.status}) on ${formatClientDate(duplicate.startDate)} - ${formatClientDate(duplicate.endDate)}.`;
      errAlert.style.display = 'block';
    }
    return;
  }

  // Balance Check
  const empBal = state.leavesState.balances.find(b => b.userId === userId);
  if (empBal && !overrideBalance && !isEmergency) {
    let rem = empBal.casualLeave.remaining;
    if (leaveType.includes('Sick')) rem = empBal.sickLeave.remaining;
    else if (leaveType.includes('Earned')) rem = empBal.earnedLeave.remaining;
    else if (leaveType.includes('Emergency')) rem = empBal.emergencyLeave.remaining;

    if (days > rem) {
      if (errAlert) {
        errAlert.textContent = `Insufficient balance. Request requires ${days} days, but only ${rem} days remaining. Enable Super Admin Override to proceed.`;
        errAlert.style.display = 'block';
      }
      return;
    }
  }

  const empSelect = document.getElementById('applyLeaveEmployeeSelect');
  const applicantName = empSelect.options[empSelect.selectedIndex].text.split('(')[0].trim();

  // Try API
  try {
    const res = await fetch('/api/leaves', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        userId,
        leaveType,
        startDate,
        endDate,
        reason,
        isEmergency,
        overrideBalance
      })
    });
    if (!res.ok) {
      const errJson = await res.json();
      throw new Error(errJson.error || 'Server rejected application');
    }
  } catch (apiErr) {
    // Continue with local update
  }

  const newId = `LR-${Math.floor(1000 + Math.random() * 9000)}`;
  const newRecord = {
    id: newId,
    applicant: applicantName,
    applicantPhoto: '/assets/teacher_hero.jpg',
    employeeId: `EMP-${userId.slice(-4).toUpperCase()}`,
    userId,
    designation: 'Faculty Member',
    department: 'Teaching',
    email: `${applicantName.toLowerCase().replace(/\s+/g, '.')}@stjude.edu`,
    phone: '+1 555-0199',
    leaveType,
    startDate,
    endDate,
    formattedStartDate: formatClientDate(startDate),
    formattedEndDate: formatClientDate(endDate),
    days,
    reason,
    appliedOn: new Date().toISOString().split('T')[0],
    formattedAppliedOn: formatClientDate(new Date().toISOString().split('T')[0]),
    status: 'PENDING',
    isEmergency,
    attachmentUrl: null,
    rejectionReason: null,
    approverName: null,
  };

  state.leavesState.leaveRequests.unshift(newRecord);
  closeModal('applyLeaveModal');
  e.target.reset();
  applyLeavesFilters();
  showToast(`✨ Leave application ${newId} for ${applicantName} submitted successfully`, 'success');
}

// 13. Review Modal Display (Leave Request Details)
function openReviewLeaveModal(leaveId) {
  const leave = state.leavesState.leaveRequests.find(l => l.id === leaveId);
  if (!leave) return;

  state.leavesState.selectedLeave = leave;

  document.getElementById('reviewModalSubtitle').textContent = `Ref: ${leave.id} • ${leave.department || 'Academic'} Department`;
  document.getElementById('reviewApplicantPhoto').src = leave.applicantPhoto || '/assets/teacher_hero.jpg';
  document.getElementById('reviewApplicantName').textContent = leave.applicant;
  document.getElementById('reviewApplicantRole').textContent = leave.designation || 'Staff Faculty';
  document.getElementById('reviewApplicantEmpId').textContent = `ID: ${leave.employeeId || 'EMP-1000'}`;
  document.getElementById('reviewApplicantDept').textContent = leave.department || 'Teaching';
  document.getElementById('reviewApplicantEmail').textContent = leave.email || `${leave.applicant.toLowerCase().replace(/\s+/g, '.')}@stjude.edu`;
  document.getElementById('reviewApplicantPhone').textContent = leave.phone || '+1 555-0100';

  const appliedDateEl = document.getElementById('reviewAppliedDate');
  if (appliedDateEl) {
    appliedDateEl.textContent = leave.formattedAppliedOn || formatClientDate(leave.appliedOn);
  }

  // Balance Quota preview
  const empBal = state.leavesState.balances.find(b => b.userId === leave.userId || b.employee === leave.applicant);
  document.getElementById('reviewApplicantQuota').textContent = empBal ? `${empBal.totalRemaining} Days Remaining` : 'Quota Available';

  // Leave Details
  document.getElementById('reviewLeaveType').textContent = leave.leaveType;
  document.getElementById('reviewLeaveDays').textContent = `${leave.days} Day${leave.days > 1 ? 's' : ''}`;
  document.getElementById('reviewStartDate').textContent = leave.formattedStartDate || formatClientDate(leave.startDate);
  document.getElementById('reviewEndDate').textContent = leave.formattedEndDate || formatClientDate(leave.endDate);
  document.getElementById('reviewReasonText').textContent = leave.reason;

  const statusBadge = document.getElementById('reviewStatusBadge');
  if (statusBadge) {
    statusBadge.textContent = leave.status;
    statusBadge.className = `badge ${leave.status === 'APPROVED' ? 'badge-success' : (leave.status === 'PENDING' ? 'badge-warning' : 'badge-danger')}`;
  }

  // Previous Employee Leave History snippet
  const historyContainer = document.getElementById('reviewEmpHistoryList');
  if (historyContainer) {
    const pastLeaves = state.leavesState.leaveRequests.filter(l => (l.userId === leave.userId || l.applicant === leave.applicant) && l.id !== leave.id);
    if (pastLeaves.length > 0) {
      historyContainer.innerHTML = pastLeaves.slice(0, 3).map(p => `
        <div style="display: flex; justify-content: space-between; align-items: center; padding: 4px 8px; background: rgba(255,255,255,0.03); border-radius: var(--radius-sm); border: 1px solid var(--border-color);">
          <span><strong>${p.leaveType}</strong> (${p.days}d) • ${p.formattedStartDate || formatClientDate(p.startDate)}</span>
          <span class="badge ${p.status === 'APPROVED' ? 'badge-success' : (p.status === 'PENDING' ? 'badge-warning' : 'badge-danger')}" style="font-size:0.68rem;">${p.status}</span>
        </div>
      `).join('');
    } else {
      historyContainer.innerHTML = '<span style="color:var(--text-muted); font-size:0.75rem;">No prior leave requests recorded for this academic year.</span>';
    }
  }

  // Attachments
  const attSection = document.getElementById('reviewAttachmentSection');
  const attFileName = document.getElementById('attachmentFileName');
  if (leave.attachmentUrl) {
    if (attSection) attSection.style.display = 'block';
    if (attFileName) attFileName.textContent = leave.attachmentUrl;
  } else {
    if (attSection) attSection.style.display = 'none';
  }

  // Rejection Reason Box
  const rejBox = document.getElementById('reviewRejectionHistoryBox');
  const rejText = document.getElementById('reviewRejectionHistoryText');
  if (leave.status === 'REJECTED' && leave.rejectionReason) {
    if (rejBox) rejBox.style.display = 'block';
    if (rejText) rejText.textContent = `${leave.rejectionReason} (Declined by ${leave.approverName || 'Super Admin'} on ${leave.rejectedAt || 'Recent'})`;
  } else {
    if (rejBox) rejBox.style.display = 'none';
  }

  // Approval Info Box
  const appBox = document.getElementById('reviewApprovalInfoBox');
  const appText = document.getElementById('reviewApprovalInfoText');
  if (leave.status === 'APPROVED') {
    if (appBox) appBox.style.display = 'block';
    if (appText) appText.textContent = `Approved by ${leave.approverName || 'Super Admin'} on ${leave.approvedAt || 'Recent'}. Quota deducted and attendance record synchronized.`;
  } else {
    if (appBox) appBox.style.display = 'none';
  }

  // Action Buttons visibility (Only show Approve/Reject buttons for PENDING requests!)
  const actionsGroup = document.getElementById('reviewActionsGroup');
  if (actionsGroup) {
    actionsGroup.style.display = leave.status === 'PENDING' ? 'flex' : 'none';
  }

  openModal('reviewLeaveModal');
}

// 14. Approve Confirmation & Execution
function openApproveFromReview() {
  if (!state.leavesState.selectedLeave) return;
  openApproveModal(state.leavesState.selectedLeave.id);
}

function openApproveModal(leaveId) {
  const leave = state.leavesState.leaveRequests.find(l => l.id === leaveId);
  if (!leave) return;

  state.leavesState.selectedLeave = leave;

  document.getElementById('approveConfirmApplicant').textContent = leave.applicant;
  document.getElementById('approveConfirmLeaveType').textContent = leave.leaveType;
  document.getElementById('approveConfirmStartDate').textContent = leave.formattedStartDate || formatClientDate(leave.startDate);
  document.getElementById('approveConfirmEndDate').textContent = leave.formattedEndDate || formatClientDate(leave.endDate);
  document.getElementById('approveConfirmDays').textContent = `${leave.days} Day${leave.days > 1 ? 's' : ''}`;

  openModal('approveConfirmModal');
}

async function executeApproveLeave() {
  const leave = state.leavesState.selectedLeave;
  if (!leave) return;

  // Prevent duplicate approval
  if (leave.status === 'APPROVED') {
    showToast('This leave request is already approved.', 'warning');
    closeModal('approveConfirmModal');
    return;
  }

  const approver = getActiveApprover();

  try {
    const token = localStorage.getItem('token') || state.token;
    const headers = { 'Content-Type': 'application/json' };
    if (token) headers['Authorization'] = `Bearer ${token}`;

    const res = await fetch(`/api/leaves/${leave.id}/approve`, {
      method: 'POST',
      headers
    });
    if (res.ok) {
      const data = await res.json();
      if (data.leave?.approvedAt) {
        leave.approvedAt = formatClientDate(data.leave.approvedAt);
      }
    }
  } catch (e) {
    console.warn('[APPROVE_API_FALLBACK]: Operating in local reactive store mode');
  }

  // Update record state dynamically
  leave.status = 'APPROVED';
  leave.approverName = `${approver.name} (${approver.title})`;
  leave.approvedById = approver.id;
  leave.approvedAt = leave.approvedAt || formatClientDate(new Date().toISOString().split('T')[0]);
  leave.rejectionReason = null;

  // Deduct employee leave balance
  const empBal = state.leavesState.balances.find(b => b.userId === leave.userId || b.employee === leave.applicant);
  if (empBal) {
    if (leave.leaveType.includes('Sick') || leave.leaveType.includes('SL')) {
      empBal.sickLeave.used += leave.days;
      empBal.sickLeave.remaining = Math.max(0, empBal.sickLeave.remaining - leave.days);
    } else if (leave.leaveType.includes('Earned') || leave.leaveType.includes('EL')) {
      empBal.earnedLeave.used += leave.days;
      empBal.earnedLeave.remaining = Math.max(0, empBal.earnedLeave.remaining - leave.days);
    } else if (leave.leaveType.includes('Emergency')) {
      empBal.emergencyLeave.used += leave.days;
      empBal.emergencyLeave.remaining = Math.max(0, empBal.emergencyLeave.remaining - leave.days);
    } else {
      empBal.casualLeave.used += leave.days;
      empBal.casualLeave.remaining = Math.max(0, empBal.casualLeave.remaining - leave.days);
    }
    empBal.totalUsed += leave.days;
    empBal.totalRemaining = Math.max(0, empBal.totalRemaining - leave.days);
  }

  closeModal('approveConfirmModal');
  closeModal('reviewLeaveModal');

  applyLeavesFilters();
  renderLeaveBalancesTable();
  updateLeaveSummaryCards();
  showToast('Leave request approved successfully.', 'success');
}

// 15. Reject Reason & Execution
function openRejectFromReview() {
  if (!state.leavesState.selectedLeave) return;
  openRejectModal(state.leavesState.selectedLeave.id);
}

function openRejectModal(leaveId) {
  const leave = state.leavesState.leaveRequests.find(l => l.id === leaveId);
  if (!leave) return;

  state.leavesState.selectedLeave = leave;
  const applicantEl = document.getElementById('rejectConfirmApplicant');
  const typeEl = document.getElementById('rejectConfirmLeaveType');
  const input = document.getElementById('rejectionReasonInput');

  if (applicantEl) applicantEl.textContent = leave.applicant;
  if (typeEl) typeEl.textContent = leave.leaveType;
  if (input) input.value = '';

  openModal('rejectReasonModal');
}

async function executeRejectLeave(e) {
  if (e) e.preventDefault();
  const leave = state.leavesState.selectedLeave;
  const reasonInput = document.getElementById('rejectionReasonInput');
  const reason = (reasonInput?.value || '').trim();

  if (!leave) return;

  if (!reason || reason.length < 5) {
    showToast('Please provide a valid reason for rejection (at least 5 characters).', 'error');
    reasonInput?.focus();
    return;
  }

  const approver = getActiveApprover();

  try {
    const token = localStorage.getItem('token') || state.token;
    const headers = { 'Content-Type': 'application/json' };
    if (token) headers['Authorization'] = `Bearer ${token}`;

    await fetch(`/api/leaves/${leave.id}/reject`, {
      method: 'POST',
      headers,
      body: JSON.stringify({ rejectionReason: reason })
    });
  } catch (err) {
    console.warn('[REJECT_API_FALLBACK]: Operating in local reactive store mode');
  }

  leave.status = 'REJECTED';
  leave.rejectionReason = reason;
  leave.approverName = `${approver.name} (${approver.title})`;
  leave.rejectedById = approver.id;
  leave.rejectedAt = formatClientDate(new Date().toISOString().split('T')[0]);

  closeModal('rejectReasonModal');
  closeModal('reviewLeaveModal');

  applyLeavesFilters();
  updateLeaveSummaryCards();
  showToast('Leave request rejected successfully.', 'info');
}

// 16. Rectification Modals & Workflow
function openRectificationReviewModal(rectId) {
  const rect = state.leavesState.rectifications.find(r => r.id === rectId);
  if (!rect) return;

  state.leavesState.selectedRectification = rect;

  document.getElementById('rectReviewEmployee').textContent = rect.employee;
  document.getElementById('rectReviewDate').textContent = rect.formattedDate || formatClientDate(rect.date);
  document.getElementById('rectReviewOriginal').textContent = rect.originalAttendance;
  document.getElementById('rectReviewRequested').textContent = rect.requestedAttendance;
  document.getElementById('rectReviewReason').textContent = rect.reason;

  const rejBox = document.getElementById('rectRejectionReasonBox');
  if (rejBox) rejBox.style.display = 'none';

  const footer = document.getElementById('rectificationActionsFooter');
  if (footer) {
    footer.style.display = rect.status === 'PENDING' ? 'flex' : 'none';
  }

  openModal('rectificationReviewModal');
}

function toggleRectRejectBox() {
  const box = document.getElementById('rectRejectionReasonBox');
  const input = document.getElementById('rectRejectionReasonInput');
  if (box && box.style.display === 'none') {
    box.style.display = 'block';
    input?.focus();
  } else {
    executeRejectRectification();
  }
}

async function quickApproveRectification(rectId) {
  const rect = state.leavesState.rectifications.find(r => r.id === rectId);
  if (!rect) return;
  state.leavesState.selectedRectification = rect;
  executeApproveRectification();
}

async function executeApproveRectification() {
  const rect = state.leavesState.selectedRectification;
  if (!rect) return;

  try {
    await fetch(`/api/attendance-rectifications/${rect.id}/approve`, { method: 'POST' });
  } catch (e) {}

  rect.status = 'APPROVED';
  rect.approverName = 'Dr. Evelyn Vance (Super Admin)';
  rect.approvedAt = formatClientDate(new Date().toISOString().split('T')[0]);

  closeModal('rectificationReviewModal');
  renderLeaveRectificationsTable();
  updateLeaveSummaryCards();
  showToast(`✅ Approved attendance punch rectification for ${rect.employee}`, 'success');
}

async function executeRejectRectification() {
  const rect = state.leavesState.selectedRectification;
  const reason = (document.getElementById('rectRejectionReasonInput')?.value || '').trim() || 'Claim unverified by supervisor';

  if (!rect) return;

  try {
    await fetch(`/api/attendance-rectifications/${rect.id}/reject`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ rejectionReason: reason })
    });
  } catch (e) {}

  rect.status = 'REJECTED';
  rect.rejectionReason = reason;

  closeModal('rectificationReviewModal');
  renderLeaveRectificationsTable();
  updateLeaveSummaryCards();
  showToast(`❌ Attendance rectification rejected for ${rect.employee}`, 'info');
}

// 17. Adjust Leave Balance Workflow
function openAdjustBalanceModal(userId, empName) {
  document.getElementById('adjustBalanceEmployeeName').value = empName;
  document.getElementById('adjustBalanceUserId').value = userId;
  document.getElementById('adjustBalanceDays').value = '1.0';
  document.getElementById('adjustBalanceReason').value = '';

  openModal('adjustBalanceModal');
}

async function handleAdjustBalanceSubmit(e) {
  e.preventDefault();
  const userId = document.getElementById('adjustBalanceUserId').value;
  const empName = document.getElementById('adjustBalanceEmployeeName').value;
  const leaveTypeCode = document.getElementById('adjustBalanceLeaveType').value;
  const actionType = document.getElementById('adjustBalanceActionType').value;
  const days = parseFloat(document.getElementById('adjustBalanceDays').value);
  const reason = document.getElementById('adjustBalanceReason').value.trim();

  if (isNaN(days) || days <= 0 || !reason) {
    showToast('Please specify a positive day duration and mandatory reason.', 'error');
    return;
  }

  try {
    await fetch(`/api/leave-balances/${userId}/adjust`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ leaveTypeCode, adjustmentType: actionType, days, reason })
    });
  } catch (err) {}

  const empBal = state.leavesState.balances.find(b => b.userId === userId || b.employee === empName);
  if (empBal) {
    const delta = actionType === 'CREDIT' ? days : -days;
    if (leaveTypeCode === 'SICK') {
      empBal.sickLeave.remaining = Math.max(0, empBal.sickLeave.remaining + delta);
    } else if (leaveTypeCode === 'EARNED') {
      empBal.earnedLeave.remaining = Math.max(0, empBal.earnedLeave.remaining + delta);
    } else if (leaveTypeCode === 'EMERGENCY') {
      empBal.emergencyLeave.remaining = Math.max(0, empBal.emergencyLeave.remaining + delta);
    } else {
      empBal.casualLeave.remaining = Math.max(0, empBal.casualLeave.remaining + delta);
    }
    empBal.totalRemaining = Math.max(0, empBal.totalRemaining + delta);
  }

  closeModal('adjustBalanceModal');
  renderLeaveBalancesTable();
  showToast(`✨ ${actionType === 'CREDIT' ? 'Added' : 'Deducted'} ${days} ${leaveTypeCode} days for ${empName}`, 'success');
}

// 18. Leave Policy CRUD Modals
function openCreatePolicyModal() {
  document.getElementById('policyModalTitle').textContent = 'Add Institutional Leave Policy';
  document.getElementById('policyEditId').value = '';
  document.getElementById('policyNameInput').value = '';
  document.getElementById('policyCodeInput').value = '';
  document.getElementById('policyAnnualDays').value = '12';
  document.getElementById('policyMaxConsecutive').value = '5';
  document.getElementById('policyNoticeDays').value = '2';
  document.getElementById('policyCarryForwardDays').value = '0';
  document.getElementById('policyCarryForwardAllowed').checked = false;
  document.getElementById('policyRequiresAttachment').checked = false;
  document.getElementById('policyDescription').value = '';

  openModal('leavePolicyModal');
}

function openEditPolicyModal(policyId) {
  const policy = state.leavesState.policies.find(p => p.id === policyId);
  if (!policy) return;

  document.getElementById('policyModalTitle').textContent = `Edit Policy • ${policy.name}`;
  document.getElementById('policyEditId').value = policy.id;
  document.getElementById('policyNameInput').value = policy.name;
  document.getElementById('policyCodeInput').value = policy.code;
  document.getElementById('policyAnnualDays').value = policy.maxDays;
  document.getElementById('policyMaxConsecutive').value = policy.maxConsecutiveDays || 5;
  document.getElementById('policyNoticeDays').value = policy.minNoticePeriodDays || 2;
  document.getElementById('policyCarryForwardDays').value = policy.maxCarryForwardDays || 0;
  document.getElementById('policyCarryForwardAllowed').checked = Boolean(policy.carryForwardAllowed);
  document.getElementById('policyRequiresAttachment').checked = Boolean(policy.requiresAttachment);
  document.getElementById('policyDescription').value = policy.description || '';

  openModal('leavePolicyModal');
}

async function handlePolicyFormSubmit(e) {
  e.preventDefault();
  const editId = document.getElementById('policyEditId').value;
  const name = document.getElementById('policyNameInput').value.trim();
  const code = document.getElementById('policyCodeInput').value.trim().toUpperCase();
  const maxDays = parseInt(document.getElementById('policyAnnualDays').value, 10);
  const maxConsecutiveDays = parseInt(document.getElementById('policyMaxConsecutive').value, 10);
  const minNoticePeriodDays = parseInt(document.getElementById('policyNoticeDays').value, 10);
  const maxCarryForwardDays = parseInt(document.getElementById('policyCarryForwardDays').value, 10);
  const carryForwardAllowed = document.getElementById('policyCarryForwardAllowed').checked;
  const requiresAttachment = document.getElementById('policyRequiresAttachment').checked;
  const description = document.getElementById('policyDescription').value.trim();

  const payload = {
    name,
    code,
    annualAllocation: maxDays,
    maxDays,
    maxConsecutiveDays,
    minNoticePeriodDays,
    carryForwardAllowed,
    maxCarryForwardDays,
    requiresAttachment,
    description
  };

  if (editId) {
    try {
      await fetch(`/api/leave-policies/${editId}`, {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(payload)
      });
    } catch (e) {}

    const p = state.leavesState.policies.find(item => item.id === editId);
    if (p) Object.assign(p, payload);
    showToast(`Updated policy "${name}"`, 'success');
  } else {
    const newId = `POL-${Math.floor(100 + Math.random() * 900)}`;
    try {
      await fetch('/api/leave-policies', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(payload)
      });
    } catch (e) {}

    state.leavesState.policies.push({ id: newId, ...payload });
    showToast(`Created new leave policy "${name}"`, 'success');
  }

  closeModal('leavePolicyModal');
  renderLeavePoliciesGrid();
}

async function deletePolicy(policyId) {
  if (!confirm('Are you sure you want to delete this leave policy?')) return;
  try {
    await fetch(`/api/leave-policies/${policyId}`, { method: 'DELETE' });
  } catch (e) {}

  state.leavesState.policies = state.leavesState.policies.filter(p => p.id !== policyId);
  renderLeavePoliciesGrid();
  showToast('Leave policy deleted', 'info');
}

// 19. Employee History Modal Display
function openEmployeeHistoryModal(userId, empName) {
  const reqs = state.leavesState.leaveRequests.filter(l => l.userId === userId || l.applicant === empName);
  const rects = state.leavesState.rectifications.filter(r => r.userId === userId || r.employee === empName);
  const bal = state.leavesState.balances.find(b => b.userId === userId || b.employee === empName);

  document.getElementById('historyModalEmpName').textContent = `Leave History & Audit Trail: ${empName}`;

  const container = document.getElementById('historyModalContent');
  if (!container) return;

  container.innerHTML = `
    <div class="history-profile-summary">
      <img src="${bal?.employeePhoto || '/assets/teacher_hero.jpg'}" alt="${empName}" class="history-avatar">
      <div>
        <h4 style="color:var(--text-primary); margin-bottom:2px;">${empName}</h4>
        <div style="font-size:0.8rem; color:var(--text-secondary);">
          Department: <strong>${bal?.department || 'Teaching'}</strong> • Available Quota: <strong class="text-emerald">${bal?.totalRemaining || 36} Days</strong>
        </div>
      </div>
    </div>

    <div>
      <h4 style="font-size:0.95rem; color:var(--text-primary); margin-bottom:10px;"><i class="fa-solid fa-list-check text-role"></i> Leave Requests History (${reqs.length})</h4>
      ${reqs.length === 0 ? '<p style="color:var(--text-muted); font-size:0.82rem;">No previous leave requests on file.</p>' : `
        <div class="timeline-list">
          ${reqs.map(r => `
            <div class="timeline-item">
              <div class="timeline-dot" style="background:${r.status === 'APPROVED' ? 'var(--success)' : (r.status === 'REJECTED' ? 'var(--danger)' : 'var(--warning)')}"></div>
              <div class="timeline-header">
                <strong>${r.leaveType} (${r.days} Day${r.days > 1 ? 's' : ''})</strong>
                <span class="badge ${r.status === 'APPROVED' ? 'badge-success' : (r.status === 'REJECTED' ? 'badge-danger' : 'badge-warning')}">${r.status}</span>
              </div>
              <div class="timeline-desc">
                Dates: ${r.formattedStartDate || formatClientDate(r.startDate)} to ${r.formattedEndDate || formatClientDate(r.endDate)}<br>
                Reason: <em>"${r.reason}"</em><br>
                ${r.rejectionReason ? `<span class="text-rose">Rejection Reason: ${r.rejectionReason}</span><br>` : ''}
                <span style="font-size:0.7rem; color:var(--text-muted);">Applied on ${r.formattedAppliedOn || formatClientDate(r.appliedOn)} ${r.approverName ? `• Reviewed by ${r.approverName}` : ''}</span>
              </div>
            </div>
          `).join('')}
        </div>
      `}
    </div>

    ${rects.length > 0 ? `
      <div>
        <h4 style="font-size:0.95rem; color:var(--text-primary); margin-bottom:10px;"><i class="fa-solid fa-user-clock text-indigo"></i> Attendance Rectifications (${rects.length})</h4>
        <div class="timeline-list">
          ${rects.map(r => `
            <div class="timeline-item">
              <div class="timeline-dot" style="background:var(--info);"></div>
              <div class="timeline-header">
                <strong>Punch Date: ${r.formattedDate || formatClientDate(r.date)}</strong>
                <span class="badge ${r.status === 'APPROVED' ? 'badge-success' : 'badge-warning'}">${r.status}</span>
              </div>
              <div class="timeline-desc">
                ${r.originalAttendance} &rarr; <strong>${r.requestedAttendance}</strong><br>
                Reason: "${r.reason}"
              </div>
            </div>
          `).join('')}
        </div>
      </div>
    ` : ''}
  `;

  openModal('employeeHistoryModal');
}


// AI Face Attendance Scanner Simulation
function initFaceScannerEvents() {
  const btnStart = document.getElementById('btnStartCamera');
  const btnStop = document.getElementById('btnStopCamera');
  const btnSim = document.getElementById('btnSimulateScan');
  const video = document.getElementById('webcamVideo');
  const placeholder = document.getElementById('cameraPlaceholder');
  const overlay = document.getElementById('faceOverlay');

  btnStart?.addEventListener('click', async () => {
    try {
      state.webcamStream = await navigator.mediaDevices.getUserMedia({ video: true });
      if (video) {
        video.srcObject = state.webcamStream;
        video.style.display = 'block';
        placeholder.style.display = 'none';
        overlay.classList.add('active');
        showToast('Webcam active • Ready for AI face alignment', 'info');
      }
    } catch (err) {
      showToast('Webcam access unavailable. Running AI simulation mode.', 'warning');
      simulateAIMatch();
    }
  });

  btnStop?.addEventListener('click', () => {
    if (state.webcamStream) {
      state.webcamStream.getTracks().forEach(track => track.stop());
      state.webcamStream = null;
    }
    if (video) video.style.display = 'none';
    if (placeholder) placeholder.style.display = 'flex';
    if (overlay) overlay.classList.remove('active');
  });

  btnSim?.addEventListener('click', () => {
    simulateAIMatch();
  });
}

let scanCandidateIdx = 0;
const SCAN_CANDIDATES = [
  { name: 'Sophia Chen', role: 'Student • Grade 10-A (Roll: 10-A-01)', avatar: '/assets/student_girl.jpg', score: '99.8%', geofence: 'Valid (Academic Wing Entrance)' },
  { name: 'Marcus Vance', role: 'Student • Grade 10-A (Roll: 10-A-02)', avatar: '/assets/student_boy.jpg', score: '99.5%', geofence: 'Valid (Science Block Gate)' },
  { name: 'Ms. Clara Oswald', role: 'Faculty • Senior Mathematics', avatar: '/assets/teacher_hero.jpg', score: '99.4%', geofence: 'Valid (Main Campus Hub)' },
  { name: 'Dr. Arthur Pendelton', role: 'Administration • Principal', avatar: '/assets/principal_hero.jpg', score: '99.9%', geofence: 'Valid (Executive Admin Wing)' }
];

function simulateAIMatch() {
  const overlay = document.getElementById('faceOverlay');
  const label = document.getElementById('detectionLabel');
  if (overlay) overlay.classList.add('active');
  if (label) label.textContent = 'Biometric Laser Scanning in progress...';

  setTimeout(() => {
    const candidate = SCAN_CANDIDATES[scanCandidateIdx % SCAN_CANDIDATES.length];
    scanCandidateIdx++;

    if (label) label.innerHTML = `<i class="fa-solid fa-circle-check"></i> ${candidate.name} Matched (${candidate.score})`;
    const profileBox = document.getElementById('matchedProfileBox');
    const matchedAvatar = document.getElementById('matchedAvatar');
    const matchedName = document.getElementById('matchedName');
    const matchedRole = document.getElementById('matchedRole');
    const matchedTime = document.getElementById('matchedTime');

    if (profileBox && matchedAvatar) {
      profileBox.style.display = 'flex';
      matchedAvatar.src = candidate.avatar;
      matchedName.textContent = candidate.name;
      matchedRole.textContent = candidate.role;
      const now = new Date().toLocaleTimeString();
      matchedTime.textContent = now;

      const newScan = {
        name: candidate.name,
        role: candidate.role.split('•')[0].trim(),
        time: now,
        score: candidate.score,
        geofence: candidate.geofence
      };
      prependScan(newScan);
      showToast(`✨ Biometric check-in recorded for ${candidate.name}`, 'success');
    }
  }, 1100);
}

function prependScan(scan) {
  const container = document.getElementById('recentScansList');
  if (!container) return;

  const item = document.createElement('div');
  item.className = 'scan-item';
  item.innerHTML = `
    <div>
      <strong>${scan.name}</strong>
      <div style="font-size:0.75rem; color:var(--text-muted)">${scan.role} • ${scan.geofence}</div>
    </div>
    <div style="text-align:right;">
      <span class="badge badge-success">${scan.score}</span>
      <div style="font-size:0.7rem; color:var(--text-muted); margin-top:2px;">${scan.time}</div>
    </div>
  `;
  container.prepend(item);
}

function renderRecentScans() {
  const scans = [
    { name: 'Dr. Arthur Pendelton', role: 'Principal', time: '08:05:12 AM', score: '99.8%', geofence: 'Valid' },
    { name: 'Prof. Julian Bashir', role: 'Faculty', time: '08:12:44 AM', score: '98.9%', geofence: 'Valid' }
  ];
  scans.forEach(s => prependScan(s));
}

// Live Bus Route Simulation
function startBusSimulation() {
  const bus1 = document.getElementById('busMarker1');
  const bus2 = document.getElementById('busMarker2');
  let angle = 0;

  if (state.busInterval) clearInterval(state.busInterval);

  state.busInterval = setInterval(() => {
    if (!state.isBusSimulating) return;
    angle += 0.05;
    
    const x1 = 50 + 35 * Math.cos(angle);
    const y1 = 45 + 30 * Math.sin(angle);
    if (bus1) {
      bus1.style.left = `${x1}%`;
      bus1.style.top = `${y1}%`;
    }

    const x2 = 50 + 38 * Math.cos(-angle * 0.8 + 2);
    const y2 = 45 + 28 * Math.sin(-angle * 0.8 + 2);
    if (bus2) {
      bus2.style.left = `${x2}%`;
      bus2.style.top = `${y2}%`;
    }
  }, 1000);

  document.getElementById('btnToggleSimBus')?.addEventListener('click', (e) => {
    state.isBusSimulating = !state.isBusSimulating;
    const btn = e.currentTarget;
    btn.innerHTML = state.isBusSimulating 
      ? '<i class="fa-solid fa-pause"></i> Pause Bus Movement' 
      : '<i class="fa-solid fa-play"></i> Resume Bus Movement';
    showToast(state.isBusSimulating ? 'Live bus simulation resumed' : 'Live bus simulation paused', 'info');
  });
}

function renderRouteDetails() {
  const container = document.getElementById('routeDetailsList');
  if (!container) return;

  container.innerHTML = `
    <div class="scan-item" style="margin-bottom: 12px;">
      <div>
        <strong>Route 1: North Valley & Tech Park</strong>
        <div style="font-size:0.75rem; color:var(--text-muted); margin-top:2px;">
          Bus: #04 • Driver: Marcus Sterling (+1 555-0188)<br>
          Next Stop: Green Valley Crossing (ETA: 4 mins)
        </div>
      </div>
      <span class="badge badge-success">38 km/h</span>
    </div>
    <div class="scan-item">
      <div>
        <strong>Route 2: Central Metro Express</strong>
        <div style="font-size:0.75rem; color:var(--text-muted); margin-top:2px;">
          Bus: #09 • Driver: Liam Brody (+1 555-0189)<br>
          Next Stop: Grand Central Station (ETA: 7 mins)
        </div>
      </div>
      <span class="badge badge-info">42 km/h</span>
    </div>
  `;
}

// Chart.js Visualization Dynamic Colors per Role
function updateChartForRole(role) {
  const ctx = document.getElementById('attendanceChart')?.getContext('2d');
  if (!ctx) return;

  let primaryColor = '#6366f1';
  let primaryBg = 'rgba(99, 102, 241, 0.15)';
  let secondaryColor = '#10b981';

  if (role === 'PRINCIPAL') {
    primaryColor = '#06b6d4';
    primaryBg = 'rgba(6, 182, 212, 0.15)';
    secondaryColor = '#10b981';
  } else if (role === 'TEACHER') {
    primaryColor = '#f59e0b';
    primaryBg = 'rgba(245, 158, 11, 0.15)';
    secondaryColor = '#f97316';
  } else if (role === 'PARENT') {
    primaryColor = '#f43f5e';
    primaryBg = 'rgba(244, 63, 94, 0.15)';
    secondaryColor = '#8b5cf6';
  }

  if (state.chartInstance) {
    state.chartInstance.destroy();
  }

  state.chartInstance = new Chart(ctx, {
    type: 'line',
    data: {
      labels: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'],
      datasets: [
        {
          label: role === 'PARENT' ? 'Sophia Chen Attendance (%)' : (role === 'TEACHER' ? 'Class 10-A Attendance (%)' : 'Student Body (%)'),
          data: [96.4, 98.1, 95.7, 97.2, 94.8, 98.9],
          borderColor: primaryColor,
          backgroundColor: primaryBg,
          fill: true,
          tension: 0.4,
          borderWidth: 3
        },
        {
          label: role === 'PARENT' ? 'Class Average (%)' : 'Faculty & Staff (%)',
          data: [98.0, 97.5, 99.0, 96.8, 97.0, 98.5],
          borderColor: secondaryColor,
          backgroundColor: 'transparent',
          borderDash: [5, 5],
          tension: 0.4,
          borderWidth: 2
        }
      ]
    },
    options: {
      responsive: true,
      maintainAspectRatio: false,
      plugins: {
        legend: {
          labels: { color: '#94a3b8', font: { family: 'Inter' } }
        }
      },
      scales: {
        x: {
          grid: { color: 'rgba(255,255,255,0.05)' },
          ticks: { color: '#94a3b8' }
        },
        y: {
          min: 80,
          max: 100,
          grid: { color: 'rgba(255,255,255,0.05)' },
          ticks: { color: '#94a3b8' }
        }
      }
    }
  });
}

// Server Health Polling & Backend Connectivity
async function startServerHealthPolling() {
  const dot = document.getElementById('serverStatusDot');
  const text = document.getElementById('serverStatusText');

  async function check() {
    try {
      const res = await fetch('/health');
      if (res.ok) {
        state.serverOnline = true;
        if (dot) dot.className = 'status-dot online';
        if (text) text.textContent = 'Backend Live (Port 5000)';
      } else {
        throw new Error('Server returned non-200');
      }
    } catch (err) {
      state.serverOnline = false;
      if (dot) dot.className = 'status-dot';
      if (text) text.textContent = 'Backend Offline';
    }
  }

  check();
  setInterval(check, 10000);
}

// Modal Handlers
function openModal(modalId) {
  document.getElementById(modalId)?.classList.add('active');
}

function closeModal(modalId) {
  document.getElementById(modalId)?.classList.remove('active');
}

// Modal Form Submissions
function handleCreateStudent(e) {
  e.preventDefault();
  const name = document.getElementById('newStudentName').value;
  const roll = document.getElementById('newStudentRoll').value;
  const cls = document.getElementById('newStudentClass').value;
  const sec = document.getElementById('newStudentSection').value;
  const parent = document.getElementById('newStudentParent').value || 'Parent';
  const phone = document.getElementById('newStudentPhone').value || '+1 555-0100';

  state.students.unshift({
    roll, name, class: cls, section: sec, parent, phone, attendance: '100%', feeStatus: 'PENDING'
  });

  renderStudentsTable();
  closeModal('addStudentModal');
  showToast(`Enrolled student ${name} successfully`, 'success');
  e.target.reset();
}

function handleCreateNotice(e) {
  e.preventDefault();
  const title = document.getElementById('newNoticeTitle').value;
  const audience = document.getElementById('newNoticeAudience').value;
  const desc = document.getElementById('newNoticeContent').value;

  state.notices.unshift({
    title, audience, date: 'Today', author: 'Principal Office', desc
  });

  renderNotices();
  closeModal('addNoticeModal');
  showToast('Announcement published across school channels', 'success');
  e.target.reset();
}

function handleApplyLeave(e) {
  e.preventDefault();
  const type = document.getElementById('leaveTypeSelect').value;
  const start = document.getElementById('leaveStartDate').value;
  const end = document.getElementById('leaveEndDate').value;
  const reason = document.getElementById('leaveReason').value;

  state.leaves.unshift({
    applicant: state.currentRole === 'PARENT' ? 'David Chen (Parent)' : 'Ms. Clara Oswald',
    type,
    start,
    end,
    reason,
    status: 'PENDING'
  });

  renderLeaves();
  renderPendingApprovals();
  closeModal('applyLeaveModal');
  showToast('Leave application submitted for review', 'success');
  e.target.reset();
}

// Toast Notification Utility
function showToast(message, type = 'info') {
  const container = document.getElementById('toastContainer');
  if (!container) return;

  const toast = document.createElement('div');
  toast.className = `toast ${type}`;
  toast.innerHTML = `
    <i class="fa-solid ${type === 'success' ? 'fa-circle-check text-emerald' : (type === 'error' ? 'fa-circle-xmark text-rose' : 'fa-circle-info')}"></i>
    <span>${message}</span>
  `;

  container.appendChild(toast);
  setTimeout(() => {
    toast.style.opacity = '0';
    toast.style.transform = 'translateX(100%)';
    setTimeout(() => toast.remove(), 300);
  }, 3500);
}
