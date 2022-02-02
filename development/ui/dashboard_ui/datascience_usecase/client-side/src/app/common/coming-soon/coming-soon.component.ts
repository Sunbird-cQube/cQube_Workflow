import { Component, OnInit, ViewEncapsulation } from '@angular/core';
import { ActivatedRoute } from '@angular/router';

@Component({
  selector: 'app-coming-soon',
  templateUrl: './coming-soon.component.html',
  styleUrls: ['./coming-soon.component.css'],
  encapsulation: ViewEncapsulation.None
})
export class ComingSoonComponent implements OnInit {
  pageTitle;
  constructor(private route: ActivatedRoute,) { }

  ngOnInit(): void {
    document.getElementById('accessProgressCard').style.display = 'none';
    document.getElementById('backBtn') ? document.getElementById('backBtn').style.display = 'none' : "";
  }

}
