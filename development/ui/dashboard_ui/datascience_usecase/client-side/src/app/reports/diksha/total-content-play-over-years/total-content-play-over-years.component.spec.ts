import { ComponentFixture, TestBed } from '@angular/core/testing';

import { TotalContentPlayOverYearsComponent } from './total-content-play-over-years.component';

describe('TotalContentPlayOverYearsComponent', () => {
  let component: TotalContentPlayOverYearsComponent;
  let fixture: ComponentFixture<TotalContentPlayOverYearsComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      declarations: [ TotalContentPlayOverYearsComponent ]
    })
    .compileComponents();
  });

  beforeEach(() => {
    fixture = TestBed.createComponent(TotalContentPlayOverYearsComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
