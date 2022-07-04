import { ComponentFixture, TestBed } from '@angular/core/testing';

import { CommonMapReportComponent } from './common-map-report.component';

describe('CommonMapReportComponent', () => {
  let component: CommonMapReportComponent;
  let fixture: ComponentFixture<CommonMapReportComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      declarations: [ CommonMapReportComponent ]
    })
    .compileComponents();
  });

  beforeEach(() => {
    fixture = TestBed.createComponent(CommonMapReportComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
