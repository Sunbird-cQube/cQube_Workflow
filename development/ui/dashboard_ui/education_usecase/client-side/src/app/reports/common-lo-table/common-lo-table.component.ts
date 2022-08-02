import { Component, OnInit } from "@angular/core";
import * as Highcharts from "highcharts/highstock";
import HeatmapModule from "highcharts/modules/heatmap";
HeatmapModule(Highcharts);
import { Router, ActivatedRoute } from "@angular/router";
import { HttpClient } from "@angular/common/http";
import { environment } from "src/environments/environment";
import { PatReportService } from "src/app/services/pat-report.service";
import { AppServiceComponent } from "src/app/app.service";
import { dynamicReportService } from "src/app/services/dynamic-report.service";
declare const $;
@Component({
  selector: 'app-common-lo-table',
  templateUrl: './common-lo-table.component.html',
  styleUrls: ['./common-lo-table.component.css']
})
export class CommonLoTableComponent implements OnInit {
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
  date = [];
  allViews = [];
  months = []
  public year = "";
  public grade = "all";
  public subject = "all";
  public examDate = "all";
  public viewBy = "indicator";
  public weeks = []

  //to set hierarchy level
  skul = true;
  dist = false;
  blok = false;
  clust = false;

  // to set hierarchy values
  districtHierarchy: any;
  blockHierarchy: any;
  clusterHierarchy: any;


  // to download the excel report
  public fileName: any = ``;
  public reportData: any = [];

  public metaData: any;
  myData;
  state: string;
  month: string = "";
  week: string = "";
  day: string = "";




  reportName = `lo_Table`;
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
  reportType = "lotable"
  hideYear: boolean = true
  hideMonth: boolean = true
  hideWeek: boolean = true
  hideDay: boolean = true
  constructor(public http: HttpClient,
    public service: PatReportService,
    public service1: dynamicReportService,
    public commonService: AppServiceComponent,
    public router: Router,
    public aRoute: ActivatedRoute) {

    this.datasourse = this.aRoute.snapshot.paramMap.get('id');
    this.getTimelineMeta()
    service1.configurableMetaData({ dataSource: this.datasourse }).subscribe(
      (res) => {
        try {
          this.metaData = res

          for (let i = 0; i < this.metaData.length; i++) {
            this.years.push(this.metaData[i]["academic_year"]);
          }

          this.year = this.years[this.years.length - 1];
          let i;
          for (i = 0; i < this.metaData.length; i++) {
            if (this.metaData[i]["academic_year"] == this.year) {
              this.months = this.metaData[i].data["months"];
              this.grades = this.metaData[i].data["grades"];
              break;
            }
          }


          this.grades = [
            { grade: "all" },
            ...this.grades.filter((item) => item !== { grade: "all" }),
          ];


          this.fileName = `${this.datasourse}_overall_allDistricts_${this.month}_${this.year}_${this.commonService.dateAndTime}`;
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
  public hideAccessBtn: boolean = false;
  public datasourse
  public header
  public description

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


    this.header = `Report on ${this.datasourse.replace(/_+/g, ' ')} access by location for`
    this.description = `The ${this.datasourse.replace(/_+/g, ' ')} dashboard visualises the data on ${this.datasourse.replace(/_+/g, ' ')} metrics for ${this.state}`
  }

  hideDist = true;
  height = window.innerHeight;
  onResize() {
    this.height = window.innerHeight;
  }


  getMetaData() {
    this.service1.configurableMetaData({ dataSource: this.datasourse }).subscribe(res => {
      this.metaData = res

      for (let i = 0; i < this.metaData.length; i++) {
        this.years.push(this.metaData[i]["academic_year"]);
      }
      this.year = this.years[this.years.length - 1];
      let i;
      for (i = 0; i < this.metaData.length; i++) {
        if (this.metaData[i]["academic_year"] == this.year) {
          this.months = this.metaData[i].data["months"];
          this.grades = this.metaData[i].data["grades"];
          break;
        }
      }

      this.grades = [
        { grade: "all" },
        ...this.grades.filter((item) => item !== { grade: "all" }),
      ];

    })
  }
  public timeRange
  getTimelineMeta() {
    this.service1.configurableTimePeriodMeta({ dataSource: this.datasourse }).subscribe(res => {
      this.timeRange = res
      const key = 'value';
      this.timeRange = [...new Map(this.timeRange.map(item =>
        [item[key], item])).values()];

    })
  }

  period = "overall";

  onChangePage() {
    document.getElementById('spinner').style.display = 'block';
    this.pageChange();
  }

  pageChange() {

    this.filteredData = this.reportData.slice(((this.currentPage - 1) * this.pageSize), ((this.currentPage - 1) * this.pageSize + this.pageSize));
    this.createTable(this.filteredData);
  }



  resetToInitPage() {
    this.resetTable();
    this.fileName = `${this.datasourse}_overall_allDistricts_${this.month}_${this.year}_${this.commonService.dateAndTime}`;
    this.skul = true;
    this.dist = false;
    this.blok = false;
    this.clust = false;
    this.hideYear = true
    this.hideMonth = true
    this.hideWeek = true
    this.hideDay = true
    this.gradeSelected = false;
    this.dateSelected = false;
    this.month = ""
    this.period = "overall"
    this.grade = "all";
    this.examDate = "all";
    this.subject = "all";
    this.week = ""
    this.viewBy = "indicator";
    this.district = undefined;
    this.block = undefined;
    this.cluster = undefined;
    this.blockHidden = true;
    this.clusterHidden = true;
    this.weekSeletced = false;
    if (this.hideAccessBtn) {
      document.getElementById("initTable").style.display = "block";
      this.commonFunc();
    } else {
      this.getView()
    }

  }

  commonFunc = () => {

    this.commonService.errMsg();

    this.level = "district";
    this.values = []

    let a = {
      dataSource: this.datasourse,
      reportType: this.reportType,
      year: this.year,
      month: this.month,
      week: this.week,
      grade: this.grade == "all" ? "" : this.grade,
      subject_name: this.subject == "all" ? "" : this.subject,
      exam_date: this.examDate == "all" ? "" : this.examDate,
      management: this.management,
      category: this.category,
      period: this.period
    };

    if (this.myData) {
      this.myData.unsubscribe();
    }
    this.myData = this.service1.dynamicDistData(a).subscribe(
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

        let Arr1 = []


        $.each(this.reportData, function (a, b) {
          $.each(b, function (key, value) {
            if (key !== 'subject' && key !== 'grade') {
              if (typeof (value.percentage) == "number") {
                Arr1.push(value.percentage)
              }

            }
          });
        });

        Arr1 = Arr1.sort(function (a, b) {
          return parseFloat(a) - parseFloat(b);
        });

        const min = Math.min(...Arr1);
        const max = Math.max(...Arr1);
        this.getRangeArray(min, max, 10)

        this.onChangePage();
      },
      (err) => {
        this.handleError();
      }
    );
  };

  columns = [];
  colorRange = []
  createTable(dataSet) {
    let weekSelct = this.weekSeletced;
    let dateSelct = this.dateSelected;
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
        if (weekSelct) {
          if (i > 3) {
            headers += `<th class="rank text-wrap" style ="text-align: center" ><div style="transform: rotate(270deg); vertical-align: middle; text-align: center;">${col}</div></th>`;
          } else {
            headers += `<th>${col}</th>`;
          }

        } else {
          if (i > 1) {
            headers += `<th class="rank text-wrap" style ="text-align: center" ><div style="transform: rotate(270deg); vertical-align: middle; text-align: center;">${col}</div></th>`;
          } else {
            headers += `<th>${col}</th>`;
          }
        }

      });

      let newArr = [];

      $.each(dataSet, function (a, b) {
        let temp = [];
        $.each(b, function (key, value) {

          let new_item = {};
          new_item["data"] = key;
          new_item["value"] = typeof (value) != 'object' ? value : value.percentage;
        
          temp.push(new_item);
        });
        newArr.push(temp);
      });

      let Arr1 = []

      $.each(dataSet, function (a, b) {

        $.each(b, function (key, value) {

          if (key !== 'subject' && key !== 'grade') {

            if (typeof (value.percentage) == "number") {

              Arr1.push(value.percentage)
            }
          }

        });
      });

      Arr1 = Arr1.sort(function (a, b) {
        return parseFloat(a) - parseFloat(b);
      });

      const min = Math.min(...Arr1);
      const max = Math.max(...Arr1);

      function generateArrayMinMax(min, max, n) {
        let list = [min],
          interval = (max - min) / (n - 1);

        for (let i = 1; i < n - 1; i++) {
          list.push(min + interval * i);
        }
        list.push(max);
        return list;
      }

      const rangeArrayIn10Parts = generateArrayMinMax(min, max, 10);

      function tableCellColor(data) {
        let colors = {}
        let color = ['#a50026', '#d73027', '#f46d43', '#fdae61', '#fee08b', '#d9ef8b', '#a6d96a', '#66bd63', '#1a9850', '#006837']
        rangeArrayIn10Parts.forEach((value, i) => {
          colors[value] = color[i]
        })

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
        if (weekSelct === true && dateSelct === false) {

          body += "<tr>";
          columns.forEach((column, i2) => {

            if (i2 > 1 && column.value || i2 > 1 && String(column.value) == String(0)) {
              let title = `${level} Name: ${columns.data}<br/> Grade:${columns[0].value[columns[0].value.length - 1]} <br/> Subject: ${columns[1].value} <br/> Total Count: ${column.value}`;
              body += `<td class="numberData" data-toggle="tooltip" data-html="true" data-placement="auto" style='background-color: ${tableCellColor(column.value)}' title="${title}">${column.value}</td>`;

            }
            else {
              if (column.data == 'date') {
                var date = column.value.split("-");
                body += `<td>${date[0]}</td>`;
              } else if (column.data == 'grade') {
                body += `<td>${column.value[column.value.length - 1]}</td>`;
              } else {
                body += `<td>${column.value}</td>`;
              }

            }
          });
          body += "</tr>";
        } if (weekSelct === true && dateSelct === true) {

          body += "<tr>";
          columns.forEach((column, i2) => {

            if (i2 > 2 && column.value || i2 > 2 && String(column.value) == String(0)) {
              let title = `${level} Name: ${column.data}<br/> Grade:${columns[0].value[columns[0].value.length - 1]} <br/> Subject: ${columns[1].value} <br/> Total Count: ${column.value}`;
              body += `<td class="numberData" data-toggle="tooltip" data-html="true" data-placement="auto" style='background-color: ${tableCellColor(column.value)}' title="${title}">${column.value}</td>`;

            }
            else {
              if (column.data == 'date') {
                var date = column.value.split("-");
                body += `<td>${date[0]}</td>`;
              } else if (column.data == 'grade') {
                body += `<td>${column.value[column.value.length - 1]}</td>`;
              } else {
                body += `<td>${column.value}</td>`;
              }

            }
          });
          body += "</tr>";
        } else {
          body += "<tr>";
          columns.forEach((column, i2) => {

            if (i2 > 1 && column.value || i2 > 1 && String(column.value) == String(0)) {
              let title = `${level} Name: ${column.data}<br/> Grade: ${columns[0].value[columns[0].value.length - 1]} <br/> Subject: ${columns[1].value} <br/> Total Count: ${column.value}`;
              body += `<td class="numberData" data-toggle="tooltip" data-html="true" data-placement="auto" style='background-color: ${tableCellColor(column.value)}' title="${title}">${column.value}</td>`;

            }
            else {

              if (column.data == 'date') {
                var date = column.value.split("-");
                body += `<td>${date[0]}</td>`;
              } else if (column.data == 'grade') {
                body += `<td>${column.value[column.value.length - 1]}</td>`;
              } else {
                body += `<td>${column.value}</td>`;
              }
            }

          });
          body += "</tr>";
        }

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

  selectedTimeRange() {

    this.month = this.period === "year and month" ? this.months[this.months.length - 1]['months'] : '';
    this.hideYear = this.period === "year and month" ? false : true;
    this.hideMonth = this.period === "year and month" ? false : true;
    this.hideWeek = this.period === "year and month" ? false : true;
    this.hideDay = this.period === "year and month" ? false : true;
    this.weeks = this.period === "year and month" ? this.months.find(a => { return a.months == this.month }).weeks : "";
    this.week = this.period === "year and month" ? this.week : "";

    this.grade = "all";
    this.examDate = "all";
    this.subject = "all";
    this.week = "";
    if (this.hideAccessBtn) {
      this.levelWiseFilter();

    } else {
      this.getView()
    }
  }

  selectedYear(event) {
    this.hideYear = this.period === "year and month" ? false : true;
    this.hideMonth = this.period === "year and month" ? false : true;
    this.hideWeek = this.period === "year and month" ? false : true;
    this.hideDay = this.period === "year and month" ? true : false;
    if (event) {
      let i;
      for (i = 0; i < this.metaData.length; i++) {
        if (this.metaData[i]["academic_year"] == this.year) {
          this.months = this.metaData[i].data["months"];
          this.grades = this.metaData[i].data["grades"];
          break;
        }
      }
      this.month = this.period === "year and month" ? this.months[this.months.length - 1]['months'] : '';

    } else {
      this.month = this.period === "year and month" ? this.months[this.months.length - 1]['months'] : '';

      this.weeks = this.period === "year and month" ? this.months.find(a => { return a.months == this.month }).weeks : "";
      this.week = this.period === "year and month" ? this.week : "";

    }

    this.grade = "all";
    this.examDate = "all";
    this.subject = "all";
    this.week = "";
    if (this.hideAccessBtn) {
      this.levelWiseFilter();

    } else {
      this.getView()
    }
  }

  selectedMonth(event) {
    this.fileName = `${this.datasourse}_${this.grade}_allDistricts_${this.month}_${this.year}_${this.commonService.dateAndTime}`;

    this.hideYear = this.period === "year and month" ? false : true;
    this.hideMonth = this.period === "year and month" ? false : true;

    this.hideWeek = this.period === "year and month" ? false : true;

    if (event) {
      this.weeks = this.period === "year and month" ? this.months.find(a => { return a.months == this.month })?.weeks : "";
    } else {
      this.month = this.period === "year and month" ? this.months[this.months.length - 1]['months'] : '';
      this.month = this.period === "year and month" ? this.months[this.months.length - 1]['months'] : '';
      this.year = this.period === "year and month" ? this.year = this.years[this.years.length - 1] : "";
      this.weeks = this.period === "year and month" ? this.months.find(a => { return a.months == this.month }).weeks : "";
    }


    this.grade = "all";
    this.examDate = "all";
    this.subject = "all";

    if (this.hideAccessBtn) {
      this.levelWiseFilter();

    } else {
      this.resetTable();
      this.getView()
    }
  }
  public weekSeletced = false
  selectedWeek() {
    this.weekSeletced = true;
    this.dateSelected = false;
    this.hideDay = false;
    this.fileName = `${this.reportName}_${this.grade}_allDistricts_${this.month}_${this.year}_${this.commonService.dateAndTime}`;
    this.date = this.weeks.find(a => { return a.week == this.week }).days;
    this.grade = "all";
    this.examDate = "all";
    this.subject = "all";
    if (this.hideAccessBtn) {
      this.levelWiseFilter();

    } else {
      this.resetTable();
      this.getView()
    }
  }


  selectedGrade() {

    this.fileName = `${this.datasourse}_${this.grade}_allDistricts_${this.month}_${this.year}_${this.commonService.dateAndTime}`;
    if (this.grade !== "all") {
      this.subjects = this.grades.find(a => { return a.grade == this.grade }).subjects;
      this.subjects = ["all", ...this.subjects.filter((item) => item !== "all")];
      this.gradeSelected = true;
    } else {
      this.grade = "all";

      this.resetToInitPage();
    }

    this.levelWiseFilter();

  }

  selectedSubject() {

    this.fileName = `${this.datasourse}_${this.grade}_${this.subject}_allDistricts_${this.month}_${this.year}_${this.commonService.dateAndTime}`;
    if (this.hideAccessBtn) {
      this.levelWiseFilter();

    } else {
      this.getView()
    }
  }

  public dateSelected = false
  selectedExamDate() {
    this.dateSelected = true
    this.grade = "all";
    this.subject = "all";
    this.fileName = `${this.datasourse}_${this.grade}_${this.examDate}_allDistricts_${this.month}_${this.year}_${this.commonService.dateAndTime}`;
    if (this.hideAccessBtn) {
      this.levelWiseFilter();
    } else {
      this.getView()
    }
  }



  selectedDistrict(districtId, blockId?) {

    this.resetTable();
    this.level = "block";
    this.fileName = `${this.datasourse}_${this.grade}_${this.level}s_of_district_${districtId}_${this.month}_${this.year}_${this.commonService.dateAndTime}`;
    this.block = undefined;
    this.cluster = undefined;
    this.blockHidden = false;
    this.clusterHidden = true;
    this.blockNames = []
    this.commonService.errMsg();

    let a = {
      dataSource: this.datasourse,
      reportType: this.reportType,
      year: this.year,
      week: this.week,
      month: this.month,
      grade: this.grade == "all" ? "" : this.grade,
      subject_name: this.subject == "all" ? "" : this.subject,
      exam_date: this.examDate == "all" ? "" : this.examDate,
      districtId: districtId,
      management: this.management,
      category: this.category,
      period: this.period
    };

    this.service1.dynamicBlockData(a).subscribe(
      (response) => {
        document.getElementById("initTable").style.display = "block";
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

    this.resetTable();
    this.level = "cluster";
    this.fileName = `${this.datasourse}_${this.grade}_${this.level}s_of_block_${blockId}_${this.month}_${this.year}_${this.commonService.dateAndTime}`;
    this.cluster = undefined;
    this.blockHidden = this.selBlock ? true : false;
    this.clusterHidden = false;

    this.commonService.errMsg();

    let a = {
      dataSource: this.datasourse,
      reportType: this.reportType,
      period: this.period,
      week: this.week,
      year: this.year,
      month: this.month,
      grade: this.grade == "all" ? "" : this.grade,
      subject_name: this.subject == "all" ? "" : this.subject,
      exam_date: this.examDate == "all" ? "" : this.examDate,
      districtId: this.district,
      blockId: blockId,
      management: this.management,
      category: this.category,
    };

    this.service1.dynamicClusterData(a).subscribe(
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

    this.resetTable();
    this.level = "school";
    this.fileName = `${this.datasourse}_${this.grade}_${this.level}s_of_cluster_${clusterId}_${this.month}_${this.year}_${this.commonService.dateAndTime}`;

    this.commonService.errMsg();
    let a = {
      dataSource: this.datasourse,
      reportType: this.reportType,
      period: this.period,
      year: this.year,
      week: this.week,
      month: this.month,
      grade: this.grade == "all" ? "" : this.grade,
      subject_name: this.subject == "all" ? "" : this.subject,
      exam_date: this.examDate == "all" ? "" : this.examDate,
      districtId: this.district,
      blockId: this.block,
      clusterId: clusterId,
      management: this.management,
      category: this.category,
      schoolLevel: this.schoolLevel,
      schoolId: Number(localStorage.getItem('schoolId'))
    };

    this.service1.dynamicSchoolData(a).subscribe(
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
  hideFooter = false
  getView() {

    document.getElementById("initTable").style.display = "block";
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
      this.hideFooter = true
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

      this.service1.dynamicClusterData(a).subscribe(
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
        }, (err) => {

          this.handleError();
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
        dataSource: this.datasourse,
        reportType: this.reportType,
        period: this.period,
        week: this.week,
        year: this.year,
        month: this.month,
        grade: this.grade == "all" ? "" : this.grade,
        subject_name: this.subject == "all" ? "" : this.subject,
        exam_date: this.examDate == "all" ? "" : this.examDate,
        districtId: this.district,
        blockId: blockid,
        management: this.management,
        category: this.category,
      };

      this.service1.dynamicClusterData(a).subscribe(
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
        }, (err) => {
          this.handleError()
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
        dataSource: this.datasourse,
        reportType: this.reportType,
        year: this.year,
        week: this.week,
        month: this.month,
        grade: this.grade == "all" ? "" : this.grade,
        subject_name: this.subject == "all" ? "" : this.subject,
        exam_date: this.examDate == "all" ? "" : this.examDate,
        districtId: districtid,
        management: this.management,
        category: this.category,
        period: this.period
      };
      this.service1.dynamicBlockData(a).subscribe(
        (response) => {
          this.updatedTable = this.reportData = response["tableData"];
          var blockNames = response["blockDetails"];
          this.blockNames = blockNames.sort((a, b) =>
            a.block_name > b.block_name ? 1 : b.block_name > a.block_name ? -1 : 0
          );
          this.selectedBlock(blockid);
        }, (err) => {
          this.handleError()
        })
      this.selCluster = false;
      this.selBlock = true;
      this.selDist = true;

      this.blockHidden = true
      this.levelVal = 2;
    } else if (level === "District") {
      this.district = districtid;
      let a = {
        dataSource: this.datasourse,
        reportType: this.reportType,
        year: this.year,
        month: this.month,
        week: this.week,
        grade: this.grade == "all" ? "" : this.grade,
        subject_name: this.subject == "all" ? "" : this.subject,
        exam_date: this.examDate == "all" ? "" : this.examDate,
        management: this.management,
        category: this.category,
        period: this.period
      };
      this.month = a.month;
      if (this.myData) {
        this.myData.unsubscribe();
      }
      this.myData = this.service1.dynamicDistData(a).subscribe(
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

        }, (err) => {
          this.handleError()
        });

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

  getRangeArray = (min, max, n) => {
    let delta = (max - min) / n;

    const ranges = [];
    let range1 = min;
    for (let i = 0; i < n; i += 1) {
      const range2 = range1 + delta;
      this.values.push(
        `${Math.round(Number(range1)).toLocaleString("en-IN")}-${Math.round(Number(
          range2
        )).toLocaleString("en-IN")}`
      );
      ranges.push([range1, range2]);
      range1 = range2;
    }

    return ranges;
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

  public values = []


}
