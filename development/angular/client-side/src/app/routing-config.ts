import { NgModule } from '@angular/core';
import { Routes, RouterModule } from '@angular/router';
import { HomeComponent } from './containers/home/home.component';
import { AuthGuard } from './auth.guard';
import { DashboardComponent } from './dashboards/default/dashboard.component';
import { HomePageComponent } from './home-page/home-page.component';
import { ComingSoonComponent } from './common/coming-soon/coming-soon.component';
import { HealthCardComponent } from './reports/healthCard/health-card/health-card.component';
import { DashboardCloneComponent } from './dashboards/usecase-1/dashboard-clone.component';
import { testCase } from './dashboards/dashboard.config';
import { PageNotFoundComponent } from './common/page-not-found/page-not-found.component';

export var routes: Routes = routes = [
    {
        path: '', redirectTo: `home`, pathMatch: 'full'
    },
    {
        path: 'home', component: HomePageComponent
    },
    {
        path: '', component: HomeComponent, canActivate: [AuthGuard], children: [
            {
                path: 'dashboard', component: DashboardComponent, canActivateChild: [AuthGuard], data: ['admin', 'report_viewer']
            },
            {
                path: 'coming-soon', component: ComingSoonComponent, canActivateChild: [AuthGuard], data: ['admin', 'report_viewer']
            },
            {
                path: 'progressCard', component: HealthCardComponent
            },
            {
                path: 'diksha', loadChildren: () => import('./reports/diksha/diksha.module').then(m => m.DikshaModule)
            },
            {
                path: 'attendance', loadChildren: () => import('./reports/attendance/attendance.module').then(m => m.AttendancModule)
            },
            {
                path: 'exception', loadChildren: () => import('./reports/exception-list/exception.module').then(m => m.ExceptionModule)
            },
            {
                path: 'infrastructure', loadChildren: () => import('./reports/school-infra/infrastructure.module').then(m => m.InfrastructureModule)
            },
            {
                path: 'student-performance', loadChildren: () => import('./reports/student-performance/student-performance.module').then(m => m.StudentPerformanceModule)
            },
            {
                path: '', loadChildren: () => import('./reports/reports.module').then(m => m.ReportsModule)
            }
        ]
    },
    { path: "**", component: PageNotFoundComponent }
];