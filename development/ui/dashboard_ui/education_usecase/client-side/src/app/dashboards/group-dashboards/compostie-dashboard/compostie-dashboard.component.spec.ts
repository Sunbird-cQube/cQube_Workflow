import { ComponentFixture, TestBed } from '@angular/core/testing';

import { CompostieDashboardComponent } from './compostie-dashboard.component';

describe('CompostieDashboardComponent', () => {
  let component: CompostieDashboardComponent;
  let fixture: ComponentFixture<CompostieDashboardComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      declarations: [ CompostieDashboardComponent ]
    })
    .compileComponents();
  });

  beforeEach(() => {
    fixture = TestBed.createComponent(CompostieDashboardComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
