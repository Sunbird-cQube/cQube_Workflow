import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { KeycloakSecurityService } from './../keycloak-security.service';
import { AppServiceComponent } from '../app.service';

@Injectable({
  providedIn: 'root'
})
export class DikshaMapReportsService {
  public map;
  public baseUrl;
  public token;

  constructor(public http: HttpClient, public keyCloakService: KeycloakSecurityService, public service: AppServiceComponent) {
    this.baseUrl = service.baseUrl;
  }

  
  tpdDistWise() {
    this.service.logoutOnTokenExpire();
    return this.http.post(`${this.baseUrl}/tpdMap/allDistData`, null);
  }

  etbDistWise() {
    this.service.logoutOnTokenExpire();
    return this.http.post(`${this.baseUrl}/etbMap/allDistData`, null);
  }
}
