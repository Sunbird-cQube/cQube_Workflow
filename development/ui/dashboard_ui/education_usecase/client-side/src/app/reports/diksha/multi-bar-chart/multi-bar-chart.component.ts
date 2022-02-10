import { ChangeDetectorRef, Component, Input, OnInit } from "@angular/core";
import * as Highcharts from 'highcharts/highstock';

declare var $

@Component({
  selector: 'app-multi-bar-chart',
  templateUrl: './multi-bar-chart.component.html',
  styleUrls: ['./multi-bar-chart.component.css']
})
export class MultiBarChartComponent implements OnInit {

  Highcharts: typeof Highcharts = Highcharts;
  chartOptions;

  //chart data variables
  @Input() public category: String[];
  @Input() public data: Number[];
  @Input() public enrolData: Number[];
  @Input() public compData: Number[];
  @Input() public perData: Number[];
  @Input() public xData: Number[];
  @Input() public xAxisLabel: String;
  @Input() public yAxisLabel: String;
  @Input() public reportName: String;
  @Input() public level: String;
  @Input() public type: String;
  @Input() height: any = window.innerHeight;
  @Input() public courseSelected: boolean;
  @Input() public programSelected: boolean;


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
    var course = this.courseSelected;
    var expectedData = this.data
    var programStatus = this.programSelected

    if ((level === 'program') && this.courseSelected === false) {
      this.chartOptions = {
        chart: {
          type: "bar",
          backgroundColor: 'transparent',
          inverted: true,

        },

        title: {
          text: null
        },
        xAxis: {
          min: 0,
          max: 4.5,
          labels: {
            x: -7,
            useHTML: true,
            style: {
              width: this.height > 1760 ? "190px" : this.height > 1160 && this.height < 1760 ? "140px" : this.height > 667 && this.height < 1160 ? "80px" : '80px',
              color: 'black',
              fontSize: this.height > 1760 ? "32px" : this.height > 1160 && this.height < 1760 ? "22px" : this.height > 667 && this.height < 1160 ? "12px" : "12px",
              whiteSpace: 'normal'
            },
            step: 1,
            formatter: function () {

              let distWidth = window.innerHeight > 1760 ? '180px' : window.innerHeight > 1160 && window.innerHeight < 1760 ? '130px' : window.innerHeight > 667 && window.innerHeight < 1160 ? '80px' : '80px';
              return '<div style="word-wrap: break-word;word-break: break-all;width:' + distWidth + '">' + this.value + '</div>';
            }
          },
          type: "category",
          gridLineColor: 'transparent',

          categories: this.category,

          title: {
            text: this.yAxisLabel,
            style: {
              color: 'black',
              fontSize: this.height > 1760 ? "32px" : this.height > 1160 && this.height < 1760 ? "22px" : this.height > 667 && this.height < 1160 ? "12px" : "12px",
              fontWeight: "bold"
            }
          },

          scrollbar: {
            minWidth: 5,
            size: this.height > 1760 ? 30 : this.height > 1160 && this.height < 1760 ? 20 : this.height > 667 && this.height < 1160 ? 14 : 14,
            enabled: true,
            opposite: true,
            margin: this.height > 1760 ? 300 : this.height > 1160 && this.height < 1760 ? 220 : this.height > 667 && this.height < 1160 ? 120 : 120,
          },
          tickLength: 0,
        },

        yAxis: {
          labels: {
            style: {
              color: 'black',
              fontSize: this.height > 1760 ? "26px" : this.height > 1160 && this.height < 1760 ? "16px" : this.height > 667 && this.height < 1160 ? "12px" : "12px"
            },
            formatter: function () {
              return this.value.toString().replace(/(\d)(?=(\d\d)+\d$)/g, "$1,");
            },
          },

          min: 0,
          opposite: true,
          max: 100,
          gridLineColor: 'transparent',
          plotLines: [{
            color: '#000',
            dashStyle: 'shortdash',
            width: 1.5,
            value: 33,
            zIndex: 5
          }, {
            color: '#000',
            dashStyle: 'shortdash',
            width: 1.5,
            value: 66,
            zIndex: 5
          }],
          title: {
            text: expectedData.length > 0 ? this.xAxisLabel : 'Total numbers',
            style: {
              color: 'black',
              fontSize: this.height > 1760 ? "32px" : this.height > 1160 && this.height < 1760 ? "22px" : this.height > 667 && this.height < 1160 ? "12px" : "10px",
              fontWeight: "bold"
            }
          }
        },
        plotOptions: {
          series: {
            events: {
              legendItemClick: function (e) {
                e.preventDefault();
              },

            }
          },

          bar: {

            dataLabels: {
              enabled: true,
              align: 'right',
              allowOverlap: true,
              crop: false,
              overflow: 'allow',
              inside: true,
              x: this.height > 1760 ? 200 : this.height > 1160 && this.height < 1760 ? 100 : this.height > 667 && this.height < 1160 ? 60 : 60,
              verticalAlign: 'middle',
              style: {
                color: "#000"
              },
            },

          },

        },
        legend: {
          enabled: true,
          align: 'right',
          verticalAlign: 'top',
          itemStyle: {
            fontSize: this.height > 1760 ? "32px" : this.height > 1160 && this.height < 1760 ? "22px" : this.height > 667 && this.height < 1160 ? "12px" : "12px",
            width: '500px',

          },

          useHTML: true,
          labelFormatter: function () {
            if (this.name === 'Expected Enrollment') {
              let iconSize = window.innerHeight > 1760 ? '36px' : window.innerHeight > 1160 && window.innerHeight < 1760 ? '26px' : window.innerHeight > 667 && window.innerHeight < 1160 ? '14px' : '14px';
              let str = '<span style="display: flex; align-item: start"><span class="legandTooltip" style="margin-right: 2px" data-index=""' + this.index + '">' + this.name + '</span><span style="font-size:' + iconSize + '; margin-top: -1px; margin-left: 2px " class="infoIcon" tabindex="0" data-toggle="tooltip" title="The program expected enrollments are equal to the total of courses expected enrollments which are in the selected program."><i class="fa fa-info-circle"></i></span></span>';
              $(function () {
                $('.infoIcon[title]').tooltip();
              });
              return str
            } else {
              return '<span>' + this.name + '</span>';
            }

          }

        },
        credits: {
          enabled: false
        },
        series: [
          {
            dataLabels: {
              enableMouseTracking: false,
              enabled: true,
              style: {
                marginLeft: '30px',
                fontWeight: 800,
                fontSize: this.height > 1760 ? "32px" : this.height > 1160 && this.height < 1760 ? "22px" : this.height > 667 && this.height < 1160 ? "12px" : "12px",
              },
              formatter: function () {
                return this.y + " (100 %)"
              }
            },
            color: '#396EB0',
            name: 'Expected Enrollment',
            data: this.data,
          },
          {
            dataLabels: {
              enabled: true,
              style: {
                fontWeight: 800,
                fontSize: this.height > 1760 ? "32px" : this.height > 1160 && this.height < 1760 ? "22px" : this.height > 667 && this.height < 1160 ? "12px" : "12px",
              },
              formatter: function () {

                if (level == 'district' || level == 'program') {
                  if (expectedData.length > 0) {
                    return this.y + '%';
                  } else {
                    return this.y;
                  }

                } else if (level == "block" || level == "cluster" || level == "school") {
                  return this.y;
                }

              }
            },
            color: '#bc5090',
            name: expectedData.length > 0 ? "% Enrolled" : 'Enrolled',
            data: this.enrolData
          },
          {
            dataLabels: {
              enabled: true,
              style: {
                fontWeight: 800,
                fontSize: this.height > 1760 ? "32px" : this.height > 1160 && this.height < 1760 ? "22px" : this.height > 667 && this.height < 1160 ? "12px" : "12px",
              },
              formatter: function () {
                if (level == 'district' || level == 'program') {
                  if (expectedData.length > 0) {
                    return this.y + '%';
                  } else {
                    return this.y;
                  }

                } else if (level == "block" || level == "cluster" || level == "school") {
                  return this.y;
                }
              }
            },
            color: '#9C19E0',

            name: expectedData.length > 0 ? '% Completed' : 'Completed',
            data: this.compData
          },
          {
            dataLabels: {
              enabled: true,
              style: {
                fontWeight: 800,
                fontSize: this.height > 1760 ? "32px" : this.height > 1160 && this.height < 1760 ? "22px" : this.height > 667 && this.height < 1160 ? "12px" : "12px",
              },
              formatter: function () {
                if (level == 'district' || level == 'program') {
                  if (expectedData.length > 0) {
                    return this.y + '%';
                  } else {
                    return this.y;
                  }
                } else if (level == "block" || level == "cluster" || level == "school") {
                  return this.y;
                }
              }
            },
            color: this.perData.length > 0 ? '#D4AC2B' : 'transparent',
            name: this.perData.length > 0 ? expectedData.length > 0 ? '% Certificates' : 'Certificates' : '',
            data: this.perData.length > 0 ? this.perData : null
          },

        ],
        tooltip: {
          style: {
            fontSize: this.height > 1760 ? "32px" : this.height > 1160 && this.height < 1760 ? "22px" : this.height > 667 && this.height < 1160 ? "12px" : "10px",
            opacity: 1,
            backgroundColor: "white"
          },
          formatter: function () {
            return '<b>' + getPointCategoryName(this.points, name, xData, level, type, this.series, course, programStatus) + '</b>';
          },
          shared: true

        }
      }

    } else if ((level === 'district') && this.courseSelected === false) {
      this.chartOptions = {
        chart: {
          type: "bar",
          backgroundColor: 'transparent',
          inverted: true,
        },

        title: {
          text: null
        },
        xAxis: {
          min: 0,
          max: 4.5,
          labels: {
            x: -7,

            useHTML: true,
            style: {
              width: this.height > 1760 ? "190px" : this.height > 1160 && this.height < 1760 ? "140px" : this.height > 667 && this.height < 1160 ? "80px" : '80px',
              color: 'black',
              fontSize: this.height > 1760 ? "32px" : this.height > 1160 && this.height < 1760 ? "22px" : this.height > 667 && this.height < 1160 ? "12px" : "12px",
              whiteSpace: 'normal'
            },
            step: 1,
            formatter: function () {

              let distWidth = window.innerHeight > 1760 ? '180px' : window.innerHeight > 1160 && window.innerHeight < 1760 ? '130px' : window.innerHeight > 667 && window.innerHeight < 1160 ? '80px' : '80px';
              return '<div style="word-wrap: break-word;word-break: break-all;width:' + distWidth + '">' + this.value + '</div>';
            }
          },
          type: "category",
          gridLineColor: 'transparent',
          categories: this.category,

          title: {
            text: this.yAxisLabel,
            margin: 50,
            style: {
              color: 'black',
              fontSize: this.height > 1760 ? "32px" : this.height > 1160 && this.height < 1760 ? "22px" : this.height > 667 && this.height < 1160 ? "12px" : "12px",
              fontWeight: "bold"
            }
          },

          scrollbar: {
            minWidth: 5,
            size: this.height > 1760 ? 30 : this.height > 1160 && this.height < 1760 ? 20 : this.height > 667 && this.height < 1160 ? 14 : 14,
            enabled: true,
            opposite: true,
            margin: this.height > 1760 ? 300 : this.height > 1160 && this.height < 1760 ? 220 : this.height > 667 && this.height < 1160 ? 120 : 120,
          },
          tickLength: 0,
        },

        yAxis: {
          labels: {
            style: {
              color: 'black',
              fontWeight: "bold",
              fontSize: this.height > 1760 ? "32px" : this.height > 1160 && this.height < 1760 ? "22px" : this.height > 667 && this.height < 1160 ? "12px" : "12px"
            },
            formatter: function () {
              return this.value.toString().replace(/(\d)(?=(\d\d)+\d$)/g, "$1,");
            },
          },

          min: 0,
          max: Math.max.apply(Math, this.enrolData),
          opposite: true,

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
          series: {
            events: {
              legendItemClick: function (e) {
                e.preventDefault();
              }
            }
          },
          bar: {

            dataLabels: {
              enabled: true,
              align: 'right',
              allowOverlap: true,
              crop: false,
              overflow: 'allow',
              inside: true,
              x: this.height > 1760 ? 200 : this.height > 1160 && this.height < 1760 ? 100 : this.height > 667 && this.height < 1160 ? 60 : 60,
              verticalAlign: 'middle',
              style: {
                color: "#000"
              },
            },

          },

        },
        legend: {
          enabled: true,
          align: 'right',
          verticalAlign: 'top',
          itemStyle: {
            fontSize: this.height > 1760 ? "32px" : this.height > 1160 && this.height < 1760 ? "22px" : this.height > 667 && this.height < 1160 ? "12px" : "10px",
          }
        },
        credits: {
          enabled: false
        },
        series: [

          {
            dataLabels: {
              enabled: true,
              style: {
                fontWeight: 800,
                fontSize: this.height > 1760 ? "32px" : this.height > 1160 && this.height < 1760 ? "22px" : this.height > 667 && this.height < 1160 ? "12px" : "12px",
              },
              formatter: function () {

                if (level == 'district' || level == 'program') {
                  return this.y;
                } else if (level == "block" || level == "cluster" || level == "school") {
                  return this.y;
                }

              }
            },
            color: '#bc5090',
            name: "Enrolled",
            data: this.enrolData
          },
          {
            dataLabels: {
              enabled: true,
              style: {
                fontWeight: 800,
                fontSize: this.height > 1760 ? "32px" : this.height > 1160 && this.height < 1760 ? "22px" : this.height > 667 && this.height < 1160 ? "12px" : "12px",
              },
              formatter: function () {
                if (level == 'district' || level == 'program') {
                  return this.y;
                } else if (level == "block" || level == "cluster" || level == "school") {
                  return this.y;
                }
              }
            },
            color: '#9C19E0',

            name: 'Completed',
            data: this.compData
          }
        ],
        tooltip: {
          style: {
            fontSize: this.height > 1760 ? "32px" : this.height > 1160 && this.height < 1760 ? "22px" : this.height > 667 && this.height < 1160 ? "12px" : "10px",
            opacity: 1,
            backgroundColor: "white"
          },
          formatter: function () {
            return '<b>' + getPointCategoryName(this.points, name, xData, level, type, this.series, course, programStatus) + '</b>';

          },
          shared: true

        }
      }
    } else
      if ((level === 'district' || level === 'program') && this.courseSelected === true) {

        this.chartOptions = {
          chart: {
            type: "bar",
            backgroundColor: 'transparent',
            inverted: true,
          },

          title: {
            text: null
          },
          xAxis: {
            min: 0,
            max: 4.5,
            labels: {
              x: -7,
              useHTML: true,
              style: {
                width: this.height > 1760 ? "190px" : this.height > 1160 && this.height < 1760 ? "140px" : this.height > 667 && this.height < 1160 ? "80px" : '80px',
                color: 'black',
                fontSize: this.height > 1760 ? "32px" : this.height > 1160 && this.height < 1760 ? "22px" : this.height > 667 && this.height < 1160 ? "12px" : "12px",
                whiteSpace: 'normal'
              },
              step: 1,
              formatter: function () {

                let distWidth = window.innerHeight > 1760 ? '180px' : window.innerHeight > 1160 && window.innerHeight < 1760 ? '130px' : window.innerHeight > 667 && window.innerHeight < 1160 ? '80px' : '80px';
                return '<div style="word-wrap: break-word;word-break: break-all;width:' + distWidth + '">' + this.value + '</div>';
              }
            },
            type: "category",
            gridLineColor: 'transparent',

            categories: this.category,

            title: {
              text: this.yAxisLabel,
              style: {
                color: 'black',
                fontSize: this.height > 1760 ? "32px" : this.height > 1160 && this.height < 1760 ? "22px" : this.height > 667 && this.height < 1160 ? "12px" : "12px",
                fontWeight: "bold"
              }
            },

            scrollbar: {
              minWidth: 5,
              size: this.height > 1760 ? 30 : this.height > 1160 && this.height < 1760 ? 20 : this.height > 667 && this.height < 1160 ? 14 : 14,
              enabled: true,
              opposite: true,
              margin: this.height > 1760 ? 300 : this.height > 1160 && this.height < 1760 ? 220 : this.height > 667 && this.height < 1160 ? 120 : 120,
            },
            tickLength: 0,
          },

          yAxis: {
            labels: {
              style: {
                color: 'black',
                fontWeight: 'bold',
                fontSize: this.height > 1760 ? "32px" : this.height > 1160 && this.height < 1760 ? "22px" : this.height > 667 && this.height < 1160 ? "12px" : "12px"
              },
              formatter: function () {
                return this.value.toString().replace(/(\d)(?=(\d\d)+\d$)/g, "$1,");
              },
            },

            min: 0,
            opposite: true,

            max: expectedData.length > 0 ? 100 : Math.max.apply(Math, this.enrolData),
            gridLineColor: 'transparent',
            plotLines: [{
              color: expectedData.length > 0 ? '#000' : 'transparent',
              dashStyle: 'shortdash',
              width: 1.5,
              value: 33,
              zIndex: 5
            }, {
              color: expectedData.length > 0 ? '#000' : 'transparent',
              dashStyle: 'shortdash',
              width: 1.5,
              value: 66,
              zIndex: 5
            }],
            title: {
              text: expectedData.length > 0 ? this.xAxisLabel : 'Total Numbers',
              style: {
                color: 'black',
                fontSize: this.height > 1760 ? "32px" : this.height > 1160 && this.height < 1760 ? "22px" : this.height > 667 && this.height < 1160 ? "12px" : "10px",
                fontWeight: "bold"
              }
            }
          },

          plotOptions: {
            series: {
              events: {
                legendItemClick: function (e) {
                  e.preventDefault();
                }
              }
            },
            bar: {
              dataLabels: {
                enabled: true,
                align: 'right',
                allowOverlap: true,
                crop: false,
                overflow: 'allow',
                inside: true,
                x: this.height > 1760 ? 200 : this.height > 1160 && this.height < 1760 ? 100 : this.height > 667 && this.height < 1160 ? 60 : 60,
                verticalAlign: 'middle',
                style: {
                  color: "#000"
                },

              },

            },

          },
          legend: {
            enabled: true,
            align: 'right',
            verticalAlign: 'top',
            itemStyle: {
              fontSize: this.height > 1760 ? "32px" : this.height > 1160 && this.height < 1760 ? "22px" : this.height > 667 && this.height < 1160 ? "12px" : "10px",
            }
          },
          credits: {
            enabled: false
          },
          series: [
            {
              dataLabels: {
                enabled: true,
                style: {
                  fontWeight: 800,

                  fontSize: this.height > 1760 ? "32px" : this.height > 1160 && this.height < 1760 ? "22px" : this.height > 667 && this.height < 1160 ? "12px" : "12px",
                },
                formatter: function () {

                  if (level == 'district' || level == 'program') {
                    return this.y + "( 100% )";
                  } else if (level == "block" || level == "cluster" || level == "school") {
                    return this.y;
                  }

                }
              },
              color: this.data.length > 0 ? '#396EB0' : 'transparent',
              name: this.data.length > 0 ? " Expected Enrolled" : '',
              data: this.data.length > 0 ? this.data : null
            },
            {
              dataLabels: {
                enabled: true,
                style: {
                  fontWeight: 800,

                  fontSize: this.height > 1760 ? "32px" : this.height > 1160 && this.height < 1760 ? "22px" : this.height > 667 && this.height < 1160 ? "12px" : "12px",
                },
                formatter: function () {

                  if (level == 'district' || level == 'program') {
                    if (expectedData.length > 0) {
                      return this.y + "%";
                    } else {
                      return this.y
                    }
                  } else if (level == "block" || level == "cluster" || level == "school") {
                    return this.y;
                  }

                }
              },
              color: '#bc5090',
              name: expectedData.length ? '% Enrolled' : 'Enrolled',
              data: this.enrolData
            },
            {
              dataLabels: {
                enabled: true,
                style: {
                  fontWeight: 800,
                  fontSize: this.height > 1760 ? "32px" : this.height > 1160 && this.height < 1760 ? "22px" : this.height > 667 && this.height < 1160 ? "12px" : "12px",
                },
                formatter: function () {
                  if (level == 'district' || level == 'program') {
                    if (expectedData.length > 0) {
                      return this.y + "%";
                    } else {
                      return this.y
                    }

                  } else if (level == "block" || level == "cluster" || level == "school") {
                    return this.y;
                  }
                }
              },
              color: '#9C19E0',

              name: expectedData.length > 0 ? '% Completed' : 'Completed',
              data: this.compData
            },
            {
              dataLabels: {
                enabled: true,
                style: {
                  fontWeight: 800,
                  fontSize: this.height > 1760 ? "32px" : this.height > 1160 && this.height < 1760 ? "22px" : this.height > 667 && this.height < 1160 ? "12px" : "12px",
                },
                formatter: function () {
                  if (level == 'district' || level === "program") {
                    if (expectedData.length > 0) {
                      return this.y + "%";
                    } else {
                      return this.y
                    }

                  } else if (level == "block" || level == "cluster" || level == "school") {
                    return this.y;
                  }
                }
              },
              color: this.perData.length > 0 ? '#D4AC2B' : 'transparent',
              name: this.perData.length > 0 ? expectedData.length > 0 ? '% Certificates' : 'Certificates' : '',
              data: this.perData.length > 0 ? this.perData : null
            }
          ],
          tooltip: {
            style: {
              fontSize: this.height > 1760 ? "32px" : this.height > 1160 && this.height < 1760 ? "22px" : this.height > 667 && this.height < 1160 ? "12px" : "10px",
              opacity: 1,
              backgroundColor: "white"
            },
            formatter: function () {
              return '<b>' + getPointCategoryName(this.points, name, xData, level, type, this.series, course, programStatus) + '</b>';
            },
            shared: true

          }
        }

      } else {

        this.chartOptions = {
          chart: {
            type: "bar",
            backgroundColor: 'transparent',
            inverted: true,

          },

          title: {
            text: null
          },
          xAxis: {
            min: 0,
            max: 4.5,
            labels: {
              x: -7,
              useHTML: true,
              style: {
                width: this.height > 1760 ? "190px" : this.height > 1160 && this.height < 1760 ? "140px" : this.height > 667 && this.height < 1160 ? "80px" : '80px',
                color: 'black',
                fontSize: this.height > 1760 ? "32px" : this.height > 1160 && this.height < 1760 ? "22px" : this.height > 667 && this.height < 1160 ? "12px" : "12px",
                whiteSpace: 'normal'
              },
              step: 1,
              formatter: function () {

                let distWidth = window.innerHeight > 1760 ? '180px' : window.innerHeight > 1160 && window.innerHeight < 1760 ? '130px' : window.innerHeight > 667 && window.innerHeight < 1160 ? '80px' : '80px';
                return '<div style="word-wrap: break-word;word-break: break-all;width:' + distWidth + '">' + this.value + '</div>';
              }
            },
            type: "category",
            gridLineColor: 'transparent',
            categories: this.category,

            title: {
              text: this.yAxisLabel,
              style: {
                color: 'black',
                fontSize: this.height > 1760 ? "32px" : this.height > 1160 && this.height < 1760 ? "22px" : this.height > 667 && this.height < 1160 ? "12px" : "12px",
                fontWeight: "bold"
              }
            },

            scrollbar: {
              minWidth: 5,
              size: this.height > 1760 ? 30 : this.height > 1160 && this.height < 1760 ? 20 : this.height > 667 && this.height < 1160 ? 14 : 14,
              enabled: true,
              opposite: true,
              margin: this.height > 1760 ? 300 : this.height > 1160 && this.height < 1760 ? 220 : this.height > 667 && this.height < 1160 ? 120 : 120,
            },
            tickLength: 0,
          },

          yAxis: {
            labels: {
              style: {
                color: 'black',
                fontWeight: 'bold',
                fontSize: this.height > 1760 ? "32px" : this.height > 1160 && this.height < 1760 ? "22px" : this.height > 667 && this.height < 1160 ? "12px" : "12px"
              },
              formatter: function () {
                return this.value.toString().replace(/(\d)(?=(\d\d)+\d$)/g, "$1,");
              },
            },
            tickAmount: 6,
            min: 0,
            max: Math.max.apply(Math, this.enrolData),
            opposite: true,

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
            series: {
              events: {
                legendItemClick: function (e) {
                  e.preventDefault();
                }
              }
            },
            bar: {
              dataLabels: {
                enabled: true,
                align: 'right',
                allowOverlap: true,
                crop: false,
                overflow: 'allow',
                inside: true,
                x: this.height > 1760 ? 200 : this.height > 1160 && this.height < 1760 ? 100 : this.height > 667 && this.height < 1160 ? 60 : 60,
                verticalAlign: 'middle',
                style: {
                  color: "#000"
                },

              },

            },

          },
          legend: {
            enabled: true,
            align: 'right',
            verticalAlign: 'top',
            itemStyle: {
              fontSize: this.height > 1760 ? "32px" : this.height > 1160 && this.height < 1760 ? "22px" : this.height > 667 && this.height < 1160 ? "12px" : "10px",
            }
          },
          credits: {
            enabled: false
          },
          series: [
            {
              dataLabels: {
                enabled: true,
                style: {
                  fontWeight: 800,
                  fontSize: this.height > 1760 ? "32px" : this.height > 1160 && this.height < 1760 ? "22px" : this.height > 667 && this.height < 1160 ? "12px" : "12px",
                },
                formatter: function () {

                  if (level == 'district') {
                    return this.y + '%';
                  } else if (level == "block" || level == "cluster" || level == "school") {
                    return this.y;
                  }

                }
              },
              color: '#bc5090',
              name: "Enrolled",
              data: this.enrolData
            },
            {
              dataLabels: {
                enabled: true,
                style: {
                  fontWeight: 800,
                  fontSize: this.height > 1760 ? "32px" : this.height > 1160 && this.height < 1760 ? "22px" : this.height > 667 && this.height < 1160 ? "12px" : "12px",
                },
                formatter: function () {
                  if (level == 'district') {
                    return this.y + '%';
                  } else if (level == "block" || level == "cluster" || level == "school") {
                    return this.y;
                  }
                }
              },
              color: '#9C19E0',

              name: 'Completed',
              data: this.compData
            },
            {
              dataLabels: {
                enabled: true,
                style: {
                  fontWeight: 800,
                  fontSize: this.height > 1760 ? "32px" : this.height > 1160 && this.height < 1760 ? "22px" : this.height > 667 && this.height < 1160 ? "12px" : "12px",
                },
                formatter: function () {
                  if (level == 'district') {
                    return this.y + '%';
                  } else if (level == "block" || level == "cluster" || level == "school") {
                    return this.y;
                  }
                }
              },
              color: this.perData.length > 0 ? '#9C19E0' : 'transparent',

              name: this.perData.length > 0 ? 'Certificate' : '',
              data: this.perData.length > 0 ? this.perData : null
            }
          ],
          tooltip: {
            style: {
              fontSize: this.height > 1760 ? "32px" : this.height > 1160 && this.height < 1760 ? "22px" : this.height > 667 && this.height < 1160 ? "12px" : "10px",
              opacity: 1,
              backgroundColor: "white"
            },
            formatter: function () {
              return '<b>' + getPointCategoryName(this.points, name, xData, level, type, this.series, course, programStatus) + '</b>';
            },
            shared: true

          }
        }
      }


    this.Highcharts.chart("container", this.chartOptions,
      function (chart) {
        var group = chart.renderer.g('legend-tooltip')
          .attr({
            transform: 'translate(-9999, -9999)',
            zIndex: 99
          }).add(),
          text = chart.renderer.text()
            .attr({
              class: 'legend-tooltip-text',
              zIndex: 7
            }).add(group),
          box = text.getBBox();

        chart.renderer.rect().attr({
          'class': 'legend-tooltip',
          'stroke-width': 1,
          'stroke': 'grey',
          'fill': 'white',
          'zIndex': 6
        })
          .add(group)

      }
    );


    //Bar tooltips::::::::::::::::::::::
    function getPointCategoryName(points, reportName, xData, level, type, series, courseSelected, programStatus) {
      var obj = '';
      if (reportName == "enroll/comp") {
        if (((level === 'district' || level == "program") && courseSelected === true) || level === "program") {
          if (expectedData.length > 0) {
            obj = `&nbsp<b>District Name:</b> ${points[0].x}
        <br> ${xData[`${points[0].point.index}`]['expected_enrolled'] !== null ? `<b>Expected Enrolled:</b>  ${xData[`${points[0].point.index}`]['expected_enrolled'].toLocaleString('en-IN')}` : ''}
        <br> ${xData[`${points[0].point.index}`]['enrollment'] !== null ? `<b>Enrolled:</b>  ${xData[`${points[0].point.index}`]['enrollment'].toLocaleString('en-IN')}` : ''}
        <br> ${xData[`${points[0].point.index}`]['enrolled_percentage'] !== null ? `<b>% Enrolled:</b>  ${xData[`${points[0].point.index}`]['enrolled_percentage']} %` : ''}
        <br> ${xData[`${points[0].point.index}`]['completion'] !== null ? `<b>Completed:</b>  ${xData[`${points[0].point.index}`]['completion'].toLocaleString('en-IN')}` : ''}
        <br> ${xData[`${points[0].point.index}`]['percent_completion'] !== null ? `<b>% Completed:</b>  ${xData[`${points[0].point.index}`]['percent_completion']} %` : ''}
        <br> ${xData[`${points[0].point.index}`]['certificate_value'] !== null ? `<b>Certificate:</b>  ${xData[`${points[0].point.index}`]['certificate_value'].toLocaleString('en-IN')}` : ''}
        <br> ${xData[`${points[0].point.index}`]['certificate_per'] !== null ? `<b>% Certificate:</b>  ${xData[`${points[0].point.index}`]['certificate_per']} %` : ''}
        `
          } else {
            obj = `&nbsp<b>District Name:</b> ${points[0].x}
        <br> ${points.y !== null ? `<b>Enrolled:</b>  ${xData[`${points[0].point.index}`]['enrollment'].toLocaleString('en-IN')}` : ''}
        <br> ${points.y !== null ? `<b>Completed:</b>  ${xData[`${points[0].point.index}`]['completion'].toLocaleString('en-IN')}` : ''}
        <br> ${xData[`${points[0].point.index}`]['certificate_value'] !== null ? `<b>Certificate:</b>  ${xData[`${points[0].point.index}`]['certificate_value'].toLocaleString('en-IN')}` : ''}
        `
          }
        }
        else if (level === 'district') {
          obj = `&nbsp<b>District Name:</b> ${points[0].x}
      <br> ${points.y !== null ? `<b>Enrolled:</b>  ${xData[`${points[0].point.index}`]['enrollment'].toLocaleString('en-IN')}` : ''}
      <br> ${points.y !== null ? `<b>Completed:</b>  ${xData[`${points[0].point.index}`]['completion'].toLocaleString('en-IN')}` : ''}
     `
        } else {
          if (courseSelected === true || programStatus === true) {
            obj = `&nbsp<b>${level.charAt(0).toUpperCase() + level.slice(1)} Name:</b> ${points[0].x}
      <br> ${points.y !== null ? `<b>Enrolled:</b>  ${xData[`${points[0].point.index}`]['enrollment'].toLocaleString('en-IN')}` : ''}
      <br> ${points.y !== null ? `<b>Completed:</b>  ${xData[`${points[0].point.index}`]['completion'].toLocaleString('en-IN')}` : ''}
      <br> ${points.y !== null ? `<b>Certificate:</b>  ${xData[`${points[0].point.index}`]['certificate_value'].toLocaleString('en-IN')}` : ''}
     `
          } else {
            obj = `&nbsp<b>${level.charAt(0).toUpperCase() + level.slice(1)} Name:</b> ${points[0].x}
      <br> ${points.y !== null ? `<b>Enrolled:</b>  ${xData[`${points[0].point.index}`]['enrollment'].toLocaleString('en-IN')}` : ''}
      <br> ${points.y !== null ? `<b>Completed:</b>  ${xData[`${points[0].point.index}`]['completion'].toLocaleString('en-IN')}` : ''}
       
      
     `
          }

        }
        return obj;

      }
    }
  }

}
