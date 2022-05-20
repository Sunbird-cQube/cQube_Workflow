import {
  Component,
  OnInit,
  ChangeDetectionStrategy,
  ChangeDetectorRef,
  ViewEncapsulation,
} from "@angular/core";
import { HttpClient } from "@angular/common/http";
import { PatReportService } from "../../../services/pat-report.service";
import { Router } from "@angular/router";
import * as L from "leaflet";
import * as R from "leaflet-responsive-popup";
import { AppServiceComponent } from "../../../app.service";
import { MapService, globalMap } from '../../../services/map-services/maps.service';
import { environment } from "src/environments/environment";
declare const $;

@Component({
  selector: "app-sat-report",
  templateUrl: "./sat-report.component.html",
  styleUrls: ["./sat-report.component.css"],
  changeDetection: ChangeDetectionStrategy.OnPush,
  encapsulation: ViewEncapsulation.None,
})
export class SatReportComponent implements OnInit {
  public title: string = "";
  public titleName: string = "";
  public colors: any;
  public setColor: any;

  public waterMark = environment.water_mark

  // to assign the count of below values to show in the UI footer
  public studentCount: any;
  public schoolCount: any;
  public dateRange: any = "";

  // to hide and show the hierarchy details
  public skul: boolean = false;
  public dist: boolean = false;
  public blok: boolean = false;
  public clust: boolean = false;

  // to hide the blocks and cluster dropdowns
  public blockHidden: boolean = true;
  public clusterHidden: boolean = true;
  subjectHidden: boolean = true;

  // to set the hierarchy names
  public districtHierarchy: any = "";
  public blockHierarchy: any = "";
  public clusterHierarchy: any = "";

  // leaflet layer dependencies
  public layerMarkers = new L.layerGroup();
  public markersList = new L.FeatureGroup();

  // assigning the data to each of these to show in dropdowns and maps
  // for dropdowns
  public data: any;
  public markers: any = [];
  public dataOptions = {};

  // for maps
  public districtMarkers: any = [];
  public blockMarkers: any = [];
  public clusterMarkers: any = [];
  public schoolMarkers: any = [];

  public allDistricts: any = [];
  public allBlocks: any = [];
  public allClusters: any = [];

  // to show and hide the dropdowns based on the selection of buttons
  public stateLevel: any = 0; // 0 for buttons and 1 for dropdowns

  // to download the excel report
  public fileName: any;
  public reportData: any = [];

  // variables
  public districtId: any = "";
  public blockId: any = "";
  public clusterId: any = "";

  public myData;

  public myDistData: any;
  public myBlockData: any = [];
  public myClusterData: any = [];
  public mySchoolData: any = [];
  public level = "District";

  allGrades = [];
  allSubjects = [];
  grade;
  subject;
  mapName;
  googleMapZoom = 7;

  distFilter = [];
  blockFilter = [];
  clusterFilter = [];
  reportName = "semester_assessment_test";

  state: string;
  // initial center position for the map
  public lat: any;
  public lng: any;

  semesters: any = [];
  semester = "";
  yearSem = false;
  years = [];
  year;

  management;
  category;
  managementName;
  studentAttended: any;
  params: any;

  constructor(
    public http: HttpClient,
    public service: PatReportService,
    public commonService: AppServiceComponent,
    public router: Router,
    private changeDetection: ChangeDetectorRef,
    private readonly _router: Router,
    public globalService: MapService,
  ) {
    this.commonService.callProgressCard.subscribe(value => {
      if (value) {
        this.goToprogressCard();
        this.commonService.setProgressCardValue(false);
      }
    })
  }

  selected = "absolute";

  getColor(data) {
    this.selected = data;
    this.levelWiseFilter();
  }

  geoJson = this.globalService.geoJson;


  width = window.innerWidth;
  height = window.innerHeight;
  onResize() {
    this.width = window.innerWidth;
    this.height = window.innerHeight;
  }

  public userAccessLevel = localStorage.getItem("userLevel");
  public hideIfAccessLevel: boolean = false
  public hideAccessBtn: boolean = false

  ngOnInit() {
    this.mapName = this.commonService.mapName;
    this.state = this.commonService.state;
    this.globalService.latitude = this.lat = this.globalService.mapCenterLatlng.lat;
    this.globalService.longitude = this.lng = this.globalService.mapCenterLatlng.lng;
    this.changeDetection.detectChanges();
    this.globalService.initMap("satMap", [[this.lat, this.lng]]);
    if (this.mapName == 'googlemap') {
      document.getElementById('leafletmap').style.display = "none";
    }
    document.getElementById("accessProgressCard").style.display = "block";
    document.getElementById("backBtn") ? document.getElementById("backBtn").style.display = "none" : "";
    let params = JSON.parse(sessionStorage.getItem("report-level-info"));
    this.params = params;
    this.managementName = this.management = JSON.parse(localStorage.getItem('management')).id;
    this.category = JSON.parse(localStorage.getItem('category')).id;
    this.managementName = this.commonService.changeingStringCases(
      this.managementName.replace(/_/g, " ")
    );

    if (params && params.level) {
      this.changeDetection.detectChanges();
      if (params.timePeriod == "overall") {
        params.timePeriod = "overall";
      }
      this.service.getYears().subscribe(res => {
        try {
          res['data'].map(a => {
            this.years.push(a);
          })
          this.year = this.years[0]['academic_year'];
          let obj = this.years.find(a => a['academic_year'] == this.year);
          this.semesters = obj['semester'];
          if (this.semesters.length) {
            this.semester = this.semesters[this.semesters.length - 1].id;
          }
          this.changeDetection.detectChanges();
          let data = params.data;
          if (params.level === "district") {
            this.districtHierarchy = {
              distId: data.id,
            };

            this.districtId = data.id;
            this.getDistricts(params.level);
          } else if (params.level === "block") {
            this.districtHierarchy = {
              distId: data.districtId,
            };

            this.blockHierarchy = {
              distId: data.districtId,
              blockId: data.id,
            };

            this.districtId = data.districtId;
            this.blockId = data.id;
            this.getDistricts(params.level);
          } else if (params.level === "cluster") {
            this.districtHierarchy = {
              distId: data.districtId,
            };

            this.blockHierarchy = {
              distId: data.districtId,
              blockId: data.blockId,
            };

            this.clusterHierarchy = {
              distId: data.districtId,
              blockId: data.blockId,
              clusterId: data.id,
            };

            this.districtId = data.districtId;
            this.blockId = data.blockId;
            this.clusterId = data.id;
            this.getDistricts(params.level);
          }
        } catch (e) {
          this.commonService.loaderAndErr([]);
        }
      }, err => {
        this.commonService.loaderAndErr([]);
      });
    } else {
      this.service.getYears().subscribe(res => {
        try {
          res['data'].map(a => {
            this.years.push(a);
          })
          this.year = this.years[0]['academic_year'];
          this.onSelectYear();
        } catch (e) {
          this.commonService.loaderAndErr([]);
        }
      }, err => {
        this.commonService.loaderAndErr([]);
      });
    }
    this.hideAccessBtn = (environment.auth_api === 'cqube' || this.userAccessLevel === "" || undefined) ? true : false;
    this.selDist = (environment.auth_api === 'cqube' || this.userAccessLevel === '' || undefined) ? false : true;

    if (environment.auth_api !== 'cqube') {
      if (this.userAccessLevel !== "" || undefined) {
        this.hideIfAccessLevel = true;
      }

    }

  }

  onSelectYear() {
    let obj = this.years.find(a => a['academic_year'] == this.year);
    this.semesters = obj['semester'];
    if (this.semesters.length > 0) {
      this.semester = this.semesters[this.semesters.length - 1].id;


      this.levelWiseFilter();
      this.changeDetection.detectChanges();
    }
  }

  semSelect() {
    this.levelWiseFilter();
    this.changeDetection.detectChanges();
  }

  getDistricts(level, distId?: any): void {

    this.service
      .PATDistWiseData({
        ...{
          grade: this.grade,
          report: "sat",
          year: this.year,
          sem: this.semester,
        }, ...{ management: this.management, category: this.category }
      })
      .subscribe((res) => {
        this.markers = this.data = res["data"];
        this.allDistricts = this.districtMarkers = this.data;
        this.allDistricts.sort((a, b) =>
          a.Details.district_name > b.Details.district_name
            ? 1
            : b.Details.district_name > a.Details.district_name
              ? -1
              : 0
        );
        if (!this.districtMarkers[0]["Subjects"]) {
          this.distFilter = this.districtMarkers;
        }
        if (distId) this.ondistLinkClick(distId);
        if (level == "district") this.ondistLinkClick(this.districtId);
        else this.getBlocks(level, this.districtId, this.blockId);
      });
    // });
  }

  getBlocks(level, distId, blockId?: any): void {


    this.service
      .PATBlocksPerDistData(distId, {
        ...{
          report: "sat",
          year: this.year,
          sem: this.semester,
        }, ...{ management: this.management, category: this.category }
      })
      .subscribe((res) => {
        this.markers = this.data = res["data"];
        this.allBlocks = this.blockMarkers = this.data;

        if (!this.blockMarkers[0]["Subjects"]) {
          this.blockFilter = this.blockMarkers;
        }
        if (blockId) this.onblockLinkClick(blockId);
        if (level == "block") this.onblockLinkClick(blockId);
        else this.getClusters(this.districtId, this.blockId, this.clusterId);
      });
  }

  getClusters(distId, blockId, clusterId?: any): void {

    this.service
      .PATClustersPerBlockData(distId, blockId, {
        ...{
          report: "sat",
          year: this.year,
          sem: this.semester,
        }, ...{ management: this.management, category: this.category }
      })
      .subscribe((res) => {
        this.markers = this.data = res["data"];
        this.allClusters = this.clusterMarkers = this.data;

        if (!this.clusterMarkers[0]["Subjects"]) {
          this.clusterFilter = this.clusterMarkers;
        }
        if (clusterId)
          this.onclusterLinkClick(clusterId);
      });
  }

  onGradeSelect(data) {
    if (this.semester == "") {
      alert("Please select semester!");
      return;
    }
    this.fileName = `${this.reportName}_${this.year}_${this.semester}_${this.grade}_${this.subject ? this.subject : ""
      }_all${this.level}_${this.commonService.dateAndTime}`;
    this.grade = data;
    this.subjectHidden = false;
    this.levelWiseFilter();
  }
  onSubjectSelect(data) {
    if (this.semester == "") {
      alert("Please select semester!");
      return;
    }
    this.fileName = `${this.reportName}_${this.year}_${this.semester}_${this.grade}_${this.subject}_all${this.level}_${this.commonService.dateAndTime}`;
    this.subject = data;
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
      this.onDistrictSelect(this.districtId);
    }
    if (this.level == "clusterPerBlock") {
      this.onBlockSelect(this.blockId);
    }
    if (this.level == "schoolPerCluster") {
      this.onClusterSelect(this.clusterId);
    }
    sessionStorage.removeItem("report-level-info")
  }



  selCluster = false;
  selBlock = false;
  selDist = true;
  levelVal = 0;

  getView() {
    let id = localStorage.getItem("userLocation");
    let level = localStorage.getItem("userLevel");
    let clusterid = localStorage.getItem("clusterId");
    let blockid = localStorage.getItem("blockId");
    let districtid = localStorage.getItem("districtId");
    let schoolid = localStorage.getItem("schoolId");

    if (districtid) {
      this.districtId = districtid;
    }
    if (blockid) {
      this.blockId = blockid;
    }
    if (clusterid) {
      this.clusterId = clusterid;

    }


    if (level === "Cluster") {
      this.onclusterLinkClick(clusterid)
      this.selCluster = true;
      this.selBlock = true;
      this.selDist = true;
      // this.blockHidden = true
      // this.clusterHidden = true
    } else if (level === "Block") {

      this.onblockLinkClick(blockid)
      this.selCluster = false;
      this.selBlock = true;
      this.selDist = true;
      // this.blockHidden = true
    } else if (level === "District") {
      this.ondistLinkClick(districtid)
      this.selCluster = false;
      this.selBlock = false;
      this.selDist = true;

    }
  }

  getView1() {
    let id = localStorage.getItem("userLocation");
    let level = localStorage.getItem("userLevel");



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
      this.selDist = true;

    }
  }

  distlevel(id) {
    this.selCluster = false;
    this.selBlock = false;
    this.selDist = true;
    this.level = "blockPerDistrict";
    this.districtId = id;
    this.levelWiseFilter();
  }

  blocklevel(id) {
    this.selCluster = false;
    this.selBlock = true;
    this.selDist = true;
    this.level = "clusterPerBlock";
    this.blockId = id;
    this.levelWiseFilter();
  }

  clusterlevel(id) {
    this.selCluster = true;
    this.selBlock = true;
    this.selDist = true;
    this.level = "schoolPerCluster";
    this.clusterId = id;
    this.levelWiseFilter();
  }


  linkClick() {
    this.grade = undefined;
    this.subject = undefined;
    this.subjectHidden = true;
    this.level = "District";
    this.year = this.years[0]['academic_year'];
    this.districtSelected = false;
    this.selectedCluster = false;
    this.blockSelected = false;
    this.hideAllBlockBtn = false;
    this.hideAllCLusterBtn = false;
    this.hideAllSchoolBtn = false;
    this.onSelectYear();
  }

  // google maps
  mouseOverOnmaker(infoWindow, $event: MouseEvent): void {
    infoWindow.open();
  }

  mouseOutOnmaker(infoWindow, $event: MouseEvent) {
    infoWindow.close();
  }

  // to load all the districts for state data on the map
  districtWise() {
    try {
      this.commonService.errMsg();
      // to clear the existing data on the map layer
      globalMap.removeLayer(this.markersList);
      this.globalService.latitude = this.lat = this.globalService.mapCenterLatlng.lat;
      this.globalService.longitude = this.lng = this.globalService.mapCenterLatlng.lng;
      this.layerMarkers.clearLayers();
      this.districtId = undefined;

      this.reportData = [];
      this.level = "District";
      this.googleMapZoom = 7;
      this.valueRange = undefined;
      this.selectedIndex = undefined;
      this.deSelect();

      this.fileName = `${this.reportName}_${this.year}_${this.semester}_${this.grade ? this.grade : "allGrades"
        }_${this.subject ? this.subject : ""}_allDistricts_${this.commonService.dateAndTime
        }`;

      // these are for showing the hierarchy names based on selection
      this.skul = true;
      this.dist = false;
      this.blok = false;
      this.clust = false;

      // to show and hide the dropdowns
      this.blockHidden = true;
      this.clusterHidden = true;
      this.service
        .gradeMetaData({
          report: "sat",
          year: this.year,
          sem: this.semester,
        })
        .subscribe(
          (res) => {
            if (res["data"]["district"]) {
              this.allGrades = res["data"]["district"];
            }
            this.allGrades.sort((a, b) =>
              a.grade > b.grade ? 1 : b.grade > a.grade ? -1 : 0
            );

            if (this.myData) {
              this.myData.unsubscribe();
            }
            this.myData = this.service
              .PATDistWiseData({
                ...{
                  grade: this.grade,
                  subject: this.subject,
                  report: "sat",
                  year: this.year,
                  sem: this.semester,
                }, ...{ management: this.management, category: this.category }
              })
              .subscribe(
                (res) => {
                  this.myDistData = res;
                  this.markers = this.data = res["data"];
                  if (this.grade) {
                    this.allSubjects = this.allGrades.find(a => { return a.grade == this.grade }).subjects;
                  }
                  // to show only in dropdowns
                  this.allDistricts = this.districtMarkers = this.data;

                  if (!this.districtMarkers[0]["Subjects"]) {
                    this.distFilter = this.districtMarkers;
                  }

                  // options to set for markers in the map
                  let options = {
                    fillOpacity: 1,
                    strokeWeight: 0.01,
                    mapZoom: this.globalService.zoomLevel,
                    centerLat: this.lat,
                    centerLng: this.lng,
                    level: "District",
                  };
                  this.dataOptions = options;
                  this.globalService.restrictZoom(globalMap);
                  globalMap.setMaxBounds([
                    [options.centerLat - 4.5, options.centerLng - 6],
                    [options.centerLat + 3.5, options.centerLng + 6],
                  ]);
                  this.changeDetection.detectChanges();
                  this.genericFun(this.data, options, this.fileName);
                  this.globalService.onResize(this.level);
                  this.allDistricts.sort((a, b) =>
                    a.Details["district_name"] > b.Details["district_name"]
                      ? 1
                      : b.Details["district_name"] > a.Details["district_name"]
                        ? -1
                        : 0
                  );

                  this.schoolCount = res['footer'] && res['footer'].total_schools != null ? res['footer'].total_schools.toString().replace(/(\d)(?=(\d\d)+\d$)/g, "$1,") : null;
                  this.studentCount = res['footer'] && res['footer'].total_students != null ? res['footer'].total_students.toString().replace(/(\d)(?=(\d\d)+\d$)/g, "$1,") : null;
                  this.studentAttended = res['footer'] && res['footer'].students_attended != null ? res['footer'].students_attended.toString().replace(/(\d)(?=(\d\d)+\d$)/g, "$1,") : null;
                  this.changeDetection.detectChanges();
                },
                (err) => {
                  this.allDistricts = [];
                  this.errorHandling();
                }
              );
          },
          (error) => {
            this.errorHandling();
          }
        );

      // adding the markers to the map layers
      globalMap.addLayer(this.layerMarkers);

    } catch (e) {
      console.log(e);
    }
  }

  blockClick() {
    if (this.semester == "") {
      alert("Please select semester!");
      return;
    }
    if (this.grade) {
      this.blockWise();
    } else {
      this.blockWise();
    }
  }
  // to load all the blocks for state data on the map
  blockWise() {
    try {
      this.commonService.errMsg();
      // to clear the existing data on the map layer
      globalMap.removeLayer(this.markersList);
      this.globalService.latitude = this.lat = this.globalService.mapCenterLatlng.lat;
      this.globalService.longitude = this.lng = this.globalService.mapCenterLatlng.lng;
      this.layerMarkers.clearLayers();

      this.allGrades = [];
      this.reportData = [];
      this.districtId = undefined;
      this.blockId = undefined;
      this.level = "Block";
      this.googleMapZoom = 7;
      this.fileName = `${this.reportName}_${this.year}_${this.semester}_${this.grade ? this.grade : "allGrades"
        }_${this.subject ? this.subject : ""}_allBlocks_${this.commonService.dateAndTime
        }`;

      this.valueRange = undefined;
      this.selectedIndex = undefined;
      this.deSelect();

      // these are for showing the hierarchy names based on selection
      this.skul = true;
      this.dist = false;
      this.blok = false;
      this.clust = false;

      // to show and hide the dropdowns
      this.blockHidden = true;
      this.clusterHidden = true;

      this.service
        .gradeMetaData({
          report: "sat",
          year: this.year,
          sem: this.semester,
        })
        .subscribe(
          (res) => {
            if (res["data"]["block"]) {
              this.allGrades = res["data"]["block"];
            }
            this.allGrades.sort((a, b) =>
              a.grade > b.grade ? 1 : b.grade > a.grade ? -1 : 0
            );

            // api call to get the all clusters data
            if (this.myData) {
              this.myData.unsubscribe();
            }
            this.myData = this.service
              .PATBlockWiseData({
                ...{
                  grade: this.grade,
                  subject: this.subject,
                  report: "sat",
                  year: this.year,
                  sem: this.semester,
                }, ...{ management: this.management, category: this.category }
              })
              .subscribe(
                (res) => {

                  if (this.districtSelected) {

                    this.myBlockData = res["data"];
                    let marker = this.myBlockData.filter(a => {
                      if (a.Details.district_id === this.districtSlectedId) {

                        return a
                      }

                    })

                    this.markers = this.data = marker;
                    if (this.grade) {
                      this.allSubjects = this.allGrades.find(a => { return a.grade == this.grade }).subjects;
                    }
                    let options = {
                      mapZoom: this.globalService.zoomLevel,
                      centerLat: this.lat,
                      centerLng: this.lng,
                      level: "Block",
                    };
                    this.dataOptions = options;
                    if (this.data.length > 0) {
                      let result = this.data;
                      this.blockMarkers = [];
                      this.blockMarkers = result;
                      if (!this.blockMarkers[0]["Subjects"]) {
                        this.blockFilter = this.blockMarkers;
                      }

                      if (this.grade && this.subject) {
                        var filtererSubData = this.blockMarkers.filter(item => {
                          return item.Subjects[`${this.subject}`];
                        })
                        this.blockMarkers = filtererSubData;
                      }

                      if (this.selected != "absolute") {
                        this.colors = this.generateRelativeColors(this.blockMarkers);
                      }
                      if (this.blockMarkers.length) {
                        for (let i = 0; i < this.blockMarkers.length; i++) {
                          if (this.grade && !this.subject && this.blockMarkers[i].Subjects['Grade Performance']) {
                            this.blockMarkers[i].Details['total_students'] = this.blockMarkers[i].Subjects['Grade Performance']['total_students'];
                            this.blockMarkers[i].Details['students_attended'] = this.blockMarkers[i].Subjects['Grade Performance']['students_attended'];
                            this.blockMarkers[i].Details['total_schools'] = this.blockMarkers[i].Subjects['Grade Performance']['total_schools'];
                          }
                          if (this.grade && this.subject) {
                            if (this.blockMarkers[i].Subjects[`${this.subject}`]) {
                              this.blockMarkers[i].Details['total_students'] = this.blockMarkers[i].Subjects[`${this.subject}`]['total_students'];
                              this.blockMarkers[i].Details['students_attended'] = this.blockMarkers[i].Subjects[`${this.subject}`]['students_attended'];
                              this.blockMarkers[i].Details['total_schools'] = this.blockMarkers[i].Subjects[`${this.subject}`]['total_schools'];
                            } else {
                              let index = this.blockMarkers.indexOf(this.blockMarkers[i]);
                              this.blockMarkers.splice(index, 1);
                            }
                          }
                          if (this.grade && this.blockMarkers[i].Subjects['Grade Performance']) {
                            this.blockMarkers[i].Subjects['Grade Performance'] = this.blockMarkers[i].Subjects['Grade Performance']['percentage']
                            this.allSubjects.map(sub => {
                              if (this.blockMarkers[i].Subjects[`${sub}`])
                                this.blockMarkers[i].Subjects[`${sub}`] = this.blockMarkers[i].Subjects[`${sub}`]['percentage']
                            })
                          } else if (!this.grade && !this.subject) {
                            this.allGrades.map(grade => {
                              var myGrade = grade.grade;
                              if (this.blockMarkers[i]['Grade Wise Performance'][`${myGrade}`])
                                this.blockMarkers[i]['Grade Wise Performance'][`${myGrade}`] = this.blockMarkers[i]['Grade Wise Performance'][`${myGrade}`]['percentage'];
                            })
                          }
                          var color;
                          if (!this.grade && !this.subject) {
                            color = this.commonService.color(
                              this.blockMarkers[i].Details,
                              "Performance"
                            );
                          } else if (this.grade && !this.subject) {
                            color = this.commonService.color(
                              this.blockMarkers[i].Subjects,
                              "Grade Performance"
                            );
                          } else if (this.grade && this.subject) {
                            color = this.commonService.color(
                              this.blockMarkers[i].Subjects,
                              this.subject
                            );
                          }

                          var markerIcon = this.attachColorsToMarkers(this.blockMarkers[i], color, this.colors, 4, 0.01, 1, options.level);
                          this.generateToolTip(
                            this.blockMarkers[i],
                            options.level,
                            markerIcon,
                            "latitude",
                            "longitude"
                          );
                          this.getDownloadableData(
                            this.blockMarkers[i],
                            options.level
                          );
                        }

                        this.globalService.restrictZoom(globalMap);
                        globalMap.setMaxBounds([
                          [options.centerLat - 4.5, options.centerLng - 6],
                          [options.centerLat + 3.5, options.centerLng + 6],
                        ]);
                        this.globalService.onResize(this.level);

                        this.schoolCount = res['footer'] && res['footer'].total_schools != null ? res['footer'].total_schools.toString().replace(/(\d)(?=(\d\d)+\d$)/g, "$1,") : null;
                        this.studentCount = res['footer'] && res['footer'].total_students != null ? res['footer'].total_students.toString().replace(/(\d)(?=(\d\d)+\d$)/g, "$1,") : null;
                        this.studentAttended = res['footer'] && res['footer'].students_attended != null ? res['footer'].students_attended.toString().replace(/(\d)(?=(\d\d)+\d$)/g, "$1,") : null;
                        this.changeDetection.detectChanges();
                        this.commonService.loaderAndErr(this.data);
                      } else {
                        this.errorHandling();
                      }
                    }
                  } else if (this.blockSelected) {

                    this.myBlockData = res["data"];
                    let marker = this.myBlockData.filter(a => {
                      if (a.Details.block_id === this.blockSelectedId) {
                      
                        return a
                      }

                    })

                    this.markers = this.data = marker;
                    if (this.grade) {
                      this.allSubjects = this.allGrades.find(a => { return a.grade == this.grade }).subjects;
                    }
                    let options = {
                      mapZoom: this.globalService.zoomLevel,
                      centerLat: this.lat,
                      centerLng: this.lng,
                      level: "Block",
                    };
                    this.dataOptions = options;
                    if (this.data.length > 0) {
                      let result = this.data;
                      this.blockMarkers = [];
                      this.blockMarkers = result;
                      if (!this.blockMarkers[0]["Subjects"]) {
                        this.blockFilter = this.blockMarkers;
                      }

                      if (this.grade && this.subject) {
                        var filtererSubData = this.blockMarkers.filter(item => {
                          return item.Subjects[`${this.subject}`];
                        })
                        this.blockMarkers = filtererSubData;
                      }

                      if (this.selected != "absolute") {
                        this.colors = this.generateRelativeColors(this.blockMarkers);
                      }
                      if (this.blockMarkers.length) {
                        for (let i = 0; i < this.blockMarkers.length; i++) {
                          if (this.grade && !this.subject && this.blockMarkers[i].Subjects['Grade Performance']) {
                            this.blockMarkers[i].Details['total_students'] = this.blockMarkers[i].Subjects['Grade Performance']['total_students'];
                            this.blockMarkers[i].Details['students_attended'] = this.blockMarkers[i].Subjects['Grade Performance']['students_attended'];
                            this.blockMarkers[i].Details['total_schools'] = this.blockMarkers[i].Subjects['Grade Performance']['total_schools'];
                          }
                          if (this.grade && this.subject) {
                            if (this.blockMarkers[i].Subjects[`${this.subject}`]) {
                              this.blockMarkers[i].Details['total_students'] = this.blockMarkers[i].Subjects[`${this.subject}`]['total_students'];
                              this.blockMarkers[i].Details['students_attended'] = this.blockMarkers[i].Subjects[`${this.subject}`]['students_attended'];
                              this.blockMarkers[i].Details['total_schools'] = this.blockMarkers[i].Subjects[`${this.subject}`]['total_schools'];
                            } else {
                              let index = this.blockMarkers.indexOf(this.blockMarkers[i]);
                              this.blockMarkers.splice(index, 1);
                            }
                          }
                          if (this.grade && this.blockMarkers[i].Subjects['Grade Performance']) {
                            this.blockMarkers[i].Subjects['Grade Performance'] = this.blockMarkers[i].Subjects['Grade Performance']['percentage']
                            this.allSubjects.map(sub => {
                              if (this.blockMarkers[i].Subjects[`${sub}`])
                                this.blockMarkers[i].Subjects[`${sub}`] = this.blockMarkers[i].Subjects[`${sub}`]['percentage']
                            })
                          } else if (!this.grade && !this.subject) {
                            this.allGrades.map(grade => {
                              var myGrade = grade.grade;
                              if (this.blockMarkers[i]['Grade Wise Performance'][`${myGrade}`])
                                this.blockMarkers[i]['Grade Wise Performance'][`${myGrade}`] = this.blockMarkers[i]['Grade Wise Performance'][`${myGrade}`]['percentage'];
                            })
                          }
                          var color;
                          if (!this.grade && !this.subject) {
                            color = this.commonService.color(
                              this.blockMarkers[i].Details,
                              "Performance"
                            );
                          } else if (this.grade && !this.subject) {
                            color = this.commonService.color(
                              this.blockMarkers[i].Subjects,
                              "Grade Performance"
                            );
                          } else if (this.grade && this.subject) {
                            color = this.commonService.color(
                              this.blockMarkers[i].Subjects,
                              this.subject
                            );
                          }

                          var markerIcon = this.attachColorsToMarkers(this.blockMarkers[i], color, this.colors, 4, 0.01, 1, options.level);
                          this.generateToolTip(
                            this.blockMarkers[i],
                            options.level,
                            markerIcon,
                            "latitude",
                            "longitude"
                          );
                          this.getDownloadableData(
                            this.blockMarkers[i],
                            options.level
                          );
                        }

                        this.globalService.restrictZoom(globalMap);
                        globalMap.setMaxBounds([
                          [options.centerLat - 4.5, options.centerLng - 6],
                          [options.centerLat + 3.5, options.centerLng + 6],
                        ]);
                        this.globalService.onResize(this.level);

                        this.schoolCount = res['footer'] && res['footer'].total_schools != null ? res['footer'].total_schools.toString().replace(/(\d)(?=(\d\d)+\d$)/g, "$1,") : null;
                        this.studentCount = res['footer'] && res['footer'].total_students != null ? res['footer'].total_students.toString().replace(/(\d)(?=(\d\d)+\d$)/g, "$1,") : null;
                        this.studentAttended = res['footer'] && res['footer'].students_attended != null ? res['footer'].students_attended.toString().replace(/(\d)(?=(\d\d)+\d$)/g, "$1,") : null;
                        this.changeDetection.detectChanges();
                        this.commonService.loaderAndErr(this.data);
                      } else {
                        this.errorHandling();
                      }
                    }
                  } else if (this.selectedCluster) {

                    this.myBlockData = res["data"];
                    let marker = this.myBlockData.filter(a => {
                      if (a.Details.cluster_id === this.selectedCLusterId) {
                        return a
                      }

                    })
                    this.markers = this.data = marker;
                    if (this.grade) {
                      this.allSubjects = this.allGrades.find(a => { return a.grade == this.grade }).subjects;
                    }
                    let options = {
                      mapZoom: this.globalService.zoomLevel,
                      centerLat: this.lat,
                      centerLng: this.lng,
                      level: "Block",
                    };
                    this.dataOptions = options;
                    if (this.data.length > 0) {
                      let result = this.data;
                      this.blockMarkers = [];
                      this.blockMarkers = result;
                      if (!this.blockMarkers[0]["Subjects"]) {
                        this.blockFilter = this.blockMarkers;
                      }

                      if (this.grade && this.subject) {
                        var filtererSubData = this.blockMarkers.filter(item => {
                          return item.Subjects[`${this.subject}`];
                        })
                        this.blockMarkers = filtererSubData;
                      }

                      if (this.selected != "absolute") {
                        this.colors = this.generateRelativeColors(this.blockMarkers);
                      }
                      if (this.blockMarkers.length) {
                        for (let i = 0; i < this.blockMarkers.length; i++) {
                          if (this.grade && !this.subject && this.blockMarkers[i].Subjects['Grade Performance']) {
                            this.blockMarkers[i].Details['total_students'] = this.blockMarkers[i].Subjects['Grade Performance']['total_students'];
                            this.blockMarkers[i].Details['students_attended'] = this.blockMarkers[i].Subjects['Grade Performance']['students_attended'];
                            this.blockMarkers[i].Details['total_schools'] = this.blockMarkers[i].Subjects['Grade Performance']['total_schools'];
                          }
                          if (this.grade && this.subject) {
                            if (this.blockMarkers[i].Subjects[`${this.subject}`]) {
                              this.blockMarkers[i].Details['total_students'] = this.blockMarkers[i].Subjects[`${this.subject}`]['total_students'];
                              this.blockMarkers[i].Details['students_attended'] = this.blockMarkers[i].Subjects[`${this.subject}`]['students_attended'];
                              this.blockMarkers[i].Details['total_schools'] = this.blockMarkers[i].Subjects[`${this.subject}`]['total_schools'];
                            } else {
                              let index = this.blockMarkers.indexOf(this.blockMarkers[i]);
                              this.blockMarkers.splice(index, 1);
                            }
                          }
                          if (this.grade && this.blockMarkers[i].Subjects['Grade Performance']) {
                            this.blockMarkers[i].Subjects['Grade Performance'] = this.blockMarkers[i].Subjects['Grade Performance']['percentage']
                            this.allSubjects.map(sub => {
                              if (this.blockMarkers[i].Subjects[`${sub}`])
                                this.blockMarkers[i].Subjects[`${sub}`] = this.blockMarkers[i].Subjects[`${sub}`]['percentage']
                            })
                          } else if (!this.grade && !this.subject) {
                            this.allGrades.map(grade => {
                              var myGrade = grade.grade;
                              if (this.blockMarkers[i]['Grade Wise Performance'][`${myGrade}`])
                                this.blockMarkers[i]['Grade Wise Performance'][`${myGrade}`] = this.blockMarkers[i]['Grade Wise Performance'][`${myGrade}`]['percentage'];
                            })
                          }
                          var color;
                          if (!this.grade && !this.subject) {
                            color = this.commonService.color(
                              this.blockMarkers[i].Details,
                              "Performance"
                            );
                          } else if (this.grade && !this.subject) {
                            color = this.commonService.color(
                              this.blockMarkers[i].Subjects,
                              "Grade Performance"
                            );
                          } else if (this.grade && this.subject) {
                            color = this.commonService.color(
                              this.blockMarkers[i].Subjects,
                              this.subject
                            );
                          }

                          var markerIcon = this.attachColorsToMarkers(this.blockMarkers[i], color, this.colors, 4, 0.01, 1, options.level);
                          this.generateToolTip(
                            this.blockMarkers[i],
                            options.level,
                            markerIcon,
                            "latitude",
                            "longitude"
                          );
                          this.getDownloadableData(
                            this.blockMarkers[i],
                            options.level
                          );
                        }

                        this.globalService.restrictZoom(globalMap);
                        globalMap.setMaxBounds([
                          [options.centerLat - 4.5, options.centerLng - 6],
                          [options.centerLat + 3.5, options.centerLng + 6],
                        ]);
                        this.globalService.onResize(this.level);

                        this.schoolCount = res['footer'] && res['footer'].total_schools != null ? res['footer'].total_schools.toString().replace(/(\d)(?=(\d\d)+\d$)/g, "$1,") : null;
                        this.studentCount = res['footer'] && res['footer'].total_students != null ? res['footer'].total_students.toString().replace(/(\d)(?=(\d\d)+\d$)/g, "$1,") : null;
                        this.studentAttended = res['footer'] && res['footer'].students_attended != null ? res['footer'].students_attended.toString().replace(/(\d)(?=(\d\d)+\d$)/g, "$1,") : null;
                        this.changeDetection.detectChanges();
                        this.commonService.loaderAndErr(this.data);
                      } else {
                        this.errorHandling();
                      }
                    }
                  } else {
                    this.myBlockData = res["data"];
                    this.markers = this.data = res["data"];
                    if (this.grade) {
                      this.allSubjects = this.allGrades.find(a => { return a.grade == this.grade }).subjects;
                    }
                    let options = {
                      mapZoom: this.globalService.zoomLevel,
                      centerLat: this.lat,
                      centerLng: this.lng,
                      level: "Block",
                    };
                    this.dataOptions = options;
                    if (this.data.length > 0) {
                      let result = this.data;
                      this.blockMarkers = [];
                      this.blockMarkers = result;
                      if (!this.blockMarkers[0]["Subjects"]) {
                        this.blockFilter = this.blockMarkers;
                      }

                      if (this.grade && this.subject) {
                        var filtererSubData = this.blockMarkers.filter(item => {
                          return item.Subjects[`${this.subject}`];
                        })
                        this.blockMarkers = filtererSubData;
                      }

                      if (this.selected != "absolute") {
                        this.colors = this.generateRelativeColors(this.blockMarkers);
                      }
                      if (this.blockMarkers.length) {
                        for (let i = 0; i < this.blockMarkers.length; i++) {
                          if (this.grade && !this.subject && this.blockMarkers[i].Subjects['Grade Performance']) {
                            this.blockMarkers[i].Details['total_students'] = this.blockMarkers[i].Subjects['Grade Performance']['total_students'];
                            this.blockMarkers[i].Details['students_attended'] = this.blockMarkers[i].Subjects['Grade Performance']['students_attended'];
                            this.blockMarkers[i].Details['total_schools'] = this.blockMarkers[i].Subjects['Grade Performance']['total_schools'];
                          }
                          if (this.grade && this.subject) {
                            if (this.blockMarkers[i].Subjects[`${this.subject}`]) {
                              this.blockMarkers[i].Details['total_students'] = this.blockMarkers[i].Subjects[`${this.subject}`]['total_students'];
                              this.blockMarkers[i].Details['students_attended'] = this.blockMarkers[i].Subjects[`${this.subject}`]['students_attended'];
                              this.blockMarkers[i].Details['total_schools'] = this.blockMarkers[i].Subjects[`${this.subject}`]['total_schools'];
                            } else {
                              let index = this.blockMarkers.indexOf(this.blockMarkers[i]);
                              this.blockMarkers.splice(index, 1);
                            }
                          }
                          if (this.grade && this.blockMarkers[i].Subjects['Grade Performance']) {
                            this.blockMarkers[i].Subjects['Grade Performance'] = this.blockMarkers[i].Subjects['Grade Performance']['percentage']
                            this.allSubjects.map(sub => {
                              if (this.blockMarkers[i].Subjects[`${sub}`])
                                this.blockMarkers[i].Subjects[`${sub}`] = this.blockMarkers[i].Subjects[`${sub}`]['percentage']
                            })
                          } else if (!this.grade && !this.subject) {
                            this.allGrades.map(grade => {
                              var myGrade = grade.grade;
                              if (this.blockMarkers[i]['Grade Wise Performance'][`${myGrade}`])
                                this.blockMarkers[i]['Grade Wise Performance'][`${myGrade}`] = this.blockMarkers[i]['Grade Wise Performance'][`${myGrade}`]['percentage'];
                            })
                          }
                          var color;
                          if (!this.grade && !this.subject) {
                            color = this.commonService.color(
                              this.blockMarkers[i].Details,
                              "Performance"
                            );
                          } else if (this.grade && !this.subject) {
                            color = this.commonService.color(
                              this.blockMarkers[i].Subjects,
                              "Grade Performance"
                            );
                          } else if (this.grade && this.subject) {
                            color = this.commonService.color(
                              this.blockMarkers[i].Subjects,
                              this.subject
                            );
                          }

                          var markerIcon = this.attachColorsToMarkers(this.blockMarkers[i], color, this.colors, 4, 0.01, 1, options.level);
                          this.generateToolTip(
                            this.blockMarkers[i],
                            options.level,
                            markerIcon,
                            "latitude",
                            "longitude"
                          );
                          this.getDownloadableData(
                            this.blockMarkers[i],
                            options.level
                          );
                        }

                        this.globalService.restrictZoom(globalMap);
                        globalMap.setMaxBounds([
                          [options.centerLat - 4.5, options.centerLng - 6],
                          [options.centerLat + 3.5, options.centerLng + 6],
                        ]);
                        this.globalService.onResize(this.level);

                        this.schoolCount = res['footer'] && res['footer'].total_schools != null ? res['footer'].total_schools.toString().replace(/(\d)(?=(\d\d)+\d$)/g, "$1,") : null;
                        this.studentCount = res['footer'] && res['footer'].total_students != null ? res['footer'].total_students.toString().replace(/(\d)(?=(\d\d)+\d$)/g, "$1,") : null;
                        this.studentAttended = res['footer'] && res['footer'].students_attended != null ? res['footer'].students_attended.toString().replace(/(\d)(?=(\d\d)+\d$)/g, "$1,") : null;
                        this.changeDetection.detectChanges();
                        this.commonService.loaderAndErr(this.data);
                      } else {
                        this.errorHandling();
                      }
                    }
                  }

                },
                (err) => {
                  this.errorHandling();
                }
              );
          },
          (error) => {
            this.errorHandling();
          }
        );
      globalMap.addLayer(this.layerMarkers);

    } catch (e) {
      console.log(e);
    }
  }

  clusterClick() {
    if (this.semester == "") {
      alert("Please select semester!");
      return;
    }
    if (this.grade) {
      this.clusterWise();
    } else {
      this.clusterWise();
    }
  }
  // to load all the clusters for state data on the map
  clusterWise() {
    try {
      this.commonService.errMsg();
      // to clear the existing data on the map layer
      globalMap.removeLayer(this.markersList);
      this.globalService.latitude = this.lat = this.globalService.mapCenterLatlng.lat;
      this.globalService.longitude = this.lng = this.globalService.mapCenterLatlng.lng;
      this.layerMarkers.clearLayers();

      this.allGrades = [];
      this.reportData = [];
      //  this.districtId = undefined;
      // this.blockId = undefined;
      // this.clusterId = undefined;
      this.level = "Cluster";
      this.googleMapZoom = 7;
      this.fileName = `${this.reportName}_${this.year}_${this.semester}_${this.grade ? this.grade : "allGrades"
        }_${this.subject ? this.subject : ""}_allClusters_${this.commonService.dateAndTime
        }`;

      this.valueRange = undefined;
      this.selectedIndex = undefined;
      this.deSelect();

      // these are for showing the hierarchy names based on selection
      this.skul = true;
      this.dist = false;
      this.blok = false;
      this.clust = false;

      // to show and hide the dropdowns
      this.blockHidden = true;
      this.clusterHidden = true;

      this.service
        .gradeMetaData({
          report: "sat",
          year: this.year,
          sem: this.semester,
        })
        .subscribe(
          (res) => {
            if (res["data"]["cluster"]) {
              this.allGrades = res["data"]["cluster"];
            }
            this.allGrades.sort((a, b) =>
              a.grade > b.grade ? 1 : b.grade > a.grade ? -1 : 0
            );

            // api call to get the all clusters data
            if (this.myData) {
              this.myData.unsubscribe();
            }
            this.myData = this.service
              .PATClusterWiseData({
                ...{
                  grade: this.grade,
                  subject: this.subject,
                  report: "sat",
                  year: this.year,
                  sem: this.semester,
                }, ...{ management: this.management, category: this.category }
              })
              .subscribe(
                (res) => {
                  if (this.districtSelected) {

                    let myBlockData = res["data"];
                    let marker = myBlockData.filter(a => {
                      if (a.Details.district_id === this.districtSlectedId) {

                        return a
                      }

                    })
                    this.markers = this.data = marker;
                    if (this.grade) {
                      this.allSubjects = this.allGrades.find(a => { return a.grade == this.grade }).subjects;
                    }
                    let options = {
                      mapZoom: this.globalService.zoomLevel,
                      centerLat: this.lat,
                      centerLng: this.lng,
                      level: "Cluster",
                    };
                    this.dataOptions = options;
                    if (this.data.length > 0) {
                      let result = this.data;
                      this.clusterMarkers = [];
                      this.clusterMarkers = result;
                      if (!this.clusterMarkers[0]["Subjects"]) {
                        this.clusterFilter = this.clusterMarkers;
                      }
                      if (this.grade && this.subject) {
                        var filtererSubData = this.clusterMarkers.filter(item => {
                          return item.Subjects[`${this.subject}`];
                        })
                        this.clusterMarkers = filtererSubData;
                      }

                      if (this.selected != "absolute") {
                        this.colors = this.generateRelativeColors(this.clusterMarkers);
                      }
                      if (this.clusterMarkers.length) {
                        for (let i = 0; i < this.clusterMarkers.length; i++) {
                          if (this.grade && !this.subject && this.clusterMarkers[i].Subjects['Grade Performance']) {
                            this.clusterMarkers[i].Details['total_students'] = this.clusterMarkers[i].Subjects['Grade Performance']['total_students'];
                            this.clusterMarkers[i].Details['students_attended'] = this.clusterMarkers[i].Subjects['Grade Performance']['students_attended'];
                            this.clusterMarkers[i].Details['total_schools'] = this.clusterMarkers[i].Subjects['Grade Performance']['total_schools'];
                          }
                          if (this.grade && this.subject) {
                            if (this.clusterMarkers[i].Subjects[`${this.subject}`]) {
                              this.clusterMarkers[i].Details['total_students'] = this.clusterMarkers[i].Subjects[`${this.subject}`]['total_students'];
                              this.clusterMarkers[i].Details['students_attended'] = this.clusterMarkers[i].Subjects[`${this.subject}`]['students_attended'];
                              this.clusterMarkers[i].Details['total_schools'] = this.clusterMarkers[i].Subjects[`${this.subject}`]['total_schools'];
                            } else {
                              let index = this.clusterMarkers.indexOf(this.clusterMarkers[i]);
                              this.clusterMarkers.splice(index, 1);
                            }
                          }
                          if (this.grade && this.clusterMarkers[i].Subjects['Grade Performance']) {
                            this.clusterMarkers[i].Subjects['Grade Performance'] = this.clusterMarkers[i].Subjects['Grade Performance']['percentage']
                            this.allSubjects.map(sub => {
                              if (this.clusterMarkers[i].Subjects[`${sub}`])
                                this.clusterMarkers[i].Subjects[`${sub}`] = this.clusterMarkers[i].Subjects[`${sub}`]['percentage']
                            })
                          } else if (!this.grade && !this.subject) {
                            this.allGrades.map(grade => {
                              var myGrade = grade.grade;
                              if (this.clusterMarkers[i]['Grade Wise Performance'][`${myGrade}`])
                                this.clusterMarkers[i]['Grade Wise Performance'][`${myGrade}`] = this.clusterMarkers[i]['Grade Wise Performance'][`${myGrade}`]['percentage'];
                            })
                          }
                          var color;
                          if (!this.grade && !this.subject) {
                            color = this.commonService.color(
                              this.clusterMarkers[i].Details,
                              "Performance"
                            );
                          } else if (this.grade && !this.subject) {
                            color = this.commonService.color(
                              this.clusterMarkers[i].Subjects,
                              "Grade Performance"
                            );
                          } else if (this.grade && this.subject) {
                            color = this.commonService.color(
                              this.clusterMarkers[i].Subjects,
                              this.subject
                            );
                          }

                          var markerIcon = this.attachColorsToMarkers(this.clusterMarkers[i], color, this.colors, 2, 0.01, 0.5, options.level);
                          this.generateToolTip(
                            this.clusterMarkers[i],
                            options.level,
                            markerIcon,
                            "latitude",
                            "longitude"
                          );
                          this.getDownloadableData(
                            this.clusterMarkers[i],
                            options.level
                          );
                        }

                        this.globalService.restrictZoom(globalMap);
                        globalMap.setMaxBounds([
                          [options.centerLat - 4.5, options.centerLng - 6],
                          [options.centerLat + 3.5, options.centerLng + 6],
                        ]);
                        this.globalService.onResize(this.level);

                        //schoolCount
                        this.schoolCount = res['footer'] && res['footer'].total_schools != null ? res['footer'].total_schools.toString().replace(/(\d)(?=(\d\d)+\d$)/g, "$1,") : null;
                        this.studentCount = res['footer'] && res['footer'].total_students != null ? res['footer'].total_students.toString().replace(/(\d)(?=(\d\d)+\d$)/g, "$1,") : null;
                        this.studentAttended = res['footer'] && res['footer'].students_attended != null ? res['footer'].students_attended.toString().replace(/(\d)(?=(\d\d)+\d$)/g, "$1,") : null;
                        this.changeDetection.detectChanges();
                        this.commonService.loaderAndErr(this.data);
                      } else {
                        this.errorHandling();
                      }
                    }
                  } else if (this.blockSelected) {

                    let myBlockData = res["data"];

                    let marker = myBlockData.filter(a => {
                      if (a.details.block_id === this.blockSelectedId) {
                       
                        return a
                      }

                    })
                    this.markers = this.data = marker;
                    if (this.grade) {
                      this.allSubjects = this.allGrades.find(a => { return a.grade == this.grade }).subjects;
                    }
                    let options = {
                      mapZoom: this.globalService.zoomLevel,
                      centerLat: this.lat,
                      centerLng: this.lng,
                      level: "Cluster",
                    };
                    this.dataOptions = options;
                    if (this.data.length > 0) {
                      let result = this.data;
                      this.clusterMarkers = [];
                      this.clusterMarkers = result;
                      if (!this.clusterMarkers[0]["Subjects"]) {
                        this.clusterFilter = this.clusterMarkers;
                      }
                      if (this.grade && this.subject) {
                        var filtererSubData = this.clusterMarkers.filter(item => {
                          return item.Subjects[`${this.subject}`];
                        })
                        this.clusterMarkers = filtererSubData;
                      }

                      if (this.selected != "absolute") {
                        this.colors = this.generateRelativeColors(this.clusterMarkers);
                      }
                      if (this.clusterMarkers.length) {
                        for (let i = 0; i < this.clusterMarkers.length; i++) {
                          if (this.grade && !this.subject && this.clusterMarkers[i].Subjects['Grade Performance']) {
                            this.clusterMarkers[i].Details['total_students'] = this.clusterMarkers[i].Subjects['Grade Performance']['total_students'];
                            this.clusterMarkers[i].Details['students_attended'] = this.clusterMarkers[i].Subjects['Grade Performance']['students_attended'];
                            this.clusterMarkers[i].Details['total_schools'] = this.clusterMarkers[i].Subjects['Grade Performance']['total_schools'];
                          }
                          if (this.grade && this.subject) {
                            if (this.clusterMarkers[i].Subjects[`${this.subject}`]) {
                              this.clusterMarkers[i].Details['total_students'] = this.clusterMarkers[i].Subjects[`${this.subject}`]['total_students'];
                              this.clusterMarkers[i].Details['students_attended'] = this.clusterMarkers[i].Subjects[`${this.subject}`]['students_attended'];
                              this.clusterMarkers[i].Details['total_schools'] = this.clusterMarkers[i].Subjects[`${this.subject}`]['total_schools'];
                            } else {
                              let index = this.clusterMarkers.indexOf(this.clusterMarkers[i]);
                              this.clusterMarkers.splice(index, 1);
                            }
                          }
                          if (this.grade && this.clusterMarkers[i].Subjects['Grade Performance']) {
                            this.clusterMarkers[i].Subjects['Grade Performance'] = this.clusterMarkers[i].Subjects['Grade Performance']['percentage']
                            this.allSubjects.map(sub => {
                              if (this.clusterMarkers[i].Subjects[`${sub}`])
                                this.clusterMarkers[i].Subjects[`${sub}`] = this.clusterMarkers[i].Subjects[`${sub}`]['percentage']
                            })
                          } else if (!this.grade && !this.subject) {
                            this.allGrades.map(grade => {
                              var myGrade = grade.grade;
                              if (this.clusterMarkers[i]['Grade Wise Performance'][`${myGrade}`])
                                this.clusterMarkers[i]['Grade Wise Performance'][`${myGrade}`] = this.clusterMarkers[i]['Grade Wise Performance'][`${myGrade}`]['percentage'];
                            })
                          }
                          var color;
                          if (!this.grade && !this.subject) {
                            color = this.commonService.color(
                              this.clusterMarkers[i].Details,
                              "Performance"
                            );
                          } else if (this.grade && !this.subject) {
                            color = this.commonService.color(
                              this.clusterMarkers[i].Subjects,
                              "Grade Performance"
                            );
                          } else if (this.grade && this.subject) {
                            color = this.commonService.color(
                              this.clusterMarkers[i].Subjects,
                              this.subject
                            );
                          }

                          var markerIcon = this.attachColorsToMarkers(this.clusterMarkers[i], color, this.colors, 2, 0.01, 0.5, options.level);
                          this.generateToolTip(
                            this.clusterMarkers[i],
                            options.level,
                            markerIcon,
                            "latitude",
                            "longitude"
                          );
                          this.getDownloadableData(
                            this.clusterMarkers[i],
                            options.level
                          );
                        }

                        this.globalService.restrictZoom(globalMap);
                        globalMap.setMaxBounds([
                          [options.centerLat - 4.5, options.centerLng - 6],
                          [options.centerLat + 3.5, options.centerLng + 6],
                        ]);
                        this.globalService.onResize(this.level);

                        //schoolCount
                        this.schoolCount = res['footer'] && res['footer'].total_schools != null ? res['footer'].total_schools.toString().replace(/(\d)(?=(\d\d)+\d$)/g, "$1,") : null;
                        this.studentCount = res['footer'] && res['footer'].total_students != null ? res['footer'].total_students.toString().replace(/(\d)(?=(\d\d)+\d$)/g, "$1,") : null;
                        this.studentAttended = res['footer'] && res['footer'].students_attended != null ? res['footer'].students_attended.toString().replace(/(\d)(?=(\d\d)+\d$)/g, "$1,") : null;
                        this.changeDetection.detectChanges();
                        this.commonService.loaderAndErr(this.data);
                      } else {
                        this.errorHandling();
                      }
                    }
                  } else if (this.selectedCluster) {

                    let cluster = res["data"];
                    

                    let marker = cluster.filter(a => {
                      if (a.details.cluster_id === this.selectedCLusterId) {
                        return a
                      }

                    })
                    this.markers = this.data = marker;
                    
                    if (this.grade) {
                      this.allSubjects = this.allGrades.find(a => { return a.grade == this.grade }).subjects;
                    }
                    let options = {
                      mapZoom: this.globalService.zoomLevel,
                      centerLat: this.lat,
                      centerLng: this.lng,
                      level: "Cluster",
                    };
                    this.dataOptions = options;
                    if (this.data.length > 0) {
                      let result = this.data;
                      this.clusterMarkers = [];
                      this.clusterMarkers = result;
                      if (!this.clusterMarkers[0]["Subjects"]) {
                        this.clusterFilter = this.clusterMarkers;
                      }
                      if (this.grade && this.subject) {
                        var filtererSubData = this.clusterMarkers.filter(item => {
                          return item.Subjects[`${this.subject}`];
                        })
                        this.clusterMarkers = filtererSubData;
                      }

                      if (this.selected != "absolute") {
                        this.colors = this.generateRelativeColors(this.clusterMarkers);
                      }
                      if (this.clusterMarkers.length) {
                        for (let i = 0; i < this.clusterMarkers.length; i++) {
                          if (this.grade && !this.subject && this.clusterMarkers[i].Subjects['Grade Performance']) {
                            this.clusterMarkers[i].Details['total_students'] = this.clusterMarkers[i].Subjects['Grade Performance']['total_students'];
                            this.clusterMarkers[i].Details['students_attended'] = this.clusterMarkers[i].Subjects['Grade Performance']['students_attended'];
                            this.clusterMarkers[i].Details['total_schools'] = this.clusterMarkers[i].Subjects['Grade Performance']['total_schools'];
                          }
                          if (this.grade && this.subject) {
                            if (this.clusterMarkers[i].Subjects[`${this.subject}`]) {
                              this.clusterMarkers[i].Details['total_students'] = this.clusterMarkers[i].Subjects[`${this.subject}`]['total_students'];
                              this.clusterMarkers[i].Details['students_attended'] = this.clusterMarkers[i].Subjects[`${this.subject}`]['students_attended'];
                              this.clusterMarkers[i].Details['total_schools'] = this.clusterMarkers[i].Subjects[`${this.subject}`]['total_schools'];
                            } else {
                              let index = this.clusterMarkers.indexOf(this.clusterMarkers[i]);
                              this.clusterMarkers.splice(index, 1);
                            }
                          }
                          if (this.grade && this.clusterMarkers[i].Subjects['Grade Performance']) {
                            this.clusterMarkers[i].Subjects['Grade Performance'] = this.clusterMarkers[i].Subjects['Grade Performance']['percentage']
                            this.allSubjects.map(sub => {
                              if (this.clusterMarkers[i].Subjects[`${sub}`])
                                this.clusterMarkers[i].Subjects[`${sub}`] = this.clusterMarkers[i].Subjects[`${sub}`]['percentage']
                            })
                          } else if (!this.grade && !this.subject) {
                            this.allGrades.map(grade => {
                              var myGrade = grade.grade;
                              if (this.clusterMarkers[i]['Grade Wise Performance'][`${myGrade}`])
                                this.clusterMarkers[i]['Grade Wise Performance'][`${myGrade}`] = this.clusterMarkers[i]['Grade Wise Performance'][`${myGrade}`]['percentage'];
                            })
                          }
                          var color;
                          if (!this.grade && !this.subject) {
                            color = this.commonService.color(
                              this.clusterMarkers[i].Details,
                              "Performance"
                            );
                          } else if (this.grade && !this.subject) {
                            color = this.commonService.color(
                              this.clusterMarkers[i].Subjects,
                              "Grade Performance"
                            );
                          } else if (this.grade && this.subject) {
                            color = this.commonService.color(
                              this.clusterMarkers[i].Subjects,
                              this.subject
                            );
                          }

                          var markerIcon = this.attachColorsToMarkers(this.clusterMarkers[i], color, this.colors, 2, 0.01, 0.5, options.level);
                          this.generateToolTip(
                            this.clusterMarkers[i],
                            options.level,
                            markerIcon,
                            "latitude",
                            "longitude"
                          );
                          this.getDownloadableData(
                            this.clusterMarkers[i],
                            options.level
                          );
                        }

                        this.globalService.restrictZoom(globalMap);
                        globalMap.setMaxBounds([
                          [options.centerLat - 4.5, options.centerLng - 6],
                          [options.centerLat + 3.5, options.centerLng + 6],
                        ]);
                        this.globalService.onResize(this.level);

                        //schoolCount
                        this.schoolCount = res['footer'] && res['footer'].total_schools != null ? res['footer'].total_schools.toString().replace(/(\d)(?=(\d\d)+\d$)/g, "$1,") : null;
                        this.studentCount = res['footer'] && res['footer'].total_students != null ? res['footer'].total_students.toString().replace(/(\d)(?=(\d\d)+\d$)/g, "$1,") : null;
                        this.studentAttended = res['footer'] && res['footer'].students_attended != null ? res['footer'].students_attended.toString().replace(/(\d)(?=(\d\d)+\d$)/g, "$1,") : null;
                        this.changeDetection.detectChanges();
                        this.commonService.loaderAndErr(this.data);
                      } else {
                        this.errorHandling();
                      }
                    }
                  } else {
                    this.markers = this.data = res["data"];
                    if (this.grade) {
                      this.allSubjects = this.allGrades.find(a => { return a.grade == this.grade }).subjects;
                    }
                    let options = {
                      mapZoom: this.globalService.zoomLevel,
                      centerLat: this.lat,
                      centerLng: this.lng,
                      level: "Cluster",
                    };
                    this.dataOptions = options;
                    if (this.data.length > 0) {
                      let result = this.data;
                      this.clusterMarkers = [];
                      this.clusterMarkers = result;
                      if (!this.clusterMarkers[0]["Subjects"]) {
                        this.clusterFilter = this.clusterMarkers;
                      }
                      if (this.grade && this.subject) {
                        var filtererSubData = this.clusterMarkers.filter(item => {
                          return item.Subjects[`${this.subject}`];
                        })
                        this.clusterMarkers = filtererSubData;
                      }

                      if (this.selected != "absolute") {
                        this.colors = this.generateRelativeColors(this.clusterMarkers);
                      }
                      if (this.clusterMarkers.length) {
                        for (let i = 0; i < this.clusterMarkers.length; i++) {
                          if (this.grade && !this.subject && this.clusterMarkers[i].Subjects['Grade Performance']) {
                            this.clusterMarkers[i].Details['total_students'] = this.clusterMarkers[i].Subjects['Grade Performance']['total_students'];
                            this.clusterMarkers[i].Details['students_attended'] = this.clusterMarkers[i].Subjects['Grade Performance']['students_attended'];
                            this.clusterMarkers[i].Details['total_schools'] = this.clusterMarkers[i].Subjects['Grade Performance']['total_schools'];
                          }
                          if (this.grade && this.subject) {
                            if (this.clusterMarkers[i].Subjects[`${this.subject}`]) {
                              this.clusterMarkers[i].Details['total_students'] = this.clusterMarkers[i].Subjects[`${this.subject}`]['total_students'];
                              this.clusterMarkers[i].Details['students_attended'] = this.clusterMarkers[i].Subjects[`${this.subject}`]['students_attended'];
                              this.clusterMarkers[i].Details['total_schools'] = this.clusterMarkers[i].Subjects[`${this.subject}`]['total_schools'];
                            } else {
                              let index = this.clusterMarkers.indexOf(this.clusterMarkers[i]);
                              this.clusterMarkers.splice(index, 1);
                            }
                          }
                          if (this.grade && this.clusterMarkers[i].Subjects['Grade Performance']) {
                            this.clusterMarkers[i].Subjects['Grade Performance'] = this.clusterMarkers[i].Subjects['Grade Performance']['percentage']
                            this.allSubjects.map(sub => {
                              if (this.clusterMarkers[i].Subjects[`${sub}`])
                                this.clusterMarkers[i].Subjects[`${sub}`] = this.clusterMarkers[i].Subjects[`${sub}`]['percentage']
                            })
                          } else if (!this.grade && !this.subject) {
                            this.allGrades.map(grade => {
                              var myGrade = grade.grade;
                              if (this.clusterMarkers[i]['Grade Wise Performance'][`${myGrade}`])
                                this.clusterMarkers[i]['Grade Wise Performance'][`${myGrade}`] = this.clusterMarkers[i]['Grade Wise Performance'][`${myGrade}`]['percentage'];
                            })
                          }
                          var color;
                          if (!this.grade && !this.subject) {
                            color = this.commonService.color(
                              this.clusterMarkers[i].Details,
                              "Performance"
                            );
                          } else if (this.grade && !this.subject) {
                            color = this.commonService.color(
                              this.clusterMarkers[i].Subjects,
                              "Grade Performance"
                            );
                          } else if (this.grade && this.subject) {
                            color = this.commonService.color(
                              this.clusterMarkers[i].Subjects,
                              this.subject
                            );
                          }

                          var markerIcon = this.attachColorsToMarkers(this.clusterMarkers[i], color, this.colors, 2, 0.01, 0.5, options.level);
                          this.generateToolTip(
                            this.clusterMarkers[i],
                            options.level,
                            markerIcon,
                            "latitude",
                            "longitude"
                          );
                          this.getDownloadableData(
                            this.clusterMarkers[i],
                            options.level
                          );
                        }

                        this.globalService.restrictZoom(globalMap);
                        globalMap.setMaxBounds([
                          [options.centerLat - 4.5, options.centerLng - 6],
                          [options.centerLat + 3.5, options.centerLng + 6],
                        ]);
                        this.globalService.onResize(this.level);

                        //schoolCount
                        this.schoolCount = res['footer'] && res['footer'].total_schools != null ? res['footer'].total_schools.toString().replace(/(\d)(?=(\d\d)+\d$)/g, "$1,") : null;
                        this.studentCount = res['footer'] && res['footer'].total_students != null ? res['footer'].total_students.toString().replace(/(\d)(?=(\d\d)+\d$)/g, "$1,") : null;
                        this.studentAttended = res['footer'] && res['footer'].students_attended != null ? res['footer'].students_attended.toString().replace(/(\d)(?=(\d\d)+\d$)/g, "$1,") : null;
                        this.changeDetection.detectChanges();
                        this.commonService.loaderAndErr(this.data);
                      } else {
                        this.errorHandling();
                      }
                    }
                  }


                },
                (err) => {
                  this.errorHandling();
                }
              );
          },
          (error) => {
            this.errorHandling();
          }
        );
      globalMap.addLayer(this.layerMarkers);

    } catch (e) {
      console.log(e);
    }
  }

  schoolClick() {
    if (this.semester == "") {
      alert("Please select semester!");
      return;
    }
    if (this.grade) {
      this.schoolWise();
    } else {
      this.schoolWise();
    }
  }
  // to load all the schools for state data on the map
  schoolWise() {
    try {
      this.commonService.errMsg();
      // to clear the existing data on the map layer
      globalMap.removeLayer(this.markersList);
      this.globalService.latitude = this.lat = this.globalService.mapCenterLatlng.lat;
      this.globalService.longitude = this.lng = this.globalService.mapCenterLatlng.lng;
      this.layerMarkers.clearLayers();

      this.allGrades = [];
      this.reportData = [];
      // this.districtId = undefined;
      // this.blockId = undefined;
      // this.clusterId = undefined;
      this.level = "School";
      this.googleMapZoom = 7;
      this.fileName = `${this.reportName}_${this.year}_${this.semester}_${this.grade ? this.grade : "allGrades"
        }_${this.subject ? this.subject : ""}_allSchools_${this.commonService.dateAndTime
        }`;

      this.valueRange = undefined;
      this.selectedIndex = undefined;
      this.deSelect();

      // these are for showing the hierarchy names based on selection
      this.skul = true;
      this.dist = false;
      this.blok = false;
      this.clust = false;

      // to show and hide the dropdowns
      this.blockHidden = true;
      this.clusterHidden = true;

      this.service
        .gradeMetaData({
          report: "sat",
          year: this.year,
          sem: this.semester,
        })
        .subscribe(
          (res) => {
            if (res["data"]["school"]) {
              this.allGrades = res["data"]["school"];
            }
            this.allGrades.sort((a, b) =>
              a.grade > b.grade ? 1 : b.grade > a.grade ? -1 : 0
            );

            // api call to get the all schools data
            if (this.myData) {
              this.myData.unsubscribe();
            }
            this.myData = this.service
              .PATSchoolWiseData({
                ...{
                  grade: this.grade,
                  subject: this.subject,
                  report: "sat",
                  year: this.year,
                  sem: this.semester,
                }, ...{ management: this.management, category: this.category }
              })
              .subscribe(
                (res) => {
                  if (this.districtSelected) {

                    let mySchoolData = res["data"];
                    let marker = mySchoolData.filter(a => {
                      if (a.Details.district_id === this.districtSlectedId) {

                        return a
                      }

                    })
                    this.markers = this.data = marker;
                    if (this.grade) {
                      this.allSubjects = this.allGrades.find(a => { return a.grade == this.grade }).subjects;
                    }
                    let options = {
                      mapZoom: this.globalService.zoomLevel,
                      centerLat: this.lat,
                      centerLng: this.lng,
                      level: "School",
                    };
                    this.dataOptions = options;
                    this.schoolMarkers = [];
                    if (this.data.length > 0) {
                      let result = this.data;
                      this.schoolMarkers = result;
                      if (this.grade && this.subject) {
                        var filtererSubData = this.schoolMarkers.filter(item => {
                          return item.Subjects[`${this.subject}`];
                        })
                        this.schoolMarkers = filtererSubData;
                      }

                      if (this.selected != "absolute") {
                        this.colors = this.generateRelativeColors(this.schoolMarkers);
                      }
                      if (this.schoolMarkers.length) {
                        for (let i = 0; i < this.schoolMarkers.length; i++) {
                          if (this.grade && !this.subject && this.schoolMarkers[i].Subjects['Grade Performance']) {
                            this.schoolMarkers[i].Details['total_students'] = this.schoolMarkers[i].Subjects['Grade Performance']['total_students'];
                            this.schoolMarkers[i].Details['students_attended'] = this.schoolMarkers[i].Subjects['Grade Performance']['students_attended'];
                            this.schoolMarkers[i].Details['total_schools'] = this.schoolMarkers[i].Subjects['Grade Performance']['total_schools'];
                          }
                          if (this.grade && this.subject) {
                            if (this.schoolMarkers[i].Subjects[`${this.subject}`]) {
                              this.schoolMarkers[i].Details['total_students'] = this.schoolMarkers[i].Subjects[`${this.subject}`]['total_students'];
                              this.schoolMarkers[i].Details['students_attended'] = this.schoolMarkers[i].Subjects[`${this.subject}`]['students_attended'];
                              this.schoolMarkers[i].Details['total_schools'] = this.schoolMarkers[i].Subjects[`${this.subject}`]['total_schools'];
                            } else {
                              let index = this.schoolMarkers.indexOf(this.schoolMarkers[i]);
                              this.schoolMarkers.splice(index, 1);
                            }
                          }
                          if (this.grade && this.schoolMarkers[i].Subjects['Grade Performance']) {
                            this.schoolMarkers[i].Subjects['Grade Performance'] = this.schoolMarkers[i].Subjects['Grade Performance']['percentage']
                            this.allSubjects.map(sub => {
                              if (this.schoolMarkers[i].Subjects[`${sub}`])
                                this.schoolMarkers[i].Subjects[`${sub}`] = this.schoolMarkers[i].Subjects[`${sub}`]['percentage']
                            })
                          } else if (!this.grade && !this.subject) {
                            this.allGrades.map(grade => {
                              var myGrade = grade.grade;
                              if (this.schoolMarkers[i]['Grade Wise Performance'][`${myGrade}`])
                                this.schoolMarkers[i]['Grade Wise Performance'][`${myGrade}`] = this.schoolMarkers[i]['Grade Wise Performance'][`${myGrade}`]['percentage'];
                            })
                          }
                          var color;
                          if (!this.grade && !this.subject) {
                            color = this.commonService.color(
                              this.schoolMarkers[i].Details,
                              "Performance"
                            );
                          } else if (this.grade && !this.subject) {
                            color = this.commonService.color(
                              this.schoolMarkers[i].Subjects,
                              "Grade Performance"
                            );
                          } else if (this.grade && this.subject) {
                            color = this.commonService.color(
                              this.schoolMarkers[i].Subjects,
                              this.subject
                            );
                          }

                          var markerIcon = this.attachColorsToMarkers(this.schoolMarkers[i], color, this.colors, 1, 0, 0.3, options.level);
                          this.generateToolTip(
                            this.schoolMarkers[i],
                            options.level,
                            markerIcon,
                            "latitude",
                            "longitude"
                          );
                          this.getDownloadableData(
                            this.schoolMarkers[i],
                            options.level
                          );
                        }

                        globalMap.doubleClickZoom.enable();
                        globalMap.scrollWheelZoom.enable();
                        globalMap.setMaxBounds([
                          [options.centerLat - 4.5, options.centerLng - 6],
                          [options.centerLat + 3.5, options.centerLng + 6],
                        ]);
                        this.globalService.onResize(this.level);

                        ///schoolCount
                        this.schoolCount = res['footer'] && res['footer'].total_schools != null ? res['footer'].total_schools.toString().replace(/(\d)(?=(\d\d)+\d$)/g, "$1,") : null;
                        this.studentCount = res['footer'] && res['footer'].total_students != null ? res['footer'].total_students.toString().replace(/(\d)(?=(\d\d)+\d$)/g, "$1,") : null;
                        this.studentAttended = res['footer'] && res['footer'].students_attended != null ? res['footer'].students_attended.toString().replace(/(\d)(?=(\d\d)+\d$)/g, "$1,") : null;
                        this.changeDetection.detectChanges();
                        this.commonService.loaderAndErr(this.data);
                      } else {
                        this.errorHandling();
                      }
                    }
                  } else if (this.blockSelected) {

                    let mySchoolData = res["data"];
                    let marker = mySchoolData.filter(a => {
                      if (a.Details.block_id === this.blockSelectedId) {
                        
                        return a
                      }

                    })
                    this.markers = this.data = marker;
                    if (this.grade) {
                      this.allSubjects = this.allGrades.find(a => { return a.grade == this.grade }).subjects;
                    }
                    let options = {
                      mapZoom: this.globalService.zoomLevel,
                      centerLat: this.lat,
                      centerLng: this.lng,
                      level: "School",
                    };
                    this.dataOptions = options;
                    this.schoolMarkers = [];
                    if (this.data.length > 0) {
                      let result = this.data;
                      this.schoolMarkers = result;
                      if (this.grade && this.subject) {
                        var filtererSubData = this.schoolMarkers.filter(item => {
                          return item.Subjects[`${this.subject}`];
                        })
                        this.schoolMarkers = filtererSubData;
                      }

                      if (this.selected != "absolute") {
                        this.colors = this.generateRelativeColors(this.schoolMarkers);
                      }
                      if (this.schoolMarkers.length) {
                        for (let i = 0; i < this.schoolMarkers.length; i++) {
                          if (this.grade && !this.subject && this.schoolMarkers[i].Subjects['Grade Performance']) {
                            this.schoolMarkers[i].Details['total_students'] = this.schoolMarkers[i].Subjects['Grade Performance']['total_students'];
                            this.schoolMarkers[i].Details['students_attended'] = this.schoolMarkers[i].Subjects['Grade Performance']['students_attended'];
                            this.schoolMarkers[i].Details['total_schools'] = this.schoolMarkers[i].Subjects['Grade Performance']['total_schools'];
                          }
                          if (this.grade && this.subject) {
                            if (this.schoolMarkers[i].Subjects[`${this.subject}`]) {
                              this.schoolMarkers[i].Details['total_students'] = this.schoolMarkers[i].Subjects[`${this.subject}`]['total_students'];
                              this.schoolMarkers[i].Details['students_attended'] = this.schoolMarkers[i].Subjects[`${this.subject}`]['students_attended'];
                              this.schoolMarkers[i].Details['total_schools'] = this.schoolMarkers[i].Subjects[`${this.subject}`]['total_schools'];
                            } else {
                              let index = this.schoolMarkers.indexOf(this.schoolMarkers[i]);
                              this.schoolMarkers.splice(index, 1);
                            }
                          }
                          if (this.grade && this.schoolMarkers[i].Subjects['Grade Performance']) {
                            this.schoolMarkers[i].Subjects['Grade Performance'] = this.schoolMarkers[i].Subjects['Grade Performance']['percentage']
                            this.allSubjects.map(sub => {
                              if (this.schoolMarkers[i].Subjects[`${sub}`])
                                this.schoolMarkers[i].Subjects[`${sub}`] = this.schoolMarkers[i].Subjects[`${sub}`]['percentage']
                            })
                          } else if (!this.grade && !this.subject) {
                            this.allGrades.map(grade => {
                              var myGrade = grade.grade;
                              if (this.schoolMarkers[i]['Grade Wise Performance'][`${myGrade}`])
                                this.schoolMarkers[i]['Grade Wise Performance'][`${myGrade}`] = this.schoolMarkers[i]['Grade Wise Performance'][`${myGrade}`]['percentage'];
                            })
                          }
                          var color;
                          if (!this.grade && !this.subject) {
                            color = this.commonService.color(
                              this.schoolMarkers[i].Details,
                              "Performance"
                            );
                          } else if (this.grade && !this.subject) {
                            color = this.commonService.color(
                              this.schoolMarkers[i].Subjects,
                              "Grade Performance"
                            );
                          } else if (this.grade && this.subject) {
                            color = this.commonService.color(
                              this.schoolMarkers[i].Subjects,
                              this.subject
                            );
                          }

                          var markerIcon = this.attachColorsToMarkers(this.schoolMarkers[i], color, this.colors, 1, 0, 0.3, options.level);
                          this.generateToolTip(
                            this.schoolMarkers[i],
                            options.level,
                            markerIcon,
                            "latitude",
                            "longitude"
                          );
                          this.getDownloadableData(
                            this.schoolMarkers[i],
                            options.level
                          );
                        }

                        globalMap.doubleClickZoom.enable();
                        globalMap.scrollWheelZoom.enable();
                        globalMap.setMaxBounds([
                          [options.centerLat - 4.5, options.centerLng - 6],
                          [options.centerLat + 3.5, options.centerLng + 6],
                        ]);
                        this.globalService.onResize(this.level);

                        ///schoolCount
                        this.schoolCount = res['footer'] && res['footer'].total_schools != null ? res['footer'].total_schools.toString().replace(/(\d)(?=(\d\d)+\d$)/g, "$1,") : null;
                        this.studentCount = res['footer'] && res['footer'].total_students != null ? res['footer'].total_students.toString().replace(/(\d)(?=(\d\d)+\d$)/g, "$1,") : null;
                        this.studentAttended = res['footer'] && res['footer'].students_attended != null ? res['footer'].students_attended.toString().replace(/(\d)(?=(\d\d)+\d$)/g, "$1,") : null;
                        this.changeDetection.detectChanges();
                        this.commonService.loaderAndErr(this.data);
                      } else {
                        this.errorHandling();
                      }
                    }
                  } else if (this.selectedCluster) {

                    let mySchoolData = res["data"];
                    
                    let marker = mySchoolData.filter(a => {
                      if (a.Details.cluster_id === this.selectedCLusterId.toString()) {
                        return a
                      }

                    })
                    this.markers = this.data = marker;
                    
                    if (this.grade) {
                      this.allSubjects = this.allGrades.find(a => { return a.grade == this.grade }).subjects;
                    }
                    let options = {
                      mapZoom: this.globalService.zoomLevel,
                      centerLat: this.lat,
                      centerLng: this.lng,
                      level: "School",
                    };
                    this.dataOptions = options;
                    this.schoolMarkers = [];
                    if (this.data.length > 0) {
                      let result = this.data;
                      this.schoolMarkers = result;
                      if (this.grade && this.subject) {
                        var filtererSubData = this.schoolMarkers.filter(item => {
                          return item.Subjects[`${this.subject}`];
                        })
                        this.schoolMarkers = filtererSubData;
                      }

                      if (this.selected != "absolute") {
                        this.colors = this.generateRelativeColors(this.schoolMarkers);
                      }
                      if (this.schoolMarkers.length) {
                        for (let i = 0; i < this.schoolMarkers.length; i++) {
                          if (this.grade && !this.subject && this.schoolMarkers[i].Subjects['Grade Performance']) {
                            this.schoolMarkers[i].Details['total_students'] = this.schoolMarkers[i].Subjects['Grade Performance']['total_students'];
                            this.schoolMarkers[i].Details['students_attended'] = this.schoolMarkers[i].Subjects['Grade Performance']['students_attended'];
                            this.schoolMarkers[i].Details['total_schools'] = this.schoolMarkers[i].Subjects['Grade Performance']['total_schools'];
                          }
                          if (this.grade && this.subject) {
                            if (this.schoolMarkers[i].Subjects[`${this.subject}`]) {
                              this.schoolMarkers[i].Details['total_students'] = this.schoolMarkers[i].Subjects[`${this.subject}`]['total_students'];
                              this.schoolMarkers[i].Details['students_attended'] = this.schoolMarkers[i].Subjects[`${this.subject}`]['students_attended'];
                              this.schoolMarkers[i].Details['total_schools'] = this.schoolMarkers[i].Subjects[`${this.subject}`]['total_schools'];
                            } else {
                              let index = this.schoolMarkers.indexOf(this.schoolMarkers[i]);
                              this.schoolMarkers.splice(index, 1);
                            }
                          }
                          if (this.grade && this.schoolMarkers[i].Subjects['Grade Performance']) {
                            this.schoolMarkers[i].Subjects['Grade Performance'] = this.schoolMarkers[i].Subjects['Grade Performance']['percentage']
                            this.allSubjects.map(sub => {
                              if (this.schoolMarkers[i].Subjects[`${sub}`])
                                this.schoolMarkers[i].Subjects[`${sub}`] = this.schoolMarkers[i].Subjects[`${sub}`]['percentage']
                            })
                          } else if (!this.grade && !this.subject) {
                            this.allGrades.map(grade => {
                              var myGrade = grade.grade;
                              if (this.schoolMarkers[i]['Grade Wise Performance'][`${myGrade}`])
                                this.schoolMarkers[i]['Grade Wise Performance'][`${myGrade}`] = this.schoolMarkers[i]['Grade Wise Performance'][`${myGrade}`]['percentage'];
                            })
                          }
                          var color;
                          if (!this.grade && !this.subject) {
                            color = this.commonService.color(
                              this.schoolMarkers[i].Details,
                              "Performance"
                            );
                          } else if (this.grade && !this.subject) {
                            color = this.commonService.color(
                              this.schoolMarkers[i].Subjects,
                              "Grade Performance"
                            );
                          } else if (this.grade && this.subject) {
                            color = this.commonService.color(
                              this.schoolMarkers[i].Subjects,
                              this.subject
                            );
                          }

                          var markerIcon = this.attachColorsToMarkers(this.schoolMarkers[i], color, this.colors, 1, 0, 0.3, options.level);
                          this.generateToolTip(
                            this.schoolMarkers[i],
                            options.level,
                            markerIcon,
                            "latitude",
                            "longitude"
                          );
                          this.getDownloadableData(
                            this.schoolMarkers[i],
                            options.level
                          );
                        }

                        globalMap.doubleClickZoom.enable();
                        globalMap.scrollWheelZoom.enable();
                        globalMap.setMaxBounds([
                          [options.centerLat - 4.5, options.centerLng - 6],
                          [options.centerLat + 3.5, options.centerLng + 6],
                        ]);
                        this.globalService.onResize(this.level);

                        ///schoolCount
                        this.schoolCount = res['footer'] && res['footer'].total_schools != null ? res['footer'].total_schools.toString().replace(/(\d)(?=(\d\d)+\d$)/g, "$1,") : null;
                        this.studentCount = res['footer'] && res['footer'].total_students != null ? res['footer'].total_students.toString().replace(/(\d)(?=(\d\d)+\d$)/g, "$1,") : null;
                        this.studentAttended = res['footer'] && res['footer'].students_attended != null ? res['footer'].students_attended.toString().replace(/(\d)(?=(\d\d)+\d$)/g, "$1,") : null;
                        this.changeDetection.detectChanges();
                        this.commonService.loaderAndErr(this.data);
                      } else {
                        this.errorHandling();
                      }
                    }
                  } else {
                    this.markers = this.data = res["data"];
                    if (this.grade) {
                      this.allSubjects = this.allGrades.find(a => { return a.grade == this.grade }).subjects;
                    }
                    let options = {
                      mapZoom: this.globalService.zoomLevel,
                      centerLat: this.lat,
                      centerLng: this.lng,
                      level: "School",
                    };
                    this.dataOptions = options;
                    this.schoolMarkers = [];
                    if (this.data.length > 0) {
                      let result = this.data;
                      this.schoolMarkers = result;
                      if (this.grade && this.subject) {
                        var filtererSubData = this.schoolMarkers.filter(item => {
                          return item.Subjects[`${this.subject}`];
                        })
                        this.schoolMarkers = filtererSubData;
                      }

                      if (this.selected != "absolute") {
                        this.colors = this.generateRelativeColors(this.schoolMarkers);
                      }
                      if (this.schoolMarkers.length) {
                        for (let i = 0; i < this.schoolMarkers.length; i++) {
                          if (this.grade && !this.subject && this.schoolMarkers[i].Subjects['Grade Performance']) {
                            this.schoolMarkers[i].Details['total_students'] = this.schoolMarkers[i].Subjects['Grade Performance']['total_students'];
                            this.schoolMarkers[i].Details['students_attended'] = this.schoolMarkers[i].Subjects['Grade Performance']['students_attended'];
                            this.schoolMarkers[i].Details['total_schools'] = this.schoolMarkers[i].Subjects['Grade Performance']['total_schools'];
                          }
                          if (this.grade && this.subject) {
                            if (this.schoolMarkers[i].Subjects[`${this.subject}`]) {
                              this.schoolMarkers[i].Details['total_students'] = this.schoolMarkers[i].Subjects[`${this.subject}`]['total_students'];
                              this.schoolMarkers[i].Details['students_attended'] = this.schoolMarkers[i].Subjects[`${this.subject}`]['students_attended'];
                              this.schoolMarkers[i].Details['total_schools'] = this.schoolMarkers[i].Subjects[`${this.subject}`]['total_schools'];
                            } else {
                              let index = this.schoolMarkers.indexOf(this.schoolMarkers[i]);
                              this.schoolMarkers.splice(index, 1);
                            }
                          }
                          if (this.grade && this.schoolMarkers[i].Subjects['Grade Performance']) {
                            this.schoolMarkers[i].Subjects['Grade Performance'] = this.schoolMarkers[i].Subjects['Grade Performance']['percentage']
                            this.allSubjects.map(sub => {
                              if (this.schoolMarkers[i].Subjects[`${sub}`])
                                this.schoolMarkers[i].Subjects[`${sub}`] = this.schoolMarkers[i].Subjects[`${sub}`]['percentage']
                            })
                          } else if (!this.grade && !this.subject) {
                            this.allGrades.map(grade => {
                              var myGrade = grade.grade;
                              if (this.schoolMarkers[i]['Grade Wise Performance'][`${myGrade}`])
                                this.schoolMarkers[i]['Grade Wise Performance'][`${myGrade}`] = this.schoolMarkers[i]['Grade Wise Performance'][`${myGrade}`]['percentage'];
                            })
                          }
                          var color;
                          if (!this.grade && !this.subject) {
                            color = this.commonService.color(
                              this.schoolMarkers[i].Details,
                              "Performance"
                            );
                          } else if (this.grade && !this.subject) {
                            color = this.commonService.color(
                              this.schoolMarkers[i].Subjects,
                              "Grade Performance"
                            );
                          } else if (this.grade && this.subject) {
                            color = this.commonService.color(
                              this.schoolMarkers[i].Subjects,
                              this.subject
                            );
                          }

                          var markerIcon = this.attachColorsToMarkers(this.schoolMarkers[i], color, this.colors, 1, 0, 0.3, options.level);
                          this.generateToolTip(
                            this.schoolMarkers[i],
                            options.level,
                            markerIcon,
                            "latitude",
                            "longitude"
                          );
                          this.getDownloadableData(
                            this.schoolMarkers[i],
                            options.level
                          );
                        }

                        globalMap.doubleClickZoom.enable();
                        globalMap.scrollWheelZoom.enable();
                        globalMap.setMaxBounds([
                          [options.centerLat - 4.5, options.centerLng - 6],
                          [options.centerLat + 3.5, options.centerLng + 6],
                        ]);
                        this.globalService.onResize(this.level);

                        ///schoolCount
                        this.schoolCount = res['footer'] && res['footer'].total_schools != null ? res['footer'].total_schools.toString().replace(/(\d)(?=(\d\d)+\d$)/g, "$1,") : null;
                        this.studentCount = res['footer'] && res['footer'].total_students != null ? res['footer'].total_students.toString().replace(/(\d)(?=(\d\d)+\d$)/g, "$1,") : null;
                        this.studentAttended = res['footer'] && res['footer'].students_attended != null ? res['footer'].students_attended.toString().replace(/(\d)(?=(\d\d)+\d$)/g, "$1,") : null;
                        this.changeDetection.detectChanges();
                        this.commonService.loaderAndErr(this.data);
                      } else {
                        this.errorHandling();
                      }
                    }
                  }


                },
                (err) => {
                  this.errorHandling();
                }
              );
          },
          (error) => {
            this.errorHandling();
          }
        );

      globalMap.addLayer(this.layerMarkers);

    } catch (e) {
      console.log(e);
    }
  }

  ondistLinkClick(districtId) {
    if (this.semester == "") {
      alert("Please select semester!");
      return;
    }
    if (this.grade) {

      this.onDistrictSelect(districtId);
    } else {
      this.onDistrictSelect(districtId);
    }
  }
  // to load all the blocks for selected district for state data on the map
  public districtSelected: boolean = false
  public districtSlectedId
  onDistrictSelect(districtId) {
    this.districtSelected = true
    this.blockSelected = false
    this.selectedCluster = false
    this.districtSlectedId = districtId
    this.hideAllBlockBtn = true;
    this.hideAllCLusterBtn = false;
    this.hideAllSchoolBtn = false;
    this.commonService.errMsg();
    // to clear the existing data on the map layer
    globalMap.removeLayer(this.markersList);
    this.layerMarkers.clearLayers();

    this.blockId = undefined;
    this.reportData = [];
    this.level = "blockPerDistrict";
    this.googleMapZoom = 9;
    this.fileName = `${this.reportName}_${this.year}_${this.semester}_${this.grade ? this.grade : "allGrades"
      }_${this.subject ? this.subject : ""}_blocks_of_district_${districtId}_${this.commonService.dateAndTime}`;
    var myData = this.distFilter.find(
      (a) => a.Details.district_id == districtId
    );

    this.valueRange = undefined;
    this.selectedIndex = undefined;
    this.deSelect();

    // api call to get the blockwise data for selected district
    if (this.myData) {
      this.myData.unsubscribe();
    }
    this.myData = this.service
      .PATBlocksPerDistData(districtId, {
        ...{
          report: "sat",
          year: this.year,
          sem: this.semester,
          grade: this.grade, subject: this.subject
        }, ...{ management: this.management, category: this.category }
      })
      .subscribe(
        (res) => {
          this.markers = this.data = res["data"];
          if (this.grade) {
            this.allSubjects = this.allGrades.find(a => { return a.grade == this.grade }).subjects;
          }
          this.allBlocks = this.blockMarkers = this.data;
          if (!this.blockMarkers[0]["Subjects"]) {
            this.blockFilter = this.blockMarkers;
          }
          // set hierarchy values
          this.districtHierarchy = {
            distId: this.data[0].Details.district_id,
            districtName: this.data[0].Details.district_name,
          };

          // to show and hide the dropdowns
          this.blockHidden = false;
          this.clusterHidden = true;

          this.districtId = districtId;

          // these are for showing the hierarchy names based on selection
          this.skul = false;
          this.dist = true;
          this.blok = false;
          this.clust = false;

          // options to set for markers in the map
          let options = {
            fillOpacity: 1,
            strokeWeight: 0.01,
            mapZoom: this.globalService.zoomLevel + 1,
            centerLat: this.data[0].Details.latitude,
            centerLng: this.data[0].Details.longitude,
            level: "blockPerDistrict",
          };
          this.dataOptions = options;
          this.globalService.latitude = this.lat = options.centerLat;
          this.globalService.longitude = this.lng = options.centerLng;

          this.globalService.restrictZoom(globalMap);
          globalMap.setMaxBounds([
            [options.centerLat - 1.5, options.centerLng - 3],
            [options.centerLat + 1.5, options.centerLng + 2],
          ]);

          this.genericFun(this.data, options, this.fileName);
          this.globalService.onResize(this.level);

          // sort the blockname alphabetically
          this.allBlocks.sort((a, b) =>
            a.Details.block_name > b.Details.block_name
              ? 1
              : b.Details.block_name > a.Details.block_name
                ? -1
                : 0
          );

          this.schoolCount = res['footer'] && res['footer'].total_schools != null ? res['footer'].total_schools.toString().replace(/(\d)(?=(\d\d)+\d$)/g, "$1,") : null;
          this.studentCount = res['footer'] && res['footer'].total_students != null ? res['footer'].total_students.toString().replace(/(\d)(?=(\d\d)+\d$)/g, "$1,") : null;
          this.studentAttended = res['footer'] && res['footer'].students_attended != null ? res['footer'].students_attended.toString().replace(/(\d)(?=(\d\d)+\d$)/g, "$1,") : null;
        },
        (err) => {
          this.errorHandling();
        }
      );
    globalMap.addLayer(this.layerMarkers);

  }


  onblockLinkClick(blockId) {


    if (this.semester == "") {
      alert("Please select semester!");
      return;
    }
    if (this.grade) {
      this.onBlockSelect(blockId);
    } else {
      this.onBlockSelect(blockId);
    }
  }
  // to load all the clusters for selected block for state data on the map

  public blockSelected: boolean = false
  public blockSelectedId
  onBlockSelect(blockId) {
    this.districtSelected = false
    this.selectedCluster = false
    this.blockSelected = true
    this.blockSelectedId = blockId
    this.hideAllBlockBtn = true;
    this.hideAllCLusterBtn = true;
    this.hideAllSchoolBtn = false;
    this.commonService.errMsg();
    // to clear the existing data on the map layer
    globalMap.removeLayer(this.markersList);
    this.layerMarkers.clearLayers();

    this.clusterId = undefined;
    this.reportData = [];
    this.level = "clusterPerBlock";
    this.googleMapZoom = 11;
    this.fileName = `${this.reportName}_${this.year}_${this.semester}_${this.grade ? this.grade : "allGrades"
      }_${this.subject ? this.subject : ""}_clusters_of_block_${blockId}_${this.commonService.dateAndTime
      }`;

    this.valueRange = undefined;
    this.selectedIndex = undefined;
    this.deSelect();

    // api call to get the clusterwise data for selected district, block
    if (this.myData) {
      this.myData.unsubscribe();
    }
    this.myData = this.service
      .PATClustersPerBlockData(this.districtId, blockId, {
        ...{
          report: "sat",
          year: this.year,
          sem: this.semester,
          grade: this.grade, subject: this.subject
        }, ...{ management: this.management, category: this.category }
      })
      .subscribe(
        (res) => {
          this.markers = this.data = res["data"];
          if (this.grade) {
            this.allSubjects = this.allGrades.find(a => { return a.grade == this.grade }).subjects;
          }
          this.allClusters = this.clusterMarkers = this.data;
          if (!this.clusterMarkers[0]["Subjects"]) {
            this.clusterFilter = this.clusterMarkers;
          }
          var myBlocks = [];
          this.blockMarkers.forEach((element) => {
            if (element.Details.district_id == this.districtId) {
              myBlocks.push(element);
            }
          });
          this.allBlocks = this.blockMarkers = myBlocks;
          this.allBlocks.sort((a, b) =>
            a.Details.block_name > b.Details.block_name
              ? 1
              : b.Details.block_name > a.Details.block_name
                ? -1
                : 0
          );
          // set hierarchy values
          this.blockHierarchy = {
            distId: this.data[0].Details.district_id,
            districtName: this.data[0].Details.district_name,
            blockId: this.data[0].Details.block_id,
            blockName: this.data[0].Details.block_name,
          };

          // to show and hide the dropdowns
          this.blockHidden = false;
          this.clusterHidden = false;

          this.districtId = this.data[0].Details.district_id;
          this.blockId = blockId;

          // these are for showing the hierarchy names based on selection
          this.skul = false;
          this.dist = false;
          this.blok = true;
          this.clust = false;

          // options to set for markers in the map
          let options = {
            fillOpacity: 1,
            strokeWeight: 0.01,
            mapZoom: this.globalService.zoomLevel + 3,
            centerLat: this.data[0].Details.latitude,
            centerLng: this.data[0].Details.longitude,
            level: "clusterPerBlock",
          };
          this.dataOptions = options;
          this.globalService.latitude = this.lat = options.centerLat;
          this.globalService.longitude = this.lng = options.centerLng;

          this.globalService.restrictZoom(globalMap);
          globalMap.setMaxBounds([
            [options.centerLat - 1.5, options.centerLng - 3],
            [options.centerLat + 1.5, options.centerLng + 2],
          ]);

          this.genericFun(this.data, options, this.fileName);
          this.globalService.onResize(this.level);

          // sort the clusterName alphabetically
          this.clusterMarkers.sort((a, b) =>
            a.Details.cluster_name > b.Details.cluster_name
              ? 1
              : b.Details.cluster_name > a.Details.cluster_name
                ? -1
                : 0
          );
          this.schoolCount = res['footer'] && res['footer'].total_schools != null ? res['footer'].total_schools.toString().replace(/(\d)(?=(\d\d)+\d$)/g, "$1,") : null;
          this.studentCount = res['footer'] && res['footer'].total_students != null ? res['footer'].total_students.toString().replace(/(\d)(?=(\d\d)+\d$)/g, "$1,") : null;
          this.studentAttended = res['footer'] && res['footer'].students_attended != null ? res['footer'].students_attended.toString().replace(/(\d)(?=(\d\d)+\d$)/g, "$1,") : null;
        },
        (err) => {
          this.errorHandling();
        }
      );
    globalMap.addLayer(this.layerMarkers);

  }

  onclusterLinkClick(clusterId) {
    if (this.semester == "") {
      alert("Please select semester!");
      return;
    }
    if (this.grade) {
      this.onClusterSelect(clusterId);
    } else {
      this.onClusterSelect(clusterId);
    }
  }
  // to load all the schools for selected cluster for state data on the map
  public selectedCluster: boolean = false;
  public selectedCLusterId
  public hideAllBlockBtn: boolean = false;
  public hideAllCLusterBtn: boolean = false
  public hideAllSchoolBtn: boolean = false;
  onClusterSelect(clusterId) {

    this.hideAllBlockBtn = true;
    this.hideAllCLusterBtn = true;
    this.hideAllSchoolBtn = true;
    this.blockSelected = false
    this.districtSelected = false
    this.selectedCluster = true
    this.selectedCLusterId = clusterId
    this.commonService.errMsg();
    // to clear the existing data on the map layer
    globalMap.removeLayer(this.markersList);
    this.layerMarkers.clearLayers();
    this.level = "schoolPerCluster";
    this.googleMapZoom = 13;
    var myData = this.clusterFilter.find(
      (a) => a.Details.cluster_id == clusterId
    );

    this.valueRange = undefined;
    this.selectedIndex = undefined;
    this.deSelect();

    // api call to get the schoolwise data for selected district, block, cluster
    if (this.myData) {
      this.myData.unsubscribe();
    }
    this.myData = this.service
      .PATBlockWiseData({
        ...{
          grade: this.grade,
          report: "sat",
          year: this.year,
          sem: this.semester,
        }, ...{ management: this.management, category: this.category }
      })
      .subscribe(
        (result: any) => {
          this.myData = this.service
            .PATSchoolssPerClusterData(
              this.districtId,
              this.blockId,
              clusterId,
              {
                ...{
                  report: "sat",
                  year: this.year, sem: this.semester, grade: this.grade, subject: this.subject
                }, ...{ management: this.management, category: this.category }
              }
            )
            .subscribe(
              (res) => {
                this.markers = this.data = res["data"];
                if (this.grade) {
                  this.allSubjects = this.allGrades.find(a => { return a.grade == this.grade }).subjects;
                }

                this.schoolMarkers = this.data;
                var myBlocks = [];
                this.blockMarkers.forEach((element) => {
                  if (
                    element.Details.district_id == this.districtId
                  ) {
                    myBlocks.push(element);
                  }
                });
                this.allBlocks = this.blockMarkers = myBlocks;
                this.allBlocks.sort((a, b) =>
                  a.Details.block_name > b.Details.block_name
                    ? 1
                    : b.Details.block_name > a.Details.block_name
                      ? -1
                      : 0
                );

                var myCluster = [];
                this.clusterMarkers.forEach((element) => {
                  if (
                    element.Details.block_id == this.blockId
                  ) {
                    myCluster.push(element);
                  }
                });
                this.allClusters = this.clusterMarkers = myCluster;
                this.allClusters.sort((a, b) =>
                  a.Details.cluster_name > b.Details.cluster_name
                    ? 1
                    : b.Details.cluster_name > a.Details.cluster_name
                      ? -1
                      : 0
                );

                // set hierarchy values
                this.clusterHierarchy = {
                  distId: this.data[0].Details.district_id,
                  districtName: this.data[0].Details.district_name,
                  blockId: this.data[0].Details.block_id,
                  blockName: this.data[0].Details.block_name,
                  clusterId: Number(this.data[0].Details.cluster_id),
                  clusterName: this.data[0].Details.cluster_name,
                };

                this.blockHidden = false;
                this.clusterHidden = false;

                this.districtHierarchy = {
                  distId: this.data[0].Details.district_id,
                };

                this.districtId = this.data[0].Details.district_id;
                this.blockId = this.data[0].Details.block_id;
                this.clusterId = clusterId;

                // these are for showing the hierarchy names based on selection
                this.skul = false;
                this.dist = false;
                this.blok = false;
                this.clust = true;

                // options to set for markers in the map
                let options = {
                  fillOpacity: 1,
                  strokeWeight: 0.01,
                  mapZoom: this.globalService.zoomLevel + 5,
                  centerLat: this.data[0].Details.latitude,
                  centerLng: this.data[0].Details.longitude,
                  level: "schoolPerCluster",
                };
                this.dataOptions = options;
                this.globalService.latitude = this.lat = options.centerLat;
                this.globalService.longitude = this.lng = options.centerLng;

                this.level = options.level;
                this.fileName = `${this.reportName}_${this.year}_${this.semester}_${this.grade ? this.grade : "allGrades"
                  }_${this.subject ? this.subject : ""}_schools_of_cluster_${clusterId}_${this.commonService.dateAndTime}`;

                globalMap.doubleClickZoom.enable();
                globalMap.scrollWheelZoom.enable();
                globalMap.setMaxBounds([
                  [options.centerLat - 1.5, options.centerLng - 3],
                  [options.centerLat + 1.5, options.centerLng + 2],
                ]);

                this.genericFun(this.data, options, this.fileName);
                this.globalService.onResize(this.level);

                this.schoolCount = res['footer'] && res['footer'].total_schools != null ? res['footer'].total_schools.toString().replace(/(\d)(?=(\d\d)+\d$)/g, "$1,") : null;
                this.studentCount = res['footer'] && res['footer'].total_students != null ? res['footer'].total_students.toString().replace(/(\d)(?=(\d\d)+\d$)/g, "$1,") : null;
                this.studentAttended = res['footer'] && res['footer'].students_attended != null ? res['footer'].students_attended.toString().replace(/(\d)(?=(\d\d)+\d$)/g, "$1,") : null;
              },
              (err) => {
                this.errorHandling();
              }
            );
        },
        (err) => {
          this.errorHandling();
        }
      );
    globalMap.addLayer(this.layerMarkers);

  }

  // common function for all the data to show in the map
  genericFun(data, options, fileName) {
    try {
      this.reportData = [];
      var color;
      var colors = [];
      this.allSubjects.sort();
      this.markers = data;
      if (this.grade && this.subject) {
        var filtererSubData = this.markers.filter(item => {
          return item.Subjects[`${this.subject}`];
        })
        this.markers = filtererSubData;
      }
      if (this.markers.length) {
        for (let i = 0; i < this.markers.length; i++) {
          if (!this.valueRange) {
            if (this.grade && !this.subject && this.markers[i].Subjects['Grade Performance']) {
              this.markers[i].Details['total_students'] = this.markers[i].Subjects['Grade Performance']['total_students'];
              this.markers[i].Details['students_attended'] = this.markers[i].Subjects['Grade Performance']['students_attended'];
              this.markers[i].Details['total_schools'] = this.markers[i].Subjects['Grade Performance']['total_schools'];
            }
            if (this.grade && this.subject) {
              if (this.markers[i].Subjects[`${this.subject}`]) {
                this.markers[i].Details['total_students'] = this.markers[i].Subjects[`${this.subject}`]['total_students'];
                this.markers[i].Details['students_attended'] = this.markers[i].Subjects[`${this.subject}`]['students_attended'];
                this.markers[i].Details['total_schools'] = this.markers[i].Subjects[`${this.subject}`]['total_schools'];
              } else {
                let index = this.markers.indexOf(this.markers[i]);
                this.markers.splice(index, 1);
              }
            }
            if (this.grade) {
              if (this.level != 'Block' && this.level != 'Cluster' && this.level != 'School' && this.markers[i].Subjects['Grade Performance']) {
                this.markers[i].Subjects['Grade Performance'] = this.markers[i].Subjects['Grade Performance']['percentage']
                this.allSubjects.map(sub => {
                  if (this.markers[i].Subjects[`${sub}`])
                    this.markers[i].Subjects[`${sub}`] = this.markers[i].Subjects[`${sub}`]['percentage']
                })
              } else {
                if (this.markers[i].Subjects['Grade Performance']) {
                  this.markers[i].Subjects['Grade Performance'] = this.markers[i].Subjects['Grade Performance']['percentage']
                  this.allSubjects.map(sub => {
                    if (this.markers[i].Subjects[`${sub}`])
                      this.markers[i].Subjects[`${sub}`] = this.markers[i].Subjects[`${sub}`]['percentage']
                  })
                }
              }
            } else if (!this.grade && !this.subject) {
              this.allGrades.map(grade => {
                var myGrade = grade.grade;
                if (this.markers[i]['Grade Wise Performance'][`${myGrade}`])
                  this.markers[i]['Grade Wise Performance'][`${myGrade}`] = this.markers[i]['Grade Wise Performance'][`${myGrade}`]['percentage'];
              })
            }
          }
          if (!this.grade && !this.subject) {
            color = this.commonService.color(
              this.markers[i].Details,
              "Performance"
            );
          } else if (this.grade && !this.subject) {
            color = this.commonService.color(
              this.markers[i].Subjects,
              "Grade Performance"
            );
          } else if (this.grade && this.subject) {
            color = this.commonService.color(
              this.markers[i].Subjects,
              `${this.subject}`
            );
          }
          colors.push(color);
        }

        if (this.selected != "absolute") {
          this.colors = this.generateRelativeColors(this.markers)
        }

        // attach values to markers
        for (let i = 0; i < this.markers.length; i++) {
          var markerIcon = this.attachColorsToMarkers(this.markers[i], colors[i], this.colors, 6, options.strokeWeight, 1, options.level);
          // data to show on the tooltip for the desired levels
          this.generateToolTip(
            this.markers[i],
            options.level,
            markerIcon,
            "latitude",
            "longitude"
          );

          // to download the report
          this.fileName = fileName;
          this.getDownloadableData(this.markers[i], options.level);
        }
        this.commonService.loaderAndErr(this.markers);
        this.changeDetection.detectChanges();
      } else {
        this.errorHandling();
      }
    } catch (e) {
      this.errorHandling();
    }

  }

  //Generate relative colors.......
  generateRelativeColors(markers) {
    var colors = this.commonService.getRelativeColors(markers, {
      value: this.grade
        ? markers[0].Subjects
          ? "Grade Performance"
          : this.grade
        : this.grade && this.subject
          ? this.subject
          : "Performance",
      selected: this.grade
        ? "G"
        : this.grade && this.subject
          ? "GS"
          : "all",
      report: "reports",
    });
    return colors;
  }

  //Attach colors to markers.........
  attachColorsToMarkers(marker, color, colors, radius, strock, border, level) {
    if (marker != undefined) {
      // google map circle icon
      if (this.mapName == "googlemap") {
        let markerColor = this.selected == "absolute"
          ? color
          : this.commonService.relativeColorGredient(
            marker,
            {
              value: this.grade
                ? marker.Subjects
                  ? "Grade Performance"
                  : this.grade
                : this.grade && this.subject
                  ? this.subject
                  : "Performance",
              selected: this.grade
                ? "G"
                : this.grade && this.subject
                  ? "GS"
                  : "all",
              report: "reports",
            },
            colors
          );

        marker['icon'] = this.globalService.initGoogleMapMarker(markerColor, radius, border);
      }


      var icon = this.globalService.initMarkers1(
        marker.Details.latitude,
        marker.Details.longitude,
        this.selected == "absolute"
          ? color
          : this.commonService.relativeColorGredient(
            marker,
            {
              value: this.grade
                ? marker.Subjects
                  ? "Grade Performance"
                  : this.grade
                : this.grade && this.subject
                  ? this.subject
                  : "Performance",
              selected: this.grade
                ? "G"
                : this.grade && this.subject
                  ? "GS"
                  : "all",
              report: "reports",
            },
            colors
          ),
        level == 'School' ? 0 : strock,
        level == 'School' ? 0.3 : border,
        level
      );
      return icon;
    }
  }

  generateToolTip(markers, level, markerIcon, lat, lng) {
    if (markers && markerIcon) {
      this.popups(markerIcon, markers, level);
      let colorText = `style='color:blue !important;'`;
      var details = {};
      var orgObject = {};
      var data1 = {};
      var data2 = {};
      var data3 = {}
      // student_count, total_schools

      Object.keys(markers.Details).forEach((key) => {
        if (key !== lat) {
          details[key] = markers.Details[key];
        }
      });
      // if (this.period == 'all') {
      //   Object.keys(details).forEach((key) => {
      //     if (key !== "total_students") {
      //       data1[key] = details[key];
      //     }
      //   });
      //   Object.keys(data1).forEach((key) => {
      //     if (key !== "total_schools") {
      //       data2[key] = data1[key];
      //     }
      //   });
      //   Object.keys(data2).forEach((key) => {
      //     if (key !== "students_attended") {
      //       data3[key] = data2[key];
      //     }
      //   });
      // } else {
      data3 = details;
      // }
      Object.keys(data3).forEach((key) => {
        if (key !== lng) {
          orgObject[key] = data3[key];
        }
      });
      if (level != "School" || level != "schoolPerCluster") {
        if (orgObject["total_schools"] != null) {
          orgObject["total_schools"] = orgObject["total_schools"]
            .toString()
            .replace(/(\d)(?=(\d\d)+\d$)/g, "$1,");
        }
      }
      if (orgObject["total_students"] != null) {
        orgObject["total_students"] = orgObject["total_students"]
          .toString()
          .replace(/(\d)(?=(\d\d)+\d$)/g, "$1,");
      }
      if (orgObject["students_attended"] != null) {
        orgObject["students_attended"] = orgObject["students_attended"]
          .toString()
          .replace(/(\d)(?=(\d\d)+\d$)/g, "$1,");
      }
      var yourData1;
      if (this.grade) {
        yourData1 = this.globalService
          .getInfoFrom(
            orgObject,
            "Performance",
            level,
            "patReport",
            "",
            colorText
          )
          .join(" <br>");
      } else {
        yourData1 = this.globalService
          .getInfoFrom(
            orgObject,
            "Performance",
            level,
            "patReport",
            "Performance",
            colorText
          )
          .join(" <br>");
      }
      var yourData;
      var ordered;
      var mylevel;
      if (level == "District" || level == 'Block' || level == 'Cluster' || level == 'School') {
        mylevel = level;
      }

      if (level == "blockPerDistrict") {
        mylevel = level;
      } else if (level == "clusterPerBlock") {
        mylevel = level;
      } else if (level == "schoolPerCluster") {
        mylevel = level;
      }

      if (level == mylevel) {
        if (this.grade && !this.subject) {
          ordered = {};
          ordered["Grade Performance"] = markers["Subjects"]["Grade Performance"]
          Object.keys(markers["Subjects"])
            .sort()
            .forEach(function (key) {
              if (key != "Grade Performance") {
                ordered[key] = markers["Subjects"][key];
              }
            });
          yourData = this.globalService
            .getInfoFrom(
              ordered,
              "Performance",
              level,
              "patReport",
              "Grade Performance",
              colorText
            )
            .join(" <br>");
        } else if (this.grade && this.subject) {
          ordered = {};
          ordered["Grade Performance"] = markers["Subjects"]["Grade Performance"]
          Object.keys(markers["Subjects"])
            .sort()
            .forEach(function (key) {
              if (key != "Grade Performance") {
                ordered[key] = markers["Subjects"][key];
              }
            });
          yourData = this.globalService
            .getInfoFrom(
              ordered,
              "Performance",
              level,
              "patReport",
              this.subject,
              colorText
            )
            .join(" <br>");
        } else {
          ordered = {};
          Object.keys(markers["Grade Wise Performance"])
            .sort()
            .forEach(function (key) {
              ordered[key] = markers["Grade Wise Performance"][key];
            });
          yourData = this.globalService
            .getInfoFrom(
              ordered,
              "Performance",
              level,
              "patReport",
              "",
              colorText
            )
            .join(" <br>");
        }
      } else {
        if (this.grade && !this.subject) {
          ordered = {};
          ordered["Grade Performance"] = markers["Subjects"]["Grade Performance"]
          Object.keys(markers["Subjects"])
            .sort()
            .forEach(function (key) {
              if (key != "Grade Performance") {
                ordered[key] = markers["Subjects"][key];
              }
            });
          yourData = this.globalService
            .getInfoFrom(
              ordered,
              "Performance",
              level,
              "patReport",
              "Grade Performance",
              colorText
            )
            .join(" <br>");
        } else if (this.grade && this.subject) {
          ordered = {};
          ordered["Grade Performance"] = markers["Subjects"]["Grade Performance"]
          Object.keys(markers["Subjects"])
            .sort()
            .forEach(function (key) {
              if (key != "Grade Performance") {
                ordered[key] = markers["Subjects"][key];
              }
            });
          yourData = this.globalService
            .getInfoFrom(
              ordered,
              "Performance",
              level,
              "patReport",
              this.subject,
              colorText
            )
            .join(" <br>");
        } else {
          ordered = {};
          Object.keys(markers["Grade Wise Performance"])
            .sort()
            .forEach(function (key) {
              ordered[key] = markers["Grade Wise Performance"][key];
            });
          yourData = this.globalService
            .getInfoFrom(
              ordered,
              "Performance",
              level,
              "patReport",
              "",
              colorText
            )
            .join(" <br>");
        }
      }
      var toolTip = "<b><u>Details</u></b>" +
        "<br>" +
        yourData1 +
        "<br><br><b><u>Semester Exam Score (%)</u></b>" +
        "<br>" +
        yourData;
      if (this.mapName != 'googlemap') {
        const popup = R.responsivePopup({
          hasTip: false,
          autoPan: false,
          offset: [15, 20],
        }).setContent(
          "<b><u>Details</u></b>" +
          "<br>" +
          yourData1 +
          "<br><br><b><u>Semester Exam Score (%)</u></b>" +
          "<br>" +
          yourData
        );
        markerIcon.addTo(globalMap).bindPopup(popup);
      } else {
        markers['label'] = toolTip;
      }
    }
  }

  popups(markerIcon, markers, level) {
    let userLevel = localStorage.getItem("userLevel");
    let chklevel = false;
    switch (userLevel) {
      case "cluster":
        if (level == "Cluster" || level == "schoolPerCluster") {
          chklevel = true;
        }
        break;
      case "block":
        if (level == "Cluster" || level == "schoolPerCluster" || level == "Block" || level == "clusterPerBlock") {
          chklevel = true;
        }
        break;
      case "district":
        if (level == "Cluster" || level == "schoolPerCluster" || level == "Block" || level == "clusterPerBlock" || level == "District" || level == "blockPerDistrict") {
          chklevel = true;
        }
        break;
      default:
        chklevel = true;
        break;
    }
    if (chklevel) {
      markerIcon.on("mouseover", function (e) {
        this.openPopup();
      });
      markerIcon.on("mouseout", function (e) {
        this.closePopup();
      });

      this.layerMarkers.addLayer(markerIcon);
      if (level === "schoolPerCluster" || level === "School") {
        markerIcon.on("click", this.onClickSchool, this);
      } else {
        markerIcon.on("click", this.onClick_Marker, this);
      }
    }
    markerIcon.myJsonData = markers;
  }
  onClickSchool(event) { }

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

  // drilldown/ click functionality on markers
  onClick_Marker(event) {
    var data = event.target.myJsonData.Details;

    if (this.userAccessLevel === null || this.userAccessLevel === undefined || this.userAccessLevel === 'State') {
      if (data.district_id && !data.block_id && !data.cluster_id) {
        this.stateLevel = 1;
        this.onDistrictSelect(data.district_id);
      }
      if (data.district_id && data.block_id && !data.cluster_id) {
        this.stateLevel = 1;
        this.districtHierarchy = {
          distId: data.district_id,
        };
        this.onBlockSelect(data.block_id);
      }
      if (data.district_id && data.block_id && data.cluster_id) {
        this.stateLevel = 1;
        this.blockHierarchy = {
          distId: data.district_id,
          blockId: data.block_id,
        };
        this.onClusterSelect(data.cluster_id);
      }
    }

  }

  // clickMarker for Google map
  onClick_AgmMarker(event, marker) {
    if (this.level == "schoolPerCluster") {
      return false;
    }
    var data = marker.Details;

    if (this.userAccessLevel === null || this.userAccessLevel === undefined || this.userAccessLevel === 'State') {
      if (data.district_id && !data.block_id && !data.cluster_id) {
        this.stateLevel = 1;
        this.onDistrictSelect(data.district_id);
      }
      if (data.district_id && data.block_id && !data.cluster_id) {
        this.stateLevel = 1;
        this.districtHierarchy = {
          distId: data.district_id,
        };
        this.onBlockSelect(data.block_id);
      }
      if (data.district_id && data.block_id && data.cluster_id) {
        this.stateLevel = 1;
        this.blockHierarchy = {
          distId: data.district_id,
          blockId: data.block_id,
        };
        this.onClusterSelect(data.cluster_id);
      }
    }
  }

  // to download the csv report
  downloadReport() {
    var position = this.reportName.length;
    this.fileName = [this.fileName.slice(0, position), `_${this.management}`, this.fileName.slice(position)].join('');
    this.commonService.download(this.fileName, this.reportData);
  }

  // getting data to download........
  getDownloadableData(markers, level) {
    var details = {};
    var orgObject = {};
    var data1 = {};
    var data2 = {};
    Object.keys(markers.Details).forEach((key) => {
      if (key !== "latitude") {
        details[key] = markers.Details[key];
      }
    });

    Object.keys(details).forEach((key) => {
      var str = key.charAt(0).toUpperCase() + key.substr(1).toLowerCase();
      if (key !== "longitude") {
        orgObject[`${str}`] = details[key];
      }
    });
    var ordered = {};
    var mylevel;
    if (level == "District") {
      mylevel = level;
    } else if (level == "Block" || level == "blockPerDistrict") {
      mylevel = level;
    } else if (level == "Cluster" || level == "clusterPerBlock") {
      mylevel = level;
    } else if (level == "School" || level == "schoolPerCluster") {
      mylevel = level;
    }
    if (level != mylevel) {
      if (this.grade && !this.subject) {
        ordered = markers.Grades[`${this.grade}`];
      } else if (this.grade && this.subject) {
        ordered = {
          [`${this.subject}` + "_score"]: markers.Grades[`${this.grade}`][
            `${this.subject}`
          ],
        };
      } else {
        Object.keys(markers["Grade Wise Performance"])
          .sort()
          .forEach(function (key) {
            ordered[key] = markers["Grade Wise Performance"][key];
          });
      }
    } else {
      if (this.grade && !this.subject) {
        ordered = markers.Subjects;
      } else if (this.grade && this.subject) {
        ordered = {
          [`${this.subject}` + "_score"]: markers.Subjects[`${this.subject}`],
        };
      } else {
        Object.keys(markers["Grade Wise Performance"])
          .sort()
          .forEach(function (key) {
            ordered[key] = markers["Grade Wise Performance"][key];
          });
      }
    }

    var myobj = Object.assign(orgObject, ordered);
    this.reportData.push(myobj);
  }

  errorHandling() {
    this.schoolCount = undefined;
    this.studentAttended = undefined;
    this.studentCount = undefined;
    this.changeDetection.detectChanges();
    this.commonService.loaderAndErr([]);
  }

  goToprogressCard(): void {
    let data: any = {};

    if (this.dist) {
      data.level = "district";
      data.value = this.districtHierarchy.distId;
    } else if (this.blok) {
      data.level = "block";
      data.value = this.blockHierarchy.blockId;
    } else if (this.clust) {
      data.level = "cluster";
      data.value = this.clusterHierarchy.clusterId;
    } else {
      data.level = "state";
      data.value = null;
    }

    data["timePeriod"] = "overall";

    sessionStorage.setItem("progress-card-info", JSON.stringify(data));
    this._router.navigate(["/progressCard"]);
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

  filterRangeWiseData(value) {
    this.prevRange = value;
    this.schoolCount = 0;
    this.studentCount = 0
    this.studentAttended = 0;

    globalMap.removeLayer(this.markersList);
    this.layerMarkers.clearLayers();
    //getting relative colors for all markers:::::::::::
    var markers = [];
    if (value) {
      this.data.map(a => {
        if (!this.grade && !this.subject) {
          if (a.Details[`Performance`] > this.valueRange.split("-")[0] - 1 && a.Details[`Performance`] <= this.valueRange.split("-")[1]) {
            markers.push(a);
          }
        } else if (this.grade && !this.subject) {
          if (a['Subjects'][`Grade Performance`] > this.valueRange.split("-")[0] - 1 && a['Subjects'][`Grade Performance`] <= this.valueRange.split("-")[1]) {
            markers.push(a);
          }
        } else {
          if (a['Subjects'][`${this.subject}`] > this.valueRange.split("-")[0] - 1 && a['Subjects'][`${this.subject}`] <= this.valueRange.split("-")[1]) {
            markers.push(a);
          }
        }
      })
    } else {
      markers = this.data;
    }
    this.genericFun(markers, this.dataOptions, this.fileName);


    this.commonService.errMsg();
    if (this.level == 'District') {
      this.allDistricts = markers;
    } else if (this.level == 'Block' || this.level == 'blockPerDistrict') {
      this.allBlocks = markers;
    } else if (this.level == 'Cluster' || this.level == 'clusterPerBlock') {
      this.allClusters = markers;
    }
    if (markers.length > 0) {
      for (let i = 0; i < markers.length; i++) {
        this.studentAttended += markers[i].Details['students_attended'] ? markers[i].Details['students_attended'] : 0;
        this.studentCount += markers[i].Details['total_students'] ? markers[i].Details['total_students'] : 0;
        this.schoolCount += markers[i].Details['total_schools'] ? markers[i].Details['total_schools'] : 0;
      }
      this.schoolCount = this.schoolCount.toString().replace(/(\d)(?=(\d\d)+\d$)/g, "$1,");
      this.studentCount = this.studentCount.toString().replace(/(\d)(?=(\d\d)+\d$)/g, "$1,");
      this.studentAttended = this.studentAttended.toString().replace(/(\d)(?=(\d\d)+\d$)/g, "$1,");
    }
    //adjusting marker size and other UI on screen resize:::::::::::
    this.globalService.onResize(this.level);
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
    if (this.level == 'District') {
      this.allDistricts = this.data;
    } else if (this.level == 'Block' || this.level == 'blockPerDistrict') {
      this.allBlocks = this.data;
    } else if (this.level == 'Cluster' || this.level == 'clusterPerBlock') {
      this.allClusters = this.data;
    }
  }

  reset(value) {
    this.valueRange = value;
    this.selectedIndex = undefined;
    this.deSelect();
    this.filterRangeWiseData(value);
  }

}
