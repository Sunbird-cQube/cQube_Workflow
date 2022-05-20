import {
  Component,
  OnInit,
  ChangeDetectionStrategy,
  ChangeDetectorRef,
  ViewEncapsulation,
} from "@angular/core";
import { HttpClient } from "@angular/common/http";
import { ExceptionReportService } from "../../../services/exception-report.service";
import { Router } from "@angular/router";
import * as L from "leaflet";
import * as R from "leaflet-responsive-popup";
import { KeycloakSecurityService } from "../../../keycloak-security.service";
import { AppServiceComponent } from "../../../app.service";
import { MapService, globalMap } from '../../../services/map-services/maps.service';
import { environment } from "src/environments/environment";
declare const $;

@Component({
  selector: "app-student-attendance-exception",
  templateUrl: "./student-attendance-exception.component.html",
  styleUrls: ["./student-attendance-exception.component.css"],
  changeDetection: ChangeDetectionStrategy.OnPush,
  encapsulation: ViewEncapsulation.None,
})
export class StudentAttendanceExceptionComponent implements OnInit {
  state;
  edate;
  public waterMark = environment.water_mark
  public telemData = {};
  public disabled = false;
  public title: string = "";
  public titleName: string = "";
  public districts: any = [];
  public blocks: any = [];
  public cluster: any = [];
  public schools: any = [];
  public districtsIds: any = [];
  public blocksIds: any = [];
  public clusterIds: any = [];
  public schoolsIds: any = [];
  public districtsNames: any = [];
  public blocksNames: any = [];
  public clusterNames: any = [];
  public schoolsNames: any = [];
  public id: any = "";
  public distHidden: boolean = true;
  public blockHidden: boolean = true;
  public clusterHidden: boolean = true;
  public myDistrict: any;
  public myBlock: any;
  public myCluster: any;
  public colors: any;
  public schoolsWithMissingData: any;
  public schoolCount: any;
  public dateRange: any = "";
  public dist: boolean = false;
  public blok: boolean = false;
  public clust: boolean = false;
  public skul: boolean = true;
  public hierName: any;
  public distName: any;
  public blockName: any;
  public clustName: any;
  public markerData;
  public layerMarkers: any = new L.layerGroup();
  public markersList = new L.FeatureGroup();
  public level: any = "District";

  // google maps zoom level
  public zoom: number = 7;

  public labelOptions: any = {};

  // initial center position for the map
  public lat: any;
  public lng: any;

  public markers: any = [];
  public mylatlngData: any = [];
  public getMonthYear: any;
  public years: any = [];
  public year;
  public months: any = [];
  public month;
  public element;
  params: any;
  mapName;
  googleMapZoom;
  geoJson = this.globalService.geoJson;

  yearMonth = true;

  timeRange = [
    { key: "overall", value: "Overall" },
    { key: "last_30_days", value: "Last 30 Days" },
    { key: "last_7_days", value: "Last 7 Days" },
    { key: "last_day", value: "Last Day" },
    { key: "select_month", value: "Year and Month" },
  ];
  period = "overall";
  timePeriod = {};

  managementName;
  management;
  category;

  constructor(
    public http: HttpClient,
    public service: ExceptionReportService,
    public router: Router,
    public keyCloakSevice: KeycloakSecurityService,
    private changeDetection: ChangeDetectorRef,
    public commonService: AppServiceComponent,
    private readonly _router: Router,
    public globalService: MapService,
  ) { }

  width = window.innerWidth;
  height = window.innerHeight;
  onResize() {
    this.width = window.innerWidth;
    this.height = window.innerHeight;
  }
  typeof(value) {
    return typeof value;
  }


  public userAccessLevel = localStorage.getItem("userLevel");
  public hideIfAccessLevel: boolean = false
  public hideAccessBtn: boolean = false

  ngOnInit() {
    this.mapName = this.commonService.mapName
    this.state = this.commonService.state;
    this.globalService.latitude = this.lat = this.globalService.mapCenterLatlng.lat;
    this.globalService.longitude = this.lng = this.globalService.mapCenterLatlng.lng;
    this.changeDetection.detectChanges();
    this.globalService.initMap("sarExpMap", [[this.lat, this.lng]]);
    if (this.mapName == 'googlemap') {
      document.getElementById('leafletmap').style.display = "none";
    }
    globalMap.setMaxBounds([
      [this.lat - 4.5, this.lng - 6],
      [this.lat + 3.5, this.lng + 6],
    ]);
    this.managementName = this.management = JSON.parse(localStorage.getItem('management'))?.id;
    this.category = JSON.parse(localStorage.getItem('category')).id;
    this.managementName = this.commonService.changeingStringCases(
      this.managementName.replace(/_/g, " ")
    );
    document.getElementById("accessProgressCard").style.display = "none";
    document.getElementById("backBtn") ? document.getElementById("backBtn").style.display = "none" : "";
    this.skul = true;
    this.timePeriod = {
      period: "overall",
      report: "sarException",
    };
    this.service.getDateRange({ report: "sarException" }).subscribe(
      (res) => {
        this.getMonthYear = res;
        this.years = Object.keys(this.getMonthYear);
        if (this.years && this.years.length > 0) {
          this.changeDetection.detectChanges();
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
          if (this.month) {
            this.month_year = {
              month: null,
              year: null,
            };
            this.levelWiseFilter();
          }
        } else {
          this.dateRange = "";
          this.changeDetection.detectChanges();

          this.getMonthYear = {};
          this.levelWiseFilter();
        }
        this.toHideDropdowns
      },
      (err) => {
        this.dateRange = "";
        this.changeDetection.detectChanges();

        this.getMonthYear = {};
        this.commonService.loaderAndErr(this.markers);
      }
    );

    this.hideAccessBtn = (environment.auth_api === 'cqube' || this.userAccessLevel === "" || undefined) ? true : false;
    this.selDist = (environment.auth_api === 'cqube' || this.userAccessLevel === '' || undefined) ? false : true;

    if (environment.auth_api !== 'cqube') {
      if (this.userAccessLevel !== "" || undefined) {
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

  getView1() {
    let id = localStorage.getItem("userLocation");
    let level = localStorage.getItem("userLevel");
    let clusterid = localStorage.getItem("clusterId");
    let blockid = localStorage.getItem("blockId");
    let districtid = localStorage.getItem("districtId");
    let schoolid = localStorage.getItem("schoolId");

    // if (districtid !== 'null') {
    //   this.myDistrict = Number(districtid);
    //   this.distHidden = false;
    // }
    // if (blockid !== 'null') {
    //   this.myBlock = Number(blockid);
    //   this.blockHidden = false;
    // }
    // if (clusterid !== 'null') {
    //   this.myCluster = Number(clusterid);
    //   this.clusterHidden = false;
    // }
    // if (districtid === 'null') {
    //   this.distHidden = false;
    // }


    if (level === "Cluster") {
      this.myDistrict = Number(districtid);
      this.myBlock = Number(blockid);
      this.myCluster = Number(clusterid);
      this.myDistData(districtid, blockid, clusterid)
      // this.myBlockData(blockid, clusterid)
      this.blockSelect({ type: "click" }, blockid);
      this.clusterSelect({ type: "click" }, clusterid);
      this.selCluster = true;
      this.selBlock = true;
      this.selDist = true;
    } else if (level === "Block") {
      this.myDistrict = Number(districtid);
      this.myBlock = Number(blockid);
      this.myDistData(districtid, blockid, clusterid)
      this.blockSelect({ type: "click" }, blockid);
      this.blockHidden = true
      this.selCluster = false;
      this.selBlock = true;
      this.selDist = true;
    } else if (level === "District") {
      this.selCluster = false;
      this.selBlock = false;
      this.selDist = false;

      this.myDistrict = districtid;

      this.distSelect({ type: "click" }, districtid, blockid, clusterid);

    }
  }

  showYearMonth() {

    this.yearMonth = false;
    this.month_year = {
      month: this.month,
      year: this.year,
    };
    this.timePeriod = {
      period: null,
      report: "sarException",
    };
    this.levelWiseFilter();
  }

  onPeriodSelect() {
    if (this.period != "overall") {

    } else {

    }
    this.yearMonth = true;
    this.timePeriod = {
      period: this.period,
      report: "sarException",
    };
    this.month_year = {
      month: null,
      year: null,
    };
    this.levelWiseFilter();
  }

  public fileName: any;
  public reportData: any = [];

  globalId;
  reportName = "student_attendance_exception";

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
      if (this.level != "school") {
        if (element.number_of_schools) {
          element.number_of_schools = element.number_of_schools.replace(
            /\,/g,
            ""
          );
        }
      }
      if (element.total_schools_with_missing_data) {
        element.total_schools_with_missing_data = element.total_schools_with_missing_data.replace(
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
    if (this.level == "District") {
      this.districtWise();
    }
    if (this.level == "Block") {
      this.blockWise();
    }
    if (this.level == "Cluster") {
      this.clusterWise();
    }
    if (this.level == "School") {
      this.schoolWise();
    }

    if (this.level == "blockPerDistrict") {
      this.myDistData(this.myDistrict);
    }
    if (this.level == "clusterPerBlock") {
      this.myBlockData(this.myBlock);
    }
    if (this.level == "schoolPerCluster") {
      this.myClusterData(this.myCluster);
    }
    this.changeDetection.detectChanges();
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
    this.period = "overall";
    this.level = "District";
    this.skul = true;
    this.month_year = {
      month: null,
      year: null,
    };
    this.timePeriod = {
      period: this.period,
      report: "sarException",
    };
    this.levelWiseFilter();

  }

  // google maps tooltip hover effect
  mouseOverOnmaker(infoWindow, $event: MouseEvent): void {
    infoWindow.open();
  }

  mouseOutOnmaker(infoWindow, $event: MouseEvent) {
    infoWindow.close();
  }

  async districtWise() {
    this.commonAtStateLevel();
    this.level = "District";
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
        .dist_wise_data({ ...this.month_year, ...this.timePeriod, ...{ management: this.management, category: this.category } })
        .subscribe(
          (res) => {
            this.reportData = this.districtData = this.mylatlngData =
              res["distData"];
            this.dateRange = res["dateRange"];
            var sorted = this.mylatlngData;

            var distNames = [];
            this.schoolsWithMissingData = res["missingSchoolsCount"];

            this.markers = sorted;
            let colors = this.commonService.getRelativeColors(sorted, {
              value: "percentage_schools_with_missing_data",
              report: "exception",
            });
            if (this.markers.length > 0) {
              for (var i = 0; i < this.markers.length; i++) {
                this.districtsIds.push(this.markers[i]["district_id"]);
                distNames.push({
                  id: this.markers[i]["district_id"],
                  name: this.markers[i]["district_name"],
                });

                // google map circle icon

                if (this.mapName == "googlemap") {
                  let markerColor = this.commonService.relativeColorGredient(
                    sorted[i],
                    {
                      value: "percentage_schools_with_missing_data",
                      report: "exception",
                    },
                    colors
                  )
                  this.markers[i]['icon'] = this.globalService.initGoogleMapMarker(markerColor, 5, 1);
                }

                var markerIcon = this.globalService.initMarkers1(
                  this.markers[i].lat,
                  this.markers[i].lng,
                  this.commonService.relativeColorGredient(
                    sorted[i],
                    {
                      value: "percentage_schools_with_missing_data",
                      report: "exception",
                    },
                    colors
                  ),
                  0.01,
                  1,
                  this.level
                );
                this.generateToolTip(
                  markerIcon,
                  this.markers[i],
                  this.onClick_Marker,
                  this.layerMarkers,
                  this.level
                );
              }
            }

            distNames.sort((a, b) =>
              a.name > b.name ? 1 : b.name > a.name ? -1 : 0
            );
            this.districtsNames = distNames;

            this.globalService.restrictZoom(globalMap);
            globalMap.setMaxBounds([
              [this.lat - 4.5, this.lng - 6],
              [this.lat + 3.5, this.lng + 6],
            ]);
            this.globalService.onResize(this.level);
            this.schoolCount = this.schoolCount
              .toString()
              .replace(/(\d)(?=(\d\d)+\d$)/g, "$1,");
            this.schoolsWithMissingData = this.schoolsWithMissingData
              .toString()
              .replace(/(\d)(?=(\d\d)+\d$)/g, "$1,");
            this.commonService.loaderAndErr(this.markers);
            this.changeDetection.markForCheck();
          },
          (err) => {
            this.dateRange = "";
            this.changeDetection.detectChanges();
            this.markers = [];
            this.districtsNames = [];
            this.commonService.loaderAndErr(this.markers);
          }
        );
    } else {
      this.markers = [];
      this.commonService.loaderAndErr(this.markers);
    }
    globalMap.addLayer(this.layerMarkers);
  }

  blockWise() {
    if (this.period === "select_month" && !this.month || this.month === '') {
      alert("Please select month!");
      return;
    }

    // this.commonAtStateLevel();
    this.level = "Block";
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
        .block_wise_data({ ...this.month_year, ...this.timePeriod, ...{ management: this.management, category: this.category } })
        .subscribe(
          (res) => {

            if (this.districtSelected) {
              let myBlockData = res["blockData"];

              let marker = myBlockData.filter(a => {
                if (a.district_id === this.districtSlectedId) {

                  return a
                }
              })
              
              this.reportData = this.mylatlngData = marker;
              this.dateRange = res["dateRange"];
              var sorted = this.mylatlngData;

              var blockNames = [];
              this.schoolsWithMissingData = res["missingSchoolsCount"];

              this.markers = sorted;
              let colors = this.commonService.getRelativeColors(sorted, {
                value: "percentage_schools_with_missing_data",
                report: "exception",
              });
              if (this.markers.length !== 0) {
                for (let i = 0; i < this.markers.length; i++) {
                  this.blocksIds.push(this.markers[i]["block_id"]);
                  blockNames.push({
                    id: this.markers[i]["block_id"],
                    name: this.markers[i]["block_name"],
                    distId: this.markers[i]["dist"],
                  });

                  // google map circle icon

                  if (this.mapName == "googlemap") {
                    let markerColor = this.commonService.relativeColorGredient(
                      sorted[i],
                      {
                        value: "percentage_schools_with_missing_data",
                        report: "exception",
                      },
                      colors
                    )
                    this.markers[i]['icon'] = this.globalService.initGoogleMapMarker(markerColor, 3.5, 1);
                  }
                  var markerIcon = this.globalService.initMarkers1(
                    this.markers[i].lat,
                    this.markers[i].lng,
                    this.commonService.relativeColorGredient(
                      sorted[i],
                      {
                        value: "percentage_schools_with_missing_data",
                        report: "exception",
                      },
                      colors
                    ),
                    0.01,
                    1,
                    this.level
                  );
                  this.generateToolTip(
                    markerIcon,
                    this.markers[i],
                    this.onClick_Marker,
                    this.layerMarkers,
                    this.level
                  );
                }
                blockNames.sort((a, b) =>
                  a.name > b.name ? 1 : b.name > a.name ? -1 : 0
                );
                this.blocksNames = blockNames;

                this.globalService.restrictZoom(globalMap);
                globalMap.setMaxBounds([
                  [this.lat - 4.5, this.lng - 6],
                  [this.lat + 3.5, this.lng + 6],
                ]);
                this.globalService.onResize(this.level);
                this.schoolCount = this.schoolCount
                  .toString()
                  .replace(/(\d)(?=(\d\d)+\d$)/g, "$1,");
                this.schoolsWithMissingData = this.schoolsWithMissingData
                  .toString()
                  .replace(/(\d)(?=(\d\d)+\d$)/g, "$1,");
                this.commonService.loaderAndErr(this.markers);
                this.changeDetection.markForCheck();
              }
            } else if (this.blockSelected) {
              let blockData = res['blockData']
              let marker = blockData.filter(a => {
                if (a.block_id === this.blockSelectedId) {

                  return a
                }

              })
              this.reportData = this.mylatlngData = marker;
              this.dateRange = res["dateRange"];
              var sorted = this.mylatlngData;

              var blockNames = [];
              this.schoolsWithMissingData = res["missingSchoolsCount"];

              this.markers = sorted;
              let colors = this.commonService.getRelativeColors(sorted, {
                value: "percentage_schools_with_missing_data",
                report: "exception",
              });
              if (this.markers.length !== 0) {
                for (let i = 0; i < this.markers.length; i++) {
                  this.blocksIds.push(this.markers[i]["block_id"]);
                  blockNames.push({
                    id: this.markers[i]["block_id"],
                    name: this.markers[i]["block_name"],
                    distId: this.markers[i]["dist"],
                  });

                  // google map circle icon

                  if (this.mapName == "googlemap") {
                    let markerColor = this.commonService.relativeColorGredient(
                      sorted[i],
                      {
                        value: "percentage_schools_with_missing_data",
                        report: "exception",
                      },
                      colors
                    )
                    this.markers[i]['icon'] = this.globalService.initGoogleMapMarker(markerColor, 3.5, 1);
                  }
                  var markerIcon = this.globalService.initMarkers1(
                    this.markers[i].lat,
                    this.markers[i].lng,
                    this.commonService.relativeColorGredient(
                      sorted[i],
                      {
                        value: "percentage_schools_with_missing_data",
                        report: "exception",
                      },
                      colors
                    ),
                    0.01,
                    1,
                    this.level
                  );
                  this.generateToolTip(
                    markerIcon,
                    this.markers[i],
                    this.onClick_Marker,
                    this.layerMarkers,
                    this.level
                  );
                }
                blockNames.sort((a, b) =>
                  a.name > b.name ? 1 : b.name > a.name ? -1 : 0
                );
                this.blocksNames = blockNames;

                this.globalService.restrictZoom(globalMap);
                globalMap.setMaxBounds([
                  [this.lat - 4.5, this.lng - 6],
                  [this.lat + 3.5, this.lng + 6],
                ]);
                this.globalService.onResize(this.level);
                this.schoolCount = this.schoolCount
                  .toString()
                  .replace(/(\d)(?=(\d\d)+\d$)/g, "$1,");
                this.schoolsWithMissingData = this.schoolsWithMissingData
                  .toString()
                  .replace(/(\d)(?=(\d\d)+\d$)/g, "$1,");
                this.commonService.loaderAndErr(this.markers);
                this.changeDetection.markForCheck();
              }
            } else if (this.selectedCluster) {
              let cluster = res['blockData']
              let marker = cluster.filter(a => {
                if (a.cluster_id === this.selectedCLusterId) {
                  return a
                }

              })
              this.reportData = this.mylatlngData = res["blockData"];
              this.dateRange = res["dateRange"];
              var sorted = this.mylatlngData;

              var blockNames = [];
              this.schoolsWithMissingData = res["missingSchoolsCount"];

              this.markers = sorted;
              let colors = this.commonService.getRelativeColors(sorted, {
                value: "percentage_schools_with_missing_data",
                report: "exception",
              });
              if (this.markers.length !== 0) {
                for (let i = 0; i < this.markers.length; i++) {
                  this.blocksIds.push(this.markers[i]["block_id"]);
                  blockNames.push({
                    id: this.markers[i]["block_id"],
                    name: this.markers[i]["block_name"],
                    distId: this.markers[i]["dist"],
                  });

                  // google map circle icon

                  if (this.mapName == "googlemap") {
                    let markerColor = this.commonService.relativeColorGredient(
                      sorted[i],
                      {
                        value: "percentage_schools_with_missing_data",
                        report: "exception",
                      },
                      colors
                    )
                    this.markers[i]['icon'] = this.globalService.initGoogleMapMarker(markerColor, 3.5, 1);
                  }
                  var markerIcon = this.globalService.initMarkers1(
                    this.markers[i].lat,
                    this.markers[i].lng,
                    this.commonService.relativeColorGredient(
                      sorted[i],
                      {
                        value: "percentage_schools_with_missing_data",
                        report: "exception",
                      },
                      colors
                    ),
                    0.01,
                    1,
                    this.level
                  );
                  this.generateToolTip(
                    markerIcon,
                    this.markers[i],
                    this.onClick_Marker,
                    this.layerMarkers,
                    this.level
                  );
                }
                blockNames.sort((a, b) =>
                  a.name > b.name ? 1 : b.name > a.name ? -1 : 0
                );
                this.blocksNames = blockNames;

                this.globalService.restrictZoom(globalMap);
                globalMap.setMaxBounds([
                  [this.lat - 4.5, this.lng - 6],
                  [this.lat + 3.5, this.lng + 6],
                ]);
                this.globalService.onResize(this.level);
                this.schoolCount = this.schoolCount
                  .toString()
                  .replace(/(\d)(?=(\d\d)+\d$)/g, "$1,");
                this.schoolsWithMissingData = this.schoolsWithMissingData
                  .toString()
                  .replace(/(\d)(?=(\d\d)+\d$)/g, "$1,");
                this.commonService.loaderAndErr(this.markers);
                this.changeDetection.markForCheck();
              }
            } else {
              this.reportData = this.mylatlngData = res["blockData"];
              this.dateRange = res["dateRange"];
              var sorted = this.mylatlngData;

              var blockNames = [];
              this.schoolsWithMissingData = res["missingSchoolsCount"];

              this.markers = sorted;
              let colors = this.commonService.getRelativeColors(sorted, {
                value: "percentage_schools_with_missing_data",
                report: "exception",
              });
              if (this.markers.length !== 0) {
                for (let i = 0; i < this.markers.length; i++) {
                  this.blocksIds.push(this.markers[i]["block_id"]);
                  blockNames.push({
                    id: this.markers[i]["block_id"],
                    name: this.markers[i]["block_name"],
                    distId: this.markers[i]["dist"],
                  });

                  // google map circle icon

                  if (this.mapName == "googlemap") {
                    let markerColor = this.commonService.relativeColorGredient(
                      sorted[i],
                      {
                        value: "percentage_schools_with_missing_data",
                        report: "exception",
                      },
                      colors
                    )
                    this.markers[i]['icon'] = this.globalService.initGoogleMapMarker(markerColor, 3.5, 1);
                  }
                  var markerIcon = this.globalService.initMarkers1(
                    this.markers[i].lat,
                    this.markers[i].lng,
                    this.commonService.relativeColorGredient(
                      sorted[i],
                      {
                        value: "percentage_schools_with_missing_data",
                        report: "exception",
                      },
                      colors
                    ),
                    0.01,
                    1,
                    this.level
                  );
                  this.generateToolTip(
                    markerIcon,
                    this.markers[i],
                    this.onClick_Marker,
                    this.layerMarkers,
                    this.level
                  );
                }
                blockNames.sort((a, b) =>
                  a.name > b.name ? 1 : b.name > a.name ? -1 : 0
                );
                this.blocksNames = blockNames;

                this.globalService.restrictZoom(globalMap);
                globalMap.setMaxBounds([
                  [this.lat - 4.5, this.lng - 6],
                  [this.lat + 3.5, this.lng + 6],
                ]);
                this.globalService.onResize(this.level);
                this.schoolCount = this.schoolCount
                  .toString()
                  .replace(/(\d)(?=(\d\d)+\d$)/g, "$1,");
                this.schoolsWithMissingData = this.schoolsWithMissingData
                  .toString()
                  .replace(/(\d)(?=(\d\d)+\d$)/g, "$1,");
                this.commonService.loaderAndErr(this.markers);
                this.changeDetection.markForCheck();
              }
            }

          },
          (err) => {
            this.dateRange = "";
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

  clusterWise() {
    if (this.period === "select_month" && !this.month || this.month === '') {
      alert("Please select month!");
      return;
    }
    this.commonAtStateLevel();
    this.level = "Cluster";
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
        .cluster_wise_data({ ...this.month_year, ...this.timePeriod, ...{ management: this.management, category: this.category } })
        .subscribe(
          (res) => {
            if (this.districtSelected) {

              let myBlockData = res["data"];
              let marker = myBlockData.filter(a => {
                if (a.district_id === this.districtSlectedId) {

                  return a
                }

              })
              this.reportData = this.mylatlngData = marker;
              this.dateRange = res["dateRange"];
              var sorted = this.mylatlngData;

              var clustNames = [];
              var blockNames = [];
              this.schoolsWithMissingData = res["missingSchoolsCount"];

              this.markers = sorted;
              let colors = this.commonService.getRelativeColors(sorted, {
                value: "percentage_schools_with_missing_data",
                report: "exception",
              });
              if (this.markers.length !== 0) {
                for (let i = 0; i < this.markers.length; i++) {
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
                    let markerColor = this.commonService.relativeColorGredient(
                      sorted[i],
                      {
                        value: "percentage_schools_with_missing_data",
                        report: "exception",
                      },
                      colors
                    )
                    this.markers[i]['icon'] = this.globalService.initGoogleMapMarker(markerColor, 2, 0.5);
                  }
                  var markerIcon = this.globalService.initMarkers1(
                    this.markers[i].lat,
                    this.markers[i].lng,
                    this.commonService.relativeColorGredient(
                      sorted[i],
                      {
                        value: "percentage_schools_with_missing_data",
                        report: "exception",
                      },
                      colors
                    ),
                    0.01,
                    0.5,
                    this.level
                  );
                  this.generateToolTip(
                    markerIcon,
                    this.markers[i],
                    this.onClick_Marker,
                    this.layerMarkers,
                    this.level
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
                globalMap.setMaxBounds([
                  [this.lat - 4.5, this.lng - 6],
                  [this.lat + 3.5, this.lng + 6],
                ]);
                this.globalService.onResize(this.level);
                this.schoolCount = this.schoolCount
                  .toString()
                  .replace(/(\d)(?=(\d\d)+\d$)/g, "$1,");
                this.schoolsWithMissingData = this.schoolsWithMissingData
                  .toString()
                  .replace(/(\d)(?=(\d\d)+\d$)/g, "$1,");
                this.commonService.loaderAndErr(this.markers);
                this.changeDetection.markForCheck();
              }
            } else if (this.blockSelected) {
              let blockData = res['clusterData']

              let marker = blockData.filter(a => {
                if (a.details.block_id === this.blockSelectedId) {
           
                  return a
                }

              })


              this.reportData = this.mylatlngData = marker;
              this.dateRange = res["dateRange"];
              var sorted = this.mylatlngData;

              var clustNames = [];
              var blockNames = [];
              this.schoolsWithMissingData = res["missingSchoolsCount"];

              this.markers = sorted;
              let colors = this.commonService.getRelativeColors(sorted, {
                value: "percentage_schools_with_missing_data",
                report: "exception",
              });
              if (this.markers.length !== 0) {
                for (let i = 0; i < this.markers.length; i++) {
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
                    let markerColor = this.commonService.relativeColorGredient(
                      sorted[i],
                      {
                        value: "percentage_schools_with_missing_data",
                        report: "exception",
                      },
                      colors
                    )
                    this.markers[i]['icon'] = this.globalService.initGoogleMapMarker(markerColor, 2, 0.5);
                  }
                  var markerIcon = this.globalService.initMarkers1(
                    this.markers[i].lat,
                    this.markers[i].lng,
                    this.commonService.relativeColorGredient(
                      sorted[i],
                      {
                        value: "percentage_schools_with_missing_data",
                        report: "exception",
                      },
                      colors
                    ),
                    0.01,
                    0.5,
                    this.level
                  );
                  this.generateToolTip(
                    markerIcon,
                    this.markers[i],
                    this.onClick_Marker,
                    this.layerMarkers,
                    this.level
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
                globalMap.setMaxBounds([
                  [this.lat - 4.5, this.lng - 6],
                  [this.lat + 3.5, this.lng + 6],
                ]);
                this.globalService.onResize(this.level);
                this.schoolCount = this.schoolCount
                  .toString()
                  .replace(/(\d)(?=(\d\d)+\d$)/g, "$1,");
                this.schoolsWithMissingData = this.schoolsWithMissingData
                  .toString()
                  .replace(/(\d)(?=(\d\d)+\d$)/g, "$1,");
                this.commonService.loaderAndErr(this.markers);
                this.changeDetection.markForCheck();
              }
            } else if (this.selectedCluster) {
              let cluster = res['clusterData'];

              let marker = cluster.filter(a => {
                if (a.details.cluster_id === this.selectedCLusterId) {
                  return a
                }

              })
              this.reportData = this.mylatlngData = marker;
              this.dateRange = res["dateRange"];
              var sorted = this.mylatlngData;

              var clustNames = [];
              var blockNames = [];
              this.schoolsWithMissingData = res["missingSchoolsCount"];

              this.markers = sorted;
              let colors = this.commonService.getRelativeColors(sorted, {
                value: "percentage_schools_with_missing_data",
                report: "exception",
              });
              if (this.markers.length !== 0) {
                for (let i = 0; i < this.markers.length; i++) {
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
                    let markerColor = this.commonService.relativeColorGredient(
                      sorted[i],
                      {
                        value: "percentage_schools_with_missing_data",
                        report: "exception",
                      },
                      colors
                    )
                    this.markers[i]['icon'] = this.globalService.initGoogleMapMarker(markerColor, 2, 0.5);
                  }
                  var markerIcon = this.globalService.initMarkers1(
                    this.markers[i].lat,
                    this.markers[i].lng,
                    this.commonService.relativeColorGredient(
                      sorted[i],
                      {
                        value: "percentage_schools_with_missing_data",
                        report: "exception",
                      },
                      colors
                    ),
                    0.01,
                    0.5,
                    this.level
                  );
                  this.generateToolTip(
                    markerIcon,
                    this.markers[i],
                    this.onClick_Marker,
                    this.layerMarkers,
                    this.level
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
                globalMap.setMaxBounds([
                  [this.lat - 4.5, this.lng - 6],
                  [this.lat + 3.5, this.lng + 6],
                ]);
                this.globalService.onResize(this.level);
                this.schoolCount = this.schoolCount
                  .toString()
                  .replace(/(\d)(?=(\d\d)+\d$)/g, "$1,");
                this.schoolsWithMissingData = this.schoolsWithMissingData
                  .toString()
                  .replace(/(\d)(?=(\d\d)+\d$)/g, "$1,");
                this.commonService.loaderAndErr(this.markers);
                this.changeDetection.markForCheck();
              }
            } else {
              this.reportData = this.mylatlngData = res["clusterData"];
              this.dateRange = res["dateRange"];
              var sorted = this.mylatlngData;

              var clustNames = [];
              var blockNames = [];
              this.schoolsWithMissingData = res["missingSchoolsCount"];

              this.markers = sorted;
              let colors = this.commonService.getRelativeColors(sorted, {
                value: "percentage_schools_with_missing_data",
                report: "exception",
              });
              if (this.markers.length !== 0) {
                for (let i = 0; i < this.markers.length; i++) {
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
                    let markerColor = this.commonService.relativeColorGredient(
                      sorted[i],
                      {
                        value: "percentage_schools_with_missing_data",
                        report: "exception",
                      },
                      colors
                    )
                    this.markers[i]['icon'] = this.globalService.initGoogleMapMarker(markerColor, 2, 0.5);
                  }
                  var markerIcon = this.globalService.initMarkers1(
                    this.markers[i].lat,
                    this.markers[i].lng,
                    this.commonService.relativeColorGredient(
                      sorted[i],
                      {
                        value: "percentage_schools_with_missing_data",
                        report: "exception",
                      },
                      colors
                    ),
                    0.01,
                    0.5,
                    this.level
                  );
                  this.generateToolTip(
                    markerIcon,
                    this.markers[i],
                    this.onClick_Marker,
                    this.layerMarkers,
                    this.level
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
                globalMap.setMaxBounds([
                  [this.lat - 4.5, this.lng - 6],
                  [this.lat + 3.5, this.lng + 6],
                ]);
                this.globalService.onResize(this.level);
                this.schoolCount = this.schoolCount
                  .toString()
                  .replace(/(\d)(?=(\d\d)+\d$)/g, "$1,");
                this.schoolsWithMissingData = this.schoolsWithMissingData
                  .toString()
                  .replace(/(\d)(?=(\d\d)+\d$)/g, "$1,");
                this.commonService.loaderAndErr(this.markers);
                this.changeDetection.markForCheck();
              }
            }


          },
          (err) => {
            this.dateRange = "";
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

  schoolWise() {
    if (this.period === "select_month" && !this.month || this.month === '') {
      alert("Please select month!");
      return;
    }
    this.commonAtStateLevel();
    this.level = "School";
    this.googleMapZoom = 11;
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
        .school_wise_data({ ...this.month_year, ...this.timePeriod, ...{ management: this.management, category: this.category } })
        .subscribe(
          (res) => {
            if (this.districtSelected) {
              let myBlockData = res["schoolData"];
              let marker = myBlockData.filter(a => {
                if (a.district_id === this.districtSlectedId) {

                  return a
                }

              })
              this.reportData = this.mylatlngData = marker;
              this.dateRange = res["dateRange"];
              var sorted = this.mylatlngData;

              this.schoolsWithMissingData = res["missingSchoolsCount"];

              this.markers = sorted;
              if (this.markers.length !== 0) {
                for (let i = 0; i < this.markers.length; i++) {
                  this.districtsIds.push(sorted[i]["district_id"]);
                  // google map circle icon

                  if (this.mapName == "googlemap") {
                    let markerColor = this.commonService.relativeColorGredient(
                      sorted[i],
                      {
                        value: "percentage_schools_with_missing_data",
                        report: "exception",
                      },
                      "red"
                    )
                    this.markers[i]['icon'] = this.globalService.initGoogleMapMarker(markerColor, 5, 1);
                  }

                  var markerIcon = this.globalService.initMarkers1(
                    this.markers[i].lat,
                    this.markers[i].lng,
                    "red",
                    0,
                    0.3,
                    this.level
                  );
                  this.generateToolTip(
                    markerIcon,
                    this.markers[i],
                    this.onClick_Marker,
                    this.layerMarkers,
                    this.level
                  );
                }

                globalMap.doubleClickZoom.enable();
                globalMap.scrollWheelZoom.enable();
                globalMap.setMaxBounds([
                  [this.lat - 4.5, this.lng - 6],
                  [this.lat + 3.5, this.lng + 6],
                ]);
                this.globalService.onResize(this.level);
                this.schoolCount = this.markers.length
                  .toString()
                  .replace(/(\d)(?=(\d\d)+\d$)/g, "$1,");
                this.schoolsWithMissingData = this.schoolsWithMissingData
                  .toString()
                  .replace(/(\d)(?=(\d\d)+\d$)/g, "$1,");
                this.commonService.loaderAndErr(this.markers);
                this.changeDetection.markForCheck();
              }
            } else if (this.blockSelected) {
              let blockData = res['schoolData']
              let marker = blockData.filter(a => {
                if (a.block_id === this.blockSelectedId) {
                  
                  return a
                }

              })
              this.reportData = this.mylatlngData = marker;
              this.dateRange = res["dateRange"];
              var sorted = this.mylatlngData;

              this.schoolsWithMissingData = res["missingSchoolsCount"];

              this.markers = sorted;
              if (this.markers.length !== 0) {
                for (let i = 0; i < this.markers.length; i++) {
                  this.districtsIds.push(sorted[i]["district_id"]);
                  // google map circle icon

                  if (this.mapName == "googlemap") {
                    let markerColor = this.commonService.relativeColorGredient(
                      sorted[i],
                      {
                        value: "percentage_schools_with_missing_data",
                        report: "exception",
                      },
                      "red"
                    )
                    this.markers[i]['icon'] = this.globalService.initGoogleMapMarker(markerColor, 5, 1);
                  }

                  var markerIcon = this.globalService.initMarkers1(
                    this.markers[i].lat,
                    this.markers[i].lng,
                    "red",
                    0,
                    0.3,
                    this.level
                  );
                  this.generateToolTip(
                    markerIcon,
                    this.markers[i],
                    this.onClick_Marker,
                    this.layerMarkers,
                    this.level
                  );
                }

                globalMap.doubleClickZoom.enable();
                globalMap.scrollWheelZoom.enable();
                globalMap.setMaxBounds([
                  [this.lat - 4.5, this.lng - 6],
                  [this.lat + 3.5, this.lng + 6],
                ]);
                this.globalService.onResize(this.level);
                this.schoolCount = this.markers.length
                  .toString()
                  .replace(/(\d)(?=(\d\d)+\d$)/g, "$1,");
                this.schoolsWithMissingData = this.schoolsWithMissingData
                  .toString()
                  .replace(/(\d)(?=(\d\d)+\d$)/g, "$1,");
                this.commonService.loaderAndErr(this.markers);
                this.changeDetection.markForCheck();
              }
            } else if (this.selectedCluster) {
              let cluster = res['schoolData']
              let marker = cluster.filter(a => {
                if (a.cluster_id === this.selectedCLusterId) {
                  return a
                }

              })
              this.reportData = this.mylatlngData = marker;
              this.dateRange = res["dateRange"];
              var sorted = this.mylatlngData;

              this.schoolsWithMissingData = res["missingSchoolsCount"];

              this.markers = sorted;
              if (this.markers.length !== 0) {
                for (let i = 0; i < this.markers.length; i++) {
                  this.districtsIds.push(sorted[i]["district_id"]);
                  // google map circle icon

                  if (this.mapName == "googlemap") {
                    let markerColor = this.commonService.relativeColorGredient(
                      sorted[i],
                      {
                        value: "percentage_schools_with_missing_data",
                        report: "exception",
                      },
                      "red"
                    )
                    this.markers[i]['icon'] = this.globalService.initGoogleMapMarker(markerColor, 5, 1);
                  }

                  var markerIcon = this.globalService.initMarkers1(
                    this.markers[i].lat,
                    this.markers[i].lng,
                    "red",
                    0,
                    0.3,
                    this.level
                  );
                  this.generateToolTip(
                    markerIcon,
                    this.markers[i],
                    this.onClick_Marker,
                    this.layerMarkers,
                    this.level
                  );
                }

                globalMap.doubleClickZoom.enable();
                globalMap.scrollWheelZoom.enable();
                globalMap.setMaxBounds([
                  [this.lat - 4.5, this.lng - 6],
                  [this.lat + 3.5, this.lng + 6],
                ]);
                this.globalService.onResize(this.level);
                this.schoolCount = this.markers.length
                  .toString()
                  .replace(/(\d)(?=(\d\d)+\d$)/g, "$1,");
                this.schoolsWithMissingData = this.schoolsWithMissingData
                  .toString()
                  .replace(/(\d)(?=(\d\d)+\d$)/g, "$1,");
                this.commonService.loaderAndErr(this.markers);
                this.changeDetection.markForCheck();
              }
            } else {
              this.reportData = this.mylatlngData = res["schoolData"];
              this.dateRange = res["dateRange"];
              var sorted = this.mylatlngData;

              this.schoolsWithMissingData = res["missingSchoolsCount"];

              this.markers = sorted;
              if (this.markers.length !== 0) {
                for (let i = 0; i < this.markers.length; i++) {
                  this.districtsIds.push(sorted[i]["district_id"]);
                  // google map circle icon

                  if (this.mapName == "googlemap") {
                    let markerColor = this.commonService.relativeColorGredient(
                      sorted[i],
                      {
                        value: "percentage_schools_with_missing_data",
                        report: "exception",
                      },
                      "red"
                    )
                    this.markers[i]['icon'] = this.globalService.initGoogleMapMarker(markerColor, 5, 1);
                  }

                  var markerIcon = this.globalService.initMarkers1(
                    this.markers[i].lat,
                    this.markers[i].lng,
                    "red",
                    0,
                    0.3,
                    this.level
                  );
                  this.generateToolTip(
                    markerIcon,
                    this.markers[i],
                    this.onClick_Marker,
                    this.layerMarkers,
                    this.level
                  );
                }

                globalMap.doubleClickZoom.enable();
                globalMap.scrollWheelZoom.enable();
                globalMap.setMaxBounds([
                  [this.lat - 4.5, this.lng - 6],
                  [this.lat + 3.5, this.lng + 6],
                ]);
                this.globalService.onResize(this.level);
                this.schoolCount = this.markers.length
                  .toString()
                  .replace(/(\d)(?=(\d\d)+\d$)/g, "$1,");
                this.schoolsWithMissingData = this.schoolsWithMissingData
                  .toString()
                  .replace(/(\d)(?=(\d\d)+\d$)/g, "$1,");
                this.commonService.loaderAndErr(this.markers);
                this.changeDetection.markForCheck();
              }
            }
          
          },
          (err) => {
            this.dateRange = "";
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
    this.schoolsWithMissingData = 0;
    this.schoolCount = 0;
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
    globalMap.setMaxBounds([
      [this.lat - 4.5, this.lng - 6],
      [this.lat + 3.5, this.lng + 6],
    ]);
    this.markerData = {};
    this.myDistrict = null;
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
      localStorage.setItem("blockId", label.block_id);
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
      localStorage.setItem("blockId", label.block_id);
      localStorage.setItem("cluster", label.cluster_name);
      localStorage.setItem("clusterId", label.cluster_id);

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
    this.level = "School";
    if (event.latlng) {
      var obj = {
        id: event.target.myJsonData.school_id,
        name: event.target.myJsonData.school_name,
        lat: event.target.myJsonData.lat,
        lng: event.target.myJsonData.lng,
      };
      this.getTelemetryData(obj, event.type, this.level);
    }
  }

  onClick_Marker(event) {
    var marker = event.target;
    this.markerData = marker.myJsonData;
    this.clickedMarker(event, marker.myJsonData);
  }

  // clickMarker for Google map
  onClick_AgmMarker(event, marker) {
    if (this.level == "schoolPerCluster") {
      return false;
    }
    this.markerData = marker;
    this.clickedMarker(event, marker);
  }

  distSelect(event, data, blockid?, clusterid?) {
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
    this.myDistData(data, blockid, clusterid);
  }

  blockData = [];

  public districtSelected: boolean = false
  public districtSlectedId

  myDistData(data, blockid?, clusterid?) {
    this.districtSelected = true
    this.blockSelected = false
    this.selectedCluster = false
    this.districtSlectedId = data
    this.hideAllBlockBtn = true;
    this.hideAllCLusterBtn = false;
    this.hideAllSchoolBtn = false;
    if (this.period === "select_month" && !this.month || this.month === '') {
      alert("Please select month!");
      this.dist = false;
      this.myDistrict = '';
      $('#choose_dist').val('');
      return;
    }
    this.level = "Block";
    globalMap.removeLayer(this.markersList);
    this.layerMarkers.clearLayers();
    this.markers = [];
    this.reportData = [];
    this.commonService.errMsg();
    this.schoolsWithMissingData = 0;
    this.schoolCount = 0;
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
        this.fileName = `${this.reportName}_${this.level
          }s_of_district_${data}_${month.name.trim()}_${this.year}_${this.commonService.dateAndTime
          }`;
      } else {
        this.fileName = `${this.reportName}_${this.level}s_of_district_${data}_${this.period}_${this.commonService.dateAndTime}`;
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
        .blockPerDist({ ...this.month_year, ...this.timePeriod, ...{ management: this.management, category: this.category } })
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

            var sorted = this.mylatlngData;

            this.markers = sorted;
            this.schoolsWithMissingData = res["missingSchoolsCount"];
            let colors = this.commonService.getRelativeColors(sorted, {
              value: "percentage_schools_with_missing_data",
              report: "exception",
            });
            for (var i = 0; i < this.markers.length; i++) {
              this.blocksIds.push(this.markers[i]["block_id"]);
              blokName.push({
                id: this.markers[i]["block_id"],
                name: this.markers[i]["block_name"],
              });

              // google map circle icon

              if (this.mapName == "googlemap") {
                let markerColor = this.commonService.relativeColorGredient(
                  sorted[i],
                  {
                    value: "percentage_schools_with_missing_data",
                    report: "exception",
                  },
                  colors
                )
                this.markers[i]['icon'] = this.globalService.initGoogleMapMarker(markerColor, 5, 1);
              }
              var markerIcon = this.globalService.initMarkers1(
                this.markers[i].lat,
                this.markers[i].lng,
                this.commonService.relativeColorGredient(
                  sorted[i],
                  {
                    value: "percentage_schools_with_missing_data",
                    report: "exception",
                  },
                  colors
                ),
                0.01,
                1,
                this.level
              );
              this.generateToolTip(
                markerIcon,
                this.markers[i],
                this.onClick_Marker,
                this.layerMarkers,
                this.level
              );
            }
            blokName.sort((a, b) =>
              a.name > b.name ? 1 : b.name > a.name ? -1 : 0
            );
            this.blocksNames = blokName;

            this.globalService.restrictZoom(globalMap);
            globalMap.setMaxBounds([
              [this.lat - 1.5, this.lng - 3],
              [this.lat + 1.5, this.lng + 2],
            ]);
            this.globalService.onResize(this.level);
            this.schoolCount = this.schoolCount
              .toString()
              .replace(/(\d)(?=(\d\d)+\d$)/g, "$1,");
            this.schoolsWithMissingData = this.schoolsWithMissingData
              .toString()
              .replace(/(\d)(?=(\d\d)+\d$)/g, "$1,");
            this.commonService.loaderAndErr(this.markers);
            this.changeDetection.markForCheck();
            if (blockid) {
              this.myBlockData(blockid, clusterid)
            }
          },
          (err) => {
            this.dateRange = "";
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
  myBlockData(data, clusterid?) {
    this.districtSelected = false
    this.selectedCluster = false
    this.blockSelected = true
    this.blockSelectedId = data
    this.hideAllBlockBtn = true;
    this.hideAllCLusterBtn = true;
    this.hideAllSchoolBtn = false;
    if (this.period === "select_month" && !this.month || this.month === '') {
      alert("Please select month!");
      this.blok = false;
      this.myBlock = '';
      $('#choose_block').val('');
      return;
    }
    this.level = "Cluster";
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
    this.blockHidden = localStorage.getItem("userLevel") === "Block" ? true : false;
    if (this.months.length > 0) {
      var month = this.months.find((a) => a.id === this.month);
      if (this.month_year.month) {
        this.fileName = `${this.reportName}_${this.level
          }s_of_block_${data}_${month.name.trim()}_${this.year}_${this.commonService.dateAndTime
          }`;
      } else {
        this.fileName = `${this.reportName}_${this.level}s_of_block_${data}_${this.period}_${this.commonService.dateAndTime}`;
      }
      var blockNames = [];

      this.blocksNames.forEach((item) => {
        if (
          item.distId &&
          item.distId === localStorage.getItem("distId")
        ) {
          blockNames.push(item);
        }
      });

      if (blockNames.length > 1) {
        this.blocksNames = blockNames;
      }
      let obj = this.blocksNames.find((o) => o.id == data);
      localStorage.setItem("block", obj.name);
      localStorage.setItem("blockId", data);
      this.titleName = localStorage.getItem("dist");
      this.distName = {
        district_id: Number(localStorage.getItem("distId")),
        district_name: this.titleName,
      };
      this.blockName = { block_id: data, block_name: obj?.name };
      this.hierName = obj.name;

      this.globalId = this.myBlock = data;
      this.myDistrict = Number(localStorage.getItem("distId"));
      this.myCluster = null;

      if (this.myData) {
        this.myData.unsubscribe();
      }
      this.month_year["id"] = data;
      this.myData = this.service
        .clusterPerBlock({ ...this.month_year, ...this.timePeriod, ...{ management: this.management, category: this.category } })
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

            var sorted = this.mylatlngData;

            this.markers = [];
            this.schoolsWithMissingData = res["missingSchoolsCount"];

            let colors = this.commonService.getRelativeColors(sorted, {
              value: "percentage_schools_with_missing_data",
              report: "exception",
            });
            this.markers = sorted;
            for (var i = 0; i < sorted.length; i++) {
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
                let markerColor = this.commonService.relativeColorGredient(
                  sorted[i],
                  {
                    value: "percentage_schools_with_missing_data",
                    report: "exception",
                  },
                  colors
                )
                this.markers[i]['icon'] = this.globalService.initGoogleMapMarker(markerColor, 5, 1);
              }

              var markerIcon = this.globalService.initMarkers1(
                this.markers[i].lat,
                this.markers[i].lng,
                this.commonService.relativeColorGredient(
                  sorted[i],
                  {
                    value: "percentage_schools_with_missing_data",
                    report: "exception",
                  },
                  colors
                ),
                0.01,
                1,
                this.level
              );
              this.generateToolTip(
                markerIcon,
                this.markers[i],
                this.onClick_Marker,
                this.layerMarkers,
                this.level
              );
            }

            clustNames.sort((a, b) =>
              a.name > b.name ? 1 : b.name > a.name ? -1 : 0
            );
            this.clusterNames = clustNames;

            this.globalService.restrictZoom(globalMap);
            globalMap.setMaxBounds([
              [this.lat - 1.5, this.lng - 3],
              [this.lat + 1.5, this.lng + 2],
            ]);
            this.globalService.onResize(this.level);
            this.schoolCount = this.schoolCount
              .toString()
              .replace(/(\d)(?=(\d\d)+\d$)/g, "$1,");
            this.schoolsWithMissingData = this.schoolsWithMissingData
              .toString()
              .replace(/(\d)(?=(\d\d)+\d$)/g, "$1,");
            this.commonService.loaderAndErr(this.markers);
            this.changeDetection.markForCheck();
            if (clusterid) {
              this.myClusterData(clusterid)
            }
          },
          (err) => {
            this.dateRange = "";
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
    this.hideAllCLusterBtn = true
    this.hideAllSchoolBtn = true
    this.blockSelected = false
    this.districtSelected = false
    this.selectedCluster = true
    this.selectedCLusterId = data
    if (this.period === "select_month" && !this.month || this.month === '') {
      alert("Please select month!");
      this.cluster = false;
      this.myCluster = '';
      $('#choose_cluster').val('');
      return;
    }
    this.level = "School";
    globalMap.removeLayer(this.markersList);
    this.layerMarkers.clearLayers();
    this.markers = [];
    this.reportData = [];
    this.commonService.errMsg();
    this.schoolsWithMissingData = 0;
    this.schoolCount = 0;
    this.markerData = null;

    this.dist = false;
    this.blok = false;
    this.clust = true;
    this.skul = false;

    this.clusterHidden = localStorage.getItem('userLevel') === "Cluster" ? true : false;
    this.blockHidden = localStorage.getItem('userLevel') === "Cluster" ? true : false;
    if (this.months.length > 0) {
      var month = this.months.find((a) => a.id === this.month);
      if (this.month_year.month) {
        this.fileName = `${this.reportName}_${this.level
          }s_of_cluster_${data}_${month.name.trim()}_${this.year}_${this.commonService.dateAndTime
          }`;
      } else {
        this.fileName = `${this.reportName}_${this.level}s_of_cluster_${data}_${this.period}_${this.commonService.dateAndTime}`;
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
          item.blockId === Number(localStorage.getItem("blockId"))
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
      var blockId = Number(localStorage.getItem("blockId"));
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
      this.hierName = obj?.name;

      this.globalId = this.myCluster = data;
      //this.myBlock = this.myBlock;
      this.myDistrict = Number(localStorage.getItem("distId"));

      if (this.myData) {
        this.myData.unsubscribe();
      }

      this.month_year["id"] = data;
      this.myData = this.service
        .schoolsPerCluster({ ...this.month_year, ...this.timePeriod, ...{ management: this.management, category: this.category } })
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

            var sorted = this.mylatlngData;

            this.markers = [];
            this.schoolsWithMissingData = res["missingSchoolsCount"];

            let colors = this.commonService.getRelativeColors(sorted, {
              value: "percentage_schools_with_missing_data",
              report: "exception",
            });
            this.markers = sorted;

            for (var i = 0; i < sorted.length; i++) {

              // google map circle icon

              if (this.mapName == "googlemap") {
                let markerColor = this.commonService.relativeColorGredient(
                  sorted[i],
                  {
                    value: "percentage_schools_with_missing_data",
                    report: "exception",
                  },
                  colors
                )
                this.markers[i]['icon'] = this.globalService.initGoogleMapMarker(markerColor, 5, 1);
              }
              // marker init
              var markerIcon = this.globalService.initMarkers1(
                this.markers[i].lat,
                this.markers[i].lng,
                this.commonService.relativeColorGredient(
                  sorted[i],
                  {
                    value: "percentage_schools_with_missing_data",
                    report: "exception",
                  },
                  colors
                ),
                0.1,
                1,
                this.level
              );
              this.generateToolTip(
                markerIcon,
                this.markers[i],
                this.onClick_Marker,
                this.layerMarkers,
                this.level
              );
            }
            globalMap.doubleClickZoom.enable();
            globalMap.scrollWheelZoom.enable();
            globalMap.setMaxBounds([
              [this.lat - 1.5, this.lng - 3],
              [this.lat + 1.5, this.lng + 2],
            ]);
            this.globalService.onResize(this.level);
            this.schoolCount = this.markers.length
              .toString()
              .replace(/(\d)(?=(\d\d)+\d$)/g, "$1,");
            this.schoolsWithMissingData = this.schoolsWithMissingData
              .toString()
              .replace(/(\d)(?=(\d\d)+\d$)/g, "$1,");
            this.commonService.loaderAndErr(this.markers);
            this.changeDetection.markForCheck();
          },
          (err) => {
            this.dateRange = "";
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

  popups(markerIcon, markers, onClick_Marker, layerMarkers, levelWise) {
    markerIcon.on("mouseover", function (e) {
      this.openPopup();
    });
    markerIcon.on("mouseout", function (e) {
      this.closePopup();
    });

    layerMarkers.addLayer(markerIcon);
    if (levelWise != "School" || levelWise == "schoolPerCluster") {
      markerIcon.on("click", onClick_Marker, this);
    } else {
      markerIcon.on("click", this.onClickSchool, this);
    }
    markerIcon.myJsonData = markers;
  }

  //Generate dynamic tool-tip
  generateToolTip(
    markerIcon,
    markers,
    onClick_Marker,
    layerMarkers,
    levelWise
  ) {
    this.popups(markerIcon, markers, onClick_Marker, layerMarkers, levelWise);
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

  getTelemetryData(data, event, level) { }

  goToprogressCard(): void {
    let data: any = {};

    if (this.level === "Block") {
      data.level = "district";
      data.value = this.myDistrict;
    } else if (this.level === "Cluster") {
      data.level = "block";
      data.value = this.myBlock;
    } else if (this.level === "school") {
      data.level = "cluster";
      data.value = this.myCluster;
    } else {
      data.level = "state";
      data.value = null;
    }

    sessionStorage.setItem("progress-card-info", JSON.stringify(data));
    this._router.navigate(["/progressCard"]);
  }
}
