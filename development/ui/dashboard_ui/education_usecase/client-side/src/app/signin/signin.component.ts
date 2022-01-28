import { Component, OnInit, ViewEncapsulation } from '@angular/core';
import { FormBuilder, FormGroup, Validators } from '@angular/forms';
import { ActivatedRoute, Router } from '@angular/router';
import { LoginService } from '../services/login.service';
import { GetQRcodeService } from '../services/get-qrcode.service'
import { environment } from '../../environments/environment'

declare let $
@Component({
  selector: 'app-signin',
  templateUrl: './signin.component.html',
  styleUrls: ['./signin.component.css'],
  encapsulation: ViewEncapsulation.Emulated
})
export class SigninComponent implements OnInit {

  loginForm!: FormGroup;
  otpForm!: FormGroup
  loading = false;
  submitted = false;

  constructor(private formBuilder: FormBuilder,
    private route: ActivatedRoute,
    private router: Router,
    public service: LoginService) { }

  ngOnInit(): void {
    this.loginForm = this.formBuilder.group({
      username: ['', Validators.required],
      password: ['', Validators.required]
    });
    this.otpForm = this.formBuilder.group({
      otp: ['', Validators.required],
      secret: ['', Validators.required]
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
  public tempSecret: any

  onSubmit() {
    this.submitted = true;

    // stop here if form is invalid
    if (this.loginForm.invalid) {
      return;
    }

    // ++++ custom qr code for 2FA

    // this.service.getQRcode(this.loginForm.value).subscribe(res => {
    //   this.otpUrl = res
    //   this.tempSecret = res['tempSecret']
    // })

    this.service.login(this.loginForm.value).subscribe(res => {
      let role = res['role'];
      let token = res['token'];
      let username = res['username'];
      let userId = res['userId']

      localStorage.setItem('roleName', role);
      localStorage.setItem('token', token);
      localStorage.setItem('userName', username);
      localStorage.setItem('userid', userId)
      this.router.navigate(['/dashboard/infrastructure-dashboard'])

    }, err => {
      this.wrongCredintional = true;
      this.errorMsg = err.error.errMsg;

    })


  }
  public otpStatus: any

  verifyQRCOde() {
    this.service.getQRverify(this.otpForm.value).subscribe(res => {
      this.otpStatus = res

      this.router.navigate(['home'])
    })
  }
}
