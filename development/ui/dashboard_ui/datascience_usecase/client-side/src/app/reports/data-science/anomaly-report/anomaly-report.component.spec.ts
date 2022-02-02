import { ComponentFixture, TestBed } from '@angular/core/testing';

import { AnomalyReportComponent } from './anomaly-report.component';

describe('AnomalyReportComponent', () => {
  let component: AnomalyReportComponent;
  let fixture: ComponentFixture<AnomalyReportComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      declarations: [ AnomalyReportComponent ]
    })
    .compileComponents();
  });

  beforeEach(() => {
    fixture = TestBed.createComponent(AnomalyReportComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
