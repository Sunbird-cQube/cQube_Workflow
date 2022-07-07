import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { KeycloakSecurityService } from './../keycloak-security.service';
import { AppServiceComponent } from '../app.service';

@Injectable({
    providedIn: 'root'
})
export class dynamicReportService {
    public map;
    public baseUrl;

    constructor(public http: HttpClient, public keyCloakService: KeycloakSecurityService, public service: AppServiceComponent) {
        this.baseUrl = service.baseUrl;
    }

    // dynamic new apis
    dynamicDistData(data) {
        this.service.logoutOnTokenExpire();
        return this.http.post(`${this.baseUrl}/common/distWise`, data);
    }    
    
    dynamicBlockData(data) {
        this.service.logoutOnTokenExpire();
        return this.http.post(`${this.baseUrl}/common/blockWise`, data);
    }

    dynamicClusterData(data) {
        this.service.logoutOnTokenExpire();
        return this.http.post(`${this.baseUrl}/common/clusterWise`, data);
    }

    dynamicSchoolData(data) {
        this.service.logoutOnTokenExpire();
        return this.http.post(`${this.baseUrl}/common/distWise`, data);
    }

    configurableProperty(){
        this.service.logoutOnTokenExpire();
        return this.http.post(`${this.baseUrl}/configProperties`,{});
    }
    configurableCardProperty() {
        this.service.logoutOnTokenExpire();
        return this.http.post(`${this.baseUrl}/configCardProperties`, {});
    }
}
