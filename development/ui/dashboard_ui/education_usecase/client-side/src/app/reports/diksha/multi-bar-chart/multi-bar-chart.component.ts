import { ChangeDetectorRef, Component, Input, OnInit } from "@angular/core";
import * as Highcharts from 'highcharts/highstock';
// import * as GroupedCategories from 'highcharts-grouped-categories/grouped-categories';
// GroupedCategories(Highcharts);

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
  @Input() public courseSelected : boolean

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
    if ((level === 'program') && this.courseSelected === false){
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
              fontSize: this.height > 1760 ? "32px" : this.height > 1160 && this.height < 1760 ? "22px" : this.height > 667 && this.height < 1160 ? "12px" : "12px",
              fontWeight: "bold"
            }
          },
        
          scrollbar: {
            minWidth: 5,
            enabled: true,
            opposite: true,
            margin: 80
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
          // max: Math.max.apply(Math, this.data),
          max: 100,
          gridLineColor: 'transparent',
          title: {
            // text: this.xAxisLabel,
            text: "Percentage",
            style: {
              color: 'black',
              fontSize: this.height > 1760 ? "32px" : this.height > 1160 && this.height < 1760 ? "22px" : this.height > 667 && this.height < 1160 ? "12px" : "10px",
              fontWeight: "bold"
            }
          }
        },
        plotOptions: {
          bar: {
            // groupPadding: 0.15,
            // pointPadding: 0.7,
            // pointWidth: 6,
            dataLabels: {
              enabled: true,
              align: 'right',
              allowOverlap: true,
              crop: false,
              overflow: 'allow',
              inside: true,
              x: 55,
              verticalAlign: 'middle',
              style:{
                color: "#000"
              },
            },
            
          },
         
        },
        legend: {
          enabled: true,
          align: 'right',
          verticalAlign: 'top',
          itemStyle:{
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
                fontWeight:  800,
                // fontSize: '12px',
                fontSize: this.height > 1760 ? "32px" : this.height > 1160 && this.height < 1760 ? "22px" : this.height > 667 && this.height < 1160 ? "12px" : "12px",
              },
              formatter: function () {
                // return this.y.toString().replace(/(\d)(?=(\d\d)+\d$)/g, "$1,");
                return this.y + " (100 %)"
              }
            },
            color: '#396EB0',
            name: '% Expected Enrollment',
            data: this.data
          },
          {
            dataLabels: {
              enabled: true,
              style: {
                fontWeight:  800,
                // fontSize: '12px',
                fontSize: this.height > 1760 ? "32px" : this.height > 1160 && this.height < 1760 ? "22px" : this.height > 667 && this.height < 1160 ? "12px" : "12px",
              },
              formatter: function () {
                
                if(level == 'district' || level == 'program'){
                  return this.y + '%';
                } else if(level == "block" || level == "cluster" || level == "school"){
                   return this.y;
                }
                
              }
            },
            color: '#bc5090',
            name: "% Enrolled",
            data: this.enrolData
          },
          {
            dataLabels: {
              enabled: true,
              style: {
                fontWeight: 800,
                // fontSize: '12px',
                fontSize: this.height > 1760 ? "32px" : this.height > 1160 && this.height < 1760 ? "22px" : this.height > 667 && this.height < 1160 ? "12px" : "12px",
              },
              formatter: function () {
                if(level == 'district' || level == 'program'){
                  return this.y + '%';
                } else if(level == "block" || level == "cluster" || level == "school"){
                   return this.y;
                }
              }
            },
            color: '#9C19E0',
            
            name: '% Completed',
            data: this.compData
          },
          // {
          //   dataLabels: {
          //     enabled: true,
          //     style: {
          //       fontWeight:  800,
          //       fontSize: '12px',
          //       // fontSize: this.height > 1760 ? "32px" : this.height > 1160 && this.height < 1760 ? "22px" : this.height > 667 && this.height < 1160 ? "12px" : "10px",
          //     },
          //     formatter: function () {
          //       if(level == 'district'){
          //         return this.y + '%';
          //       } else if(level == "block" || level == "cluster" || level == "school"){
          //          return this.y;
          //       }
          //     }
          //   },
          //   color: '#ffa600',
          //   name: '% Certificates',
          //   data: this.perData
          // }        
        ],
        tooltip: {
          style: {
            fontSize: this.height > 1760 ? "32px" : this.height > 1160 && this.height < 1760 ? "22px" : this.height > 667 && this.height < 1160 ? "12px" : "10px",
            opacity: 1,
            backgroundColor: "white"
          },
          formatter: function () {
            // return '<b>' + getPointCategoryName(this.point, name, xData, level, type, this.series) + '</b>';
             return  this.points.reduce(function (s, point) {
              return   s+ '<br/>' +  point.series.name + ': ' +
                  point.y.toLocaleString('en-IN');
          },  '<u>'+'<b>' + this.x + '</b>'+ '</u>'+'</br>'); 
          },
          shared: true
          
        }
      }
    }else if ((level === 'district' || level === 'program') && this.courseSelected === false){
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
            style: {
              color: 'black',
              fontSize: this.height > 1760 ? "32px" : this.height > 1160 && this.height < 1760 ? "22px" : this.height > 667 && this.height < 1160 ? "12px" : "12px"
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
            margin: 80
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
          // max: Math.max.apply(Math, this.data),
          max: 100,
          gridLineColor: 'transparent',
          title: {
            // text: this.xAxisLabel,
            text: "Percentage",
            style: {
              color: 'black',
              fontSize: this.height > 1760 ? "32px" : this.height > 1160 && this.height < 1760 ? "22px" : this.height > 667 && this.height < 1160 ? "12px" : "10px",
              fontWeight: "bold"
            }
          }
        },
        plotOptions: {
          bar: {
            // groupPadding: 0.15,
            // pointPadding: 0.7,
            // pointWidth: 6,
            dataLabels: {
              enabled: true,
              align: 'right',
              allowOverlap: true,
              crop: false,
              overflow: 'allow',
              inside: true,
              x: 55,
              verticalAlign: 'middle',
              style:{
                color: "#000"
              },
              // formatter: function(){
              //   console.log('color', this)
              //   return this.colorIndex === 0 ? this.y : this.y + '%';
              //   // return '%'
              // }
            },
            
          },
         
        },
        legend: {
          enabled: true,
          align: 'right',
          verticalAlign: 'top',
          itemStyle:{
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
                fontWeight:  800,
                // fontSize: '12px',
                fontSize: this.height > 1760 ? "32px" : this.height > 1160 && this.height < 1760 ? "22px" : this.height > 667 && this.height < 1160 ? "12px" : "12px",
              },
              formatter: function () {
                // return this.y.toString().replace(/(\d)(?=(\d\d)+\d$)/g, "$1,");
                return this.y + " (100 %)"
              }
            },
            color: '#396EB0',
            name: '% Expected Enrollment',
            data: this.data
          },
          {
            dataLabels: {
              enabled: true,
              style: {
                fontWeight:  800,
                // fontSize: '12px',
                fontSize: this.height > 1760 ? "32px" : this.height > 1160 && this.height < 1760 ? "22px" : this.height > 667 && this.height < 1160 ? "12px" : "12px",
              },
              formatter: function () {
                
                if(level == 'district' || level == 'program'){
                  return this.y + '%';
                } else if(level == "block" || level == "cluster" || level == "school"){
                   return this.y;
                }
                
              }
            },
            color: '#bc5090',
            name: "% Enrolled",
            data: this.enrolData
          },
          {
            dataLabels: {
              enabled: true,
              style: {
                fontWeight: 800,
                // fontSize: '12px',
                fontSize: this.height > 1760 ? "32px" : this.height > 1160 && this.height < 1760 ? "22px" : this.height > 667 && this.height < 1160 ? "12px" : "12px",
              },
              formatter: function () {
                if(level == 'district' || level == 'program'){
                  return this.y + '%';
                } else if(level == "block" || level == "cluster" || level == "school"){
                   return this.y;
                }
              }
            },
            color: '#9C19E0',
            
            name: '% Completed',
            data: this.compData
          },
          // {
          //   dataLabels: {
          //     enabled: true,
          //     style: {
          //       fontWeight:  800,
          //       fontSize: '12px',
          //       // fontSize: this.height > 1760 ? "32px" : this.height > 1160 && this.height < 1760 ? "22px" : this.height > 667 && this.height < 1160 ? "12px" : "10px",
          //     },
          //     formatter: function () {
          //       if(level == 'district'){
          //         return this.y + '%';
          //       } else if(level == "block" || level == "cluster" || level == "school"){
          //          return this.y;
          //       }
          //     }
          //   },
          //   color: '#ffa600',
          //   name: '% Certificates',
          //   data: this.perData
          // }        
        ],
        tooltip: {
          style: {
            fontSize: this.height > 1760 ? "32px" : this.height > 1160 && this.height < 1760 ? "22px" : this.height > 667 && this.height < 1160 ? "12px" : "10px",
            opacity: 1,
            backgroundColor: "white"
          },
          formatter: function () {
            // return '<b>' + getPointCategoryName(this.point, name, xData, level, type, this.series) + '</b>';
             return  this.points.reduce(function (s, point) {
              return   s  + '<br/>' +  point.series.name + ': ' +
                  point.y.toLocaleString('en-IN');
          },  '<u>'+'<b>' + this.x + '</b>'+ '</u>'+'</br>'); 
          },
          shared: true
          
        }
      }
    } else
      if ((level === 'district') && this.courseSelected === true){
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
                fontSize: this.height > 1760 ? "32px" : this.height > 1160 && this.height < 1760 ? "22px" : this.height > 667 && this.height < 1160 ? "12px" : "12px",
                fontWeight: "bold"
              }
            },
          
            scrollbar: {
              minWidth: 5,
              enabled: true,
              opposite: true,
              margin: 80
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
            // max: Math.max.apply(Math, this.data),
            max: 100,
            gridLineColor: 'transparent',
            title: {
              // text: this.xAxisLabel,
              text: "Percentage",
              style: {
                color: 'black',
                fontSize: this.height > 1760 ? "32px" : this.height > 1160 && this.height < 1760 ? "22px" : this.height > 667 && this.height < 1160 ? "12px" : "10px",
                fontWeight: "bold"
              }
            }
          },
          plotOptions: {
            bar: {
              // groupPadding: 0.15,
              // pointPadding: 0.7,
              // pointWidth: 6,
              dataLabels: {
                enabled: true,
                align: 'right',
                allowOverlap: true,
                crop: false,
                overflow: 'allow',
                inside: true,
                x: 55,
                verticalAlign: 'middle',
                style:{
                  color: "#000"
                },
              
              },
              
            },
           
          },
          legend: {
            enabled: true,
            align: 'right',
            verticalAlign: 'top',
            itemStyle:{
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
                  fontWeight:  800,
                  // fontSize: '12px',
                  fontSize: this.height > 1760 ? "32px" : this.height > 1160 && this.height < 1760 ? "22px" : this.height > 667 && this.height < 1160 ? "12px" : "12px",
                },
                formatter: function () {
                  
                  if(level == 'district' || level == 'program'){
                    return this.y ;
                  } else if(level == "block" || level == "cluster" || level == "school"){
                     return this.y;
                  }
                  
                }
              },
              color: '#bc5090',
              name: " Enrolled",
              data: this.enrolData
            },
            {
              dataLabels: {
                enabled: true,
                style: {
                  fontWeight: 800,
                  // fontSize: '12px',
                  fontSize: this.height > 1760 ? "32px" : this.height > 1160 && this.height < 1760 ? "22px" : this.height > 667 && this.height < 1160 ? "12px" : "12px",
                },
                formatter: function () {
                  if(level == 'district' || level == 'program'){
                    return this.y ;
                  } else if(level == "block" || level == "cluster" || level == "school"){
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
                  fontWeight:  800,
                  // fontSize: '12px',
                  fontSize: this.height > 1760 ? "32px" : this.height > 1160 && this.height < 1760 ? "22px" : this.height > 667 && this.height < 1160 ? "12px" : "12px",
                },
                formatter: function () {
                  if(level == 'district'){
                    return this.y ;
                  } else if(level == "block" || level == "cluster" || level == "school"){
                     return this.y;
                  }
                }
              },
              color: '#ffa600',
              name: ' Certificates',
              data: this.perData
            }        
          ],
          tooltip: {
            style: {
              fontSize: this.height > 1760 ? "32px" : this.height > 1160 && this.height < 1760 ? "22px" : this.height > 667 && this.height < 1160 ? "12px" : "10px",
              opacity: 1,
              backgroundColor: "white"
            },
            formatter: function () {
              // return '<b>' + getPointCategoryName(this.point, name, xData, level, type, this.series) + '</b>';
               return  this.points.reduce(function (s, point) {
                return   s  + '<br/>' +  point.series.name + ': ' +
                    point.y.toLocaleString('en-IN');
            },  '<u>'+'<b>' + this.x + '</b>'+ '</u>'+'</br>'); 
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
          opposite: true,
          // max: Math.max.apply(Math, this.data),
          // max: 100,
          gridLineColor: 'transparent',
          title: {
            // text: this.xAxisLabel,
            text: "Values",
            style: {
              color: 'black',
              fontSize: this.height > 1760 ? "32px" : this.height > 1160 && this.height < 1760 ? "22px" : this.height > 667 && this.height < 1160 ? "12px" : "10px",
              fontWeight: "bold"
            }
          }
        },
        plotOptions: {
          bar: {
            // groupPadding: 0.15,
            // pointPadding: 0.7,
            // pointWidth: 6,
            dataLabels: {
              enabled: true,
              align: 'right',
              allowOverlap: true,
              crop: false,
              overflow: 'allow',
              inside: true,
              x: 55,
              verticalAlign: 'middle',
              style:{
                color: "#000"
              },
              // formatter: function(){
              //   console.log('color', this)
              //   return this.colorIndex === 0 ? this.y : this.y + '%';
              //   // return '%'
              // }
            },
            
          },
         
        },
        legend: {
          enabled: true,
          align: 'right',
          verticalAlign: 'top',
          itemStyle:{
            fontSize: this.height > 1760 ? "32px" : this.height > 1160 && this.height < 1760 ? "22px" : this.height > 667 && this.height < 1160 ? "12px" : "10px",
          }
        },
        credits: {
          enabled: false
        },
        series: [
          // {
          //   dataLabels: {
          //     enabled: true,
          //     style: {
          //       fontWeight:  800,
          //       fontSize: '12px',
          //       // fontSize: this.height > 1760 ? "32px" : this.height > 1160 && this.height < 1760 ? "22px" : this.height > 667 && this.height < 1160 ? "12px" : "10px",
          //     },
          //     formatter: function () {
          //       return this.y.toString().replace(/(\d)(?=(\d\d)+\d$)/g, "$1,");
          //     }
          //   },
          //   color: '#396EB0',
          //   name: '% Expected Enrollment',
          //   data: this.data
          // },
          {
            dataLabels: {
              enabled: true,
              style: {
                fontWeight:  800,
                // fontSize: '12px',
                fontSize: this.height > 1760 ? "32px" : this.height > 1160 && this.height < 1760 ? "22px" : this.height > 667 && this.height < 1160 ? "12px" : "12px",
              },
              formatter: function () {
                
                if(level == 'district'){
                  return this.y + '%';
                } else if(level == "block" || level == "cluster" || level == "school"){
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
                // fontSize: '12px',
                fontSize: this.height > 1760 ? "32px" : this.height > 1160 && this.height < 1760 ? "22px" : this.height > 667 && this.height < 1160 ? "12px" : "12px",
              },
              formatter: function () {
                if(level == 'district'){
                  return this.y + '%';
                } else if(level == "block" || level == "cluster" || level == "school"){
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
                fontWeight:  800,
                // fontSize: '12px',
                fontSize: this.height > 1760 ? "32px" : this.height > 1160 && this.height < 1760 ? "22px" : this.height > 667 && this.height < 1160 ? "12px" : "12px",
              },
              formatter: function () {
                if(level == 'district'){
                  return this.y + '%';
                } else if(level == "block" || level == "cluster" || level == "school"){
                   return this.y;
                }
              }
            },
            color: '#ffa600',
            name: 'Certificates',
            data: this.perData
          }        
        ],
        tooltip: {
          style: {
            fontSize: this.height > 1760 ? "32px" : this.height > 1160 && this.height < 1760 ? "22px" : this.height > 667 && this.height < 1160 ? "12px" : "10px",
            opacity: 1,
            backgroundColor: "white"
          },
          formatter: function () {
            // return '<b>' + getPointCategoryName(this.point, name, xData, level, type, this.series) + '</b>';
             return  this.points.reduce(function (s, point) {
              return   s  + '<br/>' +  point.series.name + ': ' +
                  point.y.toLocaleString('en-IN');
          },  '<u>'+'<b>' + this.x + '</b>'+ '</u>'+'</br>'); 
          },
          shared: true
          
        }
      }
    }

    
    this.Highcharts.chart("container", this.chartOptions);

    //Bar tooltips::::::::::::::::::::::
    function getPointCategoryName(point, reportName, xData, level, type, series) {
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

     
      let seriess = series.chart.series;
  
            return obj;
      }
    }
  }

}
