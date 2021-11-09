import { Component, OnInit } from '@angular/core';
import { Router } from '@angular/router';
import { DikshaConfigService } from 'src/app/services/diksha-config.service';

@Component({
  selector: 'app-diksha-config',
  templateUrl: './diksha-config.component.html',
  styleUrls: ['./diksha-config.component.css']
})
export class DikshaConfigComponent implements OnInit {
  hoursArr = [];
  selectedHour = [];
  selectedDuration: any;

  constructor(private service: DikshaConfigService, public router: Router) {
    //added
    for (let i = 1; i <= 10; i++) {
      this.hoursArr.push({ hours: i });
    }
  }



  public date = new Date();
  public getTime = `${this.date.getFullYear()}-${("0" + (this.date.getMonth() + 1)).slice(-2)}-${("0" + (this.date.getDate())).slice(-2)}, ${("0" + (this.date.getHours())).slice(-2)}:${("0" + (this.date.getMinutes())).slice(-2)}:${("0" + (this.date.getSeconds())).slice(-2)}`;
  // public types = ['Default', 'Date Range'];
  public types = ['Date Range'];

  ngOnInit(): void {
    document.getElementById('spinner').style.display = 'none';
    document.getElementById('backBtn').style.display = "none";
    document.getElementById('homeBtn').style.display = "Block";
  }

  dropdownOptions = ['Emission', 'API'];
  TPDselected = 'API';
  ETBselected = 'API';
  TPDdata = {};
  TPDonSubmit() {
    document.getElementById('spinner').style.display = 'block';
    this.TPDdata['selected'] = this.TPDselected;
    this.TPDdata['time'] = this.getTime;
    this.service.dikshaTPD_ETB_data_input({ method: this.TPDselected, dataSet: 'TPD' }).subscribe(res => {
      alert(res['msg']);
      document.getElementById('spinner').style.display = 'none';
    }, err => {
      alert("Error found while initiating TPD method");
      document.getElementById('spinner').style.display = 'none';
    })
  }

  ETBdata = {};
  ETBonSubmit() {
    document.getElementById('spinner').style.display = 'block';
    this.ETBdata['selected'] = this.ETBselected;
    this.ETBdata['time'] = this.getTime;
    this.service.dikshaTPD_ETB_data_input({ method: this.ETBselected, dataSet: 'ETB' }).subscribe(res => {
      alert(res['msg']);
      document.getElementById('spinner').style.display = 'none';
    }, err => {
      alert("Error found while initiating ETB method");
      document.getElementById('spinner').style.display = 'none';
    })
  }




  fromDate = null;
  toDate = null;
  timeout: any;

  onDikshaConfigSubmit() {
    document.getElementById('spinner').style.display = 'block';
    let obj = {
      fromDate: this.fromDate ? `${this.fromDate.getFullYear()}-${("0" + (this.fromDate.getMonth() + 1)).slice(-2)}-${("0" + (this.fromDate.getDate())).slice(-2)}` : null,
      toDate: this.toDate ? `${this.toDate.getFullYear()}-${("0" + (this.toDate.getMonth() + 1)).slice(-2)}-${("0" + (this.toDate.getDate())).slice(-2)}` : null,
      hourSelected: this.selectedDuration
    }
    if (this.fromDate == null && this.toDate == null && this.selectedDuration == undefined) {
      alert("Please Select From Date, To Date and Stopping Hours");
      document.getElementById('spinner').style.display = 'none';
      return false;
    } else if (this.fromDate != null && this.toDate == null && this.selectedDuration == undefined) {
      alert("Please Select To Date and Stopping Hours");
      document.getElementById('spinner').style.display = 'none';
      return false;
    } if (this.fromDate != null && this.toDate != null && this.selectedDuration == undefined) {
      alert("Please Select Stopping Hours");
      document.getElementById('spinner').style.display = 'none';
      return false;
    } else {
      this.timeout = setTimeout(() => {
        alert('Diksha ETB Dates Configured Successfully.');
        document.getElementById('spinner').style.display = 'none';
      }, 5000);
      this.service.dikshaConfigService(obj).subscribe(res => {
      }, err => {
        clearTimeout(this.timeout);
        alert("Error found while configuring diksha");
        document.getElementById('spinner').style.display = 'none';
      })
    }
  }

  onSelectHour() {
    this.selectedDuration = this.selectedHour;
  }

}
