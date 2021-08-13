import { Injectable } from '@angular/core';
import { AppServiceComponent } from 'src/app/app.service';

@Injectable({
  providedIn: 'root'
})
export class DataSourcesService {
  public dataSources = {
    nifi_crc: "",
    nifi_attendance: "",
    nifi_semester: "",
    nifi_infra: "",
    nifi_diksha: "",
    nifi_telemetry: "",
    nifi_udise: "",
    nifi_pat: "",
    nifi_composite: "",
    nifi_sat: "",
    nifi_healthcard: ""
  }

  // public telemetryData = [];
  // public timePeriod;
  // public reportWiseViews = {
  //   imrViews: "",
  //   crViews: "",
  //   udiseViews: "",
  //   compositeViews: "",
  //   dscViews: "",
  //   dccViews: "",
  //   utViews: "",
  //   dtrViews: "",
  //   utcViews: "",
  //   crcrViews: "",
  //   srViews: "",
  //   patViews: "",
  //   semExpViews: "",
  //   isdataViews: "",
  //   sarViews: "",
  //   tarViews: "",
  //   telemDataViews: "",
  //   heatChartViews: "",
  //   lotableViews: "",
  //   tpdtpViews: "",
  //   tpdcpViews: "",
  //   tpdenrollViews: "",
  //   tpdcompViews: "",
  //   healthCardViews: "",
  //   patExcptViews: "",
  //   sarExcptViews: "",
  //   tarExpViews: "",
  //   satViews: "",
  //   satHeatChartViews: ""
  // }

  constructor(public service: AppServiceComponent) {
    service.getDataSource().subscribe((res: any) => {
      res.forEach((element) => {
        if (element.template == "nifi_crc") {
          this.dataSources.nifi_crc = element.status;
        }
        if (element.template == "nifi_attendance") {
          this.dataSources.nifi_attendance = element.status;
        }
        if (element.template == "nifi_semester") {
          this.dataSources.nifi_semester = element.status;
        }
        if (element.template == "nifi_infra") {
          this.dataSources.nifi_infra = element.status;
        }
        if (element.template == "nifi_diksha") {
          this.dataSources.nifi_diksha = element.status;
        }
        if (element.template == "nifi_telemetry") {
          this.dataSources.nifi_telemetry = element.status;
        }
        if (element.template == "nifi_udise") {
          this.dataSources.nifi_udise = element.status;
        }
        if (element.template == "nifi_pat") {
          this.dataSources.nifi_pat = element.status;
        }
        if (element.template === "nifi_composite") {
          this.dataSources.nifi_composite = element.status;
        }
        if (element.template === 'nifi_sat') {
          this.dataSources.nifi_sat = element.status;
        }
      });
    });
    // this.callOnInterval();
    // setInterval(() => {
    //   this.callOnInterval();
    // }, 30000);
  }

  // callOnInterval() {
  //   this.getViews24hrs();
  //   setTimeout(() => {
  //     this.getViews7days();
  //   }, 10000);
  //   setTimeout(() => {
  //     this.getViews30days();
  //   }, 20000);
  // }

  // fetchTelemetry(event, report) {
  //   this.service.getTelemetryData(report, event.type);
  //   document.getElementById("backBtn") ? document.getElementById("backBtn").style.display = "none" : "";
  //   this.service.homeControl();
  // }

  // getViews24hrs() {
  //   this.service.getTelemetry("last_day").subscribe((res) => {
  //     this.telemetryData = res["telemetryData"];
  //     this.assignViews(this.telemetryData);
  //   });
  // }

  // getViews7days() {
  //   this.service.getTelemetry("last_7_days").subscribe((res) => {
  //     this.telemetryData = res["telemetryData"];
  //     this.assignViews(this.telemetryData);
  //   });
  // }

  // getViews30days() {
  //   this.service.getTelemetry("last_30_days").subscribe((res) => {
  //     this.telemetryData = res["telemetryData"];
  //     this.assignViews(this.telemetryData);
  //   });
  // }

  // assignViews(views) {
  //   var myStr = this.removeUnderscore(views[0].time_range);
  //   this.timePeriod = " (" + myStr + ")";

  //   views.forEach((element) => {
  //     let timeStr = this.removeUnderscore(element.time_range);
  //     if (element.reportid == "imr") {
  //       this.reportWiseViews.imrViews = element.number_of_views + " (" + timeStr + ")";
  //     }
  //     if (element.reportid == "cr") {
  //       this.reportWiseViews.crViews = element.number_of_views + " (" + timeStr + ")";
  //     }
  //     if (element.reportid == "udise") {
  //       this.reportWiseViews.udiseViews = element.number_of_views + " (" + timeStr + ")";
  //     }
  //     if (element.reportid == "composite") {
  //       this.reportWiseViews.compositeViews = element.number_of_views + " (" + timeStr + ")";
  //     }
  //     if (element.reportid == "dsc") {
  //       this.reportWiseViews.dscViews = element.number_of_views + " (" + timeStr + ")";
  //     }
  //     if (element.reportid == "dcc") {
  //       this.reportWiseViews.dccViews = element.number_of_views + " (" + timeStr + ")";
  //     }
  //     if (element.reportid == "ut") {
  //       this.reportWiseViews.utViews = element.number_of_views + " (" + timeStr + ")";
  //     }
  //     if (element.reportid == "dtr") {
  //       this.reportWiseViews.dtrViews = element.number_of_views + " (" + timeStr + ")";
  //     }
  //     if (element.reportid == "utc") {
  //       this.reportWiseViews.utcViews = element.number_of_views + " (" + timeStr + ")";
  //     }
  //     if (element.reportid == "crcr") {
  //       this.reportWiseViews.crcrViews = element.number_of_views + " (" + timeStr + ")";
  //     }
  //     if (element.reportid == "sr") {
  //       this.reportWiseViews.srViews = element.number_of_views + " (" + timeStr + ")";
  //     }
  //     if (element.reportid == "pat") {
  //       this.reportWiseViews.patViews = element.number_of_views + " (" + timeStr + ")";
  //     }
  //     if (element.reportid == "SemExp") {
  //       this.reportWiseViews.semExpViews = element.number_of_views + " (" + timeStr + ")";
  //     }
  //     if (element.reportid == "isdata") {
  //       this.reportWiseViews.isdataViews = element.number_of_views + " (" + timeStr + ")";
  //     }
  //     if (element.reportid == "sar") {
  //       this.reportWiseViews.sarViews = element.number_of_views + " (" + timeStr + ")";
  //     }
  //     if (element.reportid == "tar") {
  //       this.reportWiseViews.tarViews = element.number_of_views + " (" + timeStr + ")";
  //     }
  //     if (element.reportid == "telemData") {
  //       this.reportWiseViews.telemDataViews = element.number_of_views + " (" + timeStr + ")";
  //     }
  //     if (element.reportid == "heatChart") {
  //       this.reportWiseViews.heatChartViews = element.number_of_views + " (" + timeStr + ")";
  //     }
  //     if (element.reportid == "lotable") {
  //       this.reportWiseViews.lotableViews = element.number_of_views + " (" + timeStr + ")";
  //     }
  //     if (element.reportid == "tpd-cp") {
  //       this.reportWiseViews.tpdcpViews = element.number_of_views + " (" + timeStr + ")";
  //     }
  //     if (element.reportid == "tpd-tp") {
  //       this.reportWiseViews.tpdtpViews = element.number_of_views + " (" + timeStr + ")";
  //     }
  //     if (element.reportid == "tpd-enroll") {
  //       this.reportWiseViews.tpdenrollViews = element.number_of_views + " (" + timeStr + ")";
  //     }
  //     if (element.reportid == "tpd-comp") {
  //       this.reportWiseViews.tpdcompViews = element.number_of_views + " (" + timeStr + ")";
  //     }
  //     if (element.reportid == "healthCard") {
  //       this.reportWiseViews.healthCardViews = element.number_of_views + " (" + timeStr + ")";
  //     }
  //     if (element.reportid == "patExcpt") {
  //       this.reportWiseViews.patExcptViews = element.number_of_views + " (" + timeStr + ")";
  //     }
  //     if (element.reportid == "sarExcpt") {
  //       this.reportWiseViews.sarExcptViews = element.number_of_views + " (" + timeStr + ")";
  //     }
  //     if (element.reportid == "tarExp") {
  //       this.reportWiseViews.tarExpViews = element.number_of_views + " (" + timeStr + ")";
  //     }
  //     if (element.reportid == "sat") {
  //       this.reportWiseViews.satViews = element.number_of_views + " (" + timeStr + ")";
  //     }
  //     if (element.reportid == "satHeatChart") {
  //       this.reportWiseViews.satHeatChartViews = element.number_of_views + " (" + timeStr + ")";
  //     }
  //   });
  // }

  // removeUnderscore(data) {
  //   var mydata = data.replace(/_/g, " ");
  //   var myStr = mydata.charAt(0).toUpperCase() + mydata.substr(1).toLowerCase();
  //   return myStr;
  // }

}
