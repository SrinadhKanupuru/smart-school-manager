import { Response } from "express";
import { AuthenticatedRequest } from "../middlewares/auth";
import prisma from "../config/db";
import bcrypt from "bcryptjs";
import jwt from "jsonwebtoken";

const JWT_SECRET = process.env.JWT_SECRET || "smart_school_super_secret_key_123!";

export async function registerSchool(req: AuthenticatedRequest, res: Response) {
  try {
    const { schoolDetails, correspondentDetails } = req.body;

    if (!schoolDetails || !correspondentDetails) {
      return res.status(400).json({ error: "Missing school or user details" });
    }

    const existingUser = await prisma.user.findUnique({
      where: { email: correspondentDetails.email }
    });

    if (existingUser) {
      return res.status(400).json({ error: "Email is already registered" });
    }

    const existingSchool = await prisma.school.findUnique({
      where: { code: schoolDetails.code }
    });

    if (existingSchool) {
      return res.status(400).json({ error: "School code already exists" });
    }

    const passwordHash = await bcrypt.hash(correspondentDetails.password, 10);

    const result = await prisma.$transaction(async (tx) => {
      const school = await tx.school.create({
        data: {
          name: schoolDetails.name,
          code: schoolDetails.code,
          type: schoolDetails.type,
          board: schoolDetails.board,
          address: schoolDetails.address,
          city: schoolDetails.city,
          state: schoolDetails.state,
          country: schoolDetails.country,
          pinCode: schoolDetails.pinCode,
          contactNumber: schoolDetails.contactNumber,
        }
      });

      const user = await tx.user.create({
        data: {
          fullName: correspondentDetails.fullName,
          email: correspondentDetails.email,
          passwordHash,
          phoneNumber: correspondentDetails.phoneNumber,
          role: "CORRESPONDENT",
          schoolId: school.id
        }
      });

      return { school, user };
    });

    const token = jwt.sign(
      {
        id: result.user.id,
        email: result.user.email,
        role: result.user.role,
        schoolId: result.user.schoolId
      },
      JWT_SECRET,
      { expiresIn: "30d" }
    );

    res.status(201).json({
      token,
      user: {
        id: result.user.id,
        fullName: result.user.fullName,
        email: result.user.email,
        role: result.user.role,
        schoolId: result.user.schoolId
      },
      school: result.school
    });
  } catch (error: any) {
    res.status(500).json({ error: error.message || "Failed to register school" });
  }
}

export async function login(req: AuthenticatedRequest, res: Response) {
  try {
    const { email, password } = req.body;

    if (!email || !password) {
      return res.status(400).json({ error: "Email and password are required" });
    }

    const user = await prisma.user.findUnique({
      where: { email },
      include: { school: true }
    });

    if (!user) {
      return res.status(401).json({ error: "Invalid email or password" });
    }

    const passwordMatch = await bcrypt.compare(password, user.passwordHash);
    if (!passwordMatch) {
      return res.status(401).json({ error: "Invalid email or password" });
    }

    const token = jwt.sign(
      {
        id: user.id,
        email: user.email,
        role: user.role,
        schoolId: user.schoolId
      },
      JWT_SECRET,
      { expiresIn: "30d" }
    );

    res.json({
      token,
      user: {
        id: user.id,
        fullName: user.fullName,
        email: user.email,
        role: user.role,
        schoolId: user.schoolId
      },
      school: user.school
    });
  } catch (error: any) {
    res.status(500).json({ error: error.message || "Login failed" });
  }
}

export async function getCurrentUser(req: AuthenticatedRequest, res: Response) {
  try {
    if (!req.user) {
      return res.status(401).json({ error: "Unauthorized" });
    }

    const user = await prisma.user.findUnique({
      where: { id: req.user.id },
      include: {
        school: true,
        teacherProfile: {
          include: {
            classTeacherOf: {
              include: {
                class: true
              }
            }
          }
        },
        parentProfile: {
          include: {
            students: {
              include: {
                student: {
                  include: {
                    classSection: {
                      include: {
                        class: true
                      }
                    }
                  }
                }
              }
            }
          }
        },
        staffAttendances: {
          orderBy: { date: "desc" }
        },
        staffAttendanceLogs: {
          orderBy: { timestamp: "desc" }
        }
      }
    });

    if (!user) {
      return res.status(404).json({ error: "User not found" });
    }

    res.json(user);
  } catch (error: any) {
    res.status(500).json({ error: error.message || "Failed to load profile" });
  }
}
