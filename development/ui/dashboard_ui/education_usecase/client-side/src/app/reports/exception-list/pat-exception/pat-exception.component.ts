import { Component, OnInit, ChangeDetectionStrategy, ChangeDetectorRef, ViewEncapsulation } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { ExceptionReportService } from '../../../services/exception-report.service';
import { Router } from '@angular/router';
import * as L from 'leaflet';
import * as R from 'leaflet-responsive-popup';
import { AppServiceComponent } from '../../../app.service';
import { MapService, globalMap } from '../../../services/map-services/maps.service';
import { environment } from 'src/environments/environment';
import { Observable } from 'rxjs';

@Component({
  selector: 'app-pat-exception',
  templateUrl: './pat-exception.component.html',
  styleUrls: ['./pat-exception.component.css'],
  changeDetection: ChangeDetectionStrategy.OnPush,
  encapsulation: ViewEncapsulation.None
})
export class PATExceptionComponent implements OnInit {
  public title: string = '';
  public titleName: string = '';
  public colors: any;

  public waterMark = environment.water_mark

  // to assign the count of below values to show in the UI footer
  public studentCount: any;
  public schoolCount: any;
  public dateRange: any = '';

  // to hide and show the hierarchy details
  public skul: boolean = true;
  public dist: boolean = false;
  public blok: boolean = false;
  public clust: boolean = false;

  // to hide the blocks and cluster dropdowns
  public distHidden: boolean = true;
  public blockHidden: boolean = true;
  public clusterHidden: boolean = true;

  // to set the hierarchy names
  public districtHierarchy: any = '';
  public blockHierarchy: any = '';
  public clusterHierarchy: any = '';

  // leaflet layer dependencies
  public layerMarkers = new L.layerGroup();
  public markersList = new L.FeatureGroup();

  // assigning the data to each of these to show in dropdowns and maps
  // for dropdowns
  public data: any;
  public markers: any = [];
  // for maps
  public districtMarkers: any = [];
  public blockMarkers: any = [];
  public clusterMarkers: any = [];
  public schoolMarkers: any = [];

  // to show and hide the dropdowns based on the selection of buttons
  public stateLevel: any = 0; // 0 for buttons and 1 for dropdowns

  // to download the excel report
  public fileName: any;
  public reportData: any = [];

  // variables
  public districtId: any = '';
  public blockId: any = '';
  public clusterId: any = '';

  public level = 'District';

  public myData;
  state: string;
  // initial center position for the map
  public lat: any;
  public lng: any;
  public mark: Observable<any>;

  timeRange = [{ key: 'overall', value: "Overall" }, { key: 'last_30_days', value: "Last 30 Days" }, { key: 'last_7_days', value: "Last 7 Days" }];
  period = 'overall';
  allGrades: any;
  grade = 'all';
  allSubjects: string[];
  subject = '';

  reportName = 'periodic_assesment_test_exception';
  managementName;
  management;
  category;

  mapName;
  googleMapZoom = 7;
  geoJson = this.globalService.geoJson;

  constructor(
    public http: HttpClient,
    public service: ExceptionReportService,
    public commonService: AppServiceComponent,
    public router: Router,
    private changeDetection: ChangeDetectorRef,
    public globalService: MapService,
  ) {
  }

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
    this.commonService.errMsg();
    this.state = this.commonService.state;
    this.globalService.latitude = this.lat = this.globalService.mapCenterLatlng.lat;
    this.globalService.longitude = this.lng = this.globalService.mapCenterLatlng.lng;
    this.changeDetection.detectChanges();
    this.globalService.initMap('patExceMap', [[this.lat, this.lng]]);
    if (this.mapName == 'googlemap') {
      document.getElementById('leafletmap').style.display = "none";
    }
    this.managementName = this.management = JSON.parse(localStorage.getItem('management')).id;
    this.category = JSON.parse(localStorage.getItem('category')).id;
    this.managementName = this.commonService.changeingStringCases(
      this.managementName.replace(/_/g, " ")
    );
    this.skul = true;
    document.getElementById('accessProgressCard').style.display = 'none';
    document.getElementById('backBtn') ? document.getElementById('backBtn').style.display = 'none' : "";
    this.fileName = `${this.reportName}_${this.period}_${this.grade != 'all' ? this.grade : 'allGrades'}_${this.subject ? this.subject : ''}_allDistricts_${this.commonService.dateAndTime}`;
    this.changeDetection.detectChanges();
    this.levelWiseFilter();
    //this.getView1()
    this.toHideDropdowns();

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

  onPeriodSelect() {
    this.levelWiseFilter();
  }

  onGradeSelect(data) {
    this.fileName = `${this.reportName}_${this.period}_${this.grade}_${this.subject ? this.subject : ''}_all_${this.commonService.dateAndTime}`;
    this.grade = data;
    this.subject = '';
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
    this.changeDetection.detectChanges();
  }


  selCluster = false;
  selBlock = false;
  selDist = false;
  levelVal = 0;
  getView() {
    let id = localStorage.getItem("userLocation");
    let level = localStorage.getItem("userLevel");

    if (level === "Cluster") {
      this.clusterlevel(id);
      this.levelVal = 3;
    } else if (level === "Block") {
      this.blocklevel(id);
      this.levelVal = 2;
    } else if (level === "District") {
      this.distlevel(id);
      this.levelVal = 1;
    }
  }

  getView1() {
    let id = localStorage.getItem("userLocation");
    let level = localStorage.getItem("userLevel");
    let clusterid = localStorage.getItem("clusterId");
    let blockid = localStorage.getItem("blockId");
    let districtid = localStorage.getItem("districtId");
    let schoolid = localStorage.getItem("schoolId");

    if (districtid !== 'null') {
      this.districtId = districtid;
      this.distHidden = false;
    }
    if (blockid !== 'null') {
      this.blockId = blockid;
      this.blockHidden = false;
    }
    if (clusterid !== 'null') {
      this.clusterId = clusterid;
      this.clusterHidden = false;
    }
    if (districtid === 'null') {
      this.distHidden = false;
    }


    if (level === "Cluster") {
      this.blockHierarchy = {
        blockId: blockid,
        distId: districtid
      }
      this.onClusterSelect(clusterid);
      // this.clusterlevel(clusterid);
      this.selCluster = true;
      this.selBlock = true;
      this.selDist = true;
      this.levelVal = 3;
    } else if (level === "Block") {
      this.districtHierarchy = {
        distId: districtid
      }
      this.onBlockSelect(blockid);

      this.selCluster = false;
      this.selBlock = true;
      this.selDist = true;
      this.levelVal = 2;
    } else if (level === "District") {
      this.onDistrictSelect(districtid);

      this.distlevel(districtid)
      this.levelVal = 1;
    }
  }

  distlevel(id) {
    this.selCluster = false;
    this.selBlock = false;
    this.selDist = true;
    //this.level= "blockPerDistrict";
    this.districtId = id;
    //this.levelWiseFilter();
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


  homeClick() {
    this.fileName = `${this.reportName}_${this.period}_${this.grade != 'all' ? this.grade : 'allGrades'}_${this.subject ? this.subject : ''}_allDistricts_${this.commonService.dateAndTime}`;
    this.grade = 'all';
    this.period = 'overall';
    this.level = "District";
    this.blok = true;
    this.subject = '';
    this.districtSelected = false;
    this.selectedCluster = false;
    this.blockSelected = false;
    this.hideAllBlockBtn = false;
    this.hideAllCLusterBtn = false;
    this.hideAllSchoolBtn = false;
    this.districtWise();
  }

  // to load all the districts for state data on the map
  districtWise() {
    try {
      // to clear the existing data on the map layer
      globalMap.removeLayer(this.markersList);
      this.layerMarkers.clearLayers();
      this.globalService.latitude = this.lat = this.globalService.mapCenterLatlng.lat;
      this.globalService.longitude = this.lng = this.globalService.mapCenterLatlng.lng;
      this.districtId = undefined;
      this.commonService.errMsg();
      this.reportData = [];
      this.schoolCount = '';
      this.level = "District";
      this.googleMapZoom = 7;

      // these are for showing the hierarchy names based on selection
      this.skul = true;
      this.dist = false;
      this.blok = false;
      this.clust = false;

      // to show and hide the dropdowns
      this.blockHidden = true;
      this.clusterHidden = true;

      this.service.gradeMetaData({ period: this.period, report: 'pat_exception' }).subscribe(res => {
        if (res['data']['district']) {
          this.allGrades = res['data']['district'];
          this.allGrades.sort((a, b) => (a.grade > b.grade) ? 1 : ((b.grade > a.grade) ? -1 : 0));
          this.allGrades = [{ grade: "all" }, ...this.allGrades.filter(item => item !== { grade: "all" })];
        }
        // api call to get all the districts data
        if (this.myData) {
          this.myData.unsubscribe();
        }
        this.myData = this.service.patExceptionDistWise({ ...{ grade: this.grade, subject: this.subject, timePeriod: this.period, report: 'pat_exception' }, ...{ management: this.management, category: this.category } }).subscribe(res => {
          this.data = res;
          // to show only in dropdowns
          this.markers = this.districtMarkers = this.data['data'];
          this.allSubjects = [];
          if (this.grade != 'all') {
            this.allSubjects = this.data['subjects'].filter(a => {
              return a != 'grade';
            });
          }
          // options to set for markers in the map
          let options = {
            radius: 6,
            fillOpacity: 1,
            strokeWeight: 0.01,
            weight: 1,
            mapZoom: this.globalService.zoomLevel,
            centerLat: this.lat,
            centerLng: this.lng,
            level: 'District'
          }

          this.globalService.restrictZoom(globalMap);
          globalMap.setMaxBounds([[options.centerLat - 4.5, options.centerLng - 6], [options.centerLat + 3.5, options.centerLng + 6]]);
          this.fileName = `${this.reportName}_${this.period}_${this.grade != 'all' ? this.grade : 'allGrades'}_${this.subject ? this.subject : ''}_allBlocks_${this.commonService.dateAndTime}`;

          this.genericFun(this.data, options, this.fileName);
          this.globalService.onResize(this.level);
          this.changeDetection.detectChanges();
          // sort the districtname alphabetically
          this.districtMarkers.sort((a, b) => (a.district_name > b.district_name) ? 1 : ((b.district_name > a.district_name) ? -1 : 0));
        }, err => {
          this.data = this.districtMarkers = [];
          this.commonService.loaderAndErr(this.data);
        });
      }, error => {
        this.data = [];
        this.commonService.loaderAndErr(this.data);
      });
      // adding the markers to the map layers
      globalMap.addLayer(this.layerMarkers);

    } catch (e) {
      console.log(e);
    }
  }

  // to load all the blocks for state data on the map
  blockWise() {
    try {
      // to clear the existing data on the map layer
      globalMap.removeLayer(this.markersList);
      this.layerMarkers.clearLayers();
      this.globalService.latitude = this.lat = this.globalService.mapCenterLatlng.lat;
      this.globalService.longitude = this.lng = this.globalService.mapCenterLatlng.lng;
      this.commonService.errMsg();
      this.level = "Block";
      this.googleMapZoom = 7;
      this.schoolCount = '';

      this.fileName = `${this.reportName}_${this.period}_${this.grade != 'all' ? this.grade : 'allGrades'}_${this.subject ? this.subject : ''}_allDistricts_${this.commonService.dateAndTime}`;

      this.reportData = [];
      this.districtId = undefined;
      this.blockId = undefined;
      // these are for showing the hierarchy names based on selection
      this.skul = true;
      this.dist = false;
      this.blok = false;
      this.clust = false;

      // to show and hide the dropdowns
      this.blockHidden = true;
      this.clusterHidden = true;

      this.service.gradeMetaData({ period: this.period, report: 'pat_exception' }).subscribe(res => {
        if (res['data']['block']) {
          this.allGrades = res['data']['block'];
          this.allGrades.sort((a, b) => (a.grade > b.grade) ? 1 : ((b.grade > a.grade) ? -1 : 0));
          this.allGrades = [{ grade: "all" }, ...this.allGrades.filter(item => item !== { grade: "all" })];
        }
        // api call to get the all clusters data
        if (this.myData) {
          this.myData.unsubscribe();
        }
        this.myData = this.service.patExceptionBlock({ ...{ grade: this.grade, subject: this.subject, timePeriod: this.period, report: 'pat_exception' }, ...{ management: this.management, category: this.category } }).subscribe(res => {
          this.data = res
          
          let options = {
            radius: 4,
            fillOpacity: 1,
            strokeWeight: 0.01,
            weight: 1,
            mapZoom: this.globalService.zoomLevel,
            centerLat: this.lat,
            centerLng: this.lng,
            level: 'Block'
          }
          if (this.data['data'].length > 0) {
            if (this.districtSelected) {

              let result = this.data['data']

              let marker = result.filter(a => {
                if (a.district_id === this.districtSlectedId) {
                  return a
                }
              })
              let markers = { data: marker }

              this.blockMarkers = [];
              // generate color gradient
              let colors = this.commonService.getRelativeColors(result, { value: 'percentage_schools_with_missing_data', report: 'exception' });
              this.colors = colors;
              // this.markers = this.blockMarkers = marker;
              this.allSubjects = [];
              if (this.grade != 'all') {
                this.allSubjects = this.data['subjects'].filter(a => {
                  return a != 'grade';
                });
              }
              this.globalService.restrictZoom(globalMap);
              globalMap.setMaxBounds([[options.centerLat - 4.5, options.centerLng - 6], [options.centerLat + 3.5, options.centerLng + 6]]);
              this.genericFun(markers, options, this.fileName);
              this.globalService.onResize(this.level);
              this.changeDetection.detectChanges();


            } else if (this.blockSelected) {
              let result = this.data['data'];

              let marker = result.filter(a => {
                if (a.block_id === this.blockSelectedId) {

                  return a
                }

              })
              let markers = { data: marker }
              this.blockMarkers = [];
              // generate color gradient
              let colors = this.commonService.getRelativeColors(result, { value: 'percentage_schools_with_missing_data', report: 'exception' });
              this.colors = colors;
              this.markers = this.blockMarkers = result;
              this.allSubjects = [];
              if (this.grade != 'all') {
                this.allSubjects = this.data['subjects'].filter(a => {
                  return a != 'grade';
                });
              }
              this.globalService.restrictZoom(globalMap);
              globalMap.setMaxBounds([[options.centerLat - 4.5, options.centerLng - 6], [options.centerLat + 3.5, options.centerLng + 6]]);
              this.genericFun(markers, options, this.fileName);
              this.globalService.onResize(this.level);
              this.changeDetection.detectChanges();

            } else if (this.selectedCluster) {
              let result = this.data['data']
              let marker = result.filter(a => {
                if (a.cluster_id === this.selectedCLusterId) {
                  return a
                }

              })
              let markers = { data: marker }
              this.blockMarkers = [];
              // generate color gradient
              let colors = this.commonService.getRelativeColors(result, { value: 'percentage_schools_with_missing_data', report: 'exception' });
              this.colors = colors;
              this.markers = this.blockMarkers = result;
              this.allSubjects = [];
              if (this.grade != 'all') {
                this.allSubjects = this.data['subjects'].filter(a => {
                  return a != 'grade';
                });
              }
              this.globalService.restrictZoom(globalMap);
              globalMap.setMaxBounds([[options.centerLat - 4.5, options.centerLng - 6], [options.centerLat + 3.5, options.centerLng + 6]]);
              this.genericFun(this.data, options, this.fileName);
              this.globalService.onResize(this.level);
              this.changeDetection.detectChanges();

            } else {
              let result = this.data['data']
              this.blockMarkers = [];
              // generate color gradient
              let colors = this.commonService.getRelativeColors(result, { value: 'percentage_schools_with_missing_data', report: 'exception' });
              this.colors = colors;
              this.markers = this.blockMarkers = result;
              this.allSubjects = [];
              if (this.grade != 'all') {
                this.allSubjects = this.data['subjects'].filter(a => {
                  return a != 'grade';
                });
              }
              this.globalService.restrictZoom(globalMap);
              globalMap.setMaxBounds([[options.centerLat - 4.5, options.centerLng - 6], [options.centerLat + 3.5, options.centerLng + 6]]);
              this.genericFun(this.data, options, this.fileName);
              this.globalService.onResize(this.level);
              this.changeDetection.detectChanges();

            }

          }
        }, err => {
          this.data = this.districtMarkers = [];
          this.commonService.loaderAndErr(this.data);
        });
      }, error => {
        this.data = [];
        this.commonService.loaderAndErr(this.data);
      });
      globalMap.addLayer(this.layerMarkers);

    } catch (e) {
      console.log(e);
    }
  }

  // to load all the clusters for state data on the map
  clusterWise() {
    try {
      // to clear the existing data on the map layer
      globalMap.removeLayer(this.markersList);
      this.layerMarkers.clearLayers();
      this.globalService.latitude = this.lat = this.globalService.mapCenterLatlng.lat;
      this.globalService.longitude = this.lng = this.globalService.mapCenterLatlng.lng;
      this.commonService.errMsg();
      this.level = "Cluster";
      this.googleMapZoom = 7;
      this.schoolCount = '';

      this.reportData = [];
      this.districtId = undefined;
      this.blockId = undefined;
      this.clusterId = undefined;

      // these are for showing the hierarchy names based on selection
      this.skul = true;
      this.dist = false;
      this.blok = false;
      this.clust = false;

      // to show and hide the dropdowns
      this.blockHidden = true;
      this.clusterHidden = true;
      this.fileName = `${this.reportName}_${this.period}_${this.grade != 'all' ? this.grade : 'allGrades'}_${this.subject ? this.subject : ''}_allClusters_${this.commonService.dateAndTime}`;

      this.service.gradeMetaData({ period: this.period, report: 'pat_exception' }).subscribe(res => {
        if (res['data']['cluster']) {
          this.allGrades = res['data']['cluster'];
          this.allGrades.sort((a, b) => (a.grade > b.grade) ? 1 : ((b.grade > a.grade) ? -1 : 0));
          this.allGrades = [{ grade: "all" }, ...this.allGrades.filter(item => item !== { grade: "all" })];
        }

        // api call to get the all clusters data
        if (this.myData) {
          this.myData.unsubscribe();
        }
        this.myData = this.service.patExceptionCluster({ ...{ grade: this.grade, subject: this.subject, timePeriod: this.period, report: 'pat_exception' }, ...{ management: this.management, category: this.category } }).subscribe(res => {
          this.data = res
          let options = {
            radius: 2,
            fillOpacity: 1,
            strokeWeight: 0.01,
            weight: 1,
            mapZoom: this.globalService.zoomLevel,
            centerLat: this.lat,
            centerLng: this.lng,
            level: 'Cluster'
          }
          if (this.data['data'].length > 0) {
            if (this.districtSelected) {
              let result = this.data['data'];
              result = result.sort((a, b) => (parseInt(a.percentage_schools_with_missing_data) < parseInt(b.percentage_schools_with_missing_data)) ? 1 : -1)
              let marker = result.filter(a => {
                if (a.district_id === this.districtSlectedId) {

                  return a
                }

              })

              let markers = { data: marker }

              this.clusterMarkers = [];
              // generate color gradient
              let colors = this.commonService.getRelativeColors(result, { value: 'percentage_schools_with_missing_data', report: 'exception' });
              this.colors = colors;
              this.markers = this.clusterMarkers = markers;
              this.allSubjects = [];
              if (this.grade != 'all') {
                this.allSubjects = this.data['subjects'].filter(a => {
                  return a != 'grade';
                });
              }
              this.globalService.restrictZoom(globalMap);
              globalMap.setMaxBounds([[options.centerLat - 4.5, options.centerLng - 6], [options.centerLat + 3.5, options.centerLng + 6]]);
              this.genericFun(markers, options, this.fileName);
              // this.schoolCount = this.data['footer'].toString().replace(/(\d)(?=(\d\d)+\d$)/g, "$1,");
              this.globalService.onResize(this.level);
              this.changeDetection.detectChanges();

            } else if (this.blockSelected) {
              let result = this.data['data'];
              result = result.sort((a, b) => (parseInt(a.percentage_schools_with_missing_data) < parseInt(b.percentage_schools_with_missing_data)) ? 1 : -1)

              let marker = result.filter(a => {
                if (a.block_id === this.blockSelectedId) {

                  return a
                }

              })

              let markers = { data: marker }

              this.clusterMarkers = [];
              // generate color gradient
              let colors = this.commonService.getRelativeColors(result, { value: 'percentage_schools_with_missing_data', report: 'exception' });
              this.colors = colors;
              this.markers = this.clusterMarkers = markers;
              this.allSubjects = [];
              if (this.grade != 'all') {
                this.allSubjects = this.data['subjects'].filter(a => {
                  return a != 'grade';
                });
              }
              this.globalService.restrictZoom(globalMap);
              globalMap.setMaxBounds([[options.centerLat - 4.5, options.centerLng - 6], [options.centerLat + 3.5, options.centerLng + 6]]);
              this.genericFun(markers, options, this.fileName);
              // this.schoolCount = this.data['footer'].toString().replace(/(\d)(?=(\d\d)+\d$)/g, "$1,");
              this.globalService.onResize(this.level);
              this.changeDetection.detectChanges();

            } else if (this.selectedCluster) {
              let result = this.data['data'];
              result = result.sort((a, b) => (parseInt(a.percentage_schools_with_missing_data) < parseInt(b.percentage_schools_with_missing_data)) ? 1 : -1)
              let marker = result.filter(a => {
                if (a.cluster_id === this.selectedCLusterId) {
                  return a
                }

              })

              let markers = { data: marker }
              this.clusterMarkers = [];
              // generate color gradient
              let colors = this.commonService.getRelativeColors(result, { value: 'percentage_schools_with_missing_data', report: 'exception' });
              this.colors = colors;
              this.markers = this.clusterMarkers = markers;
              this.allSubjects = [];
              if (this.grade != 'all') {
                this.allSubjects = this.data['subjects'].filter(a => {
                  return a != 'grade';
                });
              }
              this.globalService.restrictZoom(globalMap);
              globalMap.setMaxBounds([[options.centerLat - 4.5, options.centerLng - 6], [options.centerLat + 3.5, options.centerLng + 6]]);
              this.genericFun(markers, options, this.fileName);
              // this.schoolCount = this.data['footer'].toString().replace(/(\d)(?=(\d\d)+\d$)/g, "$1,");
              this.globalService.onResize(this.level);
              this.changeDetection.detectChanges();

            } else {
              let result = this.data['data'];
              result = result.sort((a, b) => (parseInt(a.percentage_schools_with_missing_data) < parseInt(b.percentage_schools_with_missing_data)) ? 1 : -1)

              this.clusterMarkers = [];
              // generate color gradient
              let colors = this.commonService.getRelativeColors(result, { value: 'percentage_schools_with_missing_data', report: 'exception' });
              this.colors = colors;
              this.markers = this.clusterMarkers = result;
              this.allSubjects = [];
              if (this.grade != 'all') {
                this.allSubjects = this.data['subjects'].filter(a => {
                  return a != 'grade';
                });
              }
              this.globalService.restrictZoom(globalMap);
              globalMap.setMaxBounds([[options.centerLat - 4.5, options.centerLng - 6], [options.centerLat + 3.5, options.centerLng + 6]]);
              this.genericFun(this.data, options, this.fileName);
              // this.schoolCount = this.data['footer'].toString().replace(/(\d)(?=(\d\d)+\d$)/g, "$1,");
              this.globalService.onResize(this.level);
              this.changeDetection.detectChanges();

            }


          }
        }, err => {
          this.data = this.districtMarkers = [];
          this.commonService.loaderAndErr(this.data);
        });
      }, error => {
        this.data = [];
        this.commonService.loaderAndErr(this.data);
      });
      globalMap.addLayer(this.layerMarkers);

    } catch (e) {
      console.log(e);
    }
  }

  // to load all the schools for state data on the map
  schoolWise() {
    try {
      // to clear the existing data on the map layer
      globalMap.removeLayer(this.markersList);
      this.layerMarkers.clearLayers();
      this.globalService.latitude = this.lat = this.globalService.mapCenterLatlng.lat;
      this.globalService.longitude = this.lng = this.globalService.mapCenterLatlng.lng;

      this.commonService.errMsg();
      this.level = "School";
      this.googleMapZoom = 7;
      this.schoolCount = '';
      this.fileName = `${this.reportName}_${this.period}_${this.grade != 'all' ? this.grade : 'allGrades'}_${this.subject ? this.subject : ''}_allSchools_${this.commonService.dateAndTime}`;

      this.reportData = [];
      // these are for showing the hierarchy names based on selection
      this.skul = true;
      this.dist = false;
      this.blok = false;
      this.clust = false;

      // to show and hide the dropdowns
      this.blockHidden = true;
      this.clusterHidden = true;

      this.service.gradeMetaData({ period: this.period, report: 'pat_exception' }).subscribe(res => {
        if (res['data']['school']) {
          this.allGrades = res['data']['school'];
          this.allGrades.sort((a, b) => (a.grade > b.grade) ? 1 : ((b.grade > a.grade) ? -1 : 0));
          this.allGrades = [{ grade: "all" }, ...this.allGrades.filter(item => item !== { grade: "all" })];
        }
        // api call to get the all schools data
        if (this.myData) {
          this.myData.unsubscribe();
        }
        this.myData = this.service.patExceptionSchool({ ...{ grade: this.grade, subject: this.subject, timePeriod: this.period, report: 'pat_exception' }, ...{ management: this.management, category: this.category } }).subscribe(res => {
          this.data = res
          let options = {
            radius: 1,
            fillOpacity: 1,
            strokeWeight: 0.01,
            weight: 1,
            mapZoom: this.globalService.zoomLevel,
            centerLat: this.lat,
            centerLng: this.lng,
            level: 'School'
          }
          this.schoolMarkers = [];
          if (this.data['data'].length > 0) {
            if (this.districtSelected) {
              let result = this.data['data']
              result = result.sort((a, b) => (parseInt(a.percentage_schools_with_missing_data) < parseInt(b.percentage_schools_with_missing_data)) ? 1 : -1)
              // generate color gradient
              let marker = result.filter(a => {
                if (a.district_id === this.districtSlectedId) {

                  return a
                }

              })
              let markers = { data: marker }
              this.markers = this.schoolMarkers = marker;
              this.allSubjects = [];
              if (this.grade != 'all') {
                this.allSubjects = this.data['subjects'].filter(a => {
                  return a != 'grade';
                });
              }
              globalMap.doubleClickZoom.enable();
              globalMap.scrollWheelZoom.enable();
              globalMap.setMaxBounds([[options.centerLat - 4.5, options.centerLng - 6], [options.centerLat + 3.5, options.centerLng + 6]]);
              this.genericFun(markers, options, this.fileName);
              // this.schoolCount = this.data['footer'].toString().replace(/(\d)(?=(\d\d)+\d$)/g, "$1,");
              this.globalService.onResize(this.level);
              this.changeDetection.detectChanges();

            } else if (this.blockSelected) {
              let result = this.data['data']
              result = result.sort((a, b) => (parseInt(a.percentage_schools_with_missing_data) < parseInt(b.percentage_schools_with_missing_data)) ? 1 : -1)
              // generate color gradient
              let marker = result.filter(a => {
                if (a.block_id === this.blockSelectedId) {

                  return a
                }

              })
              let markers = { data: marker }
              this.markers = this.schoolMarkers = marker;
              this.allSubjects = [];
              if (this.grade != 'all') {
                this.allSubjects = this.data['subjects'].filter(a => {
                  return a != 'grade';
                });
              }
              globalMap.doubleClickZoom.enable();
              globalMap.scrollWheelZoom.enable();
              globalMap.setMaxBounds([[options.centerLat - 4.5, options.centerLng - 6], [options.centerLat + 3.5, options.centerLng + 6]]);
              this.genericFun(markers, options, this.fileName);
              // this.schoolCount = this.data['footer'].toString().replace(/(\d)(?=(\d\d)+\d$)/g, "$1,");
              this.globalService.onResize(this.level);
              this.changeDetection.detectChanges();

            } else if (this.selectedCluster) {
              let result = this.data['data']
              result = result.sort((a, b) => (parseInt(a.percentage_schools_with_missing_data) < parseInt(b.percentage_schools_with_missing_data)) ? 1 : -1)
              // generate color gradient
              let marker = result.filter(a => {
                if (a.cluster_id === this.selectedCLusterId) {
                  return a
                }

              })
              let markers = { data: marker }
              this.markers = this.schoolMarkers = result;
              this.allSubjects = [];
              if (this.grade != 'all') {
                this.allSubjects = this.data['subjects'].filter(a => {
                  return a != 'grade';
                });
              }
              globalMap.doubleClickZoom.enable();
              globalMap.scrollWheelZoom.enable();
              globalMap.setMaxBounds([[options.centerLat - 4.5, options.centerLng - 6], [options.centerLat + 3.5, options.centerLng + 6]]);
              this.genericFun(markers, options, this.fileName);
              // this.schoolCount = this.data['footer'].toString().replace(/(\d)(?=(\d\d)+\d$)/g, "$1,");
              this.globalService.onResize(this.level);
              this.changeDetection.detectChanges();

            } else {
              let result = this.data['data']
              result = result.sort((a, b) => (parseInt(a.percentage_schools_with_missing_data) < parseInt(b.percentage_schools_with_missing_data)) ? 1 : -1)
              // generate color gradient

              this.markers = this.schoolMarkers = result;
              this.allSubjects = [];
              if (this.grade != 'all') {
                this.allSubjects = this.data['subjects'].filter(a => {
                  return a != 'grade';
                });
              }
              globalMap.doubleClickZoom.enable();
              globalMap.scrollWheelZoom.enable();
              globalMap.setMaxBounds([[options.centerLat - 4.5, options.centerLng - 6], [options.centerLat + 3.5, options.centerLng + 6]]);
              this.genericFun(this.data, options, this.fileName);
              // this.schoolCount = this.data['footer'].toString().replace(/(\d)(?=(\d\d)+\d$)/g, "$1,");
              this.globalService.onResize(this.level);
              this.changeDetection.detectChanges();

            }


          }
        }, err => {
          this.data = this.districtMarkers = [];
          this.commonService.loaderAndErr(this.data);
        });
      }, error => {
        this.data = [];
        this.commonService.loaderAndErr(this.data);
      });
      globalMap.addLayer(this.layerMarkers);

    } catch (e) {
      console.log(e);
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
    // to clear the existing data on the map layer  
    globalMap.removeLayer(this.markersList);
    this.layerMarkers.clearLayers();
    this.commonService.errMsg();
    this.blockId = undefined;
    this.schoolCount = '';
    this.level = "blockPerDistrict"
    this.googleMapZoom = 9;
    // to show and hide the dropdowns
    this.blockHidden = false;
    this.clusterHidden = true;
    this.reportData = [];

    // api call to get the blockwise data for selected district
    if (this.myData) {
      this.myData.unsubscribe();
    }
    this.myData = this.service.patExceptionBlockPerDist(districtId, { ...{ grade: this.grade, subject: this.subject, timePeriod: this.period, report: 'pat_exception' }, ...{ management: this.management, category: this.category } }).subscribe(res => {
      this.data = res;

      this.markers = this.blockMarkers = this.data['data'];
      this.allSubjects = [];
      if (this.grade != 'all') {
        this.allSubjects = this.data['subjects'].filter(a => {
          return a != 'grade';
        });
      }
      // set hierarchy values
      this.districtHierarchy = {
        distId: this.data['data'][0].district_id,
        districtName: this.data['data'][0].district_name
      }

      this.districtId = districtId;

      // these are for showing the hierarchy names based on selection
      this.skul = false;
      this.dist = true;
      this.blok = false;
      this.clust = false;

      // options to set for markers in the map
      let options = {
        radius: 5,
        fillOpacity: 1,
        strokeWeight: 0.01,
        weight: 1,
        mapZoom: this.globalService.zoomLevel + 1,
        centerLat: this.data['data'][0].block_latitude,
        centerLng: this.data['data'][0].block_longitude,
        level: 'blockPerDistrict'
      }
      this.globalService.latitude = this.lat = options.centerLat;
      this.globalService.longitude = this.lng = options.centerLng;

      this.globalService.restrictZoom(globalMap);
      globalMap.setMaxBounds([[options.centerLat - 1.5, options.centerLng - 3], [options.centerLat + 1.5, options.centerLng + 2]]);
      this.fileName = `${this.reportName}_${this.period}_${this.grade != 'all' ? this.grade : 'allGrades'}_${this.subject ? this.subject : ''}_${options.level}s_of_district_${districtId}_${this.commonService.dateAndTime}`;
      this.genericFun(this.data, options, this.fileName);
      this.globalService.onResize(this.level);
      this.changeDetection.detectChanges();
      // sort the blockname alphabetically
      this.blockMarkers.sort((a, b) => (a.block_name > b.block_name) ? 1 : ((b.block_name > a.block_name) ? -1 : 0));
      this.mark = this.blockMarkers;

    }, err => {
      this.data = this.blockMarkers = [];
      this.commonService.loaderAndErr(this.data);
    });
    globalMap.addLayer(this.layerMarkers);


  }

  // to load all the clusters for selected block for state data on the map
  public blockSelected: boolean = false
  public blockSelectedId
  onBlockSelect(blockId) {
    // to clear the existing data on the map layer
    this.districtSelected = false
    this.selectedCluster = false
    this.blockSelected = true
    this.blockSelectedId = blockId
    this.hideAllBlockBtn = true;
    this.hideAllCLusterBtn = true;
    this.hideAllSchoolBtn = false;
    globalMap.removeLayer(this.markersList);
    this.layerMarkers.clearLayers();
    this.commonService.errMsg();
    this.clusterId = undefined;
    this.schoolCount = '';
    this.level = "clusterPerBlock";
    this.googleMapZoom = 11;
    // to show and hide the dropdowns
    this.blockHidden = false;
    this.clusterHidden = false;
    this.reportData = [];

    // api call to get the clusterwise data for selected district, block
    if (this.myData) {
      this.myData.unsubscribe();
    }

    this.myData = this.service.patExceptionClusterPerBlock(this.districtHierarchy.distId, blockId, { ...{ grade: this.grade, subject: this.subject, timePeriod: this.period, report: 'pat_exception' }, ...{ management: this.management, category: this.category } }).subscribe(res => {
      this.data = res;
      this.markers = this.clusterMarkers = this.data['data'];
      this.allSubjects = [];
      if (this.grade != 'all') {
        this.allSubjects = this.data['subjects'].filter(a => {
          return a != 'grade';
        });
      }
      var myBlocks = [];
      this.blockMarkers.forEach(element => {
        if (element.district_id === this.districtHierarchy.distId) {
          myBlocks.push(element);
        }
      });
      this.blockMarkers = myBlocks;

      // set hierarchy values
      this.blockHierarchy = {
        distId: this.data['data'][0].district_id,
        districtName: this.data['data'][0].district_name,
        blockId: this.data['data'][0].block_id,
        blockName: this.data['data'][0].block_name
      }

      this.districtId = this.data['data'][0].district_id;
      this.blockId = blockId;

      // these are for showing the hierarchy names based on selection
      this.skul = false;
      this.dist = false;
      this.blok = true;
      this.clust = false;

      // options to set for markers in the map
      let options = {
        radius: 5,
        fillOpacity: 1,
        strokeWeight: 0.01,
        weight: 1,
        mapZoom: this.globalService.zoomLevel + 3,
        centerLat: this.data['data'][0].cluster_latitude,
        centerLng: this.data['data'][0].cluster_longitude,
        level: 'clusterPerBlock'
      }
      this.globalService.latitude = this.lat = options.centerLat;
      this.globalService.longitude = this.lng = options.centerLng;

      this.globalService.restrictZoom(globalMap);
      globalMap.setMaxBounds([[options.centerLat - 1.5, options.centerLng - 3], [options.centerLat + 1.5, options.centerLng + 2]]);
      this.fileName = `${this.reportName}_${this.period}_${this.grade != 'all' ? this.grade : 'allGrades'}_${this.subject ? this.subject : ''}_${options.level}s_of_block_${blockId}_${this.commonService.dateAndTime}`;
      this.genericFun(this.data, options, this.fileName);
      this.globalService.onResize(this.level);
      this.changeDetection.detectChanges();

      // sort the clusterName alphabetically
      this.clusterMarkers.sort((a, b) => (a.cluster_name > b.cluster_name) ? 1 : ((b.cluster_name > a.cluster_name) ? -1 : 0));
    }, err => {
      this.data = this.clusterMarkers = [];
      this.commonService.loaderAndErr(this.data);
    });
    globalMap.addLayer(this.layerMarkers);

  }

  // to load all the schools for selected cluster for state data on the map
  public selectedCluster: boolean = false;
  public selectedCLusterId
  public hideAllBlockBtn: boolean = false
  public hideAllCLusterBtn: boolean = false
  public hideAllSchoolBtn: boolean = false
  onClusterSelect(clusterId) {
    this.hideAllBlockBtn = true;
    this.hideAllCLusterBtn = true;
    this.hideAllSchoolBtn = true;
    this.blockSelected = false
    this.districtSelected = false
    this.selectedCluster = true
    this.selectedCLusterId = clusterId
    // to clear the existing data on the map layer
    globalMap.removeLayer(this.markersList);
    this.layerMarkers.clearLayers();
    this.commonService.errMsg();
    this.schoolCount = '';
    this.level = "schoolPerCluster";
    this.googleMapZoom = 13;
    this.blockHidden = false;
    this.clusterHidden = false;
    this.reportData = [];

    // api call to get the schoolwise data for selected district, block, cluster
    if (this.myData) {
      this.myData.unsubscribe();
    }
    this.myData = this.service.patExceptionBlock({ ...{ grade: this.grade, subject: this.subject, timePeriod: this.period, report: 'pat_exception' }, ...{ management: this.management, category: this.category } }).subscribe(result => {
      this.myData = this.service.patExceptionSchoolPerClustter(this.blockHierarchy.distId, this.blockHierarchy.blockId, clusterId, { ...{ grade: this.grade, subject: this.subject, timePeriod: this.period, report: 'pat_exception' }, ...{ management: this.management, category: this.category } }).subscribe(res => {
        this.data = res;
        this.markers = this.schoolMarkers = this.data['data'];
        this.allSubjects = [];
        if (this.grade != 'all') {
          this.allSubjects = this.data['subjects'].filter(a => {
            return a != 'grade';
          });
        }
        var markers = result['data'];
        var myBlocks = [];
        markers.forEach(element => {
          if (element.district_id === this.blockHierarchy.distId) {
            myBlocks.push(element);
          }
        });
        this.blockMarkers = myBlocks;

        var myCluster = [];
        this.clusterMarkers.forEach(element => {
          if (element.block_id === this.blockHierarchy.blockId) {
            myCluster.push(element);
          }
        });
        this.clusterMarkers = myCluster;

        // set hierarchy values
        this.clusterHierarchy = {
          distId: this.data['data'][0].district_id,
          districtName: this.data['data'][0].district_name,
          blockId: this.data['data'][0].block_id,
          blockName: this.data['data'][0].block_name,
          clusterId: this.data['data'][0].cluster_id,
          clusterName: this.data['data'][0].cluster_name,
        }

        this.districtHierarchy = {
          distId: this.data['data'][0].district_id
        }

        this.districtId = this.data['data'][0].district_id;
        this.blockId = this.data['data'][0].block_id;
        this.clusterId = clusterId;

        // these are for showing the hierarchy names based on selection
        this.skul = false;
        this.dist = false;
        this.blok = false;
        this.clust = true;

        // options to set for markers in the map
        let options = {
          radius: 5,
          fillOpacity: 1,
          strokeWeight: 0.01,
          weight: 1,
          mapZoom: this.globalService.zoomLevel + 5,
          centerLat: this.data['data'][0].school_latitude,
          centerLng: this.data['data'][0].school_longitude,
          level: 'schoolPerCluster'
        }
        this.globalService.latitude = this.lat = options.centerLat;
        this.globalService.longitude = this.lng = options.centerLng;

        globalMap.doubleClickZoom.enable();
        globalMap.scrollWheelZoom.enable();
        globalMap.setMaxBounds([[options.centerLat - 1.5, options.centerLng - 3], [options.centerLat + 1.5, options.centerLng + 2]]);
        this.fileName = `${this.reportName}_${this.period}_${this.grade != 'all' ? this.grade : 'allGrades'}_${this.subject ? this.subject : ''}_${options.level}s_of_cluster_${clusterId}_${this.commonService.dateAndTime}`;
        this.genericFun(this.data, options, this.fileName);
        this.globalService.onResize(this.level);
        this.changeDetection.detectChanges();
      }, err => {
        this.data = [];
        this.commonService.loaderAndErr(this.data);
      });
    }, err => {
      this.data = [];
      this.commonService.loaderAndErr(this.data);
    });
    globalMap.addLayer(this.layerMarkers);

  }

  // common function for all the data to show in the map
  genericFun(data, options, fileName) {
    try {
      this.reportData = [];
      if (data['data'].length > 0) {
        this.markers = [];
        this.markers = data['data'];
        var updatedMarkers = this.markers.filter(a => {
          return a.total_schools_with_missing_data && a.total_schools_with_missing_data != 0;
        });
        this.markers = updatedMarkers;
        this.schoolCount = 0;
        // generate color gradient
        this.colors = this.commonService.getRelativeColors(this.markers, { value: 'percentage_schools_with_missing_data', report: 'exception' });
        // attach values to markers
        for (let i = 0; i < this.markers.length; i++) {
          this.schoolCount = this.schoolCount + parseInt(this.markers[i].total_schools_with_missing_data);
          this.getLatLng(options.level, this.markers[i]);
          // google map circle icon
          if (this.mapName == "googlemap") {
            let markerColor = this.commonService.relativeColorGredient(this.markers[i], { value: 'percentage_schools_with_missing_data', report: 'exception' }, this.colors);
            this.markers[i]['icon'] = this.globalService.initGoogleMapMarker(markerColor, options.radius, 1);
          }
          var markerIcon = this.globalService.initMarkers1(this.latitude, this.longitude, this.commonService.relativeColorGredient(this.markers[i], { value: 'percentage_schools_with_missing_data', report: 'exception' }, this.colors), options.strokeWeight, options.weight, options.level);
          if (markerIcon)
            this.generateToolTip(this.markers[i], options.level, markerIcon, this.strLat, this.strLng);
        }

        this.fileName = fileName;
        this.commonService.loaderAndErr(this.data);
        this.changeDetection.markForCheck();
      }
      this.schoolCount = this.schoolCount.toString().replace(/(\d)(?=(\d\d)+\d$)/g, "$1,");
    } catch (e) {
      this.data = [];
      this.commonService.loaderAndErr(this.data);
    }
  }


  latitude; strLat; longitude; strLng;
  getLatLng(level, marker) {
    if (level == "District") {
      this.latitude = marker.district_latitude;
      delete marker.district_latitude;
      marker['latitude'] = this.latitude;
      this.strLat = "latitude";
      this.longitude = marker.district_longitude;
      delete marker.district_longitude;
      marker['longitude'] = this.longitude;
      this.strLng = "longitude";
    }
    if (level == "Block" || level == "blockPerDistrict") {
      this.latitude = marker.block_latitude;
      delete marker.block_latitude;
      marker['latitude'] = this.latitude;
      this.strLat = "latitude";
      this.longitude = marker.block_longitude;
      delete marker.block_longitude;
      marker['longitude'] = this.longitude;
      this.strLat = "longitude";
    }
    if (level == "Cluster" || level == "clusterPerBlock") {
      this.latitude = marker.cluster_latitude;
      delete marker.cluster_latitude;
      marker['latitude'] = this.latitude;
      this.strLat = "latitude";
      this.longitude = marker.cluster_longitude;
      delete marker.cluster_longitude;
      marker['longitude'] = this.longitude;
      this.strLat = "longitude";
    }
    if (level == "School" || level == "schoolPerCluster") {
      this.latitude = marker.school_latitude;
      delete marker.school_latitude;
      marker['latitude'] = this.latitude;
      this.strLat = "latitude";
      this.longitude = marker.school_longitude;
      delete marker.school_longitude;
      marker['longitude'] = this.longitude;
      this.strLat = "longitude";
    }
  }

  popups(markerIcon, markers, level) {
    markerIcon.on('mouseover', function (e) {
      this.openPopup();
    });
    markerIcon.on('mouseout', function (e) {
      this.closePopup();
    });

    this.layerMarkers.addLayer(markerIcon);
    if (level != 'School' || level != 'schoolPerCluster') {
      markerIcon.on('click', this.onClick_Marker, this)
    }
    markerIcon.myJsonData = markers;
  }

  onSubjectSelect(data) {
    this.levelWiseFilter();
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

  // drilldown/ click functionality on markers
  onClick_Marker(event) {
    var data = event.target.myJsonData;
    if (data.district_id && !data.block_id && !data.cluster_id) {
      this.stateLevel = 1;
      this.onDistrictSelect(data.district_id)
    }
    if (data.district_id && data.block_id && !data.cluster_id) {
      this.stateLevel = 1;
      this.districtHierarchy = {
        distId: data.district_id
      }
      this.onBlockSelect(data.block_id)
    }
    if (data.district_id && data.block_id && data.cluster_id) {
      this.stateLevel = 1;
      this.blockHierarchy = {
        distId: data.district_id,
        blockId: data.block_id
      }
      this.onClusterSelect(data.cluster_id)
    }
  }

  // clickMarker for Google map
  onClick_AgmMarker(event, marker) {
    if (this.level == "schoolPerCluster") {
      return false;
    }
    var data = marker;
    if (data.district_id && !data.block_id && !data.cluster_id) {
      this.stateLevel = 1;
      this.onDistrictSelect(data.district_id)
    }
    if (data.district_id && data.block_id && !data.cluster_id) {
      this.stateLevel = 1;
      this.districtHierarchy = {
        distId: data.district_id
      }
      this.onBlockSelect(data.block_id)
    }
    if (data.district_id && data.block_id && data.cluster_id) {
      this.stateLevel = 1;
      this.blockHierarchy = {
        distId: data.district_id,
        blockId: data.block_id
      }
      this.onClusterSelect(data.cluster_id)
    }
  }

  // google maps
  mouseOverOnmaker(infoWindow, $event: MouseEvent): void {
    infoWindow.open();
  }

  mouseOutOnmaker(infoWindow, $event: MouseEvent) {
    infoWindow.close();
  }


  // to download the excel report
  downloadReport() {
    this.reportData.forEach(element => {
      if (element.number_of_schools != undefined) {
        element['number_of_schools'] = element.number_of_schools.replace(/\,/g, '');
      }
    });
    var position = this.reportName.length;
    this.fileName = [this.fileName.slice(0, position), `_${this.management}`, this.fileName.slice(position)].join('');
    this.commonService.download(this.fileName, this.reportData);
  }

  generateToolTip(markers, level, markerIcon, lat, lng) {
    this.popups(markerIcon, markers, level);
    var details = {};
    var orgObject = {};
    let remIcon = {};
    if (this.mapName == 'googlemap') {
      Object.keys(markers).forEach(key => {
        if (key !== 'icon') {
          remIcon[key] = markers[key];
        }
      });
    } else {
      remIcon = markers;
    }
    Object.keys(remIcon).forEach(key => {
      if (key !== lat) {
        details[key] = remIcon[key];
      }
    });
    Object.keys(details).forEach(key => {
      if (key !== lng) {
        orgObject[key] = details[key];
      }
    });
    var detailSchool = {};
    var yourData;
    if (level == "School" || level == "schoolPerCluster") {
      Object.keys(orgObject).forEach(key => {
        if (key !== "total_schools_with_missing_data") {
          detailSchool[key] = orgObject[key];
        }
      });
      this.reportData.push(detailSchool);
      yourData = this.globalService.getInfoFrom(detailSchool, "percentage_schools_with_missing_data", level, "sem-exception", undefined, undefined).join(" <br>");
    } else {
      this.reportData.push(orgObject);
      yourData = this.globalService.getInfoFrom(orgObject, "percentage_schools_with_missing_data", level, "sem-exception", undefined, undefined).join(" <br>");

    }
    //Generate dynamic tool-tip
    if (this.mapName != 'googlemap') {
      const popup = R.responsivePopup({ hasTip: false, autoPan: false, offset: [15, 20] }).setContent(
        yourData);
      markerIcon.addTo(globalMap).bindPopup(popup);
    } else {
      markers['label'] = yourData;
    }
  }
}
