import { ComponentFixture, TestBed } from '@angular/core/testing';

import { HomeUsecaseTwoComponent } from './home-usecase-two.component';

describe('HomeUsecaseTwoComponent', () => {
  let component: HomeUsecaseTwoComponent;
  let fixture: ComponentFixture<HomeUsecaseTwoComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      declarations: [ HomeUsecaseTwoComponent ]
    })
    .compileComponents();
  });

  beforeEach(() => {
    fixture = TestBed.createComponent(HomeUsecaseTwoComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
