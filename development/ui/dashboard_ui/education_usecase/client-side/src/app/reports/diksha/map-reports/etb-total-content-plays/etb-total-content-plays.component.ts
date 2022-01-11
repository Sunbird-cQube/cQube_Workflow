import {
  Component,
  OnInit,
  ChangeDetectionStrategy,
  ChangeDetectorRef,
  ViewEncapsulation,
} from "@angular/core";
import { DikshaMapReportsService } from "src/app/services/diksha-map-reports.service";
import {
  MapService,
  globalMap,
} from "src/app/services/map-services/maps.service";
import * as L from "leaflet";
import * as R from "leaflet-responsive-popup";
import { Router } from "@angular/router";
import { HttpClient } from "@angular/common/http";
import { AppServiceComponent } from "src/app/app.service";

@Component({
  selector: "app-etb-total-content-plays",
  templateUrl: "./etb-total-content-plays.component.html",
  styleUrls: ["./etb-total-content-plays.component.css"],
})
export class EtbTotalContentPlaysComponent implements OnInit {
  state: string;
  // initial center position for the map
  public lat: any;
  public lng: any;

  // leaflet layer dependencies
  public layerMarkers = new L.layerGroup();
  public markersList = new L.FeatureGroup();

  // variables
  public districtId: any = "";

  public myDistData: any;

  public dataOptions = {};

  public fileName: any;

  public myData;

  public reportData;
  public selectedType = "total_time_spent";

  public selected = "absolute";
  public onRangeSelect;
  public legandName;
  public otherStateContentPlays;
  public otherStateTotalTime;
  public otherStateAvgTime;

  reportName = `ETB_${this.selectedType}`;
  reportName1 = "gpsOfLearningEtb"


  mapName;
  constructor(
    public http: HttpClient,
    public globalService: MapService,
    public service: DikshaMapReportsService,
    public commonService: AppServiceComponent,
    public router: Router,
    private changeDetection: ChangeDetectorRef
  ) {}

  geoJson = this.globalService.geoJson;

  width = window.innerWidth;
  height = window.innerHeight;
  onResize() {
    this.width = window.innerWidth;
    this.height = window.innerHeight;
  }

  ngOnInit(): void {
    this.mapName = this.commonService.mapName;
    this.state = this.commonService.state;
    this.globalService.latitude = this.lat =
      this.globalService.mapCenterLatlng.lat;
    this.globalService.longitude = this.lng =
      this.globalService.mapCenterLatlng.lng;
    this.changeDetection.detectChanges();
    this.globalService.initMap("etbMap", [[this.lat, this.lng]]);
    if (this.mapName == "googlemap") {
      document.getElementById("leafletmap").style.display = "none";
    }

    document.getElementById("accessProgressCard").style.display = "none";
    document.getElementById("backBtn")
      ? (document.getElementById("backBtn").style.display = "none")
      : "";
    this.getDistData();
  }

  data;
  districtMarkers;
  markers;
  totalContentPlays;
  othersStatePercentage;
  stateAvgTimeSpend;
  stateTotalContentPlay;

  level;
  googleMapZoom;
  selectionType = [];
  infraData;

  clickHome() {
    this.onRangeSelect = "";
    this.selectedType = "total_time_spent";
    // this.infraData = "infrastructure_score";
    this.getDistData();
  }
  // to load all the districts for state data on the map
  getDistData() {
    this.legandName = this.commonService.changeingStringCases(
      this.selectedType.replace(/_/g, " ")
    );
    try {
      // to clear the existing data on the map layer
      globalMap.removeLayer(this.markersList);
      this.layerMarkers.clearLayers();
      this.globalService.latitude = this.lat =
        this.globalService.mapCenterLatlng.lat;
      this.globalService.longitude = this.lng =
        this.globalService.mapCenterLatlng.lng;
      this.districtId = undefined;
      this.commonService.errMsg();
      this.level = "District";
      this.googleMapZoom = 7;
      this.fileName = `${this.reportName}`;
      this.selectionType = [];
     
      this.valueRange = undefined;
      this.selectedIndex = undefined;
      this.deSelect();

      this.deSelect();

      if (this.myDistData && this.myDistData["data"].length) {
        this.data = this.myDistData;
        let keys = Object.keys(this.data.data[0]);

        let obj = {};
        for (let i = 0; i < keys.length; i++) {
          if (i == 0 || i == 1 || i == 6) {
            obj = {
              id: keys[i],
              name: this.commonService.changeingStringCases(keys[i]),
            };
            this.selectionType.push(obj);
          }
        }

        let arr = [];
        this.values = [];

        for (let i = 0; i < this.data.data.length; i++) {
          arr.push(this.data.data[i][`${this.selectedType}`]);
        }
        arr = arr.sort(function (a, b) {
          return parseFloat(a) - parseFloat(b);
        });
       

        const min = Math.min(...arr);
        const max = Math.max(...arr);

        const getRangeArray = (min, max, n) => {
          const delta = (max - min) / n;

          const ranges = [];
          let range1 = min;
          for (let i = 0; i < n; i += 1) {
            const range2 = range1 + delta;
            this.values.push(
              `${Number(range1).toLocaleString("en-IN")}-${Number(
                range2
              ).toLocaleString("en-IN")}`
            );
            ranges.push([range1, range2]);
            range1 = range2;
          }

          return ranges;
        };

        const rangeArrayIn3Parts = getRangeArray(min, max, 5);

        // to show only in dropdowns
        this.districtMarkers = this.data.data;
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

        this.genericFun(this.districtMarkers, options, this.fileName);

        this.globalService.onResize(this.level);

        this.changeDetection.detectChanges();
        this.commonService.loaderAndErr(this.data);
      } else {
        if (this.myData) {
          this.myData.unsubscribe();
        }
        this.myData = this.service.etbDistWise().subscribe(
          (res) => {
            this.myDistData = this.data = res["data"];

            let arr = [];
            this.values = [];

            for (let i = 0; i < this.data.data.length; i++) {
              arr.push(this.data.data[i][`${this.selectedType}`]);
            }

            arr = arr.sort(function (a, b) {
              return parseFloat(a) - parseFloat(b);
            });
           

            const min = Math.min(...arr);
            const max = Math.max(...arr);

            const getRangeArray = (min, max, n) => {
              const delta = (max - min) / n;
              const ranges = [];
              let range1 = min;
              for (let i = 0; i < n; i += 1) {
                const range2 = range1 + delta;
                this.values.push(
                  `${Number(range1).toLocaleString("en-IN")}-${Number(
                    range2
                  ).toLocaleString("en-IN")}`
                );
                ranges.push([range1, range2]);
                range1 = range2;
              }

              return ranges;
            };

            const rangeArrayIn3Parts = getRangeArray(min, max, 5);

            let keys = Object.keys(this.data.data[0]);

            let obj = {};
            for (let i = 0; i < keys.length; i++) {
              if (i == 0 || i == 1 || i == 6) {
                obj = {
                  id: keys[i],
                  name: this.commonService.changeingStringCases(keys[i]),
                };
                this.selectionType.push(obj);
              }
            }
            // to show only in dropdowns
            this.districtMarkers = this.data.data;
            this.totalContentPlays =
              this.data.footer.total_content_plays.toLocaleString("en-IN");
            this.othersStatePercentage =
              "(" + this.data.footer.others_percentage + "%" + ")";
            this.stateAvgTimeSpend =
              this.data.footer.average_time_state.toLocaleString("en-IN") +
              " " +
              "Minutes";
            this.stateTotalContentPlay =
              this.data.footer.total_time_spent.toLocaleString("en-IN") +
              " " +
              "Hours";
            this.data.data.forEach((item) => {
              if (item.district_name === "Others") {
                this.otherStateContentPlays =
                  item.total_content_plays.toLocaleString("en-IN");
                this.otherStateTotalTime = item.total_time_spent;
                this.otherStateAvgTime = item.avg_time_spent;
              }
            });
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

            this.genericFun(this.districtMarkers, options, this.fileName);
            this.globalService.onResize(this.level);

            this.changeDetection.detectChanges();
            this.commonService.loaderAndErr(this.data);
          },
          (err) => {
            this.data = [];
            this.commonService.loaderAndErr(this.data);
          }
        );
      }
      // adding the markers to the map layers
      globalMap.addLayer(this.layerMarkers);
    } catch (e) {
      this.districtMarkers = [];
      this.commonService.loaderAndErr(this.districtMarkers);
      console.log(e);
    }
  }

  // common function for all the data to show in the map

  onSelectType(data) {
    this.selectedType = data;
    
    this.reportName = `ETB_${this.selectedType}`
    this.getDistData();
  }

  genericFun(data, options, fileName) {
    try {
      this.reportData = [];
      this.markers = data;
      var colors = this.commonService.getTpdMapRelativeColors(this.markers, {
        value: this.selectedType,
        report: "reports",
      });
      // attach values to markers
      for (let i = 0; i < this.markers.length; i++) {
        var color;
        if (this.onRangeSelect == "absolute") {
          color = this.commonService.tpdColorGredient(
            this.markers[i],
            this.valueRange
            // colors
          );
        } else {
          color = this.commonService.colorGredientForDikshaMaps(
            this.markers[i],
            this.selectedType,
            colors
          );
        }
        // google map circle icon
        if (this.mapName == "googlemap") {
          let markerColor = color;
          this.markers[i]["icon"] = this.globalService.initGoogleMapMarker(
            markerColor,
            options.radius,
            0.5
          );
        }

        if (this.markers[i].latitude && this.markers[i].longitude) {
          var markerIcon = this.globalService.initMarkers1(
            this.markers[i].latitude,
            this.markers[i].longitude,
            color,
            options.level == "School" ? 0 : options.strokeWeight,
            options.level == "School" ? 0.3 : 1,
            options.level
          );
        }

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
      console.log(e);
    }
  }

  generateToolTip(marker, level, markerIcon, lat, lng) {
    this.popups(markerIcon, marker, level);
    var infraName = this.selectedType;
    let colorText = `style='color:blue !important;'`;
    var details = {};
    var orgObject = {};
    Object.keys(marker).forEach((key) => {
      if (key !== lat) {
        details[key] = marker[key];
      }
    });
    Object.keys(details).forEach((key) => {
      if (key !== lng) {
        orgObject[key] = details[key];
      }
    });

    var detailUsage = {};
    var yourData1;

    for (var key of Object.keys(orgObject)) {
      if (key === "district_id" || key === "district_name")
        detailUsage[key] = orgObject[key];
    }

    var metrics = {};
    var yourData1;

    for (var key of Object.keys(orgObject)) {
      if (key !== "district_id" && key !== "district_name")
        metrics[key] = orgObject[key];
    }

    for (var key of Object.keys(orgObject)) {
      if (key === "total_content_plays")
        metrics[key] = orgObject[key].toLocaleString("en-IN");
    }

    for (var key of Object.keys(orgObject)) {
      if (key === "total_time_spent")
        metrics[key] = orgObject[key].toLocaleString("en-IN") + " " + "Hours";
    }

    for (var key of Object.keys(orgObject)) {
      if (key === "avg_time_spent")
        metrics[key] = orgObject[key].toLocaleString("en-IN") + " " + "Minutes";
    }

    yourData1 = this.globalService
      .getInfoFrom(detailUsage, "", level, "infra-map", infraName, colorText)
      .join(" <br>");
    var yourData = this.globalService
      .getInfoFrom(metrics, "", level, "infra-map", infraName, colorText)
      .join(" <br>");
    var toolTip = yourData;
    if (this.mapName != "googlemap") {
      const popup = R.responsivePopup({
        hasTip: false,
        autoPan: false,
        offset: [15, 20],
      }).setContent(
        "<b><u>Details</u></b>" +
          "<br>" +
          yourData1 +
          "<br><br><b><u>Metrics of Content Play</u></b>" +
          "<br>" +
          yourData
       
      );
      markerIcon.addTo(globalMap).bindPopup(popup);
    } else {
      marker["label"] = toolTip;
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

    markerIcon.myJsonData = markers;
  }

  public legendColors: any = [
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
  public len;

  filterRangeWiseData(value, index) {
    this.prevRange = value;
    globalMap.removeLayer(this.markersList);
    this.layerMarkers.clearLayers();

    let arr = [];

    for (let i = 0; i < this.data.data.length; i++) {
      arr.push(this.data.data[i][`${this.selectedType}`]);
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
        let range1 = min;
        for (let i = 0; i < n; i += 1) {
          const range2 = range1 + delta;
          ranges.push([range1, range2]);
          range1 = range2;
        }
        return ranges;
      };

      const rangeArrayIn5Parts = getRangeArray(min, max, 5);
      slabArr = arr.filter(
        (val) => val >= ranges[index][0] && val <= ranges[index][1]
      );
    } else {
      slabArr = arr;
    }

    if (value) {
      this.data.data.map((a) => {
        if (a.latitude) {
          if (
            a[`${this.selectedType}`] <= Math.max(...slabArr) &&
            a[`${this.selectedType}`] >= Math.min(...slabArr)
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
    document.getElementById(`${i}`)
      ? (document.getElementById(`${i}`).style.border =
          this.height < 1100 ? "2px solid gray" : "6px solid gray")
      : "";
    document.getElementById(`${i}`)
      ? (document.getElementById(`${i}`).style.transform = "scale(1.1)")
      : "";
    this.deSelect();
  }

  deSelect() {
    this.onRangeSelect = "";
    var elements = document.getElementsByClassName("legends");
    for (var j = 0; j < elements.length; j++) {
      if (this.selectedIndex !== j) {
        elements[j]["style"].border = "1px solid transparent";
        elements[j]["style"].transform = "scale(1.0)";
      }
    }

    this.districtMarkers = this.data;
  }

  reset(value) {
    this.valueRange = -1;
    this.selectedIndex = undefined;
    this.deSelect();
    this.filterRangeWiseData(value, -1);
  }

  // to download the csv report
  downloadReport() {
    var position = this.reportName.length;
    this.fileName = this.commonService.changeingStringCases(this.fileName)
    this.commonService.download(this.fileName, this.reportData, this.reportName1);
  }

  getDownloadableData(markers, level) {
    var details = {};
    var orgObject = {};
    var data1 = {};
    var data2 = {};
    Object.keys(markers).forEach((key) => {
      if (key !== "latitude") {
        details[key] = markers[key];
      }
    });

    Object.keys(details).forEach((key) => {
      var str = key.charAt(0).toUpperCase() + key.substr(1).toLowerCase();
      if (key !== "longitude") {
        orgObject[`${str}`] = details[key];
      }
    });
    var ordered = {};

    var myobj = Object.assign(orgObject, ordered);
    this.reportData.push(myobj);
  }
}
