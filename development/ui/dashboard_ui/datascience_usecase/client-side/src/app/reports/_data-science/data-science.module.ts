import { NgModule } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterModule, Routes } from '@angular/router';
import { AnomalyReportComponent } from './anomaly-report/anomaly-report.component';
import { AuthGuard } from 'src/app/auth.guard';
import { FormsModule } from '@angular/forms';
import { NgbPaginationModule } from '@ng-bootstrap/ng-bootstrap';
import { ComingSoonComponent } from 'src/app/common/coming-soon/coming-soon.component';
import { AgmCoreModule } from '@agm/core';
import { DropoutReportComponent } from './dropout-report/dropout-report.component';

const datascienceRoute: Routes = [
  {
    path: '', canActivate: [AuthGuard], children: [
      {
        path: 'anomaly-report', component: AnomalyReportComponent, canActivateChild: [AuthGuard], data: ['admin', 'report_viewer']
      },
      {
        path: 'dropout-report', component: DropoutReportComponent, canActivateChild: [AuthGuard], data: ['admin', 'report_viewer']
      }
    ]
  }
]

@NgModule({
  declarations: [AnomalyReportComponent, ComingSoonComponent, DropoutReportComponent],
  imports: [
    CommonModule,
    FormsModule,
    NgbPaginationModule,
    RouterModule.forChild(datascienceRoute),
    AgmCoreModule
  ]
})
export class DataScienceModule { }
