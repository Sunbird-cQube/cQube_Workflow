const router = require('express').Router();
const { logger } = require('../../lib/logger');
const auth = require('../../middleware/check-auth');
const s3File = require('../../lib/reads3File');
const db = require('../keycloakDB/db')
router.post('/configProperties', auth.authController, async (req, res) => {
    try {
        logger.info('--- Configurable properties ---');
        let filename = `ui_configurable_property/ui_configurable_property.json`
        // let data = await s3File.readFileConfig(filename);
        const key = 'report_name';

        db.query('select distinct report_name,status,state from configurable_datasource_properties ;', (error, results) => {
            if (error) {
                logger.info('--- common schedular api failed ---')
                throw error
            }

            if (results['rowCount']) {
                logger.info('---common schedular api response sent ---')

                let data = results['rows']

                data = data.filter(program => program.status === true)

                let arrayUniqueByKey = [...new Map(data.map(item =>
                    [item[key], item])).values()];

                arrayUniqueByKey.forEach(data => {
                    data.routerLink = `${data.report_name.replace(/\s+/g, '-').toLowerCase()}`;
                });
               
               
                res.status(200).send({ data: arrayUniqueByKey });
                logger.info('---list new dataSource api response send---');
            } else {
                res.send({ status: "401", err: "somthing went wrong" })
            }

        })
      
    } catch (e) {
        logger.error(e);
        res.status(500).json({ errMessage: "Internal error. Please try again!!" });
    }
})

module.exports = router;