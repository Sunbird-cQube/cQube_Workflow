import { ChangeDetectorRef, Component, OnInit, ViewChild } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { KeycloakSecurityService } from '../../keycloak-security.service';
import { AppServiceComponent } from '../../app.service';
import { environment } from '../../../environments/environment';
import { MediaMatcher } from '@angular/cdk/layout';
import { MatSidenav } from '@angular/material/sidenav';
import { NavigationEnd, Router } from '@angular/router';
import { ThemeService } from 'src/app/services/theme.service';
import { LoginService } from '../../services/login.service'
import { TelemetryService } from 'src/app/services/telemetry.service';
import { dynamicReportService } from 'src/app/services/dynamic-report.service';


@Component({
  selector: 'app-home',
  templateUrl: './home.component.html',
  styleUrls: ['./home.component.css'],
})
export class HomeComponent implements OnInit {

  currentDashboardGroup: any = "/dashboard/infrastructure-dashboard";
  edate: Date;
  public hideChangePass: boolean = environment.auth_api !== 'cqube' ? false : true;
  sidenavMode: any = 'side';

  @ViewChild('sidebar', { static: true }) public sidebar: MatSidenav;
  private _mobileQueryListener: () => void;
  showBackBtn: boolean = false;

  public hideReport: String = environment.mapName

  constructor(public http: HttpClient, public service: AppServiceComponent, public keyCloakService: KeycloakSecurityService,
    private media: MediaMatcher, private changeDetectorRef: ChangeDetectorRef, public router: Router, private themeservice: ThemeService, public logInservice: LoginService, public Test: TelemetryService, public configServic: dynamicReportService) {
    this.mobileQuery = media.matchMedia('(max-width: 600px)');
    this._mobileQueryListener = () => changeDetectorRef.detectChanges();
    this.mobileQuery.addListener(this._mobileQueryListener);
    this.router.events.subscribe(event => {
      if (event instanceof NavigationEnd) {
        this.onToggle();
      }
    })
  }

  email: any;
  role: any;
  showsideMenu: boolean = false;
  isExpanded = true;
  showSubmenu: boolean = false;
  isShowing = false;
  showUser: boolean = true;
  xpandStatus: boolean = false;
  currentURL;
  public userType = localStorage.getItem('roleName') === "admin";
  public roleName;
  mobileQuery: MediaQueryList;
  menuList
  // diksha columns
  diksha_column = "diksha_columns" in environment ? environment["diksha_columns"] : true;

  ngOnInit() {

    this.toggleTheme('defaultTheme');
    this.email = localStorage.getItem('userName');
    this.email = this.email.charAt(0).toUpperCase() + this.email.substr(1).toLowerCase();
    this.role = localStorage.getItem('roleName');
    if (this.role == "admin") {
      this.showsideMenu = false;
      this.showUser = false;
    } else {
      this.showUser = true;
    }
    if (this.role == 'admin') {
      this.showBackBtn = true;
    } else {
      this.showBackBtn = false;
    }
    this.fetchConfigProperty()

  }

  onClickToggleMenu() {
    if (!this.router.url.includes('dashboard') || this.mobileQuery.matches) {
      this.sidebar.toggle();
      setTimeout(() => {
        window.dispatchEvent(new Event('resize'));
      }, 1500);
    }
  }

  onToggle() {
    if (!this.router.url.includes('dashboard') || this.mobileQuery.matches) {
      this.sidenavMode = 'over';
      setTimeout(() => {
        window.dispatchEvent(new Event('resize'));
        if (!this.router.url.includes('dashboard') || this.mobileQuery.matches) {
          this.sidebar.close();
        }
      }, 1000);
    } else {
      this.sidenavMode = 'side';
      this.sidebar.open();
      document.getElementById("sidenav-container").style.backgroundColor = "--theme-bg-container-color";
    }
  }

  closeSidebar() {
    document.body.scrollTop = 0;
    if (!this.router.url.includes('dashboard') && this.sidebar) {
      this.sidebar.close();
    }
  }

 
  logout() {
    if (environment.auth_api === 'cqube') {
      localStorage.clear();
      this.clearSessionStorage();
      let options = {
        redirectUri: environment.appUrl
      }
      sessionStorage.clear();
      this.keyCloakService.kc.clearToken();
      this.keyCloakService.kc.logout(options);
    } else {

      if (localStorage.getItem('role') === 'admin') {
        let refreshToken = localStorage.getItem('refToken')


        this.logInservice.logout(localStorage.getItem('refToken')).subscribe(res => {
          localStorage.clear();
          this.router.navigate(['/signin'])
        })
      } else {
        localStorage.clear();
        this.router.navigate(['/signin'])
      }
    }

  }

  fetchConfigProperty() {
    this.configServic.configurableProperty().subscribe(res => {
      if (res['data']) {
        document.getElementById('spinner').style.display = "none"
      }
      this.menuList = res['data']
   
      
    },(err)=> {
      this.menuList = []
    })
  }

  fetchTelemetry(event, report) {
    this.service.getTelemetryData(report, event.type);
  }

  clearSessionStorage(): void {
    sessionStorage.clear();
  }

  onBackClick() {
    localStorage.removeItem('managements');
    localStorage.removeItem('management');
    localStorage.removeItem('category');
  }

  sccessProgressCard() {
    this.service.setProgressCardValue(true);
  }

  setCurrentDashboardGroup(route) {
    this.currentDashboardGroup = route;
  }


  toggleTheme(colorCode) {
    this.themeservice.setTheme(colorCode);
  }
}