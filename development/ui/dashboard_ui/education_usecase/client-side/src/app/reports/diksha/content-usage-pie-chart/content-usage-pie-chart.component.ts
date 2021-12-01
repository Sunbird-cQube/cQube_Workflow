import { ChangeDetectorRef, Component, OnInit } from '@angular/core';

import * as Highcharts from 'highcharts';
import { AppServiceComponent } from 'src/app/app.service';
import { ContentUsagePieService } from 'src/app/services/content-usage-pie.service';
import { MapService } from 'src/app/services/map-services/maps.service';

import addMore from "highcharts/highcharts-more";
import HC_exportData from 'highcharts/modules/export-data';
HC_exportData(Highcharts);
addMore(Highcharts)

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

  public stateDropDown = [{ key: 'State Only', name: 'State Only' }, { key: 'State with Districts', name: 'State with Districts' }]
  selectedDrop = 'State with Districts'
  
  ngOnInit(): void {
    this.commonService.errMsg();
    this.changeDetection.detectChanges();
    this.state = this.commonService.state;
    document.getElementById("accessProgressCard").style.display = "none";
    document.getElementById("backBtn") ? document.getElementById("backBtn").style.display = "none" : "";
    this.getStateData();
    // this.getDistData();
    // this.createDistPiechart();
    
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
   this.getDistData()
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
      console.log('state', data) 
      return data
      
   }

   disWisePieChart : any = []

 /// distData
 getDistData(){
  // let dataPie = []
     try {
        this.service.dikshaPieDist().subscribe(res => {
            this.distData = res['data'].data;
            // this.distToDropDown.forEach(item => {
            //   this.distWisePieData = this.distData[Number(item['district_id'])]
            
            //   dataPie.push({
            //    name: this.distData[Number(item['district_id'])]
            //  })
            //  console.log('pieData',this.distWisePieData)
            let obj1: any = []; let obj2 = {}
            Object.keys(this.distData).forEach( keys => {
              obj1.push(
                this.distData[keys])
            })
            console.log('obj',obj1)
            // Object.keys(this.distData)
            this.createDistPiechart(obj1)
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
          
          this.distToDropDown = this.distMetaData.Districts.map( (dist:any) =>{
              return dist
          })
        
           }) 
    } catch (error) {
        //  console.log(error)
    }
  
}

 public distToggle = true

onStateDropSelected(data){
  this.selectedDrop = data
  if(this.selectedDrop === 'State with Districts'){
    this.distToggle = true
  }else{
    this.distToggle = false
  }
  this.getStateData();
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
    
    try {
      this.selectedDist = data;
      this.distWiseData = this.distData[this.selectedDist]
      this.distPieData = this.restructurePieChartData(this.distWiseData)
      this.createPieChart(this.distPieData)
      this.commonService.loaderAndErr(this.distWiseData);
    } catch (error) {
      this.distWiseData = [];
      this.commonService.loaderAndErr(this.distWiseData);
    
    }
  }

  distPieChart 
  disttoLoop = []
  allDistData
  distWisePieData
 
  createDistPiechart(data ){
     console.log('dataforie', data)
    // var allDistData
    // let distWiseData
    let pieData = data
    let Distdata:any = []
    // let data1:any = []
    //     data.forEach((item, i) =>{
    //       data1.push({
    //         name: item.data[i].collection_type,
    //         y: Number((Math.round(item.data[i].total_content_plays_percent * 100) / 100).toFixed(2))
    //     })
              // item.forEach( item1 =>{
              //   data1.push({
              //     name: item1.collection_type,
              //     y: Number((Math.round(item1.total_content_plays_percent * 100) / 100).toFixed(2))
              // })
              // })
        // })
    // console.log('data1', data1)

    this.service.diskshaPieMeta().subscribe(res => {
      this.distPieChart = res['data'];
      // console.log('distPieChart', this.distPieChart )
     this.disttoLoop = this.distPieChart.Districts.map( (dist:any) =>{
         return dist
     })
    
     console.log('dist', this.disttoLoop)
     ////data///////
    
     let createdDiv
      
     let containerID = []
     var Piedata = [{
       distName: "Ahmedabad",
      data1: 12,
      data2: 25,
      data3: 40
    }, {
      distName: "Aravalli",
      data1: 67,
      data2: 11,
      data5: 56
    },
    {
      distName: "Navsari", 
      data1: 67,
      data2: 11,
      data5: 56
    },
    { 
      distName: "Junagadh",
      data1: 67,
      data2: 11,
      data5: 56
    },
    {
      distName: "Panch Mahals",
      data1: 67,
      data2: 11,
      data5: 56
    },{
      distName: "Bharuch",
      data1: 67,
      data2: 11,
      data5: 56
    },{
      distName: "Anand",
     data1: 12,
     data2: 25,
     data3: 40
   }, {
     distName: "Surat",
     data1: 67,
     data2: 11,
     data5: 56
   },
   {
     distName: "Kheda", 
     data1: 67,
     data2: 11,
     data5: 56
   },
   { 
     distName: "Kachchh",
     data1: 67,
     data2: 11,
     data5: 56
   },
   {
     distName: "Chhotaudepur",
     data1: 67,
     data2: 11,
     data5: 56
   },{
     distName: "The Dangs",
     data1: 67,
     data2: 11,
     data5: 56
   },
   {
    distName: "Sabar Kantha",
   data1: 12,
   data2: 25,
   data3: 40
 }, {
   distName: "Gandhinagar",
   data1: 67,
   data2: 11,
   data5: 56
 },
 {
   distName: 'Amreli', 
   data1: 67,
   data2: 11,
   data5: 56
 },
 { 
   distName: 'Rajkot',
   data1: 67,
   data2: 11,
   data5: 56
 },
 {
   distName: 'Mahisagar',
   data1: 67,
   data2: 11,
   data5: 56
 },{
   distName: 'Vadodara',
   data1: 67,
   data2: 11,
   data5: 56
 },{
   distName: 'Bhavnagar',
  data1: 12,
  data2: 25,
  data3: 40
}, {
  distName: "Narmada",
  data1: 67,
  data2: 11,
  data5: 56
},
{
  distName: 'Mahesana', 
  data1: 67,
  data2: 11,
  data5: 56
},
{ 
  distName: 'Tapi',
  data1: 67,
  data2: 11,
  data5: 56
},
{
  distName: 'Surendranagar',
  data1: 67,
  data2: 11,
  data5: 56
},{
  distName: 'Devbhoomi Dwarka',
  data1: 67,
  data2: 11,
  data5: 56
},{
  distName: 'Valsad', 
  data1: 67,
  data2: 11,
  data5: 56
},
{ 
  distName: 'Jamnagar',
  data1: 67,
  data2: 11,
  data5: 56
},
{
  distName: 'Patan',
  data1: 67,
  data2: 11,
  data5: 56
},{
  distName: 'Banaskantha',
  data1: 67,
  data2: 11,
  data5: 56
},{ 
  distName:  'Botad',
  data1: 67,
  data2: 11,
  data5: 56
},
{
  distName: 'Morbi',
  data1: 67,
  data2: 11,
  data5: 56
},{
  distName: 'Gir Somnath',
  data1: 67,
  data2: 11,
  data5: 56
}];

    // var Piedata = [{
    //   "name": "cakes",
    //   "data": [
    //     {
    //      name: "us",
    //      y: 149
    //     },
    //     {
    //       name: "us",
    //       y: 149
    //      },
    //      {
    //       name: "us",
    //       y: 149
    //      },
    //      {
    //       name: "us",
    //       y: 149045
    //      }
    //   ],
    // }, {
    //   "name": "pie",
    //   "data": [
    //     {
    //      name: "us",
    //      y: 149
    //     },
    //     {
    //       name: "us",
    //       y: 149
    //      },
    //      {
    //       name: "us",
    //       y: 149
    //      },
    //      {
    //       name: "us",
    //       y: 149045
    //      }
    //   ]
    // }]
    
 
     const  mainContainer = document.getElementById('container1');
    // console.log('distToLoop', this.disttoLoop)
    Piedata.forEach(function(el:any,i) {
      var chartData = [el.data1, el.data2, el.data3];
      var distName = el.distName
      console.log('ddd', distName)
      // var chartData = [el.data[i].y];
     createdDiv = document.createElement('div');
      createdDiv.style.display = 'inline-block';
      createdDiv.style.width = '300px';
      createdDiv.style.height = "300px";
      createdDiv.id = `text${i}`
      // createdDiv.style.backgroundColor = 'blue';
      
     
      
      mainContainer.appendChild(createdDiv); 
      // Object.keys(dataEl).forEach( item=> {
      //   console.log('item',item)
      // })
   
     
     
     
      // let pieData:any =  this.data[Number(dataEl['district_id'])]
      Highcharts.chart(createdDiv, {
        chart:{
          plotBackgroundColor: 'transparent',
          plotBorderWidth: null,
          plotShadow: false,
          type: 'pie',
          backgroundColor: 'transparent',

        },
        title:{
          text:  `${distName}`,
        },
        colors: ['#50B432', '#24CBE5', '#64E572', '#FF9655', '#FFF263', '#6AF9C4'],
        credits: {
          enabled: false
        },
        plotOptions: {
          pie: {
            size: 130,
          }
        },
        series: [{
          type: 'pie',
          colorByPoint: true,
          data: chartData
        }]

        
      });
     
    })     
        });
      // }) 
    }

   

  createPieChart(data){

      ////////

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
        text: '',
        align: 'left',
        style: {
          fontWeight: 'bold',
        }  
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
      align: 'left',
      // horizontalAlign: 'middle',
      borderWidth: 0,
      // width: '70%',
      // itemWidth: '30%',
      // itemMarginTop: 10,
      itemMarginBottom: 7,
      style: {
        // color: 'blue',
        // fontWeight: 'bold',
        fontSize: '0.8rem',
        lineHeight: 2
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
