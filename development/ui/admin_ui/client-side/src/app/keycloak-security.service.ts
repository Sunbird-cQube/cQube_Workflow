import { Injectable } from '@angular/core';
import { KeycloakInstance } from 'keycloak-js';
import { ActivatedRoute, Router } from '@angular/router'
import { environment } from '../../src/environments/environment';
import { UsersService } from '../app/services/users.service'
import { HttpClient } from '@angular/common/http';
declare var Keycloak: any;

@Injectable({
  providedIn: 'root'
})
export class KeycloakSecurityService {
  public kc: KeycloakInstance;
  public baseUrl = environment.apiEndpoint;
  constructor(public router: Router, public activtedRoute: ActivatedRoute, public http: HttpClient ) { }

  async init() {
    if (environment.auth_api === 'cqube') {
      this.kc = new Keycloak({
        url: environment.keycloakUrl,
        realm: environment.realm,
        clientId: environment.clientId,
        // credentials: environment.credentials
      });
      await this.kc.init({
        onLoad: 'login-required',
        checkLoginIframe: false
      });
      localStorage.setItem('user_id', this.kc.tokenParsed.sub);
      localStorage.setItem('userName', this.kc.tokenParsed['preferred_username']);
    } else {
      this.activtedRoute.queryParams.subscribe( async params => {
        
        if (params['userid']) {
           
          let userifoResponse = await this.http.get(`${this.baseUrl}/getUserdetails/${params['userid']}`).toPromise();
         
         
          if (userifoResponse['status'] === 200 && userifoResponse['userObj']) {
            localStorage.setItem('user_id', userifoResponse['userObj'].userid);
              localStorage.setItem('roleName', userifoResponse['userObj'].roleName);
              localStorage.setItem('userName', userifoResponse['userObj'].userName);
              localStorage.setItem('token', userifoResponse['userObj'].token);

            } 
           this.router.navigate(['admin-dashboard'])
          
        }
      })
     
    }
  }

}
