import {
  Component,
  OnInit,
  ChangeDetectionStrategy,
  ChangeDetectorRef,
  ViewEncapsulation,
} from "@angular/core";
import { HttpClient } from "@angular/common/http";
import { SchoolInfraService } from "../../../services/school-infra.service";
import { Router } from "@angular/router";
import * as L from "leaflet";
import * as R from "leaflet-responsive-popup";
import { AppServiceComponent, globalMap } from "../../../app.service";

@Component({
  selector: "app-infra-map-visualisation",
  templateUrl: "./infra-map-visualisation.component.html",
  styleUrls: ["./infra-map-visualisation.component.css"],
  changeDetection: ChangeDetectionStrategy.OnPush,
  encapsulation: ViewEncapsulation.None,
})
export class InfraMapVisualisationComponent implements OnInit {

  public title: string = "";
  public titleName: string = "";
  public colors: any;
  public setColor: any;

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
  state: string;
  // initial center position for the map
  public lat: any;
  public lng: any;

  public dataOptions = {};

  colorGenData: any = [];
  reportName = "infrastructure_access_by_location";
  dateAndTime;

  constructor(
    public http: HttpClient,
    public service: SchoolInfraService,
    public commonService: AppServiceComponent,
    public router: Router,
    private changeDetection: ChangeDetectorRef,
    private readonly _router: Router
  ) {
    this.commonService.callProgressCard.subscribe(value => {
      if (value) {
        this.goToHealthCard();
        this.commonService.setProgressCardValue(false);
      }
    })
  }

  selected = "absolute";

  managementName;
  management;
  category;

  getColor(data) {
    this.selected = data;
    this.levelWiseFilter();
  }

  width = window.innerWidth;
  height = window.innerHeight;
  onResize() {
    this.width = window.innerWidth;
    this.height = window.innerHeight;
  }

  ngOnInit() {
    this.state = this.commonService.state;
    this.commonService.latitude = this.lat = this.commonService.mapCenterLatlng.lat;
    this.commonService.longitude = this.lng = this.commonService.mapCenterLatlng.lng;
    this.changeDetection.detectChanges();
    this.commonService.initMap("infraMap", [[this.lat, this.lng]]);
    document.getElementById("accessProgressCard").style.display = "block";
    document.getElementById("backBtn") ? document.getElementById("backBtn").style.display = "none" : "";
    this.managementName = this.management = JSON.parse(localStorage.getItem('management')).id;
    this.category = JSON.parse(localStorage.getItem('category')).id;
    this.managementName = this.commonService.changeingStringCases(
      this.managementName.replace(/_/g, " ")
    );
    let params = JSON.parse(sessionStorage.getItem("report-level-info"));
    if (params && params.level) {
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
  }

  getDistricts(): void {
    this.service.infraMapDistWise({ management: this.management, category: this.category }).subscribe((res) => {
      this.data = res["data"];
      this.districtMarkers = this.data;
      this.districtMarkers.sort((a, b) =>
        a.details.district_name > b.details.district_name
          ? 1
          : b.details.district_name > a.details.district_name
            ? -1
            : 0
      );
    });
  }

  getBlocks(distId, blockId?: any): void {
    this.service.infraMapBlockWise(distId, { management: this.management, category: this.category }).subscribe((res) => {
      this.markers = this.data = res["data"];
      this.blockMarkers = this.data;
      this.blockMarkers.sort((a, b) =>
        a.details.block_name > b.details.block_name
          ? 1
          : b.details.block_name > a.details.block_name
            ? -1
            : 0
      );
      if (blockId) this.onBlockSelect(blockId);
    });
  }

  getClusters(distId, blockId, clusterId): void {
    this.service.infraMapClusterWise(distId, blockId, { management: this.management, category: this.category }).subscribe((res) => {
      this.data = res["data"];
      this.clusterMarkers = this.data;
      this.clusterMarkers.sort((a, b) =>
        a.details.cluster_name > b.details.cluster_name
          ? 1
          : b.details.cluster_name > a.details.cluster_name
            ? -1
            : 0
      );
      this.onClusterSelect(clusterId);
    });
  }
  clickHome() {
    this.infraData = "infrastructure_score";
    this.districtWise();
  }
  // to load all the districts for state data on the map
  districtWise() {
    try {
      // to clear the existing data on the map layer
      globalMap.removeLayer(this.markersList);
      this.layerMarkers.clearLayers();
      this.commonService.latitude = this.lat = this.commonService.mapCenterLatlng.lat;
      this.commonService.longitude = this.lng = this.commonService.mapCenterLatlng.lng;
      this.districtId = undefined;
      this.commonService.errMsg();
      this.level = "District";
      this.fileName = `${this.reportName}_allDistricts_${this.commonService.dateAndTime}`;

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
      // api call to get all the districts data
      if (this.myDistData != undefined) {
        this.markers = this.data = this.myDistData["data"];
        this.gettingInfraFilters(this.data);
        // to show only in dropdowns
        this.districtMarkers = this.myDistData["data"];
        // options to set for markers in the map
        let options = {
          fillOpacity: 1,
          strokeWeight: 0.01,
          mapZoom: this.commonService.zoomLevel,
          centerLat: this.lat,
          centerLng: this.lng,
          level: "District",
        };
        this.dataOptions = options;
        this.commonService.restrictZoom(globalMap);
        globalMap.setMaxBounds([
          [options.centerLat - 4.5, options.centerLng - 6],
          [options.centerLat + 3.5, options.centerLng + 6],
        ]);
        this.changeDetection.detectChanges();

        this.genericFun(this.markers, options, this.fileName);
        //schoolCount
        this.schoolCount = this.myDistData["footer"];
        this.schoolCount = this.schoolCount
          .toString()
          .replace(/(\d)(?=(\d\d)+\d$)/g, "$1,");
        this.commonService.onResize(this.level);
        // sort the districtname alphabetically
        this.districtMarkers.sort((a, b) =>
          a.details.district_name > b.details.district_name
            ? 1
            : b.details.district_name > a.details.district_name
              ? -1
              : 0
        );
      } else {
        if (this.myData) {
          this.myData.unsubscribe();
        }
        this.myData = this.service.infraMapDistWise({ management: this.management, category: this.category }).subscribe(
          (res) => {
            this.myDistData = res;
            this.markers = this.data = res["data"];
            this.gettingInfraFilters(this.data);

            // to show only in dropdowns
            this.districtMarkers = this.data;

            // options to set for markers in the map
            let options = {
              fillOpacity: 1,
              strokeWeight: 0.01,
              mapZoom: this.commonService.zoomLevel,
              centerLat: this.lat,
              centerLng: this.lng,
              level: "District",
            };
            this.dataOptions = options;
            this.commonService.restrictZoom(globalMap);
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
            this.genericFun(this.markers, options, this.fileName);
            //schoolCount
            this.schoolCount = res["footer"];
            this.schoolCount = this.schoolCount
              .toString()
              .replace(/(\d)(?=(\d\d)+\d$)/g, "$1,");

            this.commonService.onResize(this.level);

            // sort the districtname alphabetically
            this.districtMarkers.sort((a, b) =>
              a.details.district_name > b.details.district_name
                ? 1
                : b.details.district_name > a.details.district_name
                  ? -1
                  : 0
            );
            this.changeDetection.detectChanges();
          },
          (err) => {
            this.data = [];
            this.commonService.loaderAndErr(this.data);
          }
        );
      }

      // adding the markers to the map layers
      globalMap.addLayer(this.layerMarkers);
      //document.getElementById("home").style.display = "none";
    } catch (e) {
      this.data = [];
      this.commonService.loaderAndErr(this.data);
      console.log(e);
    }
  }

  // to load all the blocks for state data on the map
  blockWise() {
    try {
      // to clear the existing data on the map layer
      globalMap.removeLayer(this.markersList);
      this.layerMarkers.clearLayers();
      this.commonService.latitude = this.lat = this.commonService.mapCenterLatlng.lat;
      this.commonService.longitude = this.lng = this.commonService.mapCenterLatlng.lng;
      this.commonService.errMsg();
      this.reportData = [];
      this.districtId = undefined;
      this.blockId = undefined;
      this.level = "Block";
      this.fileName = `${this.reportName}_allBlocks_${this.commonService.dateAndTime}`;

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
      this.myData = this.service.infraMapAllBlockWise({ management: this.management, category: this.category }).subscribe(
        (res) => {
          this.myBlockData = res["data"];
          this.markers = this.data = res["data"];
          this.gettingInfraFilters(this.data);
          let options = {
            mapZoom: this.commonService.zoomLevel,
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
                var markerIcon = this.commonService.initMarkers1(
                  this.blockMarkers[i].details.latitude,
                  this.blockMarkers[i].details.longitude,
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
              this.commonService.restrictZoom(globalMap);
              globalMap.setMaxBounds([
                [options.centerLat - 4.5, options.centerLng - 6],
                [options.centerLat + 3.5, options.centerLng + 6],
              ]);
              this.changeDetection.detectChanges();
              this.commonService.onResize(this.level);

              //schoolCount
              this.schoolCount = res["footer"];
              this.schoolCount = this.schoolCount
                .toString()
                .replace(/(\d)(?=(\d\d)+\d$)/g, "$1,");

              this.commonService.loaderAndErr(this.data);
              this.changeDetection.markForCheck();
            }
          }
        },
        (err) => {
          this.data = [];
          this.commonService.loaderAndErr(this.data);
        }
      );
      globalMap.addLayer(this.layerMarkers);
      //document.getElementById("home").style.display = "block";
    } catch (e) {
      this.data = [];
      this.commonService.loaderAndErr(this.data);
      console.log(e);
    }
  }

  // to load all the clusters for state data on the map
  clusterWise() {
    try {
      // to clear the existing data on the map layer
      globalMap.removeLayer(this.markersList);
      this.layerMarkers.clearLayers();
      this.commonService.latitude = this.lat = this.commonService.mapCenterLatlng.lat;
      this.commonService.longitude = this.lng = this.commonService.mapCenterLatlng.lng;
      this.commonService.errMsg();
      this.reportData = [];
      this.districtId = undefined;
      this.blockId = undefined;
      this.clusterId = undefined;
      this.level = "Cluster";
      this.fileName = `${this.reportName}_allClusters_${this.commonService.dateAndTime}`;

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
      this.myData = this.service.infraMapAllClusterWise({ management: this.management, category: this.category }).subscribe(
        (res) => {
          this.markers = this.data = res["data"];
          this.gettingInfraFilters(this.data);
          let options = {
            mapZoom: this.commonService.zoomLevel,
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
                var markerIcon = this.commonService.initMarkers1(
                  this.clusterMarkers[i].details.latitude,
                  this.clusterMarkers[i].details.longitude,
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
              this.schoolCount = res["footer"];
              this.schoolCount = this.schoolCount
                .toString()
                .replace(/(\d)(?=(\d\d)+\d$)/g, "$1,");
              this.commonService.restrictZoom(globalMap);
              globalMap.setMaxBounds([
                [options.centerLat - 4.5, options.centerLng - 6],
                [options.centerLat + 3.5, options.centerLng + 6],
              ]);
              this.changeDetection.detectChanges();
              this.commonService.onResize(this.level);

              this.commonService.loaderAndErr(this.data);
              this.changeDetection.markForCheck();
            }
          }
        },
        (err) => {
          this.data = [];
          this.commonService.loaderAndErr(this.data);
        }
      );
      globalMap.addLayer(this.layerMarkers);
      //document.getElementById("home").style.display = "block";
    } catch (e) {
      this.data = [];
      this.commonService.loaderAndErr(this.data);
      console.log(e);
    }
  }

  // to load all the schools for state data on the map
  schoolWise() {
    try {
      // to clear the existing data on the map layer
      globalMap.removeLayer(this.markersList);
      this.layerMarkers.clearLayers();
      this.commonService.latitude = this.lat = this.commonService.mapCenterLatlng.lat;
      this.commonService.longitude = this.lng = this.commonService.mapCenterLatlng.lng;
      this.commonService.errMsg();
      this.reportData = [];
      this.districtId = undefined;
      this.blockId = undefined;
      this.clusterId = undefined;
      this.level = "School";
      this.fileName = `${this.reportName}_allSchools_${this.commonService.dateAndTime}`;

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
      this.myData = this.service.infraMapAllSchoolWise({ management: this.management, category: this.category }).subscribe(
        (res) => {
          this.markers = this.data = res["data"];
          this.gettingInfraFilters(this.data);
          let options = {
            mapZoom: this.commonService.zoomLevel,
            centerLat: this.lat,
            centerLng: this.lng,
            level: "School",
          };
          this.dataOptions = options;
          this.schoolMarkers = [];
          if (this.data.length > 0) {
            let result = this.data;
            this.schoolCount = 0;
            this.schoolMarkers = result;
            var colors = this.commonService.getRelativeColors(
              this.schoolMarkers,
              this.infraData
            );
            if (this.schoolMarkers.length !== 0) {
              for (let i = 0; i < this.schoolMarkers.length; i++) {
                var color;
                if (this.selected == "absolute") {
                  color = this.commonService.colorGredient(
                    this.schoolMarkers[i],
                    this.infraData
                  );
                } else {
                  color = this.commonService.relativeColorGredient(
                    this.schoolMarkers[i],
                    this.infraData,
                    colors
                  );
                }
                var markerIcon = this.commonService.initMarkers1(
                  this.schoolMarkers[i].details.latitude,
                  this.schoolMarkers[i].details.longitude,
                  color,
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
              this.commonService.onResize(this.level);

              //schoolCount
              this.schoolCount = res["footer"];
              this.schoolCount = this.schoolCount
                .toString()
                .replace(/(\d)(?=(\d\d)+\d$)/g, "$1,");

              this.commonService.loaderAndErr(this.data);
              this.changeDetection.markForCheck();
            }
          }
        },
        (err) => {
          this.data = [];
          this.commonService.loaderAndErr(this.data);
        }
      );

      globalMap.addLayer(this.layerMarkers);
      //document.getElementById("home").style.display = "block";
    } catch (e) {
      this.data = [];
      this.commonService.loaderAndErr(this.data);
      console.log(e);
    }
  }

  // to load all the blocks for selected district for state data on the map
  onDistrictSelect(districtId) {
    this.infraFilter = [];
    // to clear the existing data on the map layer
    globalMap.removeLayer(this.markersList);
    this.layerMarkers.clearLayers();
    this.commonService.errMsg();
    this.blockId = undefined;
    this.reportData = [];
    this.level = "blockPerDistrict";
    this.blockMarkers = [];

    this.valueRange = undefined;
    this.selectedIndex = undefined;
    this.deSelect();

    // api call to get the blockwise data for selected district
    if (this.myData) {
      this.myData.unsubscribe();
    }
    this.myData = this.service.infraMapBlockWise(districtId, { management: this.management, category: this.category }).subscribe(
      (res) => {
        this.markers = this.data = res["data"];
        this.gettingInfraFilters(this.data);

        this.blockMarkers = this.data;
        // set hierarchy values
        this.districtHierarchy = {
          distId: this.data[0].details.district_id,
          districtName: this.data[0].details.district_name,
        };
        this.fileName = `${this.reportName}_blocks_of_district_${districtId}_${this.commonService.dateAndTime}`;

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
          mapZoom: this.commonService.zoomLevel + 1,
          centerLat: this.data[0].details.latitude,
          centerLng: this.data[0].details.longitude,
          level: "blockPerDistrict",
        };
        this.dataOptions = options;
        this.commonService.latitude = this.lat = options.centerLat;
        this.commonService.longitude = this.lng = options.centerLng;

        this.commonService.restrictZoom(globalMap);
        globalMap.setMaxBounds([
          [options.centerLat - 1.5, options.centerLng - 3],
          [options.centerLat + 1.5, options.centerLng + 2],
        ]);

        this.genericFun(this.markers, options, this.fileName);

        //schoolCount
        this.schoolCount = res["footer"];
        this.schoolCount = this.schoolCount
          .toString()
          .replace(/(\d)(?=(\d\d)+\d$)/g, "$1,");

        this.commonService.onResize(this.level);
        // sort the blockname alphabetically
        this.blockMarkers.sort((a, b) =>
          a.details.block_name > b.details.block_name
            ? 1
            : b.details.block_name > a.details.block_name
              ? -1
              : 0
        );
        this.changeDetection.detectChanges();
      },
      (err) => {
        this.data = [];
        this.commonService.loaderAndErr(this.data);
      }
    );
    globalMap.addLayer(this.layerMarkers);
    //document.getElementById("home").style.display = "block";
  }

  // to load all the clusters for selected block for state data on the map
  onBlockSelect(blockId) {
    this.infraFilter = [];
    // to clear the existing data on the map layer
    globalMap.removeLayer(this.markersList);
    this.layerMarkers.clearLayers();
    this.commonService.errMsg();
    this.clusterId = undefined;
    this.reportData = [];
    this.level = "clusterPerBlock";

    this.valueRange = undefined;
    this.selectedIndex = undefined;
    this.deSelect();

    // api call to get the clusterwise data for selected district, block
    if (this.myData) {
      this.myData.unsubscribe();
    }

    this.myData = this.service
      .infraMapClusterWise(this.districtHierarchy.distId, blockId, { management: this.management, category: this.category })
      .subscribe(
        (res) => {
          this.markers = this.data = res["data"];
          this.gettingInfraFilters(this.data);

          this.clusterMarkers = this.data;
          var myBlocks = [];
          this.blockMarkers.forEach((element) => {
            if (element.details.district_id === this.districtHierarchy.distId) {
              myBlocks.push(element);
            }
          });
          this.blockMarkers = myBlocks;

          // set hierarchy values
          this.blockHierarchy = {
            distId: this.data[0].details.district_id,
            districtName: this.data[0].details.district_name,
            blockId: this.data[0].details.block_id,
            blockName: this.data[0].details.block_name,
          };
          this.fileName = `${this.reportName}_clusters_of_block_${blockId}_${this.commonService.dateAndTime}`;

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
            fillOpacity: 1,
            strokeWeight: 0.01,
            mapZoom: this.commonService.zoomLevel + 3,
            centerLat: this.data[0].details.latitude,
            centerLng: this.data[0].details.longitude,
            level: "clusterPerBlock",
          };
          this.dataOptions = options;
          this.commonService.latitude = this.lat = options.centerLat;
          this.commonService.longitude = this.lng = options.centerLng;

          this.commonService.restrictZoom(globalMap);
          globalMap.setMaxBounds([
            [options.centerLat - 1.5, options.centerLng - 3],
            [options.centerLat + 1.5, options.centerLng + 2],
          ]);

          this.genericFun(this.markers, options, this.fileName);
          //schoolCount
          this.schoolCount = res["footer"];
          this.schoolCount = this.schoolCount
            .toString()
            .replace(/(\d)(?=(\d\d)+\d$)/g, "$1,");

          this.commonService.onResize(this.level);
          // sort the clusterName alphabetically
          this.clusterMarkers.sort((a, b) =>
            a.details.cluster_name > b.details.cluster_name
              ? 1
              : b.details.cluster_name > a.details.cluster_name
                ? -1
                : 0
          );
          this.changeDetection.detectChanges();
        },
        (err) => {
          this.data = [];
          this.commonService.loaderAndErr(this.data);
        }
      );
    globalMap.addLayer(this.layerMarkers);
    //document.getElementById("home").style.display = "block";
  }

  // to load all the schools for selected cluster for state data on the map
  onClusterSelect(clusterId) {
    this.infraFilter = [];
    // to clear the existing data on the map layer
    globalMap.removeLayer(this.markersList);
    this.layerMarkers.clearLayers();
    this.commonService.errMsg();
    this.level = "schoolPerCluster";

    this.valueRange = undefined;
    this.selectedIndex = undefined;
    this.deSelect();
    // api call to get the schoolwise data for selected district, block, cluster
    if (this.myData) {
      this.myData.unsubscribe();
    }
    this.myData = this.service.infraMapAllBlockWise({ management: this.management, category: this.category }).subscribe(
      (result: any) => {
        this.myData = this.service
          .infraMapSchoolWise(
            this.blockHierarchy.distId,
            this.blockHierarchy.blockId,
            clusterId, { management: this.management, category: this.category }
          )
          .subscribe(
            (res) => {
              this.markers = this.data = res["data"];
              this.gettingInfraFilters(this.data);

              this.schoolMarkers = this.data;
              var markers = result["data"];
              var myBlocks = [];
              markers.forEach((element) => {
                if (
                  element.details.district_id === this.blockHierarchy.distId
                ) {
                  myBlocks.push(element);
                }
              });
              this.blockMarkers = myBlocks;
              this.blockMarkers.sort((a, b) =>
                a.details.block_name > b.details.block_name
                  ? 1
                  : b.details.block_name > a.details.block_name
                    ? -1
                    : 0
              );

              var myCluster = [];
              this.clusterMarkers.forEach((element) => {
                if (element.details.block_id === this.blockHierarchy.blockId) {
                  myCluster.push(element);
                }
              });
              this.clusterMarkers = myCluster;

              // set hierarchy values
              this.clusterHierarchy = {
                distId: this.data[0].details.district_id,
                districtName: this.data[0].details.district_name,
                blockId: this.data[0].details.block_id,
                blockName: this.data[0].details.block_name,
                clusterId: this.data[0].details.cluster_id,
                clusterName: this.data[0].details.cluster_name,
              };
              this.fileName = `${this.reportName}_schools_of_cluster_${clusterId}_${this.commonService.dateAndTime}`;

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
                fillOpacity: 1,
                strokeWeight: 0.01,
                mapZoom: this.commonService.zoomLevel + 5,
                centerLat: this.data[0].details.latitude,
                centerLng: this.data[0].details.longitude,
                level: "schoolPerCluster",
              };
              this.dataOptions = options;

              this.commonService.latitude = this.lat = options.centerLat;
              this.commonService.longitude = this.lng = options.centerLng;

              globalMap.doubleClickZoom.enable();
              globalMap.scrollWheelZoom.enable();
              globalMap.setMaxBounds([
                [options.centerLat - 1.5, options.centerLng - 3],
                [options.centerLat + 1.5, options.centerLng + 2],
              ]);
              this.changeDetection.detectChanges();

              this.level = options.level;
              this.genericFun(markers, options, this.fileName);

              //schoolCount
              this.schoolCount = res["footer"];
              this.schoolCount = this.schoolCount
                .toString()
                .replace(/(\d)(?=(\d\d)+\d$)/g, "$1,");
              this.commonService.onResize(this.level);
            },
            (err) => {
              this.data = [];
              this.commonService.loaderAndErr(this.data);
            }
          );
      },
      (err) => {
        this.data = [];
        this.commonService.loaderAndErr(this.data);
      }
    );
    globalMap.addLayer(this.layerMarkers);
    //document.getElementById("home").style.display = "block";
  }

  // common function for all the data to show in the map
  genericFun(data, options, fileName) {
    try {
      this.reportData = [];
      this.schoolCount = 0;
      if (data.length > 0) {
        this.markers = data;
        var colors = this.commonService.getRelativeColors(
          this.markers,
          this.infraData
        );
        // attach values to markers
        for (var i = 0; i < this.markers.length; i++) {
          var color;
          if (this.selected == "absolute") {
            color = this.commonService.colorGredient(
              this.markers[i],
              this.infraData
            );
          } else {
            color = this.commonService.relativeColorGredient(
              this.markers[i],
              this.infraData,
              colors
            );
          }
          var markerIcon = this.commonService.initMarkers1(
            this.markers[i].details.latitude,
            this.markers[i].details.longitude,
            color,
            // options.radius,
            options.strokeWeight,
            1,
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
        this.commonService.loaderAndErr(this.data);
        this.changeDetection.markForCheck();
      }
    } catch (e) {
      this.data = [];
      this.commonService.loaderAndErr(this.data);
    }

  }

  //infra filters.....
  gettingInfraFilters(data) {
    this.infraFilter = [];
    for (var i = 0; i < Object.keys(data[0].metrics).length; i++) {
      let val = this.changeingStringCases(
        Object.keys(this.data[0].metrics)[i].replace(/_/g, " ")
      );
      val = val.replace("Percent", "(%)");
      this.infraFilter.push({
        key: Object.keys(this.data[0].metrics)[i],
        value: val,
      });
    }

    this.infraFilter.unshift({
      key: "infrastructure_score",
      value: "Infrastructure Score",
    });

    var infraKey = this.infraFilter.filter(function (obj) {
      return obj.key == "infrastructure_score";
    });

    this.infraFilter = this.infraFilter.filter(function (obj) {
      return obj.key !== "infrastructure_score";
    });

    this.infraFilter.sort((a, b) =>
      a.value > b.value ? 1 : b.value > a.value ? -1 : 0
    );
    this.infraFilter.splice(0, 0, infraKey[0]);
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

  generateToolTip(markers, level, markerIcon, lat, lng) {
    this.popups(markerIcon, markers, level);
    var infraName = this.infraData;
    let colorText = `style='color:blue !important;'`;
    var details = {};
    var orgObject = {};
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

    var detailSchool = {};
    var yourData1;
    if (level != "School" || level != "schoolPerCluster") {
      Object.keys(orgObject).forEach((key) => {
        if (key !== "total_schools_data_received") {
          detailSchool[key] = details[key];
        }
      });
      yourData1 = this.commonService
        .getInfoFrom(detailSchool, "", level, "infra-map", infraName, colorText)
        .join(" <br>");
    } else {
      yourData1 = this.commonService
        .getInfoFrom(orgObject, "", level, "infra-map", infraName, colorText)
        .join(" <br>");
    }
    const ordered = Object.keys(markers.metrics)
      .sort()
      .reduce((obj, key) => {
        obj[key] = markers.metrics[key];
        return obj;
      }, {});
    var yourData = this.commonService
      .getInfoFrom(ordered, "", level, "infra-map", infraName, colorText)
      .join(" <br>");

    const popup = R.responsivePopup({
      hasTip: false,
      autoPan: false,
      offset: [15, 20],
    }).setContent(
      "<b><u>Details</u></b>" +
      "<br>" +
      yourData1 +
      "<br><br><b><u>School Infrastructure Metrics (% of schools)</u></b>" +
      "<br>" +
      yourData
    );
    markerIcon.addTo(globalMap).bindPopup(popup);
  }

  popups(markerIcon, markers, level) {
    for (var i = 0; i < this.markers.length; i++) {
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
    var data = event.target.myJsonData.details;
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
          district_id: markers.details.district_id,
          district_name: markers.details.district_name,
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
          district_id: markers.details.district_id,
          district_name: markers.details.district_name,
          block_id: markers.details.block_id,
          block_name: markers.details.block_name,
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
          district_id: markers.details.district_id,
          district_name: markers.details.district_name,
          block_id: markers.details.block_id,
          block_name: markers.details.block_name,
          cluster_id: markers.details.cluster_id,
          cluster_name: markers.details.cluster_name,
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
          district_id: markers.details.district_id,
          district_name: markers.details.district_name,
          block_id: markers.details.block_id,
          block_name: markers.details.block_name,
          cluster_id: markers.details.cluster_id,
          cluster_name: markers.details.cluster_name,
          school_id: markers.details.school_id,
          school_name: markers.details.school_name,
          [this.infraData]: markers.metrics[`${this.infraData}`] + "%",
        };
        this.reportData.push(obj);
      } else {
        let myobj = { ...detailSchool, ...markers.metrics };
        this.reportData.push(myobj);
      }
    }
  }

  goToHealthCard(): void {
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

    sessionStorage.setItem("health-card-info", JSON.stringify(data));
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
        if (this.infraData == "infrastructure_score") {
          if (a.details[`${this.infraData}`] > this.valueRange.split("-")[0] - 1 && a.details[`${this.infraData}`] <= this.valueRange.split("-")[1]) {
            markers.push(a);
          }
        } else {
          if (a.metrics[`${this.infraData}`] > this.valueRange.split("-")[0] - 1 && a.metrics[`${this.infraData}`] <= this.valueRange.split("-")[1]) {
            markers.push(a);
          }
        }
      })
    } else {
      markers = this.data;
    }
    this.genericFun(markers, this.dataOptions, this.fileName);

    this.reportData = markers;
    if (markers.length > 0) {
      this.commonService.errMsg();
      if (this.level == 'District') {
        this.districtMarkers = markers;
      } else if (this.level == 'Block' || this.level == 'blockPerDistrict') {
        this.blockMarkers = markers;
      } else if (this.level == 'Cluster' || this.level == 'clusterPerBlock') {
        this.clusterMarkers = markers;
      }
    }
    //adjusting marker size and other UI on screen resize:::::::::::
    this.commonService.onResize(this.level);
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
