import prisma from "../config/db";
import { processFace } from "../utils/face.util";
import bcrypt from "bcryptjs";

const MIN_SIMILARITY_THRESHOLD = 0.60; // Acceptance rate for facial similarity matching

// 🔍 COSINE SIMILARITY CALCULATION
const cosineSimilarity = (a: number[], b: number[]): number => {
  const dot = a.reduce((sum, v, i) => sum + v * b[i], 0);
  const magA = Math.sqrt(a.reduce((s, v) => s + v * v, 0));
  const magB = Math.sqrt(b.reduce((s, v) => s + v * v, 0));
  if (magA === 0 || magB === 0) return 0;
  return dot / (magA * magB);
};

// 📍 HAVERSINE DISTANCE CALCULATION
export const getDistanceInMeters = (lat1: number, lon1: number, lat2: number, lon2: number): number => {
  const R = 6371e3; // Earth's radius in meters
  const toRad = (deg: number) => (deg * Math.PI) / 180;

  const φ1 = toRad(lat1);
  const φ2 = toRad(lat2);
  const Δφ = toRad(lat2 - lat1);
  const Δλ = toRad(lon2 - lon1);

  const a = Math.sin(Δφ / 2) ** 2 + Math.cos(φ1) * Math.cos(φ2) * Math.sin(Δλ / 2) ** 2;
  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));

  return R * c; // Returns distance in meters
};

// Helper for Indian standard time YYYY-MM-DD
const getTodayString = () => {
  const date = new Date(new Date().getTime() + 5.5 * 60 * 60 * 1000);
  return date.toISOString().split("T")[0];
};

// ==========================================
// 1. registerStaffWithFaceService
// ==========================================
export const registerStaffWithFaceService = async (
  admin: { schoolId: string; id: string },
  data: any,
  imageBuffer: Buffer
) => {
  const { email, password, fullName, role, phoneNumber, details } = data;

  if (!email || !password || !fullName || !role) {
    throw new Error("Missing required registration fields: email, password, fullName, role");
  }

  // 1. Call Python API to obtain face embedding
  const face = await processFace(imageBuffer);
  if (!face) {
    throw new Error("No face structure detected in the image.");
  }
  if (!face.blinkDetected) {
    throw new Error("Liveness check failed: No blink detected.");
  }

  // 2. Fetch existing embeddings in the same school and test against similarity to prevent collision
  const existingEmbeddings = await prisma.faceEmbedding.findMany({
    where: { user: { schoolId: admin.schoolId } },
    select: { embedding: true, user: { select: { fullName: true } } },
  });

  for (const record of existingEmbeddings) {
    let dbEmbedding: number[];
    try {
      dbEmbedding = JSON.parse(record.embedding);
    } catch {
      continue;
    }

    if (!Array.isArray(dbEmbedding)) continue;

    const similarity = cosineSimilarity(face.embedding, dbEmbedding);
    if (similarity > MIN_SIMILARITY_THRESHOLD) {
      throw new Error(`Biometric collision: Face already registered to ${record.user?.fullName || "another staff member"}`);
    }
  }

  const existingUser = await prisma.user.findUnique({ where: { email } });
  if (existingUser) {
    throw new Error("Email is already registered");
  }

  const hashedPassword = await bcrypt.hash(password, 10);

  // 3. Atomically save user details and embedding
  return await prisma.$transaction(async (tx) => {
    const user = await tx.user.create({
      data: {
        email,
        passwordHash: hashedPassword,
        role,
        schoolId: admin.schoolId,
        fullName,
        phoneNumber: phoneNumber || "",
      },
    });

    // Handle staff profile creation for PRINCIPAL, HM, STAFF_HEAD, TEACHER, PT
    if (["PRINCIPAL", "HM", "STAFF_HEAD", "TEACHER", "PT"].includes(role)) {
      const parsedDetails = typeof details === "string" ? JSON.parse(details) : details;
      await tx.teacherProfile.create({
        data: {
          userId: user.id,
          qualification: parsedDetails?.qualification || "",
          experienceYears: parsedDetails?.experienceYears ? parseInt(parsedDetails.experienceYears) : 0,
          salaryAmount: parsedDetails?.salaryAmount ? parseFloat(parsedDetails.salaryAmount) : 30000,
          prevExperiences: parsedDetails?.prevExperiences || null,
          bankName: parsedDetails?.bankName || null,
          bankAccountNo: parsedDetails?.bankAccountNo || null,
          bankIfsc: parsedDetails?.bankIfsc || null,
          bankBranch: parsedDetails?.bankBranch || null,
          bloodGroup: parsedDetails?.bloodGroup || null,
          aadhaarNo: parsedDetails?.aadhaarNo || null,
          permanentAddress: parsedDetails?.permanentAddress || null,
          emergencyContactName: parsedDetails?.emergencyContactName || null,
          emergencyContactPhone: parsedDetails?.emergencyContactPhone || null
        },
      });
    }

    // Save Face Embedding as stringified JSON array
    await tx.faceEmbedding.create({
      data: {
        userId: user.id,
        embedding: JSON.stringify(face.embedding),
        createdById: admin.id,
      },
    });

    return user;
  });
};

// ==========================================
// 2. verifyAndMarkStaffAttendanceService
// ==========================================
export const verifyAndMarkStaffAttendanceService = async (
  user: { id: string; schoolId: string },
  imageBuffer: Buffer,
  location?: { latitude: number; longitude: number }
) => {
  const school = await prisma.school.findUnique({
    where: { id: user.schoolId },
  });

  if (!school) {
    throw new Error("School context not found.");
  }

  const todayStr = getTodayString();

  // 0. HOLIDAY / WEEKOFF CHECK
  const todayHolidayDate = new Date(todayStr + "T00:00:00.000Z");
  
  // A. Check dynamic holidays scheduled in DB
  const scheduledHoliday = await prisma.schoolHoliday.findUnique({
    where: {
      schoolId_date: {
        schoolId: user.schoolId,
        date: todayHolidayDate,
      },
    },
  });

  if (scheduledHoliday) {
    throw new Error(`Today is a scheduled school holiday: ${scheduledHoliday.title}`);
  }

  // B. Check regular weekly offs configured for the school
  const dayOfWeek = todayHolidayDate.getUTCDay().toString(); // 0 = Sunday, 1 = Monday, etc.
  const offs = school.weeklyOffs ? school.weeklyOffs.split(",") : ["0"];
  if (offs.includes(dayOfWeek)) {
    const weekdayNames = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"];
    throw new Error(`Today is ${weekdayNames[parseInt(dayOfWeek)]} (Weekly Off). Attendance cannot be marked.`);
  }
  
  // Determine punch type intent
  let attendance = await prisma.staffAttendance.findFirst({
    where: { userId: user.id, date: todayStr },
  });
  let intendedLogType: "CHECK_IN" | "CHECK_OUT" = 
    (!attendance || !attendance.firstCheckIn) ? "CHECK_IN" : "CHECK_OUT";

  let isInsideGeo: boolean | null = null;
  let confidence: number | null = null;

  // 1. GEOFENCING VALIDATION
  if (school.latitude !== null && school.longitude !== null) {
    if (!location) {
      throw new Error("Location coordinates are required for attendance geofence validation");
    }

    const distance = getDistanceInMeters(
      location.latitude,
      location.longitude,
      school.latitude,
      school.longitude
    );

    const radius = school.geofenceRadius ?? 100;
    isInsideGeo = distance <= radius;

    if (!isInsideGeo) {
      // Log failed punch attempt
      await prisma.staffAttendanceLog.create({
        data: {
          userId: user.id,
          type: intendedLogType,
          success: false,
          latitude: location.latitude,
          longitude: location.longitude,
          isInsideGeo: false,
        },
      });
      throw new Error(`Outside allowed school perimeter. Distance: ${Math.round(distance)}m (Limit: ${radius}m)`);
    }
  }

  // 2. FACE MATCHING VALIDATION
  const face = await processFace(imageBuffer);
  if (!face) {
    throw new Error("Face validation failed. Python AI model returned no face.");
  }
  if (!face.blinkDetected) {
    throw new Error("Liveness check failed: Eye-blink not detected.");
  }

  // Retrieve user's registered embedding
  const userEmbeddingRecord = await prisma.faceEmbedding.findUnique({
    where: { userId: user.id },
  });

  if (!userEmbeddingRecord) {
    throw new Error("No face registered for this account. Please register your face first.");
  }

  let dbEmbedding: number[];
  try {
    dbEmbedding = JSON.parse(userEmbeddingRecord.embedding);
  } catch {
    throw new Error("Failed to parse registered biometric record.");
  }

  const score = cosineSimilarity(face.embedding, dbEmbedding);
  if (score < 0.65) {
    await prisma.staffAttendanceLog.create({
      data: {
        userId: user.id,
        type: intendedLogType,
        success: false,
        confidence: score,
        latitude: location?.latitude,
        longitude: location?.longitude,
        isInsideGeo,
      },
    });
    throw new Error(`Face authentication failed (Confidence: ${score.toFixed(2)})`);
  }
  confidence = score;

  // 3. PUNCH RECORD LOGIC
  const now = new Date();
  let punchType: "CHECK_IN" | "CHECK_OUT" = "CHECK_IN";

  if (!attendance) {
    // First punch: Check-In
    attendance = await prisma.staffAttendance.create({
      data: {
        userId: user.id,
        date: todayStr,
        firstCheckIn: now,
        status: "PRESENT",
      },
    });
  } else if (!attendance.firstCheckIn) {
    attendance = await prisma.staffAttendance.update({
      where: { id: attendance.id },
      data: {
        firstCheckIn: now,
        status: "PRESENT",
      },
    });
  } else {
    // Secondary punch: Check-Out
    punchType = "CHECK_OUT";
    const totalHours = (now.getTime() - new Date(attendance.firstCheckIn).getTime()) / (1000 * 60 * 60);

    const halfDayThreshold = school.halfDayThreshold ?? 4.0;
    const fullDayThreshold = school.fullDayThreshold ?? 8.0;

    let status = "PRESENT";
    if (totalHours < halfDayThreshold) {
      status = "ABSENT";
    } else if (totalHours < fullDayThreshold) {
      status = "HALF_DAY";
    }

    attendance = await prisma.staffAttendance.update({
      where: { id: attendance.id },
      data: {
        lastCheckOut: now,
        totalHours: Number(totalHours.toFixed(2)),
        status,
        isAutoCheckout: false,
      },
    });
  }

  // Log Successful Punch
  await prisma.staffAttendanceLog.create({
    data: {
      userId: user.id,
      type: punchType,
      success: true,
      confidence,
      latitude: location?.latitude,
      longitude: location?.longitude,
      isInsideGeo,
    },
  });

  return { attendance, type: punchType, confidence, isInsideGeo };
};

export async function syncAbsentAndLeaveAttendanceRecords(schoolId: string, month: string, year: number) {
  // Convert month name to index (0-11)
  const monthNames = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];
  const monthIndex = monthNames.indexOf(month);
  if (monthIndex === -1) return;

  const startDate = new Date(Date.UTC(year, monthIndex, 1));
  const endDate = new Date(Date.UTC(year, monthIndex + 1, 0)); // last day of month

  const today = new Date();
  today.setUTCHours(0, 0, 0, 0);

  // We only sync up to min(endDate, today)
  const limitDate = endDate.getTime() < today.getTime() ? endDate : today;

  // Fetch school details for weeklyOffs
  const school = await prisma.school.findUnique({
    where: { id: schoolId },
    include: { holidays: true }
  });
  if (!school) return;

  const offs = school.weeklyOffs ? school.weeklyOffs.split(",") : ["0"];
  const holidaysSet = new Set(
    school.holidays.map(h => h.date.toISOString().split("T")[0])
  );

  // Fetch all staff users in this school
  const users = await prisma.user.findMany({
    where: {
      schoolId,
      role: {
        in: ["PRINCIPAL", "HM", "TEACHER", "PT", "STAFF_HEAD"]
      }
    }
  });

  // Loop through each date from startDate to limitDate
  let temp = new Date(startDate);
  while (temp.getTime() <= limitDate.getTime()) {
    const dateStr = temp.toISOString().split("T")[0];
    const dayOfWeek = temp.getUTCDay().toString();

    // Skip if it's a holiday or a weekoff
    if (offs.includes(dayOfWeek) || holidaysSet.has(dateStr)) {
      temp.setUTCDate(temp.getUTCDate() + 1);
      continue;
    }

    // For each user
    for (const user of users) {
      // Check if an attendance record already exists
      const existingAttendance = await prisma.staffAttendance.findUnique({
        where: {
          userId_date: {
            userId: user.id,
            date: dateStr
          }
        }
      });

      const checkDate = new Date(dateStr + "T00:00:00.000Z");
      const approvedLeave = await prisma.leaveRequest.findFirst({
        where: {
          userId: user.id,
          status: "APPROVED",
          fromDate: { lte: checkDate },
          toDate: { gte: checkDate }
        }
      });

      if (!existingAttendance) {
        if (approvedLeave) {
          // Create attendance as LEAVE
          await prisma.staffAttendance.create({
            data: {
              userId: user.id,
              date: dateStr,
              status: "LEAVE"
            }
          });
        } else {
          // Create attendance as ABSENT
          await prisma.staffAttendance.create({
            data: {
              userId: user.id,
              date: dateStr,
              status: "ABSENT"
            }
          });
        }
      } else {
        // If they have an approved leave, check if status is not already LEAVE
        if (approvedLeave && existingAttendance.status !== "LEAVE") {
          await prisma.staffAttendance.update({
            where: { id: existingAttendance.id },
            data: { status: "LEAVE" }
          });
        }
      }
    }

    temp.setUTCDate(temp.getUTCDate() + 1);
  }
}
