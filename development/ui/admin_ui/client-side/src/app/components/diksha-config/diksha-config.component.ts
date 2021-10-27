import { Component, OnInit } from '@angular/core';
import { Router } from '@angular/router';
import { DikshaConfigService } from 'src/app/services/diksha-config.service';

@Component({
  selector: 'app-diksha-config',
  templateUrl: './diksha-config.component.html',
  styleUrls: ['./diksha-config.component.css']
})
export class DikshaConfigComponent implements OnInit {

  constructor(private service: DikshaConfigService, public router: Router) { }
  public date = new Date();
  public getTime = `${this.date.getFullYear()}-${("0" + (this.date.getMonth() + 1)).slice(-2)}-${("0" + (this.date.getDate())).slice(-2)}, ${("0" + (this.date.getHours())).slice(-2)}:${("0" + (this.date.getMinutes())).slice(-2)}:${("0" + (this.date.getSeconds())).slice(-2)}`;
  public types = ['Default', 'Date Range'];
  selectedType = 'Default';

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
    this.TPDdata['selected'] = this.TPDselected;
    this.TPDdata['time'] = this.getTime;
    this.service.dikshaTPD_ETB_data_input({ method: this.TPDselected, dataSet: 'TPD' }).subscribe(res => {
      alert(res['msg']);
    }, err => {
      alert("Error found while initiating TPD method");
    })
  }

  ETBdata = {};
  ETBonSubmit() {
    this.ETBdata['selected'] = this.ETBselected;
    this.ETBdata['time'] = this.getTime;
    this.service.dikshaTPD_ETB_data_input({ method: this.ETBselected, dataSet: 'ETB' }).subscribe(res => {
      alert(res['msg']);
    }, err => {
      alert("Error found while initiating ETB method");
    })
  }




  fromDate = null;
  toDate = null;

  onDikshaConfigSubmit() {
    let obj = {
      fromDate: this.fromDate ? `${this.fromDate.getFullYear()}-${("0" + (this.fromDate.getMonth() + 1)).slice(-2)}-${("0" + (this.fromDate.getDate())).slice(-2)}` : null,
      toDate: this.toDate ? `${this.toDate.getFullYear()}-${("0" + (this.toDate.getMonth() + 1)).slice(-2)}-${("0" + (this.toDate.getDate())).slice(-2)}` : null,
      type: this.selectedType
    }
    if (this.selectedType != 'Default' && (this.fromDate == null || this.toDate == null)) {
      alert("Please Select From and To Dates");
      return false;
    } else {
      this.service.dikshaConfigService(obj).subscribe(res => {
        alert(res['msg']);
      }, err => {
        alert("Error found while configuring diksha");
      })
    }
  }


  onChooseType() {
    if (this.selectedType == 'Default') {
      this.fromDate = null;
      this.toDate = null;
    }
  }

}
