import express, { Request, Response, NextFunction } from "express";
import cors from "cors";
import dotenv from "dotenv";
import apiRoutes from "./routes/api.routes";
import path from "path";
import fs from "fs";

dotenv.config();

const app = express();

app.use(cors());
app.use(express.json());

// Ensure uploads and public folders exist
const uploadsDir = path.join(__dirname, "../uploads");
if (!fs.existsSync(uploadsDir)) {
  fs.mkdirSync(uploadsDir, { recursive: true });
}
const publicDir = path.join(__dirname, "../public");
if (!fs.existsSync(publicDir)) {
  fs.mkdirSync(publicDir, { recursive: true });
}

// Serve static files
app.use("/uploads", express.static(uploadsDir));
app.use(express.static(publicDir));

// Main API Route base
app.use("/api", apiRoutes);

// Test endpoint
app.get("/health", (req: Request, res: Response) => {
  res.json({ status: "healthy", timestamp: new Date() });
});

// Catch-all route to serve the web dashboard
app.get("*", (req: Request, res: Response) => {
  res.sendFile(path.join(publicDir, "index.html"));
});

// Error handling middleware
app.use((err: any, req: Request, res: Response, next: NextFunction) => {
  console.error(err.stack);
  res.status(500).json({ error: err.message || "Internal Server Error" });
});

export default app;
