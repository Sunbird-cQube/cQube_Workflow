import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { AppServiceComponent } from '../app.service';


@Injectable({
  providedIn: 'root'
})
export class GetQRcodeService {
  public baseUrl;
  constructor(public http: HttpClient, public service: AppServiceComponent) {
    this.baseUrl = service.baseUrl;
  }


  getQRcode(user: any) {
    let email = user.username;
    let password = user.password

    return this.http.post(`${this.baseUrl}/totp/totpVerify`, { email: email, password: password });
  }



}
