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
    var course = this.courseSelected;

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
            text: this.xAxisLabel,
            // text: "Percentage",
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
                return this.y + " (100 %)"
              }
            },
            color: '#396EB0',
            name: this.data.length > 0 ? 'Expected Enrollment' : '',
            data: this.data.length > 0 ? this.data : null 
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
            color: '#D4AC2B',
            
            name: this.perData.length > 0 ? '% Certificates' : '',
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
    }else if ((level === 'district') && this.courseSelected === false){
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
          // max: 100,
          gridLineColor: 'transparent',
          title: {
            text: this.xAxisLabel,
            // text: "Percentage",
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
                if(level == 'district' || level == 'program'){
                  return this.y;
                } else if(level == "block" || level == "cluster" || level == "school"){
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
      if ((level === 'district' || level === 'program') && this.courseSelected === true){
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
           
            max: 100,
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
                 
                  fontSize: this.height > 1760 ? "32px" : this.height > 1160 && this.height < 1760 ? "22px" : this.height > 667 && this.height < 1160 ? "12px" : "12px",
                },
                formatter: function () {
                  
                  if(level == 'district' || level == 'program'){
                    return this.y + "( 100% )" ;
                  } else if(level == "block" || level == "cluster" || level == "school"){
                     return this.y;
                  }
                  
                }
              },
              color: '#396EB0',
              name: this.data.length > 0 ? " Expected Enrolled" : '',
              data: this.data.length > 0 ? this.data : null
            },
            {
              dataLabels: {
                enabled: true,
                style: {
                  fontWeight:  800,
                 
                  fontSize: this.height > 1760 ? "32px" : this.height > 1160 && this.height < 1760 ? "22px" : this.height > 667 && this.height < 1160 ? "12px" : "12px",
                },
                formatter: function () {
                  
                  if(level == 'district' || level == 'program'){
                    return this.y + "%" ;
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
                    return this.y + "%";
                  } else if(level == "block" || level == "cluster" || level == "school"){
                     return this.y;
                  }
                }
              },
              color: '#9C19E0',
              
              name: '% Completed',
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
                  if(level == 'district' || level === "program"){
                    return this.y + "%";
                  } else if(level == "block" || level == "cluster" || level == "school"){
                     return this.y;
                  }
                }
              },
              color: '#D4AC2B',
              name:this.perData.length > 0 ? '% Certificates': '',
              data: this.perData.length > 0? this.perData : null
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
         
          gridLineColor: 'transparent',
          title: {
            text: this.xAxisLabel,
            // text: "Values",
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
            color: '#D4AC2B',
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
            return '<b>' + getPointCategoryName(this.points, name, xData, level, type, this.series, course) + '</b>';
          },
          shared: true
          
        }
      }
    }

    
    this.Highcharts.chart("container", this.chartOptions);

    //Bar tooltips::::::::::::::::::::::
    function getPointCategoryName(points, reportName, xData, level, type, series, courseSelected) {
      var obj = '';
      if (reportName == "enroll/comp") {
     if((level === 'district' || level == "program") && courseSelected === true){
      obj = `&nbsp<b>District Name:</b> ${points[0].x}
      <br> ${points.y !== null ? `<b>Expected Enrolled:</b> &nbsp ${xData[`${points[0].point.index}`]['expected_enrolled']}` : ''}
      <br> ${points.y !== null ? `<b>Enrolled:</b> &nbsp ${xData[`${points[0].point.index}`]['enrollment']}` : ''}
      <br> ${points.y !== null ? `<b>% Enrolled:</b> &nbsp ${xData[`${points[0].point.index}`]['enrolled_percentage']} %` : ''}
      <br> ${points.y !== null ? `<b>completed:</b> &nbsp ${xData[`${points[0].point.index}`]['completion']}` : ''}
      <br> ${points.y !== null ? `<b>% completed:</b> &nbsp ${xData[`${points[0].point.index}`]['percent_completion']} %` : ''}
      <br> ${points.y !== null ? `<b>certificate:</b> &nbsp ${xData[`${points[0].point.index}`]['certificate_value']}` : ''}
      <br> ${points.y !== null ? `<b>% certificate:</b> &nbsp ${xData[`${points[0].point.index}`]['certificate_per']} %` : ''}
      `
     }else if(level === 'program' ){
      obj = `&nbsp<b>District Name:</b> ${points[0].x}
      <br> ${points.y !== null ? `<b>Expected Enrolled:</b> &nbsp ${xData[`${points[0].point.index}`]['expected_enrolled']}` : ''}
      <br> ${points.y !== null ? `<b>Enrolled:</b> &nbsp ${xData[`${points[0].point.index}`]['enrollment']}` : ''}
      <br> ${points.y !== null ? `<b>% Enrolled:</b> &nbsp ${xData[`${points[0].point.index}`]['enrolled_percentage']} %` : ''}
      <br> ${points.y !== null ? `<b>completed:</b> &nbsp ${xData[`${points[0].point.index}`]['completion']}` : ''}
      <br> ${points.y !== null ? `<b>% completed:</b> &nbsp ${xData[`${points[0].point.index}`]['percent_completion']} %` : ''}
      <br> ${points.y !== null ? `<b>certificate:</b> &nbsp ${xData[`${points[0].point.index}`]['certificate_value']}` : ''}
      <br> ${points.y !== null ? `<b>% certificate:</b> &nbsp ${xData[`${points[0].point.index}`]['certificate_per']} %` : ''}
     `
     }else if(level === 'district' ){
      obj = `&nbsp<b>District Name:</b> ${points[0].x}
      <br> ${points.y !== null ? `<b>Enrolled:</b> &nbsp ${xData[`${points[0].point.index}`]['enrollment']}` : ''}
      <br> ${points.y !== null ? `<b>Completed:</b> &nbsp ${xData[`${points[0].point.index}`]['completion']}` : ''}
     `
     }else {
      obj = `&nbsp<b>District Name:</b> ${points[0].x}
      <br> ${points.y !== null ? `<b>Enrolled:</b> &nbsp ${xData[`${points[0].point.index}`]['enrollment']}` : ''}
      <br> ${points.y !== null ? `<b>Completed:</b> &nbsp ${xData[`${points[0].point.index}`]['completion']}` : ''}
      <br> ${points.y !== null ? `<b> Certificate:</b> &nbsp ${xData[`${points[0].point.index}`]['certificate_value']}` : ''}
     `
     }

        return obj;
           
      }
    }
  }

}
