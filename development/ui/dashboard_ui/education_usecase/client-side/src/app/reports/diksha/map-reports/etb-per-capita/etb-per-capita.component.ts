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
import { PerCapitaMapReport } from 'src/app/services/per-capita-map-report.service';

@Component({
  selector: 'app-etb-per-capita',
  templateUrl: './etb-per-capita.component.html',
  styleUrls: ['./etb-per-capita.component.css']
})
export class EtbPerCapitaComponent implements OnInit {

 
  public state: string;
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
  public reportName;
  public reportName1 = "perCapita"
  public reportData
  public selectedType = 'total_content_plays';
  // public selectedType = 'plays_per_capita';

  public selected = "absolute";
  public onRangeSelect;

  mapName
  constructor(
    public http: HttpClient,
    public globalService: MapService,
    public service: PerCapitaMapReport,
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
    this.reportName = `ETB_Per_Capita_${this.state}`
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
  othersStatePercentage
  otherStateContentPlays
  statePlayPerCapita
  stateExpectedUsers
  otherStatePlayPerCapita
  otherStateExpectdUser 
  stateActualUsers
  otherStateActualUsers
  

  level;
  googleMapZoom
  selectionType = []
  infraData


  clickHome() {
    this.onRangeSelect =""
    this.infraData = "infrastructure_score";
    this.getDistData();
  }
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
      this.fileName = `${this.reportName}`;
      this.selectionType = [];
     
      this.valueRange = undefined;
      this.selectedIndex = undefined;
      this.deSelect();

      this.deSelect();

      if (this.myDistData && this.myDistData['data'].length) {
        this.data = this.myDistData;
        let keys = Object.keys(this.data.data[0])
        
        let obj = {}
        for (let i = 0; i < keys.length; i++) {
          if (i == 0 || i == 5 || i == 6) {
            obj = {
              id: keys[i],
              name: this.commonService.changeingStringCases(keys[i])
            }
            this.selectionType.push(obj)
           }
        }
        // to show only in dropdowns
        this.districtMarkers = this.data.data
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
        this.myData = this.service.perCapitaState().subscribe(
          (res) => {
            this.myDistData = this.data = res["data"];
            let keys = Object.keys(this.data.data[0])
            let obj = {}
            for (let i = 0; i < keys.length ; i++) {
             if (i == 0 || i == 5 || i == 6) {
              obj = {
                id: keys[i],
                name: this.commonService.changeingStringCases(keys[i])
              }
              this.selectionType.push(obj)
             }
             
              
            }
            // to show only in dropdowns
            this.districtMarkers = this.data.data;
            this.totalContentPlays = this.data.footer.total_content_plays.toLocaleString('en-IN');
            this.othersStatePercentage ="(" +this.data.footer.others_percentage+ "%"+")";
            this.statePlayPerCapita = this.data.footer.per_capita_statewise.toLocaleString('en-IN');
            this.stateExpectedUsers = this.data.footer.total_expected_ETB_users.toLocaleString('en-IN');
           
            this.data.data.forEach( item => {
              
                 if(item.district_name === "Others"){
    
                   this.otherStateContentPlays = item.total_content_plays.toLocaleString('en-IN');
                   this.otherStatePlayPerCapita = item.plays_per_capita.toLocaleString('en-IN');
                   this.otherStateExpectdUser = item.expected_ETB_users.toLocaleString('en-IN')
                 
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
    this.getDistData()
  }
 
  genericFun(data, options, fileName) {
    try {
      this.reportData = [];
      this.markers = data.filter(distData => {
        return distData.latitude !== null;
      });
      var colors = this.commonService.getTpdMapCapitaRelativeColors(
        this.markers,
        {
          value: this.selectedType,
          report: "reports",
        }
      );
      // attach values to markers
      for (let i = 0; i < this.markers.length; i++) {
        var color;
        if (this.onRangeSelect == "absolute") {
        color = this.commonService.tpdCapitaColorGredient(
          this.markers[i],
          this.valueRange,
          // colors
        );
        }else{
          color = this.commonService.colorGredientForCapitaMaps(
            this.markers[i],
            this.selectedType,
            colors
          );
        }
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
        this.getDownloadableData(this.markers[i], options.level);
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
    let colorText = `style='color:"#212121" !important;'`;
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
  // var yourData1;
  
  for (var key of Object.keys(orgObject)) {
    if( key !== 'district_id' && key !== 'district_name' && key !== 'quartile')
    metrics[key] = orgObject[key]
}

for (var key of Object.keys(orgObject)) {
  if( key === 'total_content_plays')
  metrics[key] = orgObject[key].toLocaleString('en-IN');
  if( key === 'expected_etb_users')
  metrics[key] = orgObject[key].toLocaleString('en-IN');
  if( key === 'actual_etb_users')
  metrics[key] = orgObject[key].toLocaleString('en-IN');
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
        // `
        // <b><u>Details</u></b> 
        // <br>  ${yourData1}
        // <br><br><b><u>Metrics of Content Play</u></b> 
        // <br> 
        // ${yourData}
        // `
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
    "#9AE66E",
    "#94B3FD",
    "#FFAFAF",
  ];
  public values = [
    "Upper Quartile ( above 75% )",
    "Inter Quartile ( 25%-75% )",
    "Bottom Quartile ( below 25% )",
  ];


  //Filter data based on attendance percentage value range:::::::::::::::::::
  public valueRange = undefined;
  public prevRange = undefined;
  selectRange(value, index) {
    this.onRangeSelect = "absolute"
    this.valueRange = index;
    this.filterRangeWiseData(value, index);
  }
  public len

  filterRangeWiseData(value, index) {
    this.prevRange = value;
    globalMap.removeLayer(this.markersList);
    this.layerMarkers.clearLayers();
    // //getting relative colors for all markers:::::::::::
    var markers = [];

    if (value) {
      this.data.data.map(marker =>{
        if(marker.latitude){
            if(value === 'Upper Quartile ( above 75% )'){
              if(marker['quartile'] === 3 ){
                  markers.push(marker);
                }    
            }else if( value === "Inter Quartile ( 25%-75% )"){
              if(marker['quartile'] === 2){
                markers.push(marker);
              }    
            }else if( value === "Bottom Quartile ( below 25% )"){
              if(marker['quartile'] === 1){
                markers.push(marker);
              }    
            }else if( value === "all"){
              
                markers.push(marker);
               
            }          
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
    this.onRangeSelect = "";
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
    this.valueRange = -1;
    this.selectedIndex = undefined;
    this.deSelect();
    this.filterRangeWiseData(value, -1);
  }

  // to download the csv report
  downloadReport() {
    var position = this.reportName.length;
    this.fileName = [this.fileName.slice(0, position), this.fileName.slice(position)].join('');
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
      if (key !== "longitude" && key !== 'quartile') {
        orgObject[`${str}`] = details[key];
      }
    });
    var ordered = {};
   
  
    var myobj = Object.assign(orgObject, ordered);
    this.reportData.push(myobj);
  }

}
