import app from "./app";
import { createServer } from "http";
import { initSocket } from "./config/socket";
import { startScheduler } from "./services/scheduler.service";

const PORT = process.env.PORT || 5000;

const server = createServer(app);
initSocket(server);

server.listen(PORT, () => {
  console.log(`===============================================`);
  console.log(`   Smart School Management Server Started      `);
  console.log(`   Running on http://localhost:${PORT}        `);
  console.log(`===============================================`);
  
  // Start the background scheduler
  startScheduler();
});
