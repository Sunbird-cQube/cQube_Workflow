import { Component, HostListener, OnInit } from "@angular/core";
import * as Highcharts from "highcharts/highstock";
import HeatmapModule from "highcharts/modules/heatmap";
HeatmapModule(Highcharts);
import { AppServiceComponent } from "../../../app.service";
import { Router } from "@angular/router";
import { HttpClient } from "@angular/common/http";
import { PatReportService } from "../../../services/pat-report.service";
import { environment } from "src/environments/environment";
declare const $;

@Component({
  selector: "app-heat-chart",
  templateUrl: "./heat-chart.component.html",
  styleUrls: ["./heat-chart.component.css"],
})
export class HeatChartComponent implements OnInit {
  Highcharts: typeof Highcharts = Highcharts;
  name: string;
  level = "";
  public waterMark = environment.water_mark

  blockHidden = true;
  clusterHidden = true;
  height = window.screen.height;
  width = screen.width;
  innerWidth = screen.availWidth;

  // For filter implementation
  districtNames = [];
  district;
  blockNames = [];
  block;
  clusterNames = [];
  cluster;

  years = [];
  months = [];
  grades = [];
  subjects = [];
  examDates = [];
  allViews = [];

  public year = "";
  public month = "";
  public grade = "all";
  public subject = "all";
  public examDate = "all";
  public viewBy = "indicator";

  //to set hierarchy level
  skul = true;
  dist = false;
  blok = false;
  clust = false;

  gradeSelected = false;

  // to set hierarchy values
  districtHierarchy: any;
  blockHierarchy: any;
  clusterHierarchy: any;

  chartObject: Highcharts.Chart = null;
  data;

  // to download the excel report
  public fileName: any = ``;
  public reportData: any = [];

  public metaData: any;
  myData;
  state: string;

  //For pagination.....
  items = [];
  pageOfItems: Array<any>;
  pageSize = 40;
  currentPage = 1;

  reportName = "periodic_assesment_test_heatmap";
  screenWidth: number;

  managementName;
  management;
  category;

  @HostListener("window:resize", ["$event"])
  onResize(event) {
    this.screenWidth = window.innerWidth;
    this.resetFontSizesOfChart();
  }

  getHeight(event) {
    this.height = event.target.innerHeight;
    this.onChangePage();
  }

  constructor(
    public http: HttpClient,
    public service: PatReportService,
    public commonService: AppServiceComponent,
    public router: Router
  ) {
    this.screenWidth = window.innerWidth;
    service.PATHeatMapMetaData({ report: "pat" }).subscribe(
      (res) => {
        try {
          this.metaData = res["data"];
          for (let i = 0; i < this.metaData.length; i++) {
            this.years.push(this.metaData[i]["academic_year"]);
          }
          this.year = this.years[this.years.length - 1];
          let i;
          for (i = 0; i < this.metaData.length; i++) {
            if (this.metaData[i]["academic_year"] == this.year) {
              this.months = Object.keys(res["data"][i].data.months);
              this.grades = this.metaData[i].data["grades"];
              this.allViews = this.metaData[i].data["viewBy"];
              break;
            }
          }
          this.month = this.months[this.months.length - 1];
          this.examDates = this.metaData[i].data["months"][`${this.month}`][
            "examDate"
          ];
          this.grades = [{ grade: "all" }, ...this.grades.filter((item) => item !== { grade: "all" })];

          this.examDates = [
            { exam_date: "all" },
            ...this.examDates.filter((item) => item !== { exam_date: "all" }),
          ];

          this.fileName = `${this.reportName}_overall_allDistricts_${this.month}_${this.year}_${this.commonService.dateAndTime}`;
          this.commonFunc();
        } catch (e) {
          this.metaData = [];
          this.commonService.loaderAndErr(this.metaData);
        }
      },
      (err) => {
        this.metaData = [];
        this.commonService.loaderAndErr(this.metaData);
      }
    );
  }

  fetchFilters(metaData) {
    let i;
    for (i = 0; i < metaData.length; i++) {
      if (metaData[i]["academic_year"] == this.year) {
        this.months = Object.keys(this.metaData[i].data.months);
        this.grades = metaData[i].data["grades"];
        this.allViews = metaData[i].data["viewBy"];
        break;
      }
    }
    if (!this.months.includes(this.month)) {
      this.month = this.months[this.months.length - 1];
    }
    this.examDates = metaData[i].data["months"][`${this.month}`]["examDate"];
    this.examDates = [
      { exam_date: "all" },
      ...this.examDates.filter((item) => item !== { exam_date: "all" }),
    ];
    this.grades = [
      { grade: "all" },
      ...this.grades.filter((item) => item !== { grade: "all" }),
    ];

  }

  public userAccessLevel = localStorage.getItem("userLevel");
  public hideIfAccessLevel: boolean = false
  public hideAccessBtn: boolean = false

  ngOnInit(): void {
    this.state = this.commonService.state;
    this.managementName = this.management = JSON.parse(
      localStorage.getItem("management")
    ).id;
    this.managementName = this.commonService.changeingStringCases(
      this.managementName.replace(/_/g, " ")
    );
    this.category = JSON.parse(localStorage.getItem("category")).id;
    document.getElementById("accessProgressCard").style.display = "none";
    document.getElementById("backBtn") ? document.getElementById("backBtn").style.display = "none" : "";
    this.getView1();
    if (this.userAccessLevel !== null || this.userAccessLevel !== undefined || this.userAccessLevel !== "State") {
      this.hideIfAccessLevel = true;
    }
    if (this.userAccessLevel === null || this.userAccessLevel === undefined || this.userAccessLevel === "State") {
      this.hideAccessBtn = true;
    }
  }

  onChangePage() {
    let yLabel = this.yLabel.slice(
      (this.currentPage - 1) * this.pageSize,
      (this.currentPage - 1) * this.pageSize + this.pageSize
    );
    let data = this.items.slice(
      this.pageSize * this.xLabel.length * (this.currentPage - 1),
      this.pageSize * this.xLabel.length * this.currentPage
    );
    let tooltipData = this.toolTipData
      ? this.toolTipData.slice(
        this.pageSize * this.xLabel.length * (this.currentPage - 1),
        this.pageSize * this.xLabel.length * this.currentPage
      )
      : [];

    data = data.map((record) => {
      record.y %= this.pageSize;
      return record;
    });

    tooltipData = tooltipData.map((record) => {
      record.y %= this.pageSize;
      return record;
    });

    this.chartFun(
      this.xlab.length > 0 ? this.xlab : this.xLabel,
      this.xLabelId,
      this.ylab.length > 0 ? this.ylab : yLabel,
      this.zLabel,
      data,
      this.a["viewBy"],
      this.level,
      this.xLabel1,
      this.yLabel1,
      tooltipData,
      this.grade
    );

  }

  resetToInitPage() {
    this.fileName = `${this.reportName}_overall_allDistricts_${this.month}_${this.year}_${this.commonService.dateAndTime}`;
    this.resetOnAllGrades();
    this.year = this.years[this.years.length - 1];
    this.commonFunc();
    this.currentPage = 1;


  }

  commonFunc = () => {
    this.commonService.errMsg();
    this.level = "district";
    this.reportData = [];
    this.fetchFilters(this.metaData);
    let a = {
      report: "pat",
      year: this.year,
      month: this.month,
      grade: this.grade == "all" ? "" : this.grade,
      subject_name: this.subject == "all" ? "" : this.subject,
      exam_date: this.examDate == "all" ? "" : this.examDate,
      viewBy: this.viewBy == "indicator" ? "indicator" : this.viewBy,
      management: this.management,
      category: this.category,
    };
    this.month = a.month;
    if (this.myData) {
      this.myData.unsubscribe();
    }
    this.myData = this.service.PATHeatMapAllData(a).subscribe(
      (response) => {
        this.genericFunction(response);
        this.commonService.loaderAndErr(this.reportData);
      },
      (err) => {
        this.reportData = [];
        this.commonService.loaderAndErr(this.reportData);
        if (this.chart && this.chart.axes) {
          this.chart.destroy();
        }
      }
    );
  };

  resetFontSizesOfChart(): void {
    if (this.chart) {
      let xAxis, yAxis, dataLabels, tooltipStyle;

      if (this.screenWidth <= 1920) {
        xAxis = {
          fontSize: "12px",
        };

        yAxis = {
          fontSize: "12px",
        };

        dataLabels = {
          fontSize: "11px",
        };

        tooltipStyle = {
          fontSize: "12px",
        };
      } else if (this.screenWidth > 1920 && this.screenWidth < 3840) {
        xAxis = {
          fontSize: "1.2rem",
        };

        yAxis = {
          fontSize: "1.2rem",
        };

        dataLabels = {
          fontSize: "1.1rem",
        };

        tooltipStyle = {
          fontSize: "1.2rem",
        };
      } else {
        xAxis = {
          fontSize: "1.6rem",
        };

        yAxis = {
          fontSize: "1.6rem",
        };

        dataLabels = {
          fontSize: "1.5rem",
        };

        tooltipStyle = {
          fontSize: "1.6rem",
        };
      }

      Highcharts.setOptions({
        xAxis: {
          labels: {
            style: {
              fontSize: xAxis.fontSize,
            },
          },
        },
      });
    }
  }

  chart;
  chartFun = (
    xLabel,
    xLabelId,
    yLabel,
    zLabel,
    data,
    viewBy,
    level,
    xLabel1,
    yLabel1,
    tooltipData,
    grade
  ) => {
    let scrollBarX;
    let scrollBarY;
    let xAxis, yAxis, dataLabels, tooltipStyle;

    var yAxisLabel;
    if (this.grade != "all") {
      yAxisLabel = yLabel
        .map(a => {
          return a.substring(1, 30)
        })
    } else {
      yAxisLabel = yLabel;
    }

    if (this.screenWidth <= 1920) {
      xAxis = {
        fontSize: "12px",
      };

      yAxis = {
        fontSize: "12px",
      };

      dataLabels = {
        fontSize: "11px",
      };

      tooltipStyle = {
        fontSize: "12px",
      };
    } else if (this.screenWidth > 1920 && this.screenWidth < 3840) {
      xAxis = {
        fontSize: "1.2rem",
      };

      yAxis = {
        fontSize: "1.2rem",
      };

      dataLabels = {
        fontSize: "1.1rem",
      };

      tooltipStyle = {
        fontSize: "1.2rem",
      };
    } else {
      xAxis = {
        fontSize: "1.6rem",
      };

      yAxis = {
        fontSize: "1.6rem",
      };

      dataLabels = {
        fontSize: "1.5rem",
      };

      tooltipStyle = {
        fontSize: "1.6rem",
      };
    }

    if (xLabel1.length <= 30) {
      scrollBarX = false;
    } else {
      scrollBarX = true;
    }
    var scrollLimit =
      this.height > 800
        ? 16
        : this.height > 650 && this.height < 800
          ? 12
          : this.height < 500
            ? 8
            : 12;
    if (yLabel1.length <= scrollLimit) {
      scrollBarY = false;
    } else {
      scrollBarY = true;
    }
    for (let i = 0; i < xLabel.length; i++) {
      xLabel[i] = xLabel[i].substr(0, 15);
    }
    this.chart = Highcharts.chart("container", {
      chart: {
        type: "heatmap",
      },
      credits: {
        enabled: false,
      },
      exporting: {
        enabled: false
      },
      legend: {
        enabled: false,
      },
      xAxis: [
        {
          categories: [],
          labels: {
            rotation: 270,
            style: {
              color: "black",
              fontSize: "14px",
            },
            enabled: false,
          },
          lineColor: "#FFFFFF",
          gridLineColor: "transparent",
          min: 0,
          max: 30,
          scrollbar: {
            enabled: scrollBarX,
          },
          showLastLabel: false,
          tickLength: 16,
        },
        {
          lineColor: "#FFFFFF",
          linkedTo: 0,
          opposite: true,
          categories: xLabel,
          gridLineColor: "transparent",
          labels: {
            rotation: 270,
            style: {
              color: "black",
              fontSize: xAxis.fontSize,
              fontFamily: "Arial",
            },
          },

        },
      ],
      yAxis: {
        categories: yAxisLabel,
        labels: {
          style: {
            color: "black",
            fontSize: yAxis.fontSize,
            textDecoration: "underline",
            textOverflow: "ellipsis",
            fontFamily: "Arial",
          },
          align: "right",
          formatter: function (this) {
            return this.value !== this.pos ? `${this.value}` : "";
          },
        },
        gridLineColor: "transparent",
        title: null,
        reversed: true,
        min: 0,
        max: scrollLimit - 1,
        scrollbar: {
          enabled: scrollBarY,
        },
      },
      colorAxis: {
        min: 0,
        minColor: "#ff3300",
        maxColor: "#99ff99",
        // maxColor: Highcharts.getOptions().colors[0]
      },
      series: [
        {
          turboThreshold: data.length + 100,
          data: data,
          dataLabels: {
            enabled: true,
            color: "#000000",
            style: {
              textOutline: "none",
              fontSize: dataLabels.fontSize,
            },
            overflow: false,
            crop: true,
          },
          type: "heatmap",
        },
      ],
      title: {
        text: null,
      },
      tooltip: {
        style: {
          fontSize: tooltipStyle.fontSize,
        },
        formatter: function () {
          return (
            "<b>" +
            getPointCategoryName(this.point, "y", viewBy, level, grade) +
            "</b>"
          );
        },
      },
    });

    function getPointCategoryName(point, dimension, viewBy, level, grades) {
     
      var series = point.series,
        isY = dimension === "y",
        axis = series[isY ? "yAxis" : "xAxis"];
      let totalSchools;
      let totalStudents;
      let studentAttended;
      let indicator;
      let grade;
      let subject;
      let exam_date;
      let name;
      let marks;
      tooltipData.map((a) => {
        if (point.x == a.x && point.y == a.y) {
          totalSchools = a.total_schools;
          totalStudents = a.total_students;
          studentAttended = a.students_attended;
          grade = a.grade;
          subject = a.subject;
          exam_date = a.exam_date;
          if (viewBy == "indicator") {
            indicator = a.indicator;
          } else {
            indicator = a.qusetion_id;
          }
          name = a.name;
          marks = a.mark;
        }
      });

      var obj = "";
      if (level == "district") {
        obj = `<b>District Name: ${name}</b>`;
      }

      if (level == "block") {
        obj = `<b>Block Name: ${name}</b>`;
      }

      if (level == "cluster") {
        obj = `<b>ClusterName: ${name}</b>`;
      }

      if (level == "school") {
        obj = `<b>SchoolName: ${name}</b>`;
      }


      obj += `<br> <b>Grade: ${grade}</b>
        <br> <b>Subject: ${subject}</b>
        <br> <b>Exam Date: ${exam_date}</b>
        <br> ${grades != "all"
          ? viewBy == "indicator"
            ? `<b>Indicator: ${indicator}`
            : `<b>QuestionId: ${indicator}</b>`
          : ""
        }
        <br> <b>Total Schools: ${totalSchools ? totalSchools.toString().replace(/(\d)(?=(\d\d)+\d$)/g, "$1,") : "0"}</b>
        <br> <b>Total Students: ${totalStudents ? totalStudents.toString().replace(/(\d)(?=(\d\d)+\d$)/g, "$1,") : "0"}</b>
        <br> <b>Students Attended: ${studentAttended ? studentAttended.toString().replace(/(\d)(?=(\d\d)+\d$)/g, "$1,") : "0"}</b>
        <br> ${marks !== null ? `<b>Marks: ${marks}` : ""}</b>
        <br> ${point.value !== null
          ? `<b>Marks Percentage: ${point.value}` + "%"
          : ""
        }</b>`;
      return obj;
    }
  };

  selectedYear() {

    this.month = "";
    this.examDate = "all";
    this.subject = "all";
    this.fetchFilters(this.metaData);
    this.levelWiseFilter();
  }

  selectedMonth() {
    this.fileName = `${this.reportName}_${this.grade}_allDistricts_${this.month}_${this.year}_${this.commonService.dateAndTime}`;
    this.fetchFilters(this.metaData);
    this.grade = "all";
    this.examDate = "all";
    this.subject = "all";

    this.levelWiseFilter();
  }
  selectedGrade() {
    if (!this.month && this.month === "") {
      alert("Please select month!");
    } else {
      this.fileName = `${this.reportName}_${this.grade}_allDistricts_${this.month}_${this.year}_${this.commonService.dateAndTime}`;
      if (this.grade !== "all") {
        this.subjects = this.grades.find(a => { return a.grade == this.grade }).subjects;
        this.subjects = ["all", ...this.subjects.filter((item) => item !== "all")];
        this.gradeSelected = true;
      } else {
        this.resetOnAllGrades();
      }
      this.levelWiseFilter();
    }
  }

  resetOnAllGrades() {
    this.level = "district";
    this.skul = true;
    this.dist = false;
    this.blok = false;
    this.clust = false;
    this.grade = "all";
    this.examDate = "all";
    this.subject = "all";
    this.viewBy = "indicator";
    this.gradeSelected = false;
    this.district = undefined;
    this.block = undefined;
    this.cluster = undefined;
    this.blockHidden = true;
    this.clusterHidden = true;
  }

  selectedSubject() {
    if (!this.month && this.month === "") {
      alert("Please select month!");
    } else {
      this.fileName = `${this.reportName}_${this.grade}_${this.subject}_allDistricts_${this.month}_${this.year}_${this.commonService.dateAndTime}`;
      this.levelWiseFilter();
    }
  }

  selectedExamDate() {
    if (!this.month && this.month === "") {
      alert("Please select month!");
    } else {
      this.fileName = `${this.reportName}_${this.grade}_${this.examDate}_allDistricts_${this.month}_${this.year}_${this.commonService.dateAndTime}`;
      this.levelWiseFilter();
    }
  }

  selectedViewBy() {
    if (!this.month && this.month === "") {
      alert("Please select month!");
    } else {
      this.fileName = `${this.reportName}_${this.grade}_${this.viewBy}_allDistricts_${this.month}_${this.year}_${this.commonService.dateAndTime}`;
      this.levelWiseFilter();
    }
  }

  selectedDistrict(districtId) {
    if (!this.month && this.month === "") {
      alert("Please select month!");
      this.dist = false;
      this.district = "";
      $("#district").val("");
    } else {
      this.currentPage = 1;
      this.level = "block";
      this.fileName = `${this.reportName}_${this.grade}_${this.level}s_of_district_${districtId}_${this.month}_${this.year}_${this.commonService.dateAndTime}`;
      this.block = undefined;
      this.cluster = undefined;
      this.blockHidden = false;
      this.clusterHidden = true;

      this.commonService.errMsg();
      this.reportData = [];

      let a = {
        report: "pat",
        year: this.year,
        month: this.month,
        grade: this.grade == "all" ? "" : this.grade,
        subject_name: this.subject == "all" ? "" : this.subject,
        exam_date: this.examDate == "all" ? "" : this.examDate,
        viewBy: this.viewBy == "indicator" ? "indicator" : this.viewBy,
        districtId: districtId,
        management: this.management,
        category: this.category,
      };

      this.service.PATHeatMapDistData(a).subscribe(
        (response) => {
          this.genericFunction(response);
          var dist = this.districtNames.find(
            (a) => a.district_id == districtId
          );
          this.districtHierarchy = {
            districtName: dist?.district_name,
            distId: dist?.district_id,
          };
          this.skul = false;
          this.dist = true;
          this.blok = false;
          this.clust = false;
          this.commonService.loaderAndErr(this.reportData);
        },
        (err) => {
          this.reportData = [];
          this.commonService.loaderAndErr(this.reportData);
          if (this.chart && this.chart.axes) {
            this.chart.destroy();
          }
        }
      );
    }
  }

  selectedBlock(blockId) {
    if (!this.month && this.month === "") {
      alert("Please select month!");
      this.blok = false;
      this.block = "";
      $("#block").val("");
    } else {
      this.currentPage = 1;
      this.level = "cluster";
      this.fileName = `${this.reportName}_${this.grade}_${this.level}s_of_block_${blockId}_${this.month}_${this.year}_${this.commonService.dateAndTime}`;
      this.cluster = undefined;
      this.blockHidden = false;
      this.clusterHidden = false;

      this.commonService.errMsg();
      this.reportData = [];

      let a = {
        report: "pat",
        year: this.year,
        month: this.month,
        grade: this.grade == "all" ? "" : this.grade,
        subject_name: this.subject == "all" ? "" : this.subject,
        exam_date: this.examDate == "all" ? "" : this.examDate,
        viewBy: this.viewBy == "indicator" ? "indicator" : this.viewBy,
        districtId: this.district,
        blockId: blockId,
        management: this.management,
        category: this.category,
      };

      this.service.PATHeatMapBlockData(a).subscribe(
        (response) => {
          this.genericFunction(response);
          var block = this.blockNames.find((a) => a.block_id == blockId);

          this.blockHierarchy = {
            districtName: block?.district_name,
            distId: block?.district_id,
            blockName: block?.block_name,
            blockId: block?.block_id,
          };

          this.skul = false;
          this.dist = false;
          this.blok = true;
          this.clust = false;
          this.commonService.loaderAndErr(this.reportData);
        },
        (err) => {
          this.reportData = [];
          this.commonService.loaderAndErr(this.reportData);
          if (this.chart && this.chart.axes) {
            this.chart.destroy();
          }
        }
      );
    }
  }

  selectedCluster(clusterId) {
    if (!this.month && this.month === "") {
      alert("Please select month!");
      this.clust = false;
      this.cluster = "";
      $("#cluster").val("");
    } else {
      this.currentPage = 1;
      this.level = "school";
      this.fileName = `${this.reportName}_${this.grade}_${this.level}s_of_cluster_${clusterId}_${this.month}_${this.year}_${this.commonService.dateAndTime}`;

      this.commonService.errMsg();
      this.reportData = [];

      let a = {
        report: "pat",
        year: this.year,
        month: this.month,
        grade: this.grade == "all" ? "" : this.grade,
        subject_name: this.subject == "all" ? "" : this.subject,
        exam_date: this.examDate == "all" ? "" : this.examDate,
        viewBy: this.viewBy == "indicator" ? "indicator" : this.viewBy,
        districtId: this.district,
        blockId: this.block,
        clusterId: clusterId,
        management: this.management,
        category: this.category,
      };

      this.service.PATHeatMapClusterData(a).subscribe(
        (response) => {
          this.genericFunction(response);
          var cluster = this.clusterNames.find(
            (a) => a.cluster_id == clusterId
          );
          this.clusterHierarchy = {
            districtName: cluster?.district_name,
            distId: cluster?.district_id,
            blockName: cluster?.block_name,
            blockId: cluster?.block_id,
            clusterId: cluster?.cluster_id,
            clusterName: cluster?.cluster_name,
          };
          this.skul = false;
          this.dist = false;
          this.blok = false;
          this.clust = true;

          this.commonService.loaderAndErr(this.reportData);
        },
        (err) => {
          this.reportData = [];
          this.commonService.loaderAndErr(this.reportData);
          if (this.chart && this.chart.axes) {
            this.chart.destroy();
          }
        }
      );
    }
  }

  xlab = [];
  ylab = [];
  a = {};
  yLabel = [];
  xLabel = [];
  xLabelId = [];
  zLabel = [];
  xLabel1 = [];
  yLabel1 = [];
  toolTipData: any;
  genericFunction(response) {
    this.reportData = [];
    this.xlab = [];
    this.ylab = [];
    this.a = {
      viewBy: this.viewBy == "indicator" ? "indicator" : this.viewBy,
    };
    this.yLabel = response["result"]["yLabel"];
    this.xLabel = response["result"]["xLabel"];
    this.xLabelId = response["result"]["xLabelId"];
    this.data = response["result"]["data"];
    this.zLabel = response["result"]["zLabel"];
    this.reportData = response["downloadData"];
    if (response["districtDetails"]) {
      let districts = response["districtDetails"];
      this.districtNames = districts.sort((a, b) =>
        a.district_name > b.district_name
          ? 1
          : b.district_name > a.district_name
            ? -1
            : 0
      );
    }
    if (response["blockDetails"]) {
      let blocks = response["blockDetails"];
      this.blockNames = blocks.sort((a, b) =>
        a.block_name > b.block_name ? 1 : b.block_name > a.block_name ? -1 : 0
      );
    }
    if (response["clusterDetails"]) {
      let clusters = response["clusterDetails"];
      this.clusterNames = clusters.sort((a, b) =>
        a.cluster_name > b.cluster_name
          ? 1
          : b.cluster_name > a.cluster_name
            ? -1
            : 0
      );
    }
    if (this.xLabel.length <= 30) {
      for (let i = 0; i <= 30; i++) {
        this.xlab.push(this.xLabel[i] ? this.xLabel[i] : " ");
      }
    }

    if (this.yLabel.length <= 12) {
      for (let i = 0; i <= 12; i++) {
        this.ylab.push(this.yLabel[i] ? this.yLabel[i] : " ");
      }
    }
    this.xLabel1 = this.xLabel;
    this.yLabel1 = this.yLabel;

    this.items = this.data.map((x, i) => x);
    this.toolTipData = response["result"]["tooltipData"];
    this.onChangePage();
  }

  //level wise filter
  levelWiseFilter() {
    this.currentPage = 1;

    if (this.level == "district") {
      this.commonFunc();
    }
    if (this.level == "block") {
      this.selectedDistrict(this.district);
    }
    if (this.level == "cluster") {
      this.selectedBlock(this.block);
    }
    if (this.level == "school") {
      this.selectedCluster(this.cluster);
    }
  }

  selCluster = false;
  selBlock = false;
  selDist = false;
  levelVal = 0;
  hideDist = true

  getView1() {
    let id = localStorage.getItem("userLocation");
    let level = localStorage.getItem("userLevel");
    let clusterid = localStorage.getItem("clusterId");
    let blockid = localStorage.getItem("blockId");
    let districtid = localStorage.getItem("districtId");
    let schoolid = localStorage.getItem("schoolId");


    if (districtid) {
      this.district = districtid;
    }
    if (blockid) {
      this.block = blockid;
    }
    if (clusterid) {
      this.cluster = clusterid;
    }
    if (level === "Cluster") {
      this.selCluster = true;
      this.selBlock = true;
      this.selDist = true;
      this.levelVal = 3;
    } else if (level === "Block") {
      this.selCluster = false;
      this.selBlock = true;
      this.selDist = true;
      this.levelVal = 2;
    } else if (level === "District") {

    } else if (level === null) {
      this.hideDist = false
    }
  }
  getView() {
    let id = localStorage.getItem("userLocation");
    let level = localStorage.getItem("userLevel");
    let clusterid = localStorage.getItem("clusterId");
    let blockid = localStorage.getItem("blockId");
    let districtid = localStorage.getItem("districtId");
    let schoolid = localStorage.getItem("schoolId");

    if (districtid) {
      this.district = districtid;
    }
    if (blockid) {
      this.block = blockid;
    }
    if (clusterid) {
      this.cluster = clusterid;
    }

    if (level === "Cluster") {
      this.district = districtid;
      this.block = blockid;
      this.cluster = clusterid;
      this.selectedBlock(blockid);
      this.selectedCluster(clusterid);
      this.levelVal = 3;
    } else if (level === "Block") {
      this.district = districtid;
      this.block = blockid;
      this.cluster = clusterid;
      this.selectedDistrict(districtid);
      this.selectedBlock(blockid);
      this.levelVal = 2;
    } else if (level === "District") {
      this.district = districtid;
      this.block = blockid;
      this.cluster = clusterid;
      this.selectedDistrict(districtid);
      this.levelVal = 1;
    }
  }

  distlevel(id) {
    this.selCluster = false;
    this.selBlock = false;
    this.selDist = true;
    this.level = "block";
    this.district = id;
    this.levelWiseFilter();
  }

  blocklevel(id) {
    this.selCluster = false;
    this.selBlock = true;
    this.selDist = true;
    this.level = "cluster";
    this.block = id;
    this.levelWiseFilter();
  }

  clusterlevel(id) {
    this.selCluster = true;
    this.selBlock = true;
    this.selDist = true;
    this.level = "school";
    this.cluster = id;
    this.levelWiseFilter();
  }
  // to download the csv report
  downloadReport() {
    var position = this.reportName.length;
    this.fileName = [
      this.fileName.slice(0, position),
      `_${this.management}`,
      this.fileName.slice(position),
    ].join("");
    this.commonService.download(this.fileName, this.reportData);
  }

  public legendColors: any = [
    "#a50026",
    "#d73027",
    "#f46d43",
    "#fdae61",
    "#fee08b",
    "#d9ef8b",
    "#a6d96a",
    "#66bd63",
    "#1a9850",
    "#006837",
  ];
  public values = [
    "0-10",
    "11-20",
    "21-30",
    "31-40",
    "41-50",
    "51-60",
    "61-70",
    "71-80",
    "81-90",
    "91-100",
  ];
}
