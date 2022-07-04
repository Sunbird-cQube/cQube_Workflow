import { Component, OnInit } from '@angular/core';
import * as L from "leaflet";
import * as R from "leaflet-responsive-popup";
import { AppServiceComponent } from 'src/app/app.service';
import { environment } from "src/environments/environment";

@Component({
  selector: 'app-test-map-report',
  templateUrl: './test-map-report.component.html',
  styleUrls: ['./test-map-report.component.css']
})
export class TestMapReportComponent implements OnInit {
  // to hide and show the hierarchy details
  public skul: boolean = true;
  public dist: boolean = false;
  public blok: boolean = false;
  public clust: boolean = false;
  selected = "absolute";
  constructor(public commonService: AppServiceComponent) { }
    reportHeader = ""
    reportDescription = ""
    state
    reportName1 = "infraMap1"
  ngOnInit(): void {
    this.state = this.commonService.state;
    this.reportHeader = "Report on Infrastructure access by location for"
    this.reportDescription = `The School Infrastructure dashboard visualises the data on school infrastructure metrics for ${this.state}`
  }

  public legendColors: any = [
    "#a50026",
    "#d73027",
    "#f46d43",
    "#fdae61",
    "#fee08b",
    "#d9ef8b",
    "#a6d96a",
    "#66bd63",
    "#1a9850",
    "#006837",
  ];
  public values = [
    "0-10",
    "11-20",
    "21-30",
    "31-40",
    "41-50",
    "51-60",
    "61-70",
    "71-80",
    "81-90",
    "91-100",
  ];
}
