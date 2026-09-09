-- AlterTable
ALTER TABLE "LeaveType" ADD COLUMN     "maxDaysMid" INTEGER,
ADD COLUMN     "maxDaysSenior" INTEGER,
ADD COLUMN     "period" TEXT NOT NULL DEFAULT 'YEARLY';
