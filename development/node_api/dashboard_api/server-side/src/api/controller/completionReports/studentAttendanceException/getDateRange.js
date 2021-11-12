const router = require('express').Router();
var const_data = require('../../../lib/config');
const { logger } = require('../../../lib/logger');
const auth = require('../../../middleware/check-auth');
const groupArray = require('group-array');
const s3File = require('../../../lib/reads3File');

router.post('/getDateRange', auth.authController, async (req, res) => {
    try {
        logger.info('---getDateRange api ---');
        var report = req.body.report;
        var fileName;
        if (report == 'sarException') {
            fileName = `exception_list/student_attendance_completion/metaData.json`;
        } else {
            fileName = `exception_list/teacher_attendance_completion/metaData.json`;
        }
        let jsonData = await s3File.readFileConfig(fileName);

        let date = groupArray(jsonData, 'year')
        logger.info('--- getDateRange response sent ---');
        res.status(200).send(date);
    } catch (e) {
        logger.error(`Error :: ${e}`)
        res.status(500).json({ errMessage: "Internal error. Please try again!!" });
    }
});

module.exports = router;