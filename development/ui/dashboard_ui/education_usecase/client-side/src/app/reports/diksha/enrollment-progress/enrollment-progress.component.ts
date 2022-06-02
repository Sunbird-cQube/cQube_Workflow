import { ChangeDetectorRef, Component, OnInit } from "@angular/core";
import * as Highcharts from "highcharts/highstock";
import HC_exportData from 'highcharts/modules/export-data';
HC_exportData(Highcharts);
import { AppServiceComponent } from "src/app/app.service";
import { EnrollmentProgressLineChartService } from "src/app/services/enrollment-progress-line-chart.service";
import { ContentUsagePieService } from "src/app/services/content-usage-pie.service";
import { environment } from "src/environments/environment";

@Component({
  selector: "app-enrollment-progress",
  templateUrl: "./enrollment-progress.component.html",
  styleUrls: ["./enrollment-progress.component.css"],
})
export class EnrollmentProgressComponent implements OnInit {
  Highcharts: typeof Highcharts = Highcharts;
  chartOptions;

  public waterMark = environment.water_mark
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
  public districtHidden = true;
  public data
  constructor(
    private changeDetection: ChangeDetectorRef,
    public commonService: AppServiceComponent,
    public service: EnrollmentProgressLineChartService,
    public metaService: ContentUsagePieService
  ) { }

  width = window.innerWidth;
  height = window.innerHeight;
  onResize() {
    this.width = window.innerWidth;
    this.height = window.innerHeight;
  }

  public userAccessLevel = localStorage.getItem("userLevel");
  public hideIfAccessLevel: boolean = false
  public hideAccessBtn: boolean = false

  ngOnInit(): void {
    this.changeDetection.detectChanges();
    this.state = this.commonService.state;
    document.getElementById("accessProgressCard").style.display = "none";
    document.getElementById("backBtn")
      ? (document.getElementById("backBtn").style.display = "none")
      : "";
    if (this.level == "program") {
      setTimeout(() => {
        document.getElementById("spinner").style.display = "none";
      }, 200);
      this.getProgramData();
    }
    this.getExpectedMeta();
    this.getStateData();
    this.getProgramData();
    this.getAllDistCollection();
     this.hideIfAccessLevel = (environment.auth_api === 'cqube' || this.userAccessLevel === "") ? true : false;
    
  }

  emptyChart() {

    this.expectedEnrolled = [];
    this.netEnrolled = [];
    this.category = [];

    this.courseToDropDown = [];

  }

  getStateData() {
    this.fileName = "enrollment-progress-state";
    try {
      this.service.enrollmentProState().subscribe((res) => {
        res['data'] ? this.stateData = res["data"]["data"] : this.stateData = [];
        this.reportData = this.stateData;
        this.createLineChart(this.stateData);
        this.getDistMeta();
        this.commonService.loaderAndErr(this.stateData);
      }, (err) => {
        this.stateData = [];
        this.commonService.loaderAndErr(this.stateData);
      });
    } catch (error) {
      this.stateData = []
      console.log(error)
      this.commonService.loaderAndErr(this.stateData);
    }
  }

  expectedMeta: boolean
  getExpectedMeta() {
    try {
      this.service.enrollExpectedMeta().subscribe(res => {

        this.expectedMeta = res['jsonData'][0].data_is_available
      })
    } catch (error) {
      console.log(error)
    }
  }

  enrollExpectedMeta

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

    try {
      this.service.enrollmentProDist().subscribe((res) => {
        this.distData = res["data"]["data"];
        this.commonService.loaderAndErr(this.distData);
      });
    } catch (error) {
      this.distData = [];
      console.log(error);
      this.commonService.loaderAndErr(this.distData);
    }
  }

  public expectedEnrolled = [];
  public changeInNetEnrollment = [];
  public netEnrolled = [];
  public category = [];

  createLineChart(data) {

    this.chartData = [];
    this.expectedEnrolled = [];
    this.changeInNetEnrollment = [];
    this.netEnrolled = [];
    this.category = [];
    this.chartData = data;
    try {
      this.chartData.forEach((data) => {
        this.expectedEnrolled.push(data.expected_enrollment);
        this.netEnrolled.push(data.net_enrollment);
        this.category.push(data.date);
        this.changeInNetEnrollment.push(data.change_in_net_enrollment)
      });
      this.getLineChart();
    } catch (error) { }
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
        this.data = this.programData = res["data"]["data"]
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
        this.commonService.loaderAndErr(this.programData)
      });
    } catch (error) {
      this.programData = []
      console.log(error)
      this.commonService.loaderAndErr(this.programData)
    }
  }

  getAllDistCollection() {
    this.emptyChart();
    this.courseToDropDown = [];
    this.uniqueDistCourse = [];
    try {

      this.service.enrollProAllCollection().subscribe((res) => {
        res['data'] ? this.allDistCollection = res["data"]["data"] : this.allDistCollection = [];
        this.commonService.loaderAndErr(this.allDistCollection)
      });

    } catch (error) {
      this.allDistCollection = []
      console.log(error)
      this.commonService.loaderAndErr(this.allDistCollection)
    }
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
        this.commonService.loaderAndErr(this.allCollection);
      });
    } catch (error) {
      this.allCollection = []
      console.log(error)
      this.commonService.loaderAndErr(this.allCollection)
    }
  }

  public collectionDropDown;
  getCollectionDropDown(data) {
    this.uniqueAllCourse = []
    this.courseToDropDown = [];
    this.collectionDropDown = data.slice();
    try {

      if (this.level === "district") {
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
      } else if (this.level === "allCourse") {
        this.collectionDropDown.forEach((course) => {
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

      } else if (this.level === 'program') {

        this.collectionDropDown.forEach((course) => {
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
      }

    } catch (error) { }
  }

  public selectedDist;
  public selectedDistData: any;
  public districtName;
  public dist = false;
  public skul = true;
  public selectedDistWiseCourse;

  onDistSelected(distId) {
    document.getElementById("spinner").style.display = "block";
    setTimeout(() => {
      document.getElementById("spinner").style.display = "none";
    }, 1000);

    this.dist = true;
    this.skul = false;
    this.selectedDist = ""
    this.selectedDistData = [];
    this.selectedDistWiseCourse = [];
    this.reportData = [];
    this.emptyChart();
    this.selectedDist = distId;

    this.distToDropDown.filter((district) => {

      if (district.district_id === this.selectedDist) {
        this.districtName = district.district_name;
      }
    });

    try {
      if (this.courseSelected === true && this.programSelected === true) {
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
      } else if (this.programSelected === true && this.courseSelected !== true) {
        this.selectedCourse = "";
        this.selectedDistData = [];
        this.selectedDistData = this.allDistCollection.filter(program => {
          return program.program_id === this.selectedProgram && program.district_id === this.selectedDist
        })
        this.reportData = this.selectedDistData;
        this.createLineChart(this.selectedDistData);
      } else if (this.courseSelected === true && this.programSelected !== true) {

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
      } else {

        this.selectedCourse = "";
        this.selectedDistData = []
        this.selectedDistData = this.distData[this.selectedDist];
        this.getCollectionDropDown(this.selectedDistData);


        this.reportData = this.selectedDistData;

      }
    } catch (error) { }
  }

  public selectedProgram;
  public selectedProgData;
  public programSelected = false;

  onProgramSelected(progId) {
    document.getElementById("spinner").style.display = "block";
    setTimeout(() => {
      document.getElementById("spinner").style.display = "none";
    }, 1000);
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
    document.getElementById("spinner").style.display = "block";
    setTimeout(() => {
      document.getElementById("spinner").style.display = "none";
    }, 1000);
    this.courseSelected = true;
    this.districtHidden = this.hideIfAccessLevel === true ? false : true;
    this.selectedDist = '';
    this.emptyChart();
    this.selectedCourseData = [];
    this.selectedCourse = courseId;

    if (this.level === "district") {

      this.distWiseCourse.forEach((course) => {
        if (course.collection_id === this.selectedCourse) {
          this.selectedCourseData.push(course);
        }
      });

      this.createLineChart(this.selectedCourseData);
      this.reportData = this.selectedCourseData;

    } else if (this.level === "allCourse") {
      this.allCollection.forEach((course) => {
        if (course.collection_id === this.selectedCourse) {
          this.selectedCourseData.push(course);
        }
      });
      this.createLineChart(this.selectedCourseData);
      this.reportData = this.selectedCourseData;
    } else if (this.level === "program") {
      this.selectedCourseData = []
      this.programWiseCourse.forEach((course) => {
        if (course.collection_id === this.selectedCourse) {
          this.selectedCourseData.push(course);
        }
      });
      this.createLineChart(this.selectedCourseData);
      this.reportData = this.selectedCourseData;
    }

  }

  //filter downloadable data
  dataToDownload = [];
  newDownload(element) {
    var data1 = {},
      data2 = {},
      data3 = {};
    Object.keys(element).forEach((key) => {

      data1[key] = element[key];
    });

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
    let tickIntervlMonth
    let changeINEnroll: any = this.changeInNetEnrollment

    if (this.category.length < 30) {
      tickIntervlMonth = 2;
    } else if (this.category.length > 30 && this.category.length < 90) {
      tickIntervlMonth = 5;
    } else if (this.category.length > 90 && this.category.length < 120) {
      tickIntervlMonth = 7;
    } else if (this.category.length > 120) {
      tickIntervlMonth = 15;
    }
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
            fontSize: this.height > 1760 ? "30px" : this.height > 1160 && this.height < 1760 ? "20px" : this.height > 667 && this.height < 1160 ? "12px" : "10px"
          },
        },
        labels: {
          style: {
            fontWeight: "900",
            fontSize: this.height > 1760 ? "30px" : this.height > 1160 && this.height < 1760 ? "20px" : this.height > 667 && this.height < 1160 ? "12px" : "10px"
          }
        },
      },

      xAxis: {
        title: {
          text: "Days",
          style: {
            fontWeight: "bold",
            color: "#000",
            fontSize: this.height > 1760 ? "30px" : this.height > 1160 && this.height < 1760 ? "20px" : this.height > 667 && this.height < 1160 ? "12px" : "10px"
          },
        },

        type: "datetime",
        tickInterval: tickIntervlMonth,

        categories: this.category.map((date) => {
          return Highcharts.dateFormat("%d-%m-%Y", new Date(date).getTime());
        }),
        labels: {
          style: {
            fontWeight: "900",
            fontSize: this.height > 1760 ? "30px" : this.height > 1160 && this.height < 1760 ? "20px" : this.height > 667 && this.height < 1160 ? "12px" : "10px"
          },
          rotation: -20
        },
      },
      credits: {
        enabled: false,
      },
      tooltip: {

        style: {
          fontSize: this.height > 1760 ? "32px" : this.height > 1160 && this.height < 1760 ? "22px" : this.height > 667 && this.height < 1160 ? "12px" : "10px",
          opacity: 1,
          backgroundColor: "white"
        },
        formatter: function () {

          return '<b>' + getPointCategoryName(this.points) + '</b>';
        },

        shared: true,
      },
      legend: {
        itemStyle: {
          fontSize: this.height > 1760 ? "32px" : this.height > 1160 && this.height < 1760 ? "22px" : this.height > 667 && this.height < 1160 ? "12px" : "10px",
        }
      },

      plotOptions: {
        series: {
          stickyTracking: false
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

    };
    this.Highcharts.chart("container", this.chartOptions);

    //Bar tooltips::::::::::::::::::::::
    function getPointCategoryName(point) {

      var obj = '';
      obj = `
               <b> &nbsp;Date:</b>${point[0].x}</br>
               <b> Expected Enrollment: ${point[0].point.options.y.toLocaleString(
        "en-IN"
      )}</b></br>
               <b> Net Enrolled: ${point[1].point.options.y.toLocaleString("en-IN")}</b><br>
               <b> Change in Net Enrollment : ${changeINEnroll[`${point[0].point.index}`].toLocaleString('en-IN')}</b>
          `
      return obj
    }
  }
}
