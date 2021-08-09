import { NgModule } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterModule, Routes } from '@angular/router';
import { AuthGuard } from 'src/app/auth.guard';
import { InfrastructureDashboardComponent } from './infrastructure-dashboard/infrastructure-dashboard.component';
import { CompostieDashboardComponent } from './compostie-dashboard/compostie-dashboard.component';
import { TpdDashboardComponent } from './tpd-dashboard/tpd-dashboard.component';
import { EtbDashboardComponent } from './etb-dashboard/etb-dashboard.component';
import { CrcDashboardComponent } from './crc-dashboard/crc-dashboard.component';
import { ProgressCardDashboardComponent } from './progress-card-dashboard/progress-card-dashboard.component';
import { StdPerformanceDashboardComponent } from './std-performance-dashboard/std-performance-dashboard.component';
import { AttendanceDashboardComponent } from './sttendance-dashboard/sttendance-dashboard.component';
import { ExceptionDashboardComponent } from './exception-dashboard/exception-dashboard.component';
import { TelemetryDashboardComponent } from './telemetry-dashboard/telemetry-dashboard.component';
import { ManagementSelectorComponent } from 'src/app/common/management-selector/management-selector.component';
import { FormsModule } from '@angular/forms';

var dashboardRoutes: Routes = [
  {
    path: '', canActivate: [AuthGuard], children: [
      {
        path: 'infrastructure-dashboard', component: InfrastructureDashboardComponent
      },
      {
        path: 'composite-dashboard', component: CompostieDashboardComponent
      },
      {
        path: 'tpd-dashboard', component: TpdDashboardComponent
      },
      {
        path: 'etb-dashboard', component: EtbDashboardComponent
      },
      {
        path: 'crc-dashboard', component: CrcDashboardComponent
      },
      {
        path: 'prograss-card-dashboard', component: ProgressCardDashboardComponent
      },
      {
        path: 'std-performance-dashboard', component: StdPerformanceDashboardComponent
      },
      {
        path: 'attendance-dashboard', component: AttendanceDashboardComponent
      },
      {
        path: 'exception-dashboard', component: ExceptionDashboardComponent
      },
      {
        path: 'telemetry-dashboard', component: TelemetryDashboardComponent
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
