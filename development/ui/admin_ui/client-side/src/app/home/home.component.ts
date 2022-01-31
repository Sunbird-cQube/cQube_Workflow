import { Component, OnInit } from '@angular/core';
import { environment } from '../../environments/environment'
import { KeycloakSecurityService } from '../keycloak-security.service';
import { NavigationEnd, Router } from '@angular/router';
import { CookieService } from 'ngx-cookie-service';
@Component({
  selector: 'app-home',
  templateUrl: './home.component.html',
  styleUrls: ['./home.component.css']
})
export class HomeComponent implements OnInit {
  public grafanaUrl = environment.grafanaEndPoint;
  public storageType = environment.storageType;
  public listFileName = ""
  logoutVar;
  constructor(public keyCloakService: KeycloakSecurityService, public router: Router, public cookieService: CookieService) {
    this.listFileName = this.storageType == 's3' ? "Download \n S3 Files" : "List \n Local Files"

  }
  email: any;
  role: any;
  showSubmenu1: any = false;
  showsideMenu: boolean = false;
  isExpanded = true;
  showSubmenu: boolean = false;
  isShowing = false;
  showLogs: boolean = true;
  appUrl;

  logNames: any = [];

  ngOnInit() {
    this.appUrl = environment.appUrl;
    this.email = localStorage.getItem('userName');
    this.role = localStorage.getItem('role');
    if (this.role == 1) {
      this.showsideMenu = false;
      this.showLogs = true;
    }
  }
  logout() {
    if (environment.auth_api === 'cqube') {
      localStorage.clear();
      let options = {
        redirectUri: `${this.appUrl}`
      }
      this.keyCloakService.kc.clearToken();
      this.keyCloakService.kc.logout(options);
    } else {
      localStorage.clear();
      this.cookieService.deleteAll();
      window.location.href = `${environment.appUrl}/#/signin`;
    }

  }

  back() {
    window.location.replace(`${this.appUrl}/#/home`);
  }

  mouseenter() {
    if (!this.isExpanded) {
      this.isShowing = true;
    }
  }

  mouseleave() {
    if (!this.isExpanded) {
      this.isShowing = false;
    }
  }

}
