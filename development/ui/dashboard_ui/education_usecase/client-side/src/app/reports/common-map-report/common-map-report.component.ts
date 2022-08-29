import { HttpClient } from '@angular/common/http';
import { ChangeDetectorRef, Component, Input, OnInit } from '@angular/core';
import { Router } from '@angular/router';
import { AppServiceComponent } from 'src/app/app.service';
import { MapService, globalMap } from 'src/app/services/map-services/maps.service';
import { SchoolInfraService } from 'src/app/services/school-infra.service';
import { environment } from "src/environments/environment";
import * as L from "leaflet";
import * as R from "leaflet-responsive-popup";
import { dynamicReportService } from "src/app/services/dynamic-report.service";
import { ActivatedRoute } from '@angular/router';


@Component({
  selector: 'app-common-map-report',
  templateUrl: './common-map-report.component.html',
  styleUrls: ['./common-map-report.component.css']
})
export class CommonMapReportComponent implements OnInit {

  @Input() public header: any;
  @Input() public description: String;
  @Input() public reportName1: String;

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
  public skul: boolean = true;
  public dist: boolean = false;
  public blok: boolean = false;
  public clust: boolean = false;

  // to hide the blocks and cluster dropdowns
  public blockHidden: boolean = true;
  public clusterHidden: boolean = true;
  public hideDist: boolean = false;

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
  public districtId: any = "";
  public blockId: any = "";
  public clusterId: any = "";

  public myData;
  public infraFilter: any = [];

  public myDistData: any;
  public myBlockData: any = [];
  public myClusterData: any = [];
  public mySchoolData: any = [];
  public metricName
  public selectedType
  state: string;
  // initial center position for the map
  public lat: any;
  public lng: any;

  years: any = [];
  grades = [];
  subjects = [];
  date = [];
  allViews = [];
  public months: any = []
  public year = "";
  public grade = "all";
  public subject = "all";
  public examDate = "all";
  public viewBy = "indicator";
  public weeks: any = []

  hideMonth: boolean = true
  hideWeek: boolean = true
  hideDay: boolean = true
  hideYear: boolean = true
  public dataOptions = {};
  public onRangeSelect;


  colorGenData: any = [];
  reportName = "infrastructure_access_by_location";
  dateAndTime;
  mapName;

  reportType = "Map"
  timeRange

  period = "overall";

  public metaData
  googleMapZoom;
  datasourse = ""
  constructor(public http: HttpClient,
    public service: SchoolInfraService,
    public service1: dynamicReportService,
    public commonService: AppServiceComponent,
    public router: Router,
    private changeDetection: ChangeDetectorRef,
    private readonly _router: Router,
    private aRoute: ActivatedRoute,
    public globalService: MapService,) {
    this.datasourse = this.aRoute.snapshot.params.id
    this.getTimelineMeta()

    this.getMetricMeta()

  }

  selected = "absolute";



  managementName;
  management;
  category;



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
    this.globalService.initMap("commonMap", [[this.lat, this.lng]]);
    if (this.mapName == 'googlemap') {
      document.getElementById('leafletmap').style.display = "none";
    }
    document.getElementById("accessProgressCard").style.display = "block";
    document.getElementById("backBtn") ? document.getElementById("backBtn").style.display = "none" : "";
    this.managementName = this.management = JSON.parse(localStorage.getItem('management')).id;
    this.category = JSON.parse(localStorage.getItem('category')).id;
    this.managementName = this.commonService.changeingStringCases(
      this.managementName.replace(/_/g, " ")
    );
    this.getMetaData()

    let params = JSON.parse(sessionStorage.getItem("report-level-info"));

    if (environment.auth_api === 'cqube' || this.userAccessLevel === "") {
      if (params && params.level) {
        let data = params.data;
        if (params.level === "district") {
          this.districtHierarchy = {
            distId: data.id,
          };

          this.districtId = data.id;

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

          this.districtId = data.blockHierarchy.distId;
          this.blockId = data.blockId;
          this.clusterId = data.id;

        }
      } else {
        this.changeDetection.detectChanges();
        this.levelWiseFilter();
      }
    } else {
      this.getView()
    }


    this.hideAccessBtn = (environment.auth_api === 'cqube' || this.userAccessLevel === "" || undefined || null) ? true : false;
    this.hideDist = (environment.auth_api === 'cqube' || this.userAccessLevel === "" || undefined || null) ? false : true;


    if (this.userAccessLevel !== "") {
      this.hideIfAccessLevel = true;
    }

    this.header = `Report on ${this.datasourse.replace(/_+/g, ' ')} access by location for`
    this.description = `The ${this.datasourse.replace(/_+/g, ' ')} dashboard visualises the data on ${this.datasourse.replace(/_+/g, ' ')} metrics for ${this.state}`
  }

  getMetricMeta() {

    this.service1.configurableMetricMeta({ dataSource: this.datasourse }).subscribe(res => {
      this.metricName = ""

      this.metricName = res

      this.metricName.forEach(metric => this.metricName = metric.result_column.trim())

      this.selectedType = this.metricName.trim()
    })
  }
  getTimelineMeta() {
    this.service1.configurableTimePeriodMeta({ dataSource: this.datasourse }).subscribe(res => {
      this.timeRange = res
      const key = 'value';
      this.timeRange = [...new Map(this.timeRange.map(item =>
        [item[key], item])).values()];

    })
  }

  public hideSubject: boolean

  getMetaData() {
    this.years = []

    this.service1.configurableMetaData({ dataSource: this.datasourse }).subscribe(res => {
      this.metaData = res["data"]
      this.hideSubject = res['isSubjAvailable']
      if (this.period === "year and month") {

        for (let i = 0; i < this.metaData.length; i++) {
          if (this.metaData[i]["academic_year"] !== 'overall') {
            this.years.push(this.metaData[i]["academic_year"]);
          }
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
      } else {
        this.grades = this.metaData.filter(meta => meta.academic_year === 'overall')
        this.grades = this.grades[0]?.data['grades']
      }


      this.grades = [
        { grade: "all" },
        ...this.grades.filter((item) => item !== { grade: "all" }),
      ];

    }, err => {
      document.getElementById('spinner').style.display = "none"
    })
  }

  public month = ""
  public gradeSelected = false
  public dateSeleted = false

  selectedExamDate() {
    this.dateSeleted = true
    this.grade = "all";
    this.subject = "all";
    this.fileName = `${this.reportName}_${this.grade}_${this.examDate}_allDistricts_${this.month}_${this.year}_${this.commonService.dateAndTime}`;
    if (this.hideAccessBtn) {
      this.levelWiseFilter();
    } else {
      this.getView()
    }
  }
  selectedTimePeriod = async () => {
    document.getElementById('spinner').style.display = "block"
    this.getMetaData()
    globalMap.removeLayer(this.markersList);
    this.layerMarkers.clearLayers();

    this.hideMonth = this.period === "year and month" ? false : true;
    this.hideYear = this.period === "year and month" ? false : true;
    this.hideWeek = this.period === "year and month" ? false : true;
    this.months = [...this.months.filter((item) => item)]


    setTimeout(() => {
      this.month = this.period === "year and month" ? this.months[this.months.length - 1]['months'] : '';
      this.weeks = this.period === "year and month" ? this.months.find(a => { return a.months == this.month }).weeks : "";
      this.week = this.period === "year and month" ? this.week : "";
    }, 800);


    this.grade = "all";
    this.examDate = "all";
    this.subject = "all";

    if (this.hideAccessBtn) {
      setTimeout(() => {
        document.getElementById('spinner').style.display = "none"
        this.levelWiseFilter();
      }, 1000);
    } else {
      setTimeout(() => {
        document.getElementById('spinner').style.display = "none"
        this.getView()
      }, 1000);
    }
  }

  selectedYear(event) {
    this.hideMonth = this.period === "year and month" ? false : true;
    this.hideYear = this.period === "year and month" ? false : true;
    this.hideWeek = this.period === "year and month" ? false : true;
    this.week = ""
    this.weeks = []
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
      this.weeks = this.period === "year and month" ? this.months.find(a => { return a.months == this.month }).weeks : "";

      if (this.weeks[0].week === 0) {
        this.weeks = []
      }

    } else {
      this.months = [...this.months.filter((item) => item)]
      this.hideMonth = this.period === "year and month" ? false : true;
      this.hideYear = this.period === "year and month" ? false : true;
      this.hideWeek = this.period === "year and month" ? false : true;
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
      this.getView()
    }
  }

  selectedMonth(event) {

    this.fileName = `${this.datasourse}_${this.grade}_allDistricts_${this.month}_${this.year}_${this.commonService.dateAndTime}`;
    this.hideMonth = this.period === "year and month" ? false : true;
    this.hideYear = this.period === "year and month" ? false : true;
    this.hideWeek = this.period === "year and month" ? false : true;

    this.week = ""
    if (event) {

      this.weeks = this.period === "year and month" ? this.months.find(a => { return a.months == this.month })?.weeks : "";
    } else {
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

      this.getView()
    }
  }

  selectedGrade() {
    this.subject = "all"
    this.gradeSelected = true
    this.dateSeleted = false
    this.fileName = `${this.reportName}_${this.grade}_allDistricts_${this.month}_${this.year}_${this.commonService.dateAndTime}`;
    if (this.grade !== "all") {
      if (this.hideSubject) {
        this.subjects = this.grades.find(a => { return a.grade == this.grade }).subjects;
        this.subjects = ["all", ...this.subjects.filter((item) => item !== "all")];
      }
    } else {
      this.grade = "all";
    }

    this.levelWiseFilter();
  }

  selectedSubject() {
    if (this.hideAccessBtn) {
      this.levelWiseFilter();

    } else {

      this.getView()
    }
  }

  week
  selectedWeek() {
    this.hideDay = false;

    this.fileName = `${this.reportName}_${this.grade}_allDistricts_${this.month}_${this.year}_${this.commonService.dateAndTime}`;
    this.examDate = ""
    this.date = this.weeks.find(a => { return a.week == this.week }).days;
    this.grade = "all";
    this.examDate = "all";
    this.subject = "all";
    if (this.hideAccessBtn) {
      this.levelWiseFilter();

    } else {

      this.getView()
    }
  }



  clickHome() {
    document.getElementById('spinner').style.display = "block"
    this.infraData = "infrastructure_score";
    this.districtSelected = false;
    this.selectedCluster = false;
    this.blockSelected = false;
    this.hideAllBlockBtn = false;
    this.hideAllCLusterBtn = false;
    this.hideAllSchoolBtn = false;

    this.hideIfAccessLevel = true;

    this.gradeSelected = false
    this.dateSeleted = false
    this.month = ""
    this.week = ""
    this.hideMonth = true
    this.hideWeek = true
    this.hideDay = true
    this.hideYear = true
    this.grade = "all"
    this.examDate = "all"
    this.subject = "all"
    this.getMetaData()
    this.period = "overall"
    if (environment.auth_api === 'cqube' || this.userAccessLevel === "") {
      setTimeout(() => {
        document.getElementById('spinner').style.display = "none"
        this.districtWise();
      }, 1000);

    } else {
      this.getView()
    }

  }


  // google maps
  mouseOverOnmaker(infoWindow, $event: MouseEvent): void {
    infoWindow.open();
  }

  mouseOutOnmaker(infoWindow, $event: MouseEvent) {
    infoWindow.close();
  }
  // to load all the districts for state data on the map

  districtDropDown
  hideMap: boolean = false
  districtWise() {

    // to clear the existing data on the map layer
    globalMap.removeLayer(this.markersList);
    this.layerMarkers.clearLayers();
    this.globalService.latitude = this.lat = this.globalService.mapCenterLatlng.lat;
    this.globalService.longitude = this.lng = this.globalService.mapCenterLatlng.lng;

    this.commonService.errMsg();
    this.level = "District";
    this.googleMapZoom = 7;
    this.fileName = `${this.datasourse}_allDistricts_${this.commonService.dateAndTime}`;

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
    this.districtId = undefined
    // api call to get all the districts data

    if (this.myData) {
      this.myData.unsubscribe();
    }
    let obj = {
      management: this.management,
      category: this.category,
      reportType: this.reportType,
      dataSource: this.datasourse,
      period: this.period

    }

    if (this.grade !== "all") {
      obj['grade'] = this.grade
    }
    if (this.subject !== "all") {
      obj['subject_name'] = this.subject
    }
    if (this.year) {
      obj['year'] = this.year
    }
    if (this.month) {
      obj['month'] = this.month
    }
    if (this.week) {
      obj['week'] = this.week
    }
    if (this.examDate !== "all") {
      obj['exam_date'] = this.examDate
    }


    this.myData = this.service1.dynamicDistData(obj).subscribe(
      (res) => {
        if (res["data"]) {
          this.myDistData = res;
          this.markers = this.data = res["data"];

          this.districtDropDown = res["districtDetails"];
          this.districtDropDown.sort((a, b) =>
            a.district_name > b.district_name
              ? 1
              : b.district_name > a.district_name
                ? -1
                : 0
          );

          this.schoolCount = res["footer"]['schools']?.toString().replace(/(\d)(?=(\d\d)+\d$)/g, "$1,");
          this.studentCount = res["footer"]['students']?.toString().replace(/(\d)(?=(\d\d)+\d$)/g, "$1,");
          // to show only in dropdowns
          this.districtMarkers = this.data;
          let arr = [];
          this.values = [];
          for (let i = 0; i < this.data.length; i++) {

            arr.push(this.data[i][this.metricName])
          }

          arr = arr.sort(function (a, b) {
            return parseFloat(a) - parseFloat(b);
          });
          let uniqueArr = [...new Set(arr)]
          const min = Math.min(...arr);
          const max = Math.max(...arr);

          arr.length >= 10 ? min !== max ? this.getRangeArray(min, max, 10) : this.getRangeArray1(min, max, arr.length) : this.getRangeArray1(min, max, arr.length);

          // options to set for markers in the map
          let options = {
            radius: 6,
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

          this.data.sort((a, b) =>
            `${a[this.infraData]}` > `${b[this.infraData]}`
              ? 1
              : `${b[this.infraData]}` > `${a[this.infraData]}`
                ? -1
                : 0
          );


          this.genericFun(this.districtMarkers, options, this.fileName);

          this.globalService.onResize(this.level);

          // sort the districtname alphabetically
          this.districtMarkers.sort((a, b) =>
            a.district_name > b.district_name
              ? 1
              : b.district_name > a.district_name
                ? -1
                : 0
          );
          this.changeDetection.detectChanges();
        } else {
          this.commonService.loaderAndErr(this.data);

        }
      },
      (err) => {
        this.data = [];
        this.commonService.loaderAndErr(this.data);
        this.level = "District"
        this.globalService.setZoomLevel(this.level)
      }
    );
    // adding the markers to the map layers
    globalMap.addLayer(this.layerMarkers);
  }

  getRangeArray = (min, max, n) => {

    const delta = (max - min) / n;
    const ranges = [];
    if (delta > 1) {
      let range1 = Math.ceil(min);
      for (let i = 0; i < n; i += 1) {
        const range2 = Math.ceil(range1 + delta);
        this.values.push(
          `${Number(range1).toLocaleString("en-IN")}-${Number(
            range2
          ).toLocaleString("en-IN")}`
        );
        ranges.push([range1, range2]);
        range1 = range2;
      }
      return ranges;
    } else {
      this.getRangeArray1(min, max, n)
    }
  }


  getRangeArray1 = (min, max, n) => {
    const delta = (max - min) / n;
    const ranges = [min];
    let range1 = Math.ceil(min);
    for (let i = 0; i < n; i += 1) {
      const range2 = Math.ceil(range1 + delta);
      this.values.push(
        `${Number(
          range2
        ).toLocaleString("en-IN")}`
      );
      ranges.push([range2]);
      range1 = range2 + 1;
    }

    return ranges;
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
      this.reportData = [];

      this.level = "Block";
      this.googleMapZoom = 7;
      this.fileName = `${this.datasourse}_allBlocks_${this.commonService.dateAndTime}`;

      this.valueRange = undefined;
      this.selectedIndex = undefined;
      this.deSelect();

      // these are for showing the hierarchy names based on selection
      this.skul = true;
      this.dist = false;
      this.blok = false;
      this.clust = false;

      // to show and hide the dropdowns
      this.blockHidden = this.blockSelected === true ? false : true;
      this.clusterHidden = true;

      // api call to get the all clusters data
      if (this.myData) {
        this.myData.unsubscribe();
      }

      this.myData = this.service1.dynamicAllBlockData({ management: this.management, category: this.category, reportType: this.reportType, dataSource: this.datasourse }).subscribe(
        (res) => {
          if (this.districtSelected) {
            this.myBlockData = res["data"];
            let marker = this.myBlockData.filter(a => {
              if (a.district_id === this.districtSlectedId) {

                return a
              }

            })
            this.markers = this.data = marker;
            // this.gettingInfraFilters(this.data);
            let options = {
              radius: 4,
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
              var colors = this.commonService.getRelativeColors(
                this.blockMarkers,
                this.infraData
              );
              if (this.blockMarkers.length !== 0) {
                for (let i = 0; i < this.blockMarkers.length; i++) {
                  var color;
                  if (this.selected == "absolute") {
                    color = this.commonService.colorGredient(
                      this.blockMarkers[i],
                      this.infraData
                    );
                  } else {
                    color = this.commonService.relativeColorGredient(
                      this.blockMarkers[i],
                      this.infraData,
                      colors
                    );
                  }

                  // google map circle icon

                  if (this.mapName == "googlemap") {
                    let markerColor = color
                    this.markers[i]['icon'] = this.globalService.initGoogleMapMarker(markerColor, options.radius, 1);
                  }

                  var markerIcon = this.globalService.initMarkers1(
                    this.blockMarkers[i].block_latitude,
                    this.blockMarkers[i].block_longitude,
                    "green",
                    0.01,
                    1,
                    options.level
                  );

                  this.generateToolTip(
                    this.blockMarkers[i],
                    options.level,
                    markerIcon,
                    "latitude",
                    "longitude"
                  );
                  this.getDownloadableData(this.blockMarkers[i], options.level);
                }
                this.globalService.restrictZoom(globalMap);
                globalMap.setMaxBounds([
                  [options.centerLat - 4.5, options.centerLng - 6],
                  [options.centerLat + 3.5, options.centerLng + 6],
                ]);
                this.changeDetection.detectChanges();
                this.globalService.onResize(this.level);

                //schoolCount
                this.schoolCount = res["footer"];
                this.schoolCount = this.schoolCount
                  .toString()
                  .replace(/(\d)(?=(\d\d)+\d$)/g, "$1,");

                this.commonService.loaderAndErr(this.data);
                this.changeDetection.markForCheck();
              }
            }
          } else if (this.blockSelected) {
            this.myBlockData = res["data"];
            let marker = this.myBlockData.filter(a => {
              if (a.block_id === this.blockSelectedId) {

                return a
              }

            })
            this.markers = this.data = marker;
            this.gettingInfraFilters(this.data);
            let options = {
              radius: 4,
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
              var colors = this.commonService.getRelativeColors(
                this.blockMarkers,
                this.infraData
              );
              if (this.blockMarkers.length !== 0) {
                for (let i = 0; i < this.blockMarkers.length; i++) {
                  var color;
                  if (this.selected == "absolute") {
                    color = this.commonService.colorGredient(
                      this.blockMarkers[i],
                      this.infraData
                    );
                  } else {
                    color = this.commonService.relativeColorGredient(
                      this.blockMarkers[i],
                      this.infraData,
                      colors
                    );
                  }

                  // google map circle icon

                  if (this.mapName == "googlemap") {
                    let markerColor = color
                    this.markers[i]['icon'] = this.globalService.initGoogleMapMarker(markerColor, options.radius, 1);
                  }

                  var markerIcon = this.globalService.initMarkers1(
                    this.blockMarkers[i].lat,
                    this.blockMarkers[i].long,
                    color,
                    0.01,
                    1,
                    options.level
                  );

                  this.generateToolTip(
                    this.blockMarkers[i],
                    options.level,
                    markerIcon,
                    "latitude",
                    "longitude"
                  );
                  this.getDownloadableData(this.blockMarkers[i], options.level);
                }
                this.globalService.restrictZoom(globalMap);
                globalMap.setMaxBounds([
                  [options.centerLat - 4.5, options.centerLng - 6],
                  [options.centerLat + 3.5, options.centerLng + 6],
                ]);
                this.changeDetection.detectChanges();
                this.globalService.onResize(this.level);

                //schoolCount
                this.schoolCount = res["footer"];
                this.schoolCount = this.schoolCount
                  .toString()
                  .replace(/(\d)(?=(\d\d)+\d$)/g, "$1,");

                this.commonService.loaderAndErr(this.data);
                this.changeDetection.markForCheck();
              }
            }
          } else if (this.selectedCluster) {
            this.myBlockData = res["data"];
            let marker = this.myBlockData.filter(a => {
              if (a.block_id === this.blockSelectedId) {
                return a
              }

            })
            this.markers = this.data = marker;
            // this.gettingInfraFilters(this.data);
            let options = {
              radius: 4,
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
              var colors = this.commonService.getRelativeColors(
                this.blockMarkers,
                this.infraData
              );
              if (this.blockMarkers.length !== 0) {
                for (let i = 0; i < this.blockMarkers.length; i++) {
                  var color;
                  if (this.selected == "absolute") {
                    color = this.commonService.colorGredient(
                      this.blockMarkers[i],
                      this.infraData
                    );
                  } else {
                    color = this.commonService.relativeColorGredient(
                      this.blockMarkers[i],
                      this.infraData,
                      colors
                    );
                  }

                  // google map circle icon

                  if (this.mapName == "googlemap") {
                    let markerColor = color
                    this.markers[i]['icon'] = this.globalService.initGoogleMapMarker(markerColor, options.radius, 1);
                  }

                  var markerIcon = this.globalService.initMarkers1(
                    this.blockMarkers[i].lat,
                    this.blockMarkers[i].long,
                    color,
                    0.01,
                    1,
                    options.level
                  );

                  this.generateToolTip(
                    this.blockMarkers[i],
                    options.level,
                    markerIcon,
                    "latitude",
                    "longitude"
                  );
                  this.getDownloadableData(this.blockMarkers[i], options.level);
                }
                this.globalService.restrictZoom(globalMap);
                globalMap.setMaxBounds([
                  [options.centerLat - 4.5, options.centerLng - 6],
                  [options.centerLat + 3.5, options.centerLng + 6],
                ]);
                this.changeDetection.detectChanges();
                this.globalService.onResize(this.level);

                //schoolCount
                this.schoolCount = res["footer"];
                this.schoolCount = this.schoolCount
                  .toString()
                  .replace(/(\d)(?=(\d\d)+\d$)/g, "$1,");

                this.commonService.loaderAndErr(this.data);
                this.changeDetection.markForCheck();
              }
            }
          } else {
            this.myBlockData = res["data"];
            this.markers = this.data = res["data"];
            // this.gettingInfraFilters(this.data);
            let options = {
              radius: 4,
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

              if (this.blockMarkers.length !== 0) {
                for (let i = 0; i < this.blockMarkers.length; i++) {
                  var color;


                  // google map circle icon

                  if (this.mapName == "googlemap") {
                    let markerColor = color
                    this.markers[i]['icon'] = this.globalService.initGoogleMapMarker(markerColor, options.radius, 1);
                  }

                  var markerIcon = this.globalService.initMarkers1(
                    this.blockMarkers[i].lat,
                    this.blockMarkers[i].long,
                    "green",
                    0.01,
                    1,
                    options.level
                  );

                  this.generateToolTip(
                    this.blockMarkers[i],
                    options.level,
                    markerIcon,
                    "latitude",
                    "longitude"
                  );
                  this.getDownloadableData(this.blockMarkers[i], options.level);
                }
                this.globalService.restrictZoom(globalMap);
                globalMap.setMaxBounds([
                  [options.centerLat - 4.5, options.centerLng - 6],
                  [options.centerLat + 3.5, options.centerLng + 6],
                ]);
                this.changeDetection.detectChanges();
                this.globalService.onResize(this.level);


                this.commonService.loaderAndErr(this.data);
                this.changeDetection.markForCheck();
              }
            }
          }
        },
        (err) => {
          this.data = [];
          this.commonService.loaderAndErr(this.data);
        }
      );
      globalMap.addLayer(this.layerMarkers);
    } catch (e) {
      this.blockMarkers = [];
      this.commonService.loaderAndErr(this.blockMarkers);
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
      this.reportData = [];
      this.districtId = undefined;
      this.blockId = undefined;
      this.clusterId = undefined;
      this.level = "Cluster";
      this.googleMapZoom = 7;
      this.fileName = `${this.datasourse}_allClusters_${this.commonService.dateAndTime}`;

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
      this.schoolCount = ""
      this.studentCount = ""
      // api call to get the all clusters data
      if (this.myData) {
        this.myData.unsubscribe();
      }
      this.myData = this.service1.dynamicAllClusterData({ management: this.management, category: this.category, reportType: this.reportType, dataSource: this.datasourse }).subscribe(
        (res) => {
          if (this.districtSelected) {
            let cluster = res['data']

            this.schoolCount = res["footer"]['schools']?.toString().replace(/(\d)(?=(\d\d)+\d$)/g, "$1,");
            this.studentCount = res["footer"]['students']?.toString().replace(/(\d)(?=(\d\d)+\d$)/g, "$1,");

            let marker = cluster.filter(a => {
              if (a.district_id === this.districtSlectedId) {
                return a
              }
            })

            this.districtHierarchy = {
              distId: marker[0].district_id,
              districtName: marker[0].district_name,
            };
            this.blockHidden = false;
            this.clusterHidden = true;
            this.skul = false;
            this.dist = true;
            this.districtId = this.districtSlectedId
            this.markers = this.data = marker;
            this.level = "allCluster";

            let options = {
              radius: 5,
              mapZoom: this.globalService.zoomLevel,
              centerLat: marker[0].lat,
              centerLng: marker[0].long,
              level: "allCluster",
            };

            this.dataOptions = options;
            if (this.data.length > 0) {
              let result = this.data;
              this.clusterMarkers = [];
              this.clusterMarkers = result;


              if (this.clusterMarkers.length !== 0) {
                for (let i = 0; i < this.clusterMarkers.length; i++) {
                  var color;

                  // google map circle icon

                  if (this.mapName == "googlemap") {
                    let markerColor = color

                    this.markers[i]['icon'] = this.globalService.initGoogleMapMarker(markerColor, options.radius, 0.5);
                  }

                  var markerIcon = this.globalService.initMarkers1(
                    this.clusterMarkers[i].lat,
                    this.clusterMarkers[i].long,
                    "green",
                    1,
                    1,
                    options.level
                  );

                  this.generateToolTip(
                    this.clusterMarkers[i],
                    options.level,
                    markerIcon,
                    "latitude",
                    "longitude"
                  );
                  this.getDownloadableData(this.clusterMarkers[i], options.level);
                }



                this.globalService.restrictZoom(globalMap);
                globalMap.setMaxBounds([
                  [options.centerLat - 1.5, options.centerLng - 1],
                  [options.centerLat + 1.5, options.centerLng + 1],
                ]);
                this.changeDetection.detectChanges();
                this.globalService.onResize(this.level);
                this.commonService.loaderAndErr(this.data);
              }
            }
          } else if (this.blockSelected) {
            let cluster = res['data']
            this.schoolCount = res["footer"]['schools']?.toString().replace(/(\d)(?=(\d\d)+\d$)/g, "$1,");
            this.studentCount = res["footer"]['students']?.toString().replace(/(\d)(?=(\d\d)+\d$)/g, "$1,");

            let marker = cluster.filter(a => {
              if (a.block_id === this.blockSelectedId) {
                return a
              }

            })
            this.markers = this.data = marker;

            this.gettingInfraFilters(this.data);
            let options = {
              radius: 2,
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
              var colors = this.commonService.getRelativeColors(
                this.clusterMarkers,
                this.infraData
              );
              this.schoolCount = 0;
              if (this.clusterMarkers.length !== 0) {
                for (let i = 0; i < this.clusterMarkers.length; i++) {
                  var color;
                  if (this.selected == "absolute") {
                    color = this.commonService.colorGredient(
                      this.clusterMarkers[i],
                      this.infraData
                    );
                  } else {
                    color = this.commonService.relativeColorGredient(
                      this.clusterMarkers[i],
                      this.infraData,
                      colors
                    );
                  }
                  // google map circle icon

                  if (this.mapName == "googlemap") {
                    let markerColor = color

                    this.markers[i]['icon'] = this.globalService.initGoogleMapMarker(markerColor, options.radius, 0.5);
                  }

                  var markerIcon = this.globalService.initMarkers1(
                    this.clusterMarkers[i].lat,
                    this.clusterMarkers[i].long,
                    color,
                    0.01,
                    0.5,
                    options.level
                  );

                  this.generateToolTip(
                    this.clusterMarkers[i],
                    options.level,
                    markerIcon,
                    "latitude",
                    "longitude"
                  );
                  this.getDownloadableData(this.clusterMarkers[i], options.level);
                }

                //schoolCount
                this.schoolCount = res["footer"]
                  .toString()
                  .replace(/(\d)(?=(\d\d)+\d$)/g, "$1,");

                this.globalService.restrictZoom(globalMap);
                globalMap.setMaxBounds([
                  [options.centerLat - 4.5, options.centerLng - 6],
                  [options.centerLat + 3.5, options.centerLng + 6],
                ]);
                this.changeDetection.detectChanges();
                this.globalService.onResize(this.level);
                this.commonService.loaderAndErr(this.data);
              }
            }
          } else if (this.selectedCluster) {
            let cluster = res['data']

            this.schoolCount = res["footer"]['schools']?.toString().replace(/(\d)(?=(\d\d)+\d$)/g, "$1,");
            this.studentCount = res["footer"]['students']?.toString().replace(/(\d)(?=(\d\d)+\d$)/g, "$1,");

            let marker = cluster.filter(a => {
              if (a.cluster_id === this.selectedCLusterId) {
                return a
              }

            })
            this.markers = this.data = marker;

            this.gettingInfraFilters(this.data);
            let options = {
              radius: 2,
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
              var colors = this.commonService.getRelativeColors(
                this.clusterMarkers,
                this.infraData
              );
              this.schoolCount = 0;
              if (this.clusterMarkers.length !== 0) {
                for (let i = 0; i < this.clusterMarkers.length; i++) {
                  var color;
                  if (this.selected == "absolute") {
                    color = this.commonService.colorGredient(
                      this.clusterMarkers[i],
                      this.infraData
                    );
                  } else {
                    color = this.commonService.relativeColorGredient(
                      this.clusterMarkers[i],
                      this.infraData,
                      colors
                    );
                  }
                  // google map circle icon

                  if (this.mapName == "googlemap") {
                    let markerColor = color

                    this.markers[i]['icon'] = this.globalService.initGoogleMapMarker(markerColor, options.radius, 0.5);
                  }

                  var markerIcon = this.globalService.initMarkers1(
                    this.clusterMarkers[i].lat,
                    this.clusterMarkers[i].long,
                    color,
                    0.01,
                    0.5,
                    options.level
                  );

                  this.generateToolTip(
                    this.clusterMarkers[i],
                    options.level,
                    markerIcon,
                    "latitude",
                    "longitude"
                  );
                  // this.getDownloadableData(this.clusterMarkers[i], options.level);
                }

                //schoolCount
                this.schoolCount = res["footer"]
                  .toString()
                  .replace(/(\d)(?=(\d\d)+\d$)/g, "$1,");

                this.globalService.restrictZoom(globalMap);
                globalMap.setMaxBounds([
                  [options.centerLat - 4.5, options.centerLng - 6],
                  [options.centerLat + 3.5, options.centerLng + 6],
                ]);
                this.changeDetection.detectChanges();
                this.globalService.onResize(this.level);
                this.commonService.loaderAndErr(this.data);
              }
            }
          } else {
            this.markers = this.data = res["data"];

            this.schoolCount = res["footer"]['schools']?.toString().replace(/(\d)(?=(\d\d)+\d$)/g, "$1,");
            this.studentCount = res["footer"]['students']?.toString().replace(/(\d)(?=(\d\d)+\d$)/g, "$1,");


            let options = {
              radius: 2,
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


              if (this.clusterMarkers.length !== 0) {
                for (let i = 0; i < this.clusterMarkers.length; i++) {

                  // google map circle icon

                  if (this.mapName == "googlemap") {
                    let markerColor = color

                    this.markers[i]['icon'] = this.globalService.initGoogleMapMarker(markerColor, options.radius, 0.5);
                  }

                  var markerIcon = this.globalService.initMarkers1(
                    this.clusterMarkers[i].cluster_latitude,
                    this.clusterMarkers[i].cluster_longitude,
                    "green",
                    0.01,
                    0.5,
                    options.level
                  );

                  this.generateToolTip(
                    this.clusterMarkers[i],
                    options.level,
                    markerIcon,
                    "latitude",
                    "longitude"
                  );
                  this.getDownloadableData(this.clusterMarkers[i], options.level);
                }



                this.globalService.restrictZoom(globalMap);
                globalMap.setMaxBounds([
                  [options.centerLat - 4.5, options.centerLng - 6],
                  [options.centerLat + 3.5, options.centerLng + 6],
                ]);
                this.changeDetection.detectChanges();
                this.globalService.onResize(this.level);
                this.commonService.loaderAndErr(this.data);
              }
            }
          }

        },
        (err) => {
          this.clusterMarkers = [];
          this.commonService.loaderAndErr(this.clusterMarkers);
        }
      );
      globalMap.addLayer(this.layerMarkers);

    } catch (e) {
      this.clusterMarkers = [];
      this.commonService.loaderAndErr(this.clusterMarkers);
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
      this.reportData = [];
      this.districtId = undefined;
      this.blockId = undefined;
      this.clusterId = undefined;
      this.level = "commonSchool";
      this.googleMapZoom = 7;
      this.fileName = `${this.datasourse}_allSchools_${this.commonService.dateAndTime}`;

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

      // api call to get the all schools data
      if (this.myData) {
        this.myData.unsubscribe();
      }
      this.myData = this.service1.dynamicAllSchoolData({ management: this.management, category: this.category, reportType: this.reportType, dataSource: this.datasourse }).subscribe(
        (res) => {

          if (res) {

            if (this.districtSelected) {
              this.districtId = this.districtSlectedId;
              let data = res["data"];

              let marker = data.filter(a => {
                if (a.district_id === this.districtSlectedId) {
                  return a
                }
              })

              this.markers = this.data = marker

              this.skul = false;
              this.dist = true;
              this.districtId = this.districtSlectedId;
              this.districtHierarchy = {
                distId: marker[0].district_id,
                districtName: marker[0].district_name,
              };

              // to show and hide the dropdowns
              this.blockHidden = false;
              this.clusterHidden = false;

              let options = {
                radius: 1,
                mapZoom: this.globalService.zoomLevel,
                centerLat: this.lat,
                centerLng: this.lng,
                level: "commonSchool",
              };
              this.dataOptions = options;
              this.schoolMarkers = [];
              if (this.data.length > 0) {
                let result = this.data;
                this.schoolCount = 0;
                this.schoolMarkers = result;
                if (this.schoolMarkers.length !== 0) {
                  for (let i = 0; i < this.schoolMarkers.length; i++) {
                    var color;


                    // google map circle icon

                    if (this.mapName == "googlemap") {
                      let markerColor = color

                      this.markers[i]['icon'] = this.globalService.initGoogleMapMarker(markerColor, options.radius, 0.3);
                    }

                    var markerIcon = this.globalService.initMarkers1(
                      this.schoolMarkers[i].lat,
                      this.schoolMarkers[i].long,
                      "green",
                      0,
                      0.3,
                      options.level
                    );

                    this.generateToolTip(
                      this.schoolMarkers[i],
                      options.level,
                      markerIcon,
                      "latitude",
                      "longitude"
                    );
                    this.getDownloadableData(this.schoolMarkers[i], options.level);
                  }
                  globalMap.doubleClickZoom.enable();
                  globalMap.scrollWheelZoom.enable();
                  globalMap.setMaxBounds([
                    [options.centerLat - 4.5, options.centerLng - 6],
                    [options.centerLat + 3.5, options.centerLng + 6],
                  ]);
                  this.changeDetection.detectChanges();
                  this.globalService.onResize(this.level);

                  //schoolCount
                  this.schoolCount = res["footer"];


                  this.commonService.loaderAndErr(this.data);
                  this.changeDetection.markForCheck();
                }
              } else {
                this.schoolMarkers = [];
                this.commonService.loaderAndErr(this.schoolMarkers);
              }
            } else if (this.blockSelected) {

              let data = res["data"];
              let marker = data.filter(a => {
                if (a.block_id === this.blockSelectedId) {
                  return a
                }
              })
              this.skul = false;
              this.dist = false;
              this.blok = true;
              this.blockId = this.blockSelectedId;
              this.districtId = this.districtSlectedId;
              this.blockHidden = false;
              this.clusterHidden = false;
              this.blockHierarchy = {
                distId: marker[0].district_id,
                districtName: marker[0].district_name,
                blockId: marker[0].block_id,
                blockName: marker[0].block_name,
              };

              this.markers = this.data = marker

              let options = {
                radius: 1,
                mapZoom: this.globalService.zoomLevel,
                centerLat: this.lat,
                centerLng: this.lng,
                level: "commonSchool",
              };
              this.dataOptions = options;
              this.schoolMarkers = [];
              if (this.data.length > 0) {
                let result = this.data;
                this.schoolCount = 0;
                this.schoolMarkers = result;

                if (this.schoolMarkers.length !== 0) {
                  for (let i = 0; i < this.schoolMarkers.length; i++) {
                    var color;


                    // google map circle icon

                    if (this.mapName == "googlemap") {
                      let markerColor = color

                      this.markers[i]['icon'] = this.globalService.initGoogleMapMarker(markerColor, options.radius, 0.3);
                    }

                    var markerIcon = this.globalService.initMarkers1(
                      this.schoolMarkers[i].lat,
                      this.schoolMarkers[i].long,
                      "green",
                      0,
                      0.3,
                      options.level
                    );
                    this.generateToolTip(
                      this.schoolMarkers[i],
                      options.level,
                      markerIcon,
                      "latitude",
                      "longitude"
                    );

                    this.getDownloadableData(this.schoolMarkers[i], options.level);
                  }
                  globalMap.doubleClickZoom.enable();
                  globalMap.scrollWheelZoom.enable();
                  globalMap.setMaxBounds([
                    [options.centerLat - 4.5, options.centerLng - 6],
                    [options.centerLat + 3.5, options.centerLng + 6],
                  ]);
                  this.changeDetection.detectChanges();
                  this.globalService.onResize(this.level);

                  //schoolCount
                  this.schoolCount = res["footer"];

                  this.commonService.loaderAndErr(this.data);
                  this.changeDetection.markForCheck();
                }
              } else {
                this.schoolMarkers = [];
                this.commonService.loaderAndErr(this.schoolMarkers);
              }
            } else if (this.selectedCluster) {
              let data = res["data"];

              let marker = data.filter(a => {

                if (a.cluster_id === this.selectedCLusterId.toString()) {

                  return a
                }
              })


              if (marker.length) {

                this.markers = this.data = marker
                this.gettingInfraFilters(this.data);
                let options = {
                  radius: 4,
                  mapZoom: this.globalService.zoomLevel,
                  centerLat: this.lat,
                  centerLng: this.lng,
                  level: "commonSchool",
                };
                this.dataOptions = options;
                this.schoolMarkers = [];
                if (this.data.length > 0) {
                  let result = this.data;
                  this.schoolCount = 0;
                  this.schoolMarkers = result;

                  if (this.schoolMarkers.length !== 0) {
                    for (let i = 0; i < this.schoolMarkers.length; i++) {
                      var color;

                      // google map circle icon

                      if (this.mapName == "googlemap") {
                        let markerColor = color

                        this.markers[i]['icon'] = this.globalService.initGoogleMapMarker(markerColor, options.radius, 0.3);
                      }

                      var markerIcon = this.globalService.initMarkers1(
                        this.schoolMarkers[i].lat,
                        this.schoolMarkers[i].long,
                        "green",
                        0,
                        0.3,
                        options.level
                      );

                      this.generateToolTip(
                        this.schoolMarkers[i],
                        options.level,
                        markerIcon,
                        "latitude",
                        "longitude"
                      );
                      this.getDownloadableData(this.schoolMarkers[i], options.level);
                    }
                    globalMap.doubleClickZoom.enable();
                    globalMap.scrollWheelZoom.enable();
                    globalMap.setMaxBounds([
                      [options.centerLat - 4.5, options.centerLng - 6],
                      [options.centerLat + 3.5, options.centerLng + 6],
                    ]);
                    this.changeDetection.detectChanges();
                    this.globalService.onResize(this.level);

                    //schoolCount
                    this.schoolCount = res["footer"];
                    this.schoolCount = this.schoolCount
                      .toString()
                      .replace(/(\d)(?=(\d\d)+\d$)/g, "$1,");

                    this.commonService.loaderAndErr(this.data);
                    this.changeDetection.markForCheck();
                  }
                } else {
                  this.schoolMarkers = [];
                  this.commonService.loaderAndErr(this.schoolMarkers);
                }
              }

            } else {
              this.markers = this.data = res["data"];
              // this.gettingInfraFilters(this.data);
              let options = {
                radius: 1,
                mapZoom: this.globalService.zoomLevel,
                centerLat: this.lat,
                centerLng: this.lng,
                level: "commonSchool",
              };
              this.dataOptions = options;
              this.schoolMarkers = [];
              if (this.data.length > 0) {
                let result = this.data;
                this.schoolCount = 0;
                this.schoolMarkers = result;

                if (this.schoolMarkers.length !== 0) {
                  for (let i = 0; i < this.schoolMarkers.length; i++) {
                    var color;


                    // google map circle icon

                    if (this.mapName == "googlemap") {
                      let markerColor = color

                      this.markers[i]['icon'] = this.globalService.initGoogleMapMarker(markerColor, options.radius, 0.3);
                    }

                    var markerIcon = this.globalService.initMarkers1(
                      this.schoolMarkers[i].lat,
                      this.schoolMarkers[i].long,
                      "green",
                      0,
                      0.3,
                      options.level
                    );

                    this.generateToolTip(
                      this.schoolMarkers[i],
                      options.level,
                      markerIcon,
                      "latitude",
                      "longitude"
                    );
                    this.getDownloadableData(this.schoolMarkers[i], options.level);
                  }
                  globalMap.doubleClickZoom.enable();
                  globalMap.scrollWheelZoom.enable();
                  globalMap.setMaxBounds([
                    [options.centerLat - 4.5, options.centerLng - 6],
                    [options.centerLat + 3.5, options.centerLng + 6],
                  ]);
                  this.changeDetection.detectChanges();
                  this.globalService.onResize(this.level);



                  this.commonService.loaderAndErr(this.data);
                  this.changeDetection.markForCheck();
                }
              } else {
                this.schoolMarkers = [];
                this.commonService.loaderAndErr(this.schoolMarkers);
              }
            }

          } else {
            this.schoolMarkers = [];
            this.commonService.loaderAndErr(this.schoolMarkers);
          }
        },
        (err) => {
          this.schoolMarkers = [];
          this.commonService.loaderAndErr(this.schoolMarkers);
        }
      );

      globalMap.addLayer(this.layerMarkers);

    } catch (e) {
      this.schoolMarkers = [];
      this.commonService.loaderAndErr(this.schoolMarkers);
      console.log(e);
    }
  }

  public districtSelected: boolean = false
  public districtSlectedId
  public selectedDistrictName
  public blockDropDown
  // to load all the blocks for selected district for state data on the map
  onDistrictSelect(districtId) {
    this.hideIfAccessLevel = false;
    this.districtSelected = true
    this.blockSelected = false
    this.selectedCluster = false
    this.hideAllBlockBtn = true;
    this.hideAllCLusterBtn = false;
    this.hideAllSchoolBtn = false;
    this.infraFilter = [];
    this.districtSlectedId = districtId
    // to clear the existing data on the map layer
    globalMap.removeLayer(this.markersList);
    this.layerMarkers.clearLayers();
    this.commonService.errMsg();
    this.blockId = null;
    this.reportData = [];
    this.level = "blockPerDistrict";
    this.googleMapZoom = 9;
    this.blockMarkers = [];
    this.blockDropDown = []
    this.districtHierarchy = {}
    this.valueRange = undefined;
    this.selectedIndex = undefined;
    this.deSelect();

    // api call to get the blockwise data for selected district
    if (this.myData) {
      this.myData.unsubscribe();
    }
    let obj = {
      management: this.management,
      category: this.category,
      districtId: districtId,
      reportType: this.reportType,
      dataSource: this.datasourse,
      period: this.period
    }
    if (this.grade !== "all") {
      obj['grade'] = this.grade
    }
    if (this.subject !== "all") {
      obj['subject_name'] = this.subject
    }
    if (this.year) {
      obj['year'] = this.year
    }

    if (this.month) {
      obj['month'] = this.month
    }
    if (this.week) {
      obj['week'] = this.week
    }
    if (this.examDate !== "all") {
      obj['exam_date'] = this.examDate
    }

    this.myData = this.service1.dynamicBlockData(obj).subscribe(
      (res) => {
        if (res["data"].length) {
          this.markers = this.data = res["data"];

          this.blockDropDown = res['blockDetails']
          this.schoolCount = res["footer"]['schools']?.toString().replace(/(\d)(?=(\d\d)+\d$)/g, "$1,");
          this.studentCount = res["footer"]['students']?.toString().replace(/(\d)(?=(\d\d)+\d$)/g, "$1,");
          this.blockMarkers = this.data;

          const key = 'district_id';

          this.districtMarkers = [...new Map(this.data.map(item =>
            [item[key], item])).values()];

          let arr = [];
          this.values = [];
          for (let i = 0; i < this.data.length; i++) {
            arr.push(this.data[i][this.metricName])
          }

          arr = arr.sort(function (a, b) {
            return parseFloat(a) - parseFloat(b);
          })


          const min = Math.min(...arr);
          const max = Math.max(...arr);



          arr.length >= 10 ? this.getRangeArray(min, max, 10) : this.getRangeArray1(min, max, arr.length);
          // set hierarchy values
          this.districtHierarchy = {
            distId: this.data[0]?.district_id,
            districtName: this.data[0]?.district_name,
          };
          this.fileName = `${this.datasourse}_blocks_of_district_${districtId}_${this.commonService.dateAndTime}`;

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
            radius: 5,
            fillOpacity: 1,
            strokeWeight: 0.01,
            mapZoom: this.globalService.zoomLevel + 1,
            centerLat: this.data[0]?.lat,
            centerLng: this.data[0]?.long,
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


          this.genericFun(this.blockMarkers, options, this.fileName);
          this.globalService.onResize(this.level);
          // sort the blockname alphabetically
          this.blockDropDown.sort((a, b) =>
            a.block_name > b.block_name
              ? 1
              : b.block_name > a.block_name
                ? -1
                : 0
          );

          this.blockMarkers.sort((a, b) =>
            a.block_name > b.block_name
              ? 1
              : b.block_name > a.block_name
                ? -1
                : 0
          );
          this.changeDetection.detectChanges();
        } else {
          this.blockMarkers = [];
          this.commonService.loaderAndErr(this.blockMarkers);

        }


      },
      (err) => {
        this.blockMarkers = [];
        this.commonService.loaderAndErr(this.blockMarkers);

      }
    );
    globalMap.addLayer(this.layerMarkers);

  }

  public blockSelected: boolean = false
  public blockSelectedId
  // to load all the clusters for selected block for state data on the map
  onBlockSelect(blockId) {
    this.districtSelected = false
    this.selectedCluster = false
    this.blockSelected = true
    this.hideAllBlockBtn = true;
    this.hideAllCLusterBtn = true;
    this.hideAllSchoolBtn = false;
    this.blockSelectedId = blockId
    this.infraFilter = [];
    // to clear the existing data on the map layer
    globalMap.removeLayer(this.markersList);
    this.layerMarkers.clearLayers();
    this.commonService.errMsg();
    this.clusterId = null;
    this.reportData = [];
    this.level = "clusterPerBlock";
    this.googleMapZoom = 11;
    this.valueRange = undefined;
    this.selectedIndex = undefined;
    this.deSelect();

    // api call to get the clusterwise data for selected district, block
    if (this.myData) {
      this.myData.unsubscribe();
    }
    let obj = {
      management: this.management,
      category: this.category,
      reportType: this.reportType,
      dataSource: this.datasourse,
      period: this.period,
      blockId: blockId,
      districtId: this.districtId
    }
    if (this.grade !== "all") {
      obj['grade'] = this.grade
    }
    if (this.subject !== "all") {
      obj['subject_name'] = this.subject
    }
    if (this.year) {
      obj['year'] = this.year
    }
    if (this.month) {
      obj['month'] = this.month
    }
    if (this.week) {
      obj['week'] = this.week
    }
    if (this.examDate !== "all") {
      obj['exam_date'] = this.examDate
    }
    this.myData = this.service1
      .dynamicClusterData(obj)
      .subscribe(
        (res) => {
          if (res["data"].length) {
            this.markers = this.data = res["data"];
            this.schoolCount = res["footer"]['schools']?.toString().replace(/(\d)(?=(\d\d)+\d$)/g, "$1,");
            this.studentCount = res["footer"]['students']?.toString().replace(/(\d)(?=(\d\d)+\d$)/g, "$1,");
            this.districtMarkers = this.data;
            let distKey = "district_id"
            this.districtMarkers = [...new Map(this.data.map(item =>
              [item[distKey], item])).values()];
            let arr = [];
            this.values = [];
            for (let i = 0; i < this.data.length; i++) {
              arr.push(this.data[i][this.metricName])
            }

            arr = arr.sort(function (a, b) {
              return parseFloat(a) - parseFloat(b);
            });


            const min = Math.min(...arr);
            const max = Math.max(...arr);

            arr.length >= 10 ? this.getRangeArray(min, max, 10) : this.getRangeArray1(min, max, arr.length);
            this.clusterMarkers = this.data;

            var myBlocks = [];
            this.blockMarkers.forEach((element) => {
              if (element.district_id == this.districtId) {
                myBlocks.push(element);
              }
            });
            let key = "block_id"
            this.blockMarkers = myBlocks;
            this.blockMarkers = [...new Map(this.data.map(item =>
              [item[key], item])).values()];
            // set hierarchy values
            this.blockHierarchy = {
              distId: this.data[0]?.district_id,
              districtName: this.data[0]?.district_name,
              blockId: this.data[0]?.block_id,
              blockName: this.data[0]?.block_name,
            };
            this.fileName = `${this.datasourse}_clusters_of_block_${blockId}_${this.commonService.dateAndTime}`;

            // to show and hide the dropdowns
            this.blockHidden = this.selBlock ? true : false;
            this.clusterHidden = false;

            this.districtId = this.data[0]?.district_id;
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
              mapZoom: this.globalService.zoomLevel + 3,
              centerLat: this.data[0]?.lat,
              centerLng: this.data[0]?.long,
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

            //schoolCount
            // this.schoolCount = res["footer"].toString().replace(/(\d)(?=(\d\d)+\d$)/g, "$1,");

            this.genericFun(this.clusterMarkers, options, this.fileName);
            this.globalService.onResize(this.level);
            // sort the clusterName alphabetically
            this.clusterMarkers.sort((a, b) =>
              a.cluster_name > b.cluster_name
                ? 1
                : b.cluster_name > a.cluster_name
                  ? -1
                  : 0
            );
            this.changeDetection.detectChanges();
          } else {
            this.clusterMarkers = [];
            this.commonService.loaderAndErr(this.clusterMarkers);
          }

        },
        (err) => {
          this.clusterMarkers = [];
          this.commonService.loaderAndErr(this.clusterMarkers);
        }
      );
    globalMap.addLayer(this.layerMarkers);

  }

  // to load all the schools for selected cluster for state data on the map
  public selectedCluster: boolean = false;
  public selectedCLusterId
  public hideAllBlockBtn: boolean = false;
  public hideAllCLusterBtn: boolean = false;
  public hideAllSchoolBtn: boolean = false;

  onClusterSelect(clusterId) {
    this.hideAllBlockBtn = true
    this.hideAllCLusterBtn = true;
    this.hideAllSchoolBtn = true;
    this.blockSelected = false
    this.districtSelected = false
    this.selectedCluster = true
    this.selectedCLusterId = clusterId
    this.infraFilter = [];
    // to clear the existing data on the map layer
    globalMap.removeLayer(this.markersList);
    this.layerMarkers.clearLayers();
    this.commonService.errMsg();
    this.level = "schoolPerCluster";
    this.googleMapZoom = 13;
    this.valueRange = undefined;
    this.selectedIndex = undefined;
    this.deSelect();
    // api call to get the schoolwise data for selected district, block, cluster
    if (this.myData) {
      this.myData.unsubscribe();
    }


    this.myData = this.service1.dynamicAllClusterData({ management: this.management, category: this.category, dataSource: this.datasourse }).subscribe(
      (result: any) => {

        let obj = {
          management: this.management,
          category: this.category,
          reportType: this.reportType,
          dataSource: this.datasourse,
          period: this.period,
          blockId: this.blockId,
          districtId: this.districtId,
          clusterId: clusterId

        }
        if (this.grade !== "all") {
          obj['grade'] = this.grade
        }
        if (this.subject !== "all") {
          obj['subject_name'] = this.subject
        }
        if (this.year) {
          obj['year'] = this.year
        }
        if (this.month) {
          obj['month'] = this.month
        }
        if (this.week) {
          obj['week'] = this.week
        }
        if (this.examDate !== "all") {
          obj['exam_date'] = this.examDate
        }
        this.myData = this.service1
          .dynamicSchoolData(
            obj
          )
          .subscribe(
            (res) => {
              if (res["data"].length) {
                this.schoolCount = res["footer"]['schools']?.toString().replace(/(\d)(?=(\d\d)+\d$)/g, "$1,");
                this.studentCount = res["footer"]['students']?.toString().replace(/(\d)(?=(\d\d)+\d$)/g, "$1,");
                if (this.schoolLevel) {
                  let schoolData = res['data']
                  let data = schoolData.filter(data => data.school_id === Number(localStorage.getItem('schoolId')))

                  this.markers = this.data = data
                } else {
                  this.markers = this.data = res["data"];
                }

                this.districtMarkers = this.data;
                let distKey = "district_id"
                this.districtMarkers = [...new Map(this.data.map(item =>
                  [item[distKey], item])).values()];
                let arr = [];
                this.values = [];
                for (let i = 0; i < this.data.length; i++) {
                  arr.push(this.data[i][this.metricName])
                }

                arr = arr.sort(function (a, b) {
                  return parseFloat(a) - parseFloat(b);
                });


                const min = Math.min(...arr);
                const max = Math.max(...arr);

                arr.length >= 10 ? this.getRangeArray(min, max, 10) : this.getRangeArray1(min, max, arr.length);
                this.schoolMarkers = this.data;

                var markers = result["data"];
                var myBlocks = [];
                markers.forEach((element) => {
                  if (
                    element.district_id == this.districtId
                  ) {
                    myBlocks.push(element);
                  }
                });
                this.blockMarkers = myBlocks;
                this.blockMarkers.sort((a, b) =>
                  a.block_name > b.block_name
                    ? 1
                    : b.block_name > a.block_name
                      ? -1
                      : 0
                );

                this.changeDetection.detectChanges();
                var myCluster = [];
                this.clusterMarkers.forEach((element) => {
                  if (element.block_id == this.blockId) {
                    myCluster.push(element);
                  }
                });
                this.clusterMarkers = myCluster;



                this.changeDetection.detectChanges();
                // set hierarchy values
                this.clusterHierarchy = {
                  distId: this.data[0]?.district_id,
                  districtName: this.data[0]?.district_name,
                  blockId: this.data[0]?.block_id,
                  blockName: this.data[0]?.block_name,
                  clusterId: this.data[0]?.cluster_id,
                  clusterName: this.data[0]?.cluster_name,
                };
                this.fileName = `${this.datasourse}_schools_of_cluster_${clusterId}_${this.commonService.dateAndTime}`;

                this.blockHidden = this.selBlock ? true : false;
                this.clusterHidden = this.selCluster ? true : false;

                this.districtHierarchy = {
                  distId: this.data[0]?.district_id,
                };

                this.districtId = this.data[0]?.district_id;
                this.blockId = this.data[0]?.block_id;
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
                  mapZoom: this.globalService.zoomLevel + 5,
                  centerLat: this.data[0].lat,
                  centerLng: this.data[0].long,
                  level: "schoolPerCluster",
                };
                this.dataOptions = options;

                this.globalService.latitude = this.lat = options.centerLat;
                this.globalService.longitude = this.lng = options.centerLng;

                globalMap.doubleClickZoom.enable();
                globalMap.scrollWheelZoom.enable();
                globalMap.setMaxBounds([
                  [options.centerLat - 1.5, options.centerLng - 3],
                  [options.centerLat + 1.5, options.centerLng + 2],
                ]);



                this.genericFun(this.schoolMarkers, options, this.fileName);
                this.globalService.onResize(this.level);
                this.changeDetection.detectChanges();

              } else {

                this.data = []
                this.commonService.loaderAndErr(this.data);
              }

            },
            (err) => {

              this.schoolMarkers = [];
              this.data = []
              this.commonService.loaderAndErr(this.data);
            }
          )
      },
      (err) => {

        this.schoolMarkers = [];

        this.commonService.loaderAndErr(this.schoolMarkers);
      }
    );
    globalMap.addLayer(this.layerMarkers);

  }


  // common function for all the data to show in the map
  genericFun(data, options, fileName) {
    try {
      this.reportData = [];
      this.markers = data;

      var colors = this.commonService.commonRelativeColors(
        this.markers,
        {
          value: this.selectedType,
          report: "reports",
        }
      );

      // attach values to markers
      for (var i = 0; i < this.markers.length; i++) {
        var color;

        if (this.onRangeSelect == "absolute") {
          color = this.commonService.commonColorGredient(
            this.markers[i],
            this.valueRange,
            //colors
          );
        } else {
          color = this.commonService.commonColorGredientForMaps(
            this.markers[i],
            this.selectedType,
            colors
          );
        }

        var markerIcon = this.globalService.initMarkers1(
          this.markers[i].lat,
          this.markers[i].long,
          color,
          options.level == 'School' ? 0 : options.strokeWeight,
          options.level == 'School' ? 0.3 : 1,
          options.level
        );

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
      this.commonService.loaderAndErr(data);
      this.changeDetection.detectChanges();
    } catch (e) {
      data = [];
      this.commonService.loaderAndErr(data);
    }

  }

  //infra filters.....
  gettingInfraFilters(data) {
    this.infraFilter = [];

  }

  public infraData = "infrastructure_score";
  public level = "District";

  oninfraSelect(data) {
    this.infraData = data;
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
  }


  selCluster = false;
  selBlock = false;
  selDist = false;
  levelVal = 0;

  schoolLevel = false
  hideFooter = false
  getView() {
    let id = localStorage.getItem("userLocation");
    let level = localStorage.getItem("userLevel");
    this.clusterId = localStorage.getItem("clusterId");
    this.schoolLevel = level === "School" ? true : false
    if (level === "School") {
      this.hideFooter = true
      this.districtId = localStorage.getItem("districtId");
      this.blockId = localStorage.getItem("blockId");
      this.clusterId = localStorage.getItem('clusterId')

      this.clusterHierarchy = {
        distId: this.districtId,
        blockId: this.blockId,
        clusterId: this.clusterId,
      };
      this.onClusterSelect(this.clusterId)
      this.selCluster = true;
      this.selBlock = true;
      this.selDist = true;
      this.levelVal = 3;
      this.blockHidden = true;
      this.clusterHidden = true;
    } else if (level === "Cluster") {
      this.districtId = localStorage.getItem("districtId");
      this.blockId = localStorage.getItem("blockId");
      this.clusterId = localStorage.getItem('clusterId')

      this.clusterHierarchy = {
        distId: this.districtId,
        blockId: this.blockId,
        clusterId: this.clusterId,
      };
      this.onClusterSelect(this.clusterId)
      this.selCluster = true;
      this.selBlock = true;
      this.selDist = true;
      this.levelVal = 3;
      this.blockHidden = true;
      this.clusterHidden = true;
    } else if (level === "Block") {
      this.districtId = localStorage.getItem("districtId");
      this.blockId = localStorage.getItem("blockId");

      this.blockHierarchy = {
        distId: this.districtId,
        blockId: this.blockId,
      };
      this.onBlockSelect(this.blockId)
      this.selCluster = false;
      this.selBlock = true;
      this.selDist = true;
      this.blockHidden = true
      this.levelVal = 2;
      this.blockId = Number(this.blockId)
      this.districtId = Number(this.districtId)
    } else if (level === "District") {
      this.districtId = localStorage.getItem("districtId");
      this.levelVal = 1;
      this.districtHierarchy = {
        distId: this.districtId,
      };
      this.onDistrictSelect(this.districtId)
      this.selCluster = false;
      this.selBlock = false;
      this.selDist = false;
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

      this.selCluster = true;
      this.selBlock = true;
      this.selDist = true;
      this.levelVal = 2;
    } else if (level === "District") {

      this.selCluster = true;
      this.selBlock = true;
      this.selDist = true;
      this.levelVal = 1;
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

  generateToolTip(marker, level, markerIcon, lat, lng) {

    this.popups(markerIcon, marker, level);
    var infraName = this.infraData;
    let colorText = `style='color:blue !important;'`;
    var details = {};
    var orgObject = {};
    var orgObject1 = {};
    Object.keys(marker).forEach((key) => {
      if (key !== "lat" && key !== "long") {
        details[key] = marker[key];
      }
    });
    Object.keys(details).forEach((key) => {

      if (key === "district_name" || key == "district_id") {
        orgObject[key] = details[key];
      }
    });
    Object.keys(details).forEach((key) => {

      if (key == "block_id" || key == "block_name") {
        orgObject[key] = details[key];
      }
    });
    Object.keys(details).forEach((key) => {

      if (key == "cluster_id" || key == "cluster_name") {
        orgObject[key] = details[key];
      }
    });
    Object.keys(details).forEach((key) => {

      if (key == "school_id" || key == "school_name") {
        orgObject[key] = details[key];
      }
    });
    Object.keys(details).forEach((key) => {
      if (key !== lng && key !== "district_name" && key !== "district_id" && key !== "block_id" && key !== "block_name" && key !== "cluster_id" && key !== "cluster_name") {
        orgObject[key] = details[key];
      }
    });

    var detailSchool = {};
    var yourData1;
    if (level != "School" || level != "schoolPerCluster") {
      Object.keys(orgObject).forEach((key) => {
        if (key !== "total_schools_data_received") {
          detailSchool[key] = details[key];
        }
      });
      yourData1 = this.globalService.getInfoFrom(detailSchool, "", level, "infra-map", infraName, colorText)
        .join(" <br>");
    } else {
      yourData1 = this.globalService.getInfoFrom(orgObject, "", level, "infra-map", infraName, colorText)
        .join(" <br>");
    }


    var toolTip = "<b><u>Details</u></b>" +
      "<br>" +
      yourData1

    var toolTip = "<b><u>Details</u></b>" +
      "<br>" +
      yourData1

    if (this.mapName != 'googlemap') {
      const popup = R.responsivePopup({
        hasTip: false,
        autoPan: true,
        offset: [15, 20],
      }).setContent(
        "<b><u>Details</u></b>" +
        "<br>" +
        yourData1

      );
      markerIcon.addTo(globalMap).bindPopup(popup);

    } else {
      marker["label"] = toolTip
    }

  }



  popups(markerIcon, markers, level) {

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
    this.infraFilter = [];
    var data = event.target.myJsonData;
    if (environment.auth_api === 'cqube' || this.userAccessLevel === '') {

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
    this.infraFilter = [];
    var data = marker;
    if (environment.auth_api === 'cqube' || this.userAccessLevel === '') {
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

  changeingStringCases(str) {
    return str.replace(/\w\S*/g, function (txt) {
      return txt.charAt(0).toUpperCase() + txt.substr(1).toLowerCase();
    });
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
    Object.keys(markers).forEach((key) => {
      if (key !== "lat") {
        details[key] = markers[key];
      }
    });
    Object.keys(details).forEach((key) => {
      if (key !== "long") {
        orgObject[key] = details[key];
      }
    });
    var detailSchool = {};
    if (level == "School" || level == "schoolPerCluster") {
      Object.keys(orgObject).forEach((key) => {
        if (key != "total_schools_data_received") {
          detailSchool[key] = orgObject[key];
        }
      });
    }
    if (level == "District") {
      if (this.infraData !== "infrastructure_score") {
        let obj = {
          district_id: markers.district_id,
          district_name: markers.district_name,
          [this.infraData]: markers.metrics[`${this.infraData}`] + "%",
        };
        this.reportData.push(obj);
      } else {
        let myobj = { ...orgObject, ...markers.metrics };
        this.reportData.push(myobj);
      }
    } else if (level == "Block" || level == "blockPerDistrict") {
      if (this.infraData !== "infrastructure_score") {
        let obj = {
          district_id: markers.district_id,
          district_name: markers.district_name,
          block_id: markers.block_id,
          block_name: markers.block_name,
          [this.infraData]: markers.metrics[`${this.infraData}`] + "%",
        };
        this.reportData.push(obj);
      } else {
        let myobj = { ...orgObject, ...markers.metrics };
        this.reportData.push(myobj);
      }
    } else if (level == "Cluster" || level == "clusterPerBlock") {
      if (this.infraData !== "infrastructure_score") {
        let obj = {
          district_id: markers.district_id,
          district_name: markers.district_name,
          block_id: markers.block_id,
          block_name: markers.block_name,
          cluster_id: markers.cluster_id,
          cluster_name: markers.cluster_name,
          [this.infraData]: markers.metrics[`${this.infraData}`] + "%",
        };
        this.reportData.push(obj);
      } else {
        let myobj = { ...orgObject, ...markers.metrics };
        this.reportData.push(myobj);
      }
    } else if (level == "School" || level == "schoolPerCluster") {
      if (this.infraData !== "infrastructure_score") {
        let obj = {
          district_id: markers.district_id,
          district_name: markers.district_name,
          block_id: markers.block_id,
          block_name: markers.block_name,
          cluster_id: markers.cluster_id,
          cluster_name: markers.cluster_name,
          school_id: markers.school_id,
          school_name: markers.school_name,
          [this.infraData]: markers.metrics[`${this.infraData}`] + "%",
        };
        this.reportData.push(obj);
      } else {
        let myobj = { ...detailSchool, ...markers.metrics };
        this.reportData.push(myobj);
      }
    }
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



  public values = [];

  //Filter data based on attendance percentage value range:::::::::::::::::::
  public valueRange = undefined;
  public prevRange = undefined;
  selectRange(value, i) {
    this.onRangeSelect = "absolute";
    this.valueRange = i;
    this.filterRangeWiseData(value, i);
  }


  filterRangeWiseData(value, index) {

    this.prevRange = value;
    globalMap.removeLayer(this.markersList);
    this.layerMarkers.clearLayers();

    let arr = [];

    for (let i = 0; i < this.data.length; i++) {
      arr.push(this.data[i][this.metricName]);
    }

    arr = arr.sort(function (a, b) {
      return parseFloat(a) - parseFloat(b);
    });
    var markers = [];
    let slabArr = [];

    if (index > -1) {

      const min = Math.min(...arr);
      const max = Math.max(...arr);

      const ranges = [];
      const getRangeArray = (min, max, n) => {
        const delta = (max - min) / n;
        let range1 = Math.ceil(min);
        for (let i = 0; i < n; i += 1) {
          const range2 = Math.ceil(range1 + delta);
          ranges.push([range1, range2]);
          range1 = range2;
        }
        return ranges;
      };

      const rangeArrayIn5Parts = getRangeArray(min, max, 10);

      slabArr = arr.filter(
        (val) => val >= ranges[index][0] && val <= ranges[index][1]
      );
    } else {
      slabArr = arr;
    }


    if (value) {

      this.data.map((a) => {
        if (a.lat) {
          if (
            a[`${this.metricName}`] <= Math.max(...slabArr) &&
            a[`${this.metricName}`] >= Math.min(...slabArr)
          ) {
            markers.push(a);

          }
        }
      });
    } else {
      markers = this.data;
    }


    this.genericFun(markers, this.dataOptions, this.fileName);
    this.commonService.errMsg();

    this.districtMarkers = markers;

    //adjusting marker size and other UI on screen resize:::::::::::
    this.globalService.onResize(this.level);
    this.commonService.loaderAndErr(markers);
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
    this.onRangeSelect = "";
    var elements = document.getElementsByClassName('legends');
    for (var j = 0; j < elements.length; j++) {
      if (this.selectedIndex !== j) {
        elements[j]['style'].border = "1px solid transparent";
        elements[j]['style'].transform = "scale(1.0)";
      }
    }
    if (this.level == 'District') {
      this.districtMarkers = this.data;
    } else if (this.level == 'Block' || this.level == 'blockPerDistrict') {
      this.blockMarkers = this.data;
    } else if (this.level == 'Cluster' || this.level == 'clusterPerBlock') {
      this.clusterMarkers = this.data;
    }
  }

  reset(value) {
    this.valueRange = -1;
    this.selectedIndex = undefined;
    this.deSelect();
    this.filterRangeWiseData(value, -1);
  }
}
