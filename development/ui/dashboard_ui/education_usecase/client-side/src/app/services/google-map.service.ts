import { ElementRef, Injectable, ViewChild } from '@angular/core';

let map, popup, Popup;
@Injectable({
  providedIn: 'root'
})
export class GoogleMapService {
  // @ViewChild("sarMap", { static: false }) gmap: ElementRef;

  //  map: google.maps.Map;
  //  lat: '';
  //  lng:'';
  constructor() { }
  onMouseOver(infoWindow, $event: MouseEvent) {
    infoWindow.open();

  }

onMouseOut(infoWindow, $event: MouseEvent) {
    infoWindow.close();
}
  
}
