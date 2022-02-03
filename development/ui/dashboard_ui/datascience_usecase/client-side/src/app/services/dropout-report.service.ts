import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { KeycloakSecurityService } from './../keycloak-security.service';
import { AppServiceComponent } from '../app.service';

@Injectable({
  providedIn: 'root'
})
export class DropoutReportService {
  public map;
  public baseUrl;
  public token;

  constructor(public http: HttpClient, public keyCloakService: KeycloakSecurityService, public service: AppServiceComponent) {
    this.baseUrl = service.baseUrl;
  }

  //dropout map...
  dropoutMapDistWise(data) {
    this.service.logoutOnTokenExpire();
    return this.http.post(`${this.baseUrl}/dropoutMap/distWise`, data);
  }
  dropoutMapAllBlockWise(data) {
    this.service.logoutOnTokenExpire();
    return this.http.post(`${this.baseUrl}/dropoutMap/allBlockWise`, data);
  }

  dropoutMapBlockWise(distId, data) {
    this.service.logoutOnTokenExpire();
    return this.http.post(`${this.baseUrl}/dropoutMap/blockWise/${distId}`, data);
  }

  dropoutMapAllClusterWise(data) {
    this.service.logoutOnTokenExpire();
    return this.http.post(`${this.baseUrl}/dropoutMap/allClusterWise`, data);
  }

  dropoutMapClusterWise(distId, blockId, data) {
    this.service.logoutOnTokenExpire();
    return this.http.post(`${this.baseUrl}/dropoutMap/clusterWise/${distId}/${blockId}`, data);
  }

  dropoutMapAllSchoolWise(data) {
    this.service.logoutOnTokenExpire();
    return this.http.post(`${this.baseUrl}/dropoutMap/allSchoolWise`, data);
  }

  dropoutMapSchoolWise(distId, blockId, clusterId, data) {
    this.service.logoutOnTokenExpire();
    return this.http.post(`${this.baseUrl}/dropoutMap/schoolWise/${distId}/${blockId}/${clusterId}`, data);
  }

}

