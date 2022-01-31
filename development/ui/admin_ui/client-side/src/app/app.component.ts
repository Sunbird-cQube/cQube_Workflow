import { Component, OnInit } from '@angular/core';
import { KeycloakSecurityService } from './keycloak-security.service';
import { Router } from '@angular/router';
import { environment } from 'src/environments/environment';
import { CookieService } from 'ngx-cookie-service';
@Component({
  selector: 'app-root',
  templateUrl: './app.component.html',
  styleUrls: ['./app.component.css']
})
export class AppComponent implements OnInit {
  title = "";

  constructor(public keycloakService: KeycloakSecurityService, public router: Router, public cookieService: CookieService) {
    if (environment.auth_api === 'cqube') {
      if (this.keycloakService.kc.tokenParsed.realm_access) {
        if (!this.keycloakService.kc.tokenParsed.realm_access.roles.includes('admin')) {
          localStorage.setItem('roleName', 'admin');
          alert("Only admin has access to admin console");
          let options = {
            redirectUri: environment.appUrl
          }
          window.location.href = environment.appUrl;
        }
      }
    } else {

      const storage = this.cookieService.getAll()
      localStorage.setItem('userid', storage['userid'])
      localStorage.setItem('roleName', storage['roleName'])
      localStorage.setItem('userName', storage['userName'])
      localStorage.setItem('token', storage['token'])
    }


  }

  ngOnInit() {

  }
}