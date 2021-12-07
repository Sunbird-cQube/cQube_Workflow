import { ChangeDetectorRef, Component, OnInit, QueryList, ViewChild, ViewChildren } from '@angular/core';
// import { MultiSelectComponent } from '../../../common/multi-select/multi-select.component';
import * as Highcharts from 'highcharts';
import { AppServiceComponent } from 'src/app/app.service';
import { ContentUsagePieService } from 'src/app/services/content-usage-pie.service';
import { MapService } from 'src/app/services/map-services/maps.service';

import addMore from "highcharts/highcharts-more";
import HC_exportData from 'highcharts/modules/export-data';
import { MultiBarChartComponent } from '../multi-bar-chart/multi-bar-chart.component';
import { MultiSelectComponent } from '../../../common/multi-select/multi-select.component';
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
  public districtSelectBox = false
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
  selectedDrop = 'State Only'
  

  // @ViewChildren(MultiSelectComponent) multiSelect: QueryList<MultiSelectComponent>;
  @ViewChild(MultiSelectComponent) multiSelect1: MultiSelectComponent;
 

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
            name: item.object_type,
            // y: Number((Math.round(item.total_content_plays_percent * 100) / 100).toFixed(2))
            y: item.total_content_plays_percent
          })
      })
      return data
      
   }

   disWisePieChart : any = []

 /// distData
 getDistData(){
 
     try {
        this.service.dikshaPieDist().subscribe(res => {
            this.distData = res['data'].data;
            this.createDistPiechart()
            }) 
     } catch (error) {
          console.log(error)
     }
   
 }

    public distMetaData;
     public distToDropDown
    selectedDistricts: any;
 
     /// distMeta
  getDistMeta(){
       try {
       this.service.diskshaPieMeta().subscribe(res => {
           this.distMetaData = res['data'];
          this.selectedDistricts = [];
          this.distToDropDown = this.distMetaData.Districts.map( (dist:any) =>{
              this.selectedDistricts.push(dist.district_id);
              dist.id = dist.district_id
              dist.name = dist.district_name;
              dist.status = false;
              return dist
          })
          this.distToDropDown.sort((a, b) => a.district_name.localeCompare(b.district_name))
          this.getDistData();
        
           }) 
    } catch (error) {
        //  console.log(error)
    }
  
}

 public distToggle = false

onStateDropSelected(data){
  this.selectedDrop = data
  if(this.selectedDrop === 'State with Districts'){
    this.distToggle = true
    this.districtSelectBox = true;
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

 onSelectDistrict(data){
    if(data.length > 0){
      this.selectedDistricts = data.slice()
    }else{
       this.distMetaData.Districts.forEach( (dist:any) =>{
        this.selectedDistricts.push(dist.district_id);
      })
    }
    
     this.createDistPiechart()
  }

  clearSuccessors(data){
   
  }

  distPieChart 
  disttoLoop = []
  allDistData
  distWisePieData
  chartData

  newPieData
  
  createDistPiechart(){
    
    let pieData: any = [];
    Object.keys(this.distData).forEach( keys => {
      pieData.push({
        id:keys,
        data: this.distData[keys]
      })
    });
    
    let Distdata:any = []
    
    pieData.filter(district => {
      return this.selectedDistricts.find(districtId => districtId === +district.id ) 
      //&& districtId === 2401
    }).forEach((district, i) =>{
        let  obj = {
          name: district.data[0].district_name,
          data: []
        }

         district.data.forEach((metric, i) => {
           obj.data.push([metric.object_type,metric.total_content_plays_percent]);
         });

    Distdata.push(obj);
    Distdata.sort((a, b) => a.name.localeCompare(b.name));
        })
        

    // this.service.diskshaPieMeta().subscribe(res => {
    //   this.distPieChart = res['data'];
    //  this.disttoLoop = this.distPieChart.Districts.map( (dist:any) =>{
    //      return dist
    //  })
    
     let createdDiv;

     const mainContainer = document.getElementById('container1');
     function removeAllChildNodes(parent) {
      while (parent.firstChild) {
          parent.removeChild(parent.firstChild);
      }
  }

  removeAllChildNodes(mainContainer)

     Distdata.forEach(function(el:any,i) {
      var chartData = el
      var distName = el.name
      
        
     var distChartData = []
     
     createdDiv = document.createElement('div');
      createdDiv.style.display = 'inline-block';
      createdDiv.style.width = '370px';
      createdDiv.style.height = "350px";
      
      // createdDiv.id = `text${i}`
      
      mainContainer.appendChild(createdDiv); 
      // Object.keys(dataEl).forEach( item=> {
      //   console.log('item',item)
      // })
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
            size: 100,
              allowPointSelect: true,
              cursor: 'pointer',
              dataLabels: {
                  enabled: true,
                  format: '<b>{point.name}</b>: {point.percentage:.1f} %',
                  style: {
                    // color: 'blue',
                    // fontWeight: 'bold',
                    fontSize: '0.6rem'
                }
              },
              showInLegend: false
          }
        },
        // series: [{
        //   type: 'pie',
        //   colorByPoint: true,
        //   data: [el]
        // }]
        series : [chartData]
        
      });
     
    })    
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
          fontSize: '0.2rem'
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
        fontSize: '0.5rem',
        lineHeight: 2
    }
    },
    plotOptions: {
        pie: {
          size: 280,
            allowPointSelect: true,
            cursor: 'pointer',
            dataLabels: {
                enabled: true,
                format: '<b>{point.name}</b>: {point.percentage:.1f} %',
                style: {
                  // color: 'blue',
                  // fontWeight: 'bold',
                  fontSize: '0.6rem'
              }
            },
            showInLegend: true
        }
    },
    
    series: [{
        name: 'Percentage',
        colorByPoint: true,
        data: data
    }]
    };
    this.Highcharts.chart("container", this.chartOptions);
  }

  

 

  
}
