import { Component, OnInit, ViewEncapsulation } from '@angular/core';
import { ExportToCsv } from 'export-to-csv';
import { Router } from '@angular/router';
import { ExceptionReportService } from '../../../services/exception-report.service';
import { AppServiceComponent } from '../../../app.service';
declare const $;

@Component({
  selector: 'app-missing-data',
  templateUrl: './missing-data.component.html',
  styleUrls: ['./missing-data.component.css'],
  encapsulation: ViewEncapsulation.None
})
export class MissingDataComponent implements OnInit {
  fileName: any;
  reportData: any = [];
  managementName;
  management;
  category;

  constructor(private router: Router, private service: ExceptionReportService,public commonService: AppServiceComponent) { }

  ngOnInit(): void {
    document.getElementById('homeBtn').style.display = 'block';
    document.getElementById('backBtn').style.display = 'none';
    this.managementName = this.management = JSON.parse(localStorage.getItem('management')).id;
    this.category = JSON.parse(localStorage.getItem('category')).id;
    this.managementName = this.commonService.changeingStringCases(
      this.managementName.replace(/_/g, " ")
    );
    $(document).ready(function () {
      $('#table').DataTable({
        destroy: true, bLengthChange: false, bInfo: false,
        bPaginate: false, scrollY: "58vh", scrollX: true,
        scrollCollapse: true, paging: false, searching: false
      });
    });
  }

  school_Invalid_Data() {
    document.getElementById('spinner').style.display = 'block';
    this.service.school_invalid({ management: this.management, category: this.category }).subscribe(res => {
      document.getElementById("spinner").style.display = "none";
      window.open(`${res["downloadUrl"]}`, "_blank");
    }, err => {
      alert('No data found, Unable to download');
      document.getElementById('errMsg').style.color = 'red';
      document.getElementById('errMsg').style.display = 'block';
      document.getElementById('errMsg').innerHTML = 'No data found';
      document.getElementById('spinner').style.display = 'none';
    })
  }

  // to download the excel report
  downloadReport() {
    this.commonService.download(this.fileName, this.reportData);
  }

}
