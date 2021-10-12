import { Injectable } from '@angular/core';
import { AppServiceComponent } from 'src/app/app.service';

@Injectable({
  providedIn: 'root'
})
export class DataSourcesService {
  public dataSources = {
    crc: "",
    attendance: "",
    teacher_attendance: "",
    semester: "",
    infra: "",
    diksha: "",
    telemetry: "",
    udise: "",
    pat: "",
    composite: "",
    sat: "",
    progresscard: ""
  }

  constructor(public service: AppServiceComponent) {
    service.getDataSource().subscribe((res: any) => {
      res.forEach((element) => {
        if (element.template == "crc") {
          this.dataSources.crc = element.status;
        }
        if (element.template == "attendance") {
          this.dataSources.attendance = element.status;
        }
        if (element.template == "teacher_attendance") {
          this.dataSources.teacher_attendance = element.status;
        }
        if (element.template == "semester") {
          this.dataSources.semester = element.status;
        }
        if (element.template == "infra") {
          this.dataSources.infra = element.status;
        }
        if (element.template == "diksha") {
          this.dataSources.diksha = element.status;
        }
        if (element.template == "telemetry") {
          this.dataSources.telemetry = element.status;
        }
        if (element.template == "udise") {
          this.dataSources.udise = element.status;
        }
        if (element.template == "pat") {
          this.dataSources.pat = element.status;
        }
        if (element.template === "composite") {
          this.dataSources.composite = element.status;
        }
        if (element.template === 'sat') {
          this.dataSources.sat = element.status;
        }
        if (element.template === 'progresscard') {
          this.dataSources.progresscard = element.status;
        }
      });
    });
  }

}
