const router = require('express').Router();
const dist_wise_data = require('./controller/attendanceRoutes/student_attendance/dist_wise_data');
const block_wise_data = require('./controller/attendanceRoutes/student_attendance/block_wise_data');
const cluster_wise_data = require('./controller/attendanceRoutes/student_attendance/cluster_wise_data');
const school_wise_data = require('./controller/attendanceRoutes/student_attendance/school_wise_data');
const getDateRange = require('./controller/attendanceRoutes/student_attendance/getDateRange');

const tAttd_distWise = require('./controller/attendanceRoutes/teacher_attendance/dist_wise_data');
const tAttd_blockWise = require('./controller/attendanceRoutes/teacher_attendance/block_wise_data');
const tAttd_clusterWise = require('./controller/attendanceRoutes/teacher_attendance/cluster_wise_data');
const tAttd_schoolWise = require('./controller/attendanceRoutes/teacher_attendance/school_wise_data');
const tAttd_dateRange = require('./controller/attendanceRoutes/teacher_attendance/getDateRange');

const changePasswd = require('./controller/users/changePassword');

//deeksha
const deekshaData = require('./controller/diksha/diksha');
const dikshaTable = require('./controller/diksha/dikshaTable');
const diskhaBarChart = require('./controller/diksha/diksha-bar-chart');

//Show telemetry
const showDistTelemetry = require('./controller/telemetry/showTelemetry/distTelemetryData');
const showBlockTelemetry = require('./controller/telemetry/showTelemetry/blockTelemetryData');
const showClusterTelemetry = require('./controller/telemetry/showTelemetry/clusterTelemetryData');
const showSchoolTelemetry = require('./controller/telemetry/showTelemetry/schoolTelemetryData');

//completion report...
const sem_completionDist = require('./controller/completionReports/semester/districtWise')
const sem_completionBlock = require('./controller/completionReports/semester/blockWise')
const sem_completionCluster = require('./controller/completionReports/semester/clusterWise')
const sem_completionSchool = require('./controller/completionReports/semester/schoolWise')

const school_invalid = require('./controller/completionReports/school_invalid');

//PAT Exception Report

const patExceptDistWise = require('./controller/completionReports/patException/districtWise');
const patExceptBlockWise = require('./controller/completionReports/patException/blockWise');
const patExceptClusterWise = require('./controller/completionReports/patException/clusterWise');
const patExceptSchoolWise = require('./controller/completionReports/patException/schoolWise');

const telemetryData = require('../api/controller/telemetry/telemetryData');

// const crcData = require('./controller/users/crcData');
// crc files
const crcDistrictWise = require('../api/controller/crcRoutes/districtWise');
const crcBlockWise = require('../api/controller/crcRoutes/blockWise');
const crcClusterWise = require('../api/controller/crcRoutes/clusterWise');
const crcSchoolWise = require('../api/controller/crcRoutes/schoolWise');

//Infra
const infraDistWise = require('../api/controller/Infra/infra-distWise');
const infraBlockWise = require('../api/controller/Infra/infra-blockWise');
const infraClusterWise = require('../api/controller/Infra/infra-clusterWise');
const infraSchoolWise = require('../api/controller/Infra/infra-schoolWise');

const infraMapDistWise = require('../api/controller/Infra/report_map/infraDistWise');
const infraMapBlockWise = require('../api/controller/Infra/report_map/infraBlockWise');
const infraMapClusterWise = require('../api/controller/Infra/report_map/infraClusterWise');
const infraMapSchoolWise = require('../api/controller/Infra/report_map/infraSchoolWise');

const semDistrictWise = require('../api/controller/semRoutes/districtWise');
const semBlockWise = require('../api/controller/semRoutes/blockWise');
const semClusterWise = require('../api/controller/semRoutes/clusterWise');
const semSchoolWise = require('../api/controller/semRoutes/schoolWise');
const semMeta = require('./controller/semRoutes/metaData');

//UDISE report

const UDISE_dist_wise = require('./controller/udise-report/dist-wise');
const UDISE_block_wise = require('./controller/udise-report/block-wise');
const UDISE_cluster_wise = require('./controller/udise-report/cluster-wise');
const UDISE_school_wise = require('./controller/udise-report/school-wise');

//PAT report
const PAT_dist_wise = require('./controller/patRoutes/distWise');
const PAT_block_wise = require('./controller/patRoutes/blockWise');
const PAT_cluster_wise = require('./controller/patRoutes/clusterWise');
const PAT_school_wise = require('./controller/patRoutes/schoolWise');
const getMonthYear = require('./controller/patRoutes/getMonthYear');

// Composit report
const composit_dist_wise = require('./controller/composit-report/distWise');
const composit_block_wise = require('./controller/composit-report/blockWise');
const composit_cluster_wise = require('./controller/composit-report/clusterWise');
const composit_school_wise = require('./controller/composit-report/schoolWise');

// Heat chart
const heatDistWise = require('./controller/patRoutes/heatChart/distWise');
const heatBlockWise = require('./controller/patRoutes/heatChart/blockWise');
const heatClusterWise = require('./controller/patRoutes/heatChart/clusterWise');
const heatSchoolWise = require('./controller/patRoutes/heatChart/schoolWise');
const heatMetaData = require('./controller/patRoutes/heatChart/metaData');

// Pat LO table
const loTableDistWise = require('./controller/patRoutes/patLoTable/distWise');
const loTableBlockWise = require('./controller/patRoutes/patLoTable/blockWise');
const loTableClusterWise = require('./controller/patRoutes/patLoTable/clusterWise');
const loTableSchoolWise = require('./controller/patRoutes/patLoTable/schoolWise');

// Diksha TPD
const tpdDistWise = require('./controller/diksha/tpd-heatChart/distWise');
const tpdBlockWise = require('./controller/diksha/tpd-heatChart/blockWise');
const tpdClusterWise = require('./controller/diksha/tpd-heatChart/clusterWise');
const tpdSchoolWise = require('./controller/diksha/tpd-heatChart/schoolWise');
const courseFilter = require('./controller/diksha/tpd-heatChart/courseFilter');

//diksha TPD enrollment/completion
const distLevel = require('./controller/diksha/tpd-enroll-completion/distWise');
const blockLevel = require('./controller/diksha/tpd-enroll-completion/blockWise');
const clusterLevel = require('./controller/diksha/tpd-enroll-completion/clusterWise');
const schoolLevel = require('./controller/diksha/tpd-enroll-completion/schoolWise');


// sem routes
router.use('/sem', semDistrictWise);
router.use('/sem', semBlockWise);
router.use('/sem', semClusterWise);
router.use('/sem', semSchoolWise);
router.use('/sem', semMeta);

// crc routes
router.use('/crc', crcDistrictWise);
router.use('/crc', crcBlockWise);
router.use('/crc', crcClusterWise);
router.use('/crc', crcSchoolWise);

// attendance routes
router.use('/attendance', dist_wise_data);
router.use('/attendance', block_wise_data);
router.use('/attendance', cluster_wise_data);
router.use('/attendance', school_wise_data);
router.use('/attendance', getDateRange)

//teacher attendance routes
router.use('/teacher_attendance', tAttd_distWise);
router.use('/teacher_attendance', tAttd_blockWise);
router.use('/teacher_attendance', tAttd_clusterWise);
router.use('/teacher_attendance', tAttd_schoolWise);
router.use('/teacher_attendance', tAttd_dateRange);

// user details routes
router.use('/changePassword', changePasswd);

// Infra
router.use('/infra', infraDistWise);
router.use('/infra', infraBlockWise);
router.use('/infra', infraClusterWise);
router.use('/infra', infraSchoolWise);

router.use('/infraMap', infraMapDistWise);
router.use('/infraMap', infraMapBlockWise);
router.use('/infraMap', infraMapClusterWise);
router.use('/infraMap', infraMapSchoolWise);

router.use('/deeksha', deekshaData);
router.use('/telemetry', telemetryData);
router.use('/diksha', deekshaData);
router.use('/dikshaTable', dikshaTable);
router.use('/dikshaBarChart', diskhaBarChart);

// Semester completion report
router.use('/semCompDist', sem_completionDist);
router.use('/semCompBlock', sem_completionBlock);
router.use('/semCompCluster', sem_completionCluster);
router.use('/semCompSchool', sem_completionSchool);

router.use('/school_invalid', school_invalid);

///////
router.use('/patExcetpion', patExceptDistWise);
router.use('/patExcetpion', patExceptBlockWise);
router.use('/patExcetpion', patExceptClusterWise);
router.use('/patExcetpion', patExceptSchoolWise);

//show telemetry
router.use('/showDistTelemetry', showDistTelemetry);
router.use('/showBlockTelemetry', showBlockTelemetry);
router.use('/showClusterTelemetry', showClusterTelemetry);
router.use('/showSchoolTelemetry', showSchoolTelemetry);

// progressCard
const progressCardMeta = require('./controller/progressCard/metadata');
const stateData = require('./controller/progressCard/stateData');
const districtprogressCard = require('./controller/progressCard/districtWise');
const blockprogressCard = require('./controller/progressCard/blockWise');
const clusterprogressCard = require('./controller/progressCard/clusterWise');
const schoolprogressCard = require('./controller/progressCard/schoolWise');

router.use('/progressCard', progressCardMeta);
router.use('/progressCard', stateData);
router.use('/progressCard', districtprogressCard);
router.use('/progressCard', blockprogressCard);
router.use('/progressCard', clusterprogressCard);
router.use('/progressCard', schoolprogressCard);

//Udise......
router.use('/udise', UDISE_dist_wise);
router.use('/udise', UDISE_block_wise);
router.use('/udise', UDISE_cluster_wise);
router.use('/udise', UDISE_school_wise);

//PAT......
router.use('/pat', PAT_dist_wise);
router.use('/pat', PAT_block_wise);
router.use('/pat', PAT_cluster_wise);
router.use('/pat', PAT_school_wise);
router.use('/pat', getMonthYear);

//composit report
router.use('/composit', composit_dist_wise);
router.use('/composit', composit_block_wise);
router.use('/composit', composit_cluster_wise);
router.use('/composit', composit_school_wise);

//HeatCharts
router.use('/pat/heatChart', heatDistWise);
router.use('/pat/heatChart', heatBlockWise);
router.use('/pat/heatChart', heatClusterWise);
router.use('/pat/heatChart', heatSchoolWise);
router.use('/pat/heatChart', heatMetaData);

//Pat LO table
router.use('/pat/lotable', loTableDistWise);
router.use('/pat/lotable', loTableBlockWise);
router.use('/pat/lotable', loTableClusterWise);
router.use('/pat/lotable', loTableSchoolWise);

// Diksha TPD
router.use('/diksha/tpd', tpdDistWise);
router.use('/diksha/tpd', tpdBlockWise);
router.use('/diksha/tpd', tpdClusterWise);
router.use('/diksha/tpd', tpdSchoolWise);
router.use('/diksha/course-filter', courseFilter);


const dataSource = require('./controller/dataSource');
const { route } = require('../api/controller/Infra/report_map/infraDistWise');
router.use('/dataSource', dataSource);

//diksha TPD enrollment/completion
router.use('/tpd', distLevel);
router.use('/tpd', blockLevel);
router.use('/tpd', clusterLevel);
router.use('/tpd', schoolLevel);

//download raw data
const fileDownload = require('./controller/rawDataDownload');
router.use('/getDownloadUrl', fileDownload);


//Student Attendance Exception
const sarGetDateRange = require('./controller/completionReports/studentAttendanceException/getDateRange');
const sarExceptionDistWise = require('./controller/completionReports/studentAttendanceException/dist_wise_data');
const sarExceptionBlockWise = require('./controller/completionReports/studentAttendanceException/block_wise_data');
const sarExceptionClusterWise = require('./controller/completionReports/studentAttendanceException/cluster_wise_data');
const sarExceptionSchoolWise = require('./controller/completionReports/studentAttendanceException/school_wise_data');

router.use('/sarException', sarGetDateRange);
router.use('/sarException', sarExceptionDistWise);
router.use('/sarException', sarExceptionBlockWise);
router.use('/sarException', sarExceptionClusterWise);
router.use('/sarException', sarExceptionSchoolWise);

//Attendance Line-chart
const onDistSelect = require('./controller/attendanceRoutes/sttendance-line-chart/onSelectDistrict');
router.use('/line-chart', onDistSelect);
const onBlockSelect = require('./controller/attendanceRoutes/sttendance-line-chart/onSelectBlock');
router.use('/line-chart', onBlockSelect);
const onClusterSelect = require('./controller/attendanceRoutes/sttendance-line-chart/onSelectCluster');
router.use('/line-chart', onClusterSelect);
const onSchoolSelect = require('./controller/attendanceRoutes/sttendance-line-chart/onSelectSchool');
router.use('/line-chart', onSchoolSelect);

//SAT Line-chart
const satOnDistSelect = require('./controller/patRoutes/sat-line-chart/onSelectDistrict');
router.use('/sat-line-chart', satOnDistSelect);
const satOnBlockSelect = require('./controller/patRoutes/sat-line-chart/onSelectBlock');
router.use('/sat-line-chart', satOnBlockSelect);
const satOnClusterSelect = require('./controller/patRoutes/sat-line-chart/onSelectCluster');
router.use('/sat-line-chart', satOnClusterSelect);
const satOnSchoolSelect = require('./controller/patRoutes/sat-line-chart/onSelectSchool');
router.use('/sat-line-chart', satOnSchoolSelect);

const management_category_meta = require('./controller/attendanceRoutes/management_category_meta');
router.use('/management-category-meta', management_category_meta);

const getDefault = require('./lib/management_category_config');
router.use('/getDefault', getDefault);

module.exports = router;