import { ComponentFixture, TestBed } from '@angular/core/testing';

import { CommonBarChartComponent } from './common-bar-chart.component';

describe('CommonBarChartComponent', () => {
  let component: CommonBarChartComponent;
  let fixture: ComponentFixture<CommonBarChartComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      declarations: [ CommonBarChartComponent ]
    })
    .compileComponents();
  });

  beforeEach(() => {
    fixture = TestBed.createComponent(CommonBarChartComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
