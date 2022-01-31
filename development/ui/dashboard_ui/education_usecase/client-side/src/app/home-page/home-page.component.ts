import { Component, OnInit, ViewEncapsulation } from '@angular/core';
import { KeycloakSecurityService } from '../keycloak-security.service';
import { environment } from 'src/environments/environment';
import { Router } from '@angular/router';
import { AppServiceComponent } from '../app.service';
import { CookieService } from 'ngx-cookie-service'
@Component({
  selector: 'app-home-page',
  templateUrl: './home-page.component.html',
  styleUrls: ['./home-page.component.css'],
  encapsulation: ViewEncapsulation.Emulated
})
export class HomePageComponent implements OnInit {
  adminUrl;
  adminDashUrl;
  role;
  storage
  hideAdmin
  constructor(public keycloakService: KeycloakSecurityService, public router: Router, public service: AppServiceComponent, public cookieService: CookieService) {
    service.logoutOnTokenExpire();
  }

  ngOnInit(): void {
    this.adminUrl = environment.adminUrl;
    this.storage = window.localStorage;
    this.hideAdmin = environment.auth_api === 'cqube' ? true : false;
    if (localStorage.getItem('roleName') != 'admin') {
      this.router.navigate(['/home']);
    }
    if (environment.auth_api === 'cqube') {
      if (this.keycloakService.kc.tokenParsed.realm_access) {
        if (this.keycloakService.kc.tokenParsed.realm_access.roles.includes('admin')) {
          localStorage.setItem('roleName', 'admin');
          this.router.navigate(['/home']);
        } else if (this.keycloakService.kc.tokenParsed.realm_access.roles.includes('report_viewer')) {
          localStorage.setItem('roleName', 'report_viewer');
          this.router.navigate(['/dashboard/infrastructure-dashboard']);
        } else {
          if (!this.keycloakService.kc.tokenParsed.realm_access.roles.includes('report_viewer')
            || !this.keycloakService.kc.tokenParsed.realm_access.roles.includes('admin')) {
            alert("Unauthorised user, Only admin and viewer can login")
            let options = {
              redirectUri: environment.appUrl
            }
            this.keycloakService.kc.logout(options);
          }
        }
      } else {
        alert("Please assign role to user");
        let options = {
          redirectUri: environment.appUrl
        }
        sessionStorage.clear();
        this.keycloakService.kc.clearToken();
        this.keycloakService.kc.logout(options);
      }
    } else {
      this.role = localStorage.getItem('role')
      this.router.navigate(['/home']);

    }
  }

  logout() {
    if (environment.auth_api === 'cqube') {
      localStorage.clear();
      let options = {
        redirectUri: environment.appUrl
      }
      this.keycloakService.kc.clearToken();
      this.keycloakService.kc.logout(options);
    } else {
      localStorage.clear();
      this.router.navigate(['signin'])
    }
  }


  test() {
    this.cookieService.set('userid', localStorage.getItem('userid'))
    this.cookieService.set('roleName', localStorage.getItem('roleName'))
    this.cookieService.set('userName', localStorage.getItem('userName'))
    this.cookieService.set('token', localStorage.getItem('token'))
    window.location.href = `${environment.adminUrl}/#/admin_dashboard`;

  }

}
