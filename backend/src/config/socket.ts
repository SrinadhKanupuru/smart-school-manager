import { Server as HttpServer } from "http";
import { Server as SocketIOServer } from "socket.io";

let io: SocketIOServer | null = null;

export function initSocket(server: HttpServer): SocketIOServer {
  io = new SocketIOServer(server, {
    cors: {
      origin: "*",
      methods: ["GET", "POST"],
    },
  });

  io.on("connection", (socket) => {
    console.log(`[Socket] Client connected: ${socket.id}`);

    socket.on("join_route", (busId: string) => {
      const room = `bus_updates_${busId}`;
      socket.join(room);
      console.log(`[Socket] Client ${socket.id} joined room: ${room}`);
    });

    socket.on("leave_route", (busId: string) => {
      const room = `bus_updates_${busId}`;
      socket.leave(room);
      console.log(`[Socket] Client ${socket.id} left room: ${room}`);
    });

    socket.on("disconnect", () => {
      console.log(`[Socket] Client disconnected: ${socket.id}`);
    });
  });

  return io;
}

export function getIO(): SocketIOServer {
  if (!io) {
    throw new Error("Socket.io has not been initialized!");
  }
  return io;
}
