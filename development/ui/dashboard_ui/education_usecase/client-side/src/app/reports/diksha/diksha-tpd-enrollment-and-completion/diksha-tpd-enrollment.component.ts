// The dashboard provides information on the total enrollments and
// completions for Teacher Professional Development courses at the district level.

import { Component, OnInit } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { DikshaReportService } from '../../../services/diksha-report.service';
import { Router } from '@angular/router';
import { AppServiceComponent } from '../../../app.service';

@Component({
  selector: 'app-diksha-tpd-enrollment',
  templateUrl: './diksha-tpd-enrollment.component.html',
  styleUrls: ['./diksha-tpd-enrollment.component.css']
})
export class DikshaTpdEnrollmentComponent implements OnInit {

  //chart data variables::::::::::::
  chart: boolean = false;
  public colors = [];
  header = '';
  level = "district";
  globalId;

  public category: String[] = [];
  public chartData: Number[] = [];
  public completion: Number[] = [];
  public xAxisLabel: String = "Enrollment";
  public yAxisLabel: String;
  public reportName: String = "enrollment_completion";
  public report = "enroll/comp"

  enrollTypes = [{ key: 'enrollment', name: 'Enrollment' }, { key: 'completion', name: 'Completion' }];
  type = 'enrollment';
  districts = [];
  districtId;
  blocks = [];
  blockId;
  clusters = [];
  clusterId;

  blockHidden = true;
  clusterHidden = true;

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
  public timePeriod = 'overall';
  public hierName: any;
  public all: boolean = false;
  public timeDetails: any = [{ id: "overall", name: "Overall" }, { id: "last_30_days", name: "Last 30 Days" }, { id: "last_7_days", name: "Last 7 Days" }, { id: "last_day", name: "Last Day" }];
  public districtsDetails: any = '';
  public myChart: Chart;
  public showAllChart: boolean = false;
  public allDataNotFound: any;
  public collectioTypes: any = [{ id: "course", type: "Course" }];
  public collectionNames: any = [];
  collectionName = '';
  footer;

  downloadType;
  fileName: any;
  reportData: any = [];
  y_axisValue;
  state: string;

  constructor(
    public http: HttpClient,
    public service: DikshaReportService,
    public commonService: AppServiceComponent,
    public router: Router,
  ) {
  }

  ngOnInit(): void {
    this.state = this.commonService.state;
    document.getElementById('accessProgressCard').style.display = 'none';
    //document.getElementById('backBtn').style.display = 'none';
    this.getAllData();
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
    //document.getElementById('home').style.display = "none";
    this.timePeriod = 'overall';
    this.type = 'enrollment';
    this.districtId = undefined;
    this.blockHidden = true;
    this.clusterHidden = true;
    this.yAxisLabel = "District Names";
    this.time = this.timePeriod == 'all' ? 'overall' : this.timePeriod;
    this.fileToDownload = `diksha_raw_data/tpd_report2/${this.time}/${this.time}.csv`;
    this.emptyChart();
    this.getAllData()
  }

  //getting all chart data to show:::::::::
  async getAllData() {
    this.emptyChart();
    if (this.timePeriod != 'overall') {
      //document.getElementById('home').style.display = "block";
    } else {
      //document.getElementById('home').style.display = "none";
    }
    this.districts = [];
    this.blocks = [];
    this.clusters = [];
    this.blockId = undefined;
    this.clusterId = undefined;
    this.collectionNames = [];
    this.commonService.errMsg();
    this.level = "district"
    //this.collectionName = '';
    this.footer = '';
    this.fileName = `${this.reportName}_${this.type}_all_district_${this.timePeriod}_${this.commonService.dateAndTime}`;
    this.result = [];
    this.all = true;
    this.skul = true;
    this.dist = false;
    this.blok = false;
    this.clust = false;
    this.yAxisLabel = "District Names"

    this.listCollectionNames();
    this.service.tpdDistEnrollCompAll({ timePeriod: this.timePeriod }).subscribe(async result => {
      this.result = result['chartData'];
      this.districts = this.reportData = result['downloadData'];
      this.getBarChartData();
      this.commonService.loaderAndErr(this.result);
    }, err => {
      this.result = [];
      this.emptyChart();
      this.commonService.loaderAndErr(this.result);
    });

  }

  //Lsiting all collection  names::::::::::::::::::
  listCollectionNames() {
    this.commonService.errMsg();
    //this.collectionName = '';
    this.service.tpdgetCollection({ timePeriod: this.timePeriod, level: this.level, id: this.globalId }).subscribe(async (res) => {
      this.collectionNames = [];
      this.collectionNames = res['allCollections'];
      this.collectionNames.sort((a, b) => (a > b) ? 1 : ((b > a) ? -1 : 0));
      document.getElementById('spinner').style.display = 'none';
    }, err => {
      this.result = [];
      this.emptyChart();
      this.commonService.loaderAndErr(this.result);
    })
  }

  time = this.timePeriod == 'all' ? 'overall' : this.timePeriod;
  fileToDownload = `diksha_raw_data/tpd_report2/${this.time}/${this.time}.csv`;

  //download raw file:::::::::::
  downloadRawFile() {
    this.service.downloadFile({ fileName: this.fileToDownload }).subscribe(res => {
      window.open(`${res['downloadUrl']}`, "_blank");
    }, err => {
      alert("No Raw Data File Available in Bucket");
    })
  }


  //Show data based on time-period selection:::::::::::::
  chooseTimeRange() {
    //document.getElementById('home').style.display = "block";
    this.time = this.timePeriod == 'all' ? 'overall' : this.timePeriod;
    this.fileToDownload = `diksha_raw_data/tpd_report2/${this.time}/${this.time}.csv`;
    if (this.level == 'district') {
      this.getAllData();
    }
    if (this.level == 'block') {
      this.onDistSelect(this.districtId);
    }
    if (this.level == 'cluster') {
      this.onBlockSelect(this.blockId);
    }
    if (this.level == 'school') {
      this.onClusterSelect(this.clusterId);
    }
  }

  //Showing data based on level selected:::::::
  onTypeSelect(type) {
    if (this.level == 'district') {
      this.getAllData();
    }
    if (this.level == 'block') {
      this.onDistSelect(this.districtId);
    }
    if (this.level == 'cluster') {
      this.onBlockSelect(this.blockId);
    }
    if (this.level == 'school') {
      this.onClusterSelect(this.clusterId);
    }
  }

  //getting all chart data to show:::::::::
  getBarChartData() {
    this.completion = [];
    if (this.result.labels.length <= 25) {
      for (let i = 0; i <= 25; i++) {
        this.category.push(this.result.labels[i] ? this.result.labels[i] : ' ')
      }
    } else {
      this.category = this.result.labels;
    }
    this.result.data.forEach(element => {
      this.chartData.push(Number(element[`${this.type}`]));
      if (this.type != 'completion') {
        this.completion.push(Number(element[`completion`]));
      } else {
        this.completion.push(Number(element[`enrollment`]));
      }
    });
    this.footer = (this.chartData.reduce((a, b) => Number(a) + Number(b), 0)).toString().replace(/(\d)(?=(\d\d)+\d$)/g, "$1,");

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
    //document.getElementById('home').style.display = "block";
    this.globalId = districtId;
    this.blockHidden = false;
    this.clusterHidden = true;
    this.level = "block"
    this.skul = false;
    this.dist = true;
    this.blok = false;
    this.clust = false;
    this.blocks = [];
    this.clusters = [];
    // this.collectionNames = [];
    this.blockId = undefined;
    this.clusterId = undefined;
    this.yAxisLabel = "Block Names"
    // this.listCollectionNames();
    this.service.tpdBlockEnrollCompAll({ timePeriod: this.timePeriod, districtId: districtId }).subscribe(async (res) => {
      console.log(res);
      this.result = res['chartData'];
      this.districtHierarchy = {
        distId: res['downloadData'][0].district_id,
        districtName: res['downloadData'][0].district_name
      }
      this.fileName = `${this.reportName}_${this.type}_${this.timePeriod}_${districtId}_${this.commonService.dateAndTime}`;
      this.blocks = this.reportData = res['downloadData'];
      // this.footer = result['footer'].toString().replace(/(\d)(?=(\d\d)+\d$)/g, "$1,");
      this.getBarChartData();
      this.commonService.loaderAndErr(this.result);
    }, err => {
      this.result = [];
      this.emptyChart();
      this.commonService.loaderAndErr(this.result);
    });
  }

  //Showing block data based on selected id:::::::::::::::::
  blockLinkClick(blockId) {
    this.onBlockSelect(blockId);
    // this.collectionName = '';
  }
  onBlockSelect(blockId) {
    this.emptyChart();
    this.commonService.errMsg();
    //document.getElementById('home').style.display = "block";
    this.globalId = blockId;
    this.blockHidden = false;
    this.clusterHidden = false;
    this.level = "cluster"
    this.skul = false;
    this.dist = false;
    this.blok = true;
    this.clust = false;
    this.clusters = [];
    // this.collectionNames = [];
    this.clusterId = undefined;
    this.yAxisLabel = "Cluster Names"
    // this.listCollectionNames();
    this.service.tpdClusterEnrollCompAll({ timePeriod: this.timePeriod, blockId: blockId }).subscribe(async (res) => {
      this.result = res['chartData'];
      this.blockHierarchy = {
        distId: res['downloadData'][0].district_id,
        districtName: res['downloadData'][0].district_name,
        blockId: res['downloadData'][0].block_id,
        blockName: res['downloadData'][0].block_name
      }
      this.fileName = `${this.reportName}_${this.type}_${this.timePeriod}_${blockId}_${this.commonService.dateAndTime}`;
      this.clusters = this.reportData = res['downloadData'];
      // this.footer = result['footer'].toString().replace(/(\d)(?=(\d\d)+\d$)/g, "$1,");
      this.getBarChartData();
      this.commonService.loaderAndErr(this.result);
    }, err => {
      this.result = [];
      this.emptyChart();
      this.commonService.loaderAndErr(this.result);
    });
  }

  //Showing cluster data based on selected id:::::::::::::::::
  clusterLinkClick(clusterId) {
    this.onClusterSelect(clusterId);
    // this.collectionName = '';
  }
  onClusterSelect(clusterId) {
    this.emptyChart();
    this.commonService.errMsg();
    //document.getElementById('home').style.display = "block";
    this.globalId = this.blockId;
    this.level = "school"
    this.skul = false;
    this.dist = false;
    this.blok = false;
    this.clust = true;
    // this.collectionNames = [];
    this.yAxisLabel = "School Names"
    // this.listCollectionNames();
    this.service.tpdSchoolEnrollCompAll({ timePeriod: this.timePeriod, blockId: this.blockId, clusterId: clusterId }).subscribe(async (res) => {
      this.result = res['chartData'];
      this.clusterHierarchy = {
        distId: res['downloadData'][0].district_id,
        districtName: res['downloadData'][0].district_name,
        blockId: res['downloadData'][0].block_id,
        blockName: res['downloadData'][0].block_name,
        clusterId: res['downloadData'][0].cluster_id,
        clusterName: res['downloadData'][0].cluster_name
      }
      this.fileName = `${this.reportName}_${this.type}_${this.timePeriod}_${clusterId}_${this.commonService.dateAndTime}`;
      this.reportData = res['downloadData'];
      // this.footer = result['footer'].toString().replace(/(\d)(?=(\d\d)+\d$)/g, "$1,");
      this.getBarChartData();
      this.commonService.loaderAndErr(this.result);
    }, err => {
      this.result = [];
      this.emptyChart();
      this.commonService.loaderAndErr(this.result);
    });
  }

  //Get data based on selected collection:::::::::::::::
  getDataBasedOnCollections() {
    this.emptyChart();
    this.reportData = [];
    //document.getElementById('home').style.display = "block";
    this.commonService.errMsg();
    this.fileName = `${this.reportName}_${this.type}_${this.timePeriod}_${this.globalId}_${this.commonService.dateAndTime}`;
    this.footer = '';
    this.result = [];
    this.service.getCollectionData({ timePeriod: this.timePeriod, collection_name: this.collectionName, level: this.level, id: this.globalId, clusterId: this.clusterId }).subscribe(async (res) => {
      this.result = res['chartData'];
      this.reportData = res['downloadData'];
      if (this.level == 'block') {
        this.districtHierarchy = {
          distId: res['downloadData'][0].district_id,
          districtName: res['downloadData'][0].district_name
        }
      }
      if (this.level == 'cluster') {
        this.blockHierarchy = {
          distId: res['downloadData'][0].district_id,
          districtName: res['downloadData'][0].district_name,
          blockId: res['downloadData'][0].block_id,
          blockName: res['downloadData'][0].block_name
        }
      }
      if (this.level == 'school') {
        this.clusterHierarchy = {
          distId: res['downloadData'][0].district_id,
          districtName: res['downloadData'][0].district_name,
          blockId: res['downloadData'][0].block_id,
          blockName: res['downloadData'][0].block_name,
          clusterId: res['downloadData'][0].cluster_id,
          clusterName: res['downloadData'][0].cluster_name
        }
      }
      // this.footer = res['footer'].toString().replace(/(\d)(?=(\d\d)+\d$)/g, "$1,");
      this.getBarChartData();
      this.commonService.loaderAndErr(this.result);
    }, err => {
      this.commonService.loaderAndErr(this.result);
    });
  }

  //filter downloadable data
  dataToDownload = [];
  newDownload(element) {
    element['total_enrolled'] = element.total_enrolled.toString().replace(/(\d)(?=(\d\d)+\d$)/g, "$1,");
    element['total_completed'] = element.total_completed.toString().replace(/(\d)(?=(\d\d)+\d$)/g, "$1,");
    var data1 = {}, data2 = {}, data3 = {};
    Object.keys(element).forEach(key => {
      if (key !== "percentage_completion") {
        data1[key] = element[key];
      }
    });
    Object.keys(data1).forEach(key => {
      if (key !== "percentage_teachers") {
        data2[key] = data1[key];
      }
    });
    var myKey = this.type == 'enrollment' ? "total_completed" : "total_enrolled";
    Object.keys(data2).forEach(key => {
      if (key !== myKey) {
        data3[key] = data2[key];
      }
    });
    this.dataToDownload.push(data3);
  }

  //download UI data::::::::::::
  downloadReport() {
    this.dataToDownload = [];
    this.reportData.forEach(element => {
      this.newDownload(element);
    });
    this.commonService.download(this.fileName, this.dataToDownload);
  }

  changeingStringCases(str) {
    return str.replace(
      /\w\S*/g,
      function (txt) {
        return txt.charAt(0).toUpperCase() + txt.substr(1).toLowerCase();
      }
    );
  }
}
