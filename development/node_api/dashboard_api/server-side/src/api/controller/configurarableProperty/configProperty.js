const router = require('express').Router();
const { logger } = require('../../lib/logger');
const auth = require('../../middleware/check-auth');
const s3File = require('../../lib/reads3File');

router.post('/configProperties', auth.authController, async (req, res) => {
    try {
        logger.info('--- Configurable properties ---');
        let filename = `ui_configurable_property/ui_configurable_property.json`
        let data = await s3File.readFileConfig(filename);
        const key = 'report_name';

        const arrayUniqueByKey = [...new Map(data.map(item =>
            [item[key], item])).values()];

        arrayUniqueByKey.forEach(data => {
            data.routerLink = `${data.report_name.replace(/\s+/g, '-').toLowerCase()}`;
        });

        logger.info('--- Configurable properties  api response sent ---');
        res.status(200).send({ data: arrayUniqueByKey });
    } catch (e) {
        logger.error(e);
        res.status(500).json({ errMessage: "Internal error. Please try again!!" });
    }
})

module.exports = router;