import { NgModule } from '@angular/core';
import { Routes, RouterModule } from '@angular/router';
import { HomeComponent } from './containers/home/home.component';
import { AuthGuard } from './auth.guard';
import { HomePageComponent } from './home-page/home-page.component';
import { ComingSoonComponent } from './common/coming-soon/coming-soon.component';
import { progressCardComponent } from './reports/progressCard/progress-card/progress-card.component';
import { SigninComponent } from './signin/signin.component';
import { environment } from 'src/environments/environment';

var routes: Routes = [
  {
    path: '', redirectTo: `home`, pathMatch: 'full'
  },
  { 
    path: 'signin', component: SigninComponent,
  },
  {
    path: 'home', component: HomePageComponent, canActivate: [AuthGuard], data: ['admin', 'report_viewer', 'all']
  },
  {
    path: '', component: HomeComponent, canActivate: [AuthGuard], data: ['admin', 'report_viewer', 'all'], children: [
      {
        path: 'dashboard', canActivateChild: [AuthGuard], data: ['admin', 'report_viewer', 'all'], loadChildren: () => import('./dashboards/dashboard-module.module').then(m => m.DashboardModule)
      },
      {
        path: 'coming-soon', component: ComingSoonComponent, canActivateChild: [AuthGuard], data: ['admin', 'report_viewer', 'all']
      },
      {
        path: 'progressCard', component: progressCardComponent, canActivateChild: [AuthGuard], data: ['admin', 'report_viewer', 'all']
      },
      {
        path: 'diksha', canActivateChild: [AuthGuard], data: ['admin', 'report_viewer', 'all'], loadChildren: () => import('./reports/diksha/diksha.module').then(m => m.DikshaModule)
      },
      {
        path: 'attendance', canActivateChild: [AuthGuard], data: ['admin', 'report_viewer', 'all'], loadChildren: () => import('./reports/attendance/attendance.module').then(m => m.AttendancModule)
      },
      {
        path: 'exception', canActivateChild: [AuthGuard], data: ['admin', 'report_viewer', 'all'], loadChildren: () => import('./reports/exception-list/exception.module').then(m => m.ExceptionModule)
      },
      {
        path: 'infrastructure', canActivateChild: [AuthGuard], data: ['admin', 'report_viewer', 'all'], loadChildren: () => import('./reports/school-infra/infrastructure.module').then(m => m.InfrastructureModule)
      },
      {
        path: 'student-performance', canActivateChild: [AuthGuard], data: ['admin', 'report_viewer', 'all'], loadChildren: () => import('./reports/student-performance/student-performance.module').then(m => m.StudentPerformanceModule)
      },
      {
        path: '', canActivateChild: [AuthGuard], data: ['admin', 'report_viewer', 'all'], loadChildren: () => import('./reports/reports.module').then(m => m.ReportsModule)
      }
    ]
  },
  // { path: "**", component: PageNotFoundComponent }
];


@NgModule({
  imports: [RouterModule.forRoot(routes, { useHash: true })],
  exports: [RouterModule]
})
export class AppRoutingModule { }