import {
  Component,
  OnInit,
  ChangeDetectionStrategy,
  ChangeDetectorRef,
  ViewEncapsulation,
} from "@angular/core";
import { HttpClient } from "@angular/common/http";
import { AppServiceComponent } from "../../../app.service";
import { MapService, globalMap } from '../../../services/map-services/maps.service';
import { UdiseReportService } from "../../../services/udise-report.service";
import { Router } from "@angular/router";
import * as L from "leaflet";
import * as R from "leaflet-responsive-popup";
import { environment } from "src/environments/environment";

@Component({
  selector: "app-udise-report",
  templateUrl: "./udise-report.component.html",
  styleUrls: ["./udise-report.component.css"],
  changeDetection: ChangeDetectionStrategy.OnPush,
  encapsulation: ViewEncapsulation.None,
})
export class UdiseReportComponent implements OnInit {
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

  // to show and hide the dropdowns based on the selection of buttons
  public stateLevel: any = 0; // 0 for buttons and 1 for dropdowns

  // to download the excel report
  public fileName: any;
  public reportData: any = [];

  // variables
  public districtId: any;
  public blockId: any;
  public clusterId: any;

  public myData;
  public indiceFilter: any = [];

  public myDistData: any;
  public myBlockData: any = [];
  public myClusterData: any = [];
  public mySchoolData: any = [];
  state: string;
  // initial center position for the map
  public lat: any;
  public lng: any;

  reportName = "UDISE_report";
  managementName;
  management;
  category;
  mapName;
  googleMapZoom = 7;

  constructor(
    public http: HttpClient,
    public commonService: AppServiceComponent,
    public service: UdiseReportService,
    public router: Router,
    private changeDetection: ChangeDetectorRef,
    private readonly _router: Router,
    public globalService: MapService,
  ) {
    commonService.logoutOnTokenExpire();
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


  colorGenData: any = [];

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
    this.lat = this.globalService.mapCenterLatlng.lat;
    this.lng = this.globalService.mapCenterLatlng.lng;
    this.changeDetection.detectChanges();
    this.globalService.initMap("udisemap", [[this.lat, this.lng]]);
    if (this.mapName == 'googlemap') {
      document.getElementById('leafletmap').style.display = "none";
    }
    document.getElementById("accessProgressCard").style.display = "block";
    document.getElementById("backBtn") ? document.getElementById("backBtn").style.display = "none" : "";
    let params = JSON.parse(sessionStorage.getItem("report-level-info"));
    this.managementName = this.management = JSON.parse(localStorage.getItem('management')).id;
    this.category = JSON.parse(localStorage.getItem('category')).id;
    this.managementName = this.commonService.changeingStringCases(
      this.managementName.replace(/_/g, " ")
    );

    if (params && params.level) {
      this.changeDetection.detectChanges();
      let data = params.data;
      if (params.level === "district") {
        this.districtHierarchy = {
          distId: data.id,
        };

        this.districtId = data.id;
        this.getDistricts();
        this.onDistrictSelect(data.id);
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
        this.getDistricts();
        this.getBlocks(data.districtId, data.id);
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

        this.districtId = data.blockHierarchy;
        this.blockId = data.blockId;
        this.clusterId = data.id;
        this.getDistricts();
        this.getBlocks(data.districtId);
        this.getClusters(data.districtId, data.blockId, data.id);
      }
    } else {
      this.changeDetection.detectChanges();
      this.levelWiseFilter();
    }

    //this.getView1();
    this.hideAccessBtn = (environment.auth_api === 'cqube' || this.userAccessLevel === "" || undefined) ? true : false;
    this.selDist = (environment.auth_api === 'cqube' || this.userAccessLevel === '' || undefined) ? false : true;
    if (environment.auth_api !== 'cqube') {
      if (this.userAccessLevel !== "") {
        this.hideIfAccessLevel = true;
        this.distHidden = true
      }

    }

  }

  getDistricts(): void {
    this.service.udise_dist_wise({ management: this.management, category: this.category }).subscribe((res) => {
      this.myDistData = res;
      this.markers = this.data = res["data"];
      this.districtMarkers = this.data;
    });
  }

  getBlocks(distId, blockId?: any): void {
    this.service.udise_blocks_per_dist(distId, { management: this.management, category: this.category }).subscribe((res) => {
      this.markers = this.data = res["data"];
      this.blockMarkers = this.data;
      this.changeDetection.detectChanges();

      if (blockId) this.onBlockSelect(blockId);
    });
  }

  getClusters(distId, blockId, clusterId?: any): void {
    this.service.udise_cluster_per_block(distId, blockId, { management: this.management, category: this.category }).subscribe((res) => {
      this.markers = this.data = res["data"];
      this.clusterMarkers = this.data;
      this.changeDetection.detectChanges();
      if (clusterId)
        this.onClusterSelect(clusterId);
    });
  }

  // to load and hide the spinner
  loaderAndErr() {
    if (this.data.length !== 0) {
      document.getElementById("spinner").style.display = "none";
    } else {
      document.getElementById("spinner").style.display = "none";
      document.getElementById("errMsg").style.color = "red";
      document.getElementById("errMsg").style.display = "block";
      document.getElementById("errMsg").innerHTML = "No data found";
    }
  }

  errMsg() {
    document.getElementById("errMsg").style.display = "none";
    document.getElementById("spinner").style.display = "block";
    document.getElementById("spinner").style.marginTop = "3%";
  }

  homeClick() {
    this.indiceData = "Infrastructure_Score";
    this.districtSelected = false;
    this.selectedCluster = false;
    this.blockSelected = false;
    this.hideAllBlockBtn = false;
    this.hideAllCLusterBtn = false;
    this.hideAllSchoolBtn =false;
    this.districtWise();
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
      // to clear the existing data on the map layer
      globalMap.removeLayer(this.markersList);
      this.layerMarkers.clearLayers();
      this.globalService.latitude = this.lat = this.globalService.mapCenterLatlng.lat;
      this.globalService.longitude = this.lng = this.globalService.mapCenterLatlng.lng;
      this.districtId = undefined;
      this.errMsg();
      this.indiceFilter = [];
      this.level = "District";
      this.googleMapZoom = 7;
      this.fileName = `${this.reportName}_${this.indiceData}_allDistricts_${this.commonService.dateAndTime}`;

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
      if (this.myData) {
        this.myData.unsubscribe();
      }
      this.myData = this.service.udise_dist_wise({ management: this.management, category: this.category }).subscribe(
        (res) => {
          this.myDistData = res;
          this.markers = this.data = res["data"];
          this.gettingIndiceFilters(this.data);

          // to show only in dropdowns
          this.districtMarkers = this.data;

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
          this.data.sort((a, b) =>
            `${a[this.indiceData]}` > `${b[this.indiceData]}`
              ? 1
              : `${b[this.indiceData]}` > `${a[this.indiceData]}`
                ? -1
                : 0
          );

          //schoolCount
          this.schoolCount = res["footer"].toString().replace(/(\d)(?=(\d\d)+\d$)/g, "$1,");

          this.genericFun(this.data, options, this.fileName);
          this.globalService.onResize(this.level);

          // sort the districtname alphabetically
          this.districtMarkers.sort((a, b) =>
            a.details.District_Name > b.details.District_Name
              ? 1
              : b.details.District_Name > a.details.District_Name
                ? -1
                : 0
          );
          this.changeDetection.detectChanges();
        },
        (err) => {
          this.data = [];
          this.loaderAndErr();
        }
      );

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
      this.errMsg();
      this.reportData = [];
      this.indiceFilter = [];
      this.districtId = undefined;
      this.blockId = undefined;
      this.level = "Block";
      this.googleMapZoom = 7;
      this.fileName = `${this.reportName}_${this.indiceData}_allBlocks_${this.commonService.dateAndTime}`;

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

      // api call to get the all clusters data
      if (this.myData) {
        this.myData.unsubscribe();
      }
      this.myData = this.service.udise_block_wise({ management: this.management, category: this.category }).subscribe(
        (res) => {
          if (this.districtSelected) {

            let blockData = res["data"];
            let marker = blockData.filter(a => {
              if (a.details.district_id === this.districtSlectedId) {

                return a
              }

            })
            this.data = this.myBlockData = marker;
            this.gettingIndiceFilters(this.data);

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

              this.markers = this.blockMarkers = result;
              var colors = this.commonService.getRelativeColors(
                this.blockMarkers,
                this.indiceData
              );
              this.schoolCount = 0;
              if (this.blockMarkers.length !== 0) {
                for (let i = 0; i < this.blockMarkers.length; i++) {
                  if (this.selected == "absolute") {
                    this.setColor = this.commonService.colorGredient(
                      this.blockMarkers[i],
                      this.indiceData
                    );
                  } else {
                    this.setColor = this.commonService.relativeColorGredient(
                      this.blockMarkers[i],
                      this.indiceData,
                      colors
                    );
                  }
                  // google map circle icon
                  if (this.mapName == "googlemap") {
                    let markerColor = this.setColor
                    this.markers[i]['icon'] = this.globalService.initGoogleMapMarker(markerColor, options.radius, 1);
                  }
                  var markerIcon = this.globalService.initMarkers1(
                    this.blockMarkers[i].details.latitude,
                    this.blockMarkers[i].details.longitude,
                    this.setColor,
                    0.01,
                    1,
                    options.level
                  );
                  // data to show on the tooltip for the desired levels
                  this.generateToolTip(
                    this.blockMarkers[i],
                    options.level,
                    markerIcon,
                    "latitude",
                    "longitude"
                  );

                  //download report
                  this.getDownloadableData(this.blockMarkers[i], options.level);
                }

                this.globalService.onResize(this.level);

                //schoolCount
                this.schoolCount = res["footer"].toString().replace(/(\d)(?=(\d\d)+\d$)/g, "$1,");
                this.loaderAndErr();
                this.changeDetection.detectChanges();
              }
            }
          } else if (this.blockSelected) {

            let blockData = res["data"];
            let marker = blockData.filter(a => {
              if (a.details.block_id === this.blockSelectedId) {
                
                return a
              }

            })

            this.data = this.myBlockData = marker;
            this.gettingIndiceFilters(this.data);

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

              this.markers = this.blockMarkers = result;
              var colors = this.commonService.getRelativeColors(
                this.blockMarkers,
                this.indiceData
              );
              this.schoolCount = 0;
              if (this.blockMarkers.length !== 0) {
                for (let i = 0; i < this.blockMarkers.length; i++) {
                  if (this.selected == "absolute") {
                    this.setColor = this.commonService.colorGredient(
                      this.blockMarkers[i],
                      this.indiceData
                    );
                  } else {
                    this.setColor = this.commonService.relativeColorGredient(
                      this.blockMarkers[i],
                      this.indiceData,
                      colors
                    );
                  }
                  // google map circle icon
                  if (this.mapName == "googlemap") {
                    let markerColor = this.setColor
                    this.markers[i]['icon'] = this.globalService.initGoogleMapMarker(markerColor, options.radius, 1);
                  }
                  var markerIcon = this.globalService.initMarkers1(
                    this.blockMarkers[i].details.latitude,
                    this.blockMarkers[i].details.longitude,
                    this.setColor,
                    0.01,
                    1,
                    options.level
                  );
                  // data to show on the tooltip for the desired levels
                  this.generateToolTip(
                    this.blockMarkers[i],
                    options.level,
                    markerIcon,
                    "latitude",
                    "longitude"
                  );

                  //download report
                  this.getDownloadableData(this.blockMarkers[i], options.level);
                }

                this.globalService.onResize(this.level);

                //schoolCount
                this.schoolCount = res["footer"].toString().replace(/(\d)(?=(\d\d)+\d$)/g, "$1,");
                this.loaderAndErr();
                this.changeDetection.detectChanges();
              }
            }
          } else if (this.selectedCluster) {

            let cluster = res["data"];
            let marker = cluster.filter(a => {
              if (a.details.cluster_id === this.selectedCLusterId) {
                return a
              }

            })
            this.data = this.myBlockData = marker;
            this.gettingIndiceFilters(this.data);

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

              this.markers = this.blockMarkers = result;
              var colors = this.commonService.getRelativeColors(
                this.blockMarkers,
                this.indiceData
              );
              this.schoolCount = 0;
              if (this.blockMarkers.length !== 0) {
                for (let i = 0; i < this.blockMarkers.length; i++) {
                  if (this.selected == "absolute") {
                    this.setColor = this.commonService.colorGredient(
                      this.blockMarkers[i],
                      this.indiceData
                    );
                  } else {
                    this.setColor = this.commonService.relativeColorGredient(
                      this.blockMarkers[i],
                      this.indiceData,
                      colors
                    );
                  }
                  // google map circle icon
                  if (this.mapName == "googlemap") {
                    let markerColor = this.setColor
                    this.markers[i]['icon'] = this.globalService.initGoogleMapMarker(markerColor, options.radius, 1);
                  }
                  var markerIcon = this.globalService.initMarkers1(
                    this.blockMarkers[i].details.latitude,
                    this.blockMarkers[i].details.longitude,
                    this.setColor,
                    0.01,
                    1,
                    options.level
                  );
                  // data to show on the tooltip for the desired levels
                  this.generateToolTip(
                    this.blockMarkers[i],
                    options.level,
                    markerIcon,
                    "latitude",
                    "longitude"
                  );

                  //download report
                  this.getDownloadableData(this.blockMarkers[i], options.level);
                }

                this.globalService.onResize(this.level);

                //schoolCount
                this.schoolCount = res["footer"].toString().replace(/(\d)(?=(\d\d)+\d$)/g, "$1,");
                this.loaderAndErr();
                this.changeDetection.detectChanges();
              }
            }
          } else {
            this.data = this.myBlockData = res["data"];
            this.gettingIndiceFilters(this.data);

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

              this.markers = this.blockMarkers = result;
              var colors = this.commonService.getRelativeColors(
                this.blockMarkers,
                this.indiceData
              );
              this.schoolCount = 0;
              if (this.blockMarkers.length !== 0) {
                for (let i = 0; i < this.blockMarkers.length; i++) {
                  if (this.selected == "absolute") {
                    this.setColor = this.commonService.colorGredient(
                      this.blockMarkers[i],
                      this.indiceData
                    );
                  } else {
                    this.setColor = this.commonService.relativeColorGredient(
                      this.blockMarkers[i],
                      this.indiceData,
                      colors
                    );
                  }
                  // google map circle icon
                  if (this.mapName == "googlemap") {
                    let markerColor = this.setColor
                    this.markers[i]['icon'] = this.globalService.initGoogleMapMarker(markerColor, options.radius, 1);
                  }
                  var markerIcon = this.globalService.initMarkers1(
                    this.blockMarkers[i].details.latitude,
                    this.blockMarkers[i].details.longitude,
                    this.setColor,
                    0.01,
                    1,
                    options.level
                  );
                  // data to show on the tooltip for the desired levels
                  this.generateToolTip(
                    this.blockMarkers[i],
                    options.level,
                    markerIcon,
                    "latitude",
                    "longitude"
                  );

                  //download report
                  this.getDownloadableData(this.blockMarkers[i], options.level);
                }

                this.globalService.onResize(this.level);

                //schoolCount
                this.schoolCount = res["footer"].toString().replace(/(\d)(?=(\d\d)+\d$)/g, "$1,");
                this.loaderAndErr();
                this.changeDetection.detectChanges();
              }
            }
          }

        },
        (err) => {
          this.data = [];
          this.loaderAndErr();
        }
      );
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
      this.errMsg();
      this.reportData = [];
      this.indiceFilter = [];
      this.districtId = undefined;
      this.blockId = undefined;
      this.clusterId = undefined;
      this.level = "Cluster";
      this.googleMapZoom = 7;
      this.fileName = `${this.reportName}_${this.indiceData}_allClusters_${this.commonService.dateAndTime}`;

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

      // api call to get the all clusters data
      if (this.myData) {
        this.myData.unsubscribe();
      }
      this.myData = this.service.udise_cluster_wise({ management: this.management, category: this.category }).subscribe(
        (res) => {
          if (this.districtSelected) {
            let blockData = res["data"];
            let marker = this.myBlockData.filter(a => {
              if (a.details.district_id === this.districtSlectedId) {

                return a
              }

            })

            this.markers = this.data = marker;
            this.gettingIndiceFilters(this.data);
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
                this.indiceData
              );
              this.schoolCount = 0;
              if (this.clusterMarkers.length !== 0) {
                for (let i = 0; i < this.clusterMarkers.length; i++) {
                  if (this.selected == "absolute") {
                    this.setColor = this.commonService.colorGredient(
                      this.clusterMarkers[i],
                      this.indiceData
                    );
                  } else {
                    this.setColor = this.commonService.relativeColorGredient(
                      this.clusterMarkers[i],
                      this.indiceData,
                      colors
                    );
                  }
                  // google map circle icon
                  if (this.mapName == "googlemap") {
                    let markerColor = this.setColor

                    this.markers[i]['icon'] = this.globalService.initGoogleMapMarker(markerColor, options.radius, 0.3);
                  }
                  var markerIcon = this.globalService.initMarkers1(
                    this.clusterMarkers[i].details.latitude,
                    this.clusterMarkers[i].details.longitude,
                    this.setColor,
                    0.01,
                    0.5,
                    options.level
                  );


                  // data to show on the tooltip for the desired levels
                  this.generateToolTip(
                    this.clusterMarkers[i],
                    options.level,
                    markerIcon,
                    "latitude",
                    "longitude"
                  );

                  //download report
                  this.getDownloadableData(this.clusterMarkers[i], options.level);
                }

                //schoolCount
                this.schoolCount = res["footer"].toString().replace(/(\d)(?=(\d\d)+\d$)/g, "$1,");

                this.globalService.onResize(this.level);

                this.loaderAndErr();
                this.changeDetection.detectChanges();
              }
            }
          } else if (this.blockSelected) {
            let blockData = res["data"];
            let marker = blockData.filter(a => {
              if (a.details.block_id === this.blockSelectedId) {
              
                return a
              }

            })
            this.markers = this.data = marker;
            this.gettingIndiceFilters(this.data);
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
                this.indiceData
              );
              this.schoolCount = 0;
              if (this.clusterMarkers.length !== 0) {
                for (let i = 0; i < this.clusterMarkers.length; i++) {
                  if (this.selected == "absolute") {
                    this.setColor = this.commonService.colorGredient(
                      this.clusterMarkers[i],
                      this.indiceData
                    );
                  } else {
                    this.setColor = this.commonService.relativeColorGredient(
                      this.clusterMarkers[i],
                      this.indiceData,
                      colors
                    );
                  }
                  // google map circle icon
                  if (this.mapName == "googlemap") {
                    let markerColor = this.setColor

                    this.markers[i]['icon'] = this.globalService.initGoogleMapMarker(markerColor, options.radius, 0.3);
                  }
                  var markerIcon = this.globalService.initMarkers1(
                    this.clusterMarkers[i].details.latitude,
                    this.clusterMarkers[i].details.longitude,
                    this.setColor,
                    0.01,
                    0.5,
                    options.level
                  );


                  // data to show on the tooltip for the desired levels
                  this.generateToolTip(
                    this.clusterMarkers[i],
                    options.level,
                    markerIcon,
                    "latitude",
                    "longitude"
                  );

                  //download report
                  this.getDownloadableData(this.clusterMarkers[i], options.level);
                }

                //schoolCount
                this.schoolCount = res["footer"].toString().replace(/(\d)(?=(\d\d)+\d$)/g, "$1,");

                this.globalService.onResize(this.level);

                this.loaderAndErr();
                this.changeDetection.detectChanges();
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
            this.gettingIndiceFilters(this.data);
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
                this.indiceData
              );
              this.schoolCount = 0;
              if (this.clusterMarkers.length !== 0) {
                for (let i = 0; i < this.clusterMarkers.length; i++) {
                  if (this.selected == "absolute") {
                    this.setColor = this.commonService.colorGredient(
                      this.clusterMarkers[i],
                      this.indiceData
                    );
                  } else {
                    this.setColor = this.commonService.relativeColorGredient(
                      this.clusterMarkers[i],
                      this.indiceData,
                      colors
                    );
                  }
                  // google map circle icon
                  if (this.mapName == "googlemap") {
                    let markerColor = this.setColor

                    this.markers[i]['icon'] = this.globalService.initGoogleMapMarker(markerColor, options.radius, 0.3);
                  }
                  var markerIcon = this.globalService.initMarkers1(
                    this.clusterMarkers[i].details.latitude,
                    this.clusterMarkers[i].details.longitude,
                    this.setColor,
                    0.01,
                    0.5,
                    options.level
                  );


                  // data to show on the tooltip for the desired levels
                  this.generateToolTip(
                    this.clusterMarkers[i],
                    options.level,
                    markerIcon,
                    "latitude",
                    "longitude"
                  );

                  //download report
                  this.getDownloadableData(this.clusterMarkers[i], options.level);
                }

                //schoolCount
                this.schoolCount = res["footer"].toString().replace(/(\d)(?=(\d\d)+\d$)/g, "$1,");

                this.globalService.onResize(this.level);

                this.loaderAndErr();
                this.changeDetection.detectChanges();
              }
            }
          } else {
            this.markers = this.data = res["data"];
            this.gettingIndiceFilters(this.data);
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
                this.indiceData
              );
              this.schoolCount = 0;
              if (this.clusterMarkers.length !== 0) {
                for (let i = 0; i < this.clusterMarkers.length; i++) {
                  if (this.selected == "absolute") {
                    this.setColor = this.commonService.colorGredient(
                      this.clusterMarkers[i],
                      this.indiceData
                    );
                  } else {
                    this.setColor = this.commonService.relativeColorGredient(
                      this.clusterMarkers[i],
                      this.indiceData,
                      colors
                    );
                  }
                  // google map circle icon
                  if (this.mapName == "googlemap") {
                    let markerColor = this.setColor

                    this.markers[i]['icon'] = this.globalService.initGoogleMapMarker(markerColor, options.radius, 0.3);
                  }
                  var markerIcon = this.globalService.initMarkers1(
                    this.clusterMarkers[i].details.latitude,
                    this.clusterMarkers[i].details.longitude,
                    this.setColor,
                    0.01,
                    0.5,
                    options.level
                  );


                  // data to show on the tooltip for the desired levels
                  this.generateToolTip(
                    this.clusterMarkers[i],
                    options.level,
                    markerIcon,
                    "latitude",
                    "longitude"
                  );

                  //download report
                  this.getDownloadableData(this.clusterMarkers[i], options.level);
                }

                //schoolCount
                this.schoolCount = res["footer"].toString().replace(/(\d)(?=(\d\d)+\d$)/g, "$1,");

                this.globalService.onResize(this.level);

                this.loaderAndErr();
                this.changeDetection.detectChanges();
              }
            }
          }


        },
        (err) => {
          this.data = [];
          this.loaderAndErr();
        }
      );
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
      this.errMsg();
      this.reportData = [];
      this.indiceFilter = [];
      this.districtId = undefined;
      this.blockId = undefined;
      this.clusterId = undefined;
      this.level = "School";
      this.googleMapZoom = 7;
      this.fileName = `${this.reportName}_${this.indiceData}_allSchools_${this.commonService.dateAndTime}`;

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
      this.myData = this.service.udise_school_wise({ management: this.management, category: this.category }).subscribe(
        (res) => {
         
          if (this.districtSelected) {
            let blockData = res["data"];
            let marker = blockData.filter(a => {
              if (a.details.district_id === this.districtSlectedId) {

                return a
              }

            })



            this.markers = this.data = marker;
            this.gettingIndiceFilters(this.data);
            let options = {
              radius: 1,
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
              var colors = this.commonService.getRelativeColors(
                this.schoolMarkers,
                this.indiceData
              );
              this.schoolCount = 0;
              if (this.schoolMarkers.length !== 0) {
                for (let i = 0; i < this.schoolMarkers.length; i++) {
                  if (this.selected == "absolute") {
                    this.setColor = this.commonService.colorGredient(
                      this.schoolMarkers[i],
                      this.indiceData
                    );
                  } else {
                    this.setColor = this.commonService.relativeColorGredient(
                      this.schoolMarkers[i],
                      this.indiceData,
                      colors
                    );
                  }
                  // google map circle icon
                  if (this.mapName == "googlemap") {
                    let markerColor = this.setColor

                    this.markers[i]['icon'] = this.globalService.initGoogleMapMarker(markerColor, options.radius, 0.3);
                  }
                  var markerIcon = this.globalService.initMarkers1(
                    this.schoolMarkers[i].details.latitude,
                    this.schoolMarkers[i].details.longitude,
                    this.setColor,
                    0,
                    0.3,
                    options.level
                  );

                  // data to show on the tooltip for the desired levels
                  this.generateToolTip(
                    this.schoolMarkers[i],
                    options.level,
                    markerIcon,
                    "latitude",
                    "longitude"
                  );

                  //download report
                  this.getDownloadableData(this.schoolMarkers[i], options.level);
                }
                globalMap.doubleClickZoom.enable();
                globalMap.scrollWheelZoom.enable();
                this.globalService.onResize(this.level);

                //schoolCount
                this.schoolCount = res["footer"].toString().replace(/(\d)(?=(\d\d)+\d$)/g, "$1,");

                this.loaderAndErr();
                this.changeDetection.detectChanges();
              }
            }
          } else if (this.blockSelected) {
            let blockData = res["data"];
            let marker = blockData.filter(a => {
              if (a.details.block_id === this.blockSelectedId) {
               
                return a
              }

            })



            this.markers = this.data = marker;
            this.gettingIndiceFilters(this.data);
            let options = {
              radius: 1,
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
              var colors = this.commonService.getRelativeColors(
                this.schoolMarkers,
                this.indiceData
              );
              this.schoolCount = 0;
              if (this.schoolMarkers.length !== 0) {
                for (let i = 0; i < this.schoolMarkers.length; i++) {
                  if (this.selected == "absolute") {
                    this.setColor = this.commonService.colorGredient(
                      this.schoolMarkers[i],
                      this.indiceData
                    );
                  } else {
                    this.setColor = this.commonService.relativeColorGredient(
                      this.schoolMarkers[i],
                      this.indiceData,
                      colors
                    );
                  }
                  // google map circle icon
                  if (this.mapName == "googlemap") {
                    let markerColor = this.setColor

                    this.markers[i]['icon'] = this.globalService.initGoogleMapMarker(markerColor, options.radius, 0.3);
                  }
                  var markerIcon = this.globalService.initMarkers1(
                    this.schoolMarkers[i].details.latitude,
                    this.schoolMarkers[i].details.longitude,
                    this.setColor,
                    0,
                    0.3,
                    options.level
                  );

                  // data to show on the tooltip for the desired levels
                  this.generateToolTip(
                    this.schoolMarkers[i],
                    options.level,
                    markerIcon,
                    "latitude",
                    "longitude"
                  );

                  //download report
                  this.getDownloadableData(this.schoolMarkers[i], options.level);
                }
                globalMap.doubleClickZoom.enable();
                globalMap.scrollWheelZoom.enable();
                this.globalService.onResize(this.level);

                //schoolCount
                this.schoolCount = res["footer"].toString().replace(/(\d)(?=(\d\d)+\d$)/g, "$1,");

                this.loaderAndErr();
                this.changeDetection.detectChanges();
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
            this.gettingIndiceFilters(this.data);
            let options = {
              radius: 1,
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
              var colors = this.commonService.getRelativeColors(
                this.schoolMarkers,
                this.indiceData
              );
              this.schoolCount = 0;
              if (this.schoolMarkers.length !== 0) {
                for (let i = 0; i < this.schoolMarkers.length; i++) {
                  if (this.selected == "absolute") {
                    this.setColor = this.commonService.colorGredient(
                      this.schoolMarkers[i],
                      this.indiceData
                    );
                  } else {
                    this.setColor = this.commonService.relativeColorGredient(
                      this.schoolMarkers[i],
                      this.indiceData,
                      colors
                    );
                  }
                  // google map circle icon
                  if (this.mapName == "googlemap") {
                    let markerColor = this.setColor

                    this.markers[i]['icon'] = this.globalService.initGoogleMapMarker(markerColor, options.radius, 0.3);
                  }
                  var markerIcon = this.globalService.initMarkers1(
                    this.schoolMarkers[i].details.latitude,
                    this.schoolMarkers[i].details.longitude,
                    this.setColor,
                    0,
                    0.3,
                    options.level
                  );

                  // data to show on the tooltip for the desired levels
                  this.generateToolTip(
                    this.schoolMarkers[i],
                    options.level,
                    markerIcon,
                    "latitude",
                    "longitude"
                  );

                  //download report
                  this.getDownloadableData(this.schoolMarkers[i], options.level);
                }
                globalMap.doubleClickZoom.enable();
                globalMap.scrollWheelZoom.enable();
                this.globalService.onResize(this.level);

                //schoolCount
                this.schoolCount = res["footer"].toString().replace(/(\d)(?=(\d\d)+\d$)/g, "$1,");

                this.loaderAndErr();
                this.changeDetection.detectChanges();
              }
            }
          } else {
            this.markers = this.data = res["data"];
            this.gettingIndiceFilters(this.data);
            let options = {
              radius: 1,
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
              var colors = this.commonService.getRelativeColors(
                this.schoolMarkers,
                this.indiceData
              );
              this.schoolCount = 0;
              if (this.schoolMarkers.length !== 0) {
                for (let i = 0; i < this.schoolMarkers.length; i++) {
                  if (this.selected == "absolute") {
                    this.setColor = this.commonService.colorGredient(
                      this.schoolMarkers[i],
                      this.indiceData
                    );
                  } else {
                    this.setColor = this.commonService.relativeColorGredient(
                      this.schoolMarkers[i],
                      this.indiceData,
                      colors
                    );
                  }
                  // google map circle icon
                  if (this.mapName == "googlemap") {
                    let markerColor = this.setColor

                    this.markers[i]['icon'] = this.globalService.initGoogleMapMarker(markerColor, options.radius, 0.3);
                  }
                  var markerIcon = this.globalService.initMarkers1(
                    this.schoolMarkers[i].details.latitude,
                    this.schoolMarkers[i].details.longitude,
                    this.setColor,
                    0,
                    0.3,
                    options.level
                  );

                  // data to show on the tooltip for the desired levels
                  this.generateToolTip(
                    this.schoolMarkers[i],
                    options.level,
                    markerIcon,
                    "latitude",
                    "longitude"
                  );

                  //download report
                  this.getDownloadableData(this.schoolMarkers[i], options.level);
                }
                globalMap.doubleClickZoom.enable();
                globalMap.scrollWheelZoom.enable();
                this.globalService.onResize(this.level);

                //schoolCount
                this.schoolCount = res["footer"].toString().replace(/(\d)(?=(\d\d)+\d$)/g, "$1,");

                this.loaderAndErr();
                this.changeDetection.detectChanges();
              }
            }
          }


        },
        (err) => {
          this.data = [];
          this.loaderAndErr();
        }
      );

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
    this.hideAllBlockBtn = true;
    this.hideAllCLusterBtn = false;
    this.hideAllSchoolBtn = false;
    this.districtSlectedId = districtId
    // to clear the existing data on the map layer
    globalMap.removeLayer(this.markersList);
    this.layerMarkers.clearLayers();
    this.errMsg();
    this.blockId = undefined;
    this.reportData = [];
    this.indiceFilter = [];

    this.level = "blockPerDistrict";
    this.googleMapZoom = 9;
    this.fileName = `${this.reportName}_${this.indiceData}_blocks_of_district_${districtId}_${this.commonService.dateAndTime}`;

    this.valueRange = undefined;
    this.selectedIndex = undefined;
    this.deSelect();

    // api call to get the blockwise data for selected district
    if (this.myData) {
      this.myData.unsubscribe();
    }
    this.myData = this.service.udise_blocks_per_dist(districtId, { management: this.management, category: this.category }).subscribe(
      (res) => {
        this.markers = this.data = res["data"];
        this.gettingIndiceFilters(this.data);

        this.blockMarkers = this.data;
        // set hierarchy values
        this.districtHierarchy = {
          distId: this.data[0].details.district_id,
          districtName: this.data[0].details.District_Name,
        };

        this.districtId = districtId;

        // to show and hide the dropdowns
        this.blockHidden = false;
        this.clusterHidden = true;

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
          centerLat: this.data[0].details.latitude,
          centerLng: this.data[0].details.longitude,
          level: "blockPerDistrict",
        };
        this.dataOptions = options;
        this.globalService.latitude = this.lat = options.centerLat;
        this.globalService.longitude = this.lng = options.centerLng;

        //schoolCount
        this.schoolCount = res["footer"].toString().replace(/(\d)(?=(\d\d)+\d$)/g, "$1,");

        this.genericFun(this.data, options, this.fileName);
        this.globalService.onResize(this.level);

        // sort the blockname alphabetically
        this.blockMarkers.sort((a, b) =>
          a.details.Block_Name > b.details.Block_Name
            ? 1
            : b.details.Block_Name > a.details.Block_Name
              ? -1
              : 0
        );
        this.changeDetection.detectChanges();

      },
      (err) => {
        this.data = [];
        this.loaderAndErr();
      }
    );
    globalMap.addLayer(this.layerMarkers);

  }

  // to load all the clusters for selected block for state data on the map
  public blockSelected: boolean = false
  public blockSelectedId

  onBlockSelect(blockId) {
    this.districtSelected = false
    this.selectedCluster = false
    this.blockSelected = true
    this.hideAllBlockBtn = true;
    this.hideAllCLusterBtn = true;
    this.hideAllSchoolBtn = false;
    this.blockSelectedId = blockId
    // to clear the existing data on the map layer
    globalMap.removeLayer(this.markersList);
    this.layerMarkers.clearLayers();
    this.errMsg();
    this.clusterId = undefined;
    this.reportData = [];
    this.indiceFilter = [];

    this.level = "clusterPerBlock";
    this.googleMapZoom = 11;
    this.fileName = `${this.reportName}_${this.indiceData}_clusters_of_block_${blockId}_${this.commonService.dateAndTime}`;

    this.valueRange = undefined;
    this.selectedIndex = undefined;
    this.deSelect();

    // api call to get the clusterwise data for selected district, block
    if (this.myData) {
      this.myData.unsubscribe();
    }
    this.myData = this.service
      .udise_cluster_per_block(this.districtId, blockId, { management: this.management, category: this.category })
      .subscribe(
        (res) => {
          this.markers = this.data = res["data"];
          this.gettingIndiceFilters(this.data);

          this.clusterMarkers = this.data;
          var myBlocks = [];
          this.blockMarkers.forEach((element) => {
            if (element.details.district_id == this.districtId) {
              myBlocks.push(element);
            }
          });
          this.blockMarkers = myBlocks;

          // set hierarchy values
          this.blockHierarchy = {
            distId: this.data[0].details.district_id,
            districtName: this.data[0].details.District_Name,
            blockId: this.data[0].details.block_id,
            blockName: this.data[0].details.Block_Name,
          };

          // to show and hide the dropdowns
          this.blockHidden = false;
          this.clusterHidden = false;

          this.districtId = this.data[0].details.district_id;
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
            centerLat: this.data[0].details.latitude,
            centerLng: this.data[0].details.longitude,
            level: "clusterPerBlock",
          };
          this.dataOptions = options;
          this.globalService.latitude = this.lat = options.centerLat;
          this.globalService.longitude = this.lng = options.centerLng;

          //schoolCount
          this.schoolCount = res["footer"].toString().replace(/(\d)(?=(\d\d)+\d$)/g, "$1,");

          this.genericFun(this.data, options, this.fileName);
          this.globalService.onResize(this.level);

          // sort the clusterName alphabetically
          this.clusterMarkers.sort((a, b) =>
            a.details.Cluster_Name > b.details.Cluster_Name
              ? 1
              : b.details.Cluster_Name > a.details.Cluster_Name
                ? -1
                : 0
          )
          this.changeDetection.detectChanges();
        },
        (err) => {
          this.data = [];
          this.loaderAndErr();
        }
      );
    globalMap.addLayer(this.layerMarkers);

  }

  // to load all the schools for selected cluster for state data on the map
  public selectedCluster: boolean = false;
  public selectedCLusterId
  public hideAllBlockBtn: boolean = false;
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
    this.errMsg();
    this.reportData = [];
    this.indiceFilter = [];
    this.level = "schoolPerCluster";
    this.googleMapZoom = 13;
    this.fileName = `${this.reportName}_${this.indiceData}_schools_of_cluster_${clusterId}_${this.commonService.dateAndTime}`;

    this.valueRange = undefined;
    this.selectedIndex = undefined;
    this.deSelect();

    // api call to get the schoolwise data for selected district, block, cluster
    if (this.myData) {
      this.myData.unsubscribe();
    }
    this.myData = this.service.udise_block_wise({ management: this.management, category: this.category }).subscribe(
      (result: any) => {
        this.myData = this.service
          .udise_school_per_cluster(
            this.districtId,
            this.blockId,
            clusterId, { management: this.management, category: this.category }
          )
          .subscribe(
            (res) => {
              this.markers = this.data = res["data"];
              this.gettingIndiceFilters(this.data);

              this.schoolMarkers = this.data;
              var markers = result["data"];
              var myBlocks = [];
              markers.forEach((element) => {
                if (
                  element.details.district_id == this.districtId
                ) {
                  myBlocks.push(element);
                }
              });
              this.blockMarkers = myBlocks;

              var myCluster = [];
              this.clusterMarkers.forEach((element) => {
                if (element.details.block_id == this.blockId) {
                  myCluster.push(element);
                }
              });
              this.clusterMarkers = myCluster;

              // set hierarchy values
              this.clusterHierarchy = {
                distId: this.data[0].details.district_id,
                districtName: this.data[0].details.District_Name,
                blockId: this.data[0].details.block_id,
                blockName: this.data[0].details.Block_Name,
                clusterId: this.data[0].details.cluster_id,
                clusterName: this.data[0].details.Cluster_Name,
              };

              this.blockHidden = false;
              this.clusterHidden = false;

              this.districtHierarchy = {
                distId: this.data[0].details.district_id,
              };

              this.districtId = this.data[0].details.district_id;
              this.blockId = this.data[0].details.block_id;
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
                centerLat: this.data[0].details.latitude,
                centerLng: this.data[0].details.longitude,
                level: "schoolPerCluster",
              };
              this.dataOptions = options;
              this.globalService.latitude = this.lat = options.centerLat;
              this.globalService.longitude = this.lng = options.centerLng;

              //schoolCount
              this.schoolCount = res["footer"].toString().replace(/(\d)(?=(\d\d)+\d$)/g, "$1,");

              this.genericFun(this.data, options, this.fileName);
              this.globalService.onResize(this.level);
              this.changeDetection.detectChanges();

            },
            (err) => {
              this.data = [];
              this.loaderAndErr();
            }
          );
      },
      (err) => {
        this.data = [];
        this.loaderAndErr();
      }
    );
    globalMap.addLayer(this.layerMarkers);

  }

  // common function for all the data to show in the map
  genericFun(data, options, fileName) {
    try {
      this.reportData = [];
      if (data.length > 0) {
        this.markers = data;
        var colors = this.commonService.getRelativeColors(
          this.markers,
          this.indiceData
        );
        // attach values to markers
        for (var i = 0; i < this.markers.length; i++) {
          if (this.selected == "absolute") {
            this.setColor = this.commonService.colorGredient(
              this.markers[i],
              this.indiceData
            );
          } else {
            this.setColor = this.commonService.relativeColorGredient(
              this.markers[i],
              this.indiceData,
              colors
            );
          }

          // google map circle icon
          if (this.mapName == "googlemap") {
            let markerColor = this.setColor

            this.markers[i]['icon'] = this.globalService.initGoogleMapMarker(markerColor, options.radius, 1);
          }
          var markerIcon: any;
          var markerIcon = this.globalService.initMarkers1(
            this.markers[i].details.latitude,
            this.markers[i].details.longitude,
            this.setColor,
            options.level == 'School' ? 0 : options.strokeWeight,
            options.level == 'School' ? 0.3 : 1,
            options.level
          );

          // data to show on the tooltip for the desired levels
          if (options.level) {
            // data to show on the tooltip for the desired levels
            this.generateToolTip(
              this.markers[i],
              options.level,
              markerIcon,
              "latitude",
              "longitude"
            );

            this.fileName = fileName;
            this.getDownloadableData(this.markers[i], options.level);
          }
        }

        this.loaderAndErr();
        this.changeDetection.markForCheck();
      }

      if (this.level == "school") {
        globalMap.doubleClickZoom.enable();
        globalMap.scrollWheelZoom.enable();
        globalMap.setMaxBounds([
          [options.centerLat - 1.5, options.centerLng - 3],
          [options.centerLat + 1.5, options.centerLng + 2],
        ]);
      } else {
        this.globalService.restrictZoom(globalMap);
        globalMap.setMaxBounds([
          [options.centerLat - 4.5, options.centerLng - 6],
          [options.centerLat + 3.5, options.centerLng + 6],
        ]);
      }
    } catch (e) {
      this.data = [];
      this.loaderAndErr();
    }
  }

  //generate tooltip........
  generateToolTip(markers, level, markerIcon, lat, lng) {
    this.popups(markerIcon, markers, level);
    var indiceName = this.indiceData;

    let colorText = `style='color:blue !important;'`;
    var details = {};
    var orgObject = {};
    var data1 = {};
    var data2 = {};
    var data3 = {};
    Object.keys(markers.details).forEach((key) => {
      if (key !== lat) {
        details[key] = markers.details[key];
      }
    });
    Object.keys(details).forEach((key) => {
      if (key !== lng) {
        orgObject[key] = details[key];
      }
    });

    var schoolData = {};
    var schoolData1 = {};
    var schoolData2 = {};
    var schoolData3 = {};
    var schoolData4 = {};
    var yourData1;
    if (level == "School" || level == "schoolPerCluster") {
      Object.keys(orgObject).forEach((key) => {
        if (key !== "total_schools_data_received") {
          schoolData[key] = details[key];
        }
      });
      Object.keys(schoolData).forEach((key) => {
        if (key !== "district_id") {
          schoolData1[key] = schoolData[key];
        }
      });
      Object.keys(schoolData1).forEach((key) => {
        if (key !== "block_id") {
          schoolData2[key] = schoolData1[key];
        }
      });
      Object.keys(schoolData2).forEach((key) => {
        if (key !== "cluster_id") {
          schoolData3[key] = schoolData2[key];
        }
      });
      Object.keys(schoolData3).forEach((key) => {
        if (key !== "school_id") {
          schoolData4[key] = schoolData3[key];
        }
      });
      yourData1 = this.getInfoFrom(
        schoolData4,
        indiceName,
        colorText,
        level
      ).join(" <br>");
    } else if (level == "District") {
      Object.keys(orgObject).forEach((key) => {
        if (key !== "district_id") {
          data1[key] = orgObject[key];
        }
      });
      yourData1 = this.getInfoFrom(data1, indiceName, colorText, level).join(
        " <br>"
      );
    } else if (level == "Block" || level == "blockPerDistrict") {
      Object.keys(orgObject).forEach((key) => {
        if (key !== "district_id") {
          data1[key] = orgObject[key];
        }
      });
      Object.keys(data1).forEach((key) => {
        if (key !== "block_id") {
          data2[key] = data1[key];
        }
      });
      yourData1 = this.getInfoFrom(data2, indiceName, colorText, level).join(
        " <br>"
      );
    } else if (level == "Cluster" || level == "clusterPerBlock") {
      Object.keys(orgObject).forEach((key) => {
        if (key !== "district_id") {
          data1[key] = orgObject[key];
        }
      });
      Object.keys(data1).forEach((key) => {
        if (key !== "block_id") {
          data2[key] = data1[key];
        }
      });
      Object.keys(data2).forEach((key) => {
        if (key !== "cluster_id") {
          data3[key] = data2[key];
        }
      });
      yourData1 = this.getInfoFrom(data3, indiceName, colorText, level).join(
        " <br>"
      );
    }
    var yourData = this.getInfoFrom(
      markers.indices,
      indiceName,
      colorText,
      level
    ).join(" <br>");
    var yourData2 = this.getInfoFrom(
      markers.rank,
      indiceName,
      colorText,
      level
    ).join(" <br>");

    let toolTip = "<b><u>Details</u></b>" +
      "<br>" +
      yourData1 +
      "<br><br><b><u>Rank</u></b>" +
      "<br>" +
      yourData2 +
      "<br><br><b><u>All indices (%)</u></b>" +
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
        "<br><br><b><u>Rank</u></b>" +
        "<br>" +
        yourData2 +
        "<br><br><b><u>All indices (%)</u></b>" +
        "<br>" +
        yourData
      );
      markerIcon.addTo(globalMap).bindPopup(popup);
    } else {
      markers['label'] = toolTip;
    }
  }
  public indiceData = "Infrastructure_Score";
  public level = "District";
  onIndiceSelect(data) {
    this.indiceData = data;
    try {
      this.levelWiseFilter();
    } catch (e) {
      this.loaderAndErr();
    }
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
  distHidden = false
  levelVal = 0;

  getView() {
    let id = localStorage.getItem("userLocation");
    let level = localStorage.getItem("userLevel");
    let clusterid = localStorage.getItem("clusterId");
    let blockid = localStorage.getItem("blockId");
    let districtid = localStorage.getItem("districtId");
    let schoolid = localStorage.getItem("schoolId");


    if (districtid) {
      this.districtId = Number(districtid);
    }
    if (blockid) {
      this.blockId = Number(blockid);
    }
    if (clusterid) {
      this.clusterId = Number(clusterid);
    }


    if (level === "Cluster") {

      this.onClusterSelect(clusterid)
      this.selCluster = true;
      this.selBlock = true;
      this.selDist = true;
      this.levelVal = 3;
    } else if (level === "Block") {

      this.onBlockSelect(blockid)
      this.selCluster = false;
      this.selBlock = true;
      this.selDist = true;
      this.levelVal = 2;
    } else if (level === "District") {

      this.onDistrictSelect(districtid)
      this.selCluster = false;
      this.selBlock = false;
      this.selDist = true;

    } else if (level === '' || level == undefined) {
      this.distHidden = false
    }
  }

  getView1() {
    let id = localStorage.getItem("userLocation");
    let level = localStorage.getItem("userLevel");
    let clusterid = localStorage.getItem("clusterId");
    let blockid = localStorage.getItem("blockId");
    let districtid = localStorage.getItem("districtId");
    let schoolid = localStorage.getItem("schoolId");


    if (level === "Cluster") {


      this.levelVal = 3;
    } else if (level === "Block") {


      this.levelVal = 2;
    } else if (level === "District") {


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



  //map tooltip automation
  public getInfoFrom(object, indiceName, colorText, level) {
    var popupFood = [];
    var stringLine;
    for (var key in object) {
      if (key == 'School_Management_Type' || key == 'School_Category') {
        object[`${key}`] = this.commonService.changeingStringCases(object[key].replace(/_/g, ' '));
      }
      if (object.hasOwnProperty(key)) {
        stringLine =
          `<span ${indiceName == key ? colorText : ""}>` +
          "<b>" +
          key.replace(/\w\S*/g, function (txt) {
            if (txt.includes("Index")) {
              txt = txt.replace("Index", "");
            }
            txt = txt.replace(/_/g, " ");
            return toTitleCase(txt);
          }) +
          "</b>" +
          ": " +
          object[key] +
          `</span>`;
      }
      popupFood.push(stringLine);
    }
    function toTitleCase(phrase) {
      var key = phrase
        .toLowerCase()
        .split(" ")
        .map((word) => word.charAt(0).toUpperCase() + word.slice(1))
        .join(" ");
      key = key.replace("Nsqf", "NSQF");
      key = key.replace("Ict", "ICT");
      key = key.replace("Crc", "CRC");
      key = key.replace("Cctv", "CCTV");
      key = key.replace("Cwsn", "CWSN");
      key = key.replace("Ff Uuid", "UUID");
      return key;
    }
    return popupFood;
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

    // markerIcon.on("click", null);
    // markerIcon.addEventListener('click', (event) => {
    //   event.preventDefault();
    //   event.stopPropagation();
    //   return false;
    // });
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

  //indice filters.....
  gettingIndiceFilters(data) {
    this.indiceFilter = [];
    for (var i = 0; i < Object.keys(data[0].indices).length; i++) {
      let val = Object.keys(data[0].indices)[i].replace(/_/g, " ");
      if (val.includes("Index")) {
        val = val.replace("Index", "");
      }
      val = val.replace("Percent", "(%)");
      this.indiceFilter.push({
        key: Object.keys(data[0].indices)[i],
        value: val,
      });
    }

    this.indiceFilter.unshift({
      key: "Infrastructure_Score",
      value: "Infrastructure Score",
    });

    var indiceKey = this.indiceFilter.filter(function (obj) {
      return obj.key == "Infrastructure_Score";
    });

    this.indiceFilter = this.indiceFilter.filter(function (obj) {
      return obj.key !== "Infrastructure_Score";
    });

    this.indiceFilter.sort((a, b) =>
      a.value > b.value ? 1 : b.value > a.value ? -1 : 0
    );
    this.indiceFilter.splice(0, 0, indiceKey[0]);
  }

  // getting data to download........
  getDownloadableData(markers, level) {
    var details = {};
    var orgObject = {};
    var detailSchool = {};
    Object.keys(markers.details).forEach((key) => {
      if (key !== "latitude") {
        details[key] = markers.details[key];
      }
    });
    Object.keys(details).forEach((key) => {
      if (key !== "longitude") {
        orgObject[key] = details[key];
      }
    });
    if (level == "School" || level == "schoolPerCluster") {
      Object.keys(orgObject).forEach((key) => {
        if (key !== "total_schools_data_received") {
          detailSchool[key] = details[key];
        }
      });
    }
    if (level == "District") {
      if (this.indiceData !== "Infrastructure_Score") {
        let obj = {
          district_id: markers.details.district_id,
          district_name: markers.details.District_Name,
          [this.indiceData]: markers.indices[`${this.indiceData}`] + "%",
        };
        this.reportData.push(obj);
      } else {
        let myobj = { ...orgObject, ...markers.rank, ...markers.indices };
        this.reportData.push(myobj);
      }
    } else if (level == "Block" || level == "blockPerDistrict") {
      if (this.indiceData !== "Infrastructure_Score") {
        let obj = {
          district_id: markers.details.district_id,
          district_name: markers.details.District_Name,
          block_id: markers.details.block_id,
          block_name: markers.details.Block_Name,
          [this.indiceData]: markers.indices[`${this.indiceData}`] + "%",
        };
        this.reportData.push(obj);
      } else {
        let myobj = { ...orgObject, ...markers.rank, ...markers.indices };
        this.reportData.push(myobj);
      }
    } else if (level == "Cluster" || level == "clusterPerBlock") {
      if (this.indiceData !== "Infrastructure_Score") {
        let obj = {
          district_id: markers.details.district_id,
          district_name: markers.details.District_Name,
          block_id: markers.details.block_id,
          block_name: markers.details.Block_Name,
          cluster_id: markers.details.cluster_id,
          cluster_name: markers.details.Cluster_Name,
          [this.indiceData]: markers.indices[`${this.indiceData}`] + "%",
        };
        this.reportData.push(obj);
      } else {
        let myobj = { ...orgObject, ...markers.rank, ...markers.indices };
        this.reportData.push(myobj);
      }
    } else if (level == "School" || level == "schoolPerCluster") {
      if (this.indiceData !== "Infrastructure_Score") {
        let obj = {
          district_id: markers.details.district_id,
          district_name: markers.details.District_Name,
          block_id: markers.details.block_id,
          block_name: markers.details.Block_Name,
          cluster_id: markers.details.cluster_id,
          cluster_name: markers.details.Cluster_Name,
          school_id: markers.details.school_id,
          school_name: markers.details.School_Name,
          [this.indiceData]: markers.indices[`${this.indiceData}`] + "%",
        };
        this.reportData.push(obj);
      } else {
        let myobj = { ...detailSchool, ...markers.rank, ...markers.indices };
        this.reportData.push(myobj);
      }
    }
  }

  // drilldown/ click functionality on markers
  onClick_Marker(event) {
    this.indiceFilter = [];
    var data = event.target.myJsonData.details;
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
  onClick_AgmMarker(marker) {
    this.indiceFilter = [];
    var data = marker.details;
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

  // to download the csv report
  downloadReport() {
    var position = this.reportName.length;
    this.fileName = [this.fileName.slice(0, position), `_${this.management}`, this.fileName.slice(position)].join('');
    this.commonService.download(this.fileName, this.reportData);
  }

  goToprogressCard(): void {
    let data: any = {};

    if (this.level === "blockPerDistrict") {
      data.level = "district";
      data.value = this.districtHierarchy.distId;
    } else if (this.level === "clusterPerBlock") {
      data.level = "block";
      data.value = this.blockHierarchy.blockId;
    } else if (this.level === "schoolPerCluster") {
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
    globalMap.removeLayer(this.markersList);
    this.layerMarkers.clearLayers();

    //getting relative colors for all markers:::::::::::
    var markers = [];
    if (value) {
      this.data.map(a => {
        if (this.indiceData == "Infrastructure_Score") {
          if (a.details[`${this.indiceData}`] > this.valueRange.split("-")[0] - 1 && a.details[`${this.indiceData}`] <= this.valueRange.split("-")[1]) {
            markers.push(a);
          }
        } else {
          if (a.indices[`${this.indiceData}`] > this.valueRange.split("-")[0] - 1 && a.indices[`${this.indiceData}`] <= this.valueRange.split("-")[1]) {
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
      this.districtMarkers = markers;
    } else if (this.level == 'Block' || this.level == 'blockPerDistrict') {
      this.blockMarkers = markers;
    } else if (this.level == 'Cluster' || this.level == 'clusterPerBlock') {
      this.clusterMarkers = markers;
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
      this.districtMarkers = this.data;
    } else if (this.level == 'Block' || this.level == 'blockPerDistrict') {
      this.blockMarkers = this.data;
    } else if (this.level == 'Cluster' || this.level == 'clusterPerBlock') {
      this.clusterMarkers = this.data;
    }
  }

  reset(value) {
    this.valueRange = value;
    this.selectedIndex = undefined;
    this.deSelect();
    this.filterRangeWiseData(value);
  }
}
