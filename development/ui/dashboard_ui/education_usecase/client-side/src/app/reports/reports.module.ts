import { NgModule } from '@angular/core';
import { CommonModule } from '@angular/common';
import { AuthGuard } from '../auth.guard';
import { CompositReportComponent } from './composit/composit-report/composit-report.component';
import { CrcReportComponent } from './school-monitoring/crc-report/crc-report.component';
import { TelemetryDataComponent } from './telemetry/telemetry-data/telemetry-data.component';
import { ChangePasswordComponent } from './users/change-password/change-password.component';
import { FormsModule } from '@angular/forms';
import { RouterModule } from '@angular/router';
import { AgmCoreModule } from '@agm/core';
import { CommonMapReportComponent } from './common-map-report/common-map-report.component';
import { CommonBarChartComponent } from './common-bar-chart/common-bar-chart.component';
import { CommonLoTableComponent } from './common-lo-table/common-lo-table.component';
import { NgbPaginationModule } from '@ng-bootstrap/ng-bootstrap';


const otherRoutes = [
  {
    path: 'crc', canActivate: [AuthGuard], children: [
      {
        path: 'crc-report', component: CrcReportComponent, canActivateChild: [AuthGuard], data: ['admin', 'report_viewer']
      }]
  },
  {
    path: 'user', canActivate: [AuthGuard], data: ['viewer'], children: [
      {
        path: 'changePassword', component: ChangePasswordComponent, canActivateChild: [AuthGuard], data: ['viewer']
      }]
  },
  {
    path: '', canActivate: [AuthGuard], children: [
      {
        path: 'telemetry', component: TelemetryDataComponent, canActivateChild: [AuthGuard], data: ['admin', 'report_viewer']
      }]
  },
  {
    path: 'composite', canActivate: [AuthGuard], children: [
      {
        path: 'composite-report', component: CompositReportComponent, canActivateChild: [AuthGuard], data: ['admin', 'report_viewer']
      }
    ]
  },
  {
    path: '', canActivate: [AuthGuard], children: [
      {
        path: ':id/map', component: CommonMapReportComponent, canActivateChild: [AuthGuard], data: ['admin', 'report_viewer']
      }]
  },
  {
    path: '', canActivate: [AuthGuard], children: [
      {
        path: ':id/lotable', component: CommonLoTableComponent, canActivateChild: [AuthGuard], data: ['admin', 'report_viewer']
      }]
  },
]


@NgModule({
  declarations: [
    CrcReportComponent,
    ChangePasswordComponent,
    TelemetryDataComponent,
    CompositReportComponent,
    CommonBarChartComponent,
    CommonMapReportComponent,
    CommonLoTableComponent,
  ],
  imports: [
    CommonModule,
    FormsModule,
    NgbPaginationModule,
    RouterModule.forChild(otherRoutes),
    AgmCoreModule
  ]
})
export class ReportsModule { }