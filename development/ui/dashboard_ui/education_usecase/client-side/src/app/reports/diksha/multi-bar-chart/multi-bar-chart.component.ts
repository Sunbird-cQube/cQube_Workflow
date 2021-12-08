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
            fontSize: this.height > 1760 ? "32px" : this.height > 1160 && this.height < 1760 ? "22px" : this.height > 667 && this.height < 1160 ? "12px" : "10px",
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
            fontSize: this.height > 1760 ? "26px" : this.height > 1160 && this.height < 1760 ? "16px" : this.height > 667 && this.height < 1160 ? "12px" : "10px"
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
              fontSize: '12px',
              // fontSize: this.height > 1760 ? "32px" : this.height > 1160 && this.height < 1760 ? "22px" : this.height > 667 && this.height < 1160 ? "12px" : "10px",
            },
            formatter: function () {
              return this.y.toString().replace(/(\d)(?=(\d\d)+\d$)/g, "$1,");
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
              fontSize: '12px',
              // fontSize: this.height > 1760 ? "32px" : this.height > 1160 && this.height < 1760 ? "22px" : this.height > 667 && this.height < 1160 ? "12px" : "10px",
            },
            formatter: function () {
              return this.y + '%';
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
              fontSize: '12px',
              // fontSize: this.height > 1760 ? "32px" : this.height > 1160 && this.height < 1760 ? "22px" : this.height > 667 && this.height < 1160 ? "12px" : "10px",
            },
            formatter: function () {
              return  this.y + '%';
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
              fontSize: '12px',
              // fontSize: this.height > 1760 ? "32px" : this.height > 1160 && this.height < 1760 ? "22px" : this.height > 667 && this.height < 1160 ? "12px" : "10px",
            },
            formatter: function () {
              return this.y + '%';
            }
          },
          color: '#ffa600',
          name: '% Certificates',
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

      // obj = `<b>${level.charAt(0).toUpperCase() + level.substr(1).toLowerCase()} Name:</b> ${point.category.parent.name} 
      //        ${xData[point.index] ? `<br><b>Enrollment: </b>${xData[0][1][point.index]}<br><b>Completion: </b>${xData[0][2][point.index]}<br>
      //        <b>Percet Completion: </b>${xData[0][0][point.index]}%
      //        ` : ''}`
      let seriess = series.chart.series;
  
    //   for(var i=0; i<seriess.length; i++) {
               
    //      obj = `<b>${level.charAt(0).toUpperCase() + level.substr(1).toLowerCase()} Name:</b> ${point.category} 
    //             <br><b>${series.name}: </b>${point.options.y}<br>`;
    // }
            return obj;
      }
    }
  }

}
