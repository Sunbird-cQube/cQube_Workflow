import { Component, OnInit } from '@angular/core';
import { environment } from '../../environments/environment'
import { AppService } from '../app.service';

@Component({
  selector: 'app-dashboard',
  templateUrl: './dashboard.component.html',
  styleUrls: ['./dashboard.component.css']
})
export class DashboardComponent implements OnInit {
  public grafanaUrl = environment.grafanaEndPoint;
  public storageType = environment.storageType;
  public listFileName = ""
  constructor(service: AppService) {
    service.logoutOnTokenExpire();
    this.listFileName = this.storageType == 's3' ? "Download \n S3 Files" : "List \n Local Files"
  }

  ngOnInit(): void {
    document.getElementById('backBtn').style.display = "block";
    document.getElementById('homeBtn').style.display = "None";
  }

}
