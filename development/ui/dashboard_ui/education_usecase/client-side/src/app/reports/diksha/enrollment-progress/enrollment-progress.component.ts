import { ChangeDetectorRef, Component, OnInit } from "@angular/core";
import * as Highcharts from "highcharts/highstock";
import { AppServiceComponent } from "src/app/app.service";
import { EnrollmentProgressLineChartService } from "src/app/services/enrollment-progress-line-chart.service";
import { ContentUsagePieService } from "src/app/services/content-usage-pie.service";
@Component({
  selector: "app-enrollment-progress",
  templateUrl: "./enrollment-progress.component.html",
  styleUrls: ["./enrollment-progress.component.css"],
})
export class EnrollmentProgressComponent implements OnInit {
  Highcharts: typeof Highcharts = Highcharts;
  chartOptions;

  public state;
  public stateData;
  public chartData:any = [];
  public distMetaData:any = [];
  public level
  public allDistCollection;
  public distWiseCourse:any[];
  public courseToDropDown:any[] ;
  public uniqueDistCourse:any[];
  public selectedCourse;
  public reportData:any = [];
  public fileName

  constructor(
    private changeDetection: ChangeDetectorRef,
    public commonService: AppServiceComponent,
    public service: EnrollmentProgressLineChartService,
    public metaService: ContentUsagePieService
  ) {}

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
    document.getElementById("backBtn")
      ? (document.getElementById("backBtn").style.display = "none")
      : "";

    this.getStateData();
  }

  emptyChart(){
   this.chartData = [];
   this.expectedEnrolled = [];
   this.netEnrolled = [];
   this.category = [];
  //  this.selectedCourseData = [];
   this.courseToDropDown = [];
  //  this.reportData= [];
  
  }

  getStateData() {
    this.fileName = 'enrollment-progress-state'
    try {
      this.service.enrollmentProState().subscribe((res) => {
        this.stateData = res["data"]["data"];
        this.reportData = this.stateData
        this.createLineChart(this.stateData);
        this.getDistMeta()
      });
    } catch (error) {}
  }
   
  clickHome(){
    this.dist = false;
    this.skul = true;
    this.selectedDist = "";
    this.emptyChart();
    this.getStateData();
  }

  public distData
  getDistWise(){
    // this.emptyChart()
    // this.reportData = [];
    try {
      this.service.enrollmentProDist().subscribe((res) => {
        this.distData = res["data"]["data"];
       
        // this.reportData = this.distData
        // this.createLineChart(this.stateData);
        // this.getDistMeta()
      });
    } catch (error) {}
  }



  public expectedEnrolled = [];
  public netEnrolled = [];
  public category = [];

  createLineChart(data) {
     this.emptyChart()
    this.chartData = data;
    try {

      this.chartData.forEach((data) => {
        this.expectedEnrolled.push(data.expected_enrollment);
        this.netEnrolled.push(data.net_enrollment);
        this.category.push(data.date);
      });
      this.getLineChart();
    } catch (error) {
      
    }
   
  }

  public selectedDistricts;
  public distToDropDown;
  

  getDistMeta() {
    try {
      this.metaService.diskshaPieMeta().subscribe((res) => {
        this.distMetaData = res["data"];
        this.selectedDistricts = [];
        this.distToDropDown = this.distMetaData.Districts.map((dist: any) => {
          this.selectedDistricts.push(dist.district_id);
          return dist;
        });
        this.distToDropDown.sort((a, b) =>
          a.district_name.localeCompare(b.district_name)
        );
      });
      this.getDistWise();
      this.getAllCollection();
    } catch (error) {
      //  console.log(error)
    }
  }

  
 
  getAllDistCollection(){
    this.emptyChart()
    this.courseToDropDown = [];
      this.uniqueDistCourse = [];
    try {
      
      this.service.enrollProAllCollection().subscribe(res => {
        this.allDistCollection = res['data']['data'];
        this.distWiseCourse = this.allDistCollection.filter(collection =>{
            return collection.district_id == this.selectedDist
        })
         this.distWiseCourse.forEach(course => {
            this.courseToDropDown.push({
              collection_id : course.collection_id,
              collection_name: course.collection_name
            })
         })
         this.courseToDropDown.map(x => this.uniqueDistCourse.filter(a => a.collection_id == x.collection_id && a.collection_name == x.collection_name).length > 0 ? null : this.uniqueDistCourse.push(x));
        })
    } catch (error) {
      
    }
    
  }


  public allCollection 
  public uniqueAllCourse:any[]
  getAllCollection(){
    this.emptyChart();
    this.uniqueAllCourse = []
    this.level = "allCourse"
    try {
      this.service.enrollProAllCourse().subscribe(res => {
        this.allCollection = res['data']['data']
        //  this.distWiseCourse = this.allCollection
        this.allCollection.forEach(course => {
          this.courseToDropDown.push({
            collection_id : course.collection_id,
            collection_name: course.collection_name
          })
        })
        this.courseToDropDown.map(x => this.uniqueAllCourse.filter(a => a.collection_id == x.collection_id && a.collection_name == x.collection_name).length > 0 ? null : this.uniqueAllCourse.push(x));
 
      })
    } catch (error) {
      
    }
   
  }
   
  public selectedDist
  public selectedDistData
  public districtName
  public dist = false
  public skul = true
  onDistSelected(distId){
    this.dist = true;
    this.skul = false;
      this.emptyChart()
      this.selectedDist = distId
      this.level = "district";
      this.distToDropDown.filter(district => {
        if(district.district_id === this.selectedDist){
          this.districtName = district.district_name
        }
      } ) 
      

    try {
      
      this.selectedDistData = this.distData[this.selectedDist];
      this.reportData =  this.selectedDistData;
      this.createLineChart(this.selectedDistData);
      this.getAllDistCollection()
    } catch (error) {
      
    }
   
  }

  public selectedCourseData:any[]

  onCourseSelected(courseId){
    this.emptyChart()
    this.selectedCourseData = [];
    this.selectedCourse = courseId;
    if(this.level ==='district'){
    
      this.distWiseCourse.forEach( course => {
       if(course.collection_id === this.selectedCourse){
         this.selectedCourseData.push(course)
         
       }
     })
     this.createLineChart(this.selectedCourseData)
    }else if(this.level ==='allCourse'){
      this.allCollection.forEach( course => {
        
       if(course.collection_id === this.selectedCourse){
         this.selectedCourseData.push(course)
       }
     })
     this.createLineChart(this.selectedCourseData)
    }
     
    //  this.createLineChart(this.selectedCourseData)
  }

     //filter downloadable data
     dataToDownload = [];
     newDownload(element) {
       var data1 = {}, data2 = {}, data3 = {};
       Object.keys(element).forEach(key => {
         // if (key !== "percentage_completion") {
           
           data1[key] = element[key];
         // }
       });
       // Object.keys(data1).forEach(key => {
       //   // if (key !== "percentage_teachers") {
       //     data2[key] = data1[key];
       //   // }
       // });
       this.dataToDownload.push(data1);
     }
   
     //download UI data::::::::::::
     downloadReport() {
       this.dataToDownload = [];
       this.reportData.forEach(element => {
         
 
         this.newDownload(element);
       });
       this.commonService.download(this.fileName, this.dataToDownload);
     }


  getLineChart() {
    
       let tickIntervlMonth = 1
       if(this.category.length > 30 && this.category.length < 60){
         tickIntervlMonth = 2
       }else if(this.category.length > 60 && this.category.length < 90){
         tickIntervlMonth = 3
       }else if(this.category.length > 90 && this.category.length < 120){
        tickIntervlMonth = 4
      }else if(this.category.length > 120){
        tickIntervlMonth = 7
      }
    // var pointStart = new Date( this.category[0]).getFullYear();
    this.chartOptions = {
      chart: {
        type: "line",
        plotBackgroundColor: "transparent",
        plotBorderWidth: null,
        plotShadow: false,
        backgroundColor: "transparent",
      },
      title: {
        text: "",
      },
      yAxis: {
        title: {
          text: "Value",
          style:{
            fontWeight: 'bold',
            color: '#000',
            fontSize: '12px'
          }
        },
      },

      xAxis: {
        title: {
          text: "Days",
          style:{
            fontWeight: 'bold',
            color: '#000',
            fontSize: '12px'
          }
        },
        type: "datetime",
        tickInterval   :  tickIntervlMonth,
        
        // categories: this.category,
        categories: this.category.map(date =>{
           return Highcharts.dateFormat('%d-%b-%Y', new Date(date).getTime());
        })
      },
      credits: {
        enabled: false,
      },
      tooltip:{
        formatter: function(){
          return `
               <b> Date:${this.x}</b></br>
               <b> Expected Enrollment: ${this.points[0].y}</b></br>
               <b> Net Enrolled: ${this.points[1].y}</b>
          `
        },
        shared: true
      },
     
      // legend: {
      //   layout: "vertical",
      //   align: "right",
      //   verticalAlign: "top",
      // },

      plotOptions: {
        series: {
          // pointStart      : pointStart,
          // pointInterval   : 24 * 3600 * 1000*30
        },
      },

      series: [
      
        {
          name: "Expected Enrolled",
          color: "#F3950D",
          data: this.expectedEnrolled,
        },
        {
          name: "Total Net Enrolled",
          color: "#D47AE8",
          data: this.netEnrolled,
        }
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
    };
    this.Highcharts.chart("container", this.chartOptions);
  }
}
