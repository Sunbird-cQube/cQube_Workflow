const router = require('express').Router();
var const_data = require('../../lib/config');
const { logger } = require('../../lib/logger');
const auth = require('../../middleware/check-auth');
const groupArray = require('group-array');
const s3File = require('../../lib/readFiles')

router.post('/getMonthYear', auth.authController, async (req, res) => {
    try {
        logger.info('---getDateRange api ---');
        var report = req.body.report;
        var fileName;
        if (report == 'sar') {
            fileName = `data_replay/stud_att_meta.json`;
        } else if (report == 'tar') {
            fileName = `data_replay/tch_att_meta.json`;
        } else {
            fileName = `data_replay/crc_meta.json`;
        }
        let dataObj = await s3File.readFileConfig(fileName);
        let date = groupArray(dataObj, 'year')
        logger.info('--- getDateRange response sent ---');
        res.status(200).send(date);

    } catch (e) {
        logger.error(`Error :: ${e}`)
        res.status(500).json({ errMessage: "Internal error. Please try again!!" });
    }
});

router.post('/getSemesters', auth.authController, async (req, res) => {
    try {
        logger.info('---getSemesters api ---');
        var fileName = `data_replay/sat_meta.json`;

        let dataObj = await s3File.readFileConfig(fileName);
        logger.info('--- getSemesters response sent ---');
        res.status(200).send(dataObj);
    } catch (e) {
        logger.error(`Error :: ${e}`)
        res.status(500).json({ errMessage: "Internal error. Please try again!!" });
    }
});

router.post('/getBatchIds', auth.authController, async (req, res) => {
    try {
        logger.info('---getBatchIds api ---');
        var fileName = `data_replay/diksha_tpd_meta.json`;

        let dataObj = await s3File.readFileConfig(fileName);
        logger.info('--- getBatchIds response sent ---');
        res.status(200).send(dataObj);
    } catch (e) {
        logger.error(`Error :: ${e}`)
        res.status(500).json({ errMessage: "Internal error. Please try again!!" });
    }
});

router.post('/getExamCode', auth.authController, async (req, res) => {
    try {
        logger.info('---getExamCode api ---');
        var fileName = `data_replay/pat_meta.json`;

        let dataObj = await s3File.readFileConfig(fileName);
        logger.info('--- getExamCode response sent ---');
        res.status(200).send(dataObj);
    } catch (e) {
        logger.error(`Error :: ${e}`)
        res.status(500).json({ errMessage: "Internal error. Please try again!!" });
    }
});

module.exports = router;