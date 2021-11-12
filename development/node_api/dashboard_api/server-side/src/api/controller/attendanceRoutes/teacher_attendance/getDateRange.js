const router = require('express').Router();
var const_data = require('../../../lib/config');
const { logger } = require('../../../lib/logger');
const auth = require('../../../middleware/check-auth');
const groupArray = require('group-array');
const s3File = require('../../../lib/reads3File');

router.get('/getDateRange', auth.authController, async (req, res) => {
    try {
        logger.info('---getDateRange api ---');
        let fileName = `teacher_attendance/teacher_attendance_meta.json`;
        let jsonData = await s3File.readFileConfig(fileName);

        let date = groupArray(jsonData, 'year')
        logger.info('--- getDateRange response sent ---');
        if (date == {}) {
            res.status(403).send({ errMsg: "data not found" });
        } else {
            res.status(200).send(date);
        }
    } catch (e) {
        logger.error(`Error :: ${e}`)
        res.status(500).json({ errMessage: "Internal error. Please try again!!" });
    }
});

module.exports = router;