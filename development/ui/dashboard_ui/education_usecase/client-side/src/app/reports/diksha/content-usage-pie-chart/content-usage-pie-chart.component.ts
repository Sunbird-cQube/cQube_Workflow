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
  constructor(public service:ContentUsagePieService) { }

  ngOnInit(): void {
    this.createPieChart()
    this.getStateData()
  }
 
  pieData 
 getStateData(){
      this.service.dikshaPieState().subscribe(res => {
          this.pieData = res['data'];
          
      })
 }

  createPieChart(){

    this.chartOptions = { 
      chart: {
        plotBackgroundColor: 'transparent',
        plotBorderWidth: null,
        plotShadow: false,
        type: 'pie',
        backgroundColor: 'transparent'
    },
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
        data: [{
            name: 'Content',
            y: 61.41,
            // sliced: true,
            // selected: true
        }, {
            name: 'Course Assesment',
            y: 11.84
        }, {
            name: 'Course unit',
            y: 10.85
        }, {
            name: 'eTextbook',
            y: 4.67
        }, {
            name: 'content PlayList',
            y: 4.18
        }, {
            name: 'classRoomTeachingVideos',
            y: 1.64
        } ]
    }]
    };
    this.Highcharts.chart("container", this.chartOptions);

  }

  
}
