const router = require("express").Router();
const { logger } = require("../../../lib/logger");
const auth = require("../../../middleware/check-auth");
const s3File = require("../../../lib/reads3File");

router.post("/clusterData", auth.authController, async (req, res) => {
  try {
    logger.info("--- diksha chart cluster allData api ---");
    let timePeriod = req.body.timePeriod;
    let blockId = req.body.blockId;
    let programId = req.body.programId;
    let courseId = req.body.courseId;
    let districtId = req.body.districtId;
    let programSelected = req.body.programSeleted;
    let courseSelected = req.body.courseSelected;
    let districtSelected = req.body.districtSelected;
    if (
      programSelected === true &&
      courseSelected !== true &&
      districtSelected === true
    ) {
      var fileName = `diksha_tpd/report2/${timePeriod}/cluster/all_programs/${blockId}.json`;
    } else if (
      programSelected === true &&
      courseSelected === true &&
      districtSelected === true
    ) {
      var fileName = `diksha_tpd/report2/${timePeriod}/cluster/all_program_collections/${blockId}.json`;
    } else if (
      programSelected !== true &&
      courseSelected === true &&
      districtSelected === true
    ) {
      var fileName = `diksha_tpd/report2/${timePeriod}/cluster/all_collections/${blockId}.json`;
    } else if (
      programSelected !== true &&
      courseSelected !== true &&
      districtSelected === true
    ) {
      var fileName = `diksha_tpd/report2/${timePeriod}/cluster/all/${blockId}.json`;
    }else {
        var fileName = `diksha_tpd/report2/${timePeriod}/cluster/all/${blockId}.json`;
    }

    let jsonData = await s3File.readFileConfig(fileName);
    var footer = jsonData["footer"][`${blockId}`];

    if (
      programId !== undefined &&
      courseId !== undefined &&
      districtId !== undefined
    ) {
      var result = jsonData.data
        .filter((data) => {
          return data.program_id === programId;
        })
        .filter((block) => {
          return block.collection_id === courseId;
        })
        .filter((block) => {
          return block.district_id === districtId;
        });
    } else if (
      programId === undefined &&
      courseId !== undefined &&
      districtId !== undefined
    ) {
      var result = jsonData.data
        .filter((data) => {
          return data.collection_id === courseId;
        })
        .filter((block) => {
          return block.district_id === districtId;
        });
    }else if (
        programId !== undefined &&
        courseId == undefined &&
        districtId !== undefined
      ) {
        var result = jsonData.data
          .filter((data) => {
            return data.program_id === programId;
          })
          .filter((block) => {
            return block.district_id === districtId;
          });
      } else if (
      programId === undefined &&
      courseId == undefined &&
      districtId !== undefined
    ) {
      var result = jsonData.data.filter((data) => {
        return data.district_id === districtId;
      });
    }

    result = result.filter((a) => {
      return a.block_id == blockId;
    });

    var chartData = {
      labels: "",
      data: "",
    };

    result = result.sort((a, b) => (a.cluster_name > b.cluster_name ? 1 : -1));
    chartData["labels"] = result.map((a) => {
      return a.cluster_name;
    });
    chartData["data"] = result.map((a) => {
      return {
        enrollment: a.total_enrolled,
        completion: a.total_completed,
        certificate_value: a.certificate_count,
      };
    });
    logger.info("--- diksha chart allData api response sent ---");
    res.send({ chartData, downloadData: result, footer, result });
  } catch (e) {
    logger.error(`Error :: ${e}`);
    res.status(500).json({ errMessage: "Internal error. Please try again!!" });
  }
});

module.exports = router;
