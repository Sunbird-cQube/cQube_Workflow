const router = require('express').Router();
const { logger } = require('../../../lib/logger')
const auth = require('../../../middleware/check-auth');
const readFile = require('../../../lib/reads3File');

router.get('/certificateMeta' , auth.authController, async (req, res) => {
    try {
        logger.info('--- diksha multi bar  meta data api ---');
        var fileName = `diksha_tpd/report2/course_certificate_meta.json`;
        let jsonData = await readFile.readFileConfig(fileName);
        // var footer = jsonData['footer'];
        let mydata = jsonData;
        logger.info('--- diksha multi bar  meta data api response sent ---');
        res.send({ data: mydata });
    } catch (e) {
        logger.error(`Error :: ${e}`)
        res.status(500).json({ errMessage: "Internal error. Please try again!!" });
    }
})



module.exports = router;