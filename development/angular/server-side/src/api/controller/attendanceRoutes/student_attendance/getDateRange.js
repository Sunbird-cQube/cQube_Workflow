const router = require('express').Router();
var const_data = require('../../../lib/config');
const { logger } = require('../../../lib/logger');
const auth = require('../../../middleware/check-auth');
const groupArray = require('group-array');
const s3File = require('../../../lib/reads3File');

router.get('/getDateRange', auth.authController, async (req, res) => {
    try {
        logger.info('---getDateRange api ---');
        let fileName = `attendance/student_attendance_meta.json`;
        var jsonData = await s3File.storageType == "s3" ? await s3File.readS3File(fileName) : await s3File.readLocalFile(fileName);;
        let date = groupArray(jsonData, 'year')
        logger.info('--- getDateRange response sent ---');
        res.status(200).send(date);
    } catch (e) {
        logger.error(`Error :: ${e}`)
        res.status(500).json({ errMessage: "Internal error. Please try again!!" });
    }
});

router.post('/rawMeta', auth.authController, async (req, res) => {
    try {
        var report = req.body.report;
        logger.info('---raw data download meta api ---');
        let fileName = (report == 'sar') ? `attendance/raw/metaData.json` : `teacher_attendance/raw/metaData.json`;
        var jsonData = await s3File.storageType == "s3" ? await s3File.readS3File(fileName) : await s3File.readLocalFile(fileName);
        let academic_years = [];
        jsonData.map(i => {
            academic_years.push(i.academic_year);
        })
        logger.info('--- raw data download meta response sent ---');
        res.status(200).send(academic_years);
    } catch (e) {
        logger.error(`Error :: ${e}`)
        res.status(500).json({ errMessage: "Internal error. Please try again!!" });
    }
});


module.exports = router;