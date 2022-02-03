import { NgModule } from '@angular/core';
import { CommonModule } from '@angular/common';
import { AnomalyReportComponent } from './anomaly-report/anomaly-report.component';
import { DropoutReportComponent } from './dropout-report/dropout-report.component';
import { RouterModule, Routes } from '@angular/router';
import { AuthGuard } from 'src/app/auth.guard';
import { FormsModule } from '@angular/forms';
import { NgbPaginationModule } from '@ng-bootstrap/ng-bootstrap';
import { AgmCoreModule } from '@agm/core';

const datascienceRoutes: Routes = [
  {
    path: '', canActivate: [AuthGuard], children: [
      {
        path: 'anomaly', component: AnomalyReportComponent, canActivateChild: [AuthGuard], data: ['admin', 'report_viewer']
      },
      {
        path: 'dropout', component: DropoutReportComponent, canActivateChild: [AuthGuard], data: ['admin', 'report_viewer']
      }
    ]
  }
]

@NgModule({
  declarations: [
    AnomalyReportComponent,
    DropoutReportComponent
  ],
  imports: [
    CommonModule,
    FormsModule,
    NgbPaginationModule,
    RouterModule.forChild(datascienceRoutes),
    AgmCoreModule
  ]
})
export class DataScienceModule { }
