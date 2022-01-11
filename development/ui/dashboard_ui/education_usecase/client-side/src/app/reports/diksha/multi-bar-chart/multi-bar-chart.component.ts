import { ChangeDetectorRef, Component, Input, OnInit } from "@angular/core";
import * as Highcharts from 'highcharts/highstock';

// import info from 'src/assets/images/'
// import * as GroupedCategories from 'highcharts-grouped-categories/grouped-categories';
// GroupedCategories(Highcharts);
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
  @Input() public courseSelected: boolean

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

    if ((level === 'program') && this.courseSelected === false) {
      this.chartOptions = {
        chart: {
          type: "bar",
          backgroundColor: 'transparent',
          inverted: true,
          
          // events: {
          //   load: function () {
          //     var chart = this,
          //       legend = chart.legend;

          //     for (var i = 0, len = legend.allItems.length; i < len; i++) {
          //       let expected: any = legend.allItems[i].name;

          //       // if (expected === "Expected Enrollment") {

          //       (function (i) {
                  

          //         var item = legend.allItems[0].legendItem.parentGroup,

          //           group = $('.highcharts-legend-tooltip'),
          //           rectElem = $('.legend-tooltip'),
          //           textElem = $('.legend-tooltip-text'),
          //           box;

          //         item.on('mouseover', function (e) {

          //           // Define legend-tooltip text
          //           // var str = chart.series[i].userOptions.fullName

          //           var str = 'Program expected: '

          //           textElem.text(str)

          //           // Adjust rect size to text
          //           box = textElem[0].getBBox()
          //           rectElem.attr({
          //             x: box.x - 8,
          //             y: box.y - 5,
          //             width: box.width + 15,
          //             height: box.height + 40
          //           })

          //           // Show tooltip
          //           group.attr({
          //             transform: `translate(${e.clientX - 80}, ${e.clientY - 120})`
          //           })

          //         }).on('mouseout', function (e) {

          //           // Hide tooltip
          //           group.attr({
          //             transform: 'translate(-9999,-9999)'
          //           })
          //         });


          //       })(i)
          //       // };
          //     }

          //   }
          // }

         

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
              width: '80px',
              color: 'black',
              fontSize: this.height > 1760 ? "32px" : this.height > 1160 && this.height < 1760 ? "22px" : this.height > 667 && this.height < 1160 ? "12px" : "12px",
              whiteSpace: 'normal'
            },
            step: 1,
            formatter: function () {
              return '<div style="word-wrap: break-word;word-break: break-all;width:80px">' + this.value + '</div>';
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
            enabled: true,
            opposite: true,
            margin: 120
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
              enabled: true,
              align: 'right',
              allowOverlap: true,
              crop: false,
              overflow: 'allow',
              inside: true,
              x: 100,
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

          },

          useHTML: true,
          labelFormatter: function () {
            if (this.name === 'Expected Enrollment') {
              return '<span class="legandTooltip"  data-index=""' + this.index + '">' + this.name + '</span>&nbsp;&nbsp;<span style="font-size: 10px; color: orange; " data-toggle="tooltip" data-placement="top" title="Tooltip on top" >&#9432;</span>';
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
            return '<b>' + getPointCategoryName(this.points, name, xData, level, type, this.series, course) + '</b>';
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
              width: '80px',
              color: 'black',
              fontSize: this.height > 1760 ? "32px" : this.height > 1160 && this.height < 1760 ? "22px" : this.height > 667 && this.height < 1160 ? "12px" : "12px",
              whiteSpace: 'normal'
            },
            step: 1,
            formatter: function () {
              return '<div style="word-wrap: break-word;word-break: break-all;width:80px">' + this.value + '</div>';
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
            enabled: true,
            opposite: true,
            margin: 120
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
          bar: {

            dataLabels: {
              enabled: true,
              align: 'right',
              allowOverlap: true,
              crop: false,
              overflow: 'allow',
              inside: true,
              x: 55,
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
            return '<b>' + getPointCategoryName(this.points, name, xData, level, type, this.series, course) + '</b>';

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
                width: '85px',
                color: 'black',
                fontSize: this.height > 1760 ? "32px" : this.height > 1160 && this.height < 1760 ? "22px" : this.height > 667 && this.height < 1160 ? "12px" : "12px",
                whiteSpace: 'normal'
              },
              step: 1,
              formatter: function () {
                return '<div  style="word-wrap: break-word;word-break: break-all;width:85px">' + this.value + '</div>';
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
              enabled: true,
              opposite: true,
              margin: 120
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
                enabled: true,
                align: 'right',
                allowOverlap: true,
                crop: false,
                overflow: 'allow',
                inside: true,
                x: 100,
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
              return '<b>' + getPointCategoryName(this.points, name, xData, level, type, this.series, course) + '</b>';
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
                width: '80px',
                color: 'black',
                fontSize: this.height > 1760 ? "32px" : this.height > 1160 && this.height < 1760 ? "22px" : this.height > 667 && this.height < 1160 ? "12px" : "12px",
                whiteSpace: 'normal'
              },
              step: 1,
              formatter: function () {
                return '<div  style="word-wrap: break-word;word-break: break-all;width:80px">' + this.value + '</div>';
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
              minWidth: 2,
              enabled: true,
              opposite: true,
              margin: 60
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
            bar: {
              dataLabels: {
                enabled: true,
                align: 'right',
                allowOverlap: true,
                crop: false,
                overflow: 'allow',
                inside: true,
                x: 55,
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
            }
          ],
          tooltip: {
            style: {
              fontSize: this.height > 1760 ? "32px" : this.height > 1160 && this.height < 1760 ? "22px" : this.height > 667 && this.height < 1160 ? "12px" : "10px",
              opacity: 1,
              backgroundColor: "white"
            },
            formatter: function () {
              return '<b>' + getPointCategoryName(this.points, name, xData, level, type, this.series, course) + '</b>';
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



    // $(".legandTooltip").hover(function () {
    //   $(this).css('cursor', 'pointer').attr('title', 'This is a hover text.');
    // }, function () {
    //   $(this).css('cursor', 'auto');
    // });



    //Bar tooltips::::::::::::::::::::::
    function getPointCategoryName(points, reportName, xData, level, type, series, courseSelected) {
      var obj = '';
      if (reportName == "enroll/comp") {
        if (((level === 'district' || level == "program") && courseSelected === true) || level === "program") {
          if (expectedData.length > 0) {
            obj = `&nbsp<b>District Name:</b> ${points[0].x}
        <br> ${xData[`${points[0].point.index}`]['expected_enrolled'] ? `<b>Expected Enrolled:</b> &nbsp ${xData[`${points[0].point.index}`]['expected_enrolled']}` : ''}
        <br> ${xData[`${points[0].point.index}`]['enrollment'] ? `<b>Enrolled:</b> &nbsp ${xData[`${points[0].point.index}`]['enrollment']}` : ''}
        <br> ${xData[`${points[0].point.index}`]['enrolled_percentage'] ? `<b>% Enrolled:</b> &nbsp ${xData[`${points[0].point.index}`]['enrolled_percentage']} %` : ''}
        <br> ${xData[`${points[0].point.index}`]['completion'] ? `<b>completed:</b> &nbsp ${xData[`${points[0].point.index}`]['completion']}` : ''}
        <br> ${xData[`${points[0].point.index}`]['percent_completion'] ? `<b>% completed:</b> &nbsp ${xData[`${points[0].point.index}`]['percent_completion']} %` : ''}
        <br> ${xData[`${points[0].point.index}`]['certificate_value'] ? `<b>certificate:</b> &nbsp ${xData[`${points[0].point.index}`]['certificate_value']}` : ''}
        <br> ${xData[`${points[0].point.index}`]['certificate_per'] ? `<b>% certificate:</b> &nbsp ${xData[`${points[0].point.index}`]['certificate_per']} %` : ''}
        `
          } else {
            obj = `&nbsp<b>District Name:</b> ${points[0].x}
        <br> ${points.y !== null ? `<b>Enrolled:</b> &nbsp ${xData[`${points[0].point.index}`]['enrollment']}` : ''}
        <br> ${points.y !== null ? `<b>completed:</b> &nbsp ${xData[`${points[0].point.index}`]['completion']}` : ''}
        <br> ${xData[`${points[0].point.index}`]['certificate_value'] ? `<b>certificate:</b> &nbsp ${xData[`${points[0].point.index}`]['certificate_value']}` : ''}
        `
          }

        }
       

        else if (level === 'district') {
          obj = `&nbsp<b>District Name:</b> ${points[0].x}
      <br> ${points.y !== null ? `<b>Enrolled:</b> &nbsp ${xData[`${points[0].point.index}`]['enrollment']}` : ''}
      <br> ${points.y !== null ? `<b>Completed:</b> &nbsp ${xData[`${points[0].point.index}`]['completion']}` : ''}
     `
        } else {
          obj = `&nbsp<b>District Name:</b> ${points[0].x}
      <br> ${points.y !== null ? `<b>Enrolled:</b> &nbsp ${xData[`${points[0].point.index}`]['enrollment']}` : ''}
      <br> ${points.y !== null ? `<b>Completed:</b> &nbsp ${xData[`${points[0].point.index}`]['completion']}` : ''}
      
     `
        }
        return obj;

      }
    }
  }

}
