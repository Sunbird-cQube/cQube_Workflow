import * as config from '../../assets/config.json';
import { environment } from '../../environments/environment';

let state = config.default[`${environment.stateName}`].name;
export const dashboardReportDescriptions = {
    imrTooltip: "This geo-location-based dashboard provides insights on school infrastructure access across " + state + ".",
    crTooltip: "This dashboard allows users to correlate various available metrics on school infrastructure data using a combined visualisation of the scatter plot and table.",
    udiseTooltip: "This geo-location dashboard converts data available in UDISE into actionable indices that can be visualised at various administrative levels across " + state + ".",
    compositeTooltip: "This dashboard brings metrics from other dashboards and allows users to correlate various metrics among each other.",
    dscTooltip: "This dashboard provides insights on grade and subject-wise consumption of TPD courses broken by user type.",
    dccTooltip: "This dashboard provides insight on district-wise usage of TPD courses",
    utTooltip: "This dashboard provides insights on district-wise usage of ETB",
    dtrTooltip: "This dashboard provides insights on total usage at the course content level.",
    utcTooltip: "This dashboard provides insights on the total usage at the ETB content level.",
    crcrTooltip: "This dashboard allows users to correlate various available metrics calculated from the CRC visit data using a combined visualisation of the scatter plot and table.",
    srTooltip: "This geo-location-based dashboard provides insights on student semester performance across " + state + ".",
    patTooltip: "This geo-location-based dashboard provides insights on student Periodic Assessment Test (PAT) performance across " + state + ".",
    semExpTooltip: "This geo-location-based dashboard provides insights on those schools that did not upload their semester scores.",
    isdataTooltip: "This dashboard allows you to download exception reports for the different dashboards available on cQube",
    sarTooltip: "This geo-location-based dashboard provides insights on Student Attendance across " + state + ".",
    tarTooltip: "This geo-location-based dashboard provides insights on Teacher Attendance across " + state + ".",
    telemDataTooltip: "This dashboard provides insights on usage statistics for cQube",
    heatChartTooltip: "This dashboard provides insights on student performance at the question level.",
    lotableTooltip: "This dashboard provides insights on student performance at the learning outcome level.",
    tpdtpTooltip: "This dashboard provides details on district-wise TPD course enrolment progress broken at the individual course level.",
    tpdcpTooltip: "This dashboard provides details on district-wise TPD course enrolment progress broken at the individual course level.",
    healthCardTooltip: "This dashboard brings metrics from other dashboards and allows users to correlate various metrics among each other.",
    patExcptTooltip: "This geo-location-based dashboard provides insights on those schools that did not upload their periodic assessment scores.",
    tarExpTooltip: "This geo-location-based dashboard provides insights on those schools that did not upload their teacher attendance data.",
    sarExcptTooltip: "This geo-location-based dashboard provides insights on those schools that did not upload their student attendance data.",
    satTooltip: "This geo-location-based dashboard provides insights on student Periodic Assessment Test (SAT) performance across " + state + ".",
    satHeatChartTooltip: "This dashboard provides insights on student performance at the question level."
}