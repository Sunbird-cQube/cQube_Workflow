const { logger } = require('../lib/logger');
var const_data = require('../lib/config');
const fs = require('fs');
const jsonexport = require('jsonexport');
var S3Append = require('s3-append').S3Append;
const { format } = require('path');
var shell = require('shelljs');
const inputDir = `${process.env.EMISSION_DIRECTORY}`;
var storageType = `${process.env.STORAGE_TYPE}`;

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
function saveToLocal(fileName, formData, report) {
    
    return new Promise((resolve, reject) => {
        try {
            let username = process.env.SYSTEM_USERNAME;
          
            username = username.replace(/\n/g, '');
            var newLine = '\r';
            fs.stat(fileName, async function (err, stats) {
          
                let data = "";
                let row = "";
                if (err == null) {
                    if (report != 'sar') {
                    shell.exec(`sudo chown ${username}:${username} ${inputDir}/telemetry/telemetry_view`);
                        row = `${formData[0].uid}|${formData[0].eventType}|${formData[0].reportId}|${formData[0].time}`
                    } else {
                        shell.exec(`sudo chown ${username}:${username} ${inputDir}/telemetry`);
                        row = `${formData[0].pageId}|${formData[0].uid}|${formData[0].event}|${formData[0].level}|${formData[0].locationid}|${formData[0].locationname}|${formData[0].lat}|${formData[0].lng}|${formData[0].download}`
                    }

                    data = '\n' + row.replace(/,/g, '|') + newLine;
                    fs.appendFile(fileName, data, function (err) {
                        if (!err) {
                            resolve({ msg: "Successfully update file" });
                        } else {
                            reject({ errMsg: "Internal error" });
                        }
                    });
                } else {
                    jsonexport(formData, function (error, csv) {
                        if (error) return console.error(error);

                        let data = csv.replace(/,/g, '|');
                        
                        let username = process.env.SYSTEM_USERNAME;
                        username = username.replace(/\n/g, ''); 
                        if (report != 'sar') {   
                            shell.exec(`sudo chown ${username}:${username} ${inputDir}/${fileName}`, function (err) {
                                if (err) {
                                   
                                    process.exit(0);
                                }
                            });
                        } else {
                            shell.exec(`sudo chown ${username}:${username} ${inputDir}/telemetry`);
                        }
                      
                        fs.writeFile(`${inputDir}/${fileName}`, data, function (err) {
                            if (!err) {
                                resolve({ msg: "Successfully uploaded file" });
                            } else {
                                reject({ errMsg: "Internal error telemetry view failed" });
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

//azure config
if (storageType === 'azure') {
    var azure = require('azure-storage');
    const { storageType } = require('./reads3File');
    const AZURE_STORAGE_CONNECTION_STRING = process.env.AZURE_STORAGE_CONNECTION_STRING;
    var blobService = azure.createBlobService(AZURE_STORAGE_CONNECTION_STRING);
    const containerName = process.env.AZURE_OUTPUT_STORAGE;
}


const saveToAzure = async (containerName, fileName, formData, localFile) => {
    let file = inputDir + fileName;
    
    jsonexport(formData, function (error, csv) {
        let data = csv.replace(/,/g, '|');
        fs.writeFile(file, data, async (err) => {
            
            if (err) {
                console.log(err);
            } else {
                await deleteAzure(containerName, fileName);
                await uploadFileAzure(containerName, fileName, localFile);
            }
        });
    });
}

const readFromBlob = async (containerName, blobName) => {
    return new Promise((resolve, reject) => {
        blobService.getBlobToText(containerName, blobName, (err, data) => {
            if (err) {
                reject(err);
            } else {
                resolve(JSON.parse(data));
            }
        });
    });
};


const deleteAzure = (containerName, blobName) => {
    return new Promise((resolve, reject) => {
        blobService.deleteBlobIfExists(containerName, blobName, (err, result) => {
            if (err) {
                reject(err);
            } else {
                resolve(result);
            }
        });
    });
}

const uploadFileAzure = (containerName, fileName, localFile) => {
    blobService.createBlockBlobFromLocalFile(containerName, fileName, localFile, function (error, result, response) {
        if (!error) {
            console.log("File uploaded")
            fs.unlinkSync('input.json');
        } else {
            console.log(error);
        }
    });
}


const uploadFiles = async (containerName, fileName, formData, type) => {
    let response;
    if (storageType == 's3') {
        response = await saveToS3(fileName, formData)
    } else if (storageType == 'local') {
        response = await saveToLocal(fileName, formData, type);
    } else if (storageType == 'azure') {
        fileName = inputDir + fileName;
        let localFile = fileName;
        response = await saveToAzure(containerName, fileName, formData, localFile)
    }
    return response;
}


module.exports = { saveToS3, saveToLocal, saveToAzure, uploadFiles };