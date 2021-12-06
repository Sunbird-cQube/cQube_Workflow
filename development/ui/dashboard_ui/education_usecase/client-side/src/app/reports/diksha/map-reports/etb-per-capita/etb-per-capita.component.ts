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
  selector: 'app-etb-per-capita',
  templateUrl: './etb-per-capita.component.html',
  styleUrls: ['./etb-per-capita.component.css']
})
export class EtbPerCapitaComponent implements OnInit {

 
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

  public selected = "absolute";
  public onRangeSelect;

  reportName = "ETB_Total_content_play";

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
  othersStatePercentage
  otherStateContentPlays

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
            
            this.data.data.forEach( item => {
              
                 if(item.district_name === "Others"){
                   this.otherStateContentPlays = item.total_content_plays.toLocaleString('en-IN')
                   
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
      this.markers = data;
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

for (var key of Object.keys(orgObject)) {
  if( key === 'total_content_plays')
  metrics[key] = orgObject[key].toLocaleString('en-IN');
}

for (var key of Object.keys(orgObject)) {
  if( key === 'total_time_spent')
  metrics[key] = orgObject[key].toLocaleString('en-IN') + " "+ 'Hours'
}

for (var key of Object.keys(orgObject)) {
  if( key === 'avg_time_spent')
  metrics[key] = orgObject[key].toLocaleString('en-IN') + " "+ 'Seconds'
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
    "Above Average",
    "Average",
    "Below Average",
  ];


  //Filter data based on attendance percentage value range:::::::::::::::::::
  public valueRange = undefined;
  public prevRange = undefined;
  selectRange(value) {
    this.onRangeSelect = "absolute"
    this.valueRange = value;
    this.filterRangeWiseData(value);
  }
  public len

  filterRangeWiseData(value) {
    this.prevRange = value;
    globalMap.removeLayer(this.markersList);
    this.layerMarkers.clearLayers();
  
    let arr = [];
    
    for(let i = 0; i< this.data.data.length; i++){
        arr.push(this.data.data[i][`${this.selectedType}`])
    }
    arr = arr.sort(function (a, b) { return   parseFloat(a) - parseFloat(b) });
     console.log('value', value)
    //getting relative colors for all markers:::::::::::
    var markers = [];
    let slabArr = [];
    let slabLength = Math.round((arr.length)/3)
    
    if (value) {
      if( value === 'Below Average'){
        // slabArr = arr.slice(0,Math.round((arr.length)/5))
        slabArr = arr.slice(0,slabLength)
      } else if(value === '21-40'){
        slabArr = arr.slice(slabLength,slabLength *2)
        // slabArr = arr.slice(slabArr.length ,slabLength)
      } else if(value === 'Average'){
        slabArr = arr.slice(slabLength,slabLength *2)
      }else if(value === '61-80'){
        slabArr = arr.slice(slabLength *3, slabLength *4)
      }else if(value === 'Above Average'){
        slabArr = arr.slice(slabLength *2)
      }else if(value === '0-100'){
        slabArr = arr
      }

      console.log('slab',slabArr)
      this.data.data.map(a => {
       
        if(a.latitude){
          if(a[`${this.selectedType}`] <= Math.max(...slabArr) && a[`${this.selectedType}`] >= Math.min(...slabArr)){
                
                markers.push(a);
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
    this.valueRange = value;
    this.selectedIndex = undefined;
    this.deSelect();
    this.filterRangeWiseData(value);
  }

  // to download the csv report
  downloadReport() {
    var position = this.reportName.length;
    this.fileName = [this.fileName.slice(0, position), this.fileName.slice(position)].join('');
    this.commonService.download(this.fileName, this.reportData);
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
