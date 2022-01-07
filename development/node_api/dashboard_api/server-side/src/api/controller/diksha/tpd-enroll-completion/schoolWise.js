const router = require("express").Router();
const { logger } = require("../../../lib/logger");
const auth = require("../../../middleware/check-auth");
const s3File = require("../../../lib/reads3File");

router.post("/schoolData", auth.authController, async (req, res) => {
  try {
    logger.info("--- diksha chart allData api ---");
    let timePeriod = req.body.timePeriod;
    let blockId = req.body.blockId;
    let clusterId = req.body.clusterId;

    let programId = req.body.programId;
    let courseId = req.body.courseId;
    let districtId = req.body.districtId;

    let programSelected = req.body.programSeleted;
    let courseSelected = req.body.courseSelected;
    let districtSelected = req.body.districtSelected;
    let blockSelected = req.body.blockSelected;
    var fileName = "";
    if (
      programSelected === true &&
      courseSelected === undefined &&
      districtSelected === true &&
      blockSelected === true
    ) {
      fileName = `diksha_tpd/report2/${timePeriod}/school/all_programs/${blockId}.json`;
    } else if (
      programSelected === true &&
      courseSelected === true &&
      districtSelected === true &&
      blockSelected === true
    ) {
      fileName = `diksha_tpd/report2/${timePeriod}/school/all_program_collections/${blockId}.json`;
    } else if (
      programSelected === undefined &&
      courseSelected === true &&
      districtSelected === true &&
      blockSelected === true
    ) {
      fileName = `diksha_tpd/report2/${timePeriod}/school/all_collections/${blockId}.json`;
    } else if (
      programSelected === undefined &&
      courseSelected === undefined &&
      districtSelected === true &&
      blockSelected === true
    ) {
      fileName = `diksha_tpd/report2/${timePeriod}/school/all/${blockId}.json`;
    } else {
      fileName = `diksha_tpd/report2/${timePeriod}/school/all/${blockId}.json`;
    }

    let jsonData = await s3File.readFileConfig(fileName);
    var footer = jsonData["footer"][`${clusterId}`];

    if (
      programId !== undefined &&
      courseId !== undefined &&
      districtId !== undefined &&
      blockId !== undefined
    ) {
      var result = jsonData.data
        .filter((data) => {
          return data.program_id === programId;
        })
        .filter((data) => {
          return data.collection_id === courseId;
        })
        .filter((data) => {
          return data.district_id === districtId;
        }).filter((data) => {
            return data.block_id === blockId;
          });
    } else if (
      programId === undefined &&
      courseId !== undefined &&
      districtId !== undefined && 
      blockId !== undefined
    ) {
      var result = jsonData.data
        .filter((data) => {
          return data.collection_id === courseId;
        })
        .filter((block) => {
          return block.district_id === districtId;
        }).filter((data) => {
            return data.block_id === blockId;
          });
    }else if (
        programId === undefined &&
        courseId == undefined &&
        districtId !== undefined &&
        blockId !== undefined
      ) {
        var result = jsonData.data.filter((data) => {
            return data.district_id === districtId;
        }).filter((data) => {
            return data.block_id === blockId;
          });
      }else if (
        programId !== undefined &&
        courseId == undefined &&
        districtId !== undefined &&
        blockId !== undefined
      ) {
        var result = jsonData.data.filter((data) => {
            return data.program_id === programId;
        }).filter((data) => {
            return data.district_id === districtId;
          }).filter((data) => {
            return data.block_id === blockId;
          });
      }

   
    result = result.filter((a) => {
      return a.cluster_id == clusterId;
    });

    var chartData = {
      labels: "",
      data: "",
    };

    result = result.sort((a, b) => (a.school_name > b.school_name ? 1 : -1));
    chartData["labels"] = result.map((a) => {
      return a.school_name;
    });
    chartData["data"] = result.map((a) => {
      return {
        enrollment: a.total_enrolled,
        completion: a.total_completed,
        percent_teachers: a.percentage_teachers,
        certificate_value: a.certificate_count,
      };
    });
    logger.info("--- diksha chart allData api response sent ---");
    res.send({ chartData, downloadData: result, footer });
  } catch (e) {
    logger.error(`Error :: ${e}`);
    res.status(500).json({ errMessage: "Internal error. Please try again!!" });
  }
});

module.exports = router;
