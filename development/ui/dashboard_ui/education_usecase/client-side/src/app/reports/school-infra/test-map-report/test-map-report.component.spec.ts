import { ComponentFixture, TestBed } from '@angular/core/testing';

import { TestMapReportComponent } from './test-map-report.component';

describe('TestMapReportComponent', () => {
  let component: TestMapReportComponent;
  let fixture: ComponentFixture<TestMapReportComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      declarations: [ TestMapReportComponent ]
    })
    .compileComponents();
  });

  beforeEach(() => {
    fixture = TestBed.createComponent(TestMapReportComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
