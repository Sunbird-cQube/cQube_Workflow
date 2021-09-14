import { HttpClient } from '@angular/common/http';
import { Injectable } from '@angular/core';
import { AppService } from '../app.service';
import { environment } from '../../../src/environments/environment';
import { KeycloakSecurityService } from '../keycloak-security.service';

@Injectable({
  providedIn: 'root'
})
export class DataReplayService {
  public baseUrl = environment.apiEndpoint;
  constructor(public http: HttpClient, public keyCloakService: KeycloakSecurityService, private service: AppService) { }

  getDataSources() {
    this.service.logoutOnTokenExpire();
    return this.http.get(`${this.baseUrl}/getDataSource`);
  }

  getMonthYear(data) {
    this.service.logoutOnTokenExpire();
    return this.http.post(`${this.baseUrl}/getMonthYear`, data);
  }

  getSemesters() {
    this.service.logoutOnTokenExpire();
    return this.http.post(`${this.baseUrl}/getSemesters`, {});
  }

  getBatchIds() {
    this.service.logoutOnTokenExpire();
    return this.http.post(`${this.baseUrl}/getBatchIds`, {});
  }

  getExamCode() {
    this.service.logoutOnTokenExpire();
    return this.http.post(`${this.baseUrl}/getExamCode`, {});
  }


  saveDataToS3(data) {
    this.service.logoutOnTokenExpire();
    return this.http.post(`${this.baseUrl}/savetoS3`, data);
  }



}
