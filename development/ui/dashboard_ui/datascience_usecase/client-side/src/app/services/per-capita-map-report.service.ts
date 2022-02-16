import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { KeycloakSecurityService } from './../keycloak-security.service';
import { AppServiceComponent } from '../app.service';

@Injectable({
  providedIn: 'root'
})
export class PerCapitaMapReport {
  public map;
  public baseUrl;
  public token;

  constructor(public http: HttpClient, public keyCloakService: KeycloakSecurityService, public service: AppServiceComponent) {
    this.baseUrl = service.baseUrl;
  }

  perCapitaState() {
    this.service.logoutOnTokenExpire();
    return this.http.post(`${this.baseUrl}/perCapita/allDistData`, null);
  }
}
