import { BrowserModule } from '@angular/platform-browser';
import { NgModule, CUSTOM_ELEMENTS_SCHEMA, APP_INITIALIZER } from '@angular/core';
import { HttpClientModule, HTTP_INTERCEPTORS } from '@angular/common/http';
import { FormsModule } from '@angular/forms';
import { ChartsModule } from 'ng2-charts';
import { AppRoutingModule } from './app-routing.module';
import { AppComponent } from './app.component';
import { HomeComponent } from './containers/home/home.component';
import { BrowserAnimationsModule } from '@angular/platform-browser/animations';
import { MatButtonModule } from '@angular/material/button';
import { MatIconModule } from '@angular/material/icon';
import { MatListModule } from '@angular/material/list';
import { MatSidenavModule } from '@angular/material/sidenav';
import { MatToolbarModule } from '@angular/material/toolbar';
import { MatTableModule } from '@angular/material/table';
import { DashboardComponent } from './dashboards/default/dashboard.component';
import { KeycloakSecurityService } from './keycloak-security.service';
import { HomePageComponent } from './home-page/home-page.component';
import { AuthInterceptor } from './auth.interceptor';
import { InfoComponent } from './common/info/info.component';
import { DikshaChartComponent } from './reports/diksha/diksha-chart/diksha-chart.component';
import { HealthCardComponent } from './reports/healthCard/health-card/health-card.component';
import { NgbModule } from '@ng-bootstrap/ng-bootstrap';
import { NgCircleProgressModule } from 'ng-circle-progress';
import { BubblesComponent } from './reports/healthCard/bubbles/bubbles.component';
import { ProgressCircleComponent } from './reports/healthCard/progress-circle/progress-circle.component';
import { MapLegendsComponent } from './common/map-legends/map-legends.component';
import { MultiSelectComponent } from './common/multi-select/multi-select.component';
import { DikshaTPDContentProgressComponent } from './reports/diksha/tpd/diksha-tpd-course-progress/diksha-tpd-content-progress.component';
import { DikshaTPDTeachersPercentageComponent } from './reports/diksha/tpd/diksha-tpd-teachers-percentage/diksha-tpd-teachers-percentage.component';
import { StudentAttendanceChartComponent } from './reports/attendance/student-attendance-chart/student-attendance-chart.component';
import { LineChartComponent } from './common/line-chart/line-chart.component';
import { FontAwesomeModule } from '@fortawesome/angular-fontawesome';
import { DashboardCloneComponent } from './dashboards/usecase-1/dashboard-clone.component';
import { PageNotFoundComponent } from './common/page-not-found/page-not-found.component';
import { AuthGuard } from './auth.guard';
import { UsecaseTwoComponent } from './dashboards/usecase-two/usecase-two.component';
import { UsecaseThreeComponent } from './dashboards/usecase-three/usecase-three.component';
import { HomeUsecaseTwoComponent } from './containers/home-usecase-two/home-usecase-two.component';

export function kcFactory(kcSecurity: KeycloakSecurityService) {
  return () => kcSecurity.init();
}

@NgModule({
  declarations: [
    AppComponent,
    HomeComponent,
    DashboardComponent,
    HomePageComponent,
    InfoComponent,
    DikshaChartComponent,
    HealthCardComponent,
    BubblesComponent,
    ProgressCircleComponent,
    MapLegendsComponent,
    MultiSelectComponent,
    DikshaTPDContentProgressComponent,
    DikshaTPDTeachersPercentageComponent,
    StudentAttendanceChartComponent,
    LineChartComponent,
    DashboardCloneComponent,
    PageNotFoundComponent,
    UsecaseTwoComponent,
    UsecaseThreeComponent,
    HomeUsecaseTwoComponent,
    //UsecaseThreeComponent
  ],
  imports: [
    BrowserModule,
    MatToolbarModule,
    MatSidenavModule,
    MatListModule,
    MatButtonModule,
    MatIconModule,
    MatTableModule,
    FontAwesomeModule,
    HttpClientModule,
    FormsModule,
    ChartsModule,
    BrowserAnimationsModule,
    AppRoutingModule,
    NgbModule,
    NgCircleProgressModule.forRoot({})
  ],
  exports: [
    MatTableModule,
    // MatPaginatorModule,
    // MatSortModule
  ],
  providers: [
    {
      provide: APP_INITIALIZER,
      deps: [KeycloakSecurityService],
      useFactory: kcFactory,
      multi: true
    },
    {
      provide: HTTP_INTERCEPTORS,
      useClass: AuthInterceptor,
      multi: true
    },
    AuthGuard
  ],
  bootstrap: [AppComponent],
  schemas: [CUSTOM_ELEMENTS_SCHEMA]
})
export class AppModule { }
