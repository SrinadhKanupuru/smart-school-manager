import { Response } from "express";
import { AuthenticatedRequest } from "../middlewares/auth";
import prisma from "../config/db";
import bcrypt from "bcryptjs";

export async function addUser(req: AuthenticatedRequest, res: Response) {
  try {
    const { email, password, phoneNumber, fullName, role, details } = req.body;
    const schoolId = req.user?.schoolId;

    if (!schoolId) {
      return res.status(400).json({ error: "Missing school context" });
    }

    if (!email || !password || !fullName || !role) {
      return res.status(400).json({ error: "Required fields: email, password, fullName, role" });
    }

    // Authorization hierarchy:
    // CORRESPONDENT can create PRINCIPAL, HM, STAFF_HEAD, TEACHER, PT, PARENT
    // PRINCIPAL/HM can create STAFF_HEAD, TEACHER, PT, PARENT
    const creatorRole = req.user?.role;
    if (creatorRole !== "CORRESPONDENT" && creatorRole !== "PRINCIPAL" && creatorRole !== "HM") {
      return res.status(403).json({ error: "Permission denied to add users" });
    }

    if ((role === "PRINCIPAL" || role === "HM") && creatorRole !== "CORRESPONDENT") {
      return res.status(403).json({ error: "Only the Correspondent can create Principal or HM roles" });
    }

    const existingUser = await prisma.user.findUnique({ where: { email } });
    if (existingUser) {
      return res.status(400).json({ error: "Email is already registered" });
    }

    const passwordHash = await bcrypt.hash(password, 10);

    const user = await prisma.$transaction(async (tx) => {
      const newUser = await tx.user.create({
        data: {
          email,
          passwordHash,
          phoneNumber: phoneNumber || "",
          fullName,
          role,
          schoolId
        }
      });

      if (["PRINCIPAL", "HM", "STAFF_HEAD", "TEACHER", "PT"].includes(role)) {
        await tx.teacherProfile.create({
          data: {
            userId: newUser.id,
            qualification: details?.qualification || "",
            experienceYears: details?.experienceYears ? parseInt(details.experienceYears) : 0,
            salaryAmount: details?.salaryAmount ? parseFloat(details.salaryAmount) : 30000,
            prevExperiences: details?.prevExperiences || null,
            bankName: details?.bankName || null,
            bankAccountNo: details?.bankAccountNo || null,
            bankIfsc: details?.bankIfsc || null,
            bankBranch: details?.bankBranch || null,
            bloodGroup: details?.bloodGroup || null,
            aadhaarNo: details?.aadhaarNo || null,
            permanentAddress: details?.permanentAddress || null,
            emergencyContactName: details?.emergencyContactName || null,
            emergencyContactPhone: details?.emergencyContactPhone || null
          }
        });
      } else if (role === "PARENT") {
        await tx.parentProfile.create({
          data: {
            userId: newUser.id,
            relation: details?.relation || "FATHER"
          }
        });
      }

      return newUser;
    });

    res.status(201).json({
      message: `${role} user created successfully`,
      user: {
        id: user.id,
        fullName: user.fullName,
        email: user.email,
        role: user.role
      }
    });
  } catch (error: any) {
    res.status(500).json({ error: error.message || "Failed to create user" });
  }
}

export async function quickAddTeacher(req: any, res: Response) {
  try {
    const { fullName, email, phoneNumber, subject, handledClass, qualification, experienceYears, salaryAmount } = req.body;

    if (!fullName) {
      return res.status(400).json({ error: "Teacher full name is required" });
    }

    let school = await prisma.school.findFirst();
    if (!school) {
      school = await prisma.school.create({
        data: {
          name: "Smart Public School",
          code: "SPS-2026",
          type: "K12",
          board: "CBSE",
          address: "Main Campus, Education Hub",
          city: "New Delhi",
          state: "Delhi",
          country: "India",
          pinCode: "110001",
          contactNumber: "+91 98765 00000"
        }
      });
    }

    const teacherEmail = email && email.trim().length > 0 
      ? email.trim() 
      : `${fullName.toLowerCase().replace(/[^a-z0-9]/g, ".")}.${Date.now().toString().slice(-4)}@smartschool.edu`;

    const existingUser = await prisma.user.findUnique({ where: { email: teacherEmail } });
    if (existingUser) {
      return res.status(400).json({ error: "A user with this email already exists" });
    }

    const passwordHash = await bcrypt.hash("teacher123", 10);

    const result = await prisma.$transaction(async (tx) => {
      const newUser = await tx.user.create({
        data: {
          fullName: fullName.trim(),
          email: teacherEmail,
          phoneNumber: phoneNumber || "+91 98765 00000",
          passwordHash,
          role: "TEACHER",
          schoolId: school.id
        }
      });

      const profile = await tx.teacherProfile.create({
        data: {
          userId: newUser.id,
          qualification: qualification || "M.Sc., B.Ed",
          experienceYears: experienceYears ? parseInt(experienceYears.toString()) : 3,
          salaryAmount: salaryAmount ? parseFloat(salaryAmount.toString()) : 45000,
          workingStatus: "ACTIVE",
          permanentAddress: handledClass ? `Class Incharge: ${handledClass}` : undefined
        }
      });

      return { user: newUser, profile };
    });

    res.status(201).json({
      message: "Teacher added successfully to database",
      teacher: {
        id: result.user.id,
        fullName: result.user.fullName,
        email: result.user.email,
        phoneNumber: result.user.phoneNumber,
        role: result.user.role,
        schoolId: result.user.schoolId,
        profileId: result.profile.id,
        qualification: result.profile.qualification,
        salaryAmount: result.profile.salaryAmount
      }
    });
  } catch (error: any) {
    console.error("quickAddTeacher error:", error);
    res.status(500).json({ error: error.message || "Failed to add teacher" });
  }
}

export async function getTeachersList(req: any, res: Response) {
  try {
    const teachers = await prisma.teacherProfile.findMany({
      include: {
        user: {
          select: {
            id: true,
            fullName: true,
            email: true,
            phoneNumber: true,
            role: true,
            schoolId: true,
            createdAt: true
          }
        }
      },
      orderBy: { id: "desc" }
    });

    res.json({ count: teachers.length, teachers });
  } catch (error: any) {
    res.status(500).json({ error: error.message || "Failed to fetch teachers" });
  }
}

export async function getPrincipalsList(req: any, res: Response) {
  try {
    const principals = await prisma.user.findMany({
      where: {
        role: { in: ["PRINCIPAL", "HM", "CORRESPONDENT"] }
      },
      include: {
        school: true
      },
      orderBy: { createdAt: "desc" }
    });
    res.json({ count: principals.length, principals });
  } catch (error: any) {
    res.status(500).json({ error: error.message || "Failed to fetch principals" });
  }
}

export async function quickAddPrincipal(req: any, res: Response) {
  try {
    const { fullName, email, phoneNumber, qualification, branch } = req.body;
    if (!fullName) {
      return res.status(400).json({ error: "Full name is required" });
    }

    let school = await prisma.school.findFirst();
    if (!school) {
      school = await prisma.school.create({
        data: {
          name: branch || "Delhi Public International School",
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

    const principalEmail = email && email.trim().length > 0
      ? email.trim()
      : `principal.${Date.now().toString().slice(-4)}@smartschool.edu`;

    const passwordHash = await bcrypt.hash("principal123", 10);

    const newUser = await prisma.user.create({
      data: {
        fullName: fullName.trim(),
        email: principalEmail,
        phoneNumber: phoneNumber || "+91 98765 43210",
        passwordHash,
        role: "PRINCIPAL",
        schoolId: school.id
      },
      include: { school: true }
    });

    res.status(201).json({ message: "Principal created successfully", principal: newUser });
  } catch (error: any) {
    res.status(500).json({ error: error.message || "Failed to add principal" });
  }
}

export async function getParentsList(req: any, res: Response) {
  try {
    const parents = await prisma.parentProfile.findMany({
      include: {
        user: true,
        students: {
          include: {
            student: {
              include: {
                classSection: {
                  include: { class: true }
                }
              }
            }
          }
        }
      },
      orderBy: { id: "desc" }
    });
    res.json({ count: parents.length, parents });
  } catch (error: any) {
    res.status(500).json({ error: error.message || "Failed to fetch parents" });
  }
}

export async function getSchools(req: AuthenticatedRequest, res: Response) {
  try {
    const schools = await prisma.school.findMany({
      include: {
        _count: {
          select: { users: true }
        }
      }
    });
    res.json(schools);
  } catch (error: any) {
    res.status(500).json({ error: error.message || "Failed to list schools" });
  }
}

export async function getUsersByRole(req: AuthenticatedRequest, res: Response) {
  try {
    const schoolId = req.user?.schoolId;
    const role = req.query.role as string;

    if (!schoolId) {
      return res.status(400).json({ error: "Missing school context" });
    }

    const whereClause: any = { schoolId };
    if (role) {
      whereClause.role = role;
    }

    const users = await prisma.user.findMany({
      where: whereClause,
      include: {
        teacherProfile: {
          include: {
            timetables: {
              include: {
                classSection: {
                  include: {
                    class: true
                  }
                }
              }
            },
            salaryRecords: {
              orderBy: { generatedAt: "desc" }
            }
          }
        },
        parentProfile: {
          include: {
            students: {
              include: {
                student: true
              }
            }
          }
        },
        leaveRequests: {
          orderBy: { createdAt: "desc" }
        },
        staffAttendances: {
          orderBy: { date: "desc" }
        },
        staffAttendanceLogs: {
          orderBy: { timestamp: "desc" }
        }
      }
    });

    res.json(users);
  } catch (error: any) {
    res.status(500).json({ error: error.message || "Failed to retrieve users" });
  }
}

export async function addParentAndAssignStudents(req: AuthenticatedRequest, res: Response) {
  try {
    const { email, password, phoneNumber, fullName, relation, studentIds } = req.body;
    const schoolId = req.user?.schoolId;

    if (!schoolId) {
      return res.status(400).json({ error: "Missing school context" });
    }

    if (!email || !password || !fullName || !relation) {
      return res.status(400).json({ error: "Required fields: email, password, fullName, relation" });
    }

    const existingUser = await prisma.user.findUnique({ where: { email } });
    if (existingUser) {
      return res.status(400).json({ error: "Email is already registered" });
    }

    const passwordHash = await bcrypt.hash(password, 10);

    const user = await prisma.$transaction(async (tx) => {
      const newUser = await tx.user.create({
        data: {
          email,
          passwordHash,
          phoneNumber: phoneNumber || "",
          fullName,
          role: "PARENT",
          schoolId
        }
      });

      const parentProfile = await tx.parentProfile.create({
        data: {
          userId: newUser.id,
          relation: relation || "FATHER"
        }
      });

      // Link students to this parent
      if (studentIds && Array.isArray(studentIds) && studentIds.length > 0) {
        const links = studentIds.map((studentId: string) => ({
          parentId: parentProfile.id,
          studentId: studentId
        }));
        await tx.parentToStudent.createMany({
          data: links
        });
      }

      return newUser;
    });

    res.status(201).json({
      message: "Parent user created and children assigned successfully",
      user: {
        id: user.id,
        fullName: user.fullName,
        email: user.email,
        role: user.role
      }
    });
  } catch (error: any) {
    res.status(500).json({ error: error.message || "Failed to create parent user" });
  }
}

export async function updateSchool(req: AuthenticatedRequest, res: Response) {
  try {
    const { schoolId } = req.params;
    const {
      name,
      type,
      board,
      address,
      city,
      state,
      country,
      pinCode,
      contactNumber,
      latitude,
      longitude,
      geofenceRadius,
      weeklyOffs,
      halfDayThreshold,
      fullDayThreshold,
      casualLeaveLimit,
      sickLeaveLimit,
      rectificationLimit,
      autoCheckoutEnabled,
      autoCheckoutTime
    } = req.body;

    const school = await prisma.school.update({
      where: { id: schoolId },
      data: {
        name,
        type,
        board,
        address,
        city,
        state,
        country,
        pinCode,
        contactNumber,
        latitude: latitude !== undefined && latitude !== null ? parseFloat(latitude) : undefined,
        longitude: longitude !== undefined && longitude !== null ? parseFloat(longitude) : undefined,
        geofenceRadius: geofenceRadius !== undefined && geofenceRadius !== null ? parseFloat(geofenceRadius) : undefined,
        weeklyOffs: weeklyOffs !== undefined ? weeklyOffs : undefined,
        halfDayThreshold: halfDayThreshold !== undefined && halfDayThreshold !== null ? parseFloat(halfDayThreshold) : undefined,
        fullDayThreshold: fullDayThreshold !== undefined && fullDayThreshold !== null ? parseFloat(fullDayThreshold) : undefined,
        casualLeaveLimit: casualLeaveLimit !== undefined && casualLeaveLimit !== null ? parseInt(casualLeaveLimit) : undefined,
        sickLeaveLimit: sickLeaveLimit !== undefined && sickLeaveLimit !== null ? parseInt(sickLeaveLimit) : undefined,
        rectificationLimit: rectificationLimit !== undefined && rectificationLimit !== null ? parseInt(rectificationLimit) : undefined,
        autoCheckoutEnabled: autoCheckoutEnabled !== undefined ? autoCheckoutEnabled : undefined,
        autoCheckoutTime: autoCheckoutTime !== undefined ? autoCheckoutTime : undefined,
      }
    });

    res.json({ message: "School details updated successfully", school });
  } catch (error: any) {
    res.status(500).json({ error: error.message || "Failed to update school details" });
  }
}

export async function deleteSchool(req: AuthenticatedRequest, res: Response) {
  try {
    const { schoolId } = req.params;

    await prisma.school.delete({
      where: { id: schoolId }
    });

    res.json({ message: "School deleted successfully" });
  } catch (error: any) {
    res.status(500).json({ error: error.message || "Failed to delete school" });
  }
}

export async function createSchool(req: AuthenticatedRequest, res: Response) {
  try {
    const { name, code, type, board, address, city, state, country, pinCode, contactNumber } = req.body;

    if (!name || !code || !type || !board || !address || !city || !state || !country || !pinCode || !contactNumber) {
      return res.status(400).json({ error: "Missing required school details" });
    }

    const existingSchool = await prisma.school.findUnique({
      where: { code }
    });

    if (existingSchool) {
      return res.status(400).json({ error: "School code already exists" });
    }

    const school = await prisma.school.create({
      data: {
        name,
        code,
        type,
        board,
        address,
        city,
        state,
        country,
        pinCode,
        contactNumber,
      }
    });

    res.status(201).json({ message: "School created successfully", school });
  } catch (error: any) {
    res.status(500).json({ error: error.message || "Failed to create school" });
  }
}

