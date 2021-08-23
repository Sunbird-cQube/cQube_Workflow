import { NgModule } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterModule, Routes } from '@angular/router';
import { AuthGuard } from 'src/app/auth.guard';
import { InfrastructureDashboardComponent } from './group-dashboards/infrastructure-dashboard/infrastructure-dashboard.component';
import { CompostieDashboardComponent } from './group-dashboards/compostie-dashboard/compostie-dashboard.component';
import { TpdDashboardComponent } from './group-dashboards/tpd-dashboard/tpd-dashboard.component';
import { EtbDashboardComponent } from './group-dashboards/etb-dashboard/etb-dashboard.component';
import { CrcDashboardComponent } from './group-dashboards/crc-dashboard/crc-dashboard.component';
import { ProgressCardDashboardComponent } from './group-dashboards/progress-card-dashboard/progress-card-dashboard.component';
import { StdPerformanceDashboardComponent } from './group-dashboards/std-performance-dashboard/std-performance-dashboard.component';
import { AttendanceDashboardComponent } from './group-dashboards/sttendance-dashboard/sttendance-dashboard.component';
import { ExceptionDashboardComponent } from './group-dashboards/exception-dashboard/exception-dashboard.component';
import { TelemetryDashboardComponent } from './group-dashboards/telemetry-dashboard/telemetry-dashboard.component';
import { ManagementSelectorComponent } from 'src/app/common/management-selector/management-selector.component';
import { FormsModule } from '@angular/forms';

var dashboardRoutes: Routes = [
  {
    path: '', canActivate: [AuthGuard], data: ['admin', 'report_viewer'], children: [
      {
        path: 'infrastructure-dashboard', component: InfrastructureDashboardComponent, canActivateChild: [AuthGuard], data: ['admin', 'report_viewer']
      },
      {
        path: 'composite-dashboard', component: CompostieDashboardComponent, canActivateChild: [AuthGuard], data: ['admin', 'report_viewer']
      },
      {
        path: 'tpd-dashboard', component: TpdDashboardComponent, canActivateChild: [AuthGuard], data: ['admin', 'report_viewer']
      },
      {
        path: 'etb-dashboard', component: EtbDashboardComponent, canActivateChild: [AuthGuard], data: ['admin', 'report_viewer']
      },
      {
        path: 'crc-dashboard', component: CrcDashboardComponent, canActivateChild: [AuthGuard], data: ['admin', 'report_viewer']
      },
      {
        path: 'prograss-card-dashboard', component: ProgressCardDashboardComponent, canActivateChild: [AuthGuard], data: ['admin', 'report_viewer']
      },
      {
        path: 'std-performance-dashboard', component: StdPerformanceDashboardComponent, canActivateChild: [AuthGuard], data: ['admin', 'report_viewer']
      },
      {
        path: 'attendance-dashboard', component: AttendanceDashboardComponent, canActivateChild: [AuthGuard], data: ['admin', 'report_viewer']
      },
      {
        path: 'exception-dashboard', component: ExceptionDashboardComponent, canActivateChild: [AuthGuard], data: ['admin', 'report_viewer']
      },
      {
        path: 'telemetry-dashboard', component: TelemetryDashboardComponent, canActivateChild: [AuthGuard], data: ['admin', 'report_viewer']
      }
    ]
  }
];



@NgModule({
  declarations: [
    InfrastructureDashboardComponent,
    CompostieDashboardComponent,
    TpdDashboardComponent,
    EtbDashboardComponent,
    CrcDashboardComponent,
    ProgressCardDashboardComponent,
    StdPerformanceDashboardComponent,
    AttendanceDashboardComponent,
    ExceptionDashboardComponent,
    TelemetryDashboardComponent,
    ManagementSelectorComponent
  ],
  imports: [
    CommonModule,
    FormsModule,
    RouterModule.forChild(dashboardRoutes)
  ]
})
export class DashboardModule { }
