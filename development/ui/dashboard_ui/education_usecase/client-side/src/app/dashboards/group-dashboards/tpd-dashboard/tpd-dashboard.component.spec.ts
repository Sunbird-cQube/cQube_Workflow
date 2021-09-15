import { ComponentFixture, TestBed } from '@angular/core/testing';

import { TpdDashboardComponent } from './tpd-dashboard.component';

describe('TpdDashboardComponent', () => {
  let component: TpdDashboardComponent;
  let fixture: ComponentFixture<TpdDashboardComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      declarations: [ TpdDashboardComponent ]
    })
    .compileComponents();
  });

  beforeEach(() => {
    fixture = TestBed.createComponent(TpdDashboardComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
