import { Component, OnInit, ElementRef } from '@angular/core';
import { Router } from '@angular/router';
import { ConfigurableData } from 'src/app/services/configurable.data.service';
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

  constructor(private service: DikshaConfigService, public router: Router, public service1: ConfigurableData, private elementRef: ElementRef) {
    //added
    for (let i = 1; i <= 10; i++) {
      this.hoursArr.push({ hours: i });
    }
  }



  public date = new Date();
  public getTime = `${this.date.getFullYear()}-${("0" + (this.date.getMonth() + 1)).slice(-2)}-${("0" + (this.date.getDate())).slice(-2)}, ${("0" + (this.date.getHours())).slice(-2)}:${("0" + (this.date.getMinutes())).slice(-2)}:${("0" + (this.date.getSeconds())).slice(-2)}`;

  public types = ['Date Range'];
  public disableBtn
  ngOnInit(): void {

    this.disableBtn = this.dataListSelected == "choose DataSource" ? false : true
    document.getElementById('spinner').style.display = 'none';
    document.getElementById('backBtn').style.display = "none";
    document.getElementById('homeBtn').style.display = "Block";
    this.getdatalist()
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


  dataSourceList
  dataSourceItem
  dataListSelected = "choose DataSource "
  getdatalist() {
    this.service1.getConfigDataSource().subscribe(res => {
      this.dataSourceList = res

    }, err => {
      document.getElementById('spinner').style.display = "none";

    })

  }

  hideConfig: boolean = false

  interver = null

  startTimer(duration, display) {
    var timer = duration, minutes, seconds;
    var self = this;
    let _interver = setInterval(function () {

      minutes = Math.floor(timer / 60);
      seconds = Math.floor(timer % 60);

      minutes = minutes < 60 ? minutes : minutes;
      seconds = seconds < 60 ? seconds : seconds;

      display.textContent = minutes + ":" + seconds;

      if (--timer < 0) {
        self.hideConfig = false
        clearInterval(_interver);

      }
    }, 1000);

  }

  startTimer1() {
    var fiveMinutes = 60 * 60,
      display = this.elementRef.nativeElement.querySelector('#time1');
    this.startTimer(fiveMinutes, display);
  };

  selectedDataList() {
    this.disableBtn = false
  }

  activation() {
    this.hideConfig = true
    this.dataSourceList = this.dataSourceList.filter(list => list !== this.dataListSelected)
    this.startTimer1()
    this.buildAngular()
  }

  buildAngular() {
    let obj = {
      dataSource: this.dataListSelected
    }

    this.service1.buildAngular(obj).subscribe(res => {

      let index = this.dataSourceList.indexOf(this.dataListSelected)
      if (index > -1) { // only splice array when item is found
        this.dataSourceList.splice(index, 1);
      }

    }, err => {
      console.log('err', err)
    })
  }

}
