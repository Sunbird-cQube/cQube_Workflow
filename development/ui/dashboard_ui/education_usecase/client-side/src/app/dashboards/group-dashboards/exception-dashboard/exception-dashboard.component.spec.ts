import { ComponentFixture, TestBed } from '@angular/core/testing';

import { ExceptionDashboardComponent } from './exception-dashboard.component';

describe('ExceptionDashboardComponent', () => {
  let component: ExceptionDashboardComponent;
  let fixture: ComponentFixture<ExceptionDashboardComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      declarations: [ ExceptionDashboardComponent ]
    })
    .compileComponents();
  });

  beforeEach(() => {
    fixture = TestBed.createComponent(ExceptionDashboardComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
