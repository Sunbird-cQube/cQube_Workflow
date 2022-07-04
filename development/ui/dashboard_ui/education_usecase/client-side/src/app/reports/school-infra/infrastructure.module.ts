import { NgModule } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterModule, Routes } from '@angular/router';
import { NgbDropdownModule } from '@ng-bootstrap/ng-bootstrap';

import { AuthGuard } from 'src/app/auth.guard';
import { InfraMapVisualisationComponent } from './infra-map-visualisation/infra-map-visualisation.component';
import { SchoolInfrastructureComponent } from './school-infrastructure/school-infrastructure.component';
import { FormsModule } from '@angular/forms';
import { UdiseReportComponent } from './udise-report/udise-report.component';
import { AgmCoreModule } from '@agm/core';
import { TestMapReportComponent } from './test-map-report/test-map-report.component';
import { CommonMapReportComponent } from '../common-map-report/common-map-report.component';


const infraRoutes: Routes = [
  {
    path: '', canActivate: [AuthGuard], children: [
      {
        path: 'school-infrastructure', component: SchoolInfrastructureComponent, canActivateChild: [AuthGuard], data: ['admin', 'report_viewer']
      },
      {
        path: 'school-infra-map', component: InfraMapVisualisationComponent, canActivateChild: [AuthGuard], data: ['admin', 'report_viewer']
      },
      {
        path: 'udise-report', component: UdiseReportComponent, canActivateChild: [AuthGuard], data: ['admin', 'report_viewer']
      }
    ]
  }
]


@NgModule({
  declarations: [
    SchoolInfrastructureComponent,
    InfraMapVisualisationComponent,
    UdiseReportComponent,
    TestMapReportComponent,
  ],
  imports: [
    CommonModule,
    FormsModule,
    NgbDropdownModule,
    RouterModule.forChild(infraRoutes),
    AgmCoreModule
  ]
})
export class InfrastructureModule { }