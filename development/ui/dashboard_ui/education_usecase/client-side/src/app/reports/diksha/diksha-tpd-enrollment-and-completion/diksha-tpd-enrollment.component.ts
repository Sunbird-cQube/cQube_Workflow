// The dashboard provides information on the total enrollments and
// completions for Teacher Professional Development courses at the district level.

import { Component, OnInit, ViewChild } from "@angular/core";
import { HttpClient } from "@angular/common/http";
import { DikshaReportService } from "../../../services/diksha-report.service";
import { Router } from "@angular/router";
import { AppServiceComponent } from "../../../app.service";
import { FormControl, ReactiveFormsModule } from "@angular/forms";
import { MatSelect } from "@angular/material/select";

@Component({
  selector: "app-diksha-tpd-enrollment",
  templateUrl: "./diksha-tpd-enrollment.component.html",
  styleUrls: ["./diksha-tpd-enrollment.component.css"],
})
export class DikshaTpdEnrollmentComponent implements OnInit {
  //chart data variables::::::::::::
  chart: boolean = false;
  public colors = [];
  header = "";
  level = "district";
  globalId;

  public category: String[] = [];
  public chartData: Number[] = [];
  // public completion: Number[] = [];
  public completion: any;
  public xAxisLabel: String = "Percentage";
  public yAxisLabel: String;
  public reportName: String = "enrollment_completion";
  public report = "enroll/comp";
  public courseSelected = false;
  public districtSelected = false;

  public expectedEnrolled = [];
  public enrollChartData = [];
  public compliChartData = [];
  public pecentChartData = [];

  public selectedCourse = undefined;

  enrollTypes = [
    { key: "enrollment", name: "Enrollment" },
    { key: "completion", name: "Completion" },
    { key: "percent_completion", name: "Percent Completion" },
  ];
  type = "enrollment";
  districts = [];
  districtId;
  blocks = [];
  blockId;
  clusters = [];
  clusterId;

  blockHidden = true;
  clusterHidden = true;
  public districtHidden = true;
  // to hide and show the hierarchy details
  public skul: boolean = false;
  public dist: boolean = false;
  public blok: boolean = false;
  public clust: boolean = false;

  // to set the hierarchy names
  public districtHierarchy: any = {};
  public blockHierarchy: any = {};
  public clusterHierarchy: any = {};

  public result: any = [];
  public timePeriod = "overall";
  public hierName: any;
  public all: boolean = false;
  public timeDetails: any = [
    { id: "overall", name: "Overall" },
    { id: "last_90_days", name: "Last 90 Days" },
    { id: "last_30_days", name: "Last 30 Days" },
    { id: "last_7_days", name: "Last 7 Days" },
    { id: "last_day", name: "Last Day" },
  ];
  public districtsDetails: any = "";
  public myChart: Chart;
  public showAllChart: boolean = false;
  public allDataNotFound: any;
  public collectioTypes: any = [{ id: "course", type: "Course" }];
  public collectionNames: any = [];
  collectionName = "";
  footer;
  public programSeleted = false;
  public blockSelected = false;

  downloadType;
  fileName: any;
  reportData: any = [];
  y_axisValue;
  state: string;

  @ViewChild("singleSelect", { static: true }) singleSelect: MatSelect;
  /** control for the selected bank */
  public bankCtrl: FormControl = new FormControl();
  /** control for the MatSelect filter keyword */
  public bankFilterCtrl: FormControl = new FormControl();
  constructor(
    public http: HttpClient,
    public service: DikshaReportService,
    public commonService: AppServiceComponent,
    public router: Router
  ) {}

  ngOnInit(): void {
    // this.bankCtrl.setValue(this.collectionNames);
    this.state = this.commonService.state;
    document.getElementById("accessProgressCard").style.display = "none";
    //document.getElementById('backBtn') ?document.getElementById('backBtn').style.display = 'none' : "";
    this.getAllData();
    this.getProgramData();
  }

  //making chart empty:::::::::
  emptyChart() {
    this.result = [];
    this.chartData = [];
    this.category = [];
    this.reportData = [];
    this.districtHierarchy = {};
    this.blockHierarchy = {};
    this.clusterHierarchy = {};
    this.footer = undefined;
  }

  homeClick() {
    this.expEnrolChartData = [];
    this.expectedEnrolled = [];
    this.enrollChartData = [];
    this.compliChartData = [];
    this.pecentChartData = [];
    this.collectionName = "";
    this.selectedCourse = undefined;
    this.districtHidden = true;
    this.selectedProgram = "";
    this.timePeriod = "overall";
    this.programSeleted = false;
    this.districtId = undefined;
    this.blockHidden = true;
    this.clusterHidden = true;
    this.courseSelected = false;
   this.districtSelected = false;
   this.blockSelected = false;

    this.level = "district";
    this.yAxisLabel = "District Names";
    this.collectionName = "";
    this.time = this.timePeriod == "all" ? "overall" : this.timePeriod;
    this.fileToDownload = `diksha_raw_data/tpd_report2/${this.time}/${this.time}.csv`;
    this.emptyChart();
    this.getAllData();
    this.getProgramData();
  }

  deleteSingle(id: string) {
    this.collectionNames = this.collectionNames.filter((s) => s != id);
  }
  //getting all chart data to show:::::::::
  async getAllData() {
    this.emptyChart();
    if (this.timePeriod != "overall") {
    } else {
    }
    this.districts = [];
    this.blocks = [];
    this.clusters = [];
    this.blockId = undefined;
    this.clusterId = undefined;
    this.collectionNames = [];
    this.commonService.errMsg();
    this.level = "district";
    //this.collectionName = '';
    this.footer = "";
    this.fileName = `${this.reportName}_${this.type}_all_district_${this.timePeriod}_${this.commonService.dateAndTime}`;
    this.result = [];
    this.all = true;
    this.skul = true;
    this.dist = false;
    this.blok = false;
    this.clust = false;
    this.yAxisLabel = "District Names";

    this.listCollectionNames();
    this.service
      .tpdDistEnrollCompAll({ timePeriod: this.timePeriod })
      .subscribe(
        async (result) => {
          this.result = result["chartData"];
          this.districts = result["chartData"]["dropDown"];
          this.reportData = result["downloadData"];
          this.getBarChartData();
          this.commonService.loaderAndErr(this.result);
        },
        (err) => {
          this.result = [];
          this.emptyChart();
          this.commonService.loaderAndErr(this.result);
        }
      );
  }
  public program;
  public programData;
  public programMetaData;

  getProgramData() {
    this.districts = [];
    this.blocks = [];
    this.clusters = [];
    this.blockId = undefined;
    this.clusterId = undefined;
    // this.collectionNames = [];
    this.commonService.errMsg();
    // this.level = "district"
    try {
      this.service.tpdProgramData().subscribe((res) => {
        this.programData = res["data"]["data"];
        this.programMetaData = res["dropDown"]["data"];
        this.listProgramNames();
        this.commonService.loaderAndErr(this.programData);
      });
    } catch (error) {
      this.program = [];
      this.emptyChart();
      this.commonService.loaderAndErr(this.result);
    }
  }

  ///---custom search function---

  customSearchFn(term: string, item: any) {
    term = term.toLocaleLowerCase();
    return (
      item.toLocaleLowerCase().indexOf(term) > -1 ||
      item.toLocaleLowerCase().indexOf(term) > -1
    );
  }

  public programNames;
  public programToDropDown: any = [];
  public uniqePrograms: any = [];

  listProgramNames() {
    this.programToDropDown = [];
    this.uniqePrograms = [];
    this.programNames = this.programMetaData.filter((program) => {
      this.programToDropDown.push({
        program_id: program.program_id,
        program_name: program.program_name,
      });
    });
    // this.programToDropDown.map(x => this.uniqeProgram.filter(a => a.id == x.id && a.name == x.name).length > 0 ? null : this.uniqeProgram.push(x));

    let mymap = new Map();

    this.uniqePrograms = this.programToDropDown.filter((el) => {
      if (mymap.has(el.program_id)) {
        return false;
      }
      mymap.set(el.program_id, el.program_name);
      return true;
    });
  }

  public selectedProgram;
  public programBarData: any = [];
  onProgramSelect(progID) {
    this.emptyChart();
    this.districtId = undefined;
    this.districtHidden = false;
    this.selectedCourse = undefined;
    this.collectionName = "";
    this.courseSelected = false;
    this.districtSelected = false;
    this.blockSelected =false;

    this.programSeleted = true;
    this.blockHidden = true;
    this.clusterHidden = true;
    this.collectionNames = [];
    // added

    this.expEnrolChartData = [];
    this.enrollChartData = [];
    this.compliChartData = [];
    this.pecentChartData = [];
    this.programBarData = [];
    this.commonService.errMsg();
    this.selectedProgram = progID;
    this.level = "district";

    try {
      this.programBarData = this.programData.filter((program) => {
        return program.program_id === this.selectedProgram;
      });
      let collectionlist = this.collectionData.data.filter((program) => {
        return program.program_id === this.selectedProgram;
      });
      if (collectionlist) {
        let collections = [];

        let collectionMap = new Map();

        collectionlist.forEach((collection) => {
          if (!collectionMap.has(collection.collection_id)) {
            collections.push(collection);
            collectionMap.set(collection.collection_id, true);
          }
        });
        this.collectionNames = collections;
      }

      var chartData = {
        labels: "",
        data: "",
      };
      this.programBarData = this.programBarData.sort((a, b) =>
        a.district_name > b.district_name ? 1 : -1
      );

      chartData["labels"] = this.programBarData.map((a) => {
        return a.district_name;
      });
      chartData["data"] = this.programBarData.map((a) => {
        return {
          enrollment: a.total_enrolled,
          completion: a.total_completed,
          percent_completion: a.percentage_completion,
          expected_enrolled: a.expected_total_enrolled,
          enrolled_percentage: a.total_enrolled_percentage,
          certificate_value: a.certificate_count,
          certificate_per: a.certificate_percentage,
        };
      });

      this.result = chartData;
      this.reportData = this.programBarData;
      setTimeout(() => {
        this.getBarChartData();
      }, 100);

      this.commonService.loaderAndErr(this.result);
    } catch (error) {
      this.result = [];
      console.log(error);
      this.commonService.loaderAndErr(this.result);
    }
  }

  //Lsiting all collection  names::::::::::::::::::
  listCollectionNames() {
    this.commonService.errMsg();
    //this.collectionName = '';
    this.service
      .tpdgetCollection({
        timePeriod: this.timePeriod,
        level: this.level,
        id: this.globalId,
      })
      .subscribe(
        async (res) => {
          this.collectionNames = [];
          this.collectionNames = res["allCollections"];
          this.collectionData = res["allData"];
          this.collectionNames.sort((a, b) => (a > b ? 1 : b > a ? -1 : 0));
          document.getElementById("spinner").style.display = "none";
        },
        (err) => {
          this.result = [];
          this.emptyChart();
          this.commonService.loaderAndErr(this.result);
        }
      );
  }

  time = this.timePeriod == "all" ? "overall" : this.timePeriod;
  fileToDownload = `diksha_raw_data/tpd_report2/${this.time}/${this.time}.csv`;

  //download raw file:::::::::::
  downloadRawFile() {
    this.service.downloadFile({ fileName: this.fileToDownload }).subscribe(
      (res) => {
        window.open(`${res["downloadUrl"]}`, "_blank");
      },
      (err) => {
        alert("No Raw Data File Available in Bucket");
      }
    );
  }

  //Show data based on time-period selection:::::::::::::
  chooseTimeRange() {
    this.emptyChart();
     this.level = 'district'
    this.expEnrolChartData = [];
    this.expectedEnrolled = [];
    this.enrollChartData = [];
    this.compliChartData = [];
    this.pecentChartData = [];
    this.collectionName = "";
    this.selectedCourse = undefined;
    this.districtHidden = true;
    this.selectedProgram = "";
    // this.timePeriod = "overall";
    this.programSeleted = false;
    this.districtId = undefined;
    this.blockHidden = true;
    this.clusterHidden = true;
    this.courseSelected = false;
   this.districtSelected = false;
   this.blockSelected = false;

    // this.expEnrolChartData = [];
    // this.enrollChartData = [];
    // this.compliChartData = [];
    // this.pecentChartData = [];
    // this.programBarData = [];
    this.time = this.timePeriod == "all" ? "overall" : this.timePeriod;
    this.fileToDownload = `diksha_raw_data/tpd_report2/${this.time}/${this.time}.csv`;
    if (this.level == "program") {
      setTimeout(() => {
        document.getElementById("spinner").style.display = "none";
      }, 200);
      this.getProgramData();
    }
    if (this.level == "district") {
      setTimeout(() => {
        this.getAllData();
      }, 100);
    }
    if (this.level == "block") {
      this.onDistSelect(this.districtId);
    }
    if (this.level == "cluster") {
      this.onBlockSelect(this.blockId);
    }
    if (this.level == "school") {
      this.onClusterSelect(this.clusterId);
    }
  }

  //Showing data based on level selected:::::::
  onTypeSelect(type) {
    if (this.level == "district") {
      this.getAllData();
    }
    if (this.level == "block") {
      this.onDistSelect(this.districtId);
    }
    if (this.level == "cluster") {
      this.onBlockSelect(this.blockId);
    }
    if (this.level == "school") {
      this.onClusterSelect(this.clusterId);
    }
  }

  
  public expEnrolChartData: any = [];

  getBarChartData() {
    this.completion = [];
    let perCompletion = [],
      expectedEnrolledVal = [],
      enrComplitionVal = [],
      certificatPer = [],
      certificatVal = [],
      enrComplition = [],
      comComplition = [];
    this.chartData = [];
    this.category = [];
    let expectedEnrolled = [];
    let enrollChartData = [];
    let compliChartData = [];
    let pecentChartData = [];

    if (this.result.labels.length <= 25) {
      for (let i = 0; i <= 25; i++) {
        this.category.push(this.result.labels[i] ? this.result.labels[i] : " ");
      }
    } else {
      this.result.labels.forEach((item) => {
        this.category = this.result.labels;
      });
      // this.category = this.result.labels;
    }
    this.result.data.forEach((element) => {
      if (
        (this.level === "district" || this.level === "program") &&
        this.courseSelected === false
      ) {
        expectedEnrolled.push(Number(element[`expected_enrolled`]));
        enrollChartData.push(Number(element[`enrolled_percentage`]));
        compliChartData.push(Number(element[`percent_completion`]));
        pecentChartData.push(Number(element[`certificate_per`]));
      } else if (
        this.level === "block" ||
        this.level === "cluster" ||
        this.level === "school" ||
        this.level === "course"
      ) {
        enrollChartData.push(Number(element[`enrollment`]));
        compliChartData.push(Number(element[`completion`]));
        pecentChartData.push(Number(element[`certificate_value`]));
      } else if (this.level === "district" && this.courseSelected) {
        enrollChartData.push(Number(element[`enrollment`]));
        compliChartData.push(Number(element[`completion`]));
        pecentChartData.push(Number(element[`certificate_value`]));
      }

      // tool tip
      if (this.level === "district" || this.level === "program") {
        expectedEnrolledVal.push(Number([element[`expected_enrolled`]]));
        certificatPer.push(Number([element[`certificate_per`]]));
        certificatVal.push(Number([element[`certificate_value`]]));
        perCompletion.push(Number([element[`percent_completion`]]));
        enrComplition.push(Number([element[`enrollment`]]));
        enrComplitionVal.push(Number([element[`enrollment`]]));
        comComplition.push(Number([element[`completion`]]));
        this.completion.push([
          [...perCompletion],
          [...enrComplition],
          [...comComplition],
          [...expectedEnrolledVal],
          [...enrComplitionVal],
          [...expectedEnrolledVal],
        ]);
      } else if (
        this.level === "block" ||
        this.level === "cluster" ||
        this.level === "school"
      ) {
      }
    });

    this.enrollChartData = enrollChartData;
    this.expectedEnrolled = expectedEnrolled;
    this.compliChartData = compliChartData;
    this.pecentChartData = pecentChartData;
    this.footer = this.chartData
      .reduce((a, b) => Number(a) + Number(b), 0)
      .toString()
      .replace(/(\d)(?=(\d\d)+\d$)/g, "$1,");

    this.xAxisLabel = this.type.charAt(0).toUpperCase() + this.type.slice(1);
  }

  //Showing district data based on selected id:::::::::::::::::
  distLinkClick(districtId) {
    this.onDistSelect(districtId);
    // this.collectionName = '';
  }

  onDistSelect(districtId) {
    this.emptyChart();
    this.commonService.errMsg();
    // added
    this.expEnrolChartData = [];
    this.enrollChartData = [];
    this.compliChartData = [];
    this.pecentChartData = [];
    this.districtSelected = true;
    this.blockSelected = false;
    // this.result = null;
    this.globalId = districtId;
    this.blockHidden = false;
    this.clusterHidden = true;
    this.level = "block";
    this.skul = false;
    this.dist = true;
    this.blok = false;
    this.clust = false;
    this.blocks = [];
    this.clusters = [];

    this.blockId = undefined;
    this.clusterId = undefined;
    this.yAxisLabel = "Block Names";

    var requestBody: any = {
      timePeriod: this.timePeriod,
      districtId: districtId,
    };

    if (this.selectedProgram) {
      requestBody.programId = this.selectedProgram;
    }
    if (this.collectionName) {
      requestBody.courseId = this.collectionName;
    }
    if (this.programSeleted) {
      requestBody.programSeleted = this.programSeleted;
    }
    if (this.courseSelected) {
      requestBody.courseSelected = this.courseSelected;
    }
    if (this.districtSelected) {
      requestBody.districtSelected = this.districtSelected;
    }
    this.service.tpdBlockEnrollCompAll(requestBody).subscribe(
      async (res) => {
        this.result = res["chartData"];
        if (res["downloadData"].length !== 0) {
          this.districtHierarchy = {
            distId: res["downloadData"][0].district_id,
            districtName: res["downloadData"][0].district_name,
          };
        }
       
        this.fileName = `${this.reportName}_${this.type}_${this.timePeriod}_${districtId}_${this.commonService.dateAndTime}`;
        this.blocks = this.reportData = res["downloadData"];
        this.getBarChartData();
        this.commonService.loaderAndErr(this.result);
      },
      (err) => {
        this.result = [];
        this.emptyChart();
        this.commonService.loaderAndErr(this.result);
      }
    );
  }

  //Showing block data based on selected id:::::::::::::::::
  blockLinkClick(blockId) {
    this.onBlockSelect(blockId);
    // this.collectionName = '';
  }
  onBlockSelect(blockId) {
    this.emptyChart();
    this.commonService.errMsg();

    // added
    this.expEnrolChartData = [];
    this.enrollChartData = [];
    this.compliChartData = [];
    this.pecentChartData = [];

    this.globalId = blockId;
    this.blockHidden = false;
    this.clusterHidden = false;
    this.level = "cluster";
    this.skul = false;
    this.dist = false;
    this.blok = true;
    this.clust = false;
    this.clusters = [];

    this.clusterId = undefined;
    this.yAxisLabel = "Cluster Names";
    
     
    var requestBody: any = {
      timePeriod: this.timePeriod,
      blockId: blockId,
    };

    if (this.selectedProgram) {
      requestBody.programId = this.selectedProgram;
    }
    if (this.collectionName) {
      requestBody.courseId = this.collectionName;
    }
    if (this.districtSelected) {
      requestBody.districtSelected = this.districtSelected;
    }
    if (this.programSeleted) {
      requestBody.programSeleted = this.programSeleted;
    }
    if (this.courseSelected) {
      requestBody.courseSelected = this.courseSelected;
    }
    if (this.districtId) {
      requestBody.districtId = this.districtId;
    }


    this.service
      .tpdClusterEnrollCompAll(requestBody)
      .subscribe(
        async (res) => {
          this.result = res["chartData"];
          if (res["downloadData"].length !== 0) {
            this.blockHierarchy = {
              distId: res["downloadData"][0].district_id,
              districtName: res["downloadData"][0].district_name,
              blockId: res["downloadData"][0].block_id,
              blockName: res["downloadData"][0].block_name,
            };
          }

          this.fileName = `${this.reportName}_${this.type}_${this.timePeriod}_${blockId}_${this.commonService.dateAndTime}`;
          this.clusters = this.reportData = res["downloadData"];
          this.getBarChartData();
          this.commonService.loaderAndErr(this.result);
        },
        (err) => {
          this.result = [];
          this.emptyChart();
          this.commonService.loaderAndErr(this.result);
        }
      );
  }

  //Showing cluster data based on selected id:::::::::::::::::
  clusterLinkClick(clusterId) {
    this.onClusterSelect(clusterId);
  }
  onClusterSelect(clusterId) {
    this.emptyChart();
    this.commonService.errMsg();
    this.blockSelected = true
    // added
    this.expEnrolChartData = [];
    this.enrollChartData = [];
    this.compliChartData = [];
    this.pecentChartData = [];

    this.globalId = this.blockId;
    this.level = "school";
    this.skul = false;
    this.dist = false;
    this.blok = false;
    this.clust = true;

    this.yAxisLabel = "School Names";

    var requestBody: any = {
      timePeriod: this.timePeriod,
      blockId: this.blockId,
      clusterId: clusterId,
    };

    if (this.selectedProgram) {
      requestBody.programId = this.selectedProgram;
    }
    if (this.collectionName) {
      requestBody.courseId = this.collectionName;
    }
    if (this.districtId) {
      requestBody.districtId = this.districtId;
    }

    if (this.programSeleted) {
      requestBody.programSeleted = this.programSeleted;
    }
    if (this.courseSelected) {
      requestBody.courseSelected = this.courseSelected;
    }
    if(this.districtSelected){
      requestBody.districtSelected = this.districtSelected;
    }

    if(this.blockSelected){
      requestBody.blockSelected = this.blockSelected;
    }

    this.service
      .tpdSchoolEnrollCompAll(requestBody)
      .subscribe(
        async (res) => {
          this.result = res["chartData"];
          if (res["downloadData"].length !== 0) {
            this.clusterHierarchy = {
              distId: res["downloadData"][0].district_id,
              districtName: res["downloadData"][0].district_name,
              blockId: res["downloadData"][0].block_id,
              blockName: res["downloadData"][0].block_name,
              clusterId: res["downloadData"][0].cluster_id,
              clusterName: res["downloadData"][0].cluster_name,
            };
          }

          this.fileName = `${this.reportName}_${this.type}_${this.timePeriod}_${clusterId}_${this.commonService.dateAndTime}`;
          this.reportData = res["downloadData"];
          this.getBarChartData();
          this.commonService.loaderAndErr(this.result);
        },
        (err) => {
          this.result = [];
          this.emptyChart();
          this.commonService.loaderAndErr(this.result);
        }
      );
  }

  onClear() {
    this.collectionName = "";
    if (this.selectedProgram !== undefined) {
      this.onProgramSelect(this.selectedProgram);
    } else {
      this.homeClick();
    }
  }
  //Get data based on selected collection:::::::::::::::
  public collectionData;
  getDataBasedOnCollections($event) {
    this.courseSelected = true;
    this.districtSelected = false;
    this.blockSelected = false;
    this.blockHidden = true;
    this.clusterHidden = true;
    this.districtId = undefined;
    this.clusterId = undefined;
    
    this.level = 'district'
    if ($event) {
      this.collectionName = $event.collection_id;
      this.emptyChart();
      this.reportData = [];

      // added
      this.expEnrolChartData = [];
      this.enrollChartData = [];
      this.compliChartData = [];
      this.pecentChartData = [];

      this.commonService.errMsg();
      this.fileName = `${this.reportName}_${this.type}_${this.timePeriod}_${this.globalId}_${this.commonService.dateAndTime}`;
      this.footer = "";
      this.result = [];

      let requestBody: any = {
        timePeriod: this.timePeriod,
        collection_name: this.collectionName,
        level: this.level,
        id: this.globalId,
      };
      if (this.selectedProgram) {
        requestBody.programId = this.selectedProgram;
      }
      if (this.clusterId) {
        requestBody.clusterId = this.clusterId;
      }

      this.service.getCollectionData(requestBody).subscribe(
        async (res) => {
          this.result = res["chartData"];
          this.reportData = res["downloadData"];
          if (this.reportData.length !== 0) {
            if (this.level == "block") {
              this.districtHierarchy = {
                distId: res["downloadData"][0].district_id,
                districtName: res["downloadData"][0].district_name,
              };
            }
            if (this.level == "cluster") {
              this.blockHierarchy = {
                distId: res["downloadData"][0].district_id,
                districtName: res["downloadData"][0].district_name,
                blockId: res["downloadData"][0].block_id,
                blockName: res["downloadData"][0].block_name,
              };
            }
            if (this.level == "school") {
              this.clusterHierarchy = {
                distId: res["downloadData"][0].district_id,
                districtName: res["downloadData"][0].district_name,
                blockId: res["downloadData"][0].block_id,
                blockName: res["downloadData"][0].block_name,
                clusterId: res["downloadData"][0].cluster_id,
                clusterName: res["downloadData"][0].cluster_name,
              };
            }

            // this.commonService.loaderAndErr(this.result);
          }
          this.getBarChartData();
          this.commonService.loaderAndErr(this.result);
        },
        (err) => {
          this.commonService.loaderAndErr(this.result);
        }
      );
    }
  }

  //filter downloadable data
  dataToDownload = [];
  newDownload(element) {
    element["total_enrolled"] = element.total_enrolled
      .toString()
      .replace(/(\d)(?=(\d\d)+\d$)/g, "$1,");
    element["total_completed"] = element.total_completed
      .toString()
      .replace(/(\d)(?=(\d\d)+\d$)/g, "$1,");
    var data1 = {},
      data2 = {},
      data3 = {};

    Object.keys(element).forEach((key) => {
      data1[key] = element[key];
    });
    this.dataToDownload.push(data1);
  }

  //download UI data::::::::::::
  downloadReport() {
    this.dataToDownload = [];
    this.reportData.forEach((element) => {
      this.newDownload(element);
    });
    this.commonService.download(this.fileName, this.dataToDownload);
  }

  changeingStringCases(str) {
    return str.replace(/\w\S*/g, function (txt) {
      return txt.charAt(0).toUpperCase() + txt.substr(1).toLowerCase();
    });
  }
}
