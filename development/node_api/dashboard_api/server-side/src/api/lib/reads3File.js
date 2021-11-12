var const_data = require('./config');
const { logger } = require('./logger');
const fs = require('fs')
var baseDir = `${process.env.OUTPUT_DIRECTORY}`;
var storageType = `${process.env.STORAGE_TYPE}`;
const readS3File = (s3Key) => {
    return new Promise((resolve, reject) => {
        try {
            const_data['getParams']['Key'] = s3Key;
            const_data['s3'].getObject(const_data['getParams'], function (err, data) {
                if (err) {
                    logger.error(err);
                    reject({ errMsg: "Something went wrong" });
                } else if (!data) {
                    logger.error("No data found in s3 file");
                    reject({ errMsg: "No such data found" });
                } else {
                    var jsonData = JSON.parse(data.Body.toString());
                    resolve(jsonData)
                }
            });
        } catch (e) {
            reject(e)
        }
    })
}


const readLocalFile = (fileName) => {
    return new Promise((resolve, reject) => {
        try {
            fileName = baseDir + fileName;
            fs.readFile(fileName, function (err, data) {
                if (err) {
                    logger.error(err);
                    reject({ errMsg: "Something went wrong" });
                } else if (!data) {
                    logger.error("No data found in s3 file");
                    reject({ errMsg: "No such data found" });
                } else {
                    var jsonData = JSON.parse(data.toString());
                    resolve(jsonData)
                }
            });
        } catch (e) {
            reject(e)
        }
    })
}

//azure config
var azure = require('azure-storage');
const AZURE_STORAGE_CONNECTION_STRING = process.env.AZURE_STORAGE_CONNECTION_STRING;
var blobService = azure.createBlobService(AZURE_STORAGE_CONNECTION_STRING);
var containerName = process.env.AZURE_OUTPUT_STORAGE;

//reading file from azure
const readFromBlob = async (blobName) => {
    let container = containerName;
    return new Promise((resolve, reject) => {
        blobService.getBlobToText(container, blobName, (err, data) => {
            if (err) {
                reject(err);
            } else {
                resolve(JSON.parse(data));
            }
        });
    });
};

// async function fun() {
//     try {
//         let data = await readFromBlob(blobName);
//         console.log(data);
//     } catch (e) {
//         console.log({ message: "The specified blob does not exist" })
//     }
// }

// fun();

// var fileService = azure.createFileService(AZURE_STORAGE_CONNECTION_STRING);
// fileService.createShareIfNotExists('taskshare1', function (error, result, response) {
//     if (!error) {
//         console.log("share created");
//         fileService.createDirectoryIfNotExists('taskshare1', 'dir1', function (error, result, response) {
//             if (!error) {
//                 console.log(":::::")
//                 var text = 'Hello World!';
//                 fileService.createFileFromText('taskshare1', 'dir1', 'taskfile', text, function (error, result, response) {
//                     if (!error) {
//                         console.log("File Created")
//                     } else {
//                         console.log("++++++++++++++++++++++++++++++++++++")
//                     }
//                 });

//             } else {
//                 console.log(error)
//             }
//         });
//     } else {
//         console.log("share errorrrrrrrrrrrrrrrrrrrr");
//     }
// });


// blobService.createBlockBlobFromLocalFile(containerName, 'taskblob', 'output.txt', function (error, result, response) {
//     if (!error) {
//        console.log("File uploaded")
//     }else{
//         console(error);
//     }
// });

const readFileConfig = async (fileName) => {
    var data;
    if (storageType == "s3") {
        data = await readS3File(fileName);
    } else if (storageType == 'local') {
        data = await readLocalFile(fileName);
    } else if (storageType == 'azure') {
        data = await readFromBlob(fileName);
    };
    return data;
}

module.exports = {
    readFileConfig, storageType
};