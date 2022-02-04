import { Component, OnInit, ViewEncapsulation } from '@angular/core';
import { FormBuilder, FormGroup, Validators } from '@angular/forms';
import { ActivatedRoute, Router } from '@angular/router';
import { LoginService } from '../services/login.service';
import { GetQRcodeService } from '../services/get-qrcode.service'
import { environment } from '../../environments/environment'
import { AppServiceComponent } from '../app.service'

declare let $
@Component({
  selector: 'app-signin',
  templateUrl: './signin.component.html',
  styleUrls: ['./signin.component.css'],
  encapsulation: ViewEncapsulation.Emulated
})
export class SigninComponent implements OnInit {

  loginForm!: FormGroup;
  otpForm!: FormGroup;
  passwordForm!: FormGroup
  loading = false;
  submitted = false;
  adminUserId = '';
  public tempSecret: '';

  constructor(private formBuilder: FormBuilder,
    private route: ActivatedRoute,
    private router: Router,
    public service: LoginService,
    public commonService: AppServiceComponent) { }

  ngOnInit(): void {

    this.loginForm = this.formBuilder.group({
      username: ['', Validators.required],
      password: ['', Validators.required]
    });
    this.otpForm = this.formBuilder.group({
      otp: ['', Validators.required],
      secret: ['', Validators.required]
    })


    this.passwordForm = this.formBuilder.group({
      username: ['', Validators.required],
      newPassword: ['', Validators.required],
      cnfpass: ['', Validators.required]
    })
  }

  onChange(el) {
    if (el.target.value.length > 0) {
      document.getElementById("togglePassword").style.display = 'block';
    } else {
      document.getElementById("togglePassword").style.display = 'none';
    }
  }

  myFun(el) {
    if (this.loginForm.valid) {
      document.getElementById("login").style.backgroundColor = "#31D08C";
      document.getElementById("login").style.color = "white";
      document.getElementById("signinSymbol").style.display = "none";
      document.getElementById("signinSymbolWithInput").style.display = "block";
    } else {
      document.getElementById("login").style.color = "#899BFF";
      document.getElementById("login").style.backgroundColor = "transparent";
      document.getElementById("signinSymbol").style.display = "block";
      document.getElementById("signinSymbolWithInput").style.display = "none";
    }
  }
  public togglePassword: boolean = false;
  test(el) {
    this.togglePassword = !this.togglePassword
    $("#togglePassword").toggleClass('fa-eye-slash');
  }
  // convenience getter for easy access to form fields
  get f() {
    return this.loginForm.controls;
  }

  public wrongCredintional: boolean = false;
  public errorMsg = '';
  public otpUrl: any

  public userName = ''
  public userStatus = ''
  public qrcode

  onSubmit() {
    this.submitted = true;

    // stop here if form is invalid
    if (this.loginForm.invalid) {
      return;
    }




    this.service.login(this.loginForm.value).subscribe(res => {
      this.wrongCredintional = false;
      let response = res
      this.userName = res['username']
      this.adminUserId = res['userId']
      this.userStatus = res['status']
      if (this.userStatus === 'true') {
        this.tempSecret = ''
        // ++++ custom qr code for 2FA
        this.service.getQRcode(this.loginForm.value).subscribe(res => {
          this.otpUrl = res
          this.qrcode = res['dataURL']
          this.tempSecret = res['tempSecret'];
        })
      }
      if (response['role'] === 'report_viewer') {
        let role = res['role'];
        let token = res['token'];
        let username = res['username'];
        let userId = res['userId']

        localStorage.setItem('roleName', role);
        localStorage.setItem('token', token);
        localStorage.setItem('userName', username);
        localStorage.setItem('userid', userId)
        this.router.navigate(['/dashboard/infrastructure-dashboard'])
      } else if (response['role'] === 'admin' && this.userName !== environment.keycloak_adm_user) {
        let role = res['role'];
        let token = res['token'];
        let username = res['username'];
        let userId = res['userId']
        document.getElementById("otp-container").style.display = "block";
        document.getElementById("kc-form-login1").style.display = "none";
        localStorage.setItem('roleName', role);
        localStorage.setItem('token', token);
        localStorage.setItem('userName', username);
        localStorage.setItem('userid', userId)
      } else if (response['role'] === 'admin' && this.userName === environment.keycloak_adm_user) {
        let role = res['role'];
        let token = res['token'];
        let username = res['username'];
        let userId = res['userId']
        if (this.userStatus === "true") {
          document.getElementById("otp-container").style.display = "none";
          document.getElementById("kc-form-login1").style.display = "none";
          document.getElementById("updatePassword").style.display = "block";
          localStorage.setItem('roleName', role);
          localStorage.setItem('token', token);
          localStorage.setItem('userName', username);
          localStorage.setItem('userid', userId)
        } else if (this.userStatus !== "true") {
          localStorage.setItem('roleName', role);
          localStorage.setItem('token', token);
          localStorage.setItem('userName', username);
          localStorage.setItem('userid', userId);
          this.router.navigate(['home'])
        }

      }


    }, err => {
      this.wrongCredintional = true;
      this.errorMsg = err.error.errMsg;

    })


  }




  public otpStatus: any

  verifyQRCOde() {
    if (this.userStatus === 'true') {
      this.service.getQRverify(this.otpForm.value).subscribe(res => {
        this.otpStatus = res
        if (res['status'] === 200) {

          document.getElementById("otp-container").style.display = "none";
          document.getElementById("qr-code").style.display = "none"
          document.getElementById("updatePassword").style.display = "block";
          document.getElementById("kc-form-login1").style.display = "none";

        }

      }, err => {
        this.wrongCredintional = true;
        this.errorMsg = err.error.errMsg;

      })

    } else if (this.userStatus !== 'true') {

      this.service.getSecret(this.userName).subscribe(res => {

        if (res['status'] === 200) {
          let otpSecret = res['secret']
          let data = {
            secret: otpSecret,
            otp: this.otpForm.value.otp

          }
          this.service.getQRverify(data).subscribe(res => {
            this.otpStatus = res
            if (res['status'] === 200) {
              this.router.navigate(['home'])
            }

          })

        }
      })
    }

  }

  changePasswordStatus: any
  err: any

  changePassword() {
    let data = {
      cnfpass: this.passwordForm.value.cnfpass,
      username: this.passwordForm.value.username

    }
    if (this.passwordForm.value.newPassword != this.passwordForm.value.cnfpass) {
      this.err = "Password not matched"
    } else {
      this.commonService.changePassword(data, this.adminUserId).subscribe(res => {
        this.changePasswordStatus = res
        this.router.navigate(['home'])
      })
    }

  }


}
