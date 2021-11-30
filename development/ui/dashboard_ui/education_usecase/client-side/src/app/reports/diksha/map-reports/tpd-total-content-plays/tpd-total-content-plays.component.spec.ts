import { ComponentFixture, TestBed } from '@angular/core/testing';

import { TpdTotalContentPlaysComponent } from './tpd-total-content-plays.component';

describe('TpdTotalContentPlaysComponent', () => {
  let component: TpdTotalContentPlaysComponent;
  let fixture: ComponentFixture<TpdTotalContentPlaysComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      declarations: [ TpdTotalContentPlaysComponent ]
    })
    .compileComponents();
  });

  beforeEach(() => {
    fixture = TestBed.createComponent(TpdTotalContentPlaysComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
