import { NgModule } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterModule, Routes } from '@angular/router';
import { FormsModule } from '@angular/forms';
import { ChartsModule } from 'ng2-charts';
import { AuthGuard } from 'src/app/auth.guard';
import { DikshaBarChartComponent } from './diksha-bar-chart/diksha-bar-chart.component';
import { DikshaChartComponent } from './diksha-chart/diksha-chart.component';
import { DikshaTableComponent } from './diksha-table/diksha-table.component';
import { DikshaUsageByTextBookComponent } from './diksha-usage-by-text-book/diksha-usage-by-text-book.component';
import { UsageByTextbookContentComponent } from './usage-by-textbook-content/usage-by-textbook-content.component';
import { DikshaTPDContentProgressComponent } from './tpd/diksha-tpd-course-progress/diksha-tpd-content-progress.component';
import { DikshaTPDTeachersPercentageComponent } from './tpd/diksha-tpd-teachers-percentage/diksha-tpd-teachers-percentage.component';
import { DikshaTpdEnrollmentComponent } from './diksha-tpd-enrollment-and-completion/diksha-tpd-enrollment.component';
import { DikshaTpdCompletionComponent } from './diksha-tpd-completion-percentage/diksha-tpd-completion.component';
import { BarChartComponent } from './bar-chart/bar-chart.component';
import { NgbPaginationModule } from '@ng-bootstrap/ng-bootstrap';
import { MultiBarChartComponent } from './multi-bar-chart/multi-bar-chart.component';
import { TpdTotalContentPlaysComponent } from './map-reports/tpd-total-content-plays/tpd-total-content-plays.component';
import { EtbTotalContentPlaysComponent } from './map-reports/etb-total-content-plays/etb-total-content-plays.component';
import { ContentUsagePieChartComponent } from './content-usage-pie-chart/content-usage-pie-chart.component';
import { EtbPerCapitaComponent } from './map-reports/etb-per-capita/etb-per-capita.component';
import { TotalContentPlayOverYearsComponent } from './total-content-play-over-years/total-content-play-over-years.component';
import { EnrollmentProgressComponent } from './enrollment-progress/enrollment-progress.component';
import { AverageTimeSpendBarComponent } from './average-time-spend-bar/average-time-spend-bar.component';
import { NgSelectModule } from '@ng-select/ng-select';
// import { MatFormFieldModule } from '@angular/material/form-field/form-field-module';
// import { MultiSelectComponent } from 'src/app/common/multi-select/multi-select.component';

// import { EtbPerCapitaComponent } from '..//etb-per-capita/etb-per-capita.component';

const dikshaRoutes: Routes = [
  {
    path: '', canActivate: [AuthGuard], children: [
      {
        path: 'usage-by-user-profile', component: DikshaChartComponent, canActivateChild: [AuthGuard], data: ['admin', 'report_viewer']
      },
      {
        path: 'usage-by-course-content', component: DikshaTableComponent, canActivateChild: [AuthGuard], data: ['admin', 'report_viewer']
      },
      {
        path: 'usage-by-course', component: DikshaBarChartComponent, canActivateChild: [AuthGuard], data: ['admin', 'report_viewer']
      },
      {
        path: 'usage-by-textbook', component: DikshaUsageByTextBookComponent, canActivateChild: [AuthGuard], data: ['admin', 'report_viewer']
      },
      {
        path: 'usage-by-textbook-content', component: UsageByTextbookContentComponent, canActivateChild: [AuthGuard], data: ['admin', 'report_viewer']
      },
      {
        path: 'tpd-course-progress', component: DikshaTPDContentProgressComponent, canActivateChild: [AuthGuard], data: ['admin', 'report_viewer']
      },
      {
        path: 'tpd-teacher-percentage', component: DikshaTPDTeachersPercentageComponent, canActivateChild: [AuthGuard], data: ['admin', 'report_viewer']
      },
      {
        path: 'tpd-enrollment', component: DikshaTpdEnrollmentComponent, canActivateChild: [AuthGuard], data: ['admin', 'report_viewer']
      },
      {
        path: 'tpd-completion', component: DikshaTpdCompletionComponent, canActivateChild: [AuthGuard], data: ['admin', 'report_viewer']
      },
      {
        path: 'tpd-total-content-plays', component: TpdTotalContentPlaysComponent, canActivateChild: [AuthGuard], data: ['admin', 'report_viewer']
      },
      {
        path: 'etb-total-content-plays', component: EtbTotalContentPlaysComponent, canActivateChild: [AuthGuard], data: ['admin', 'report_viewer']
      },
      {
        path: 'content-usage-pie-chart', component: ContentUsagePieChartComponent, canActivateChild: [AuthGuard], data: ['admin', 'report_viewer']
      },
      {
        path: 'etb-per-capita', component: EtbPerCapitaComponent, canActivateChild: [AuthGuard], data: ['admin', 'report_viewer']
      },
      {
        path: 'total-content-play', component: TotalContentPlayOverYearsComponent, canActivateChild: [AuthGuard], data: ['admin', 'report_viewer']
      },
      {
        path: 'enrollment-progress', component: EnrollmentProgressComponent, canActivateChild: [AuthGuard], data: ['admin', 'report_viewer']
      },
      {
        path: 'average-time-spend', component: AverageTimeSpendBarComponent, canActivateChild: [AuthGuard], data: ['admin', 'report_viewer']
      }
    ]
  }
]

@NgModule({
  declarations: [
    DikshaTableComponent,
    DikshaBarChartComponent,
    DikshaUsageByTextBookComponent,
    UsageByTextbookContentComponent,
    DikshaTpdEnrollmentComponent,
    DikshaTpdCompletionComponent,
    BarChartComponent,
    MultiBarChartComponent,
    TpdTotalContentPlaysComponent,
    EtbTotalContentPlaysComponent,
    EtbPerCapitaComponent,
    TotalContentPlayOverYearsComponent,
    EnrollmentProgressComponent,
    AverageTimeSpendBarComponent,
    
  ],
  imports: [
    CommonModule,
    FormsModule,
    ChartsModule,
    NgbPaginationModule,
    NgSelectModule,
    RouterModule.forChild(dikshaRoutes)
  ]
})
export class DikshaModule { }