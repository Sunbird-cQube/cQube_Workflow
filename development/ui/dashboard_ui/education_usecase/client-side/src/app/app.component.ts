import { Component, OnDestroy, OnInit } from '@angular/core';
import { KeycloakSecurityService } from './keycloak-security.service';
import { environment } from 'src/environments/environment';

@Component({
  selector: 'app-root',
  templateUrl: './app.component.html',
  styleUrls: ['./app.component.css']
})
export class AppComponent implements OnDestroy, OnInit {
  ngOnDestroy() {
    sessionStorage.clear();
  }
  constructor(public keycloakService: KeycloakSecurityService) { }
  ngOnInit() {
    if (environment.auth_api === 'cQube') {
      if (this.keycloakService.kc.tokenParsed.realm_access.roles.includes('admin')) {
        localStorage.setItem('roleName', 'admin');
      } else if (this.keycloakService.kc.tokenParsed.realm_access.roles.includes('report_viewer')) {
        localStorage.setItem('roleName', 'report_viewer');
      }
    }

  }
}