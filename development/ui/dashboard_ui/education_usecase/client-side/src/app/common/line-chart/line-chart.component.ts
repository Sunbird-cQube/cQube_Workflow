import { ChangeDetectorRef, Component, Input, OnChanges, OnInit } from '@angular/core';
// import * as Highcharts from 'highcharts/highstock'
import * as Highcharts from 'highcharts';

@Component({
  selector: 'app-line-chart',
  templateUrl: './line-chart.component.html',
  styleUrls: ['./line-chart.component.css']
})
export class LineChartComponent implements OnInit, OnChanges {
  Highcharts: typeof Highcharts = Highcharts;
  chartOptions;
  @Input() selectedYear;
  @Input() lineData: any = [];
  @Input() xAxisLabels: any = [];
  @Input() level = '';
  @Input() xAxisTitle;
  @Input() yAxisTitle;
  @Input() counts = [];
  @Input() managementName;
  @Input() chartId;
  @Input() reportName;
  constructor(private changeDetection: ChangeDetectorRef) { }

  ngOnInit(): void {
    this.onResize();
    this.changeDetection.detectChanges();
  }

  height = window.innerHeight;
  onResize() {
    this.height = window.innerHeight;
    this.getCurrentData();
    this.changeDetection.detectChanges();
    this.createChart();
  }


  ngOnChanges() {
    this.onResize();
  }

  public currentData: any = [];
  public dataArray = [];
  getCurrentData() {
    this.currentData = [];
    this.dataArray = [];
    this.lineData.map(item => {
      var obj = {
        marker: {
          radius: this.height > 1760 ? 8 : this.height > 1160 && this.height < 1760 ? 6 : this.height > 667 && this.height < 1160 ? 3 : 2.2
        },
        dataLabels: {
          enabled: true,
          style: {
            fontWeight: 1,
            fontSize: this.height > 1760 ? "32px" : this.height > 1160 && this.height < 1760 ? "22px" : this.height > 667 && this.height < 1160 ? "12px" : "10px"
          },
          formatter: function () {
            return this.y.toString().replace(/(\d)(?=(\d\d)+\d$)/g, "$1,");
          }
        },
        lineWidth: this.height > 1760 ? 6 : this.height > 1160 && this.height < 1760 ? 5 : this.height > 667 && this.height < 1160 ? 3 : 2.2,
        data: [],
        name: '',
        color: ''
      }
      obj.data = item.data;
      obj.name = item.name;
      obj.color = item.color;
      this.currentData.push(obj);
      obj.data.map(i => {
        if (typeof (i) == 'number')
          this.dataArray.push(i);
      })
    });
  }

  @Input() selected = "relative";

  createChart() {
    let reportName = this.reportName;
    var counts = this.counts;
    var academicYear = this.selectedYear;
    var level = this.level;
    var xAxisTitle = this.xAxisTitle;
    var yAxisTitle = this.yAxisTitle;
    this.chartOptions = {
      chart: {
        type: "line",
        backgroundColor: 'transparent',
      },
      title: {
        text: null
      },
      xAxis: {
        labels: {
          style: {
            color: 'black',
            fontSize: this.height > 1760 ? "32px" : this.height > 1160 && this.height < 1760 ? "22px" : this.height > 667 && this.height < 1160 ? "12px" : "10px"
          }
        },
        type: "category",
        gridLineColor: 'transparent',
        categories: this.xAxisLabels,
        min: 0,
        startOnTick: true,
        title: {
          text: xAxisTitle,
          style: {
            color: 'black',
            fontSize: this.height > 1760 ? "32px" : this.height > 1160 && this.height < 1760 ? "22px" : this.height > 667 && this.height < 1160 ? "12px" : "10px",
            fontWeight: "bold"
          }
        },
        scrollbar: {
          minWidth: 6,
          enabled: false,
        },
        tickLength: 0
      },
      yAxis: {
        labels: {
          style: {
            color: 'black',
            fontSize: this.height > 1760 ? "30px" : this.height > 1160 && this.height < 1760 ? "20px" : this.height > 667 && this.height < 1160 ? "12px" : "10px"
          },
          formatter: function () {
            return this.value.toString().replace(/(\d)(?=(\d\d)+\d$)/g, "$1,");
          }
        },
        min: this.selected == 'absolute' ? 0 : Math.min(...this.dataArray) - 2,
        max: this.selected == 'absolute' ? 100 : Math.max(...this.dataArray),
        startOnTick: false,
        opposite: false,
        gridLineColor: 'transparent',
        title: {
          text: yAxisTitle,
          style: {
            color: 'black',
            fontSize: this.height > 1760 ? "32px" : this.height > 1160 && this.height < 1760 ? "22px" : this.height > 667 && this.height < 1160 ? "12px" : "10px",
            fontWeight: "bold"
          }
        }
      },
      plotOptions: {
        bar: {
          dataLabels: {
            enabled: true
          }
        },
        series: {
          pointPadding: 0,
          groupPadding: 0
        }
      },
      legend: {
        enabled: false,
      },
      credits: {
        enabled: false
      },
      series: this.currentData,
      tooltip: {
        style: {
          fontSize: this.height > 1760 ? "32px" : this.height > 1160 && this.height < 1760 ? "22px" : this.height > 667 && this.height < 1160 ? "12px" : "10px",
          opacity: 1,
          backgroundColor: "white"
        },
        formatter: function () {
          if (this.point.category != 0) {
            return '<b>' + getPointCategoryName(this.point, level, counts, academicYear, reportName) + '</b>';
          } else {
            return false;
          }
        }
      }
    }
    this.Highcharts.chart(this.chartId, this.chartOptions);

    function getPointCategoryName(point, level, counts, academicYear, reportName) {
      var obj = '';
      if (reportName == 'sar') {
        obj = `<b>Acedmic Year:</b> ${academicYear} 
        <br><b>Month:</b> ${point.category}
        <br> ${`<b>${level} Name:</b> ${point.series.name}`}
        <br>${counts[point.series.index][point.index].schoolCount ? `<b>School Count:</b> ${counts[point.series.index][point.index].schoolCount}` : ''}
        <br>${counts[point.series.index][point.index].studentCount ? `<b>Student Count:</b> ${counts[point.series.index][point.index].studentCount}` : ''}
        <br> ${point.y !== null ? `<b>Attendance:</b> ${point.y.toString().replace(/(\d)(?=(\d\d)+\d$)/g, "$1,")} % ` : ''}`
      }
      if (reportName == 'sat') {
        obj = `<b>Acedmic Year:</b> ${academicYear} 
        <br><b>Month:</b> ${point.category}
        <br>${`<b>${level} Name:</b> ${point.series.name}`}
        ${counts[point.series.index][point.index].grade != "AllGrades" ? `<br><b>Grade:</b> ${counts[point.series.index][point.index].grade}` : ''}
        <br>${counts[point.series.index][point.index].schoolCount ? `<b>School Count:</b> ${counts[point.series.index][point.index].schoolCount}` : ''}
        <br>${counts[point.series.index][point.index].studentCount ? `<b>Student Count:</b> ${counts[point.series.index][point.index].studentCount}` : ''}
        <br>${counts[point.series.index][point.index].studentAttended ? `<b>Student Attended:</b> ${counts[point.series.index][point.index].studentAttended}` : ''}
        <br>${point.y !== null ? `<b>Performance:</b> ${point.y.toString().replace(/(\d)(?=(\d\d)+\d$)/g, "$1,")} % ` : ''}`
      }
      return obj;
    }
  }

}