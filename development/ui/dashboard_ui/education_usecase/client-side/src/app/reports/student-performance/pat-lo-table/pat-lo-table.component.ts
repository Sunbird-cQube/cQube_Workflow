import { Component, OnInit } from "@angular/core";
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
  selector: "app-pat-lo-table",
  templateUrl: "./pat-lo-table.component.html",
  styleUrls: ["./pat-lo-table.component.css"],
})
export class PATLOTableComponent implements OnInit {
  level = "";

  // For filter implementation
  districtNames = [];
  district;
  blockNames = [];
  block;
  clusterNames = [];
  cluster;

  public waterMark = environment.water_mark

  blockHidden = true;
  clusterHidden = true;

  years = [];
  grades = [];
  subjects = [];
  examDates = [];
  allViews = [];

  public year = "";
  public grade = "all";
  public subject = "all";
  public examDate = "all";
  public viewBy = "indicator";

  //to set hierarchy level
  skul = true;
  dist = false;
  blok = false;
  clust = false;

  // to set hierarchy values
  districtHierarchy: any;
  blockHierarchy: any;
  clusterHierarchy: any;

  data;

  // to download the excel report
  public fileName: any = ``;
  public reportData: any = [];

  public metaData: any;
  myData;
  state: string;
  months: string[];
  month: string = "";

  reportName = "periodic_assesment_test_loTable";
  managementName;
  management;
  category;

  //For pagination.....
  pageSize = 200;
  currentPage = 1;
  filteredData = []
  showPagination = false;
  validTransactions: any;
  table: any = undefined;
  updatedTable: any = [];
  gradeSelected: boolean;

  constructor(
    public http: HttpClient,
    public service: PatReportService,
    public commonService: AppServiceComponent,
    public router: Router
  ) {
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
          this.grades = [
            { grade: "all" },
            ...this.grades.filter((item) => item !== { grade: "all" }),
          ];
          this.examDates = [
            { exam_date: "all" },
            ...this.examDates.filter((item) => item !== { exam_date: "all" }),
          ];

          this.fileName = `${this.reportName}_overall_allDistricts_${this.month}_${this.year}_${this.commonService.dateAndTime}`;
          if (environment.auth_api === 'cqube' || this.userAccessLevel === "") {

            this.commonFunc();
          } else {

            this.getView()
          }

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

  public userAccessLevel = localStorage.getItem("userLevel");
  public hideIfAccessLevel: boolean = false
  public hideAccessBtn: boolean = false


  ngOnInit(): void {
    this.managementName = this.management = JSON.parse(localStorage.getItem('management')).id;
    this.category = JSON.parse(localStorage.getItem('category')).id;
    this.managementName = this.commonService.changeingStringCases(
      this.managementName.replace(/_/g, " ")
    );
    this.state = this.commonService.state;
    document.getElementById("accessProgressCard").style.display = "none";
    document.getElementById("backBtn") ? document.getElementById("backBtn").style.display = "none" : "";


    this.hideAccessBtn = (environment.auth_api === 'cqube' || this.userAccessLevel === '') ? true : false;
    this.hideDist = (environment.auth_api === 'cqube' || this.userAccessLevel === '' || undefined) ? false : true;

    if (environment.auth_api !== 'cqube') {

      if (this.userAccessLevel !== "" || undefined) {
        this.hideIfAccessLevel = true;
      }

    }



  }

  hideDist = true;
  height = window.innerHeight;
  onResize() {
    this.height = window.innerHeight;
  }

  onChangePage() {
    document.getElementById('spinner').style.display = 'block';
    this.pageChange();
  }

  pageChange() {
    this.filteredData = this.reportData.slice(((this.currentPage - 1) * this.pageSize), ((this.currentPage - 1) * this.pageSize + this.pageSize));
    this.createTable(this.filteredData);
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

  resetToInitPage() {
    this.resetTable();
    this.fileName = `${this.reportName}_overall_allDistricts_${this.month}_${this.year}_${this.commonService.dateAndTime}`;
    this.skul = true;
    this.dist = false;
    this.blok = false;
    this.clust = false;
    this.grade = "all";
    this.examDate = "all";
    this.subject = "all";
    this.viewBy = "indicator";
    this.district = undefined;
    this.block = undefined;
    this.cluster = undefined;
    this.blockHidden = true;
    this.clusterHidden = true;
    this.year = this.years[this.years.length - 1];
    this.gradeSelected = false;
    if (this.hideAccessBtn) {

      this.commonFunc();
    } else {
      this.getView()
    }

  }

  commonFunc = () => {
    this.commonService.errMsg();
    this.level = "district";
    this.fetchFilters(this.metaData);
    let a = {
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
    this.myData = this.service.patLOTableDistData(a).subscribe(
      (response) => {
        this.resetTable();
        this.updatedTable = this.reportData = response["tableData"];
        var districtNames = response["districtDetails"];
        this.districtNames = districtNames.sort((a, b) =>
          a.district_name > b.district_name
            ? 1
            : b.district_name > a.district_name
              ? -1
              : 0
        );
        this.onChangePage();
      },
      (err) => {
        this.handleError();
      }
    );
  };

  columns = [];
  createTable(dataSet) {

    var level = this.level.charAt(0).toUpperCase() + this.level.substr(1);
    var my_columns = this.columns = this.commonService.getColumns(dataSet);
    
    $(document).ready(function () {
      var headers = "<thead><tr>";
      var body = "<tbody>";
      my_columns.forEach((column, i) => {

        var col = column.data.replace(/_/g, " ").replace(/\w\S*/g, (txt) => {
          return txt.charAt(0).toUpperCase() + txt.substr(1).toLowerCase();
        });

        if (col.length > 10) {
          col = col.slice(0, 10) + "..."
        }
        if (i > 3) {
          headers += `<th class="rank text-wrap"><div style="transform: rotate(270deg);">${col}</div></th>`;
        } else {
          if (col == 'Indicator') {
            headers += `<th class="indicator">${col}</th>`;
          } else {
            headers += `<th>${col}</th>`;
          }
        }
      });

      let newArr = [];
      $.each(dataSet, function (a, b) {
        let temp = [];
        $.each(b, function (key, value) {
          var new_item = {};
          new_item["data"] = key;
          new_item["value"] = typeof (value) != 'object' ? value : value.percentage;
          new_item["mark"] = typeof (value) != 'object' ? '' : value.mark;
          temp.push(new_item);
        });
        newArr.push(temp);
      });

      function tableCellColor(data) {
        var colors = {
          10: '#a50026',
          20: '#d73027',
          30: '#f46d43',
          40: '#fdae61',
          50: '#fee08b',
          60: '#d9ef8b',
          70: '#a6d96a',
          80: '#66bd63',
          90: '#1a9850',
          100: '#006837'
        }
        var keys = Object.keys(colors);
        var setColor = '';
        for (let i = 0; i < keys.length; i++) {
          if (data <= parseInt(keys[i])) {
            setColor = colors[keys[i]];
            break;
          } else if (data > parseInt(keys[i]) && data <= parseInt(keys[i + 1])) {
            setColor = colors[keys[i + 1]];
            break;
          }
        }
        return setColor;
      }
      function toTitleCase(phrase) {
        var key = phrase
          .toLowerCase()
          .split(' ')
          .map(word => word.charAt(0).toUpperCase() + word.slice(1))
          .join(' ');
        return key;
      }
      newArr.forEach((columns, i1) => {
        body += "<tr>";
        columns.forEach((column, i2) => {
          if (i2 > 3 && column.value || i2 > 3 && String(column.value) == String(0)) {
            let title = `${level} Name: ${column.data}<br/> Date: ${columns[0].value} <br/> Grade: ${columns[1].value[columns[1].value.length - 1]} <br/> Subject: ${columns[2].value} <br/> ${toTitleCase(columns[3].data.replace('_', ' '))}: ${columns[3].value} <br/>Marks: ${column.mark}`;
            body += `<td class="numberData" data-toggle="tooltip" data-html="true" data-placement="auto" style='background-color: ${tableCellColor(column.value)}' title="${title}">${column.value}</td>`;
          }
          else {
            if (column.data == 'indicator') {
              body += `<td class="indicator" style="min-width: 170px">${column.value.substring(0, 30)}</td>`;
            } else {
              if (column.data == 'date') {
                var date = column.value.split("-");
                body += `<td>${date[0]}</td>`;
              } else if (column.data == 'grade') {
                body += `<td>${column.value[column.value.length - 1]}</td>`;
              } else {
                body += `<td>${column.value}</td>`;
              }
            }
          }
        });
        body += "</tr>";
      });

      headers += `</tr></thead>`;
      body += "</tbody>";
      $(`#LOtable`).empty();
      $(`#LOtable`).append(headers);
      $(`#LOtable`).append(body);

      var obj =
      {
        destroy: true,
        bInfo: false,
        bPaginate: false,
        scrollY: "54vh",
        scrollX: true,
        scrollCollapse: true,
        displayLength: 10,
        searching: false
      }
      if (dataSet.length > 0) {
        obj['order'] = [[0, "asc"]];
        obj['columnDefs'] = [{ targets: 0, type: "date-dd-mm-yyyy" }, { className: "dt-head-center" }];
      }

      this.table = $(`#LOtable`).DataTable(obj);
      $('[data-toggle="tooltip"]').tooltip({

        placement: 'right',

        container: 'body'
      }
      ).on('inserted.bs.tooltip', function () {
        $("body div.tooltip-inner").css({
          "min-width": `${innerWidth < 2540 ? "200px" : '300px'}`,
          "max-width": `${innerWidth < 2540 ? "600px" : '900px'}`,
          "padding": `${innerWidth < 2540 ? '10px' : '15px'}`,
          "text-align": "auto",
          "border-radius": `${innerWidth < 2540 ? '20px' : '30px'}`,
          "background-color": "black",
          "color": "white",
          "font-family": "Arial",
          "font-size": `${innerWidth < 2540 ? '11px' : '26px'}`,
          "border": "1px solid gray",
          "z-index": 900
        });
      });
      $('[data-toggle="tooltip"]').click(function () {
        $('[data-toggle="tooltip"]').tooltip("hide");
      });

      $(document).ready(function () {
        $('#LOtable').on('page.dt', function () {
          $('.dataTables_scrollBody').scrollTop(0);
        });
      }, 300);
      $('select').on('keydown', function (e) {
        if (e.keyCode === 37 || e.keyCode === 38 || e.keyCode === 39 || e.keyCode === 40) { //up or down
          e.preventDefault();
          return false;
        }
      });
      if (this.table)
        document.getElementById('spinner').style.display = 'none';
    });
    this.showPagination = true;
  }

  selectedYear() {

    this.month = "";
    this.grade = "all";
    this.examDate = "all";
    this.subject = "all";
    this.fetchFilters(this.metaData);
    if (this.hideAccessBtn) {
      this.levelWiseFilter();

    } else {
      this.getView()
    }
  }

  selectedMonth() {
    this.fileName = `${this.reportName}_${this.grade}_allDistricts_${this.month}_${this.year}_${this.commonService.dateAndTime}`;
    this.fetchFilters(this.metaData);
    this.grade = "all";
    this.examDate = "all";
    this.subject = "all";

    if (this.hideAccessBtn) {
      this.levelWiseFilter();

    } else {
      this.getView()
    }
  }

  selectedGrade() {
    if (!this.month && this.month === '') {
      alert("Please select month!");
      return;
    } else {
      this.fileName = `${this.reportName}_${this.grade}_allDistricts_${this.month}_${this.year}_${this.commonService.dateAndTime}`;
      if (this.grade !== "all") {
        this.subjects = this.grades.find(a => { return a.grade == this.grade }).subjects;
        this.subjects = ["all", ...this.subjects.filter((item) => item !== "all")];
        this.gradeSelected = true;
      } else {
        this.grade = "all";
        
          this.resetToInitPage();
       
      }
      if (this.hideAccessBtn) {
        this.levelWiseFilter();
      } else {
        this.getView()
        
      }

    }
  }

  selectedSubject() {
    if (!this.month && this.month === '') {
      alert("Please select month!");
      return;
    }

    this.fileName = `${this.reportName}_${this.grade}_${this.subject}_allDistricts_${this.month}_${this.year}_${this.commonService.dateAndTime}`;
    if (this.hideAccessBtn) {
      this.levelWiseFilter();

    } else {
      this.getView()
    }
  }

  selectedExamDate() {
    if (!this.month && this.month === '') {
      alert("Please select month!");
      return;
    }

    this.fileName = `${this.reportName}_${this.grade}_${this.examDate}_allDistricts_${this.month}_${this.year}_${this.commonService.dateAndTime}`;
    if (this.hideAccessBtn) {
      this.levelWiseFilter();

    } else {
      this.getView()
    }
  }

  selectedViewBy() {
    if (!this.month && this.month === '') {
      alert("Please select month!");
      return;
    }

    this.fileName = `${this.reportName}_${this.grade}_${this.viewBy}_allDistricts_${this.month}_${this.year}_${this.commonService.dateAndTime}`;
    if (this.hideAccessBtn) {
      this.levelWiseFilter();

    } else {
      this.getView()
    }
  }

  selectedDistrict(districtId, blockId?) {
    if (!this.month && this.month === '') {
      alert("Please select month!");
      this.district = '';
      this.dist = false;
      $('#district').val('');
      return;
    }

    this.resetTable();
    this.level = "block";
    this.fileName = `${this.reportName}_${this.grade}_${this.level}s_of_district_${districtId}_${this.month}_${this.year}_${this.commonService.dateAndTime}`;
    this.block = undefined;
    this.cluster = undefined;
    this.blockHidden = false;
    this.clusterHidden = true;

    this.commonService.errMsg();

    let a = {
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

    this.service.patLOTableBlockData(a).subscribe(
      (response) => {
        this.updatedTable = this.reportData = response["tableData"];
        var blockNames = response["blockDetails"];
        this.blockNames = blockNames.sort((a, b) =>
          a.block_name > b.block_name ? 1 : b.block_name > a.block_name ? -1 : 0
        );

        this.onChangePage();
        var dist = this.districtNames.find((a) => a.district_id == districtId);
        this.districtHierarchy = {
          districtName: dist?.district_name,
          distId: dist?.district_id,
        };
        this.skul = false;
        this.dist = true;
        this.blok = false;
        this.clust = false;
        if (blockId) {
          this.selectedBlock(blockId)
        }

      },
      (err) => {
        this.handleError();
      }
    );
  }

  selectedBlock(blockId) {
    if (!this.month && this.month === '') {
      alert("Please select month!");
      this.block = '';
      this.blok = false;
      $('#block').val('');
      return;
    }

    this.resetTable();
    this.level = "cluster";
    this.fileName = `${this.reportName}_${this.grade}_${this.level}s_of_block_${blockId}_${this.month}_${this.year}_${this.commonService.dateAndTime}`;
    this.cluster = undefined;
    this.blockHidden = this.selBlock ? true : false;
    this.clusterHidden = false;

    this.commonService.errMsg();

    let a = {
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

    this.service.patLOTableClusterData(a).subscribe(
      (response) => {
        this.updatedTable = this.reportData = response["tableData"];
        var clusterNames = response["clusterDetails"];
        this.clusterNames = clusterNames.sort((a, b) =>
          a.cluster_name > b.cluster_name
            ? 1
            : b.cluster_name > a.cluster_name
              ? -1
              : 0
        );
        this.onChangePage();

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
      },
      (err) => {
        this.handleError();
      }
    );
  }

  selectedCluster(clusterId) {
    if (!this.month && this.month === '') {
      alert("Please select month!");
      this.cluster = '';
      this.clust = false;
      $('#cluster').val('');
      return;
    }

    this.resetTable();
    this.level = "school";
    this.fileName = `${this.reportName}_${this.grade}_${this.level}s_of_cluster_${clusterId}_${this.month}_${this.year}_${this.commonService.dateAndTime}`;

    this.commonService.errMsg();
    let a = {
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
      schoolLevel: this.schoolLevel,
      schoolId: Number(localStorage.getItem('schoolId'))
    };

    this.service.patLOTableSchoolData(a).subscribe(
      (response) => {

        this.updatedTable = this.reportData = response["tableData"];
        this.onChangePage();

        var cluster = this.clusterNames.find((a) => a.cluster_id == clusterId);
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

        this.blockHidden = this.selBlock ? true : false;
        this.clusterHidden = this.selCluster ? true : false;
      },
      (err) => {
        this.handleError();
      }
    );
  }

  //resetting table
  resetTable() {
    if ($.fn.DataTable.isDataTable("#LOtable")) {
      this.reportData = [];
      $("#LOtable").DataTable().destroy();
      $("#LOtable").empty();
    }
  }

  //level wise filter
  levelWiseFilter() {
    document.getElementById("initTable").style.display = "block";

    if (this.level == "district") {
      this.resetTable();
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
  hideblock = false
  schoolLevel = false
  getView() {
    let id = localStorage.getItem("userLocation");
    let level = localStorage.getItem("userLevel");
    let clusterid = localStorage.getItem("clusterId");
    let blockid = localStorage.getItem("blockId");
    let districtid = localStorage.getItem("districtId");
    let schoolid = localStorage.getItem("schoolId");
    this.schoolLevel = level === "School" ? true : false
    if (districtid) {
      this.district = districtid;
    }
    if (blockid) {
      this.district = districtid;
      this.block = blockid;
    }
    if (clusterid) {
      this.district = districtid;
      this.block = blockid;
      this.cluster = clusterid;

    }


    if (level === "School") {
      this.district = districtid;
      this.block = blockid;
      this.cluster = clusterid;

      let a = {
        year: this.year,
        month: this.month,
        grade: this.grade == "all" ? "" : this.grade,
        subject_name: this.subject == "all" ? "" : this.subject,
        exam_date: this.examDate == "all" ? "" : this.examDate,
        viewBy: this.viewBy == "indicator" ? "indicator" : this.viewBy,
        districtId: this.district,
        blockId: blockid,
        management: this.management,
        category: this.category,
      };

      this.service.patLOTableClusterData(a).subscribe(
        (response) => {
          this.updatedTable = this.reportData = response["tableData"];
          var clusterNames = response["clusterDetails"];
          this.clusterNames = clusterNames.sort((a, b) =>
            a.cluster_name > b.cluster_name
              ? 1
              : b.cluster_name > a.cluster_name
                ? -1
                : 0
          );
          this.selectedCluster(clusterid);
        })

      this.clusterHidden = true
      this.blockHidden = true
      this.selCluster = true;
      this.selBlock = true;
      this.selDist = true;
      this.levelVal = 3;
    } else if (level === "Cluster") {
      this.district = districtid;
      this.block = blockid;
      this.cluster = clusterid;

      let a = {
        year: this.year,
        month: this.month,
        grade: this.grade == "all" ? "" : this.grade,
        subject_name: this.subject == "all" ? "" : this.subject,
        exam_date: this.examDate == "all" ? "" : this.examDate,
        viewBy: this.viewBy == "indicator" ? "indicator" : this.viewBy,
        districtId: this.district,
        blockId: blockid,
        management: this.management,
        category: this.category,
      };

      this.service.patLOTableClusterData(a).subscribe(
        (response) => {
          this.updatedTable = this.reportData = response["tableData"];
          var clusterNames = response["clusterDetails"];
          this.clusterNames = clusterNames.sort((a, b) =>
            a.cluster_name > b.cluster_name
              ? 1
              : b.cluster_name > a.cluster_name
                ? -1
                : 0
          );
          this.selectedCluster(clusterid);
        })

      this.clusterHidden = true
      this.blockHidden = true
      this.selCluster = true;
      this.selBlock = true;
      this.selDist = true;
      this.levelVal = 3;
    } else if (level === "Block") {
      this.district = districtid;
      this.block = blockid;
      this.hideblock = true

      let a = {
        year: this.year,
        month: this.month,
        grade: this.grade == "all" ? "" : this.grade,
        subject_name: this.subject == "all" ? "" : this.subject,
        exam_date: this.examDate == "all" ? "" : this.examDate,
        viewBy: this.viewBy == "indicator" ? "indicator" : this.viewBy,
        districtId: districtid,
        management: this.management,
        category: this.category,
      };
      this.service.patLOTableBlockData(a).subscribe(
        (response) => {
          this.updatedTable = this.reportData = response["tableData"];
          var blockNames = response["blockDetails"];
          this.blockNames = blockNames.sort((a, b) =>
            a.block_name > b.block_name ? 1 : b.block_name > a.block_name ? -1 : 0
          );
          this.selectedBlock(blockid);
        })
      this.selCluster = false;
      this.selBlock = true;
      this.selDist = true;

      this.blockHidden = true
      this.levelVal = 2;
    } else if (level === "District") {
      this.district = districtid;
      let a = {
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
      this.myData = this.service.patLOTableDistData(a).subscribe(
        (response) => {
          this.resetTable();
          this.updatedTable = this.reportData = response["tableData"];
          var districtNames = response["districtDetails"];
          this.districtNames = districtNames.sort((a, b) =>
            a.district_name > b.district_name
              ? 1
              : b.district_name > a.district_name
                ? -1
                : 0
          );
          this.selectedDistrict(districtid);

        },

      );

      this.selCluster = false;
      this.selBlock = false;
      this.selDist = false;
      this.levelVal = 1;
    } else if (level === null) {
      this.hideDist = false
    }
  }

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

      this.selCluster = false;
      this.selBlock = false;
      this.selDist = true;
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


  //error handling
  handleError() {
    $(`#LOtable`).empty();
    this.reportData = [];
    this.commonService.loaderAndErr(this.reportData);
    document.getElementById("initTable").style.display = "none";
  }

  // to download the csv report
  downloadReport() {
    this.reportData.map(a => {
      var keys = Object.keys(a);
      keys.map(key => {
        if (typeof (a[key]) == "object") {
          a[key] = a[key]['percentage'];
        }
      })
    })
    var position = this.reportName.length;
    this.fileName = [this.fileName.slice(0, position), `_${this.management}`, this.fileName.slice(position)].join('');
    this.commonService.download(this.fileName, this.reportData);
  }

  updateFilter(event: any) {
    this.columns = this.commonService.getColumns(this.updatedTable);
    var val = event.target.value.toLowerCase();

    // filter our data
    let ref = this;
    let temp: any = [];

    if (val) {
      temp = this.updatedTable.filter(function (d: any) {
        let found = false;

        for (let i = 0; i < ref.columns.length; i++) {
          let value = d[ref.columns[i].data];
          if (typeof value === 'number') {
            value = value.toString()
          }

          if (value.toLowerCase().indexOf(val) !== -1) {
            found = true;
            break;
          }
        }
        return found;
      });
    } else {
      document.getElementById('spinner').style.display = 'block';
      temp = this.updatedTable;
    }

    // update the rows
    this.reportData = temp;
    this.pageChange();
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
    "91-100"
  ];
}
