// The dashboard provides information on the total content plays at
// the course level for Teacher Professional Development courses at the district level.

import { Component, OnInit, ViewEncapsulation } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { DikshaReportService } from '../../../services/diksha-report.service';
import { Router } from '@angular/router';
import { AppServiceComponent } from '../../../app.service';
import { DomSanitizer } from '@angular/platform-browser';
import { environment } from 'src/environments/environment';

@Component({
  selector: 'app-diksha-bar-chart',
  templateUrl: './diksha-bar-chart.component.html',
  styleUrls: ['./diksha-bar-chart.component.css'],
  encapsulation: ViewEncapsulation.None
})
export class DikshaBarChartComponent implements OnInit {
  chart: boolean = false;
  public colors = [];
  public waterMark = environment.water_mark
  header = '';
  public category: String[] = [];
  public chartData: Number[] = [];
  public xAxisLabel: String = "Total Content Plays";
  public yAxisLabel: String = "District Names";

  public collection_type: String = 'course';

  public result: any = [];
  public timePeriod = 'all';
  public hierName: any;
  public dist: boolean = false;
  public all: boolean = false;
  public timeDetails: any = [{ id: "all", name: "Overall" }, { id: "last_30_days", name: "Last 30 Days" }, { id: "last_7_days", name: "Last 7 Days" }, { id: "last_day", name: "Last Day" }];
  public districtsDetails: any = '';
  public myChart: Chart;
  public collectioTypes: any = [{ id: "course", type: "Course" }];
  public collectionNames: any = [];
  collectionName = '';
  footer;

  downloadType;
  fileName: any;
  reportData: any = [];
  y_axisValue;
  state: string;

  reportName = 'usage_by_course';

  constructor(
    public http: HttpClient,
    public service: DikshaReportService,
    public commonService: AppServiceComponent,
    public router: Router,
    private sanitizer: DomSanitizer
  ) {
  }
  userAccessLevel = localStorage.getItem('userLevel')
  showError = false
  ngOnInit(): void {
    this.state = this.commonService.state;
    document.getElementById('accessProgressCard').style.display = 'none';
    document.getElementById('backBtn') ? document.getElementById('backBtn').style.display = 'none' : "";
    if (environment.auth_api === 'cqube' || this.userAccessLevel === "") {
      this.getAllData();
    }else{
      document.getElementById('spinner').style.display = "none"
      this.showError = true
    }
    
  }

  //making chart empty
  emptyChart() {
    this.result = [];
    this.chartData = [];
    this.category = [];
  }

  homeClick() {

    this.timePeriod = 'all';
    this.getAllData()
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
      this.chartData.push(Number(element[`total_content_plays`]));
    });
  }

  async getAllData() {
    this.emptyChart();
    if (this.timePeriod != 'all') {

    } else {

    }
    this.reportData = [];
    this.commonService.errMsg();

    this.collectionName = '';
    this.footer = '';
    this.fileName = `${this.reportName}_${this.timePeriod}_${this.commonService.dateAndTime}`;
    this.result = [];
    this.all = true
    this.dist = false;
    this.header = this.changeingStringCases(this.collection_type) + " Linked";

    this.listCollectionNames();
    this.service.dikshaBarChart({ collection_type: this.collection_type }).subscribe(async result => {
      this.result = result['chartData'];
      this.reportData = result['downloadData'];
      this.footer = result['footer'].toString().replace(/(\d)(?=(\d\d)+\d$)/g, "$1,");
      this.time = this.timePeriod == 'all' ? 'overall' : this.timePeriod;
      this.fileToDownload = `diksha_raw_data/table_reports/course/${this.time}/${this.time}.csv`;
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
    this.emptyChart();
    this.commonService.errMsg();
    this.collectionName = '';
    this.footer = '';
    this.reportData = [];

    this.service.listCollectionNames({ collection_type: this.collection_type, timePeriod: this.timePeriod == 'all' ? '' : this.timePeriod }).subscribe(async (res) => {

      this.collectionNames = [];
      this.collectionNames = res['uniqueCollections'];
      this.collectionNames.sort((a, b) => (a > b) ? 1 : ((b > a) ? -1 : 0));
      if (res['chartData']) {
        this.result = [];
        this.emptyChart();
        this.result = res['chartData'];
        this.footer = res['footer'].toString().replace(/(\d)(?=(\d\d)+\d$)/g, "$1,");
        this.getBarChartData();
        this.reportData = res['downloadData'];
      }
      this.commonService.loaderAndErr(this.result);
    }, err => {
      this.collectionNames = [];
      this.result = [];
      this.emptyChart();
      this.commonService.loaderAndErr(this.result);
    })
  }


  time = this.timePeriod == 'all' ? 'overall' : this.timePeriod;
  fileToDownload = `diksha_raw_data/table_reports/course/${this.time}/${this.time}.csv`;

  //Show data based on time-period selection:::::::::::::
  chooseTimeRange() {
    this.emptyChart();
    this.time = this.timePeriod == 'all' ? 'overall' : this.timePeriod;
    this.fileToDownload = `diksha_raw_data/table_reports/course/${this.time}/${this.time}.csv`;
    if (this.timePeriod == 'all') {
      this.getAllData();
    } else {
      this.listCollectionNames();
    }

  }

  //download raw file:::::::::::
  downloadRawFile() {
    this.commonService.errMsg();
    this.service.downloadFile({ fileName: this.fileToDownload }).subscribe(res => {
      if (res['data']) {
        this.commonService.download(this.time, res['data']);
        this.commonService.loaderAndErr([]);
      } else {
        window.open(`${res['downloadUrl']}`, "_blank");
        this.commonService.loaderAndErr([]);
      }
    }, err => {
      alert("No Raw Data File Available in Bucket");
    })
  }


  //Get data based on selected collection:::::::::::::::
  getDataBasedOnCollections() {
    this.emptyChart();
    this.reportData = [];

    this.commonService.errMsg();
    this.fileName = `${this.reportName}_${this.timePeriod}_${this.commonService.dateAndTime}`;
    this.footer = '';
    this.result = [];
    this.all = true
    this.dist = false
    this.service.getDataByCollectionNames({ collection_type: this.collection_type, timePeriod: this.timePeriod == 'all' ? '' : this.timePeriod, collection_name: this.collectionName }).subscribe(async res => {
      this.result = res['chartData'];
      this.reportData = res['downloadData'];
      this.footer = res['footer'].toString().replace(/(\d)(?=(\d\d)+\d$)/g, "$1,");
      this.getBarChartData();
      this.commonService.loaderAndErr(this.result);
    }, err => {
      this.commonService.loaderAndErr(this.result);
    });
  }

  onChange() {
    document.getElementById('errMsg').style.display = 'none';
  }

  downloadReport() {
    this.commonService.download(this.fileName, this.reportData);
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
