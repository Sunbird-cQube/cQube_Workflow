// This dashboard provides information about teacher attendance
// calculated at a monthly level. The data has been collated at various administrative levels (i.e.
// District, Block, Cluster and School) and
// this dashboard allows you to view and download the data at these various administrative levels. You can
// select a different month/year combination to view teacher attendance for any other time period.

import {
  Component,
  OnInit,
  ChangeDetectorRef,
  ViewEncapsulation,
} from "@angular/core";
import { HttpClient } from "@angular/common/http";
import { TeacherAttendanceReportService } from "../../../services/teacher-attendance-report.service";
import { Router } from "@angular/router";
import * as L from "leaflet";
import * as R from "leaflet-responsive-popup";
import { KeycloakSecurityService } from "../../../keycloak-security.service";
import { AppServiceComponent } from "../../../app.service";
import { MapService, globalMap } from '../../../services/map-services/maps.service';
import { environment } from "src/environments/environment";
declare const $;

@Component({
  selector: "app-teacher-attendance",
  templateUrl: "./teacher-attendance.component.html",
  styleUrls: ["./teacher-attendance.component.css"],
  encapsulation: ViewEncapsulation.None,
})
export class TeacherAttendanceComponent implements OnInit {
  //variables for telemetry data
  state;
  edate;
  public telemData = {};

  public waterMark = environment.water_mark
  // to set the hierarchy names
  public title: string = "";
  public titleName: string = "";

  //to store level data
  public districts: any = [];
  public blocks: any = [];
  public cluster: any = [];
  public schools: any = [];

  //to store level wise ids
  public districtsIds: any = [];
  public blocksIds: any = [];
  public clusterIds: any = [];
  public schoolsIds: any = [];

  //to store names for dropdown
  public districtsNames: any = [];
  public blocksNames: any = [];
  public clusterNames: any = [];
  public schoolsNames: any = [];

  //to show or hide dropdowns
  public distHidden: boolean = true;
  public blockHidden: boolean = true;
  public clusterHidden: boolean = true;

  //to store selected level value
  public myDistrict: any;
  public myBlock: any;
  public myCluster: any;

  //to store colors for markers
  public colors: any;

  //to store footer values
  public teacherCount: any;
  public schoolCount: any;
  public dateRange: any = "";

  //to control hierarchy
  public dist: boolean = false;
  public blok: boolean = false;
  public clust: boolean = false;
  public skul: boolean = false;

  // store level wise heirarchy
  public hierName: any;
  public distName: any;
  public blockName: any;
  public clustName: any;

  //to store all markers
  public markerData;

  // leaflet layer dependencies
  public layerMarkers: any = new L.layerGroup();
  public markersList = new L.FeatureGroup();
  public levelWise: any = "District";

  // google maps zoom level
  public zoom: number = 7;

  public labelOptions: any = {};

  // initial center position for the map
  public lat: any;
  public lng: any;

  public markers: any = [];
  public mylatlngData: any = [];

  //for year and month selection
  public getMonthYear: any;
  public years: any = [];
  public year;
  public months: any = [];
  public month;
  public element;
  params: any;
  mapName;
  googleMapZoom;
  yearMonth = true;
  selected = "absolute";
  reportName = "teacher_attendance";

  //options for timerange dropdown::::::
  timeRange = [
    { key: "overall", value: "Overall" },
    { key: "last_30_days", value: "Last 30 Days" },
    { key: "last_7_days", value: "Last 7 Days" },
    { key: "last_day", value: "Last Day" },
    { key: "select_month", value: "Year and Month" },
  ];
  period = "overall";
  timePeriod = {};
  rawFileName: string;
  academicYear: any;
  academicYears: any;

  constructor(
    public http: HttpClient,
    public service: TeacherAttendanceReportService,
    public router: Router,
    public keyCloakSevice: KeycloakSecurityService,
    private changeDetection: ChangeDetectorRef,
    public commonService: AppServiceComponent,
    private readonly _router: Router,
    public globalService: MapService,
  ) { }

  getColor(data) {
    this.selected = data;
    this.levelWiseFilter();
  }

  geoJson = this.globalService.geoJson;


  width = window.innerWidth;
  height = window.innerHeight;
  onResize(event) {
    this.height = window.innerHeight;
  }

  //to select management and category
  managementName;
  management;
  category;

  public userAccessLevel = localStorage.getItem("userLevel");
  public hideIfAccessLevel: boolean = false
  public hideAccessBtn: boolean = false

  ngOnInit() {
    this.mapName = this.commonService.mapName;
    this.state = this.commonService.state;
    this.globalService.latitude = this.lat = this.globalService.mapCenterLatlng.lat;
    this.globalService.longitude = this.lng = this.globalService.mapCenterLatlng.lng;
    this.changeDetection.detectChanges();
    this.globalService.initMap("tarMap", [[this.lat, this.lng]]);
    if (this.mapName == 'googlemap') {
      document.getElementById('leafletmap').style.display = "none";
    }
    document.getElementById("accessProgressCard").style.display = "none";
    document.getElementById("backBtn") ? document.getElementById("backBtn").style.display = "none" : "";
    this.skul = true;
    this.timePeriod = {
      period: "overall",
    };

    //setting management-category values
    this.managementName = this.management = JSON.parse(localStorage.getItem('management')).id;
    this.category = JSON.parse(localStorage.getItem('category')).id;
    this.managementName = this.commonService.changeingStringCases(
      this.managementName.replace(/_/g, " ")
    );

    //setting year-month options:::::
    this.service.getDateRange().subscribe(
      (res) => {
        try {
          this.getMonthYear = res;
          this.years = Object.keys(this.getMonthYear);
          this.year = this.years[this.years.length - 1];
          var allMonths = [];
          allMonths = this.getMonthYear[`${this.year}`];
          this.months = [];
          allMonths.forEach((month) => {
            var obj = {
              name: month.month_name,
              id: month.month,
            };
            this.months.push(obj);
          });
          this.month = this.months[this.months.length - 1].id;
          // this.dateRange = `${this.getMonthYear[`${this.year}`][this.months.length - 1].data_from_date} to ${this.getMonthYear[`${this.year}`][this.months.length - 1].data_upto_date}`;
          if (this.month) {
            this.month_year = {
              month: null,
              year: null,
            };

            this.params = JSON.parse(sessionStorage.getItem("report-level-info"));
            let params = this.params;

            if (params && params.level) {
              let data = params.data;
              if (params.level === "district") {
                this.myDistrict = data.id;
              } else if (params.level === "block") {
                this.myDistrict = data.districtId;
                this.myBlock = data.id;
              } else if (params.level === "cluster") {
                this.myDistrict = data.districtId;
                this.myBlock = Number(data.blockId);
                this.myCluster = data.id;
              }
              this.changeDetection.detectChanges();
              this.getDistricts();
            } else {
              this.levelWiseFilter();
            }
          }
        } catch (e) {
          this.commonService.loaderAndErr(this.markers);
        }
        //this.getView1();
      },
      (err) => {
        this.dateRange = "";
        this.teacherCount = 0;
        this.schoolCount = 0;
        this.changeDetection.detectChanges();

        this.getMonthYear = {};
        this.commonService.loaderAndErr(this.markers);
      }
    );
    this.service.getRawMeta({ report: "tar" }).subscribe((res) => {
      this.academicYears = res;
    });
    this.toHideDropdowns();

    this.hideAccessBtn = (environment.auth_api === 'cqube' || this.userAccessLevel === "") ? true : false;
    this.selDist = (environment.auth_api === 'cqube' || this.userAccessLevel === '') ? false : true;

    if (environment.auth_api !== 'cqube') {
      if (this.userAccessLevel !== '') {
        this.hideIfAccessLevel = true;
      }
    }
  }

  toHideDropdowns() {
    this.blockHidden = true;
    this.clusterHidden = true;
    this.distHidden = true;
  }

  selCluster = false;
  selBlock = false;
  selDist = false;
  levelVal = 0;

  getView() {
    let id = JSON.parse(localStorage.getItem("userLocation"));
    let level = localStorage.getItem("userLevel");
    let clusterid = JSON.parse(localStorage.getItem("clusterId"));
    let blockid = JSON.parse(localStorage.getItem("blockId"));
    let districtid = JSON.parse(localStorage.getItem("districtId"));
    let schoolid = JSON.parse(localStorage.getItem("schoolId"));


    if (districtid) {
      this.myDistrict = districtid;
      this.myDistData(districtid);
    }
    if (blockid) {
      this.myBlock = blockid;
      this.myDistData(districtid, blockid);
    }
    if (clusterid) {
      this.myCluster = clusterid;
      this.myDistData(districtid, blockid, clusterid);

    }


    if (level === "cluster") {
      this.clusterlevel(id);
      this.levelVal = 3;
    } else if (level === "block") {
      this.blocklevel(id);
      this.levelVal = 2;
    } else if (level === "district") {
      this.distlevel(id);
      this.levelVal = 1;
    }
  }
  getView1() {
    let id = JSON.parse(localStorage.getItem("userLocation"));
    let level = localStorage.getItem("userLevel");
    let clusterid = JSON.parse(localStorage.getItem("clusterId"));
    let blockid = JSON.parse(localStorage.getItem("blockId"));
    let districtid = JSON.parse(localStorage.getItem("districtId"));
    let schoolid = JSON.parse(localStorage.getItem("schoolId"));


    if (districtid !== null) {
      this.myDistrict = districtid;
      this.distHidden = false;
    }
    if (blockid !== null) {
      this.myBlock = blockid;
      this.blockHidden = false;
    }
    if (clusterid !== null) {
      this.myCluster = clusterid;
      this.clusterHidden = false;
    }
    if (districtid === null) {
      this.distHidden = false;
    }
    if (level === "Cluster") {
      this.myDistData(districtid, blockid, clusterid);
      this.clusterlevel(clusterid);
      this.selCluster = true
      this.levelVal = 3;
    } else if (level === "Block") {
      this.myDistData(districtid, blockid);
      this.blocklevel(blockid);
      this.selBlock = true
      this.levelVal = 2;
    } else if (level === "District") {
      this.myDistData(districtid);
      this.distlevel(districtid)
      this.levelVal = 1;
    }
  }


  distlevel(id) {
    this.selCluster = false;
    this.selBlock = false;
    this.selDist = true;
    //  this.level= "blockPerDistrict";
    this.myDistrict = id;
    //   this.levelWiseFilter();
  }

  blocklevel(id) {
    this.selCluster = false;
    this.selBlock = true;
    this.selDist = true;
    // this.level= "clusterPerBlock";
    this.myBlock = id;
    //   this.levelWiseFilter();
  }

  clusterlevel(id) {
    this.selCluster = true;
    this.selBlock = true;
    this.selDist = true;
    // this.level= "schoolPerCluster";
    this.myCluster = id;
    //  this.levelWiseFilter();
  }


  //This function will be called on select year-month option show year month dropdown:::::
  showYearMonth() {

    this.yearMonth = false;
    this.month_year = {
      month: this.month,
      year: this.year,
    };
    this.timePeriod = {
      period: null,
    };
    this.levelWiseFilter();
  }

  //This function will be called on select period dropdown::::
  onPeriodSelect() {
    this.yearMonth = true;
    this.timePeriod = {
      period: this.period,
    };
    this.month_year = {
      month: null,
      year: null,
    };
    this.levelWiseFilter();
  }

  //This function is get all district names, on load of page after coming from progress card:::::::
  getDistricts(): void {
    this.service.dist_wise_data(this.month_year).subscribe(
      (res) => {
        var sorted = res["distData"].sort((a, b) =>
          a.attendance > b.attendance ? 1 : -1
        );
        var distNames = [];
        this.markers = sorted;
        if (this.markers.length > 0) {
          for (var i = 0; i < this.markers.length; i++) {
            if (this.myDistrict === this.markers[i]["district_id"]) {
              localStorage.setItem("dist", this.markers[i].district_name);
              localStorage.setItem("distId", this.markers[i].district_id);
            }

            this.districtsIds.push(this.markers[i]["district_id"]);
            distNames.push({
              id: this.markers[i]["district_id"],
              name: this.markers[i]["district_name"],
            });
          }
        }

        distNames.sort((a, b) =>
          a.name > b.name ? 1 : b.name > a.name ? -1 : 0
        );
        this.districtsNames = distNames;

        if (this.params.level === "district") {
          this.distSelect({ type: "click" }, this.myDistrict);
        } else {
          this.getBlocks();
        }
      },
      (err) => {
        this.markers = [];
        this.commonService.loaderAndErr(this.markers);
      }
    );
  }

  getBlocks(): void {
    this.month_year["id"] = this.myDistrict;
    this.service.blockPerDist(this.month_year).subscribe(
      (res) => {
        let blockData = res["blockData"];
        var uniqueData = blockData.reduce(function (previous, current) {
          var object = previous.filter(
            (object) => object["block_id"] === current["block_id"]
          );
          if (object.length == 0) previous.push(current);
          return previous;
        }, []);
        blockData = uniqueData;
        var blokName = [];
        var sorted = blockData.sort((a, b) =>
          parseInt(a.attendance) > parseInt(b.attendance) ? 1 : -1
        );

        this.markers = sorted;

        for (var i = 0; i < this.markers.length; i++) {
          if (this.myBlock === this.markers[i]["block_id"]) {
            localStorage.setItem("block", this.markers[i].block_name);
            localStorage.setItem("blockid", this.markers[i].block_id);
          }

          this.blocksIds.push(this.markers[i]["block_id"]);
          blokName.push({
            id: this.markers[i]["block_id"],
            name: this.markers[i]["block_name"],
          });
        }
        blokName.sort((a, b) =>
          a.name > b.name ? 1 : b.name > a.name ? -1 : 0
        );
        this.blocksNames = blokName;

        if (this.params.level === "block") {
          this.blockSelect({ type: "click" }, this.myBlock);
        } else {
          this.getClusters();
        }
      },
      (err) => {
        this.markers = [];
        this.commonService.loaderAndErr(this.markers);
      }
    );
  }

  getClusters(): void {
    this.month_year["id"] = this.myBlock;
    this.service.clusterPerBlock(this.month_year).subscribe(
      (res) => {
        let clusterData = res["clusterDetails"];
        var uniqueData = clusterData.reduce(function (previous, current) {
          var object = previous.filter(
            (object) => object["cluster_id"] === current["cluster_id"]
          );
          if (object.length == 0) previous.push(current);
          return previous;
        }, []);
        clusterData = uniqueData;
        var clustNames = [];

        var sorted = clusterData.sort((a, b) =>
          parseInt(a.attendance) > parseInt(b.attendance) ? 1 : -1
        );
        for (var i = 0; i < sorted.length; i++) {
          if (this.myCluster === sorted[i]["cluster_id"]) {
            localStorage.setItem("cluster", sorted[i].cluster_name);
            localStorage.setItem("clusterid", sorted[i].cluster_id);
          }

          this.clusterIds.push(sorted[i]["cluster_id"]);
          if (sorted[i]["name"] !== null) {
            clustNames.push({
              id: sorted[i]["cluster_id"],
              name: sorted[i]["cluster_name"],
              blockId: sorted[i]["block_id"],
            });
          } else {
            clustNames.push({
              id: sorted[i]["cluster_id"],
              name: "NO NAME FOUND",
              blockId: sorted[i]["block_id"],
            });
          }
        }

        clustNames.sort((a, b) =>
          a.name > b.name ? 1 : b.name > a.name ? -1 : 0
        );
        this.clusterNames = clustNames;

        this.clusterSelect({ type: "click" }, this.myCluster);
      },
      (err) => {
        this.markers = [];
        this.commonService.loaderAndErr(this.markers);
      }
    );
  }

  // google maps
  mouseOverOnmaker(infoWindow, $event: MouseEvent): void {
    infoWindow.open();
  }

  mouseOutOnmaker(infoWindow, $event: MouseEvent) {
    infoWindow.close();
  }


  public fileName: any;
  public reportData: any = [];

  globalId;

  downloadReport(event) {
    if (this.globalId == this.myDistrict) {
      var distData: any = {};
      this.districtData.find((a) => {
        if (a.district_id == this.myDistrict) {
          distData = {
            id: a.district_id,
            name: a.district_name,
            lat: a.lat,
            lng: a.lng,
          };
        }
      });
      this.getTelemetryData(distData, event.target.id, "district");
    }

    if (this.globalId == this.myBlock) {
      var blokData: any = {};
      this.blockData.find((a) => {
        if (a.block_id == this.myBlock) {
          blokData = {
            id: a.block_id,
            name: a.block_name,
            lat: a.lat,
            lng: a.lng,
          };
        }
      });
      this.getTelemetryData(blokData, event.target.id, "block");
    }
    if (this.globalId == this.myCluster) {
      var clustData: any = {};
      this.clusterData.find((a) => {
        if (a.cluster_id == this.myCluster) {
          clustData = {
            id: a.cluster_id,
            name: a.cluster_name,
            lat: a.lat,
            lng: a.lng,
          };
        }
      });
      this.getTelemetryData(clustData, event.target.id, "cluster");
    }

    var myReport = [];
    this.reportData.forEach((element) => {
      if (this.levelWise != "School") {
        if (element.number_of_schools) {
          element.number_of_schools = element.number_of_schools.replace(
            /\,/g,
            ""
          );
        }
      }
      if (element.number_of_students) {
        element.number_of_students = element.number_of_students.replace(
          /\,/g,
          ""
        );
      }
      var data = {};
      var downloadable_data = {};
      Object.keys(element).forEach((key) => {
        if (key !== "lat") {
          data[key] = element[key];
        }
      });
      Object.keys(data).forEach((key) => {
        if (key !== "lng") {
          downloadable_data[key] = data[key];
        }
      });
      myReport.push(downloadable_data);
    });
    var position = this.reportName.length;
    this.fileName = [this.fileName.slice(0, position), `_${this.management}`, this.fileName.slice(position)].join('');
    this.commonService.download(this.fileName, myReport);
  }

  public month_year;
  getMonth(event) {
    var month = this.getMonthYear[`${this.year}`].find(
      (a) => a.month === this.month
    );
    // this.dateRange = `${month.data_from_date} to ${month.data_upto_date}`;
    this.month_year = {
      month: this.month,
      year: this.year,
    };
    this.levelWiseFilter();
  }

  levelWiseFilter() {
    if (this.skul) {
      if (this.levelWise === "District") {
        this.districtWise();
      }
      if (this.levelWise === "Block") {
        this.blockWise(event);
      }
      if (this.levelWise === "Cluster") {
        this.clusterWise(event);
      }
      if (this.levelWise === "School") {
        this.schoolWise(event);
      }
    } else {
      if (this.dist && this.myDistrict !== null) {
        this.myDistData(this.myDistrict);
      }
      if (this.blok && this.myBlock !== undefined) {
        this.myBlockData(this.myBlock);
      }
      if (this.clust && this.myCluster !== null) {
        this.myClusterData(this.myCluster);
      }
    }
  }

  getYear() {
    this.months = [];
    this.month = undefined;
    var allMonths = [];
    allMonths = this.getMonthYear[`${this.year}`];
    allMonths.forEach((month) => {
      var obj = {
        name: month.month_name,
        id: month.month,
      };
      this.months.push(obj);
    });
    // this.element.disabled = false;
  }

  public myData;
  districtData = [];

  onClickHome() {
    this.districtSelected = false;
    this.selectedCluster = false;
    this.blockSelected = false;
    this.hideAllBlockBtn = false;
    this.hideAllCLusterBtn = false;
    this.hideAllSchoolBtn = false;
    this.yearMonth = true;
    this.academicYear = undefined;
    this.period = "overall";
    this.levelWise = "District";
    this.month_year = {
      month: null,
      year: null,
    };
    this.timePeriod = {
      period: this.period,
    };
    this.districtWise();

  }

  async districtWise() {
    this.commonAtStateLevel();
    this.levelWise = "District";
    this.googleMapZoom = 7;
    if (this.months.length > 0) {
      var month = this.months.find((a) => a.id === this.month);
      if (this.month_year.month) {
        this.fileName = `${this.reportName}_allDistricts_${month.name.trim()}_${this.year
          }_${this.commonService.dateAndTime}`;
      } else {
        this.fileName = `${this.reportName}_allDistricts_${this.period}_${this.commonService.dateAndTime}`;
      }
      if (this.myData) {
        this.myData.unsubscribe();
      }
      this.myData = this.service
        .dist_wise_data({
          ...this.month_year,
          ...this.timePeriod,
          ...{ management: this.management, category: this.category },
        })
        .subscribe(
          (res) => {
            this.reportData = this.districtData = this.mylatlngData =
              res["distData"];
            this.dateRange = res["dateRange"];
            var sorted = this.mylatlngData.sort((a, b) =>
              a.attendance > b.attendance ? 1 : -1
            );

            var distNames = [];
            this.teacherCount = res["teacherCount"].toString().replace(/(\d)(?=(\d\d)+\d$)/g, "$1,");
            this.schoolCount = res["schoolCount"].toString().replace(/(\d)(?=(\d\d)+\d$)/g, "$1,");

            this.markers = sorted;

            //getting relative colors for all markers:::::::::::
            let colors = this.commonService.getRelativeColors(sorted, {
              value: "attendance",
              report: "reports",
            });
            if (this.markers.length > 0) {
              for (var i = 0; i < this.markers.length; i++) {
                var color = this.commonService.color(
                  this.markers[i],
                  "attendance"
                );
                this.districtsIds.push(this.markers[i]["district_id"]);
                distNames.push({
                  id: this.markers[i]["district_id"],
                  name: this.markers[i]["district_name"],
                });

                // google map circle icon

                if (this.mapName == "googlemap") {
                  let markerColor = this.selected == "absolute"
                    ? color
                    : this.commonService.relativeColorGredient(
                      sorted[i],
                      { value: "attendance", report: "reports" },
                      colors
                    );

                  this.markers[i]['icon'] = this.globalService.initGoogleMapMarker(markerColor, 6, 1);
                }

                //initialize markers with its latitude and longitude
                var markerIcon = this.globalService.initMarkers1(
                  this.markers[i].lat,
                  this.markers[i].lng,
                  this.selected == "absolute"
                    ? color
                    : this.commonService.relativeColorGredient(
                      sorted[i],
                      { value: "attendance", report: "reports" },
                      colors
                    ),
                  0.01,
                  1,
                  this.levelWise
                );
                this.layerMarkers.addLayer(markerIcon);

                //Adding values to tooltip 
                this.generateToolTip(
                  markerIcon,
                  this.markers[i],
                  this.onClick_Marker,
                  this.levelWise
                );
              }
            }

            distNames.sort((a, b) =>
              a.name > b.name ? 1 : b.name > a.name ? -1 : 0
            );
            this.districtsNames = distNames;

            this.globalService.restrictZoom(globalMap);

            //Setting map bound for scroll::::::::::::
            globalMap.setMaxBounds([
              [this.lat - 4.5, this.lng - 6],
              [this.lat + 3.5, this.lng + 6],
            ]);

            //adjusting marker size and other UI on screen resize:::::::::::
            this.globalService.onResize(this.levelWise);
            this.commonService.loaderAndErr(this.markers);
            this.changeDetection.markForCheck();
          },
          (err) => {
            this.dateRange = "";
            this.teacherCount = 0;
            this.schoolCount = 0;
            this.changeDetection.detectChanges();
            this.markers = [];
            this.commonService.loaderAndErr(this.markers);
          }
        );
    } else {
      this.markers = [];
      this.commonService.loaderAndErr(this.markers);
    }
    globalMap.addLayer(this.layerMarkers);

  }

  blockWise(event) {
    if (this.period === "select_month" && !this.month || this.month === '') {
      alert("Please select month!");
      return;
    }
    this.commonAtStateLevel();
    this.levelWise = "Block";
    this.googleMapZoom = 7;
    if (this.months.length > 0) {
      var month = this.months.find((a) => a.id === this.month);
      if (this.month_year.month) {
        this.fileName = `${this.reportName}_allBlocks_${month.name.trim()}_${this.year
          }_${this.commonService.dateAndTime}`;
      } else {
        this.fileName = `${this.reportName}_allBlocks_${this.period}_${this.commonService.dateAndTime}`;
      }

      if (this.myData) {
        this.myData.unsubscribe();
      }
      this.myData = this.service
        .block_wise_data({
          ...this.month_year,
          ...this.timePeriod,
          ...{ management: this.management, category: this.category },
        })
        .subscribe(
          (res) => {

            if (this.districtSelected) {
              let myBlockData = res["blockData"];
              let marker = myBlockData.filter(a => {
                if (a.district_id === Number(this.districtSlectedId)) {

                  return a
                }

              })

              this.reportData = this.mylatlngData = marker;
              this.dateRange = res["dateRange"];
              var sorted = this.mylatlngData.sort((a, b) =>
                parseInt(a.attendance) > parseInt(b.attendance) ? 1 : -1
              );

              var blockNames = [];
              this.teacherCount = res["teacherCount"].toString().replace(/(\d)(?=(\d\d)+\d$)/g, "$1,");
              this.schoolCount = res["schoolCount"].toString().replace(/(\d)(?=(\d\d)+\d$)/g, "$1,");

              this.markers = sorted;

              //getting relative colors for all markers:::::::::::
              let colors = this.commonService.getRelativeColors(sorted, {
                value: "attendance",
                report: "reports",
              });
              if (this.markers.length !== 0) {
                for (let i = 0; i < this.markers.length; i++) {
                  var color = this.commonService.color(
                    this.markers[i],
                    "attendance"
                  );
                  this.blocksIds.push(this.markers[i]["block_id"]);
                  blockNames.push({
                    id: this.markers[i]["block_id"],
                    name: this.markers[i]["block_name"],
                    distId: this.markers[i]["dist"],
                  });

                  // google map circle icon

                  if (this.mapName == "googlemap") {
                    let markerColor = this.selected == "absolute"
                      ? color
                      : this.commonService.relativeColorGredient(
                        sorted[i],
                        { value: "attendance", report: "reports" },
                        colors
                      );

                    this.markers[i]['icon'] = this.globalService.initGoogleMapMarker(markerColor, 4, 1);
                  }

                  //initialize markers with its latitude and longitude
                  var markerIcon = this.globalService.initMarkers1(
                    this.markers[i].lat,
                    this.markers[i].lng,
                    this.selected == "absolute"
                      ? color
                      : this.commonService.relativeColorGredient(
                        sorted[i],
                        { value: "attendance", report: "reports" },
                        colors
                      ),
                    0.01,
                    1,
                    this.levelWise
                  );

                  this.layerMarkers.addLayer(markerIcon);

                  //Adding values to tooltip 
                  this.generateToolTip(
                    markerIcon,
                    this.markers[i],
                    this.onClick_Marker,
                    this.levelWise
                  );
                }
                blockNames.sort((a, b) =>
                  a.name > b.name ? 1 : b.name > a.name ? -1 : 0
                );
                this.blocksNames = blockNames;

                this.globalService.restrictZoom(globalMap);

                //Setting map bound for scroll::::::::::::
                globalMap.setMaxBounds([
                  [this.lat - 4.5, this.lng - 6],
                  [this.lat + 3.5, this.lng + 6],
                ]);

                //adjusting marker size and other UI on screen resize:::::::::::
                this.globalService.onResize(this.levelWise);
                this.commonService.loaderAndErr(this.markers);
                this.changeDetection.markForCheck();
              }
            } else if (this.blockSelected) {
              let blockData = res['blockData'];
              let marker = blockData.filter(a => {
                if (a.block_id === Number(this.blockSelectedId)) {

                  return a
                }

              })
              this.reportData = this.mylatlngData = marker;
              this.dateRange = res["dateRange"];
              var sorted = this.mylatlngData.sort((a, b) =>
                parseInt(a.attendance) > parseInt(b.attendance) ? 1 : -1
              );

              var blockNames = [];
              this.teacherCount = res["teacherCount"].toString().replace(/(\d)(?=(\d\d)+\d$)/g, "$1,");
              this.schoolCount = res["schoolCount"].toString().replace(/(\d)(?=(\d\d)+\d$)/g, "$1,");

              this.markers = sorted;

              //getting relative colors for all markers:::::::::::
              let colors = this.commonService.getRelativeColors(sorted, {
                value: "attendance",
                report: "reports",
              });
              if (this.markers.length !== 0) {
                for (let i = 0; i < this.markers.length; i++) {
                  var color = this.commonService.color(
                    this.markers[i],
                    "attendance"
                  );
                  this.blocksIds.push(this.markers[i]["block_id"]);
                  blockNames.push({
                    id: this.markers[i]["block_id"],
                    name: this.markers[i]["block_name"],
                    distId: this.markers[i]["dist"],
                  });

                  // google map circle icon

                  if (this.mapName == "googlemap") {
                    let markerColor = this.selected == "absolute"
                      ? color
                      : this.commonService.relativeColorGredient(
                        sorted[i],
                        { value: "attendance", report: "reports" },
                        colors
                      );

                    this.markers[i]['icon'] = this.globalService.initGoogleMapMarker(markerColor, 4, 1);
                  }

                  //initialize markers with its latitude and longitude
                  var markerIcon = this.globalService.initMarkers1(
                    this.markers[i].lat,
                    this.markers[i].lng,
                    this.selected == "absolute"
                      ? color
                      : this.commonService.relativeColorGredient(
                        sorted[i],
                        { value: "attendance", report: "reports" },
                        colors
                      ),
                    0.01,
                    1,
                    this.levelWise
                  );

                  this.layerMarkers.addLayer(markerIcon);

                  //Adding values to tooltip 
                  this.generateToolTip(
                    markerIcon,
                    this.markers[i],
                    this.onClick_Marker,
                    this.levelWise
                  );
                }
                blockNames.sort((a, b) =>
                  a.name > b.name ? 1 : b.name > a.name ? -1 : 0
                );
                this.blocksNames = blockNames;

                this.globalService.restrictZoom(globalMap);

                //Setting map bound for scroll::::::::::::
                globalMap.setMaxBounds([
                  [this.lat - 4.5, this.lng - 6],
                  [this.lat + 3.5, this.lng + 6],
                ]);

                //adjusting marker size and other UI on screen resize:::::::::::
                this.globalService.onResize(this.levelWise);
                this.commonService.loaderAndErr(this.markers);
                this.changeDetection.markForCheck();
              }
            } else if (this.selectedCluster) {
              let cluster = res['blockData'];
              let marker = cluster.filter(a => {
                if (a.cluster_id === Number(this.selectedCLusterId)) {
                  return a
                }

              })
              this.reportData = this.mylatlngData = marker;
              this.dateRange = res["dateRange"];
              var sorted = this.mylatlngData.sort((a, b) =>
                parseInt(a.attendance) > parseInt(b.attendance) ? 1 : -1
              );

              var blockNames = [];
              this.teacherCount = res["teacherCount"].toString().replace(/(\d)(?=(\d\d)+\d$)/g, "$1,");
              this.schoolCount = res["schoolCount"].toString().replace(/(\d)(?=(\d\d)+\d$)/g, "$1,");

              this.markers = sorted;

              //getting relative colors for all markers:::::::::::
              let colors = this.commonService.getRelativeColors(sorted, {
                value: "attendance",
                report: "reports",
              });
              if (this.markers.length !== 0) {
                for (let i = 0; i < this.markers.length; i++) {
                  var color = this.commonService.color(
                    this.markers[i],
                    "attendance"
                  );
                  this.blocksIds.push(this.markers[i]["block_id"]);
                  blockNames.push({
                    id: this.markers[i]["block_id"],
                    name: this.markers[i]["block_name"],
                    distId: this.markers[i]["dist"],
                  });

                  // google map circle icon

                  if (this.mapName == "googlemap") {
                    let markerColor = this.selected == "absolute"
                      ? color
                      : this.commonService.relativeColorGredient(
                        sorted[i],
                        { value: "attendance", report: "reports" },
                        colors
                      );

                    this.markers[i]['icon'] = this.globalService.initGoogleMapMarker(markerColor, 4, 1);
                  }

                  //initialize markers with its latitude and longitude
                  var markerIcon = this.globalService.initMarkers1(
                    this.markers[i].lat,
                    this.markers[i].lng,
                    this.selected == "absolute"
                      ? color
                      : this.commonService.relativeColorGredient(
                        sorted[i],
                        { value: "attendance", report: "reports" },
                        colors
                      ),
                    0.01,
                    1,
                    this.levelWise
                  );

                  this.layerMarkers.addLayer(markerIcon);

                  //Adding values to tooltip 
                  this.generateToolTip(
                    markerIcon,
                    this.markers[i],
                    this.onClick_Marker,
                    this.levelWise
                  );
                }
                blockNames.sort((a, b) =>
                  a.name > b.name ? 1 : b.name > a.name ? -1 : 0
                );
                this.blocksNames = blockNames;

                this.globalService.restrictZoom(globalMap);

                //Setting map bound for scroll::::::::::::
                globalMap.setMaxBounds([
                  [this.lat - 4.5, this.lng - 6],
                  [this.lat + 3.5, this.lng + 6],
                ]);

                //adjusting marker size and other UI on screen resize:::::::::::
                this.globalService.onResize(this.levelWise);
                this.commonService.loaderAndErr(this.markers);
                this.changeDetection.markForCheck();
              }
            } else {
              this.reportData = this.mylatlngData = res["blockData"];
              this.dateRange = res["dateRange"];
              var sorted = this.mylatlngData.sort((a, b) =>
                parseInt(a.attendance) > parseInt(b.attendance) ? 1 : -1
              );

              var blockNames = [];
              this.teacherCount = res["teacherCount"].toString().replace(/(\d)(?=(\d\d)+\d$)/g, "$1,");
              this.schoolCount = res["schoolCount"].toString().replace(/(\d)(?=(\d\d)+\d$)/g, "$1,");

              this.markers = sorted;

              //getting relative colors for all markers:::::::::::
              let colors = this.commonService.getRelativeColors(sorted, {
                value: "attendance",
                report: "reports",
              });
              if (this.markers.length !== 0) {
                for (let i = 0; i < this.markers.length; i++) {
                  var color = this.commonService.color(
                    this.markers[i],
                    "attendance"
                  );
                  this.blocksIds.push(this.markers[i]["block_id"]);
                  blockNames.push({
                    id: this.markers[i]["block_id"],
                    name: this.markers[i]["block_name"],
                    distId: this.markers[i]["dist"],
                  });

                  // google map circle icon

                  if (this.mapName == "googlemap") {
                    let markerColor = this.selected == "absolute"
                      ? color
                      : this.commonService.relativeColorGredient(
                        sorted[i],
                        { value: "attendance", report: "reports" },
                        colors
                      );

                    this.markers[i]['icon'] = this.globalService.initGoogleMapMarker(markerColor, 4, 1);
                  }

                  //initialize markers with its latitude and longitude
                  var markerIcon = this.globalService.initMarkers1(
                    this.markers[i].lat,
                    this.markers[i].lng,
                    this.selected == "absolute"
                      ? color
                      : this.commonService.relativeColorGredient(
                        sorted[i],
                        { value: "attendance", report: "reports" },
                        colors
                      ),
                    0.01,
                    1,
                    this.levelWise
                  );

                  this.layerMarkers.addLayer(markerIcon);

                  //Adding values to tooltip 
                  this.generateToolTip(
                    markerIcon,
                    this.markers[i],
                    this.onClick_Marker,
                    this.levelWise
                  );
                }
                blockNames.sort((a, b) =>
                  a.name > b.name ? 1 : b.name > a.name ? -1 : 0
                );
                this.blocksNames = blockNames;

                this.globalService.restrictZoom(globalMap);

                //Setting map bound for scroll::::::::::::
                globalMap.setMaxBounds([
                  [this.lat - 4.5, this.lng - 6],
                  [this.lat + 3.5, this.lng + 6],
                ]);

                //adjusting marker size and other UI on screen resize:::::::::::
                this.globalService.onResize(this.levelWise);
                this.commonService.loaderAndErr(this.markers);
                this.changeDetection.markForCheck();
              }
            }


          },
          (err) => {
            this.dateRange = "";
            this.teacherCount = 0;
            this.schoolCount = 0;
            this.changeDetection.detectChanges();
            this.markers = [];
            this.commonService.loaderAndErr(this.markers);
          }
        );
    } else {
      this.markers = [];
      this.commonService.loaderAndErr(this.markers);
    }
    globalMap.addLayer(this.layerMarkers);

  }

  clusterWise(event) {
    if (this.period === "select_month" && !this.month || this.month === '') {
      alert("Please select month!");
      return;
    }
    this.commonAtStateLevel();
    this.levelWise = "Cluster";
    this.googleMapZoom = 7;
    if (this.months.length > 0) {
      var month = this.months.find((a) => a.id === this.month);
      if (this.month_year.month) {
        this.fileName = `${this.reportName}_allClusters_${month.name.trim()}_${this.year
          }_${this.commonService.dateAndTime}`;
      } else {
        this.fileName = `${this.reportName}_allClusters_${this.period}_${this.commonService.dateAndTime}`;
      }

      if (this.myData) {
        this.myData.unsubscribe();
      }
      this.myData = this.service
        .cluster_wise_data({
          ...this.month_year,
          ...this.timePeriod,
          ...{ management: this.management, category: this.category },
        })
        .subscribe(
          (res) => {

            if (this.districtSelected) {
              let myBlockData = res["clusterData"];
              let marker = myBlockData.filter(a => {
                if (a.district_id === Number(this.districtSlectedId)) {

                  return a
                }

              })
              this.reportData = this.mylatlngData = marker;
              this.dateRange = res["dateRange"];
              var sorted = this.mylatlngData.sort((a, b) =>
                parseInt(a.attendance) > parseInt(b.attendance) ? 1 : -1
              );

              var clustNames = [];
              var blockNames = [];
              this.teacherCount = res["teacherCount"].toString().replace(/(\d)(?=(\d\d)+\d$)/g, "$1,");
              this.schoolCount = res["schoolCount"].toString().replace(/(\d)(?=(\d\d)+\d$)/g, "$1,");

              this.markers = sorted;

              //getting relative colors for all markers:::::::::::
              let colors = this.commonService.getRelativeColors(sorted, {
                value: "attendance",
                report: "reports",
              });
              if (this.markers.length !== 0) {
                for (let i = 0; i < this.markers.length; i++) {
                  var color = this.commonService.color(
                    this.markers[i],
                    "attendance"
                  );
                  this.clusterIds.push(this.markers[i]["cluster_id"]);
                  this.blocksIds.push(this.markers[i]["block_id"]);
                  if (this.markers[i]["cluster_name"] !== null) {
                    clustNames.push({
                      id: this.markers[i]["cluster_id"],
                      name: this.markers[i]["cluster_name"],
                      blockId: this.markers[i]["block_id"],
                    });
                  } else {
                    clustNames.push({
                      id: this.markers[i]["cluster_id"],
                      name: "NO NAME FOUND",
                      blockId: this.markers[i]["block_id"],
                    });
                  }
                  blockNames.push({
                    id: this.markers[i]["block_id"],
                    name: this.markers[i]["block_name"],
                    distId: this.markers[i]["district_id"],
                  });

                  // google map circle icon

                  if (this.mapName == "googlemap") {
                    let markerColor = this.selected == "absolute"
                      ? color
                      : this.commonService.relativeColorGredient(
                        sorted[i],
                        { value: "attendance", report: "reports" },
                        colors
                      );

                    this.markers[i]['icon'] = this.globalService.initGoogleMapMarker(markerColor, 2, 0.3);
                  }

                  //initialize markers with its latitude and longitude
                  var markerIcon = this.globalService.initMarkers1(
                    this.markers[i].lat,
                    this.markers[i].lng,
                    this.selected == "absolute"
                      ? color
                      : this.commonService.relativeColorGredient(
                        sorted[i],
                        { value: "attendance", report: "reports" },
                        colors
                      ),
                    0.01,
                    0.5,
                    this.levelWise
                  );

                  this.layerMarkers.addLayer(markerIcon);

                  //Adding values to tooltip 
                  this.generateToolTip(
                    markerIcon,
                    this.markers[i],
                    this.onClick_Marker,
                    this.levelWise
                  );
                }

                clustNames.sort((a, b) =>
                  a.name > b.name ? 1 : b.name > a.name ? -1 : 0
                );
                this.clusterNames = clustNames;
                blockNames.sort((a, b) =>
                  a.name > b.name ? 1 : b.name > a.name ? -1 : 0
                );
                this.blocksNames = blockNames;

                this.globalService.restrictZoom(globalMap);

                //Setting map bound for scroll::::::::::::
                globalMap.setMaxBounds([
                  [this.lat - 4.5, this.lng - 6],
                  [this.lat + 3.5, this.lng + 6],
                ]);

                //adjusting marker size and other UI on screen resize:::::::::::
                this.globalService.onResize(this.levelWise);
                this.commonService.loaderAndErr(this.markers);
                this.changeDetection.markForCheck();
              }
            } else if (this.blockSelected) {
              let blockData = res['clusterData'];
              let marker = blockData.filter(a => {
                if (a.block_id === Number(this.blockSelectedId)) {
                  return a
                }

              })
              this.reportData = this.mylatlngData = marker;
              this.dateRange = res["dateRange"];
              var sorted = this.mylatlngData.sort((a, b) =>
                parseInt(a.attendance) > parseInt(b.attendance) ? 1 : -1
              );

              var clustNames = [];
              var blockNames = [];
              this.teacherCount = res["teacherCount"].toString().replace(/(\d)(?=(\d\d)+\d$)/g, "$1,");
              this.schoolCount = res["schoolCount"].toString().replace(/(\d)(?=(\d\d)+\d$)/g, "$1,");

              this.markers = sorted;

              //getting relative colors for all markers:::::::::::
              let colors = this.commonService.getRelativeColors(sorted, {
                value: "attendance",
                report: "reports",
              });
              if (this.markers.length !== 0) {
                for (let i = 0; i < this.markers.length; i++) {
                  var color = this.commonService.color(
                    this.markers[i],
                    "attendance"
                  );
                  this.clusterIds.push(this.markers[i]["cluster_id"]);
                  this.blocksIds.push(this.markers[i]["block_id"]);
                  if (this.markers[i]["cluster_name"] !== null) {
                    clustNames.push({
                      id: this.markers[i]["cluster_id"],
                      name: this.markers[i]["cluster_name"],
                      blockId: this.markers[i]["block_id"],
                    });
                  } else {
                    clustNames.push({
                      id: this.markers[i]["cluster_id"],
                      name: "NO NAME FOUND",
                      blockId: this.markers[i]["block_id"],
                    });
                  }
                  blockNames.push({
                    id: this.markers[i]["block_id"],
                    name: this.markers[i]["block_name"],
                    distId: this.markers[i]["district_id"],
                  });

                  // google map circle icon

                  if (this.mapName == "googlemap") {
                    let markerColor = this.selected == "absolute"
                      ? color
                      : this.commonService.relativeColorGredient(
                        sorted[i],
                        { value: "attendance", report: "reports" },
                        colors
                      );

                    this.markers[i]['icon'] = this.globalService.initGoogleMapMarker(markerColor, 2, 0.3);
                  }

                  //initialize markers with its latitude and longitude
                  var markerIcon = this.globalService.initMarkers1(
                    this.markers[i].lat,
                    this.markers[i].lng,
                    this.selected == "absolute"
                      ? color
                      : this.commonService.relativeColorGredient(
                        sorted[i],
                        { value: "attendance", report: "reports" },
                        colors
                      ),
                    0.01,
                    0.5,
                    this.levelWise
                  );

                  this.layerMarkers.addLayer(markerIcon);

                  //Adding values to tooltip 
                  this.generateToolTip(
                    markerIcon,
                    this.markers[i],
                    this.onClick_Marker,
                    this.levelWise
                  );
                }

                clustNames.sort((a, b) =>
                  a.name > b.name ? 1 : b.name > a.name ? -1 : 0
                );
                this.clusterNames = clustNames;
                blockNames.sort((a, b) =>
                  a.name > b.name ? 1 : b.name > a.name ? -1 : 0
                );
                this.blocksNames = blockNames;

                this.globalService.restrictZoom(globalMap);

                //Setting map bound for scroll::::::::::::
                globalMap.setMaxBounds([
                  [this.lat - 4.5, this.lng - 6],
                  [this.lat + 3.5, this.lng + 6],
                ]);

                //adjusting marker size and other UI on screen resize:::::::::::
                this.globalService.onResize(this.levelWise);
                this.commonService.loaderAndErr(this.markers);
                this.changeDetection.markForCheck();
              }
            } else if (this.selectedCluster) {
              let cluster = res['clusterData'];
              let marker = cluster.filter(a => {
                if (a.cluster_id === Number(this.selectedCLusterId)) {
                  return a
                }

              })

              this.reportData = this.mylatlngData = marker;
              this.dateRange = res["dateRange"];
              var sorted = this.mylatlngData.sort((a, b) =>
                parseInt(a.attendance) > parseInt(b.attendance) ? 1 : -1
              );

              var clustNames = [];
              var blockNames = [];
              this.teacherCount = res["teacherCount"].toString().replace(/(\d)(?=(\d\d)+\d$)/g, "$1,");
              this.schoolCount = res["schoolCount"].toString().replace(/(\d)(?=(\d\d)+\d$)/g, "$1,");

              this.markers = sorted;

              //getting relative colors for all markers:::::::::::
              let colors = this.commonService.getRelativeColors(sorted, {
                value: "attendance",
                report: "reports",
              });
              if (this.markers.length !== 0) {
                for (let i = 0; i < this.markers.length; i++) {
                  var color = this.commonService.color(
                    this.markers[i],
                    "attendance"
                  );
                  this.clusterIds.push(this.markers[i]["cluster_id"]);
                  this.blocksIds.push(this.markers[i]["block_id"]);
                  if (this.markers[i]["cluster_name"] !== null) {
                    clustNames.push({
                      id: this.markers[i]["cluster_id"],
                      name: this.markers[i]["cluster_name"],
                      blockId: this.markers[i]["block_id"],
                    });
                  } else {
                    clustNames.push({
                      id: this.markers[i]["cluster_id"],
                      name: "NO NAME FOUND",
                      blockId: this.markers[i]["block_id"],
                    });
                  }
                  blockNames.push({
                    id: this.markers[i]["block_id"],
                    name: this.markers[i]["block_name"],
                    distId: this.markers[i]["district_id"],
                  });

                  // google map circle icon

                  if (this.mapName == "googlemap") {
                    let markerColor = this.selected == "absolute"
                      ? color
                      : this.commonService.relativeColorGredient(
                        sorted[i],
                        { value: "attendance", report: "reports" },
                        colors
                      );

                    this.markers[i]['icon'] = this.globalService.initGoogleMapMarker(markerColor, 2, 0.3);
                  }

                  //initialize markers with its latitude and longitude
                  var markerIcon = this.globalService.initMarkers1(
                    this.markers[i].lat,
                    this.markers[i].lng,
                    this.selected == "absolute"
                      ? color
                      : this.commonService.relativeColorGredient(
                        sorted[i],
                        { value: "attendance", report: "reports" },
                        colors
                      ),
                    0.01,
                    0.5,
                    this.levelWise
                  );

                  this.layerMarkers.addLayer(markerIcon);

                  //Adding values to tooltip 
                  this.generateToolTip(
                    markerIcon,
                    this.markers[i],
                    this.onClick_Marker,
                    this.levelWise
                  );
                }

                clustNames.sort((a, b) =>
                  a.name > b.name ? 1 : b.name > a.name ? -1 : 0
                );
                this.clusterNames = clustNames;
                blockNames.sort((a, b) =>
                  a.name > b.name ? 1 : b.name > a.name ? -1 : 0
                );
                this.blocksNames = blockNames;

                this.globalService.restrictZoom(globalMap);

                //Setting map bound for scroll::::::::::::
                globalMap.setMaxBounds([
                  [this.lat - 4.5, this.lng - 6],
                  [this.lat + 3.5, this.lng + 6],
                ]);

                //adjusting marker size and other UI on screen resize:::::::::::
                this.globalService.onResize(this.levelWise);
                this.commonService.loaderAndErr(this.markers);
                this.changeDetection.markForCheck();
              }
            } else {
              this.reportData = this.mylatlngData = res["clusterData"];
              this.dateRange = res["dateRange"];
              var sorted = this.mylatlngData.sort((a, b) =>
                parseInt(a.attendance) > parseInt(b.attendance) ? 1 : -1
              );

              var clustNames = [];
              var blockNames = [];
              this.teacherCount = res["teacherCount"].toString().replace(/(\d)(?=(\d\d)+\d$)/g, "$1,");
              this.schoolCount = res["schoolCount"].toString().replace(/(\d)(?=(\d\d)+\d$)/g, "$1,");

              this.markers = sorted;

              //getting relative colors for all markers:::::::::::
              let colors = this.commonService.getRelativeColors(sorted, {
                value: "attendance",
                report: "reports",
              });
              if (this.markers.length !== 0) {
                for (let i = 0; i < this.markers.length; i++) {
                  var color = this.commonService.color(
                    this.markers[i],
                    "attendance"
                  );
                  this.clusterIds.push(this.markers[i]["cluster_id"]);
                  this.blocksIds.push(this.markers[i]["block_id"]);
                  if (this.markers[i]["cluster_name"] !== null) {
                    clustNames.push({
                      id: this.markers[i]["cluster_id"],
                      name: this.markers[i]["cluster_name"],
                      blockId: this.markers[i]["block_id"],
                    });
                  } else {
                    clustNames.push({
                      id: this.markers[i]["cluster_id"],
                      name: "NO NAME FOUND",
                      blockId: this.markers[i]["block_id"],
                    });
                  }
                  blockNames.push({
                    id: this.markers[i]["block_id"],
                    name: this.markers[i]["block_name"],
                    distId: this.markers[i]["district_id"],
                  });

                  // google map circle icon

                  if (this.mapName == "googlemap") {
                    let markerColor = this.selected == "absolute"
                      ? color
                      : this.commonService.relativeColorGredient(
                        sorted[i],
                        { value: "attendance", report: "reports" },
                        colors
                      );

                    this.markers[i]['icon'] = this.globalService.initGoogleMapMarker(markerColor, 2, 0.3);
                  }

                  //initialize markers with its latitude and longitude
                  var markerIcon = this.globalService.initMarkers1(
                    this.markers[i].lat,
                    this.markers[i].lng,
                    this.selected == "absolute"
                      ? color
                      : this.commonService.relativeColorGredient(
                        sorted[i],
                        { value: "attendance", report: "reports" },
                        colors
                      ),
                    0.01,
                    0.5,
                    this.levelWise
                  );

                  this.layerMarkers.addLayer(markerIcon);

                  //Adding values to tooltip 
                  this.generateToolTip(
                    markerIcon,
                    this.markers[i],
                    this.onClick_Marker,
                    this.levelWise
                  );
                }

                clustNames.sort((a, b) =>
                  a.name > b.name ? 1 : b.name > a.name ? -1 : 0
                );
                this.clusterNames = clustNames;
                blockNames.sort((a, b) =>
                  a.name > b.name ? 1 : b.name > a.name ? -1 : 0
                );
                this.blocksNames = blockNames;

                this.globalService.restrictZoom(globalMap);

                //Setting map bound for scroll::::::::::::
                globalMap.setMaxBounds([
                  [this.lat - 4.5, this.lng - 6],
                  [this.lat + 3.5, this.lng + 6],
                ]);

                //adjusting marker size and other UI on screen resize:::::::::::
                this.globalService.onResize(this.levelWise);
                this.commonService.loaderAndErr(this.markers);
                this.changeDetection.markForCheck();
              }
            }

          },
          (err) => {
            this.dateRange = "";
            this.teacherCount = 0;
            this.schoolCount = 0;
            this.changeDetection.detectChanges();
            this.markers = [];
            this.commonService.loaderAndErr(this.markers);
          }
        );
    } else {
      this.markers = [];
      this.commonService.loaderAndErr(this.markers);
    }
    globalMap.addLayer(this.markersList);

    this.cluster = [];
  }

  schoolWise(event) {
    if (this.period === "select_month" && !this.month || this.month === '') {
      alert("Please select month!");
      return;
    }

    this.commonAtStateLevel();
    this.levelWise = "School";
    this.googleMapZoom = 7;
    if (this.months.length > 0) {
      var month = this.months.find((a) => a.id === this.month);
      if (this.month_year.month) {
        this.fileName = `${this.reportName}_allSchools_${month.name.trim()}_${this.year
          }_${this.commonService.dateAndTime}`;
      } else {
        this.fileName = `${this.reportName}_allSchools_${this.period}_${this.commonService.dateAndTime}`;
      }

      if (this.myData) {
        this.myData.unsubscribe();
      }
      this.myData = this.service
        .school_wise_data({
          ...this.month_year,
          ...this.timePeriod,
          ...{ management: this.management, category: this.category },
        })
        .subscribe(
          (res) => {


            if (this.districtSelected) {
              let myBlockData = res["schoolData"];
              let marker = myBlockData.filter(a => {
                if (a.district_id === Number(this.districtSlectedId)) {

                  return a
                }

              })
              this.reportData = this.mylatlngData = marker;
              this.dateRange = res["dateRange"];
              var sorted = this.mylatlngData.sort((a, b) =>
                parseInt(a.attendance) > parseInt(b.attendance) ? 1 : -1
              );

              this.teacherCount = res["teacherCount"].toString().replace(/(\d)(?=(\d\d)+\d$)/g, "$1,");
              this.schoolCount = res["schoolCount"].toString().replace(/(\d)(?=(\d\d)+\d$)/g, "$1,");

              this.markers = sorted;

              //getting relative colors for all markers:::::::::::
              let colors = this.commonService.getRelativeColors(sorted, {
                value: "attendance",
                report: "reports",
              });
              if (this.markers.length !== 0) {
                for (let i = 0; i < this.markers.length; i++) {
                  var color = this.commonService.color(
                    this.markers[i],
                    "attendance"
                  );
                  this.districtsIds.push(sorted[i]["district_id"]);

                  if (this.mapName == "googlemap") {
                    let markerColor = this.selected == "absolute"
                      ? color
                      : this.commonService.relativeColorGredient(
                        sorted[i],
                        { value: "attendance", report: "reports" },
                        colors
                      );

                    this.markers[i]['icon'] = this.globalService.initGoogleMapMarker(markerColor, 1, 0.3);
                  }

                  //initialize markers with its latitude and longitude
                  var markerIcon = this.globalService.initMarkers1(
                    this.markers[i].lat,
                    this.markers[i].lng,
                    this.selected == "absolute"
                      ? color
                      : this.commonService.relativeColorGredient(
                        sorted[i],
                        { value: "attendance", report: "reports" },
                        colors
                      ),
                    0,
                    0.3,
                    this.levelWise
                  );
                  this.layerMarkers.addLayer(markerIcon);

                  //Adding values to tooltip 
                  this.generateToolTip(
                    markerIcon,
                    this.markers[i],
                    this.onClick_Marker,
                    this.levelWise
                  );
                }

                globalMap.doubleClickZoom.enable();
                globalMap.scrollWheelZoom.enable();

                //Setting map bound for scroll::::::::::::
                globalMap.setMaxBounds([
                  [this.lat - 4.5, this.lng - 6],
                  [this.lat + 3.5, this.lng + 6],
                ]);

                //adjusting marker size and other UI on screen resize:::::::::::
                this.globalService.onResize(this.levelWise);
                this.commonService.loaderAndErr(this.markers);
                this.changeDetection.markForCheck();
              }
            } else if (this.blockSelected) {
              let blockData = res['schoolData'];
              let marker = blockData.filter(a => {
                if (a.block_id === Number(this.blockSelectedId)) {

                  return a
                }

              })
              this.reportData = this.mylatlngData = marker;
              this.dateRange = res["dateRange"];
              var sorted = this.mylatlngData.sort((a, b) =>
                parseInt(a.attendance) > parseInt(b.attendance) ? 1 : -1
              );

              this.teacherCount = res["teacherCount"].toString().replace(/(\d)(?=(\d\d)+\d$)/g, "$1,");
              this.schoolCount = res["schoolCount"].toString().replace(/(\d)(?=(\d\d)+\d$)/g, "$1,");

              this.markers = sorted;

              //getting relative colors for all markers:::::::::::
              let colors = this.commonService.getRelativeColors(sorted, {
                value: "attendance",
                report: "reports",
              });
              if (this.markers.length !== 0) {
                for (let i = 0; i < this.markers.length; i++) {
                  var color = this.commonService.color(
                    this.markers[i],
                    "attendance"
                  );
                  this.districtsIds.push(sorted[i]["district_id"]);

                  if (this.mapName == "googlemap") {
                    let markerColor = this.selected == "absolute"
                      ? color
                      : this.commonService.relativeColorGredient(
                        sorted[i],
                        { value: "attendance", report: "reports" },
                        colors
                      );

                    this.markers[i]['icon'] = this.globalService.initGoogleMapMarker(markerColor, 1, 0.3);
                  }

                  //initialize markers with its latitude and longitude
                  var markerIcon = this.globalService.initMarkers1(
                    this.markers[i].lat,
                    this.markers[i].lng,
                    this.selected == "absolute"
                      ? color
                      : this.commonService.relativeColorGredient(
                        sorted[i],
                        { value: "attendance", report: "reports" },
                        colors
                      ),
                    0,
                    0.3,
                    this.levelWise
                  );
                  this.layerMarkers.addLayer(markerIcon);

                  //Adding values to tooltip 
                  this.generateToolTip(
                    markerIcon,
                    this.markers[i],
                    this.onClick_Marker,
                    this.levelWise
                  );
                }

                globalMap.doubleClickZoom.enable();
                globalMap.scrollWheelZoom.enable();

                //Setting map bound for scroll::::::::::::
                globalMap.setMaxBounds([
                  [this.lat - 4.5, this.lng - 6],
                  [this.lat + 3.5, this.lng + 6],
                ]);

                //adjusting marker size and other UI on screen resize:::::::::::
                this.globalService.onResize(this.levelWise);
                this.commonService.loaderAndErr(this.markers);
                this.changeDetection.markForCheck();
              }
            } else if (this.selectedCluster) {
              let cluster = res['schoolData']

              let marker = cluster.filter(a => {
                if (a.cluster_id === Number(this.selectedCLusterId)) {
                  return a
                }

              })
              this.reportData = this.mylatlngData = marker;
              this.dateRange = res["dateRange"];
              var sorted = this.mylatlngData.sort((a, b) =>
                parseInt(a.attendance) > parseInt(b.attendance) ? 1 : -1
              );

              this.teacherCount = res["teacherCount"].toString().replace(/(\d)(?=(\d\d)+\d$)/g, "$1,");
              this.schoolCount = res["schoolCount"].toString().replace(/(\d)(?=(\d\d)+\d$)/g, "$1,");

              this.markers = sorted;

              //getting relative colors for all markers:::::::::::
              let colors = this.commonService.getRelativeColors(sorted, {
                value: "attendance",
                report: "reports",
              });
              if (this.markers.length !== 0) {
                for (let i = 0; i < this.markers.length; i++) {
                  var color = this.commonService.color(
                    this.markers[i],
                    "attendance"
                  );
                  this.districtsIds.push(sorted[i]["district_id"]);

                  if (this.mapName == "googlemap") {
                    let markerColor = this.selected == "absolute"
                      ? color
                      : this.commonService.relativeColorGredient(
                        sorted[i],
                        { value: "attendance", report: "reports" },
                        colors
                      );

                    this.markers[i]['icon'] = this.globalService.initGoogleMapMarker(markerColor, 1, 0.3);
                  }

                  //initialize markers with its latitude and longitude
                  var markerIcon = this.globalService.initMarkers1(
                    this.markers[i].lat,
                    this.markers[i].lng,
                    this.selected == "absolute"
                      ? color
                      : this.commonService.relativeColorGredient(
                        sorted[i],
                        { value: "attendance", report: "reports" },
                        colors
                      ),
                    0,
                    0.3,
                    this.levelWise
                  );
                  this.layerMarkers.addLayer(markerIcon);

                  //Adding values to tooltip 
                  this.generateToolTip(
                    markerIcon,
                    this.markers[i],
                    this.onClick_Marker,
                    this.levelWise
                  );
                }

                globalMap.doubleClickZoom.enable();
                globalMap.scrollWheelZoom.enable();

                //Setting map bound for scroll::::::::::::
                globalMap.setMaxBounds([
                  [this.lat - 4.5, this.lng - 6],
                  [this.lat + 3.5, this.lng + 6],
                ]);

                //adjusting marker size and other UI on screen resize:::::::::::
                this.globalService.onResize(this.levelWise);
                this.commonService.loaderAndErr(this.markers);
                this.changeDetection.markForCheck();
              }
            } else {
              this.reportData = this.mylatlngData = res["schoolData"];
              this.dateRange = res["dateRange"];
              var sorted = this.mylatlngData.sort((a, b) =>
                parseInt(a.attendance) > parseInt(b.attendance) ? 1 : -1
              );

              this.teacherCount = res["teacherCount"].toString().replace(/(\d)(?=(\d\d)+\d$)/g, "$1,");
              this.schoolCount = res["schoolCount"].toString().replace(/(\d)(?=(\d\d)+\d$)/g, "$1,");

              this.markers = sorted;

              //getting relative colors for all markers:::::::::::
              let colors = this.commonService.getRelativeColors(sorted, {
                value: "attendance",
                report: "reports",
              });
              if (this.markers.length !== 0) {
                for (let i = 0; i < this.markers.length; i++) {
                  var color = this.commonService.color(
                    this.markers[i],
                    "attendance"
                  );
                  this.districtsIds.push(sorted[i]["district_id"]);

                  if (this.mapName == "googlemap") {
                    let markerColor = this.selected == "absolute"
                      ? color
                      : this.commonService.relativeColorGredient(
                        sorted[i],
                        { value: "attendance", report: "reports" },
                        colors
                      );

                    this.markers[i]['icon'] = this.globalService.initGoogleMapMarker(markerColor, 1, 0.3);
                  }

                  //initialize markers with its latitude and longitude
                  var markerIcon = this.globalService.initMarkers1(
                    this.markers[i].lat,
                    this.markers[i].lng,
                    this.selected == "absolute"
                      ? color
                      : this.commonService.relativeColorGredient(
                        sorted[i],
                        { value: "attendance", report: "reports" },
                        colors
                      ),
                    0,
                    0.3,
                    this.levelWise
                  );
                  this.layerMarkers.addLayer(markerIcon);

                  //Adding values to tooltip 
                  this.generateToolTip(
                    markerIcon,
                    this.markers[i],
                    this.onClick_Marker,
                    this.levelWise
                  );
                }

                globalMap.doubleClickZoom.enable();
                globalMap.scrollWheelZoom.enable();

                //Setting map bound for scroll::::::::::::
                globalMap.setMaxBounds([
                  [this.lat - 4.5, this.lng - 6],
                  [this.lat + 3.5, this.lng + 6],
                ]);

                //adjusting marker size and other UI on screen resize:::::::::::
                this.globalService.onResize(this.levelWise);
                this.commonService.loaderAndErr(this.markers);
                this.changeDetection.markForCheck();
              }
            }



          },
          (err) => {
            this.dateRange = "";
            this.teacherCount = 0;
            this.schoolCount = 0;
            this.changeDetection.detectChanges();
            this.markers = [];
            this.commonService.loaderAndErr(this.markers);
          }
        );
    } else {
      this.markers = [];
      this.commonService.loaderAndErr(this.markers);
    }
    globalMap.addLayer(this.layerMarkers);

  }

  commonAtStateLevel() {
    globalMap.removeLayer(this.markersList);
    this.layerMarkers.clearLayers();
    this.commonService.errMsg();
    this.reportData = [];
    this.markers = [];
    // this.teacherCount = 0;
    // this.schoolCount = 0;
    this.blockHidden = true;
    this.clusterHidden = true;
    this.dist = false;
    this.blok = false;
    this.clust = false;
    this.skul = true;
    this.hierName = "";
    this.distName = "";
    this.blockName = "";
    this.title = "";
    this.titleName = "";
    this.clustName = "";
    this.globalService.latitude = this.lat = this.globalService.mapCenterLatlng.lat;
    this.globalService.longitude = this.lng = this.globalService.mapCenterLatlng.lng;

    //Setting map bound for scroll::::::::::::
    globalMap.setMaxBounds([
      [this.lat - 4.5, this.lng - 6],
      [this.lat + 3.5, this.lng + 6],
    ]);
    this.markerData = {};
    this.myDistrict = null;
    this.valueRange = undefined;
    this.selectedIndex = undefined;
    this.deSelect();
  }

  clickedMarker(event, label) {
    var level;
    var obj = {};
    if (this.districtsIds.includes(label.district_id)) {
      level = "District";
      localStorage.setItem("dist", label.district_name);
      localStorage.setItem("distId", label.district_id);
      this.myDistData(label.district_id);
      if (event.latlng) {
        obj = {
          id: label.district_id,
          name: label.district_name,
          lat: event.latlng.lat,
          lng: event.latlng.lng,
        };
      }
    }

    if (this.blocksIds.includes(label.block_id)) {
      level = "Block";
      if (this.skul) {
        localStorage.setItem("dist", label.district_name);
        localStorage.setItem("distId", label.district_id);
      } else {
        localStorage.setItem("dist", localStorage.getItem("dist"));
        localStorage.setItem("distId", localStorage.getItem("distId"));
      }
      localStorage.setItem("block", label.block_name);
      localStorage.setItem("blockid", label.block_id);
      this.myBlockData(label.block_id);

      if (event.latlng) {
        obj = {
          id: label.block_id,
          name: label.block_name,
          lat: event.latlng.lat,
          lng: event.latlng.lng,
        };
      }
    }

    if (this.clusterIds.includes(label.cluster_id)) {
      level = "Cluster";
      localStorage.setItem("dist", label.district_name);
      localStorage.setItem("distId", label.district_id);
      localStorage.setItem("block", label.block_name);
      localStorage.setItem("blockid", label.block_id);
      localStorage.setItem("cluster", label.cluster_name);
      localStorage.setItem("clusterid", label.cluster_id);

      this.myClusterData(label.cluster_id);
      if (event.latlng) {
        obj = {
          id: label.cluster_id,
          name: label.cluster_name,
          lat: event.latlng.lat,
          lng: event.latlng.lng,
        };
      }
    }
    this.getTelemetryData(obj, event.type, level);
  }

  //Showing tooltips on markers on mouse hover...
  onMouseOver(m, infowindow) {
    m.lastOpen = infowindow;
    m.lastOpen.open();
  }

  //Hide tooltips on markers on mouse hover...
  hideInfo(m) {
    if (m.lastOpen != null) {
      m.lastOpen.close();
    }
  }

  onClickSchool(event) {
    this.levelWise = "School";
    if (event.latlng) {
      var obj = {
        id: event.target.myJsonData.school_id,
        name: event.target.myJsonData.school_name,
        lat: event.target.myJsonData.lat,
        lng: event.target.myJsonData.lng,
      };
      this.getTelemetryData(obj, event.type, this.levelWise);
    }
  }

  onClick_Marker(event) {
    var marker = event.target;
    this.markerData = marker.myJsonData;
    if (this.userAccessLevel === null || this.userAccessLevel === undefined || this.userAccessLevel === 'State') {
      this.clickedMarker(event, marker.myJsonData);
    }

  }

  // clickMarker for Google map
  onClick_AgmMarker(event, marker) {
    if (this.levelWise == "schoolPerCluster") {
      return false;
    }
    this.markerData = marker;
    if (this.userAccessLevel === null || this.userAccessLevel === undefined || this.userAccessLevel === 'State') {
      this.clickedMarker(event, marker);
    }

  }

  distSelect(event, data) {
    var distData: any = {};
    this.districtData.find((a) => {
      if (a.district_id == data) {
        distData = {
          id: a.district_id,
          name: a.district_name,
          lat: a.lat,
          lng: a.lng,
        };
      }
    });
    this.getTelemetryData(distData, event.type, "district");
    this.myDistData(data);
  }

  blockData = [];

  public districtSelected: boolean = false
  public districtSlectedId
  myDistData(data, bid?, cid?) {
    this.districtSelected = true
    this.blockSelected = false
    this.selectedCluster = false
    this.districtSlectedId = data
    this.hideAllBlockBtn = true
    this.hideAllCLusterBtn = false
    this.hideAllSchoolBtn = false
    if (this.period === "select_month" && !this.month || this.month === '') {
      alert("Please select month!");
      this.dist = false;
      this.myDistrict = '';
      $('#choose_dist').val('');
      return;
    }

    this.valueRange = undefined;
    this.selectedIndex = undefined;
    this.deSelect();

    this.levelWise = "blockPerDistrict";
    this.googleMapZoom = 9;
    globalMap.removeLayer(this.markersList);
    this.layerMarkers.clearLayers();
    this.markers = [];
    this.reportData = [];
    this.commonService.errMsg();
    // this.teacherCount = 0;
    // this.schoolCount = 0;
    this.markerData = null;

    this.dist = true;
    this.blok = false;
    this.clust = false;
    this.skul = false;
    this.blockHidden = false;
    this.clusterHidden = true;
    let obj = this.districtsNames.find((o) => o.id == data);
    this.hierName = "";
    if (this.months.length > 0) {
      var month = this.months.find((a) => a.id === this.month);
      if (this.month_year.month) {
        this.fileName = `${this.reportName}_${this.levelWise
          }s_of_district_${data}_${month.name.trim()}_${this.year}_${this.commonService.dateAndTime
          }`;
      } else {
        this.fileName = `${this.reportName}_${this.levelWise}s_of_district_${data}_${this.period}_${this.commonService.dateAndTime}`;
      }
      this.distName = { district_id: data, district_name: obj?.name };
      this.hierName = obj?.name;
      localStorage.setItem("dist", obj?.name);
      localStorage.setItem("distId", data);

      this.globalId = this.myDistrict = data;
      this.myBlock = null;

      this.month_year["id"] = data;

      if (this.myData) {
        this.myData.unsubscribe();
      }
      this.myData = this.service
        .blockPerDist({
          ...this.month_year,
          ...this.timePeriod,
          ...{ management: this.management, category: this.category },
        })
        .subscribe(
          (res) => {
            this.reportData = this.blockData = this.mylatlngData =
              res["blockData"];
            this.dateRange = res["dateRange"];
            var uniqueData = this.mylatlngData.reduce(function (
              previous,
              current
            ) {
              var object = previous.filter(
                (object) => object["block_id"] === current["block_id"]
              );
              if (object.length == 0) previous.push(current);
              return previous;
            },
              []);
            this.mylatlngData = uniqueData;
            this.globalService.latitude = this.lat = Number(
              this.mylatlngData[0]["lat"]
            );
            this.globalService.longitude = this.lng = Number(
              this.mylatlngData[0]["lng"]
            );

            var blokName = [];

            var sorted = this.mylatlngData.sort((a, b) =>
              parseInt(a.attendance) > parseInt(b.attendance) ? 1 : -1
            );

            this.markers = sorted;

            //getting relative colors for all markers:::::::::::
            let colors = this.commonService.getRelativeColors(sorted, {
              value: "attendance",
              report: "reports",
            });
            this.teacherCount = res["teacherCount"].toString().replace(/(\d)(?=(\d\d)+\d$)/g, "$1,");
            this.schoolCount = res["schoolCount"].toString().replace(/(\d)(?=(\d\d)+\d$)/g, "$1,");

            for (var i = 0; i < this.markers.length; i++) {
              var color = this.commonService.color(
                this.markers[i],
                "attendance"
              );
              this.blocksIds.push(this.markers[i]["block_id"]);
              blokName.push({
                id: this.markers[i]["block_id"],
                name: this.markers[i]["block_name"],
              });

              // google map circle icon

              if (this.mapName == "googlemap") {
                let markerColor = this.selected == "absolute"
                  ? color
                  : this.commonService.relativeColorGredient(
                    sorted[i],
                    { value: "attendance", report: "reports" },
                    colors
                  );

                this.markers[i]['icon'] = this.globalService.initGoogleMapMarker(markerColor, 5, 1);
              }

              //initialize markers with its latitude and longitude
              var markerIcon = this.globalService.initMarkers1(
                this.markers[i].lat,
                this.markers[i].lng,
                this.selected == "absolute"
                  ? color
                  : this.commonService.relativeColorGredient(
                    sorted[i],
                    { value: "attendance", report: "reports" },
                    colors
                  ),
                0.01,
                1,
                this.levelWise
              );
              this.layerMarkers.addLayer(markerIcon);

              //Adding values to tooltip 
              this.generateToolTip(
                markerIcon,
                this.markers[i],
                this.onClick_Marker,
                this.levelWise
              );
            }
            blokName.sort((a, b) =>
              a.name > b.name ? 1 : b.name > a.name ? -1 : 0
            );
            this.blocksNames = blokName;

            this.globalService.restrictZoom(globalMap);

            //Setting map bound for scroll::::::::::::
            globalMap.setMaxBounds([
              [this.lat - 1.5, this.lng - 3],
              [this.lat + 1.5, this.lng + 2],
            ]);

            //adjusting marker size and other UI on screen resize:::::::::::
            this.globalService.onResize(this.levelWise);
            this.commonService.loaderAndErr(this.markers);
            this.changeDetection.markForCheck();
            if (bid) {
              this.myBlockData(bid, cid);
            }
          },
          (err) => {
            this.dateRange = "";
            this.teacherCount = 0;
            this.schoolCount = 0;
            this.changeDetection.detectChanges();
            this.markers = [];
            this.commonService.loaderAndErr(this.markers);
          }
        );
    } else {
      this.markers = [];
      this.commonService.loaderAndErr(this.markers);
    }

    globalMap.addLayer(this.layerMarkers);
  }

  blockSelect(event, data) {
    var blokData: any = {};
    this.blockData.find((a) => {
      if (a.block_id == data) {
        blokData = {
          id: a.block_id,
          name: a.block_name,
          lat: a.lat,
          lng: a.lng,
        };
      }
    });
    this.getTelemetryData(blokData, event.type, "block");
    this.myBlockData(data);
  }

  clusterData = [];
  public blockSelected: boolean = false
  public blockSelectedId
  myBlockData(data, cid?) {
    this.districtSelected = false
    this.selectedCluster = false
    this.blockSelected = true
    this.blockSelectedId = data
    this.hideAllBlockBtn = true
    this.hideAllCLusterBtn = true
    this.hideAllSchoolBtn = false
    if (this.period === "select_month" && !this.month || this.month === '') {
      alert("Please select month!");
      this.blok = false;
      //   this.myBlock = '';
      $('#choose_block').val('');
      return;
    }

    this.valueRange = undefined;
    this.selectedIndex = undefined;
    this.deSelect();

    this.levelWise = "clusterPerBlock";
    this.googleMapZoom = 11;
    globalMap.removeLayer(this.markersList);
    this.layerMarkers.clearLayers();
    this.markers = [];
    this.reportData = [];
    this.commonService.errMsg();
    this.markerData = null;

    this.dist = false;
    this.blok = true;
    this.clust = false;
    this.skul = false;
    this.clusterHidden = false;
    this.blockHidden = false;
    if (this.months.length > 0) {
      var month = this.months.find((a) => a.id === this.month);
      if (this.month_year.month) {
        this.fileName = `${this.reportName}_${this.levelWise
          }s_of_block_${data}_${month.name.trim()}_${this.year}_${this.commonService.dateAndTime
          }`;
      } else {
        this.fileName = `${this.reportName}_${this.levelWise}s_of_block_${data}_${this.period}_${this.commonService.dateAndTime}`;
      }
      var blockNames = [];
      this.blocksNames.forEach((item) => {
        if (
          item.distId &&
          item.distId === Number(localStorage.getItem("distId"))
        ) {
          blockNames.push(item);
        }
      });

      if (blockNames.length > 1) {
        this.blocksNames = blockNames;
      }
      let obj = this.blocksNames.find((o) => o.id == data);
      localStorage.setItem("block", obj?.name);
      localStorage.setItem("blockid", data);
      this.titleName = localStorage.getItem("dist");
      this.distName = {
        district_id: Number(localStorage.getItem("distId")),
        district_name: this.titleName,
      };
      this.blockName = { block_id: data, block_name: obj?.name };
      this.hierName = obj?.name;

      this.globalId = this.myBlock = data;
      this.myDistrict = Number(localStorage.getItem("distId"));
      this.myCluster = null;

      if (this.myData) {
        this.myData.unsubscribe();
      }
      this.month_year["id"] = data;
      this.myData = this.service
        .clusterPerBlock({
          ...this.month_year,
          ...this.timePeriod,
          ...{ management: this.management, category: this.category },
        })
        .subscribe(
          (res) => {
            this.reportData = this.clusterData = this.mylatlngData =
              res["clusterDetails"];
            this.dateRange = res["dateRange"];
            var uniqueData = this.mylatlngData.reduce(function (
              previous,
              current
            ) {
              var object = previous.filter(
                (object) => object["cluster_id"] === current["cluster_id"]
              );
              if (object.length == 0) previous.push(current);
              return previous;
            },
              []);
            this.mylatlngData = uniqueData;
            this.globalService.latitude = this.lat = Number(
              this.mylatlngData[0]["lat"]
            );
            this.globalService.longitude = this.lng = Number(
              this.mylatlngData[0]["lng"]
            );
            var clustNames = [];

            var sorted = this.mylatlngData.sort((a, b) =>
              parseInt(a.attendance) > parseInt(b.attendance) ? 1 : -1
            );

            this.markers = [];
            this.teacherCount = res["teacherCount"].toString().replace(/(\d)(?=(\d\d)+\d$)/g, "$1,");
            this.schoolCount = res["schoolCount"].toString().replace(/(\d)(?=(\d\d)+\d$)/g, "$1,");
            // sorted.pop();
            this.markers = sorted;

            //getting relative colors for all markers:::::::::::
            let colors = this.commonService.getRelativeColors(sorted, {
              value: "attendance",
              report: "reports",
            });
            for (var i = 0; i < sorted.length; i++) {
              var color = this.commonService.color(
                this.markers[i],
                "attendance"
              );
              this.clusterIds.push(sorted[i]["cluster_id"]);
              if (sorted[i]["name"] !== null) {
                clustNames.push({
                  id: sorted[i]["cluster_id"],
                  name: sorted[i]["cluster_name"],
                  blockId: sorted[i]["block_id"],
                });
              } else {
                clustNames.push({
                  id: sorted[i]["cluster_id"],
                  name: "NO NAME FOUND",
                  blockId: sorted[i]["block_id"],
                });
              }

              // google map circle icon

              if (this.mapName == "googlemap") {
                let markerColor = this.selected == "absolute"
                  ? color
                  : this.commonService.relativeColorGredient(
                    sorted[i],
                    { value: "attendance", report: "reports" },
                    colors
                  );

                this.markers[i]['icon'] = this.globalService.initGoogleMapMarker(markerColor, 5, 1);
              }

              //initialize markers with its latitude and longitude
              var markerIcon = this.globalService.initMarkers1(
                this.markers[i].lat,
                this.markers[i].lng,
                this.selected == "absolute"
                  ? color
                  : this.commonService.relativeColorGredient(
                    sorted[i],
                    { value: "attendance", report: "reports" },
                    colors
                  ),
                0.01,
                1,
                this.levelWise
              );
              this.layerMarkers.addLayer(markerIcon);

              //Adding values to tooltip 
              this.generateToolTip(
                markerIcon,
                this.markers[i],
                this.onClick_Marker,
                this.levelWise
              );
            }

            clustNames.sort((a, b) =>
              a.name > b.name ? 1 : b.name > a.name ? -1 : 0
            );
            this.clusterNames = clustNames;

            this.globalService.restrictZoom(globalMap);

            //Setting map bound for scroll::::::::::::
            globalMap.setMaxBounds([
              [this.lat - 1.5, this.lng - 3],
              [this.lat + 1.5, this.lng + 2],
            ]);

            //adjusting marker size and other UI on screen resize:::::::::::
            this.globalService.onResize(this.levelWise);
            this.commonService.loaderAndErr(this.markers);
            this.changeDetection.markForCheck();
            if (cid) {
              this.myClusterData(cid);
            }
          },
          (err) => {
            this.dateRange = "";
            this.teacherCount = 0;
            this.schoolCount = 0;
            this.changeDetection.detectChanges();
            this.markers = [];
            this.commonService.loaderAndErr(this.markers);
          }
        );
    } else {
      this.markers = [];
      this.commonService.loaderAndErr(this.markers);
    }
    globalMap.addLayer(this.layerMarkers);

  }

  clusterSelect(event, data) {
    var clustData: any = {};
    this.clusterData.find((a) => {
      if (a.cluster_id == data) {
        clustData = {
          id: a.cluster_id,
          name: a.cluster_name,
          lat: a.lat,
          lng: a.lng,
        };
      }
    });
    this.getTelemetryData(clustData, event.type, "cluster");
    this.myClusterData(data);
  }

  public selectedCluster: boolean = false;
  public selectedCLusterId
  public hideAllBlockBtn: boolean = false
  public hideAllCLusterBtn: boolean = false
  public hideAllSchoolBtn: boolean = false
  myClusterData(data) {
    this.hideAllBlockBtn = true
    this.blockSelected = false
    this.districtSelected = false
    this.selectedCluster = true
    this.hideAllCLusterBtn = true
    this.hideAllSchoolBtn = true
    this.selectedCLusterId = data
    if (this.period === "select_month" && !this.month || this.month === '') {
      alert("Please select month!");
      this.cluster = false;
      this.myCluster = '';
      $('#choose_cluster').val('');
      return;
    }

    this.valueRange = undefined;
    this.selectedIndex = undefined;
    this.deSelect();

    this.levelWise = "schoolPerCluster";
    this.googleMapZoom = 13;
    globalMap.removeLayer(this.markersList);
    this.layerMarkers.clearLayers();
    this.markers = [];
    this.reportData = [];
    this.commonService.errMsg();
    // this.teacherCount = 0;
    // this.schoolCount = 0;
    this.markerData = null;

    this.dist = false;
    this.blok = false;
    this.clust = true;
    this.skul = false;

    this.clusterHidden = false;
    this.blockHidden = false;
    if (this.months.length > 0) {
      var month = this.months.find((a) => a.id === this.month);
      if (this.month_year.month) {
        this.fileName = `${this.reportName}_${this.levelWise
          }s_of_cluster_${data}_${month.name.trim()}_${this.year}_${this.commonService.dateAndTime
          }`;
      } else {
        this.fileName = `${this.reportName}_${this.levelWise}s_of_cluster_${data}_${this.period}_${this.commonService.dateAndTime}`;
      }

      let obj = this.clusterNames.find((o) => o.id == data);
      var blockNames = [];
      this.blocksNames.forEach((item) => {
        if (
          item.distId &&
          item.distId === Number(localStorage.getItem("distId"))
        ) {
          blockNames.push(item);
        }
      });
      var uniqueData;
      if (blockNames.length > 1) {
        uniqueData = blockNames.reduce(function (previous, current) {
          var object = previous.filter(
            (object) => object["id"] === current["id"]
          );
          if (object.length == 0) previous.push(current);
          return previous;
        }, []);
        this.blocksNames = uniqueData;
      }

      var clustName = [];
      this.clusterNames.forEach((item) => {
        if (
          item.blockId &&
          item.blockId === Number(localStorage.getItem("blockid"))
        ) {
          clustName.push(item);
        }
      });

      if (clustName.length > 1) {
        uniqueData = clustName.reduce(function (previous, current) {
          var object = previous.filter(
            (object) => object["id"] === current["id"]
          );
          if (object.length == 0) previous.push(current);
          return previous;
        }, []);
        this.clusterNames = uniqueData;
      }

      this.title = localStorage.getItem("block");
      this.titleName = localStorage.getItem("dist");
      var blockId = Number(localStorage.getItem("blockid"));
      this.distName = {
        district_id: Number(localStorage.getItem("distId")),
        district_name: this.titleName,
      };
      this.blockName = {
        block_id: blockId,
        block_name: this.title,
        district_id: this.distName.id,
        district_name: this.distName.name,
      };
      this.clustName = { cluster_id: data };
      this.hierName = obj.name;

      this.globalId = this.myCluster = data;
      // this.myBlock = this.myBlock;
      this.myDistrict = Number(localStorage.getItem("distId"));

      if (this.myData) {
        this.myData.unsubscribe();
      }

      this.month_year["id"] = data;
      this.myData = this.service
        .schoolsPerCluster({
          ...this.month_year,
          ...this.timePeriod,
          ...{ management: this.management, category: this.category },
        })
        .subscribe(
          (res) => {
            this.reportData = this.mylatlngData = res["schoolsDetails"];
            this.dateRange = res["dateRange"];
            var uniqueData = this.mylatlngData.reduce(function (
              previous,
              current
            ) {
              var object = previous.filter(
                (object) => object["school_id"] === current["school_id"]
              );
              if (object.length == 0) previous.push(current);
              return previous;
            },
              []);
            this.mylatlngData = uniqueData;
            this.globalService.latitude = this.lat = Number(
              this.mylatlngData[0]["lat"]
            );
            this.globalService.longitude = this.lng = Number(
              this.mylatlngData[0]["lng"]
            );

            var sorted = this.mylatlngData.sort((a, b) =>
              parseInt(a.attendance) > parseInt(b.attendance) ? 1 : -1
            );

            this.markers = [];
            this.teacherCount = res["teacherCount"].toString().replace(/(\d)(?=(\d\d)+\d$)/g, "$1,");
            this.schoolCount = res["schoolCount"].toString().replace(/(\d)(?=(\d\d)+\d$)/g, "$1,");

            this.markers = sorted;

            //getting relative colors for all markers:::::::::::
            let colors = this.commonService.getRelativeColors(sorted, {
              value: "attendance",
              report: "reports",
            });
            for (var i = 0; i < sorted.length; i++) {
              var color = this.commonService.color(
                this.markers[i],
                "attendance"
              );

              // google map circle icon

              if (this.mapName == "googlemap") {
                let markerColor = this.selected == "absolute"
                  ? color
                  : this.commonService.relativeColorGredient(
                    sorted[i],
                    { value: "attendance", report: "reports" },
                    colors
                  );

                this.markers[i]['icon'] = this.globalService.initGoogleMapMarker(markerColor, 5, 1);
              }
              //initialize markers with its latitude and longitude
              var markerIcon = this.globalService.initMarkers1(
                this.markers[i].lat,
                this.markers[i].lng,
                this.selected == "absolute"
                  ? color
                  : this.commonService.relativeColorGredient(
                    sorted[i],
                    { value: "attendance", report: "reports" },
                    colors
                  ),
                0.1,
                1,
                this.levelWise
              );
              this.layerMarkers.addLayer(markerIcon);

              //Adding values to tooltip 
              this.generateToolTip(
                markerIcon,
                this.markers[i],
                this.onClick_Marker,
                this.levelWise
              );
            }
            globalMap.doubleClickZoom.enable();
            globalMap.scrollWheelZoom.enable();

            //Setting map bound for scroll::::::::::::
            globalMap.setMaxBounds([
              [this.lat - 1.5, this.lng - 3],
              [this.lat + 1.5, this.lng + 2],
            ]);

            //adjusting marker size and other UI on screen resize:::::::::::
            this.globalService.onResize(this.levelWise);
            this.commonService.loaderAndErr(this.markers);
            this.changeDetection.markForCheck();
          },
          (err) => {
            this.dateRange = "";
            this.teacherCount = 0;
            this.schoolCount = 0;
            this.changeDetection.detectChanges();
            this.markers = [];
            this.commonService.loaderAndErr(this.markers);
          }
        );
    } else {
      this.markers = [];
      this.commonService.loaderAndErr(this.markers);
    }
    globalMap.addLayer(this.layerMarkers);

  }

  popups(markerIcon, markers, onClick_Marker) {
    let userLevel = localStorage.getItem("userLevel");
    let chklevel = false;
    switch (userLevel) {
      case "cluster":
        if (this.levelWise == "Cluster" || this.levelWise == "schoolPerCluster") {
          chklevel = true;
        }
        break;
      case "block":
        if (this.levelWise == "Cluster" || this.levelWise == "schoolPerCluster" || this.levelWise == "Block" || this.levelWise == "clusterPerBlock") {
          chklevel = true;
        }
        break;
      case "district":
        if (this.levelWise == "Cluster" || this.levelWise == "schoolPerCluster" || this.levelWise == "Block" || this.levelWise == "clusterPerBlock" || this.levelWise == "District" || this.levelWise == "blockPerDistrict") {
          chklevel = true;
        }
        break;
      default:
        chklevel = true;
        break;
    }

    // markerIcon.on("click", null);
    if (chklevel) {
      markerIcon.on("mouseover", function (e) {
        this.openPopup();
      });
      markerIcon.on("mouseout", function (e) {
        this.closePopup();
      });
      if (this.levelWise === "schoolPerCluster" || this.levelWise === "School") {
        markerIcon.on("click", this.onClickSchool, this);
      } else {
        markerIcon.on("click", onClick_Marker, this);
      }
    }
    markerIcon.myJsonData = markers;
  }

  //Generate dynamic tool-tip
  generateToolTip(
    markerIcon,
    markers,
    onClick_Marker,
    levelWise
  ) {
    this.popups(markerIcon, markers, onClick_Marker);
    var details = {};
    var orgObject = {};
    Object.keys(markers).forEach((key) => {
      if (key !== "lat") {
        details[key] = markers[key];
      }
    });
    Object.keys(details).forEach((key) => {
      if (key !== "lng") {
        orgObject[key] = details[key];
      }
    });

    let gmapObj = {};
    Object.keys(orgObject).forEach((key) => {
      if (key !== "icon") {
        gmapObj[key] = orgObject[key];
      }
    })

    var yourData = this.globalService.getInfoFrom(
      this.mapName == "googlemap" ? gmapObj : orgObject,
      "attendance",
      levelWise,
      "std-attd",
      undefined,
      undefined
    )
      .join(" <br>");
    if (this.mapName != 'googlemap') {
      const popup = R.responsivePopup({
        hasTip: false,
        autoPan: false,
        offset: [15, 20],
      }).setContent(yourData);
      markerIcon.addTo(globalMap).bindPopup(popup);
    } else {
      // this.googleTooltip.push(yourData)
      markers['label'] = yourData;

    }
  }

  getTelemetryData(data, event, level) {
    this.service.telemetryData = [];
    var obj = {};
    if (data.id != undefined) {
      if (event == "download") {
        obj = {
          pageId: "student_attendance",
          uid: this.keyCloakSevice.kc.tokenParsed.sub,
          event: event,
          level: level,
          locationid: data.id,
          locationname: data.name,
          lat: data.lat,
          lng: data.lng,
          download: 1,
        };
        this.service.telemetryData.push(obj);
      } else {
        obj = {
          pageId: "student_attendance",
          uid: this.keyCloakSevice.kc.tokenParsed.sub,
          event: event,
          level: level,
          locationid: data.id,
          locationname: data.name,
          lat: data.lat,
          lng: data.lng,
          download: 0,
        };
        this.service.telemetryData.push(obj);
      }

      this.edate = new Date();
      var dateObj = {
        year: this.edate.getFullYear(),
        month: ("0" + (this.edate.getMonth() + 1)).slice(-2),
        date: ("0" + this.edate.getDate()).slice(-2),
        hour: ("0" + this.edate.getHours()).slice(-2),
      };
      this.service.telemetrySar(dateObj).subscribe(
        (res) => { },
        (err) => {
          // this.dateRange = "";
          // this.teacherCount = "";
          // this.schoolCount = "";
          this.changeDetection.detectChanges();
        }
      );
    }
  }

  // goToprogressCard(): void {
  //   let data: any = {};

  //   if (this.levelWise === 'Block') {
  //     data.level = 'district';
  //     data.value = this.myDistrict;
  //   } else if (this.levelWise === 'Cluster') {
  //     data.level = 'block';
  //     data.value = this.myBlock;
  //   } else if (this.levelWise === 'school') {
  //     data.level = 'cluster';
  //     data.value = this.myCluster;
  //   } else {
  //     data.level = 'state';
  //     data.value = null
  //   }

  //   sessionStorage.setItem('progress-card-info', JSON.stringify(data));
  //   this._router.navigate(['/progressCard']);
  // }

  downloadRaw() {
    document.getElementById("spinner").style.display = "block";
    var selectedAcademicYear = this.academicYear;
    this.rawFileName = `teacher_attendance/raw/teacher_attendance_all_${this.levelWise.toLowerCase()}s_${selectedAcademicYear}.csv`;
    this.service.downloadFile({ fileName: this.rawFileName }).subscribe(
      (res) => {
        this.academicYear = undefined;
        document.getElementById("spinner").style.display = "none";
        window.open(`${res["downloadUrl"]}`, "_blank");
      },
      (err) => {
        alert("No Raw Data File Available in Bucket");
        document.getElementById("spinner").style.display = "none";
      }
    );
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


  //Filter data based on attendance percentage value range:::::::::::::::::::
  public valueRange = undefined;
  public prevRange = undefined;
  selectRange(value) {
    this.valueRange = value;
    this.filterRangeWiseData(value);
  }

  async filterRangeWiseData(value) {
    this.prevRange = value;
    globalMap.removeLayer(this.markersList);
    this.layerMarkers.clearLayers();

    //getting relative colors for all markers:::::::::::
    let colors = this.commonService.getRelativeColors(this.markers, {
      value: "attendance",
      report: "reports",
    });

    var markers = [];
    if (value) {
      markers = this.mylatlngData.filter(a => {
        return a['attendance'] > this.valueRange.split("-")[0] - 1 && a['attendance'] <= this.valueRange.split("-")[1]
      })
    } else {
      markers = this.mylatlngData;
    }

    this.reportData = markers;

    var distNames = [];
    var blockNames = [];
    var clustNames = [];
    this.teacherCount = 0;
    this.schoolCount = this.levelWise == 'School' || this.levelWise == 'schoolPerCluster' ? markers.length : 0;
    var stopLoader = false;
    if (markers.length > 0) {
      this.commonService.errMsg();
      for (var i = 0; i < markers.length; i++) {
        if (i == markers.length - 1) {
          stopLoader = true;
        }
        var color = this.commonService.color(
          markers[i],
          "attendance"
        );
        if (this.levelWise == "District") {
          this.districtsIds.push(markers[i]["district_id"]);
          distNames.push({
            id: markers[i]["district_id"],
            name: markers[i]["district_name"],
          });
          this.schoolCount += parseInt(markers[i]['number_of_schools'].replace(',', ''));
        }
        if (this.levelWise == "Block" || this.levelWise == "blockPerDistrict") {
          this.blocksIds.push(markers[i]["block_id"]);
          blockNames.push({
            id: markers[i]["block_id"],
            name: markers[i]["block_name"],
            distId: markers[i]["dist"],
          });
          this.schoolCount += parseInt(markers[i]['number_of_schools'].replace(',', ''));
        }
        if (this.levelWise == "Cluster" || this.levelWise == "clusterPerBlock") {
          this.clusterIds.push(markers[i]["cluster_id"]);
          this.blocksIds.push(markers[i]["block_id"]);
          clustNames.push({
            id: markers[i]["cluster_id"],
            name: markers[i]["cluster_name"],
            blockId: markers[i]["block_id"],
          });
          blockNames.push({
            id: markers[i]["block_id"],
            name: markers[i]["block_name"],
            distId: markers[i]["district_id"],
          });
          this.schoolCount += parseInt(markers[i]['number_of_schools'].replace(',', ''));
        }
        this.teacherCount += markers[i] ? parseInt(markers[i]['number_of_teachers'].replace(',', '')) : 0;

        //initialize markers with its latitude and longitude
        var markerIcon = this.globalService.initMarkers1(
          markers[i].lat,
          markers[i].lng,
          this.selected == "absolute"
            ? color
            : this.commonService.relativeColorGredient(
              markers[i],
              { value: "attendance", report: "reports" },
              colors
            ),
          this.levelWise == "School" ? 1 : 0.01,
          this.levelWise == "School" ? 0.3 : 1,
          this.levelWise
        );
        this.layerMarkers.addLayer(markerIcon);

        //Adding values to tooltip 
        this.generateToolTip(
          markerIcon,
          markers[i],
          this.onClick_Marker,
          this.levelWise
        );
      }

      stopLoader ? this.commonService.loaderAndErr(markers) : "";
      this.schoolCount = this.schoolCount.toString().replace(/(\d)(?=(\d\d)+\d$)/g, "$1,");
      this.teacherCount = this.teacherCount.toString().replace(/(\d)(?=(\d\d)+\d$)/g, "$1,");
    }
    this.markers = markers

    if (this.levelWise == "District") {
      distNames.sort((a, b) =>
        a.name > b.name ? 1 : b.name > a.name ? -1 : 0
      );
      this.districtsNames = distNames;
    }
    if (this.levelWise == "blockPerDistrict") {
      blockNames.sort((a, b) =>
        a.name > b.name ? 1 : b.name > a.name ? -1 : 0
      );
      this.blocksNames = blockNames;
    }
    if (this.levelWise == "clusterPerBlock") {
      clustNames.sort((a, b) =>
        a.name > b.name ? 1 : b.name > a.name ? -1 : 0
      );
      this.clusterNames = clustNames;
    }

    //adjusting marker size and other UI on screen resize:::::::::::
    this.globalService.onResize(this.levelWise);
    this.commonService.loaderAndErr(markers)
    this.changeDetection.detectChanges();
  }

  public selectedIndex;
  select(i) {
    this.selectedIndex = i;
    document.getElementById(`${i}`) ? document.getElementById(`${i}`).style.border = this.height < 1100 ? "2px solid gray" : "6px solid gray" : "";
    document.getElementById(`${i}`) ? document.getElementById(`${i}`).style.transform = "scale(1.1)" : "";
    this.deSelect();
  }

  deSelect() {
    var elements = document.getElementsByClassName('legends');
    for (var j = 0; j < elements.length; j++) {
      if (this.selectedIndex !== j) {
        elements[j]['style'].border = "1px solid transparent";
        elements[j]['style'].transform = "scale(1.0)";
      }
    }
  }

  reset(value) {
    this.valueRange = value;
    this.selectedIndex = undefined;
    this.deSelect();
    this.filterRangeWiseData(value);
  }

}
