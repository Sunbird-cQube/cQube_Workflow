const router = require('express').Router();
const { logger } = require('../../lib/logger');
const auth = require('../../middleware/check-auth');
const s3File = require('../../lib/reads3File');
const db = require('../keycloakDB/db')
router.post('/configCardProperties', auth.authController, async (req, res) => {
    try {
        logger.info('--- Configurable card properties ---');

       
        db.query('select distinct report_name,status,state, report_type, description from configurable_datasource_properties ;', (error, results) => {
            if (error) {
                logger.info('--- common schedular api failed ---')
                throw error
            }

            if (results['rowCount']) {
                logger.info('---common schedular api response sent ---')

                let data = results['rows']


                const makeUnique = (array = [], keys = []) => {
                    if (!keys.length || !array.length) return [];

                    return array.reduce((list, item) => {

                        const hasItem = list.find(listItem =>
                            keys.every(key => listItem[key].toLowerCase() === item[key].toLowerCase())
                        );
                        if (!hasItem) list.push(item);
                    
                        return list;
                    }, []);
                };

                data = makeUnique(data, ["report_name", "report_type"]);

                data.forEach(data => {
                    data.routerLink = `/${data.report_name.replace(/\s+/g, '-').toLowerCase()}/${data.report_type}`;
                });

                res.status(200).send({ data: data });
                logger.info('---Configurable card properties response sent---');
            } else {
                res.send({ status: "401", err: "somthing went wrong" })
            }

        })

        logger.info('--- Configurable card properties  api response sent ---');
      
    } catch (e) {
        logger.error(e);
        res.status(500).json({ errMessage: "Internal error. Please try again!!" });
    }
})

module.exports = router;