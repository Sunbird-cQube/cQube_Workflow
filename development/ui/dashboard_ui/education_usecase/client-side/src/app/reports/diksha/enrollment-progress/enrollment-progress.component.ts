import { ChangeDetectorRef, Component, OnInit } from "@angular/core";
import * as Highcharts from "highcharts/highstock";
import { AppServiceComponent } from "src/app/app.service";
import { EnrollmentProgressLineChartService } from "src/app/services/enrollment-progress-line-chart.service";
import { ContentUsagePieService } from "src/app/services/content-usage-pie.service";
import { element } from "protractor";
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
  public chartData: any = [];
  public distMetaData: any = [];
  public level;
  public allDistCollection;
  public distWiseCourse: any[];
  public courseToDropDown: any[];
  public uniqueDistCourse: any[];
  public selectedCourse;
  public reportData: any = [];
  public fileName;
  public districtHidden  = true;
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
    this.getProgramData();
    this.getAllDistCollection();
  }

  emptyChart() {
    //  this.chartData = [];
    this.expectedEnrolled = [];
    this.netEnrolled = [];
    this.category = [];
    //  this.selectedCourseData = [];
    this.courseToDropDown = [];
    //  this.reportData= [];
  }

  getStateData() {
    this.fileName = "enrollment-progress-state";
    try {
      this.service.enrollmentProState().subscribe((res) => {
        this.stateData = res["data"]["data"];
        this.reportData = this.stateData;
        this.createLineChart(this.stateData);
        this.getDistMeta();
        // this.getAllDistCollection();
      });
    } catch (error) {}
  }

  clickHome() {
    this.dist = false;
    this.skul = true;
    this.districtHidden = true;
    this.selectedDist = "";
    this.selectedCourse = "";
    this.courseSelected = false;
    this.programSelected = false;
    this.selectedProgram = "";
    this.emptyChart();
    this.getStateData();
  }

  public distData;
  getDistWise() {
    this.emptyChart();
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
    this.chartData = [];
    this.expectedEnrolled = [];
    this.netEnrolled = [];
    this.category = [];
    this.chartData = data;
    try {
      this.chartData.forEach((data) => {
        this.expectedEnrolled.push(data.expected_enrollment);
        this.netEnrolled.push(data.net_enrollment);
        this.category.push(data.date);
      });
      this.getLineChart();
    } catch (error) {}
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

  public programData;
  public programDropDown = [];
  public programWiseCourse: any = [];
  public uniquePrograms: any = [];

  getProgramData() {
    this.programWiseCourse = [];
    this.uniquePrograms = [];
    try {
      this.service.enrollProgam().subscribe((res) => {
        this.programData = res["data"]["data"]
        this.programData.forEach((course) => {
          this.programDropDown.push({
            program_id: course.program_id,
            program_name: course.program_name,
          });
        });
        this.programDropDown.map((x) =>
          this.uniquePrograms.filter(
            (a) =>
              a.program_id == x.program_id && a.program_name == x.program_name
          ).length > 0
            ? null
            : this.uniquePrograms.push(x)
        );
      });
    } catch (error) {}
  }

  getAllDistCollection() {
    this.emptyChart();
    this.courseToDropDown = [];
    this.uniqueDistCourse = [];
    try {
      document.getElementById("spinner").style.display = "block";
      this.service.enrollProAllCollection().subscribe((res) => {
        this.allDistCollection = res["data"]["data"];
        document.getElementById("spinner").style.display = "none";
      });
      
      // setTimeout(()=>{
      //   document.getElementById("spinner").style.display = "block";
      // })
    } catch (error) {}
  }

  public programWiseCollection;

  getProgramWiseColl(data) {
    this.service.enrollProgamWiseColl().subscribe((res) => {
      this.programWiseCollection = res["data"]["data"];
      this.programWiseCourse = this.programWiseCollection.filter(
        (collection) => {
          return collection.program_id == data;
        }
      );
      this.getCollectionDropDown(this.programWiseCourse);
    });
  }

  public allCollection;
  public uniqueAllCourse: any;
  getAllCollection() {
    this.emptyChart();
    this.uniqueAllCourse = [];
    this.allCollection = [];
    this.level = "allCourse";
    try {
      this.service.enrollProAllCourse().subscribe((res) => {
        this.allCollection = res["data"]["data"];
        this.getCollectionDropDown(this.allCollection);
        // this.allCollection.forEach(course => {
        //   this.courseToDropDown.push({
        //     collection_id : course.collection_id,
        //     collection_name: course.collection_name
        //   })
        // })
        // this.courseToDropDown.map(x => this.uniqueAllCourse.filter(a => a.collection_id == x.collection_id && a.collection_name == x.collection_name).length > 0 ? null : this.uniqueAllCourse.push(x));
      });
    } catch (error) {}
  }

  public collectionDropDown;
  getCollectionDropDown(data) {
    this.courseToDropDown = [];
    this.collectionDropDown = data.slice();
    try {
      document.getElementById("spinner").style.display = "display";
      if (this.level === "district") {
        // document.getElementById("spinner").style.display = "display";
        this.distWiseCourse = this.allDistCollection.filter((collection) => {
          return collection.district_id == this.selectedDist;
        });
        this.distWiseCourse.forEach((course) => {
          this.courseToDropDown.push({
            collection_id: course.collection_id,
            collection_name: course.collection_name,
          });
        });
        this.courseToDropDown.map((x) =>
          this.uniqueAllCourse.filter(
            (a) =>
              a.collection_id == x.collection_id &&
              a.collection_name == x.collection_name
          ).length > 0
            ? null
            : this.uniqueAllCourse.push(x)
        );
        document.getElementById("spinner").style.display = "none";
      } else {
        this.collectionDropDown.forEach((course) => {
          this.courseToDropDown.push({
            collection_id: course.collection_id,
            collection_name: course.collection_name,
          });
        });

        let mymap = new Map();
  
        this.uniqueAllCourse = this.courseToDropDown.filter(el => {
           
            if(mymap.has(el.collection_id)) {
                 return false
            }
            mymap.set(el.collection_id,el.collection_name );
            return true;
        });

      }

    } catch (error) {}
  }

  public selectedDist;
  public selectedDistData:any;
  public districtName;
  public dist = false;
  public skul = true;
  public selectedDistWiseCourse;

  onDistSelected(distId) {
    this.dist = true;
    this.skul = false;
    this.selectedDist = ""
    this.selectedDistData = [];
    this.selectedDistWiseCourse = [];
    this.reportData = [];
    this.emptyChart();
    this.selectedDist = distId;
    this.level = "district";
    this.distToDropDown.filter((district) => {
      if (district.district_id === this.selectedDist) {
        this.districtName = district.district_name;
      }
    });

    try {
      if (this.courseSelected === true && this.programSelected === true) {
        //  this.courseSelected = false;
        this.selectedDistData = this.allDistCollection.filter((collection) => {
          return collection.district_id === this.selectedDist;
        });
        this.selectedDistWiseCourse = this.selectedDistData.filter(
          (collection) => {
            return collection.collection_id === this.selectedCourse && collection.program_id === this.selectedProgram;
          }
        );

       
        this.createLineChart(this.selectedDistWiseCourse);
        this.reportData = this.selectedDistWiseCourse;
        document.getElementById("spinner").style.display = "none";
        }else if(this.programSelected === true && this.courseSelected !== true) {
          // this.programSelected = false;
        document.getElementById("spinner").style.display = "display";
        this.selectedCourse = "";
        this.selectedDistData = [];
        this.selectedDistData = this.allDistCollection.filter( program =>{
           return program.program_id === this.selectedProgram && program.district_id === this.selectedDist
        })
         

        // this.getCollectionDropDown(this.selectedDistData);
        this.reportData = this.selectedDistData;
        this.createLineChart(this.selectedDistData);
        document.getElementById("spinner").style.display = "none";
      }else if(this.courseSelected === true && this.programSelected !== true ) {
        //  this.courseSelected = false;
        this.selectedDistData = [];
        this.selectedDistWiseCourse = [];
        this.selectedDistData = this.distData.filter((collection) => {
          return collection.district_id === this.selectedDist;
        });
        this.selectedDistWiseCourse = this.selectedDistData.filter(
          (collection) => {
            return collection.collection_id === this.selectedCourse; 
          }
        );

       
        this.createLineChart(this.selectedDistWiseCourse);
        this.reportData = this.selectedDistWiseCourse;
        document.getElementById("spinner").style.display = "none";
        }else {
        
        this.selectedCourse = "";
        this.selectedDistData = []
        this.selectedDistData = this.distData[this.selectedDist];
          this.getCollectionDropDown(this.selectedDistData);
        
        // this.getCollectionDropDown(this.selectedDistData);
        this.reportData = this.selectedDistData;
        setTimeout(() => {
          document.getElementById("spinner").style.display = "display";
        }, 200);
        this.createLineChart(this.selectedDistData);
        document.getElementById("spinner").style.display = "none";
      }
    } catch (error) {}
  }

  public selectedProgram;
  public selectedProgData;
  public programSelected = false;

  onProgramSelected(progId) {
    this.programSelected = true;
    this.courseSelected = false;
    this.selectedProgData = [];
    this.selectedDist = "";
    this.selectedCourse = "";
    this.uniqueDistCourse = [];
    this.uniqueAllCourse = [];
    this.level = "program";
    this.selectedProgram = progId;
    this.selectedProgData = this.programData.filter((program) => {
      return program.program_id === this.selectedProgram;
    });
    this.createLineChart(this.selectedProgData);
    this.reportData = this.selectedProgData;
    this.getProgramWiseColl(this.selectedProgram);
  }

  public selectedCourseData: any[];
  public courseSelected = false;

  onCourseSelected(courseId) {
    this.courseSelected = true;
    this.districtHidden = false;
    this.selectedDist = '';
    this.emptyChart();
    this.selectedCourseData = [];
    this.selectedCourse = courseId;
    // document.getElementById("spinner").style.display = "display";
    if (this.level === "district") {
      
      this.distWiseCourse.forEach((course) => {
        if (course.collection_id === this.selectedCourse) {
          this.selectedCourseData.push(course);
        }
      });

      this.createLineChart(this.selectedCourseData);
      // document.getElementById("spinner").style.display = "none";
    } else if (this.level === "allCourse") {
      this.allCollection.forEach((course) => {
        if (course.collection_id === this.selectedCourse) {
          this.selectedCourseData.push(course);
        }
      });
      this.createLineChart(this.selectedCourseData);
      // document.getElementById("spinner").style.display = "none";
    } else if (this.level === "program") {
      this.selectedCourseData = []
      this.programWiseCourse.forEach((course) => {
        if (course.collection_id === this.selectedCourse) {
          this.selectedCourseData.push(course);
        }
      });
      this.createLineChart(this.selectedCourseData);
      // document.getElementById("spinner").style.display = "none";
    }


    // this.programWiseCourse.forEach((course) => {
    //       if (course.collection_id === this.selectedCourse) {
    //         this.selectedCourseData.push(course);
    //       }
    //     });
    //     this.createLineChart(this.selectedCourseData);

    //  this.createLineChart(this.selectedCourseData)
  }

  //filter downloadable data
  dataToDownload = [];
  newDownload(element) {
    var data1 = {},
      data2 = {},
      data3 = {};
    Object.keys(element).forEach((key) => {
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
    this.reportData.forEach((element) => {
      this.newDownload(element);
    });
    this.commonService.download(this.fileName, this.dataToDownload);
  }

  getLineChart() {
    let tickIntervlMonth = 1;
    if (this.category.length > 30 && this.category.length < 60) {
      tickIntervlMonth = 2;
    } else if (this.category.length > 60 && this.category.length < 90) {
      tickIntervlMonth = 3;
    } else if (this.category.length > 90 && this.category.length < 120) {
      tickIntervlMonth = 4;
    } else if (this.category.length > 120) {
      tickIntervlMonth = 7;
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
          style: {
            fontWeight: "bold",
            color: "#000",
            fontSize: "12px",
          },
        },
      },

      xAxis: {
        title: {
          text: "Days",
          style: {
            fontWeight: "bold",
            color: "#000",
            fontSize: "12px",
          },
        },
        type: "datetime",
        tickInterval: tickIntervlMonth,

        // categories: this.category,
        categories: this.category.map((date) => {
          return Highcharts.dateFormat("%d-%b-%Y", new Date(date).getTime());
        }),
      },
      credits: {
        enabled: false,
      },
      tooltip: {
        formatter: function () {
          return `
               <b> Date:${this.x}</b></br>
               <b> Expected Enrollment: ${this.points[0].y.toLocaleString(
                 "en-IN"
               )}</b></br>
               <b> Net Enrolled: ${this.points[1].y.toLocaleString("en-IN")}</b>
          `;
        },
        shared: true,
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
        },
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
