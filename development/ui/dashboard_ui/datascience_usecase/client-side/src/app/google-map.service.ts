import { HttpClient } from '@angular/common/http';
import { Injectable } from '@angular/core';

@Injectable({
  providedIn: 'root'
})
export class GoogleMapService {

  googleApiKey;
  constructor(public http: HttpClient) {
    this.googleApiKey = "";
  }
}
