import { Response } from "express";
import { AuthenticatedRequest } from "../middlewares/auth";
import prisma from "../config/db";
import { ComponentCategory, CalculationType } from "@prisma/client";

// GET /school/salary-components
export async function getSalaryComponents(req: AuthenticatedRequest, res: Response) {
  try {
    const schoolId = req.user?.schoolId;
    if (!schoolId) {
      return res.status(400).json({ error: "Missing school context" });
    }

    const components = await prisma.salaryComponent.findMany({
      where: { schoolId, isActive: true },
      orderBy: { name: "asc" }
    });

    const categories = Object.values(ComponentCategory);

    res.json({
      categories,
      components
    });
  } catch (error: any) {
    res.status(500).json({ error: error.message || "Failed to retrieve salary components" });
  }
}

// POST /school/salary-components
export async function createSalaryComponent(req: AuthenticatedRequest, res: Response) {
  try {
    const schoolId = req.user?.schoolId;
    const { name, category, isTaxable, isProrated } = req.body;

    if (!schoolId) {
      return res.status(400).json({ error: "Missing school context" });
    }
    if (!name || !category) {
      return res.status(400).json({ error: "Name and category are required" });
    }

    if (!Object.values(ComponentCategory).includes(category as ComponentCategory)) {
      return res.status(400).json({ error: `Invalid category. Must be one of: ${Object.values(ComponentCategory).join(", ")}` });
    }

    const component = await prisma.salaryComponent.create({
      data: {
        schoolId,
        name,
        category: category as ComponentCategory,
        isTaxable: isTaxable !== undefined ? isTaxable : true,
        isProrated: isProrated !== undefined ? isProrated : true
      }
    });

    res.status(201).json({ message: "Salary component created successfully", component });
  } catch (error: any) {
    res.status(500).json({ error: error.message || "Failed to create salary component" });
  }
}

// GET /school/salary-templates
export async function getSalaryTemplates(req: AuthenticatedRequest, res: Response) {
  try {
    const schoolId = req.user?.schoolId;
    if (!schoolId) {
      return res.status(400).json({ error: "Missing school context" });
    }

    const templates = await prisma.salaryTemplate.findMany({
      where: { schoolId },
      include: {
        components: {
          include: {
            component: true
          }
        }
      },
      orderBy: { name: "asc" }
    });

    res.json(templates);
  } catch (error: any) {
    res.status(500).json({ error: error.message || "Failed to retrieve salary templates" });
  }
}

// POST /school/salary-templates
export async function createSalaryTemplate(req: AuthenticatedRequest, res: Response) {
  try {
    const schoolId = req.user?.schoolId;
    const { name, description, components } = req.body;

    if (!schoolId) {
      return res.status(400).json({ error: "Missing school context" });
    }
    if (!name || !components || !Array.isArray(components)) {
      return res.status(400).json({ error: "Name and components array are required" });
    }

    const template = await prisma.$transaction(async (tx) => {
      const newTemplate = await tx.salaryTemplate.create({
        data: {
          schoolId,
          name,
          description,
          overtimeMultiplier: req.body.overtimeMultiplier ? parseFloat(req.body.overtimeMultiplier) : null
        }
      });

      for (const comp of components) {
        await tx.templateComponent.create({
          data: {
            templateId: newTemplate.id,
            componentId: comp.componentId,
            calculationType: comp.calculationType as CalculationType,
            value: parseFloat(comp.value),
            calculateOnMax: comp.calculateOnMax ? parseFloat(comp.calculateOnMax) : null,
            activeOnlyIfGrossLessThan: comp.activeOnlyIfGrossLessThan ? parseFloat(comp.activeOnlyIfGrossLessThan) : null
          }
        });
      }

      return newTemplate;
    });

    const fullTemplate = await prisma.salaryTemplate.findUnique({
      where: { id: template.id },
      include: {
        components: {
          include: {
            component: true
          }
        }
      }
    });

    res.status(201).json({ message: "Salary template created successfully", template: fullTemplate });
  } catch (error: any) {
    res.status(500).json({ error: error.message || "Failed to create salary template" });
  }
}

// PUT /school/salary-templates/:id
export async function updateSalaryTemplate(req: AuthenticatedRequest, res: Response) {
  try {
    const { id } = req.params;
    const { name, description, components, overtimeMultiplier } = req.body;

    const existingTemplate = await prisma.salaryTemplate.findUnique({
      where: { id }
    });
    if (!existingTemplate) {
      return res.status(404).json({ error: "Salary template not found" });
    }

    await prisma.$transaction(async (tx) => {
      await tx.salaryTemplate.update({
        where: { id },
        data: {
          name: name !== undefined ? name : undefined,
          description: description !== undefined ? description : undefined,
          overtimeMultiplier: overtimeMultiplier !== undefined ? (overtimeMultiplier ? parseFloat(overtimeMultiplier) : null) : undefined
        }
      });

      if (components && Array.isArray(components)) {
        // Delete existing relations
        await tx.templateComponent.deleteMany({
          where: { templateId: id }
        });

        // Add new relations
        for (const comp of components) {
          await tx.templateComponent.create({
            data: {
              templateId: id,
              componentId: comp.componentId,
              calculationType: comp.calculationType as CalculationType,
              value: parseFloat(comp.value),
              calculateOnMax: comp.calculateOnMax ? parseFloat(comp.calculateOnMax) : null,
              activeOnlyIfGrossLessThan: comp.activeOnlyIfGrossLessThan ? parseFloat(comp.activeOnlyIfGrossLessThan) : null
            }
          });
        }
      }
    });

    const updatedTemplate = await prisma.salaryTemplate.findUnique({
      where: { id },
      include: {
        components: {
          include: {
            component: true
          }
        }
      }
    });

    res.json({ message: "Salary template updated successfully", template: updatedTemplate });
  } catch (error: any) {
    res.status(500).json({ error: error.message || "Failed to update salary template" });
  }
}

// DELETE /school/salary-templates/:id
export async function deleteSalaryTemplate(req: AuthenticatedRequest, res: Response) {
  try {
    const { id } = req.params;
    
    // Check if assigned to any teachers
    const count = await prisma.teacherProfile.count({
      where: { salaryTemplateId: id }
    });

    if (count > 0) {
      return res.status(400).json({ error: "Cannot delete template: It is assigned to one or more staff members." });
    }

    await prisma.salaryTemplate.delete({
      where: { id }
    });

    res.json({ message: "Salary template deleted successfully" });
  } catch (error: any) {
    res.status(500).json({ error: error.message || "Failed to delete salary template" });
  }
}

// PUT /school/teachers/:teacherId/salary-template
export async function assignSalaryTemplate(req: AuthenticatedRequest, res: Response) {
  try {
    const { teacherId } = req.params;
    const { salaryTemplateId } = req.body;

    const teacher = await prisma.teacherProfile.findUnique({
      where: { id: teacherId }
    });
    if (!teacher) {
      return res.status(404).json({ error: "Teacher profile not found" });
    }

    if (salaryTemplateId) {
      const template = await prisma.salaryTemplate.findUnique({
        where: { id: salaryTemplateId }
      });
      if (!template) {
        return res.status(404).json({ error: "Salary template not found" });
      }
    }

    const updated = await prisma.teacherProfile.update({
      where: { id: teacherId },
      data: {
        salaryTemplateId: salaryTemplateId || null
      },
      include: {
        user: true,
        salaryTemplate: true
      }
    });

    res.json({ message: "Salary template assigned successfully", teacher: updated });
  } catch (error: any) {
    res.status(500).json({ error: error.message || "Failed to assign salary template" });
  }
}

// DELETE /school/salary-components/:id
export async function deleteSalaryComponent(req: AuthenticatedRequest, res: Response) {
  try {
    const { id } = req.params;
    
    // Check if component is used in any templates
    const count = await prisma.templateComponent.count({
      where: { componentId: id }
    });

    if (count > 0) {
      return res.status(400).json({ error: "Cannot delete component: It is used in one or more templates." });
    }

    await prisma.salaryComponent.update({
      where: { id },
      data: { isActive: false }
    });

    res.json({ message: "Salary component deleted successfully" });
  } catch (error: any) {
    res.status(500).json({ error: error.message || "Failed to delete salary component" });
  }
}

// GET /school/variable-pay
export async function getVariablePays(req: AuthenticatedRequest, res: Response) {
  try {
    const { teacherId, month, year } = req.query;
    if (!teacherId) {
      return res.status(400).json({ error: "teacherId is required" });
    }

    const where: any = { teacherId: String(teacherId) };
    if (month) where.month = String(month);
    if (year) where.year = parseInt(String(year));

    const variables = await prisma.variablePay.findMany({
      where,
      include: {
        component: true
      },
      orderBy: { createdAt: "desc" }
    });

    res.json(variables);
  } catch (error: any) {
    res.status(500).json({ error: error.message || "Failed to retrieve variable pays" });
  }
}

// POST /school/variable-pay
export async function createVariablePay(req: AuthenticatedRequest, res: Response) {
  try {
    const { teacherId, componentId, month, year, amount, remarks, isArrear } = req.body;
    if (!teacherId || !componentId || !month || !year || amount === undefined) {
      return res.status(400).json({ error: "Missing required fields: teacherId, componentId, month, year, amount" });
    }

    const variable = await prisma.variablePay.create({
      data: {
        teacherId,
        componentId,
        month,
        year: parseInt(year),
        amount: parseFloat(amount),
        remarks: remarks || null,
        isArrear: isArrear === true
      },
      include: {
        component: true
      }
    });

    res.status(201).json({ message: "Variable pay added successfully", variable });
  } catch (error: any) {
    res.status(500).json({ error: error.message || "Failed to create variable pay" });
  }
}

// DELETE /school/variable-pay/:id
export async function deleteVariablePay(req: AuthenticatedRequest, res: Response) {
  try {
    const { id } = req.params;
    await prisma.variablePay.delete({
      where: { id }
    });
    res.json({ message: "Variable pay deleted successfully" });
  } catch (error: any) {
    res.status(500).json({ error: error.message || "Failed to delete variable pay" });
  }
}


