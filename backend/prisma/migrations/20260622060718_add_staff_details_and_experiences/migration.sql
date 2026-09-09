/*
  Warnings:

  - You are about to drop the column `prevFromYear` on the `TeacherProfile` table. All the data in the column will be lost.
  - You are about to drop the column `prevOtherDetails` on the `TeacherProfile` table. All the data in the column will be lost.
  - You are about to drop the column `prevReason` on the `TeacherProfile` table. All the data in the column will be lost.
  - You are about to drop the column `prevSalary` on the `TeacherProfile` table. All the data in the column will be lost.
  - You are about to drop the column `prevSchool` on the `TeacherProfile` table. All the data in the column will be lost.
  - You are about to drop the column `prevSubject` on the `TeacherProfile` table. All the data in the column will be lost.
  - You are about to drop the column `prevToYear` on the `TeacherProfile` table. All the data in the column will be lost.

*/
-- AlterTable
ALTER TABLE "TeacherProfile" DROP COLUMN "prevFromYear",
DROP COLUMN "prevOtherDetails",
DROP COLUMN "prevReason",
DROP COLUMN "prevSalary",
DROP COLUMN "prevSchool",
DROP COLUMN "prevSubject",
DROP COLUMN "prevToYear",
ADD COLUMN     "aadhaarNo" TEXT,
ADD COLUMN     "bankAccountNo" TEXT,
ADD COLUMN     "bankBranch" TEXT,
ADD COLUMN     "bankIfsc" TEXT,
ADD COLUMN     "bankName" TEXT,
ADD COLUMN     "bloodGroup" TEXT,
ADD COLUMN     "emergencyContactName" TEXT,
ADD COLUMN     "emergencyContactPhone" TEXT,
ADD COLUMN     "permanentAddress" TEXT,
ADD COLUMN     "prevExperiences" TEXT;
