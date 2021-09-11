import { NgModule } from '@angular/core';
import { Routes, RouterModule } from '@angular/router';
import { HomeComponent } from './containers/home/home.component';
import { AuthGuard } from './auth.guard';
import { DashboardComponent } from './dashboards/education_usecase/dashboard.component';
import { HomePageComponent } from './home-page/home-page.component';
import { ComingSoonComponent } from './common/coming-soon/coming-soon.component';
import { HealthCardComponent } from './reports/healthCard/health-card/health-card.component';
import { usecase } from './dashboards/dashboard.config';
import { PageNotFoundComponent } from './common/page-not-found/page-not-found.component';
import { UsecaseTwoComponent } from './dashboards/usecase-two/usecase-two.component';
import { UsecaseThreeComponent } from './dashboards/usecase-three/usecase-three.component';
import { HomeUsecaseTwoComponent } from './containers/home-usecase-two/home-usecase-two.component';

var routes: Routes = [];
var useCase = usecase;

switch (useCase) {
  case "education_usecase":
    localStorage.setItem('usecase', 'all');
    routes = [
      {
        path: '', redirectTo: `home`, pathMatch: 'full'
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
            path: 'progressCard', component: HealthCardComponent, canActivateChild: [AuthGuard], data: ['admin', 'report_viewer', 'all']
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
    break;
  case "test_usecase":
    localStorage.setItem('usecase', 'usecase1');
    routes = [
      {
        path: '', redirectTo: `home`, pathMatch: 'full'
      },
      {
        path: 'home', component: HomePageComponent, canActivate: [AuthGuard], data: ['admin', 'report_viewer', 'usecase1']
      },
      {
        path: '', component: HomeUsecaseTwoComponent, canActivate: [AuthGuard], data: ['admin', 'report_viewer', 'usecase1'], children: [
          {
            path: 'dashboard', component: DashboardComponent, canActivateChild: [AuthGuard], data: ['admin', 'report_viewer', 'usecase1']
          },
          {
            path: 'coming-soon', component: ComingSoonComponent, canActivateChild: [AuthGuard], data: ['admin', 'report_viewer', 'usecase1']
          },
          {
            path: 'diksha', canActivateChild: [AuthGuard], data: ['admin', 'report_viewer', 'usecase1'], loadChildren: () => import('./reports/diksha/diksha.module').then(m => m.DikshaModule)
          }
        ]
      },
      // { path: "**", component: PageNotFoundComponent }
    ];
    break;
  // case "uc3_edu":
  //   localStorage.setItem('usecase', 'usecase2');
  //   routes = [
  //     {
  //       path: '', redirectTo: `home`, pathMatch: 'full'
  //     },
  //     {
  //       path: 'home', component: HomePageComponent, canActivate: [AuthGuard], data: ['admin', 'report_viewer', 'usecase2']
  //     },
  //     {
  //       path: '', component: HomeComponent, canActivate: [AuthGuard], data: ['admin', 'report_viewer', 'usecase2'], children: [
  //         {
  //           path: 'dashboard', component: UsecaseTwoComponent, canActivateChild: [AuthGuard], data: ['admin', 'report_viewer', 'usecase2']
  //         },
  //         {
  //           path: 'coming-soon', component: ComingSoonComponent, canActivateChild: [AuthGuard], data: ['admin', 'report_viewer', 'usecase2']
  //         },
  //         {
  //           path: 'attendance', canActivateChild: [AuthGuard], data: ['admin', 'report_viewer', 'usecase2'], loadChildren: () => import('./reports/attendance/attendance.module').then(m => m.AttendancModule)
  //         },
  //         {
  //           path: 'infrastructure', canActivateChild: [AuthGuard], data: ['admin', 'report_viewer', 'usecase2'], loadChildren: () => import('./reports/school-infra/infrastructure.module').then(m => m.InfrastructureModule)
  //         },
  //         {
  //           path: 'student-performance', canActivateChild: [AuthGuard], data: ['admin', 'report_viewer', 'usecase2'], loadChildren: () => import('./reports/student-performance/student-performance.module').then(m => m.StudentPerformanceModule)
  //         },
  //         {
  //           path: '', canActivateChild: [AuthGuard], data: ['admin', 'report_viewer', 'usecase2'], loadChildren: () => import('./reports/reports.module').then(m => m.ReportsModule)
  //         }
  //       ]
  //     },
  //     // { path: "**", component: PageNotFoundComponent }
  //   ];
  //   break;
  // case "uc3_edu":
  //   localStorage.setItem('usecase', 'usecase3');
  //   routes = [
  //     {
  //       path: '', redirectTo: `home`, pathMatch: 'full'
  //     },
  //     {
  //       path: 'home', component: HomePageComponent, canActivate: [AuthGuard], data: ['admin', 'report_viewer', 'usecase3']
  //     },
  //     {
  //       path: '', component: HomeComponent, canActivate: [AuthGuard], data: ['admin', 'report_viewer', 'usecase3'], children: [
  //         {
  //           path: 'dashboard', component: UsecaseThreeComponent, canActivateChild: [AuthGuard], data: ['admin', 'report_viewer', 'usecase3']
  //         },
  //         {
  //           path: 'coming-soon', component: ComingSoonComponent, canActivateChild: [AuthGuard], data: ['admin', 'report_viewer', 'usecase3']
  //         },
  //         {
  //           path: 'attendance', canActivateChild: [AuthGuard], data: ['admin', 'report_viewer', 'usecase3'], loadChildren: () => import('./reports/attendance/attendance.module').then(m => m.AttendancModule)
  //         },
  //         {
  //           path: 'infrastructure', canActivateChild: [AuthGuard], data: ['admin', 'report_viewer', 'usecase3'], loadChildren: () => import('./reports/school-infra/infrastructure.module').then(m => m.InfrastructureModule)
  //         },
  //         {
  //           path: '', canActivateChild: [AuthGuard], data: ['admin', 'report_viewer', 'usecase3'], loadChildren: () => import('./reports/reports.module').then(m => m.ReportsModule)
  //         }
  //       ]
  //     },
  //     // { path: "**", component: PageNotFoundComponent }
  //   ];
  //   break;
  default:
    //localStorage.setItem('usecase', 'all');
    routes = [
      { path: "**", component: PageNotFoundComponent }
    ];
}

@NgModule({
  imports: [RouterModule.forRoot(routes, { useHash: true })],
  exports: [RouterModule]
})
export class AppRoutingModule { }