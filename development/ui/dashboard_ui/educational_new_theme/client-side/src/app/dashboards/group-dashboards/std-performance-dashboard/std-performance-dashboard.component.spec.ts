import { ComponentFixture, TestBed } from '@angular/core/testing';

import { StdPerformanceDashboardComponent } from './std-performance-dashboard.component';

describe('StdPerformanceDashboardComponent', () => {
  let component: StdPerformanceDashboardComponent;
  let fixture: ComponentFixture<StdPerformanceDashboardComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      declarations: [ StdPerformanceDashboardComponent ]
    })
    .compileComponents();
  });

  beforeEach(() => {
    fixture = TestBed.createComponent(StdPerformanceDashboardComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
