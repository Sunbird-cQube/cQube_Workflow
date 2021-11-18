import { Component, OnInit } from '@angular/core';

import * as Highcharts from 'highcharts';
import { ContentUsagePieService } from 'src/app/services/content-usage-pie.service';

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
  distData:any
  constructor(public service:ContentUsagePieService) { }

  ngOnInit(): void {
    this.getStateData();
    this.getDistData();
    
  }
 
 

 getStateData(){
      this.service.dikshaPieState().subscribe(res => {
          this.pieData = res['data'].data;
         this.stateData = this.restructurePieChartData(this.pieData)
         this.createPieChart(this.stateData);
         this.getDistMeta();
      })
    
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
            this.distData = res['data'];
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
        //   console.log('drop',this.distToDropDown)
           }) 
    } catch (error) {
        //  console.log(error)
    }
  
}

 public selectedDist

  onDistSelected(data){
    this.selectedDist = data;
     let distWiseData = this.distData[this.selectedDist]
     let distPieData = this.restructurePieChartData(distWiseData)
     this.createPieChart(distPieData)
    console.log('selected', data)
  }

  createPieChart(data){
    console.log('inside', this.stateData);
    this.chartOptions = { 
      chart: {
        plotBackgroundColor: 'transparent',
        plotBorderWidth: null,
        plotShadow: false,
        type: 'pie',
        backgroundColor: 'transparent'
    },
    colors: ['#50B432', '#ED561B', '#DDDF00', '#24CBE5', '#64E572', '#FF9655', '#FFF263', '#6AF9C4'],
    title: {
        text: 'Total'
    },
    tooltip: {
        pointFormat: '{series.name}: <b>{point.percentage:.1f}%</b>'
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
      width: 400,
      itemWidth: 300,
      itemMarginTop: 5,
      itemMarginBottom: 5
    },
    plotOptions: {
        pie: {
            allowPointSelect: true,
            cursor: 'pointer',
            dataLabels: {
                enabled: true,
                format: '<b>{point.name}</b>: {point.percentage:.1f} %'
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
