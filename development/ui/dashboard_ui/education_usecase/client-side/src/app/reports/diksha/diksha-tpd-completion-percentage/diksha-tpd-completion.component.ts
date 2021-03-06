// The dashboard provides information on the % of teachers who have
//  completed Teacher Professional Development courses at the district level.

import { Component, OnInit } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { DikshaReportService } from '../../../services/diksha-report.service';
import { Router } from '@angular/router';
import { AppServiceComponent } from '../../../app.service';

@Component({
  selector: 'app-diksha-tpd-completion',
  templateUrl: './diksha-tpd-completion.component.html',
  styleUrls: ['./diksha-tpd-completion.component.css']
})
export class DikshaTpdCompletionComponent implements OnInit {
  //chart data variabes:::::::::::::
  chart: boolean = false;
  public colors = [];
  header = '';
  chartHeight;
  public category: String[] = [];
  public chartData: Number[] = [];
  public xAxisLabel: String = "Completion Percentage";
  public yAxisLabel: String;
  public reportName = "completion_percentage";
  public report = "completion"

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
  public districtHierarchy: any = '';
  public blockHierarchy: any = '';
  public clusterHierarchy: any = '';

  public result: any = [];
  public timePeriod = 'overall';
  public hierName: any;
  public all: boolean = false;
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
  state: string;
  level: string = "district";
  ylabel: String[];

  globalId: any;

  constructor(
    public http: HttpClient,
    public service: DikshaReportService,
    public commonService: AppServiceComponent,
    public router: Router,
  ) { }

  ngOnInit(): void {
    this.state = this.commonService.state;
    document.getElementById('accessProgressCard').style.display = 'none';
    //document.getElementById('backBtn') ?document.getElementById('backBtn').style.display = 'none' : "";
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
  }

  homeClick() {

    this.timePeriod = 'overall';
    this.districtId = undefined;
    this.blockHidden = true;
    this.clusterHidden = true;
    this.yAxisLabel = "District Names"
    this.collectionName = '';
    this.emptyChart();
    this.getAllData()
  }

  //getting all chart data to show:::::::::
  async getAllData() {
    this.emptyChart();
    if (this.timePeriod != 'overall') {

    } else {

    }
    this.commonService.errMsg();
    this.districts = [];
    this.blocks = [];
    this.clusters = [];
    this.blockId = undefined;
    this.clusterId = undefined;
    this.collectionNames = [];
    this.collectionName = '';
    this.footer = '';
    this.fileName = `${this.reportName}_all_district_${this.timePeriod}_${this.commonService.dateAndTime}`;
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
    this.collectionName = '';
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

  //Show data based on time-period selection:::::::::::::
  chooseTimeRange() {

    this.time = this.timePeriod == 'all' ? 'overall' : this.timePeriod;
    this.fileToDownload = `diksha_raw_data/tpd_report2/${this.time}/${this.time}.csv`;
    this.getAllData();
  }

  //download raw file:::::::::::
  downloadRawFile() {
    this.service.downloadFile({ fileName: this.fileToDownload }).subscribe(res => {
      window.open(`${res['downloadUrl']}`, "_blank");
    }, err => {
      alert("No Raw Data File Available in Bucket");
    })
  }

  //getting all chart data to show:::::::::
  getBarChartData() {
    if (this.result.labels.length <= 25) {
      for (let i = 0; i <= 25; i++) {
        this.category.push(this.result.labels[i] ? this.result.labels[i] : ' ')
      }
    } else {
      this.category = this.result.labels;
    }
    this.result.data.forEach(element => {
      this.chartData.push(Number(element[`percent_completion`]));
    });
  }

  //Showing district data based on selected id:::::::::::::::::
  onDistSelect(districtId) {
    this.emptyChart();
    this.commonService.errMsg();

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

    this.blockId = undefined;
    this.clusterId = undefined;
    this.yAxisLabel = "Block Names"

    this.service.tpdBlockEnrollCompAll({ timePeriod: this.timePeriod, districtId: districtId }).subscribe(async (res) => {
      this.result = res['chartData'];
      this.districtHierarchy = {
        distId: res['downloadData'][0].district_id,
        districtName: res['downloadData'][0].district_name
      }
      this.fileName = `${this.reportName}_${this.timePeriod}_${districtId}_${this.commonService.dateAndTime}`;
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
  onBlockSelect(blockId) {
    this.emptyChart();
    this.commonService.errMsg();

    this.globalId = blockId;
    this.blockHidden = false;
    this.clusterHidden = false;
    this.level = "cluster"
    this.skul = false;
    this.dist = false;
    this.blok = true;
    this.clust = false;
    this.clusters = [];

    this.clusterId = undefined;
    this.yAxisLabel = "Cluster Names"

    this.service.tpdClusterEnrollCompAll({ timePeriod: this.timePeriod, blockId: blockId }).subscribe(async (res) => {
      this.result = res['chartData'];
      this.blockHierarchy = {
        distId: res['downloadData'][0].district_id,
        districtName: res['downloadData'][0].district_name,
        blockId: res['downloadData'][0].block_id,
        blockName: res['downloadData'][0].block_name
      }
      this.fileName = `${this.reportName}_${this.timePeriod}_${blockId}_${this.commonService.dateAndTime}`;
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
  onClusterSelect(clusterId) {
    this.emptyChart()
    this.commonService.errMsg();

    this.globalId = this.blockId;
    this.level = "school"
    this.skul = false;
    this.dist = false;
    this.blok = false;
    this.clust = true;

    this.yAxisLabel = "School Names"

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
      this.fileName = `${this.reportName}_${this.timePeriod}_${clusterId}_${this.commonService.dateAndTime}`;
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

    this.commonService.errMsg();
    this.fileName = `${this.reportName}_${this.timePeriod}_${this.globalId}_${this.commonService.dateAndTime}`;
    this.footer = '';
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

  onChange() {
    document.getElementById('errMsg').style.display = 'none';
  }

  //to filter downloadable data
  dataToDownload = [];
  newDownload(element) {
    var data1 = {}, data2 = {};
    Object.keys(element).forEach(key => {
      if (key !== "total_completed") {
        data1[key] = element[key];
      }
    });
    Object.keys(data1).forEach(key => {
      if (key !== "total_enrolled") {
        data2[key] = data1[key];
      }
    });

    this.dataToDownload.push(data2);
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

