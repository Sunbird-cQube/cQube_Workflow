import { ComponentFixture, TestBed } from '@angular/core/testing';

import { AverageTimeSpendBarComponent } from './average-time-spend-bar.component';

describe('AverageTimeSpendBarComponent', () => {
  let component: AverageTimeSpendBarComponent;
  let fixture: ComponentFixture<AverageTimeSpendBarComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      declarations: [ AverageTimeSpendBarComponent ]
    })
    .compileComponents();
  });

  beforeEach(() => {
    fixture = TestBed.createComponent(AverageTimeSpendBarComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
