import { Response } from "express";
import { AuthenticatedRequest } from "../middlewares/auth";
import prisma from "../config/db";
import { getIO } from "../config/socket";

export async function getBusRoutes(req: AuthenticatedRequest, res: Response) {
  try {
    const schoolId = req.user?.schoolId;
    if (!schoolId) {
      return res.status(400).json({ error: "Missing school context" });
    }

    const routes = await prisma.busRoute.findMany({
      where: { schoolId },
      include: {
        stops: {
          orderBy: { sequenceNo: "asc" }
        },
        students: true,
        location: true
      }
    });

    res.json(routes);
  } catch (error: any) {
    res.status(500).json({ error: error.message || "Failed to load bus routes" });
  }
}

export async function createOrUpdateRoute(req: AuthenticatedRequest, res: Response) {
  try {
    const { routeName, busNo, driverName, driverContact, stops, studentIds } = req.body; // stops: Array<{ stopName: string, arrivalTime: string, sequenceNo: number }>, studentIds: string[]
    const schoolId = req.user?.schoolId;

    if (!routeName || !busNo || !driverName || !schoolId) {
      return res.status(400).json({ error: "Missing required route properties" });
    }

    const route = await prisma.$transaction(async (tx) => {
      const newRoute = await tx.busRoute.create({
        data: {
          schoolId,
          routeName,
          busNo,
          driverName,
          driverContact: driverContact || ""
        }
      });

      if (stops && Array.isArray(stops)) {
        const stopsOps = stops.map((stop) => {
          return tx.busStop.create({
            data: {
              routeId: newRoute.id,
              stopName: stop.stopName,
              arrivalTime: stop.arrivalTime,
              sequenceNo: typeof stop.sequenceNo === 'number' ? stop.sequenceNo : parseInt(stop.sequenceNo, 10)
            }
          });
        });
        await Promise.all(stopsOps);
      }

      if (studentIds && Array.isArray(studentIds) && studentIds.length > 0) {
        await tx.student.updateMany({
          where: { id: { in: studentIds } },
          data: { busRouteId: newRoute.id }
        });
      }

      return newRoute;
    });

    res.status(201).json({ message: "Bus route created successfully", route });
  } catch (error: any) {
    res.status(500).json({ error: error.message || "Failed to record transport route" });
  }
}

export async function updateBusLocation(req: AuthenticatedRequest, res: Response) {
  try {
    const { busRouteId, latitude, longitude, heading } = req.body;

    if (!busRouteId || latitude === undefined || longitude === undefined) {
      return res.status(400).json({ error: "Missing required properties: busRouteId, latitude, longitude" });
    }

    const lat = parseFloat(latitude);
    const lng = parseFloat(longitude);
    const head = heading !== undefined ? parseFloat(heading) : 0.0;

    if (isNaN(lat) || isNaN(lng)) {
      return res.status(400).json({ error: "Invalid coordinates format" });
    }

    // Verify that the bus route exists to avoid foreign key database constraint violations
    const routeExists = await prisma.busRoute.findUnique({
      where: { id: busRouteId }
    });

    if (!routeExists) {
      return res.status(404).json({ error: `Bus route with ID '${busRouteId}' not found` });
    }

    // Clean SQL UPSERT logic using Prisma
    const updatedLocation = await prisma.busLocation.upsert({
      where: { busRouteId },
      update: { latitude: lat, longitude: lng },
      create: { busRouteId, latitude: lat, longitude: lng }
    });

    // Wire up the scoped Socket.io room emitter ('bus_updates_${busId}')
    const io = getIO();
    io.to(`bus_updates_${busRouteId}`).emit("location_received", {
      busRouteId,
      latitude: lat,
      longitude: lng,
      heading: isNaN(head) ? 0.0 : head,
      updatedAt: updatedLocation.updatedAt
    });

    res.json({ message: "Bus location updated successfully", location: updatedLocation });
  } catch (error: any) {
    res.status(500).json({ error: error.message || "Failed to update bus location" });
  }
}
