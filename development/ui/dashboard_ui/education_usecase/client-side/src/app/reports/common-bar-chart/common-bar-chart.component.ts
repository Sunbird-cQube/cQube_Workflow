
import { ChangeDetectorRef, Component, Input, OnInit } from "@angular/core";
import * as Highcharts from 'highcharts/highstock'

@Component({
  selector: 'app-common-bar-chart',
  templateUrl: './common-bar-chart.component.html',
  styleUrls: ['./common-bar-chart.component.css']
})
export class CommonBarChartComponent implements OnInit {
  Highcharts: typeof Highcharts = Highcharts;
  chartOptions;

  //chart data variables
  @Input() public category: String[];
  @Input() public data: Number[];
  @Input() public xData: Number[];
  @Input() public xAxisLabel: String;
  @Input() public yAxisLabel: String;
  @Input() public reportName: String;
  @Input() public level: String;
  @Input() public type: String;
  @Input() height: any = window.innerHeight;

  constructor(public changeDetection: ChangeDetectorRef) {
  }

  onResize() {
    this.height = window.innerHeight;
    this.createBarChart();
  }


  ngOnInit() {
    this.changeDetection.detectChanges();
    this.onResize();
  }

  //generate bar chart:::::::::::
  createBarChart() {
    var xData = this.xData;
    var name = this.reportName;
    var level = this.level;
    var type = this.type;
    let scrollBarX
    if (this.data.length < 25) {
      scrollBarX = false
    } else {
      scrollBarX = true
    }
    if (this.reportName == 'averageTimeSpend') {
      this.chartOptions = {
        chart: {
          type: "bar",
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
          categories: this.category,
          title: {
            text: this.yAxisLabel,
            style: {
              color: 'black',
              fontSize: this.height > 1760 ? "32px" : this.height > 1160 && this.height < 1760 ? "22px" : this.height > 667 && this.height < 1160 ? "12px" : "10px",
              fontWeight: "bold"
            }
          },
          plotOptions: {

          },
          min: 0,
          max: 25,
          showEmpty: false,
          scrollbar: {
            minWidth: 6,
            enabled: scrollBarX,
          },
          tickLength: 0
        },
        yAxis: {
          labels: {
            style: {
              color: 'black',
              fontSize: this.height > 1760 ? "26px" : this.height > 1160 && this.height < 1760 ? "16px" : this.height > 667 && this.height < 1160 ? "12px" : "10px"
            },
            formatter: function () {
              return this.value.toString().replace(/(\d)(?=(\d\d)+\d$)/g, "$1,");
            }
          },
          min: 0,
          showEmpty: false,
          opposite: true,
          max: Math.max.apply(Math, this.data),
          gridLineColor: 'transparent',
          title: {
            text: this.xAxisLabel,
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
            pointPadding: 0.1,
            groupPadding: 0,
          }
        },
        legend: {
          enabled: false,
        },
        credits: {
          enabled: false
        },
        series: [
          {
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

            name: this.xAxisLabel,
            data: this.data
          }
        ],
        tooltip: {
          style: {
            fontSize: this.height > 1760 ? "32px" : this.height > 1160 && this.height < 1760 ? "22px" : this.height > 667 && this.height < 1160 ? "12px" : "10px",
            opacity: 1,
            backgroundColor: "white"
          },
          formatter: function () {
            return '<b>' + getPointCategoryName(this.point, name, xData, level, type) + '</b>';
          }
        }
      }
    } else {
      this.chartOptions = {
        chart: {
          type: "bar",
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
          categories: this.category,
          title: {
            text: this.yAxisLabel,
            style: {
              color: 'black',
              fontSize: this.height > 1760 ? "32px" : this.height > 1160 && this.height < 1760 ? "22px" : this.height > 667 && this.height < 1160 ? "12px" : "10px",
              fontWeight: "bold"
            }
          },
          min: 0,
          max: 25,
          scrollbar: {
            minWidth: 6,
            enabled: scrollBarX,
          },
          tickLength: 0
        },
        yAxis: {
          labels: {
            style: {
              color: 'black',
              fontSize: this.height > 1760 ? "26px" : this.height > 1160 && this.height < 1760 ? "16px" : this.height > 667 && this.height < 1160 ? "12px" : "10px"
            },
            formatter: function () {
              return this.value.toString().replace(/(\d)(?=(\d\d)+\d$)/g, "$1,");
            }
          },
          min: 0,
          opposite: true,
          max: Math.max.apply(Math, this.data),
          gridLineColor: 'transparent',
          title: {
            text: this.xAxisLabel,
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
        series: [
          {
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

            name: this.xAxisLabel,
            data: this.data
          }
        ],
        tooltip: {
          style: {
            fontSize: this.height > 1760 ? "32px" : this.height > 1160 && this.height < 1760 ? "22px" : this.height > 667 && this.height < 1160 ? "12px" : "10px",
            opacity: 1,
            backgroundColor: "white"
          },
          formatter: function () {
            return '<b>' + getPointCategoryName(this.point, name, xData, level, type) + '</b>';
          }
        }
      }
    }

    this.Highcharts.chart("container", this.chartOptions);

    //Bar tooltips::::::::::::::::::::::
    function getPointCategoryName(point, reportName, xData, level, type) {
      var obj = '';
      if (reportName == "course") {
        let percentage = ((point.y / point.series.yData.reduce((a, b) => a + b, 0)) * 100).toFixed(2);
        obj = `<b>District Name:</b> ${point.category}
        <br> ${point.y !== null ? `<b>Total Content Plays:</b> ${point.y.toString().replace(/(\d)(?=(\d\d)+\d$)/g, "$1,")}` : ''}
        <br> ${point.y !== null ? `<b>Percentage:</b> ${percentage} %` : ''}`
        return obj;
      }
      if (reportName == "textbook") {
        let percentage = ((point.y / point.series.yData.reduce((a, b) => a + b, 0)) * 100).toFixed(2);
        obj = `<b>District Name:</b> ${point.category}
        <br> ${point.y !== null ? `<b>Total Content Plays:</b> ${point.y.toString().replace(/(\d)(?=(\d\d)+\d$)/g, "$1,")}` : ''}
        <br> ${point.y !== null ? `<b>Percentage: ${percentage} %` : ''}</b>`
        return obj;
      }
      if (reportName == "completion") {
        obj = `<b>${level.charAt(0).toUpperCase() + level.substr(1).toLowerCase()} Name:</b> ${point.category}
        <br> ${point.y !== null ? `<b>Completion Percentage: </b>${point.y} %` : ''}`
        return obj;
      }
      if (reportName == "enroll/comp") {

        obj = `<b>${level.charAt(0).toUpperCase() + level.substr(1).toLowerCase()} Name:</b> ${point.category}
        <br> ${point.y !== null ? `<b style= 'color: blue'>${type.split('_').length > 1 ?
            type.split('_')[0].charAt(0).toUpperCase() + type.split('_')[0].substr(1).toLowerCase() + " " + type.split('_')[1].charAt(0).toUpperCase() + type.split('_')[1].substr(1).toLowerCase() :
            type.charAt(0).toUpperCase() + type.substr(1).toLowerCase()}:</b> <span style ="color:blue">${point.y.toString().replace(/(\d)(?=(\d\d)+\d$)/g, "$1,")}</span>` : ''}
       ${type == `completion` && xData[point.index] ? `<br><b>Enrollment: </b>${xData[point.index][1][point.index]}<br>
       <b>Percet Completion: </b>${xData[point.index][0][point.index]}%
       ` : ''}
       ${type == `enrollment` && xData[point.index] ? `<br><b>Completion: </b>${xData[point.index][1][point.index]}<br>
       <b>Percet Completion: </b>${xData[point.index][0][point.index]}%
       ` : ''}

       ${type == `percent_completion` && xData[point.index] ? `<br><b>Enrollment: </b>${xData[point.index][1][point.index]}<br>
       <b>Completion: </b>${xData[point.index][0][point.index]}
       ` : ''}
       `
        return obj;

      }
      if (reportName = 'averageTimeSpend') {

        obj = `<b style="padding-left: '10px'">Name:</b> ${point.category}
          <br> ${point.y !== null ? `<b>Average Time Spent: </b>${point.y} Hours` : ''}<br>
           <b> Enrolled Users : ${xData[point.index].total_enrolled}</b> 
          
           `
      }


      return obj
    }
  }
}
