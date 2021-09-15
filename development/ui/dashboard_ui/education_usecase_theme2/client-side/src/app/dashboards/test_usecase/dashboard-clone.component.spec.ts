import { ComponentFixture, TestBed } from '@angular/core/testing';

import { DashboardCloneComponent } from './dashboard-clone.component';

describe('DashboardCloneComponent', () => {
  let component: DashboardCloneComponent;
  let fixture: ComponentFixture<DashboardCloneComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      declarations: [ DashboardCloneComponent ]
    })
    .compileComponents();
  });

  beforeEach(() => {
    fixture = TestBed.createComponent(DashboardCloneComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
