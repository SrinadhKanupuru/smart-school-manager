import prisma from "../config/db";

// Helper for Indian standard time YYYY-MM-DD
const getTodayString = () => {
  const date = new Date(new Date().getTime() + 5.5 * 60 * 60 * 1000);
  return date.toISOString().split("T")[0];
};

export const runAutoCheckoutJob = async () => {
  try {
    const todayStr = getTodayString();
    const todayHolidayDate = new Date(todayStr + "T00:00:00.000Z");
    const todayDayOfWeek = todayHolidayDate.getUTCDay().toString();
    
    // Find all schools with auto-checkout enabled
    const schools = await prisma.school.findMany({
      where: { autoCheckoutEnabled: true },
      include: {
        holidays: {
          where: { date: todayHolidayDate }
        }
      }
    });

    const now = new Date();
    
    for (const school of schools) {
      const autoTime = school.autoCheckoutTime || "18:00";
      const [targetHours, targetMinutes] = autoTime.split(":").map(Number);
      
      // Construct today's auto checkout DateTime in UTC
      const autoCheckoutDate = new Date(Date.UTC(
        Number(todayStr.split("-")[0]),
        Number(todayStr.split("-")[1]) - 1,
        Number(todayStr.split("-")[2]),
        targetHours,
        targetMinutes
      ));
      // Subtract 5.5 hours to convert IST to UTC date (5.5 * 60 = 330 minutes)
      autoCheckoutDate.setMinutes(autoCheckoutDate.getMinutes() - 330);

      // Check if current time has reached or passed the auto checkout time
      if (now.getTime() >= autoCheckoutDate.getTime()) {
        // Determine holiday or weekoff status
        const isHoliday = school.holidays.length > 0;
        const offs = school.weeklyOffs ? school.weeklyOffs.split(",") : ["0"];
        const isWeekoff = offs.includes(todayDayOfWeek);

        // Fetch all staff users in this school
        const staffUsers = await prisma.user.findMany({
          where: {
            schoolId: school.id,
            role: {
              in: ["PRINCIPAL", "HM", "TEACHER", "PT", "STAFF_HEAD"]
            }
          }
        });

        for (const user of staffUsers) {
          // Fetch existing attendance record for today
          const attendance = await prisma.staffAttendance.findUnique({
            where: {
              userId_date: {
                userId: user.id,
                date: todayStr
              }
            }
          });

          if (attendance) {
            // Case A: Checked In
            const firstCheckIn = attendance.firstCheckIn;
            if (firstCheckIn && !attendance.lastCheckOut && new Date(firstCheckIn).getTime() < autoCheckoutDate.getTime()) {
              // Calculate working hours up to autoCheckoutDate
              const totalHours = (autoCheckoutDate.getTime() - new Date(firstCheckIn).getTime()) / (1000 * 60 * 60);

              const halfDayThreshold = school.halfDayThreshold ?? 4.0;
              const fullDayThreshold = school.fullDayThreshold ?? 8.0;

              let status = "PRESENT";
              if (totalHours < halfDayThreshold) {
                status = "ABSENT";
              } else if (totalHours < fullDayThreshold) {
                status = "HALF_DAY";
              }

              // Update record with auto-checkout details
              await prisma.staffAttendance.update({
                where: { id: attendance.id },
                data: {
                  lastCheckOut: autoCheckoutDate,
                  totalHours: Number(totalHours.toFixed(2)),
                  status,
                  isAutoCheckout: true,
                },
              });

              // Log the successful auto checkout
              await prisma.staffAttendanceLog.create({
                data: {
                  userId: user.id,
                  type: "CHECK_OUT",
                  success: true,
                  confidence: 1.0,
                },
              });
              
              console.log(`[AUTO_CHECKOUT]: Checked out user ${user.fullName} (${user.id}) for school ${school.name} at ${autoTime}`);
            }
          } else {
            // Case B: No attendance record yet for today
            if (isHoliday) {
              // Create record with status HOLIDAY
              await prisma.staffAttendance.create({
                data: {
                  userId: user.id,
                  date: todayStr,
                  status: "HOLIDAY"
                }
              });
              console.log(`[AUTO_CHECKOUT]: Marked HOLIDAY for user ${user.fullName} (${user.id})`);
            } else if (isWeekoff) {
              // Create record with status WEEKOFF
              await prisma.staffAttendance.create({
                data: {
                  userId: user.id,
                  date: todayStr,
                  status: "WEEKOFF"
                }
              });
              console.log(`[AUTO_CHECKOUT]: Marked WEEKOFF for user ${user.fullName} (${user.id})`);
            } else {
              // Check for approved leave
              const approvedLeave = await prisma.leaveRequest.findFirst({
                where: {
                  userId: user.id,
                  status: "APPROVED",
                  fromDate: { lte: todayHolidayDate },
                  toDate: { gte: todayHolidayDate }
                }
              });

              if (approvedLeave) {
                await prisma.staffAttendance.create({
                  data: {
                    userId: user.id,
                    date: todayStr,
                    status: "LEAVE"
                  }
                });
                console.log(`[AUTO_CHECKOUT]: Marked LEAVE for user ${user.fullName} (${user.id})`);
              } else {
                // Create record with status ABSENT
                await prisma.staffAttendance.create({
                  data: {
                    userId: user.id,
                    date: todayStr,
                    status: "ABSENT"
                  }
                });
                console.log(`[AUTO_CHECKOUT]: Marked ABSENT for user ${user.fullName} (${user.id})`);
              }
            }
          }
        }
      }
    }
  } catch (error: any) {
    if (error?.message?.includes("Authentication failed") || error?.message?.includes("Can't reach database server")) {
      // Quiet log for offline/unconfigured DB
      // console.warn("[SCHEDULER]: Database waiting for active credentials.");
    } else {
      console.error("[AUTO_CHECKOUT_JOB_ERROR]:", error?.message || error);
    }
  }
};

let intervalId: NodeJS.Timeout | null = null;

export const startScheduler = () => {
  if (intervalId) return;
  // Run every 1 minute
  intervalId = setInterval(runAutoCheckoutJob, 60 * 1000);
  console.log("[SCHEDULER]: Auto-checkout background scheduler started (interval: 1 min)");
};
