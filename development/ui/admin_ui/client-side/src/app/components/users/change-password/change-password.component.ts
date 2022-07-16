import { Component, OnInit } from '@angular/core';
import { UsersService } from '../../../services/users.service';
import { Router } from '@angular/router';
import { NgForm } from '@angular/forms';
import { KeycloakSecurityService } from '../../../keycloak-security.service';
import { environment } from 'src/environments/environment';
import { HomeComponent } from "../../../home/home.component";
import { CookieService } from 'ngx-cookie-service';

declare const $;

@Component({
  selector: 'app-change-password',
  templateUrl: './change-password.component.html',
  styleUrls: ['./change-password.component.css']
})
export class ChangePasswordComponent implements OnInit {
  public changePasswdData: any = {};
  public err;
  public successMsg;
  public isDisabled;
  otpConfig = environment.report_viewer_config_otp;
  public userName = localStorage.getItem('userName')
  public otpToggle = this.userName !== 'admin' ? true : false

  roleIds: any = [];

  constructor(public service: UsersService, public router: Router, public keycloakService: KeycloakSecurityService, cookieService: CookieService) {
    this.changePasswdData['userName'] = localStorage.getItem('userName');

  }

  ngOnInit() {
    document.getElementById('backBtn').style.display = "none";
    document.getElementById('homeBtn').style.display = "Block";

  }
  logout() {

    localStorage.clear();

    window.location.href = `${environment.appUrl}/#/signin`;
  }

  onSubmit(formData: NgForm) {

    document.getElementById('spinner').style.display = 'block';
    this.isDisabled = false;
    if (this.changePasswdData.userName === localStorage.getItem('userName')) {
      if (this.changePasswdData.newPasswd != this.changePasswdData.cnfpass) {
        this.err = "Password not matched";
        document.getElementById('spinner').style.display = 'none';
      } else {
        this.service.changePassword(this.changePasswdData, localStorage.getItem('user_id')).subscribe(res => {
          document.getElementById('success').style.display = "Block";
          this.err = '';
          this.successMsg = res['msg'] + "\n" + " please login again...";
          document.getElementById('spinner').style.display = 'none';
          this.isDisabled = true;
          formData.resetForm();
          setTimeout(() => {
            if (environment.auth_api === 'state') {
              this.logout()
            }
          }, 2000)

          setTimeout(() => {
            localStorage.clear();
            let options = {
              redirectUri: environment.appUrl
            }
            this.keycloakService.kc.logout(options);
          }, 2000);
        }, err => {
          this.err = "Something went wrong"
          document.getElementById('spinner').style.display = 'none';
        })
      }

    } else {
      this.err = "Invalid User";
      document.getElementById('spinner').style.display = 'none';
    }
  }

}
