const router = require('express').Router();
const { logger } = require('../../lib/logger');
const auth = require('../../middleware/check-auth');
var const_data = require('../../lib/config');
const { storageType } = require('../../lib/readFiles');
const glob = require("glob");

router.post('/listBuckets', auth.authController, async function (req, res) {
    try {
        logger.info(`listbucket of ${storageType} api`);
        let listBuckets = {};
        if (storageType == "s3") {
            listBuckets = {
                'input': process.env.INPUT_BUCKET_NAME,
                'output': process.env.OUTPUT_BUCKET_NAME,
                'emission': process.env.EMISSION_BUCKET_NAME
            }
        } else {
            listBuckets = {
                'input': process.env.INPUT_DIRECTORY,
                'output': process.env.OUTPUT_DIRECTORY,
                'emission': process.env.EMISSION_DIRECTORY
            }
        }
        logger.info(`listfolder of ${storageType} api response sent`);
        res.status(200).send({ listBuckets, storageType: storageType == "s3" ? "bucket" : "folder" });
    } catch (e) {
        logger.error(`Error :: ${e}`);
        res.status(500).json({ errMsg: "Internal error. Please try again!!" });
    }
});

router.post('/listFiles', auth.authController, async function (req, res) {
    try {
        logger.info(`listfiles of ${storageType} api`);
        const param = {
            Bucket: req.body.bucketName
        };
        if (storageType == "s3") {
            async function getAllKeys(params, allKeys = []) {
                const response = await const_data['s3'].listObjectsV2(params).promise();
                response.Contents.forEach(obj => allKeys.push(obj.Key));

                if (response.NextContinuationToken) {
                    params.ContinuationToken = response.NextContinuationToken;
                    await getAllKeys(params, allKeys); // RECURSIVE CALL
                }
                return allKeys;
            }
            const list = await getAllKeys(param);
            logger.info(`listfiles of ${storageType} api response sent`);
            res.status(200).send(list);
        }
        else {
            var getDirectories = function (src, callback) {
                glob(src + '/**/*', callback);
            };
            getDirectories(req.body.bucketName, function (err, response) {
                if (err) {
                    logger.error('Error', err);
                } else {
                    let list = response.filter(a => { return a.includes(".json") || a.includes(".zip") });
                    logger.info(`listfiles of ${storageType} api response sent`);
                    res.status(200).send(list);
                }
            });
        }
    } catch (e) {
        logger.error(`Error :: ${e}`);
        res.status(500).json({ errMsg: "Internal error. Please try again!!" });
    }
});

router.post('/getDownloadUrl', auth.authController, async function (req, res) {
    try {
        logger.info(`---list s3 Files for bucket ${req.body.bucketName} and fileName ${req.body.fileName} api ---`);
        const params = {
            Bucket: req.body.bucketName,
            Key: req.body.fileName,
            Expires: 60 * 5
        };

        const_data['s3_download'].getSignedUrl('getObject', params, (err, url) => {
            logger.info(`--- list ${storageType}  file for bucket response sent.. ---`);
            res.status(200).send({ downloadUrl: url })
        });
    } catch (e) {
        logger.error(`Error :: ${e}`);
        res.status(500).json({ errMsg: "Internal error. Please try again!!" });
    }
});


module.exports = router;