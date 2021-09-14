const router = require('express').Router();

const addUser = require('./controller/users/addUser');
const changePasswd = require('./controller/users/changePassword');
const users = require('./controller/users/allUsers');

//sumary
const summary = require('./controller/statistics/summary');
//logs
const logs = require('./controller/logs/logs');
const s3Download = require('./controller/s3Downloads/s3FileDownload');
const nifi = require('./controller/niFiScheduler/nifiScheduler');

const dataSource = require('./controller/data-replay/getDataSources');
router.use('/getDataSource', dataSource);

const getMonthAndYear = require('./controller/data-replay/getMonthAndYear');
router.use('/', getMonthAndYear);

const saveDataToS3 = require('./controller/data-replay/saveData');
router.use('/savetoS3', saveDataToS3);

// user details routes
router.use('/addUser', addUser);
router.use('/changePassword', changePasswd);
router.use('/allUsers', users);

router.use('/logs', logs);
router.use('/s3Download', s3Download);

router.use('/summary', summary);

router.use('/nifi', nifi);


module.exports = router;