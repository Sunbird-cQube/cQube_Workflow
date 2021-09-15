import { Component, OnInit } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { KeycloakSecurityService } from '../../keycloak-security.service';
import { AppServiceComponent } from '../../app.service';
import { environment } from '../../../environments/environment';

@Component({
  selector: 'app-home',
  templateUrl: './home.component.html',
  styleUrls: ['./home.component.css'],
})
export class HomeComponent implements OnInit {
  edate: Date;
  // semester = true;

  constructor(public http: HttpClient, public service: AppServiceComponent, public keyCloakService: KeycloakSecurityService) { }
  email: any;
  role: any;
  showSubmenu1: any = false;
  showSubmenu2: any = false;
  showSubmenu3: any = false;
  showSubmenu4: any = false;
  showSubmenu5: any = false;
  showSubmenu6: any = false;
  showSubmenu7: any = false;
  showSubmenu8: any = false;
  showSubmenu9: any = false;
  showsideMenu: boolean = false;
  isExpanded = true;
  showSubmenu: boolean = false;
  isShowing = false;
  showUser: boolean = true;
  currentURL;
  public userType = localStorage.getItem('roleName') === "admin";
  public roleName;

  // diksha columns
  diksha_column = 'diksha_columns' in environment ? environment['diksha_columns'] : true

  //for coming soon page
  crc;
  attendance;
  semester;
  infra;
  diksha;
  telemetry;
  udise;
  pat;
  composite;
  sat;


  ngOnInit() {
    this.changeDataSourceStatus();
    this.email = localStorage.getItem('userName');
    this.email = this.email.charAt(0).toUpperCase() + this.email.substr(1).toLowerCase();
    this.role = localStorage.getItem('roleName');
    if (this.role == "admin") {
      this.showsideMenu = false;
      this.showUser = false;
    } else {
      this.showUser = true;
    }

  }

  changeDataSourceStatus() {
    this.service.getDataSource().subscribe((res: any) => {
      res.forEach(element => {
        if (element.template == 'crc') {
          this.crc = element.status;
        }
        if (element.template == 'attendance') {
          this.attendance = element.status;
        }
        if (element.template == 'semester') {
          this.semester = element.status;
        }
        if (element.template == 'infra') {
          this.infra = element.status;
        }
        if (element.template == 'diksha') {
          this.diksha = element.status;
        }
        if (element.template == 'telemetry') {
          this.telemetry = element.status;
        }
        if (element.template == 'udise') {
          this.udise = element.status;
        }
        if (element.template == 'pat') {
          this.pat = element.status;
        }
        if (element.template === 'composite') {
          this.composite = element.status;
        }
        if (element.template === 'sat') {
          this.sat = element.status;
        }
      });
    })
  }

  logout() {
    localStorage.clear();
    this.clearSessionStorage();
    let options = {
      redirectUri: environment.appUrl
    }
    sessionStorage.clear();
    this.keyCloakService.kc.clearToken();
    this.keyCloakService.kc.logout(options);
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

  fetchTelemetry(event, report) {
    this.service.getTelemetryData(report, event.type);
  }

  clearSessionStorage(): void {
    sessionStorage.clear();
  }

  onBackClick() {
    localStorage.removeItem('management');
    localStorage.removeItem('category');
  }
}