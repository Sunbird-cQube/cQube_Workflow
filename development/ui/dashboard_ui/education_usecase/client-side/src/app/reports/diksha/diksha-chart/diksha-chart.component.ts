import { Component, OnInit, ViewEncapsulation } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { DikshaReportService } from '../../../services/diksha-report.service';
import { Router } from '@angular/router';
import { ExportToCsv } from 'export-to-csv';
import { ChartOptions, ChartType, ChartDataSets } from 'chart.js';
import { Label, Color } from 'ng2-charts';
import { AppServiceComponent } from 'src/app/app.service';

@Component({
  selector: 'app-diksha-chart',
  templateUrl: './diksha-chart.component.html',
  styleUrls: ['./diksha-chart.component.css'],
  encapsulation: ViewEncapsulation.None
})
export class DikshaChartComponent implements OnInit {
  chart1: boolean = false;
  chart2: boolean = false;
  chart3: boolean = false;
  chart4: boolean = false;

  usagebyOthers = `Total Content Usage by Others : `;
  usageByTeachers = `Total Content Usage by Teachers : `;
  usageByStudents = `Total Content Usage by Students : `;

  public colors = [];
  public barChartOptions: ChartOptions = {};
  public barChartLabels: Label[] = [];
  public barChartLabels1: Label[] = [];
  public barChartLabels2: Label[] = [];
  public barChartLabels3: Label[] = [];
  public barChartType: ChartType = 'bar';
  public barChartLegend = true;
  public barChartPlugins = [];

  public barChartColors: Color[] = [];
  public barChartColors1: Color[] = [];
  public barChartColors2: Color[] = [];
  public barChartColors3: Color[] = [];

  public barChartData: ChartDataSets[] = [
    { data: [], label: 'Series A', stack: 'a' }
  ];

  public barChartData1: ChartDataSets[] = [
    { data: [], label: 'Series A', stack: 'a' }
  ];

  public barChartData2: ChartDataSets[] = [
    { data: [], label: 'Series A', stack: 'a' }
  ];

  public barChartData3: ChartDataSets[] = [
    { data: [], label: 'Series A', stack: 'a' }
  ];

  public result: any = [];
  public districtId: any = '';
  public timePeriod = 'last_30_days';
  public hierName: any;
  public dist: boolean = false;
  public all: boolean = false;
  public timeDetails: any = [];
  public districtsDetails: any = '';
  public myChart: Chart;
  public showAllChart: boolean = false;
  public allDataNotFound: any;
  public usageByType: any = [{ type: "All" }, { type: "Teacher" }, { type: "Student" }, { type: "Other" }];
  downloadType;
  fileName: any;
  reportData: any = [];
  y_axisValue;
  footer;
  state: string;
  public reportName = "usage_by_user_profile";

  constructor(
    public http: HttpClient,
    public service: DikshaReportService,
    public commonService: AppServiceComponent,
    public router: Router
  ) {
  }

  ngOnInit(): void {
    this.state = this.commonService.state;
    document.getElementById('accessProgressCard').style.display = 'none';
    document.getElementById('backBtn') ? document.getElementById('backBtn').style.display = 'none' : "";
    this.metaData();
    this.getAllData();
  }
  loaderAndErr() {
    if (this.result.length !== 0) {
      document.getElementById('spinner').style.display = 'none';
    } else {
      document.getElementById('spinner').style.display = 'none';
      document.getElementById('errMsg').style.color = 'red';
      document.getElementById('errMsg').style.display = 'block';
    }
  }
  metaData() {
    document.getElementById('spinner').style.display = 'block';
    this.service.dikshaMetaData().subscribe((result) => {
      this.districtsDetails = result['districtDetails']
      result['timeRange'].forEach((element) => {
        var obj = { timeRange: element, name: this.changeingStringCases(element.replace(/_/g, ' ')) }
        this.timeDetails.push(obj);
      });
    }, err => {
      console.log(err);
      this.loaderAndErr();
    })
  }

  errMsg() {
    document.getElementById('errMsg').style.display = 'none';
    document.getElementById('spinner').style.display = 'block';
    document.getElementById('spinner').style.marginTop = '3%';
  }
  emptyChart() {
    this.barChartData = [
      { data: [], label: '', stack: 'a' }
    ];

    this.barChartData1 = [
      { data: [], label: '', stack: 'a' }
    ];

    this.barChartData2 = [
      { data: [], label: '', stack: 'a' }
    ];

    this.barChartData3 = [
      { data: [], label: '', stack: 'a' }
    ];
  }
  public legendColors = [];
  homeClick() {
    this.timePeriod = 'last_30_days';
    this.fileToDownload = `diksha_raw_data/stack_bar_reports/${this.timePeriod}/${this.timePeriod}.csv`;
    this.getAllData();
  }
  async getAllData() {
    this.emptyChart();

    this.errMsg();
    this.districtId = '';
    this.footer = '';
    this.hierName = undefined;

    this.result = [];
    this.all = true
    this.dist = false
    this.service.dikshaAllData('All', this.timePeriod).subscribe(async result => {
      var arr = [];
      this.footer = result['footer'].toString().replace(/(\d)(?=(\d\d)+\d$)/g, "$1,");
      var maxValue = 0;
      this.legendColors = [];
      this.subjects = [];
      await result['funRes']['data'].forEach(async element => {
        arr.push(element.score.map(Number));
        this.legendColors.push(this.getColor(element));
        this.subjects.push(element.subject);
      });
      var array = arr;
      var result1 = array.reduce((r, a) => a.map((b, i) => (r[i] || 0) + b), []);
      maxValue = Math.max(...result1);
      this.y_axisValue = maxValue;

      this.createChart(result['funRes'], "barChartData");

      if (result['funRes']['data']) {
        this.chart1 = (result['funRes']['data'][0].length > 0);
      }

      this.service.dikshaAllData('Teacher', this.timePeriod).subscribe(result => {
        this.createChart(result['funRes'], "barChartData1");
        if (result['funRes']['data']) {
          this.chart2 = (result['funRes']['data'][0].length > 0);
        }
      }, err => {
        this.loaderAndErr();
      })
      this.service.dikshaAllData('Student', this.timePeriod).subscribe(result => {
        this.createChart(result['funRes'], "barChartData2");
        if (result['funRes']['data']) {
          this.chart3 = (result['funRes']['data'][0].length > 0);
        }
      }, err => {
        this.loaderAndErr();
      })
      this.service.dikshaAllData('Other', this.timePeriod).subscribe(result => {

        this.createChart(result['funRes'], "barChartData3");
        if (result['funRes']['data']) {
          this.chart4 = (result['funRes']['data'][0].length > 0);
        }
        document.getElementById('spinner').style.display = 'none';
      }, err => {
        this.loaderAndErr();
      })
    }, err => {
      this.loaderAndErr();
    });

  }


  districtWise(districtId) {
    this.emptyChart();
    this.errMsg();

    this.districtId = districtId
    this.hierName = undefined;
    this.footer = '';
    this.all = false
    this.dist = true
    let d = this.districtsDetails.filter(item => {
      if (item.district_id == districtId)
        return item.district_name
    })
    this.hierName = d[0].district_name;
    this.timeRange(this.timePeriod);
  }

  fileToDownload = `diksha_raw_data/stack_bar_reports/${this.timePeriod}/${this.timePeriod}.csv`;
  timeRange(timePeriod) {
    this.emptyChart();
    this.fileToDownload = `diksha_raw_data/stack_bar_reports/${this.timePeriod}/${this.timePeriod}.csv`;

    this.allDataNotFound = undefined;
    this.errMsg();
    this.result = [];
    this.footer = '';
    if (this.districtId == '') {
      this.districtId = 'All'
    }
    this.timePeriod = timePeriod

    this.service.dikshaDistData(this.districtId, 'All', this.timePeriod).subscribe(async result => {
      var arr = [];
      var maxValue = 0;
      this.footer = result['footer'].toString().replace(/(\d)(?=(\d\d)+\d$)/g, "$1,");
      this.legendColors = [];
      this.subjects = [];
      await result['funRes']['data'].forEach(async element => {
        arr.push(element.score.map(Number));
        this.legendColors.push(this.getColor(element));
        this.subjects.push(element.subject);
      });
      var array = arr;
      var result1 = array.reduce((r, a) => a.map((b, i) => (r[i] || 0) + b), []);
      maxValue = Math.max(...result1);
      this.y_axisValue = maxValue;

      this.createChart(result['funRes'], "barChartData");
      if (result['funRes']['data']) {
        this.chart1 = (result['funRes']['data'][0].length > 0);
      }

      this.service.dikshaDistData(this.districtId, 'Teacher', this.timePeriod).subscribe(result => {
        this.createChart(result['funRes'], "barChartData1");
        if (result['funRes']['data']) {
          this.chart2 = (result['funRes']['data'][0].length > 0);
        }

      }, err => {
        this.loaderAndErr();
        console.log(err);
      })
      this.service.dikshaDistData(this.districtId, 'Student', this.timePeriod).subscribe(result => {
        this.createChart(result['funRes'], "barChartData2");
        if (result['funRes']['data']) {
          this.chart3 = (result['funRes']['data'][0].length > 0);
        }

      }, err => {
        this.loaderAndErr();
        console.log(err);
      })
      this.service.dikshaDistData(this.districtId, 'Other', this.timePeriod).subscribe(result => {

        this.createChart(result['funRes'], "barChartData3");
        if (result['funRes']['data']) {
          this.chart4 = (result['funRes']['data'][0].length > 0);
        }

        document.getElementById('spinner').style.display = 'none';
      }, err => {
        this.loaderAndErr();
        console.log(err);
      });
    }, err => {
      this.loaderAndErr();
      this.result = [];
      this.showAllChart = (this.result.length! > 0);
      this.allDataNotFound = err.error.errMsg;
    })

  }

  downloadRawFile() {
    this.service.downloadFile({ fileName: this.fileToDownload }).subscribe(res => {
      window.open(`${res['downloadUrl']}`, "_blank");
    }, err => {
      alert("No Raw Data File Available in Bucket");
    })
  }

  getColor(element) {
    let a = { backgroundColor: '' };
    if (element.subject == 'Sanskrit') {
      a.backgroundColor = '#a6cee3'
    }
    if (element.subject == 'Gujarati') {
      a.backgroundColor = '#1f78b4'
    }
    if (element.subject == 'Science') {
      a.backgroundColor = '#b2df8a'
    }
    if (element.subject == 'Gyan Setu') {
      a.backgroundColor = '#33a02c'
    }
    if (element.subject == 'Environmental Studies') {
      a.backgroundColor = '#fb9a99'
    }
    if (element.subject == 'Hindi') {
      a.backgroundColor = '#e31a1c'
    }
    if (element.subject == 'Multi Subject') {
      a.backgroundColor = '#fdbf6f'
    }
    if (element.subject == 'Mathematics') {
      a.backgroundColor = '#ff7f00'
    }
    if (element.subject == 'English') {
      a.backgroundColor = '#cab2d6'
    }
    if (element.subject == 'Social Science') {
      a.backgroundColor = '#6a3d9a'
    }
    if (element.subject == 'Training') {
      a.backgroundColor = '#e31a1c'
    }
    if (element.subject == 'Psychology') {
      a.backgroundColor = '#b1592a'
    }
    if (element.subject == 'Biology') {
      a.backgroundColor = '#ff7fff'
    }
    if (element.subject == 'Physics') {
      a.backgroundColor = '#ffff99'
    }
    return a;
  }

  public subjects = [];
  createChart(data, barChartData) {
    var chartData = [];
    var colors = [];
    if (data.data != undefined) {
      data.data.forEach(async element => {
        var obj = { data: element.score, label: element.subject, stack: 'a' }
        chartData.push(obj);
        colors.push(this.getColor(element));
      });
      this.barChartOptions = {
        legend: {
          display: false
        },
        responsive: true,
        tooltips: {
          mode: 'index',
          custom: function (tooltip) {
            if (!tooltip) return;
            tooltip.displayColors = false;
          },
        },

        scales: {
          xAxes: [{
            gridLines: {
              color: "rgba(252, 239, 252)",
            },
            ticks: {
              fontColor: 'black',
              min: 0
            },
            scaleLabel: {
              fontColor: "black",
              display: true,
              labelString: "Content-Grade(Group)",
              fontSize: 12,
            }
          }],
          yAxes: [{
            gridLines: {
              color: "rgba(252, 239, 252)",
            },
            ticks: {
              fontColor: 'black',
              min: 0,
              max: this.y_axisValue
            },
            scaleLabel: {
              fontColor: "black",
              display: true,
              labelString: "Total Content Play",
              fontSize: 12,
            }
          }]
        }
      }
      if (barChartData == "barChartData") {
        this.barChartLabels = data.grades;
        this.barChartData = chartData;
        this.barChartColors = colors;
      }
      if (barChartData == "barChartData1") {
        this.barChartLabels1 = data.grades;
        this.barChartData1 = chartData;
        this.barChartColors1 = colors;
      }
      if (barChartData == "barChartData2") {
        this.barChartLabels2 = data.grades;
        this.barChartData2 = chartData;
        this.barChartColors2 = colors;
      }
      if (barChartData == "barChartData3") {
        this.barChartLabels3 = data.grades;
        this.barChartData3 = chartData;
        this.barChartColors3 = colors;
      }

    }

  }

  onChange() {
    document.getElementById('errMsg').style.display = 'none';
  }

  downloadReportByType(type) {
    this.reportData = [];
    if (type) {
      this.errMsg();
      this.service.dikshaDataDownload({ districtId: this.districtId, timePeriod: this.timePeriod }).subscribe(res => {
        if (this.districtId == '' || this.districtId == undefined || this.hierName == undefined) {
          if (res['All'][`${type}`]) {
            this.fileName = `${this.reportName}_${type}_${this.timePeriod}_${this.commonService.dateAndTime}`;
            res['All'][`${type}`].forEach(element => {
              var obj1 = {};
              var obj2 = {};
              Object.keys(element).forEach(key => {
                if (key !== "district_id") {
                  obj1[key] = element[key];
                }
              });
              Object.keys(obj1).forEach(key => {
                if (key !== "district_name") {
                  obj2[key] = obj1[key];
                }
              });
              this.reportData.push(obj2);
            });
            this.downloadReport();
          } else {
            document.getElementById('errMsg').innerHTML = 'No data found for this type';
            document.getElementById('errMsg').style.display = 'block';
            document.getElementById('errMsg').style.color = 'red';
          }

        } else {
          if (res[`${this.districtId}`][`${type}`]) {
            this.fileName = `${this.reportName}_${type}_${this.timePeriod}_${this.districtId}_${this.commonService.dateAndTime}`;
            this.reportData = res[`${this.districtId}`][`${type}`];
            this.downloadReport();
          } else {
            document.getElementById('errMsg').innerHTML = 'No data found for this type';
            document.getElementById('errMsg').style.display = 'block';
            document.getElementById('errMsg').style.color = 'red';
          }
        }
        document.getElementById('spinner').style.display = 'none';
      }, err => {
        console.log(err);
        document.getElementById('spinner').style.display = 'none';
        alert("No data found for this type");
      })
    } else {
      document.getElementById('errMsg').innerHTML = 'Please select download type';
      document.getElementById('errMsg').style.display = 'block';
      document.getElementById('errMsg').style.color = 'red';
    }

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
