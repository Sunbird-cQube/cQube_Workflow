import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { environment } from '../../src/environments/environment';
import { KeycloakSecurityService } from './keycloak-security.service';
import { ActivatedRoute, Router } from '@angular/router';
@Injectable({
    providedIn: 'root'
})
export class AppService {

    public baseUrl = environment.apiEndpoint;
    public token;

    constructor(public http: HttpClient, public keyCloakService: KeycloakSecurityService, private route: ActivatedRoute,
        private router: Router) {
        if (environment.auth_api === 'cqube') {
            this.token = keyCloakService.kc.token;
            localStorage.setItem('token', this.token);
        }

    }

    tokenExpired(token: string) {
        let dateNow = new Date();
        const expiry = (JSON.parse(atob(token.split('.')[1]))).exp;

        return (Math.round(dateNow.getTime() / 1000)) >= expiry;
    }


    logoutOnTokenExpire() {
        if (environment.auth_api === 'cqube') {
            if (this.keyCloakService.kc.isTokenExpired() == true) {
                // alert("Session expired, Please login again!");
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
                this.router.navigate(['/signin'])
            }
        }

    }

}