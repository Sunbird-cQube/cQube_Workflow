import { ChangeDetectorRef, Component, OnInit } from '@angular/core';
import * as Highcharts from 'highcharts';

// import addMore from "highcharts/highcharts-more";
import HC_exportData from 'highcharts/modules/export-data';
import { AppServiceComponent } from 'src/app/app.service';
import { TotalContentPlayLineCahrtService } from 'src/app/services/total-content-play-line-cahrt.service';
HC_exportData(Highcharts);
// addMore(Highcharts)

@Component({
  selector: 'app-total-content-play-over-years',
  templateUrl: './total-content-play-over-years.component.html',
  styleUrls: ['./total-content-play-over-years.component.css']
})
export class TotalContentPlayOverYearsComponent implements OnInit {

  Highcharts: typeof Highcharts = Highcharts;
  chartOptions;

  public state

  constructor(
    private changeDetection: ChangeDetectorRef,
    public commonService: AppServiceComponent,
    public service: TotalContentPlayLineCahrtService
    ) { }

    width = window.innerWidth;
  height = window.innerHeight;
  onResize() {
    this.width = window.innerWidth;
    this.height = window.innerHeight;
  }

  ngOnInit(): void {
    this.changeDetection.detectChanges();
    this.state = this.commonService.state;
    document.getElementById("accessProgressCard").style.display = "none";
    document.getElementById("backBtn") ? document.getElementById("backBtn").style.display = "none" : "";
    this.getStateData()
  }

  public data
  public catgory=[]
  getStateData(){
    this.service.getTotalCotentPlayLine().subscribe(res =>{
      this.data = res['data'];
      let obj =[]
      this.data.data.forEach(element => {
          obj.push({
            name:element.month,
            y: element.plays
          })
          this.catgory.push(element.month)
      });
      this.createLineChart(obj)
    })
     
  }

  createLineChart(data){
    // var pointStart = Date.UTC(2020,5,1);
   this.chartOptions = {
  chart:{
   type: 'area',
   plotBackgroundColor: 'transparent',
   plotBorderWidth: null,
   plotShadow: false,
   backgroundColor: 'transparent',
  }, 
  title:{
    text: ""
 },
  yAxis: {
      title: {
          text: 'Total Content Play'
      }
  },

  xAxis: {
    title: {
      text: 'Days'
  },
   type: 'datetime',  
    categories: this.catgory,
    // labels: {
    //   formatter: function() {
    //     return Highcharts.dateFormat('%b/%e/%Y', this.value);
    //   }
    // }
    },

  // xAxis: { 
  //   title: {
  //     text: 'Days'
  // },
  //   min:Date.UTC(2020, 5, 1),
  //   max:Date.UTC(2021, 10, 1),
  //   //allowDecimals: false,
  //   type           : 'datetime',
  //   tickInterval   : 24 * 3600 * 1000*30, //one day
  //   labels         : {
  //       rotation : 0
  //   },
  // },
  credits:{
   enabled: false
  },
  legend: {
      layout: 'vertical',
      align: 'right',
      verticalAlign: 'middle'
  },

  plotOptions : {
    series  : {
        // pointStart      : pointStart,
        // pointInterval   : 24 * 3600 * 1000*30
    }
},

  series: [{
      name: 'Total Content Plays',
      data: data
      //   data: [{
    //     name: 'jan-2021',
    //     y:  43934
    //   },{
    //     name: 'jan-2021',
    //     y:  43934
    //   }
    // ]
      // data: [43934, 52503, 57177, 69658, 97031, 119931, 137133, 154175,69658, 97031, 119931, 137133, 154175,97031, 119931, 137133, 154175,119931]
  }, 
  // {
  //     name: 'Manufacturing',
  //     data: [24916, 24064, 29742, 29851, 32490, 30282, 38121, 40434]
  // }, {
  //     name: 'Sales & Distribution',
  //     data: [11744, 17722, 16005, 19771, 20185, 24377, 32147, 39387]
  // }, {
  //     name: 'Project Development',
  //     data: [null, null, 7988, 12169, 15112, 22452, 34400, 34227]
  // }, {
  //     name: 'Other',
  //     data: [12908, 5948, 8105, 11248, 8989, 11816, 18274, 18111]
  // }
],

  responsive: {
      rules: [{
          condition: {
              maxWidth: 500
          },
          chartOptions: {
              legend: {
                  layout: 'horizontal',
                  align: 'center',
                  verticalAlign: 'bottom'
              }
          }
      }]
  }

}
   this.Highcharts.chart("container", this.chartOptions);
  }

}
