import { Request, Response } from "express";
import { AuthenticatedRequest } from "../middlewares/auth";
import prisma from "../config/db";
import multer from "multer";
import path from "path";

export async function getClassesAndSections(req: AuthenticatedRequest, res: Response) {
  try {
    const schoolId = req.user?.schoolId;
    if (!schoolId) {
      return res.status(400).json({ error: "Missing school context" });
    }

    const classes = await prisma.class.findMany({
      where: { schoolId },
      include: {
        sections: {
          include: {
            classTeacher: {
              include: { user: true }
            },
            students: {
              include: {
                parents: {
                  include: {
                    parent: {
                      include: { user: true }
                    }
                  }
                }
              }
            }
          }
        }
      }
    });

    res.json(classes);
  } catch (error: any) {
    res.status(500).json({ error: error.message || "Failed to load classes" });
  }
}

export async function markAttendance(req: AuthenticatedRequest, res: Response) {
  try {
    const { date, attendanceData } = req.body; // attendanceData: Array<{ studentId: string, status: string }>
    const userId = req.user?.id;

    if (!date || !attendanceData || !Array.isArray(attendanceData) || !userId) {
      return res.status(400).json({ error: "Missing date, attendanceData, or user credentials" });
    }

    const parsedDate = new Date(date);
    parsedDate.setUTCHours(0, 0, 0, 0); // clear times

    // Use Prisma upsert transactions for bulk inputs
    const ops = attendanceData.map((item) => {
      const recordKey = {
        date_studentId: {
          date: parsedDate,
          studentId: item.studentId
        }
      };
      return prisma.attendance.upsert({
        where: recordKey,
        update: {
          status: item.status,
          markedById: userId
        },
        create: {
          date: parsedDate,
          studentId: item.studentId,
          status: item.status,
          markedById: userId
        }
      });
    });

    await prisma.$transaction(ops);
    res.json({ message: "Attendance marked successfully" });
  } catch (error: any) {
    res.status(500).json({ error: error.message || "Failed to mark attendance" });
  }
}

export async function getAttendanceHistory(req: AuthenticatedRequest, res: Response) {
  try {
    const { classSectionId, date } = req.query;

    if (!classSectionId) {
      return res.status(400).json({ error: "classSectionId parameter is required" });
    }

    const filter: any = {
      student: { classSectionId: classSectionId as string }
    };

    if (date) {
      const parsedDate = new Date(date as string);
      parsedDate.setUTCHours(0, 0, 0, 0);
      filter.date = parsedDate;
    }

    const attendance = await prisma.attendance.findMany({
      where: filter,
      include: {
        student: true,
        markedBy: { select: { fullName: true } }
      }
    });

    res.json(attendance);
  } catch (error: any) {
    res.status(500).json({ error: error.message || "Failed to fetch attendance history" });
  }
}

export async function uploadHomework(req: AuthenticatedRequest, res: Response) {
  try {
    const { classSectionId, subject, title, description, dueDate, fileUrl } = req.body;
    const userId = req.user?.id;

    if (!classSectionId || !subject || !title || !description || !dueDate || !userId) {
      return res.status(400).json({ error: "Missing required homework fields" });
    }

    const homework = await prisma.homework.create({
      data: {
        classSectionId,
        subject,
        title,
        description,
        dueDate: new Date(dueDate),
        fileUrl,
        createdById: userId
      }
    });

    res.status(201).json({ message: "Homework uploaded successfully", homework });
  } catch (error: any) {
    res.status(500).json({ error: error.message || "Failed to upload homework" });
  }
}

export async function getHomework(req: AuthenticatedRequest, res: Response) {
  try {
    const { classSectionId } = req.query;

    if (!classSectionId) {
      return res.status(400).json({ error: "classSectionId is required" });
    }

    const homework = await prisma.homework.findMany({
      where: { classSectionId: classSectionId as string },
      orderBy: { createdAt: "desc" },
      include: {
        createdBy: { select: { fullName: true } }
      }
    });

    res.json(homework);
  } catch (error: any) {
    res.status(500).json({ error: error.message || "Failed to load homework" });
  }
}

export async function addDiary(req: AuthenticatedRequest, res: Response) {
  try {
    const { classSectionId, date, subject, details } = req.body;
    const userId = req.user?.id;

    if (!classSectionId || !date || !subject || !details || !userId) {
      return res.status(400).json({ error: "Missing required diary fields" });
    }

    const diary = await prisma.learningDiary.create({
      data: {
        classSectionId,
        date: new Date(date),
        subject,
        details,
        createdById: userId
      }
    });

    res.status(201).json({ message: "Diary entry added successfully", diary });
  } catch (error: any) {
    res.status(500).json({ error: error.message || "Failed to create diary entry" });
  }
}

export async function getDiary(req: AuthenticatedRequest, res: Response) {
  try {
    const { classSectionId, date } = req.query;

    if (!classSectionId) {
      return res.status(400).json({ error: "classSectionId is required" });
    }

    const filter: any = { classSectionId: classSectionId as string };
    if (date) {
      const parsedDate = new Date(date as string);
      parsedDate.setUTCHours(0, 0, 0, 0);
      filter.date = parsedDate;
    }

    const diaries = await prisma.learningDiary.findMany({
      where: filter,
      orderBy: { date: "desc" },
      include: {
        createdBy: { select: { fullName: true } }
      }
    });

    res.json(diaries);
  } catch (error: any) {
    res.status(500).json({ error: error.message || "Failed to load learning diaries" });
  }
}

export async function enterMarks(req: AuthenticatedRequest, res: Response) {
  try {
    const { examName, classId, date, marksData } = req.body; // marksData: Array<{ studentId: string, subject: string, marksObtained: number, maxMarks: number }>
    const schoolId = req.user?.schoolId;

    if (!examName || !classId || !marksData || !Array.isArray(marksData) || !schoolId) {
      return res.status(400).json({ error: "Missing exam properties or marks array" });
    }

    const exam = await prisma.exam.create({
      data: {
        classId,
        name: examName,
        date: date ? new Date(date) : new Date(),
      }
    });

    const marksOps = marksData.map((item) => {
      return prisma.mark.create({
        data: {
          examId: exam.id,
          studentId: item.studentId,
          subject: item.subject,
          marksObtained: parseFloat(item.marksObtained),
          maxMarks: parseFloat(item.maxMarks)
        }
      });
    });

    await prisma.$transaction(marksOps);
    res.json({ message: "Marks recorded successfully", examId: exam.id });
  } catch (error: any) {
    res.status(500).json({ error: error.message || "Failed to record exam grades" });
  }
}

export async function getExamMarks(req: AuthenticatedRequest, res: Response) {
  try {
    const { classId } = req.query;

    if (!classId) {
      return res.status(400).json({ error: "classId parameter is required" });
    }

    const exams = await prisma.exam.findMany({
      where: { classId: classId as string },
      include: {
        marks: {
          include: {
            student: true
          }
        }
      },
      orderBy: { date: "desc" }
    });

    res.json(exams);
  } catch (error: any) {
    res.status(500).json({ error: error.message || "Failed to load marks" });
  }
}

export async function getTimetable(req: AuthenticatedRequest, res: Response) {
  try {
    const { classSectionId, teacherId } = req.query;

    const filter: any = {};
    if (classSectionId) filter.classSectionId = classSectionId as string;
    if (teacherId) filter.teacherId = teacherId as string;

    if (Object.keys(filter).length === 0) {
      return res.status(400).json({ error: "Either classSectionId or teacherId is required" });
    }

    const timetables = await prisma.timetable.findMany({
      where: filter,
      include: {
        classSection: {
          include: {
            class: true
          }
        },
        teacher: {
          include: {
            user: { select: { fullName: true } }
          }
        }
      },
      orderBy: [
        { dayOfWeek: "asc" },
        { startTime: "asc" }
      ]
    });

    res.json(timetables);
  } catch (error: any) {
    res.status(500).json({ error: error.message || "Failed to retrieve timetable logs" });
  }
}

// Helper to parse time strings like "08:30 AM" or "02:30 PM" to minutes since midnight
function parseTimeToMinutes(timeStr: string): number {
  const clean = timeStr.trim().toUpperCase();
  const ampmMatch = clean.match(/^(\d+):(\d+)\s*(AM|PM)$/);
  if (ampmMatch) {
    let hours = parseInt(ampmMatch[1]);
    const minutes = parseInt(ampmMatch[2]);
    const ampm = ampmMatch[3];
    if (ampm === "PM" && hours < 12) hours += 12;
    if (ampm === "AM" && hours === 12) hours = 0;
    return hours * 60 + minutes;
  }

  const standardMatch = clean.match(/^(\d+):(\d+)$/);
  if (standardMatch) {
    const hours = parseInt(standardMatch[1]);
    const minutes = parseInt(standardMatch[2]);
    return hours * 60 + minutes;
  }

  return 0;
}

// Helper to check for overlap between two time intervals
function isOverlapping(start1: string, end1: string, start2: string, end2: string): boolean {
  const s1 = parseTimeToMinutes(start1);
  const e1 = parseTimeToMinutes(end1);
  const s2 = parseTimeToMinutes(start2);
  const e2 = parseTimeToMinutes(end2);
  return s1 < e2 && e1 > s2;
}

// Conflict checking function
async function checkTimetableClashes(
  dayOfWeek: number,
  startTime: string,
  endTime: string,
  teacherId: string,
  classSectionId: string,
  roomNo: string,
  excludeId?: string
) {
  // 1. Check teacher overlap
  const teacherSlots = await prisma.timetable.findMany({
    where: {
      dayOfWeek,
      teacherId,
      id: excludeId ? { not: excludeId } : undefined
    },
    include: {
      classSection: { include: { class: true } }
    }
  });

  for (const slot of teacherSlots) {
    if (isOverlapping(startTime, endTime, slot.startTime, slot.endTime)) {
      throw new Error(`Teacher is already scheduled at this time in Class ${slot.classSection.class.name} - ${slot.classSection.name} (Room ${slot.roomNo})`);
    }
  }

  // 2. Check class section overlap
  const classSlots = await prisma.timetable.findMany({
    where: {
      dayOfWeek,
      classSectionId,
      id: excludeId ? { not: excludeId } : undefined
    },
    include: {
      classSection: { include: { class: true } }
    }
  });

  for (const slot of classSlots) {
    if (isOverlapping(startTime, endTime, slot.startTime, slot.endTime)) {
      throw new Error(`Class section "${slot.classSection.class.name} - ${slot.classSection.name}" already has a scheduled slot at this time: ${slot.subject} (Room ${slot.roomNo})`);
    }
  }

  // 3. Check room overlap
  const roomSlots = await prisma.timetable.findMany({
    where: {
      dayOfWeek,
      roomNo,
      id: excludeId ? { not: excludeId } : undefined
    },
    include: {
      classSection: { include: { class: true } }
    }
  });

  for (const slot of roomSlots) {
    if (isOverlapping(startTime, endTime, slot.startTime, slot.endTime)) {
      throw new Error(`Room ${roomNo} is already occupied at this time by Class ${slot.classSection.class.name} - ${slot.classSection.name}`);
    }
  }
}

export async function createClass(req: AuthenticatedRequest, res: Response) {
  try {
    const { name } = req.body;
    const schoolId = req.user?.schoolId;

    if (!schoolId) {
      return res.status(400).json({ error: "Missing school context" });
    }
    if (!name) {
      return res.status(400).json({ error: "Class name is required" });
    }

    const newClass = await prisma.class.create({
      data: {
        name,
        schoolId
      }
    });

    res.status(201).json({ message: "Class created successfully", class: newClass });
  } catch (error: any) {
    res.status(500).json({ error: error.message || "Failed to create class" });
  }
}

export async function createClassSection(req: AuthenticatedRequest, res: Response) {
  try {
    const { classId, name, classTeacherId } = req.body;

    if (!classId || !name) {
      return res.status(400).json({ error: "classId and section name are required" });
    }

    const section = await prisma.classSection.create({
      data: {
        classId,
        name,
        classTeacherId: classTeacherId || null
      }
    });

    res.status(201).json({ message: "Class section created successfully", section });
  } catch (error: any) {
    res.status(500).json({ error: error.message || "Failed to create class section" });
  }
}

export async function assignStudentsToClassSection(req: AuthenticatedRequest, res: Response) {
  try {
    const { classSectionId, studentIds } = req.body;

    if (!classSectionId || !studentIds || !Array.isArray(studentIds)) {
      return res.status(400).json({ error: "classSectionId and studentIds (array) are required" });
    }

    // Check if any student is already assigned to a DIFFERENT class section.
    // "if a student is already assigned in a class he can't assign in another class"
    const students = await prisma.student.findMany({
      where: { id: { in: studentIds } },
      include: { classSection: { include: { class: true } } }
    });

    for (const student of students) {
      if (student.classSectionId && student.classSectionId !== classSectionId) {
        return res.status(400).json({
          error: `Student "${student.fullName}" is already assigned to class "${student.classSection?.class.name} - ${student.classSection?.name}" and cannot be assigned to another class.`
        });
      }
    }

    // Update students' classSectionId
    await prisma.$transaction(
      studentIds.map(id =>
        prisma.student.update({
          where: { id },
          data: { classSectionId }
        })
      )
    );

    res.json({ message: "Students assigned to class section successfully" });
  } catch (error: any) {
    res.status(500).json({ error: error.message || "Failed to assign students" });
  }
}

export async function updateTimetable(req: AuthenticatedRequest, res: Response) {
  try {
    const { classSectionId, dayOfWeek, startTime, endTime, subject, teacherId, roomNo } = req.body;

    if (!classSectionId || !dayOfWeek || !startTime || !endTime || !subject || !teacherId || !roomNo) {
      return res.status(400).json({ error: "Missing required timetable properties" });
    }

    // Check overlaps
    try {
      await checkTimetableClashes(
        parseInt(dayOfWeek),
        startTime,
        endTime,
        teacherId,
        classSectionId,
        roomNo
      );
    } catch (clashError: any) {
      return res.status(400).json({ error: clashError.message });
    }

    const timetable = await prisma.timetable.create({
      data: {
        classSectionId,
        dayOfWeek: parseInt(dayOfWeek),
        startTime,
        endTime,
        subject,
        teacherId,
        roomNo
      }
    });

    res.status(201).json({ message: "Timetable slot added successfully", timetable });
  } catch (error: any) {
    res.status(500).json({ error: error.message || "Failed to register timetable slot" });
  }
}

export async function updateTimetableSlot(req: AuthenticatedRequest, res: Response) {
  try {
    const { id } = req.params;
    const { classSectionId, dayOfWeek, startTime, endTime, subject, teacherId, roomNo } = req.body;

    if (!classSectionId || !dayOfWeek || !startTime || !endTime || !subject || !teacherId || !roomNo) {
      return res.status(400).json({ error: "Missing required timetable properties" });
    }

    const existing = await prisma.timetable.findUnique({ where: { id } });
    if (!existing) {
      return res.status(404).json({ error: "Timetable slot not found" });
    }

    // Check overlaps (excluding this slot)
    try {
      await checkTimetableClashes(
        parseInt(dayOfWeek),
        startTime,
        endTime,
        teacherId,
        classSectionId,
        roomNo,
        id
      );
    } catch (clashError: any) {
      return res.status(400).json({ error: clashError.message });
    }

    const updated = await prisma.timetable.update({
      where: { id },
      data: {
        classSectionId,
        dayOfWeek: parseInt(dayOfWeek),
        startTime,
        endTime,
        subject,
        teacherId,
        roomNo
      }
    });

    res.json({ message: "Timetable slot updated successfully", timetable: updated });
  } catch (error: any) {
    res.status(500).json({ error: error.message || "Failed to update timetable slot" });
  }
}

export async function deleteTimetableSlot(req: AuthenticatedRequest, res: Response) {
  try {
    const { id } = req.params;

    const existing = await prisma.timetable.findUnique({ where: { id } });
    if (!existing) {
      return res.status(404).json({ error: "Timetable slot not found" });
    }

    await prisma.timetable.delete({ where: { id } });
    res.json({ message: "Timetable slot deleted successfully" });
  } catch (error: any) {
    res.status(500).json({ error: error.message || "Failed to delete timetable slot" });
  }
}

export async function addStudent(req: AuthenticatedRequest, res: Response) {
  try {
    const { fullName, rollNo, classSectionId, gender, dateOfBirth, initialFees } = req.body;
    const schoolId = req.user?.schoolId;

    if (!schoolId) {
      return res.status(400).json({ error: "Missing school context" });
    }

    if (!fullName || !rollNo || !gender || !dateOfBirth) {
      return res.status(400).json({ error: "Missing required student details (fullName, rollNo, gender, dateOfBirth)" });
    }

    const student = await prisma.$transaction(async (tx) => {
      const newStudent = await tx.student.create({
        data: {
          schoolId,
          fullName,
          rollNo,
          classSectionId: classSectionId || null,
          gender,
          dateOfBirth: new Date(dateOfBirth)
        }
      });

      if (initialFees && Array.isArray(initialFees) && initialFees.length > 0) {
        await tx.feeRecord.createMany({
          data: initialFees.map((fee: any) => ({
            studentId: newStudent.id,
            category: fee.category || "OTHER",
            amount: parseFloat(fee.amount),
            paidAmount: 0.0,
            status: "PENDING",
            dueDate: new Date(fee.dueDate)
          }))
        });
      }

      return newStudent;
    });

    const fullStudent = await prisma.student.findUnique({
      where: { id: student.id },
      include: {
        classSection: {
          include: { class: true }
        },
        feeRecords: true
      }
    });

    res.status(201).json({ message: "Student added successfully", student: fullStudent || student });
  } catch (error: any) {
    res.status(500).json({ error: error.message || "Failed to add student" });
  }
}

export async function getStudents(req: any, res: Response) {
  try {
    let schoolId = req.user?.schoolId;
    if (!schoolId) {
      const defaultSchool = await prisma.school.findFirst();
      schoolId = defaultSchool?.id;
    }

    if (!schoolId) {
      return res.json([]);
    }

    const { classSectionId } = req.query;
    const whereClause: any = { schoolId };
    if (classSectionId) {
      whereClause.classSectionId = classSectionId as string;
    }

    const students = await prisma.student.findMany({
      where: whereClause,
      include: {
        classSection: {
          include: {
            class: true,
            homeworks: {
              orderBy: { dueDate: "desc" },
              take: 10
            }
          }
        },
        parents: {
          include: {
            parent: {
              include: {
                user: {
                  select: {
                    fullName: true,
                    email: true,
                    phoneNumber: true
                  }
                }
              }
            }
          }
        },
        attendance: {
          orderBy: { date: "desc" }
        },
        marks: {
          include: {
            exam: true
          }
        },
        feeRecords: {
          orderBy: { dueDate: "desc" }
        },
        busRoute: {
          include: {
            stops: {
              orderBy: { sequenceNo: "asc" }
            }
          }
        }
      },
      orderBy: { fullName: "asc" }
    });

    res.json(students);
  } catch (error: any) {
    res.status(500).json({ error: error.message || "Failed to fetch students" });
  }
}

export async function directAddStudent(req: any, res: Response) {
  try {
    const { fullName, rollNo, className, section, gender, dob, parentName, parentPhone } = req.body;

    if (!fullName) {
      return res.status(400).json({ error: "Student full name is required" });
    }

    let school = await prisma.school.findFirst();
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
    }

    // Find or create class and section
    const clsName = className || "Grade 10";
    const secName = section || "A";

    let classRecord = await prisma.class.findFirst({
      where: { schoolId: school.id, name: clsName }
    });
    if (!classRecord) {
      classRecord = await prisma.class.create({
        data: { schoolId: school.id, name: clsName }
      });
    }

    let sectionRecord = await prisma.classSection.findFirst({
      where: { classId: classRecord.id, name: secName }
    });
    if (!sectionRecord) {
      sectionRecord = await prisma.classSection.create({
        data: { classId: classRecord.id, name: secName }
      });
    }

    const sRollNo = rollNo || `${Math.floor(10 + Math.random() * 90)}`;
    const parsedDob = dob ? new Date(dob) : new Date("2011-05-15");

    const newStudent = await prisma.student.create({
      data: {
        schoolId: school.id,
        fullName: fullName.trim(),
        rollNo: sRollNo,
        classSectionId: sectionRecord.id,
        gender: gender || "Male",
        dateOfBirth: isNaN(parsedDob.getTime()) ? new Date("2011-05-15") : parsedDob,
        isActive: true,
      }
    });

    // Create default Tuition fee record
    await prisma.feeRecord.create({
      data: {
        studentId: newStudent.id,
        category: "Tuition Fee (Q2)",
        amount: 25000.0,
        paidAmount: 0.0,
        status: "PENDING",
        dueDate: new Date(Date.now() + 30 * 24 * 60 * 60 * 1000)
      }
    });

    const fullStudent = await prisma.student.findUnique({
      where: { id: newStudent.id },
      include: {
        classSection: {
          include: { class: true }
        },
        feeRecords: true
      }
    });

    res.status(201).json({ message: "Student created successfully", student: fullStudent });
  } catch (error: any) {
    console.error("directAddStudent error:", error);
    res.status(500).json({ error: error.message || "Failed to add student" });
  }
}

export async function deleteStudent(req: any, res: Response) {
  try {
    const { id } = req.params;
    const existing = await prisma.student.findUnique({ where: { id } });
    if (!existing) {
      return res.status(404).json({ error: "Student not found" });
    }
    await prisma.student.delete({ where: { id } });
    res.json({ message: "Student deleted successfully" });
  } catch (error: any) {
    res.status(500).json({ error: error.message || "Failed to delete student" });
  }
}

export async function uploadResource(req: AuthenticatedRequest, res: Response) {
  try {
    const { classSectionId, subject, title, description, resourceType, fileUrl } = req.body;
    const userId = req.user?.id;

    if (!classSectionId || !subject || !title || !resourceType || !fileUrl || !userId) {
      return res.status(400).json({ error: "Missing required resource fields (classSectionId, subject, title, resourceType, fileUrl)" });
    }

    const resource = await prisma.classResource.create({
      data: {
        classSectionId,
        subject,
        title,
        description,
        resourceType,
        fileUrl,
        createdById: userId
      }
    });

    res.status(201).json({ message: "Class resource uploaded successfully", resource });
  } catch (error: any) {
    res.status(500).json({ error: error.message || "Failed to upload resource" });
  }
}

export async function getResources(req: AuthenticatedRequest, res: Response) {
  try {
    const { classSectionId } = req.query;

    if (!classSectionId) {
      return res.status(400).json({ error: "classSectionId is required" });
    }

    const resources = await prisma.classResource.findMany({
      where: { classSectionId: classSectionId as string },
      orderBy: { createdAt: "desc" },
      include: {
        createdBy: { select: { fullName: true } }
      }
    });

    res.json(resources);
  } catch (error: any) {
    res.status(500).json({ error: error.message || "Failed to load class resources" });
  }
}

const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, path.join(__dirname, "../../uploads"));
  },
  filename: (req, file, cb) => {
    const sanitized = file.originalname.replace(/[^a-zA-Z0-9.-]/g, "_");
    const timestamp = Date.now();
    cb(null, `${timestamp}-${sanitized}`);
  }
});

export const fileUploadMiddleware = multer({
  storage,
  limits: { fileSize: 50 * 1024 * 1024 }
});

export async function uploadFileController(req: Request, res: Response) {
  try {
    if (!req.file) {
      return res.status(400).json({ error: "No file uploaded" });
    }
    const fileUrl = `${req.protocol}://${req.get("host")}/uploads/${req.file.filename}`;
    res.status(200).json({
      message: "File uploaded successfully",
      fileUrl,
      filename: req.file.originalname,
      size: req.file.size
    });
  } catch (error: any) {
    res.status(500).json({ error: error.message || "Failed to upload file" });
  }
}

export async function assignClassTeacher(req: AuthenticatedRequest, res: Response) {
  try {
    const { sectionId } = req.params;
    const { classTeacherId } = req.body; // TeacherProfile id or null

    if (!sectionId) {
      return res.status(400).json({ error: "classSectionId (sectionId) is required" });
    }

    if (classTeacherId) {
      // Check if the teacher profile exists
      const teacher = await prisma.teacherProfile.findUnique({
        where: { id: classTeacherId }
      });
      if (!teacher) {
        return res.status(404).json({ error: "Teacher profile not found" });
      }

      // Check if this teacher is already assigned to another class section
      const existingSection = await prisma.classSection.findFirst({
        where: {
          classTeacherId,
          id: { not: sectionId }
        }
      });

      if (existingSection) {
        // Unassign them from the other section first to prevent unique constraint violation
        await prisma.classSection.update({
          where: { id: existingSection.id },
          data: { classTeacherId: null }
        });
      }
    }

    const updatedSection = await prisma.classSection.update({
      where: { id: sectionId },
      data: { classTeacherId: classTeacherId || null },
      include: {
        classTeacher: {
          include: {
            user: { select: { fullName: true } }
          }
        }
      }
    });

    res.json({ message: "Class teacher assigned successfully", section: updatedSection });
  } catch (error: any) {
    res.status(500).json({ error: error.message || "Failed to assign class teacher" });
  }
}
