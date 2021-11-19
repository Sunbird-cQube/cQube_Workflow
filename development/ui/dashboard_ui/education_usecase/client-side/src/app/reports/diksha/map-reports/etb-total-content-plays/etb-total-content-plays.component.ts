import {
  Component, OnInit,
  ChangeDetectionStrategy,
  ChangeDetectorRef,
  ViewEncapsulation,
} from '@angular/core';
import { DikshaMapReportsService } from 'src/app/services/diksha-map-reports.service';
import { MapService, globalMap } from 'src/app/services/map-services/maps.service';
import * as L from "leaflet";
import * as R from "leaflet-responsive-popup";
import { Router } from '@angular/router';
import { HttpClient } from '@angular/common/http';
import { AppServiceComponent } from 'src/app/app.service';

@Component({
  selector: 'app-etb-total-content-plays',
  templateUrl: './etb-total-content-plays.component.html',
  styleUrls: ['./etb-total-content-plays.component.css']
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

  public reportData
  public selectedType = 'total_time_spent';

  selected = "absolute"

  mapName
  constructor(
    public http: HttpClient,
    public globalService: MapService,
    public service: DikshaMapReportsService,
    public commonService: AppServiceComponent,
    public router: Router,
    private changeDetection: ChangeDetectorRef,
  ) { }


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
    this.globalService.latitude = this.lat = this.globalService.mapCenterLatlng.lat;
    this.globalService.longitude = this.lng = this.globalService.mapCenterLatlng.lng;
    this.changeDetection.detectChanges();
    this.globalService.initMap("etbMap", [[this.lat, this.lng]]);
    if (this.mapName == 'googlemap') {
      document.getElementById('leafletmap').style.display = "none";
    }

    document.getElementById("accessProgressCard").style.display = "none";
    document.getElementById("backBtn") ? document.getElementById("backBtn").style.display = "none" : "";
    this.getDistData()

  }

  data
  districtMarkers
  markers
  totalContentPlays

  level;
  googleMapZoom
  // to load all the districts for state data on the map
  getDistData() {
    try {
      // to clear the existing data on the map layer
      globalMap.removeLayer(this.markersList);
      this.layerMarkers.clearLayers();
      this.globalService.latitude = this.lat = this.globalService.mapCenterLatlng.lat;
      this.globalService.longitude = this.lng = this.globalService.mapCenterLatlng.lng;
      this.districtId = undefined;
      this.commonService.errMsg();
      this.level = "District";
      this.googleMapZoom = 7;
      // this.fileName = `${this.reportName}_allDistricts_${this.commonService.dateAndTime}`;
      this.selectionType = [];
      if (this.myDistData && this.myDistData['data'].length) {
        this.data = this.myDistData;
        let keys = Object.keys(this.data.data[0])
        let obj = {}
        for (let i = 0; i < keys.length - 4; i++) {
          obj = {
            id: keys[i],
            name: this.commonService.changeingStringCases(keys[i])
          }
          this.selectionType.push(obj)
        }
        // to show only in dropdowns
        this.districtMarkers = this.data;
        this.totalContentPlays = this.data.footer.total_content_plays;
        
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
            console.log('etb',res)
            let keys = Object.keys(this.data.data[0])
            let obj = {}
            for (let i = 0; i < keys.length - 4; i++) {
              obj = {
                id: keys[i],
                name: this.commonService.changeingStringCases(keys[i])
              }
              this.selectionType.push(obj)
            }
            // to show only in dropdowns
            this.districtMarkers = this.data;
            this.totalContentPlays = this.data.footer.total_content_plays;
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

  selectionType = []
  onSelectType(data) {
    this.selectedType = data;
    this.getDistData()
  }

  // common function for all the data to show in the map

  genericFun(data, options, fileName) {
    try {
      this.reportData = [];
      this.markers = data.data;
      var colors = this.commonService.getTpdMapRelativeColors(
        this.markers,
        {
          value: this.selectedType,
          report: "reports",
        }
      );

      // attach values to markers
      for (let i = 0; i < this.markers.length; i++) {
        var color;
        color = this.commonService.colorGredientForDikshaMaps(
          this.markers[i],
          this.selectedType,
          colors
        );

        // google map circle icon
        if (this.mapName == "googlemap") {
          let markerColor = color
          this.markers[i]['icon'] = this.globalService.initGoogleMapMarker(markerColor, options.radius, .5);
        }

        if (this.markers[i].latitude && this.markers[i].longitude) {
          var markerIcon = this.globalService.initMarkers1(
            this.markers[i].latitude,
            this.markers[i].longitude,
            color,
            options.level == 'School' ? 0 : options.strokeWeight,
            options.level == 'School' ? 0.3 : 1,
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
      }
      this.commonService.loaderAndErr(data);
      this.changeDetection.detectChanges();
    } catch (e) {
      data = [];
      this.commonService.loaderAndErr(data);
      console.log(e)
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

    var yourData = this.globalService.getInfoFrom(orgObject, "", level, "infra-map", infraName, colorText)
      .join(" <br>");

    var toolTip = yourData;
    if (this.mapName != 'googlemap') {
      const popup = R.responsivePopup({
        hasTip: false,
        autoPan: false,
        offset: [15, 20],
      }).setContent(

        yourData
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

    markerIcon.myJsonData = markers;
  }


}
