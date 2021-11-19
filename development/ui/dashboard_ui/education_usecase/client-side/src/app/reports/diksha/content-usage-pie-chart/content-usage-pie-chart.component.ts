import { ChangeDetectorRef, Component, OnInit } from '@angular/core';

import * as Highcharts from 'highcharts';
import { AppServiceComponent } from 'src/app/app.service';
import { ContentUsagePieService } from 'src/app/services/content-usage-pie.service';
import { MapService } from 'src/app/services/map-services/maps.service';

@Component({
  selector: 'app-content-usage-pie-chart',
  templateUrl: './content-usage-pie-chart.component.html',
  styleUrls: ['./content-usage-pie-chart.component.css']
})
export class ContentUsagePieChartComponent implements OnInit {
  Highcharts: typeof Highcharts = Highcharts;
  chartOptions;

  public pieData 
  public stateData = [];
  public distData:any
  public level
  public state

  constructor(
    public service:ContentUsagePieService,
    public commonService: AppServiceComponent,
    private changeDetection: ChangeDetectorRef,
    public globalService: MapService,
    ) { }

    width = window.innerWidth;
  height = window.innerHeight;
  onResize() {
    this.width = window.innerWidth;
    this.height = window.innerHeight;
  }

  ngOnInit(): void {
    this.commonService.errMsg();
    this.changeDetection.detectChanges();
    this.state = this.commonService.state;
    document.getElementById("accessProgressCard").style.display = "none";
    document.getElementById("backBtn") ? document.getElementById("backBtn").style.display = "none" : "";
    this.getStateData();
    this.getDistData();
    
  }
 
 public skul = true;

 getStateData(){
  this.commonService.errMsg();
  this.stateData = [];
try {

  this.service.dikshaPieState().subscribe(res => {
    this.pieData = res['data'].data;
   this.stateData = this.restructurePieChartData(this.pieData)
   this.createPieChart(this.stateData);
   this.getDistMeta();
   this.commonService.loaderAndErr(this.stateData);
   })
} catch (e) {
  this.stateData = [];
  this.commonService.loaderAndErr(this.stateData);
      console.log(e);
}    
 }

 clickHome() {
  this.selectedDist = "";
  this.dist =false;
  this.skul = true;
  this.getStateData();
}
  

   restructurePieChartData(pieData){
      let data:any = []
    pieData.forEach( item => {
       data.push({
            name: item.collection_type,
            y: Number((Math.round(item.total_content_plays_percent * 100) / 100).toFixed(2))
        })
      }) 
      return data
   }


 /// distData
 getDistData(){
     try {
        this.service.dikshaPieDist().subscribe(res => {
            this.distData = res['data'].data;
           console.log('dist',this.distData)
            }) 
     } catch (error) {
          console.log(error)
     }
   
 }

    public distMetaData;
     public distToDropDown
  /// distMeta
  getDistMeta(){
    try {
       this.service.diskshaPieMeta().subscribe(res => {
           this.distMetaData = res['data'];
           console.log('metaData', this.distMetaData)
          this.distToDropDown = this.distMetaData.Districts.map( (dist:any) =>{
              return dist
          })
          console.log('drop',this.distToDropDown)
           }) 
    } catch (error) {
        //  console.log(error)
    }
  
}

 public selectedDist;
 public distWiseData = [];
 public distPieData = [];
 public dist = false;
 public distName

  onDistSelected(data){
     this.distWiseData = [];
     this.distPieData = [];
     this.dist = true;
     this.skul = false;
     this.distName = '';
     console.log('distName', data)
    try {
      this.selectedDist = data;
      this.distWiseData = this.distData[this.selectedDist]
      this.distPieData = this.restructurePieChartData(this.distWiseData)
      this.createPieChart(this.distPieData)
      this.commonService.loaderAndErr(this.distWiseData);
    } catch (error) {
      this.distWiseData = [];
      this.commonService.loaderAndErr(this.distWiseData);
      console.log(error)
    }
  }

  createPieChart(data){
    this.chartOptions = { 
      chart: {
        plotBackgroundColor: 'transparent',
        plotBorderWidth: null,
        plotShadow: false,
        type: 'pie',
        backgroundColor: 'transparent'
    },
    colors: ['#50B432', '#24CBE5', '#64E572', '#FF9655', '#FFF263', '#6AF9C4'],
    title: {
        text: 'Total'
    },
    tooltip: {
        pointFormat: '{series.name}: <b>{point.percentage:.1f}%</b>',
        style: {
          // color: 'blue',
          fontWeight: 'bold',
          fontSize: '1rem'
          // point.percentage
      }
    },
    accessibility: {
        point: {
            valueSuffix: '%'
        }
    },
    credits: {
      enabled: false
    },
    legend: {
      layout:  'vertical',
      align: 'right',
      verticalAlign: 'middle',
      borderWidth: 0,
      width: '40%',
      itemWidth: '30%',
      itemMarginTop: 5,
      itemMarginBottom: 5,
      style: {
        // color: 'blue',
        // fontWeight: 'bold',
        fontSize: '0.8rem'
    }
    },
    plotOptions: {
        pie: {
            allowPointSelect: true,
            cursor: 'pointer',
            dataLabels: {
                enabled: true,
                format: '<b>{point.name}</b>: {point.percentage:.1f} %',
                style: {
                  // color: 'blue',
                  // fontWeight: 'bold',
                  fontSize: '0.8rem'
              }
            },
            showInLegend: true
        }
    },
    
    series: [{
        name: 'Percentage',
        colorByPoint: true,
        data: data
        // data: [{
        //     name: "Collection",
        //      y: 0.01
        //     // sliced: true,
        //     // selected: true
        // }, {
        //     name: "Course",
        //     y: 88.47
        // }, {
        //     name: "CourseUnit",
        //     y: 0
        // }, {
        //     name: "LessonPlan",
        //     y: 0
        // }, {
        //     name: "TextBook",
        //     y: 11.51
        // }, {
        //     name: "TextBookUnit",
        //     y: 0.01
        // } ]
    }]
    };
    this.Highcharts.chart("container", this.chartOptions);
  }

  
}
