import { ComponentFixture, TestBed } from '@angular/core/testing';

import { EtbTotalContentPlaysComponent } from './etb-total-content-plays.component';

describe('EtbTotalContentPlaysComponent', () => {
  let component: EtbTotalContentPlaysComponent;
  let fixture: ComponentFixture<EtbTotalContentPlaysComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      declarations: [ EtbTotalContentPlaysComponent ]
    })
    .compileComponents();
  });

  beforeEach(() => {
    fixture = TestBed.createComponent(EtbTotalContentPlaysComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
