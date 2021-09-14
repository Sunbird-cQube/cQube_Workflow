import { Component, Input, OnInit } from '@angular/core';
declare const $;

@Component({
  selector: 'app-info',
  templateUrl: './info.component.html',
  styleUrls: ['./info.component.css']
})
export class InfoComponent implements OnInit {
  @Input() tooltipText: string;
  constructor() { }

  ngOnInit(): void {
    $(function () {
      $('[data-toggle="tooltip"]').tooltip().on('inserted.bs.tooltip', function () {
        $("body div.tooltip-inner").css({
          "padding": "3%",
          "text-align": "center",
          "border-radius": "20px",
          "background-color": "black",
          "color": "white",
          "font-family": "Arial"
        });
      });
      $('[data-toggle="tooltip"]').click(function () {
        $('[data-toggle="tooltip"]').tooltip("hide");
      });
    });
  }


}
