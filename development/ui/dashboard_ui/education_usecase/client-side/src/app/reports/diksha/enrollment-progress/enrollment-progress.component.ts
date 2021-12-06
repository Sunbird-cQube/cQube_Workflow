import { ChangeDetectorRef, Component, OnInit } from '@angular/core';
import * as Highcharts from 'highcharts';
import { AppServiceComponent } from 'src/app/app.service';

@Component({
  selector: 'app-enrollment-progress',
  templateUrl: './enrollment-progress.component.html',
  styleUrls: ['./enrollment-progress.component.css']
})
export class EnrollmentProgressComponent implements OnInit {


  Highcharts: typeof Highcharts = Highcharts;
  chartOptions;

  public state

  constructor(
    private changeDetection: ChangeDetectorRef,
    public commonService: AppServiceComponent,
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
    this.getLineChart()
  }


  getLineChart(){

    var pointStart = Date.UTC(2021,10,1);
   this.chartOptions = {
  chart:{
   type: 'line',
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
          text: 'Value'
      }
  },

  xAxis: {
    title: {
      text: 'Days'
  },
    
    categories: ['Jan-01', 'Jan-02', 'Jan-03', 'Jan-04', 'Jan-05', 'Jan-06','Jan-07', 'Jan-08', 'Jan-09', 'Jan-10', 'Jan-11',
                'Jan-12','Jan-13','Jan-14','Jan-15','Jan-16','Jan-17','Jan-18','Jan-19','Jan-20','Jan-21','Jan-22',
                'Jan-23','Jan-24','Jan-25','Jan-26','Jan-27','Jan-28','Jan-29','Jan-30','Jan-31'
                ]
  },
  credits: {
    enabled: false
  },
 
  // xAxis: { 
  //   min:Date.UTC(2021, 10, 1),
  //   max:Date.UTC(2021, 10, 30),
  //   //allowDecimals: false,
  //   type           : 'datetime',
  //   tickInterval   : 24 * 3600 * 1000*30, //one day
  //   labels         : {
  //       rotation : 0
  //   },
  // },
  legend: {
      layout: 'vertical',
      align: 'right',
      verticalAlign: 'top',
  },

  plotOptions : {
    series  : {
        // pointStart      : pointStart,
        // pointInterval   : 24 * 3600 * 1000*30
    }
},

  series: [{
      name: 'Total Net Enrolled',
      color: '#D47AE8',
      data: [43934, 52503, 57177, 69658, 97031, 119931, 69658, 97031,52503, 57177,97031,
        43934, 52503, 57177, 69658, 97031, 119931, 69658, 97031,52503, 57177,97031,
        119931, 69658, 97031,52503, 57177,97031,97031,52503, 57177,
      ]
  }, 
  {
      name: 'Expected Enrolled',
      color: '#F3950D',
      data: [24916, 50000, 75000, 100000,125000 , 150000, 175000,200000, 210000, 225000, 240000,
        100000,125000 , 150000, 175000,200000, 210000, 225000, 240000,100000,125000 , 150000, 175000,200000, 210000, 225000, 240000,100000,125000 , 150000, 175000
      ]
  },
  //  {
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

  // responsive: {
  //     rules: [{
  //         // condition: {
  //         //     maxWidth: 500
  //         // },
  //         chartOptions: {
  //             // legend: {
  //             //     layout: 'vertical',
  //             //     align: 'center',
  //             //     verticalAlign: 'bottom'
  //             // }
  //         }
  //     }]
  // }

}
   this.Highcharts.chart("container", this.chartOptions);
  }

}
