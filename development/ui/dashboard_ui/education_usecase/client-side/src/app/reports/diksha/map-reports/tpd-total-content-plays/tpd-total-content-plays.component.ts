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
      
  public legandName = ''
  public selected = "absolute";
  public onRangeSelect;
 
  reportName = `TPD_${this.selectedType}`;
  reportName1 = "gpsOfLearningTpd"

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

  public data
  public districtMarkers
  public markers
  public totalContentPlays
  public othersStatePercentage
  public otherStateContentPlays
  public otherStateTotalTime
  public otherStateAvgTime;
  public stateAvgTimeSpend;
  public stateTotalContentPlay;
 public  level;
 public  googleMapZoom
  selectionType = []
  infraData

  clickHome() {
    this.onRangeSelect ="",
    this.selectedType ="total_time_spent"
    this.infraData = "infrastructure_score";
    this.getDistData();
  }
  // to load all the districts for state data on the map
  getDistData() {
   this.reportName = `TPD_${this.selectedType}`;
   this.legandName = this.commonService.changeingStringCases(this.selectedType.replace(/_/g, " "))
  
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
          if (i == 0 || i == 1 || i == 6) {
            obj = {
              id: keys[i],
              name: this.commonService.changeingStringCases(keys[i])
            }
            this.selectionType.push(obj)
           }
        }

        let arr = [];
            this.values = [];
    
            for(let i = 0; i< this.data.data.length; i++){
                arr.push(this.data.data[i][`${this.selectedType}`])
            }
            
            arr = arr.sort(function (a, b) { return   parseFloat(a) - parseFloat(b) });
            
            let maxArr = arr[arr.length-1]
            let partition
            if(this.selectedType == 'avg_time_spent'){
               partition = maxArr/5
              //  partition = +partition.toFixed(2)
               //  partition = Math.round((partition + Number.EPSILON) * 100) / 100
            }else {
               partition = Math.ceil(maxArr/5)
            }
            for(let i = 0; i< 5; i++){
              
              if (this.selectedType == "avg_time_spent") {
                this.values.push(`${(partition * i).toFixed(2)}-${(partition * (i + 1)).toFixed(2)}`); // 0-partition /  partition+1-partition*2
              } else {
                // this.values.push(`${partition * i + i}-${partition * (i + 1)}`); // 0-partition /  partition+1-partition*2
                this.values.push(`${Number(partition * i + i).toLocaleString('en-IN')}-${Number(partition * (i + 1)).toLocaleString('en-IN')}`);
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
        this.myData = this.service.tpdDistWise().subscribe(
          (res) => {
            this.myDistData = this.data = res["data"];

            let arr = [];
            this.values = [];
    
            for(let i = 0; i< this.data.data.length; i++){
                arr.push(this.data.data[i][`${this.selectedType}`])
            }
          
            arr = arr.sort(function (a, b) { return   parseFloat(a) - parseFloat(b) });
            
            let maxArr = arr[arr.length-1]
            let partition
            if(this.selectedType == 'avg_time_spent'){
               partition = maxArr/5
            }else {
               partition = Math.ceil(maxArr/5)
            }
            
            for(let i = 0; i< 5; i++){
              
              if (this.selectedType == "avg_time_spent") {
                this.values.push(`${(partition * i).toFixed(2)}-${(partition * (i + 1)).toFixed(2)}`); // 0-partition /  partition+1-partition*2
              } else {
                // this.values.push(`${partition * i + i}-${partition * (i + 1)}`); // 0-partition /  partition+1-partition*2
                this.values.push(`${Number((partition * i) + i).toLocaleString('en-IN')}-${Number(partition * (i + 1)).toLocaleString('en-IN')}`);
              }
            }

            let keys = Object.keys(this.data.data[0])
            let obj = {}
            for (let i = 0; i < keys.length ; i++) {
             if (i == 0 || i == 1 || i == 6) {
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
            this.stateAvgTimeSpend = this.data.footer.average_time_state.toLocaleString('en-IN') + " " + "Minutes" 
            this.stateTotalContentPlay = this.data.footer.total_time_spent.toLocaleString('en-IN') + " " + "Hours" 
            
            this.data.data.forEach( item => {
              
                 if(item.district_name === "Others"){
                   this.otherStateContentPlays = item.total_content_plays.toLocaleString('en-IN')
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
    this.getDistData();
  }
  
  
 
  genericFun(data, options, fileName) {
    try {
      this.reportData = [];
      this.markers = data;
      this.markers = data.filter(distData =>{
          return distData.latitude !== null
      })
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
        if (this.onRangeSelect == "absolute") {
        color = this.commonService.tpdColorGredient(
          this.markers[i],
          this.valueRange,
          // colors
        );
        }else{
          color = this.commonService.colorGredientForDikshaMaps(
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
  metrics[key] = orgObject[key].toLocaleString('en-IN') + " "+ 'Minutes'
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
    "#d9ef8b",
    "#a6d96a",
    "#66bd63",
    "#1a9850",
    "#006837",
  ];
  // public values = [
  //   "0-20",
  //   "21-40",
  //   "41-60",
  //   "61-80",
  //   "81-100",
  // ];

  public values = [

  ]


  //Filter data based on attendance percentage value range:::::::::::::::::::
  public valueRange = undefined;
  public prevRange = undefined;
  selectRange(value, i) {
    this.onRangeSelect = "absolute"
    this.valueRange = i;
    this.filterRangeWiseData(value, i);
  }
  public len

  filterRangeWiseData(value, index) {
    this.prevRange = value;
    globalMap.removeLayer(this.markersList);
    this.layerMarkers.clearLayers();
  
    let arr = [];
    
    for(let i = 0; i< this.data.data.length; i++){
        arr.push(this.data.data[i][`${this.selectedType}`])
    }
  
    arr = arr.sort(function (a, b) { return   parseFloat(a) - parseFloat(b) });
    var markers = [];
    let slabArr = [];

      if (index > -1) {
        let maxArr = arr[arr.length-1]
        let partition
        if(this.selectedType == 'avg_time_spent'){
           partition = maxArr/5
          //  partition = +partition.toFixed(2)
           //  partition = Math.round((partition + Number.EPSILON) * 100) / 100
        }else {
           partition = Math.ceil(maxArr/5)
        }
        //getting relative colors for all markers:::::::::::
        
        let min
        
        if(this.selectedType == 'avg_time_spent'){
          min = partition*index+0.1
        }else{
          min = partition*index+index
        }
        let max = partition*(index+1)
        slabArr = arr.filter(val => val >= min && val <= max)
      } else {
        slabArr = arr;
      }
     
    if (value) {
      // if( value === '0-20'){
      //   // slabArr = arr.slice(0,Math.round((arr.length)/5))
      //   slabArr = arr.slice(0,slabLength)
      // } else if(value === '21-40'){
      //   slabArr = arr.slice(slabLength,slabLength *2)
      //   // slabArr = arr.slice(slabArr.length ,slabLength)
      // } else if(value === '41-60'){
      //   slabArr = arr.slice(slabLength *2,slabLength *3)
      // }else if(value === '61-80'){
      //   slabArr = arr.slice(slabLength *3, slabLength *4)
      // }else if(value === '81-100'){
      //   slabArr = arr.slice(slabLength *4)
      // }else if(value === '0-100'){
      //   slabArr = arr
      // }
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
    this.valueRange = -1;
    this.selectedIndex = undefined;
    this.deSelect();
    this.filterRangeWiseData(value, -1);
  }

  // to download the csv report
  downloadReport() {
    var position = this.reportName.length;
    this.fileName = this.commonService.changeingStringCases(this.fileName);
    // this.fileName = [this.fileName.slice(0, position), this.fileName.slice(position)].join('');
    this.commonService.download(this.fileName, this.reportData, this.reportName1);
  }


  getDownloadableData(markers, level) {
 
    var details = {};
    var orgObject = {};
    var data1 = {};
    var data2 = {};
    Object.keys(markers).forEach((key) => {
      if (key !== "latitude" && key !== "longitude") {
        details[key] = markers[key];
      }
    });
   
    var ordered = {};
   
    var myobj = Object.assign(details, ordered);
    this.reportData.push(myobj);
  }

}



