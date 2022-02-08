import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { environment } from '../../src/environments/environment';
import { KeycloakSecurityService } from './keycloak-security.service';
import { Router } from '@angular/router';

@Injectable({
    providedIn: 'root'
})
export class AppService {

    public baseUrl = environment.apiEndpoint;
    public token;

    constructor(public http: HttpClient, public keyCloakService: KeycloakSecurityService, public router: Router
    ) {
        if (environment.auth_api === 'cqube') {
            this.token = keyCloakService.kc.token;
            localStorage.setItem('token', this.token);
        }

    }

    tokenExpired(token: string) {
        let dateNow = new Date();
        const expiry = token !== 'undefined' && token ? (JSON.parse(atob(token.split('.')[1]))).exp : false;
        return (Math.round(dateNow.getTime() / 1000)) >= expiry;
    }


    logoutOnTokenExpire() {
        if (environment.auth_api === 'cqube') {
            if (this.keyCloakService.kc.isTokenExpired() == true) {

                let options = {
                    redirectUri: environment.appUrl
                }
                this.keyCloakService.kc.logout(options);
            }
        } else {

            if (this.tokenExpired(localStorage.getItem('token'))) {
                localStorage.removeItem("management");
                localStorage.removeItem("category");
                sessionStorage.clear();
                localStorage.removeItem('roleName')
                localStorage.removeItem('token')

            }
        }

    }



}