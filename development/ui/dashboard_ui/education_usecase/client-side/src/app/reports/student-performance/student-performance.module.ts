import { NgModule } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterModule, Routes } from '@angular/router';
import { AuthGuard } from 'src/app/auth.guard';
import { PATReportComponent } from './pat-report/pat-report.component';
import { SemViewComponent } from './sem-view/sem-view.component';
import { FormsModule } from '@angular/forms';
import { HeatChartComponent } from './heat-chart/heat-chart.component';
import { PATLOTableComponent } from './pat-lo-table/pat-lo-table.component';
import { NgbPaginationModule } from '@ng-bootstrap/ng-bootstrap';
import { SatReportComponent } from './sat-report/sat-report.component';
import { SatHeatChartComponent } from './sat-heat-chart/sat-heat-chart.component';
import { SatTrendsChartComponent } from './sat-trends-chart/sat-trends-chart.component';
import { AgmCoreModule } from '@agm/core';

const performRoute: Routes = [
  {
    path: '', canActivate: [AuthGuard], children: [
      {
        path: 'semester-report', component: SemViewComponent, canActivateChild: [AuthGuard], data: ['admin', 'report_viewer']
      },
      {
        path: 'pat-report', component: PATReportComponent, canActivateChild: [AuthGuard], data: ['admin', 'report_viewer']
      },
      {
        path: 'heat-chart', component: HeatChartComponent, canActivateChild: [AuthGuard], data: ['admin', 'report_viewer']
      },
      {
        path: 'PAT-LO-table', component: PATLOTableComponent, canActivateChild: [AuthGuard], data: ['admin', 'report_viewer']
      },
      {
        path: 'sat-report', component: SatReportComponent, canActivateChild: [AuthGuard], data: ['admin', 'report_viewer']
      },
      {
        path: 'sat-heat-chart', component: SatHeatChartComponent, canActivateChild: [AuthGuard], data: ['admin', 'report_viewer']
      },
      {
        path: 'sat-trends-chart', component: SatTrendsChartComponent, canActivateChild: [AuthGuard], data: ['admin', 'report_viewer']
      }
    ]
  }
]

@NgModule({
  declarations: [
    SemViewComponent,
    PATReportComponent,
    HeatChartComponent,
    PATLOTableComponent,
    SatReportComponent,
    SatHeatChartComponent
  ],
  imports: [
    CommonModule,
    FormsModule,
    NgbPaginationModule,
    RouterModule.forChild(performRoute),
    AgmCoreModule
  ]
})
export class StudentPerformanceModule { }
