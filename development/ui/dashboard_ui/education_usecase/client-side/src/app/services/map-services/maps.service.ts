import { Injectable } from '@angular/core';
import { environment } from 'src/environments/environment';
import * as config from '../../../assets/config.json';
import * as mapData from '../../../assets/map.json';
declare var MapmyIndia: any;
declare var L: any;
export var globalMap;

@Injectable({
  providedIn: 'root'
})
export class MapService {
  mapName = environment.mapName;
  mapCenterLatlng = config.default[`${environment.stateName}`];
  zoomLevel = this.mapCenterLatlng.zoomLevel;

  latitude;
  longitude;

  constructor() { }

  width = window.innerWidth;
  onResize(level) {
    this.width = window.innerWidth;
    this.zoomLevel = this.width > 3820 ? this.mapCenterLatlng.zoomLevel + 2 : this.width < 3820 && this.width >= 2500 ? this.mapCenterLatlng.zoomLevel + 1 : this.width < 2500 && this.width > 1920 ? this.mapCenterLatlng.zoomLevel + 1 : this.mapCenterLatlng.zoomLevel;
    this.setZoomLevel(level);
    this.setMarkerRadius(level);
  }

  //Initialisation of Map  
  initMap(map, maxBounds) {
    if (this.mapName == 'leafletMap') {
      globalMap = L.map(map, { zoomControl: false, maxBounds: maxBounds, dragging: environment.stateName == 'UP' ? false : true }).setView([maxBounds[0][0], maxBounds[0][1]], this.mapCenterLatlng.zoomLevel);
      var data = mapData.default;
      function applyCountryBorder(map) {
        L.geoJSON(data[`${environment.stateName}`]['features'], {
          color: "#6e6d6d",
          weight: 2,
          fillOpacity: 0,
          fontWeight: "bold"
        }).addTo(map);
      }
      applyCountryBorder(globalMap);
      L.tileLayer('https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png',
        {
          subdomains: ['mt0', 'mt1', 'mt2', 'mt3'],
          maxZoom: this.mapCenterLatlng.zoomLevel + 10,
        }
      ).addTo(globalMap);
    } else{
      globalMap = new MapmyIndia.Map(map, { hasTip: false, autoPan: false, offset: [15, 20] }, {
        zoomControl: false,
        hybrid: false,
      }).setView([maxBounds[0][0], maxBounds[0][1]], this.mapCenterLatlng.zoomLevel);
    }
  }

  restrictZoom(globalMap) {
    globalMap.touchZoom.disable();
    globalMap.boxZoom.disable();
    globalMap.keyboard.disable();
  }

  //Initialise markers.....
  markersIcons = [];
  public initMarkers1(lat, lng, color, strokeWeight, weight, levelWise) {
    if (lat !== undefined && lng !== undefined) {
      var markerIcon;
      markerIcon = L.circleMarker([lat, lng], {
        color: "gray",
        fillColor: color,
        fillOpacity: 1,
        strokeWeight: strokeWeight,
        weight: weight
      }).addTo(globalMap);
      this.markersIcons.push(markerIcon);
      return markerIcon;
    }

    return undefined;
  }

  setMarkerRadius(level) {
    this.markersIcons.map(markerIcon => {
      if (level === "District") {
        markerIcon.setRadius(this.getMarkerRadius(18, 14, 10, 6));
      }
      if (level === "Block") {
        markerIcon.setRadius(this.getMarkerRadius(12, 10, 8, 5));
      }
      if (level === "Cluster") {
        markerIcon.setRadius(this.getMarkerRadius(5, 4, 3, 2));
      }
      if (level === "School") {
        markerIcon.setRadius(this.getMarkerRadius(3, 2.5, 2, 1));
      }
      if (level === "blockPerDistrict" || level === "clusterPerBlock" || level === "schoolPerCluster") {
        markerIcon.setRadius(this.getMarkerRadius(18, 14, 10, 5));
      }
    })
  }

  getMarkerRadius(rad1, rad2, rad3, rad4) {
    let radius = this.width > 3820 ? rad1 : this.width > 2500 && this.width < 3820 ? rad2 : this.width < 2500 && this.width > 1920 ? rad3 : rad4;
    return radius;
  }

  setZoomLevel(level) {
    var zoomLevel;
    if (level === "District" || level === "Block" || level === "Cluster" || level === "School") {
      zoomLevel = this.zoomLevel
    }
    if (level === "blockPerDistrict") {
      zoomLevel = this.zoomLevel + 1;
    }
    if (level === "clusterPerBlock") {
      zoomLevel = this.zoomLevel + 3;
    }
    if (level === "schoolPerCluster") {
      zoomLevel = this.zoomLevel + 5;
    }
    globalMap.options.minZoom = zoomLevel;
    if (this.latitude !== null && this.longitude !== null)
      globalMap.setView(new L.LatLng(this.latitude, this.longitude), zoomLevel);
  }

  //map tooltip automation
  public getInfoFrom(object, value, levelWise, reportType, infraName, colorText) {
    var popupFood = [];
    var stringLine;
    var selected = '<span>';
    for (var key in object) {
      if (object[key] && typeof object[key] != 'number' && typeof object[key] == 'string' && object[key].includes('%')) {
        var split = object[key].split("% ");
        object[`${key}`] = parseFloat(split[0].replace(` `, '')).toFixed(1) + ' % ' + split[1];
      }
      if (key == 'school_management_type' || key == 'school_category') {
        object[`${key}`] = this.changeingStringCases(object[key].replace(/_/g, ' '));
      }
      if (object.hasOwnProperty(key)) {
        if (key == value) {
          if (reportType == "infra-map" || reportType == "patReport") {
            selected = `<span ${infraName == key.trim() ? colorText : ''}>`
          }
          stringLine = selected + "<b>" +
            key.replace(
              /\w\S*/g,
              function (txt) {
                txt = txt.replace('Id', '_id');
                txt = txt.replace('Name', '_name');
                txt = txt.replace(/_/g, ' ');
                if (txt.includes('percent') && txt != 'percentage schools with missing data') {
                  txt = txt.replace('percent', '(%)');
                }
                txt = txt == 'students count' ? 'student count' : txt;
                if (txt.includes('id')) {
                  return txt.charAt(0).toUpperCase();
                } else {
                  return toTitleCase(txt);
                }
              })
            + "</b>" + ": " + object[key] + " %" + `</span>`;
        } else {
          if (reportType == "infra-map" || reportType == "patReport") {
            selected = `<span ${infraName == key.trim() ? colorText : ''}>`
          }
          stringLine = selected + "<b>" +
            key.replace(
              /\w\S*/g,
              function (txt) {
                txt = txt.replace('Id', '_id');
                txt = txt.replace('Name', '_name');
                txt = txt.replace(/_/g, ' ');
                if (txt.includes('percent') && txt != 'percentage schools with missing data') {
                  txt = txt.replace('percent', '(%)');
                }
                txt = txt == 'students count' ? 'student count' : txt;
                if (txt.includes('id')) {
                  txt = txt.replace('id', 'ID');
                  return txt.charAt(0).toUpperCase() + txt.substr(1);
                } else {
                  return toTitleCase(txt);
                }
              })

            + "</b>" + ": " + object[key] + `</span>`;
        }
      }
      popupFood.push(stringLine);
    }
    function toTitleCase(phrase) {
      var key = phrase
        .toLowerCase()
        .split(' ')
        .map(word => word.charAt(0).toUpperCase() + word.slice(1))
        .join(' ');
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

  changeingStringCases(str) {
    return str.replace(
      /\w\S*/g,
      function (txt) {
        return txt.charAt(0).toUpperCase() + txt.substr(1).toLowerCase();
      }
    );
  }

  // google marker initialsation

  initGoogleMapMarker(color, scale, stroke){
    var circleIcon = {
      path: google.maps.SymbolPath.CIRCLE,
     fillColor: color,
     fillOpacity: 1,
     scale: scale,
     strokeColor: 'gray',
     strokeWeight: stroke,
   };
   return circleIcon;
  }
}
