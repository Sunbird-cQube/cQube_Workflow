import { ChangeDetectorRef, Component, OnInit } from "@angular/core";
import { AppServiceComponent } from "../../../app.service";
import { KeycloakSecurityService } from "../../../keycloak-security.service";
import { environment } from "../../../../environments/environment";
import { dashboardReportDescriptions } from "../../description.config";

@Component({
  selector: 'app-crc-dashboard',
  templateUrl: './crc-dashboard.component.html',
  styleUrls: ['./crc-dashboard.component.css']
})
export class CrcDashboardComponent implements OnInit {
  state;
  reportGroup = "CRC Visit"
  //tooltip texts::::::::::::::
  toolTip = dashboardReportDescriptions;

  hiddenPass = false;
  edate: Date;
  telemetryData = [];
  timePeriod;

  imrViews;
  crViews;
  udiseViews;
  compositeViews;
  dscViews;
  dccViews;
  utViews;
  dtrViews;
  utcViews;
  crcrViews;
  srViews;
  patViews;
  semExpViews;
  isdataViews;
  sarViews;
  tarViews;
  telemDataViews;
  heatChartViews;
  lotableViews;
  tpdtpViews;
  tpdcpViews;
  tpdenrollViews;
  tpdcompViews;
  healthCardViews;
  patExcptViews;
  sarExcptViews;
  tarExpViews;
  satViews;
  satHeatChartViews;

  //for coming soon page
  nifi_crc;
  nifi_attendance;
  nifi_semester;
  nifi_infra;
  nifi_diksha;
  nifi_telemetry;
  nifi_udise;
  nifi_pat;
  nifi_composite;
  nifi_sat;


  managementType;
  categoryType;

  // diksha columns
  diksha_column =
    "diksha_columns" in environment ? environment["diksha_columns"] : true;

  constructor(
    private service: AppServiceComponent,
    public keyCloakService: KeycloakSecurityService,
    private changeDetection: ChangeDetectorRef,
  ) {
    service.logoutOnTokenExpire();
    this.changeDataSourceStatus();
  }



  ngOnInit() {
    sessionStorage.clear();
    document.getElementById("spinner").style.display = "block";
    document.getElementById("accessProgressCard").style.display = "none";
    //document.getElementById("backBtn").style.display = "block";
    if (localStorage.getItem("roleName") == "admin") {
      this.hiddenPass = false;
    } else {
      this.hiddenPass = true;
    }

    //calling function to show telemetry views..................

    this.callOnInterval();
    setInterval(() => {
      this.callOnInterval();
    }, 30000);

  }

  changeDataSourceStatus() {
    this.service.getDataSource().subscribe((res: any) => {
      res.forEach((element) => {
        if (element.template == "nifi_crc") {
          this.nifi_crc = element.status;
        }
        if (element.template == "nifi_attendance") {
          this.nifi_attendance = element.status;
        }
        if (element.template == "nifi_semester") {
          this.nifi_semester = element.status;
        }
        if (element.template == "nifi_infra") {
          this.nifi_infra = element.status;
        }
        if (element.template == "nifi_diksha") {
          this.nifi_diksha = element.status;
        }
        if (element.template == "nifi_telemetry") {
          this.nifi_telemetry = element.status;
        }
        if (element.template == "nifi_udise") {
          this.nifi_udise = element.status;
        }
        if (element.template == "nifi_pat") {
          this.nifi_pat = element.status;
        }
        if (element.template === "nifi_composite") {
          this.nifi_composite = element.status;
        }
        if (element.template === 'nifi_sat') {
          this.nifi_sat = element.status;
        }
      });
    });
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
    //document.getElementById("backBtn").style.display = "none";
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
    this.imrViews = "";
    this.crViews = "";
    this.udiseViews = "";
    this.compositeViews = "";
    this.dscViews = "";
    this.dccViews = "";
    this.utViews = "";
    this.dtrViews = "";
    this.utcViews = "";
    this.crcrViews = "";
    this.srViews = "";
    this.patViews = "";
    this.semExpViews = "";
    this.isdataViews = "";
    this.sarViews = "";
    this.tarViews = "";
    this.telemDataViews = "";
    this.heatChartViews = "";
    this.lotableViews = "";
    this.tpdcpViews = "";
    this.tpdtpViews = "";
    this.tpdenrollViews = "";
    this.tpdcompViews = "";
    this.patExcptViews = "";
    this.sarExcptViews = "";
    this.tarExpViews = "";
    this.satViews = "";
    this.satHeatChartViews = "";

    var myStr = this.removeUnderscore(views[0].time_range);
    this.timePeriod = " (" + myStr + ")";

    views.forEach((element) => {
      let timeStr = this.removeUnderscore(element.time_range);
      if (element.reportid == "imr") {
        this.imrViews = element.number_of_views + " (" + timeStr + ")";
      }
      if (element.reportid == "cr") {
        this.crViews = element.number_of_views + " (" + timeStr + ")";
      }
      if (element.reportid == "udise") {
        this.udiseViews = element.number_of_views + " (" + timeStr + ")";
      }
      if (element.reportid == "composite") {
        this.compositeViews = element.number_of_views + " (" + timeStr + ")";
      }
      if (element.reportid == "dsc") {
        this.dscViews = element.number_of_views + " (" + timeStr + ")";
      }
      if (element.reportid == "dcc") {
        this.dccViews = element.number_of_views + " (" + timeStr + ")";
      }
      if (element.reportid == "ut") {
        this.utViews = element.number_of_views + " (" + timeStr + ")";
      }
      if (element.reportid == "dtr") {
        this.dtrViews = element.number_of_views + " (" + timeStr + ")";
      }
      if (element.reportid == "utc") {
        this.utcViews = element.number_of_views + " (" + timeStr + ")";
      }
      if (element.reportid == "crcr") {
        this.crcrViews = element.number_of_views + " (" + timeStr + ")";
      }
      if (element.reportid == "sr") {
        this.srViews = element.number_of_views + " (" + timeStr + ")";
      }
      if (element.reportid == "pat") {
        this.patViews = element.number_of_views + " (" + timeStr + ")";
      }
      if (element.reportid == "SemExp") {
        this.semExpViews = element.number_of_views + " (" + timeStr + ")";
      }
      if (element.reportid == "isdata") {
        this.isdataViews = element.number_of_views + " (" + timeStr + ")";
      }
      if (element.reportid == "sar") {
        this.sarViews = element.number_of_views + " (" + timeStr + ")";
      }
      if (element.reportid == "tar") {
        this.tarViews = element.number_of_views + " (" + timeStr + ")";
      }
      if (element.reportid == "telemData") {
        this.telemDataViews = element.number_of_views + " (" + timeStr + ")";
      }
      if (element.reportid == "heatChart") {
        this.heatChartViews = element.number_of_views + " (" + timeStr + ")";
      }
      if (element.reportid == "lotable") {
        this.lotableViews = element.number_of_views + " (" + timeStr + ")";
      }
      if (element.reportid == "tpd-cp") {
        this.tpdcpViews = element.number_of_views + " (" + timeStr + ")";
      }
      if (element.reportid == "tpd-tp") {
        this.tpdtpViews = element.number_of_views + " (" + timeStr + ")";
      }
      if (element.reportid == "tpd-enroll") {
        this.tpdenrollViews = element.number_of_views + " (" + timeStr + ")";
      }
      if (element.reportid == "tpd-comp") {
        this.tpdcompViews = element.number_of_views + " (" + timeStr + ")";
      }
      if (element.reportid == "healthCard") {
        this.healthCardViews = element.number_of_views + " (" + timeStr + ")";
      }
      if (element.reportid == "patExcpt") {
        this.patExcptViews = element.number_of_views + " (" + timeStr + ")";
      }
      if (element.reportid == "sarExcpt") {
        this.sarExcptViews = element.number_of_views + " (" + timeStr + ")";
      }
      if (element.reportid == "tarExp") {
        this.tarExpViews = element.number_of_views + " (" + timeStr + ")";
      }
      if (element.reportid == "sat") {
        this.satViews = element.number_of_views + " (" + timeStr + ")";
      }
      if (element.reportid == "satHeatChart") {
        this.satHeatChartViews = element.number_of_views + " (" + timeStr + ")";
      }
    });
  }

  removeUnderscore(data) {
    var mydata = data.replace(/_/g, " ");
    var myStr = mydata.charAt(0).toUpperCase() + mydata.substr(1).toLowerCase();
    return myStr;
  }
}
