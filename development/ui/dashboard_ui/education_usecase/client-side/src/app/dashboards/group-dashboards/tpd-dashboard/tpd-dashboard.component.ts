import { ChangeDetectorRef, Component, OnInit } from "@angular/core";
import { AppServiceComponent } from "../../../app.service";
import { KeycloakSecurityService } from "../../../keycloak-security.service";
import { environment } from "../../../../environments/environment";
import { dashboardReportDescriptions } from "../../description.config";
import { DataSourcesService } from "../data-sources.service";
import { dashboardReportHeadings } from "../../reportHeading.config";

@Component({
  selector: 'app-tpd-dashboard',
  templateUrl: './tpd-dashboard.component.html',
  styleUrls: ['./tpd-dashboard.component.css']
})
export class TpdDashboardComponent implements OnInit {
  state;
  semester = true;
  reportGroup = "Teacher Professional Development"
  //tooltip texts::::::::::::::
  toolTip = dashboardReportDescriptions;
  reportHeading = dashboardReportHeadings;
  dataSource = {};

  hiddenPass = false;
  edate: Date;
  telemetryData = [];
  timePeriod;

  dccViews = "";
  dtrViews = "";
  tpdtpViews = "";
  tpdcpViews = "";
  tpdenrollViews = "";
  tpdcompViews = "";
  tpdcontentViews = "";
  tpdgpsViews = "";
  tpdUserEngagViews = "";
  tpduserOnboardViews = ""
  // diksha columns
  diksha_column =
    "diksha_columns" in environment ? environment["diksha_columns"] : true;

  constructor(
    private service: AppServiceComponent,
    public keyCloakService: KeycloakSecurityService,
    public sourceService: DataSourcesService
  ) {
    service.logoutOnTokenExpire();
  }

  ngOnInit() {
    sessionStorage.clear();
    document.getElementById("accessProgressCard").style.display = "none";
    document.getElementById("backBtn") ? document.getElementById("backBtn").style.display = "block" : "";
    if (localStorage.getItem("roleName") == "admin") {
      this.hiddenPass = false;
    } else {
      this.hiddenPass = true;
    }
    this.dataSource = this.sourceService.dataSources;

    //calling function to show telemetry views..................
    this.callOnInterval();
    setInterval(() => {
      this.callOnInterval();
    }, 30000);

  }




  callOnInterval() {
    this.getViews24hrs();
    setTimeout(() => {
      this.getViews7days();
    }, 10000);
    setTimeout(() => {
      this.getViews30days();
    }, 20000);
  }

  fetchTelemetry(event, report) {
    this.service.getTelemetryData(report, event.type);
    document.getElementById("backBtn") ? document.getElementById("backBtn").style.display = "none" : "";
    this.service.homeControl();
  }

  getViews24hrs() {
    this.service.getTelemetry("last_day").subscribe((res) => {
      this.telemetryData = res["telemetryData"];
      this.assignViews(this.telemetryData);
    });
  }

  getViews7days() {
    this.service.getTelemetry("last_7_days").subscribe((res) => {
      this.telemetryData = res["telemetryData"];
      this.assignViews(this.telemetryData);
    });
  }

  getViews30days() {
    this.service.getTelemetry("last_30_days").subscribe((res) => {
      this.telemetryData = res["telemetryData"];
      this.assignViews(this.telemetryData);
    });
  }

  assignViews(views) {
    var myStr = this.removeUnderscore(views[0].time_range);
    this.timePeriod = " (" + myStr + ")";

    views.forEach((element) => {
      let timeStr = this.removeUnderscore(element.time_range);
      if (element.reportid == "dcc") {
        this.dccViews = element.number_of_views + " (" + timeStr + ")";
      }
      if (element.reportid == "dtr") {
        this.dtrViews = element.number_of_views + " (" + timeStr + ")";
      }
      if (element.reportid == "tpd-cp") {
        this.tpdcpViews = element.number_of_views + " (" + timeStr + ")";
      }
      if (element.reportid == "tpd-enroll") {
        this.tpdenrollViews = element.number_of_views + " (" + timeStr + ")";
      }
      if (element.reportid == "tpd-comp") {
        this.tpdcompViews = element.number_of_views + " (" + timeStr + ")";
      }
      if (element.reportid == "tpd-content") {
        this.tpdcontentViews = element.number_of_views + " (" + timeStr + ")";
      }
      if (element.reportid == "tpd-gps") {
        this.tpdgpsViews = element.number_of_views + " (" + timeStr + ")";
      }
      if (element.reportid == "tpd-userEngag") {
        this.tpdUserEngagViews = element.number_of_views + " (" + timeStr + ")";
      }
      if (element.reportid == "tpd-userOnboard") {
        this.tpduserOnboardViews = element.number_of_views + " (" + timeStr + ")";
      }
      
    });
  }

  removeUnderscore(data) {
    var mydata = data.replace(/_/g, " ");
    var myStr = mydata.charAt(0).toUpperCase() + mydata.substr(1).toLowerCase();
    return myStr;
  }
}
