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
import { CommonDashboardComponent } from './group-dashboards/common-dashboard/common-dashboard.component';

var dashboardRoutes: Routes = [
  {
    path: '', canActivate: [AuthGuard], data: ['admin', 'report_viewer'], children: [
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
        path: 'common-dashboard', component: CommonDashboardComponent
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
    ManagementSelectorComponent,
    CommonDashboardComponent
  ],
  imports: [
    CommonModule,
    FormsModule,
    RouterModule.forChild(dashboardRoutes)
  ]
})
export class DashboardModule { }
