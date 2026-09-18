import prisma from "./config/db";
import bcrypt from "bcryptjs";

async function main() {
  console.log("Checking database status...");
  const schools = await prisma.school.findMany();
  console.log("Schools found:", schools.length);

  let school = schools[0];
  if (!school) {
    school = await prisma.school.create({
      data: {
        name: "Delhi Public International School",
        code: "DPIS-2026",
        type: "K12",
        board: "CBSE",
        address: "Plot 14, Institutional Area, Sector 5",
        city: "New Delhi",
        state: "Delhi",
        country: "India",
        pinCode: "110001",
        contactNumber: "+91 98765 43210"
      }
    });
    console.log("Created default school:", school.id);
  }

  let admin = await prisma.user.findFirst({
    where: { schoolId: school.id, role: "CORRESPONDENT" }
  });

  if (!admin) {
    const passwordHash = await bcrypt.hash("admin123", 10);
    admin = await prisma.user.create({
      data: {
        fullName: "Dr. Sarah Jenkins",
        email: "admin@school.com",
        phoneNumber: "+91 98765 00001",
        passwordHash,
        role: "CORRESPONDENT",
        schoolId: school.id
      }
    });
    console.log("Created admin user:", admin.email);
  } else {
    console.log("Admin user exists:", admin.email);
  }

  // Check employees / staff
  const staffMembers = [
    { fullName: "Ananya Sharma", email: "ananya.s@school.com", phone: "+91 98765 11111", role: "TEACHER", department: "Mathematics" },
    { fullName: "Rajesh Kumar", email: "rajesh.k@school.com", phone: "+91 98765 22222", role: "TEACHER", department: "Science" },
    { fullName: "Vikram Singh", email: "vikram.s@school.com", phone: "+91 98765 33333", role: "ADMIN_STAFF", department: "Administration" },
    { fullName: "Priya Nair", email: "priya.n@school.com", phone: "+91 98765 44444", role: "TEACHER", department: "English" },
    { fullName: "Amitabh Sen", email: "amitabh.s@school.com", phone: "+91 98765 55555", role: "SUPPORT_STAFF", department: "Transport" }
  ];

  const staffUsers = [];
  for (const s of staffMembers) {
    let u = await prisma.user.findFirst({ where: { email: s.email } });
    if (!u) {
      const passwordHash = await bcrypt.hash("staff123", 10);
      u = await prisma.user.create({
        data: {
          fullName: s.fullName,
          email: s.email,
          phoneNumber: s.phone,
          passwordHash,
          role: s.role,
          schoolId: school.id
        }
      });
    }
    if (s.role === "TEACHER") {
      const existingProfile = await prisma.teacherProfile.findUnique({ where: { userId: u.id } });
      if (!existingProfile) {
        await prisma.teacherProfile.create({
          data: {
            userId: u.id,
            qualification: "M.Sc., B.Ed",
            experienceYears: 5,
            salaryAmount: 45000,
            workingStatus: "ACTIVE",
            bloodGroup: "O+",
            permanentAddress: "Sector 4, New Delhi"
          }
        });
      }
    }
    staffUsers.push({ ...u, department: s.department });
  }

  // Ensure default Leave Types / Policies
  const defaultPolicies = [
    { name: "Casual Leave", code: "CASUAL", maxDays: 12, maxConsecutiveDays: 3, minNoticePeriodDays: 2, carryForwardAllowed: false, maxCarryForwardDays: 0, requiresAttachment: false, attachmentAfterDays: 0, requiresApproval: true, description: "General short-term leave for personal commitments or urgent personal affairs." },
    { name: "Sick Leave", code: "SICK", maxDays: 10, maxConsecutiveDays: 7, minNoticePeriodDays: 0, carryForwardAllowed: true, maxCarryForwardDays: 5, requiresAttachment: true, attachmentAfterDays: 2, requiresApproval: true, description: "Leave granted for medical reasons, illness, or emergency health recovery." },
    { name: "Paid / Earned Leave", code: "EARNED", maxDays: 15, maxConsecutiveDays: 14, minNoticePeriodDays: 7, carryForwardAllowed: true, maxCarryForwardDays: 10, requiresAttachment: false, attachmentAfterDays: 0, requiresApproval: true, description: "Annual planned vacation or long personal breaks accrued through service." },
    { name: "Maternity Leave", code: "MATERNITY", maxDays: 180, maxConsecutiveDays: 180, minNoticePeriodDays: 30, carryForwardAllowed: false, maxCarryForwardDays: 0, requiresAttachment: true, attachmentAfterDays: 1, requiresApproval: true, description: "Statutory maternity leave for female employees for prenatal and postnatal care." },
    { name: "Compensatory Off", code: "COMPOFF", maxDays: 6, maxConsecutiveDays: 2, minNoticePeriodDays: 1, carryForwardAllowed: false, maxCarryForwardDays: 0, requiresAttachment: false, attachmentAfterDays: 0, requiresApproval: true, description: "Leave credited for extra work performed on public holidays or weekends." }
  ];

  const leaveTypes = [];
  for (const p of defaultPolicies) {
    let lt = await prisma.leaveType.findFirst({
      where: { schoolId: school.id, code: p.code }
    });
    if (!lt) {
      lt = await prisma.leaveType.create({
        data: {
          schoolId: school.id,
          ...p
        }
      });
    }
    leaveTypes.push(lt);
  }

  // Ensure Leave Balances
  for (const u of staffUsers) {
    for (const lt of leaveTypes) {
      const existingBalance = await prisma.leaveBalance.findFirst({
        where: { userId: u.id, leaveTypeCode: lt.code, year: 2026 }
      });
      if (!existingBalance) {
        await prisma.leaveBalance.create({
          data: {
            userId: u.id,
            leaveTypeId: lt.id,
            leaveTypeCode: lt.code,
            year: 2026,
            allocated: lt.maxDays,
            used: 0,
            adjusted: 0,
            remaining: lt.maxDays
          }
        });
      }
    }
  }

  // Ensure Sample Leave Requests
  const sampleRequests = [
    {
      userId: staffUsers[0].id,
      leaveType: "Sick Leave",
      leaveTypeId: leaveTypes[1].id, // Sick Leave
      fromDate: new Date("2026-09-10T00:00:00.000Z"),
      toDate: new Date("2026-09-12T00:00:00.000Z"),
      daysCount: 3,
      reason: "Diagnosed with viral fever and advised strict home rest by physician.",
      status: "PENDING",
      isEmergency: true
    },
    {
      userId: staffUsers[1].id,
      leaveType: "Casual Leave",
      leaveTypeId: leaveTypes[0].id, // Casual Leave
      fromDate: new Date("2026-09-15T00:00:00.000Z"),
      toDate: new Date("2026-09-16T00:00:00.000Z"),
      daysCount: 2,
      reason: "Family function in hometown.",
      status: "PENDING",
      isEmergency: false
    },
    {
      userId: staffUsers[2].id,
      leaveType: "Paid / Earned Leave",
      leaveTypeId: leaveTypes[2].id, // Paid Leave
      fromDate: new Date("2026-08-20T00:00:00.000Z"),
      toDate: new Date("2026-08-24T00:00:00.000Z"),
      daysCount: 5,
      reason: "Annual family vacation trip to Himachal.",
      status: "APPROVED",
      approvedAt: new Date("2026-08-18T10:30:00.000Z"),
      approvedById: admin.id
    },
    {
      userId: staffUsers[3].id,
      leaveType: "Casual Leave",
      leaveTypeId: leaveTypes[0].id, // Casual Leave
      fromDate: new Date("2026-08-28T00:00:00.000Z"),
      toDate: new Date("2026-08-29T00:00:00.000Z"),
      daysCount: 2,
      reason: "Personal work at regional passport office.",
      status: "REJECTED",
      rejectedAt: new Date("2026-08-27T14:15:00.000Z"),
      rejectionReason: "Clashing with scheduled mid-term exam supervision duties. Please reschedule after exam week.",
      approvedById: admin.id
    }
  ];

  for (const sr of sampleRequests) {
    const existingReq = await prisma.leaveRequest.findFirst({
      where: {
        userId: sr.userId,
        fromDate: sr.fromDate,
        toDate: sr.toDate
      }
    });
    if (!existingReq) {
      await prisma.leaveRequest.create({
        data: sr
      });
    }
  }

  // Ensure Sample Attendance Rectifications
  const sampleRectifications = [
    {
      userId: staffUsers[1].id,
      date: "2026-09-04",
      originalAttendance: "ABSENT",
      requestedAttendance: "PRESENT",
      checkInTime: "08:15 AM",
      checkOutTime: "03:45 PM",
      reason: "Biometric AI face machine failed to recognize facial contour due to morning lighting glares. Security gate register signed at 08:15 AM.",
      status: "PENDING"
    },
    {
      userId: staffUsers[0].id,
      date: "2026-09-02",
      originalAttendance: "HALF_DAY",
      requestedAttendance: "PRESENT",
      checkInTime: "08:00 AM",
      checkOutTime: "04:10 PM",
      reason: "Stayed back for science exhibition preparation until 4:10 PM; checkout machine was in offline maintenance mode.",
      status: "APPROVED",
      approvedAt: new Date("2026-09-03T11:00:00.000Z"),
      approvedById: admin.id
    }
  ];

  for (const ar of sampleRectifications) {
    const existingRec = await prisma.attendanceRectification.findFirst({
      where: {
        userId: ar.userId,
        date: ar.date
      }
    });
    if (!existingRec) {
      await prisma.attendanceRectification.create({
        data: ar
      });
    }
  }

  console.log("Database initialization & seeding complete!");
  process.exit(0);
}

main().catch(err => {
  console.error("Error in seed script:", err);
  process.exit(1);
});
