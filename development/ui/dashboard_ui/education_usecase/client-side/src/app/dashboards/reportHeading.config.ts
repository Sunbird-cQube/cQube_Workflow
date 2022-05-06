import * as config from '../../assets/config.json';
import { environment } from '../../environments/environment';

let state = config.default[`${environment.stateName}`].name;
export const dashboardReportHeadings = {

  // ----School Infrastructure reports -----
  InfrastructureAccessbyLocation: "Infrastructure Access by Location",
  CompositeReport: "Infrastructure Composite Report",
  UDISEReport: "UDISE Report",

  // ---- student Perfomance reports ----
  SemesterAssesmentTest: "Semester Assesment Test",
  SemesterAssesmentTestHeatchart: "Semester Assesment Test Heat-chart",
  PeriodicAssesmentTest: "Periodic Assesment Test",
  PeriodicAssesmentTestHeatchart: "Periodic Assesment Test Heat-chart",
  PeriodicAssesmentTestLOTable: "Periodic Assesment Test LO-Table",

  // --- student Attendance reports ---
  StudentAttendance: "Student Attendance",
  TeacherAttendance: "Teacher Attendance",

  // ----  Teacher Profesional Development reports ------
  UsagebyCourse: "Usage by Course",
  UsageByCourseContent: "Usage By Course Content",
  TPDCourseProgress: "Course Progress",
  UserProgress: "User Progress",
  tpdGpsOfLearning: "GPS of learning- Courses",
  ContentPreference: "Content Preference",
  UserEngagement: "User Engagement",

  // ---- ETB reports --------
  UsagebyUserProfile: "Usage by User Profile",
  UsagebyTextbook: "Usage by Textbook ",
  UsageByTextbookContent: "Usage By Textbook Content",
  etbGpsOfLearning: "GPS of learning- ETB",
  Usagepercapita: "Usage Per Capita",
  heartbeatOfTheNationLearning: "  Heartbeat of the Nation Learning",
  UserOnboarding: "User Onboarding",

  // ------ crc visits reports ---------
  CRCReport: "CRC Report",

  // ------ composite reports across metrics----
  CompositeReportAcrossMetrics: "Composite Report Across Metrics",

  // ------- progress card reports ---
  ProgressReport: "Progress Report",

  // ------Exception reports -----
  SemesterAssesmentTestException: "Semester Assesment Test Exception",
  PeriodicAssesmentTestException: "Periodic Assesment Test Exception",
  DownloadExceptionList: "Download Exception List",
  StudentAttendanceReportException: "Student Attendance Report Exception",
  TeacherAttendanceReportException: "Teacher Attendance Report Exception",

  // --- telemetry reports -------
  Telemetry: "Telemetry"



}