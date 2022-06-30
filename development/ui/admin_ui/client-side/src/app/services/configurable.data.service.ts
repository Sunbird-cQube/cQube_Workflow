import { HttpClient } from '@angular/common/http';
import { Injectable } from '@angular/core';
import { AppService } from '../app.service';
import { environment } from '../../../src/environments/environment';
import { KeycloakSecurityService } from '../keycloak-security.service';

@Injectable({
    providedIn: 'root'
})
export class ConfigurableData {
    public baseUrl = environment.apiEndpoint;
    constructor(public http: HttpClient, public keyCloakService: KeycloakSecurityService, private service: AppService) { }

    getConfigDataSource(){
        this.service.logoutOnTokenExpire();
        return this.http.get(`${this.baseUrl}/listDataSource`)
    }

    buildAngular(data) {
        this.service.logoutOnTokenExpire();
        return this.http.post(`${this.baseUrl}/buildUI`, data)
    }
}
