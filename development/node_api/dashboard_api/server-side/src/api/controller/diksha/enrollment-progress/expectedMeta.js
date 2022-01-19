const router = require('express').Router();
const { logger
} = require('../../../lib/logger');
const auth = require('../../../middleware/check-auth');
const s3File = require('../../../lib/reads3File');

router.get('/expectedMeta', auth.authController, async (req, res) => {
    try {
        logger.info('--- diksha enrolled meta api ---');
        let timePeriod = req.body.timePeriod;
        var fileName = `diksha_tpd/report2/course_enrolment_meta.json`;
        let jsonData = await s3File.readFileConfig(fileName);


        logger.info('--- diksha enrolled meta api ---');

        res.send({
            jsonData
        });
    } catch (e) {
        logger.error(`Error : : ${e
            }`)
        res.status(500).json({
            errMessage: "Internal error. Please try again!!"
        });
    }
})

module.exports = router;