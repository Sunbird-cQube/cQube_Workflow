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
  selector: 'app-tpd-total-content-plays',
  templateUrl: './tpd-total-content-plays.component.html',
  styleUrls: ['./tpd-total-content-plays.component.css'],
  changeDetection: ChangeDetectionStrategy.OnPush,
  encapsulation: ViewEncapsulation.None,
})
export class TpdTotalContentPlaysComponent implements OnInit {


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
    this.globalService.initMap("tpdMap", [[this.lat, this.lng]]);
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
        this.myData = this.service.tpdDistWise().subscribe(
          (res) => {
            this.myDistData = this.data = res["data"];
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
            this.districtMarkers = this.data.data;
            this.totalContentPlays = this.data.footer.total_content_plays.toLocaleString('en-IN');
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
  selectionType = []
  onSelectType(data) {
    this.selectedType = data;
    this.getDistData()
  }
  genericFun(data, options, fileName) {
    try {
      this.reportData = [];
      this.markers = data;
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
    
    var detailUsage = {};
    var yourData1;
    
    for (var key of Object.keys(orgObject)) {
      if( key === 'district_id' || key === 'district_name')
      detailUsage[key] = orgObject[key]
  }

  var metrics = {};
  var yourData1;
  
  for (var key of Object.keys(orgObject)) {
    if( key !== 'district_id' && key !== 'district_name')
    metrics[key] = orgObject[key]
}
    
     yourData1 = this.globalService.getInfoFrom(detailUsage, "", level, "infra-map", infraName, colorText)
      .join(" <br>");
    var yourData = this.globalService.getInfoFrom(metrics, "", level, "infra-map", infraName, colorText)
      .join(" <br>");

    var toolTip = yourData;
    if (this.mapName != 'googlemap') {
      const popup = R.responsivePopup({
        hasTip: false,
        autoPan: false,
        offset: [15, 20],
      }).setContent(
        "<b><u>Details</u></b>" +
        "<br>" + yourData1
         +
        "<br><br><b><u>Metrics of Content Play</u></b>" +
        "<br>" +
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



  public legendColors: any = [
    "#d9ef8b",
    "#a6d96a",
    "#66bd63",
    "#1a9850",
    "#006837",
  ];
  public values = [
    "0-20",
    "21-40",
    "41-60",
    "61-80",
    "81-100",
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
      this.data.data.map(a => {
       
          if ( Math.round(a.avg_time_spent) > this.valueRange.split("-")[0] - 1 && Math.round(a.avg_time_spent) <= this.valueRange.split("-")[1]) {
            markers.push(a);
          }
       
      })
    } else {
      markers = this.data;
    }
    this.genericFun(markers, this.dataOptions, this.fileName);
    this.commonService.errMsg();
   
      this.districtMarkers = markers;
   

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
  
      this.districtMarkers = this.data;
   
  }

  reset(value) {
    this.valueRange = value;
    this.selectedIndex = undefined;
    this.deSelect();
    this.filterRangeWiseData(value);
  }

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
   
  
    var myobj = Object.assign(orgObject, ordered);
    this.reportData.push(myobj);
  }

}



