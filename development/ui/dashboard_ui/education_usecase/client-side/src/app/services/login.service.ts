import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { AppServiceComponent } from '../app.service';

@Injectable({
  providedIn: 'root'
})
export class LoginService {
  public baseUrl;
  constructor(public http: HttpClient, public service: AppServiceComponent) {
    this.baseUrl = service.baseUrl;
  }

  login(user: any) {
    let email = user.username;
    let password = user.password

    return this.http.post(`${this.baseUrl}/login/login`, { email: email, password: password });
  }

  getQRcode(user: any) {
    let email = user.username;
    let password = user.password

    return this.http.post(`${this.baseUrl}/totp/getTotp`, { email: email, password: password });
  }

  getQRverify(otp: any) {
    let totp = otp.otp;
    let secret = otp.secret;
    return this.http.post(`${this.baseUrl}/totpVerify`, { token: totp, secret: secret });
  }

  getLoginPage() {

    return this.http.get('http://localhost:8080/auth/realms/cQube/account');

  }
  getSecret(data) {

    let username = data;

    return this.http.post(`${this.baseUrl}/getSecret`, { username: username });

  }
}
