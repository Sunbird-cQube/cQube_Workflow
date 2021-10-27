import { HttpClient } from '@angular/common/http';
import { Injectable } from '@angular/core';
import { environment } from 'src/environments/environment';
import { AppService } from '../app.service';
import { KeycloakSecurityService } from '../keycloak-security.service';

@Injectable({
  providedIn: 'root'
})
export class DikshaConfigService {

  public baseUrl = environment.apiEndpoint;
  constructor(public http: HttpClient, public keyCloakService: KeycloakSecurityService, private service: AppService) { }

  dikshaTPD_ETB_data_input(data) {
    this.service.logoutOnTokenExpire();
    return this.http.post(`${this.baseUrl}/dikshaTPD_ETB_data_input`, data);
  }

  dikshaConfigService(data) {
    this.service.logoutOnTokenExpire();
    return this.http.post(`${this.baseUrl}/dikshaConfig`, data);
  }
}
