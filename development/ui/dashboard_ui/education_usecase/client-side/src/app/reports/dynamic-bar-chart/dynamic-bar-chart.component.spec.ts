import { ComponentFixture, TestBed } from '@angular/core/testing';

import { DynamicBarChartComponent } from './dynamic-bar-chart.component';

describe('DynamicBarChartComponent', () => {
  let component: DynamicBarChartComponent;
  let fixture: ComponentFixture<DynamicBarChartComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      declarations: [ DynamicBarChartComponent ]
    })
    .compileComponents();
  });

  beforeEach(() => {
    fixture = TestBed.createComponent(DynamicBarChartComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
