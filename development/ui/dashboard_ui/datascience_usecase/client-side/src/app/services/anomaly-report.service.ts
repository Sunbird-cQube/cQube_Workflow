import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { KeycloakSecurityService } from './../keycloak-security.service';
import { AppServiceComponent } from '../app.service';

@Injectable({
  providedIn: 'root'
})
export class AnomalyReportService {
  public map;
  public baseUrl;
  public token;

  constructor(public http: HttpClient, public keyCloakService: KeycloakSecurityService, public service: AppServiceComponent) {
    this.baseUrl = service.baseUrl;
  }

  //anomaly map...
  anomalyMapDistWise(data) {
    this.service.logoutOnTokenExpire();
    return this.http.post(`${this.baseUrl}/anomalyMap/distWise`, data);
  }
  anomalyMapAllBlockWise(data) {
    this.service.logoutOnTokenExpire();
    return this.http.post(`${this.baseUrl}/anomalyMap/allBlockWise`, data);
  }

  anomalyMapBlockWise(distId, data) {
    this.service.logoutOnTokenExpire();
    return this.http.post(`${this.baseUrl}/anomalyMap/blockWise/${distId}`, data);
  }

  anomalyMapAllClusterWise(data) {
    this.service.logoutOnTokenExpire();
    return this.http.post(`${this.baseUrl}/anomalyMap/allClusterWise`, data);
  }

  anomalyMapClusterWise(distId, blockId, data) {
    this.service.logoutOnTokenExpire();
    return this.http.post(`${this.baseUrl}/anomalyMap/clusterWise/${distId}/${blockId}`, data);
  }

  anomalyMapAllSchoolWise(data) {
    this.service.logoutOnTokenExpire();
    return this.http.post(`${this.baseUrl}/anomalyMap/allSchoolWise`, data);
  }

  anomalyMapSchoolWise(distId, blockId, clusterId, data) {
    this.service.logoutOnTokenExpire();
    return this.http.post(`${this.baseUrl}/anomalyMap/schoolWise/${distId}/${blockId}/${clusterId}`, data);
  }
}
