import { Component, AfterViewInit, ViewChild, ElementRef, OnInit } from "@angular/core";
import { HttpClient } from '@angular/common/http';
import { environment } from '../environments/environment';
let map, popup, Popup;


@Component({
  selector: "app-root",
  templateUrl: "./app.component.html",
  styleUrls: ["./app.component.css"]
})
export class AppComponent implements AfterViewInit, OnInit {
  @ViewChild("mapContainer", { static: false }) gmap: ElementRef;
  constructor(public http: HttpClient) {

  }
  map: google.maps.Map;
  lat = 22.3660414123535;
  lng = 71.48396301269531;
  circleIcon = {
    path: google.maps.SymbolPath.CIRCLE,
    fillColor: 'red',
    fillOpacity: 1,
    scale: 1,
    strokeColor: 'gray',
    strokeWeight: 0.5,
  };

  tooltiponclcik = 'Company Name :  1  , <br> ' + 'Sales Off Name :  2  , <br>' + 'Warehouse Name :  3 ';

  markers = [];
  ngOnInit() {

  }

  //   attendance: 85.7
  // block_id: 240101
  // block_name: "Lakhapat"
  // district_id: 2401
  // district_name: "Kachchh"
  // lat: 23.636197222
  // lng: 68.754551929
  // number_of_schools: "11"
  // number_of_students: "1,367"



  //Coordinates to set the center of the map
  coordinates = new google.maps.LatLng(this.lat, this.lng);

  getAllMarkers() {
    document.getElementById('spinner').style.display = "block";
    this.http.post(environment.apiRoute, {
      category: "overall",
      management: environment.management,
      month: null,
      period: "overall",
      year: null
    }).subscribe(res => {
      res['schoolData'].map(item => {
        this.circleIcon.fillColor = "green";
        let tooltip = `School Name: ${item.school_name} <br>
                        Cluster Name: ${item.cluster_name} <br>
                        Block Name: ${item.block_name} <br>
                      District Name: ${item.district_name} <br>
                      Attendance %: ${item.attendance}`
        let marker = {
          position: new google.maps.LatLng(item.lat, item.lng),
          title: tooltip,
          icon: this.circleIcon,
          zIndex: 4000
        }
        this.loadAllMarkers(marker);
        this.markers.push(marker);
      });
      // this.coordinates = new google.maps.LatLng(res['blockData'][0].lat, res['blockData'][0].lng);
      if (this.markers .length == res['schoolData'].length) {
        document.getElementById('spinner').style.display = "none";
      }
    })
  }

  mapOptions: google.maps.MapOptions = {
    center: this.coordinates,
    zoom: 7,
    panControl: false,
    zoomControl: false,
    mapTypeControl: false,
    scaleControl: true,
    streetViewControl: false,
    rotateControl: false,
    fullscreenControl: false
  };

  ngAfterViewInit(): void {
    this.mapInitializer();
  }

  mapInitializer(): void {
    this.map = new google.maps.Map(this.gmap.nativeElement, this.mapOptions);
    this.getAllMarkers();
  }

  loadAllMarkers(markerInfo): void {
    //Creating a new marker object
    const marker = new google.maps.Marker({
      ...markerInfo
    });

    //creating a new info window with markers info
    const infoWindow = new google.maps.InfoWindow({
      content: marker.getTitle()
    });
    // inf
    //Add click event to open info window on marker
    marker.addListener("mouseover", () => {
      infoWindow.open(marker.getMap(), marker);
    });

    marker.addListener("mouseout", () => {
      infoWindow.close();
    });

    google.maps.event.addListener(marker, 'mouseover', function (e) {
    });

    marker.addListener("click", (event) => {
      const infoWindow = new google.maps.InfoWindow({
        content: marker.getTitle()
      });
    });

    //Adding marker to google map
    marker.setMap(this.map);
  }
}