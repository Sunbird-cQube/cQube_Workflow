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

var azure = require('azure-storage');
const AZURE_STORAGE_CONNECTION_STRING = process.env.AZURE_STORAGE_CONNECTION_STRING;
var blobService = azure.createBlobService(AZURE_STORAGE_CONNECTION_STRING);

var containerName = process.env.AZURE_OUTPUT_STORAGE;

var blobName = 'test.json';
const readFromBlob = async (containerName, blobName) => {
    return new Promise((resolve, reject) => {
        blobService.getBlobToText(containerName, blobName, (err, data) => {
            if (err) {
                reject(err);
            } else {
                resolve(data);
            }
        });
    });
};

async function fun() {
    try {
        let data = await readFromBlob(containerName, blobName);
        console.log(JSON.parse(data));
    } catch (e) {
        console.log({ message: "The specified blob does not exist" })
    }
}

fun();





module.exports = {
    readS3File, readLocalFile, storageType
};