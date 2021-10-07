const { logger } = require('../lib/logger');
var const_data = require('../lib/config');
const fs = require('fs');
const jsonexport = require('jsonexport');
var S3Append = require('s3-append').S3Append;
const { format } = require('path');


function saveToS3(fileName, formData) {
    return new Promise((resolve, reject) => {
        try {
            let params = {
                Bucket: const_data['getParams1']['Bucket'],
                Key: fileName
            };
            const_data['s3'].headObject(params, function (err, metadata) {
                if (err && err.statusCode == 404) {
                    //=====================Upload new files..........
                    jsonexport(formData, function (error, csv) {
                        if (error) return console.error(error);
                        params['Body'] = csv.replace(/,/g, '|');
                        const_data['s3'].upload(params, function (err1, result) {
                            if (err1) {
                                console.error(err1);
                                reject({ errMsg: "Internal error" });
                            } else {
                                logger.info('--- upload new file successful---');
                                resolve({ msg: "Successfully uploaded file" });
                            }
                        });
                    });
                } else {
                    const_data['s3'].getSignedUrl('getObject', params, () => {
                        jsonexport(formData, { includeHeaders: false }, function (error1, csv) {
                            var service = new S3Append(const_data.appendConfig, fileName, format.csv);
                            service.append(`\r${csv.replace(/,/g, '|')}`);
                            service.flush()
                                .then(function () {
                                    logger.info('--- appende new data successful---');
                                    resolve({ msg: "new data appended" });
                                })
                                .catch(function (err1) {
                                    reject({ errMsg: "Internal error" });
                                });
                        });
                    });
                }
            });
        } catch (e) {
            reject(e);
        }
    })
}
function saveToLocal(fileName, formData) {
    return new Promise((resolve, reject) => {
        try {
            var newLine = '\r\n';
            fs.stat(fileName, async function (err, stat) {
                if (err == null) {
                    let row = `${formData[0].eventType}|${formData[0].reportId}|${formData[0].time}`
                    let data = row.replace(/,/g, '|') + newLine;
                    fs.appendFile(fileName, data, function (err) {
                        if (!err) {
                            resolve({ msg: "Successfully update file" });
                        } else {
                            reject({ errMsg: "Internal error" });
                        }
                    });
                } else {
                    jsonexport(formData, function (error, csv) {
                        let data = csv.replace(/,/g, '|');
                        fs.writeFile(fileName, data, function (err) {
                            if (!err) {
                                resolve({ msg: "Successfully uploaded file" });
                            } else {
                                reject({ errMsg: "Internal error" });
                            }
                        });
                    });
                }
            });
        } catch (e) {
            reject(e);
        }
    })
}


module.exports = { saveToS3, saveToLocal };