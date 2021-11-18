import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { KeycloakSecurityService } from '../keycloak-security.service';
import { AppServiceComponent } from '../app.service';

@Injectable({
  providedIn: 'root'
})
export class ContentUsagePieService {
  public baseUrl;
  
  constructor(public http: HttpClient, public keyCloakService: KeycloakSecurityService, public service: AppServiceComponent) {
    this.baseUrl = service.baseUrl;
  }

  // Diksha pie chart apis
  dikshaPieState() {
    this.service.logoutOnTokenExpire();
    return this.http.get(`${this.baseUrl}/diksha/contentUsage/stateData`);
  }

  dikshaPieDist(){
    this.service.logoutOnTokenExpire();
    return this.http.get(`${this.baseUrl}/diksha/contentUsage/distWise`);
  }
  diskshaPieMeta(){
    this.service.logoutOnTokenExpire();
    return this.http.get(`${this.baseUrl}/diksha/contentUsage/distMeta`);
  }
}
