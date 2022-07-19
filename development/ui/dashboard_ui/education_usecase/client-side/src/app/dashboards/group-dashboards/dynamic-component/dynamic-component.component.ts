import { Component, OnDestroy, OnInit } from '@angular/core';
import { ActivatedRoute, Router, Event, NavigationStart, NavigationEnd, NavigationError } from '@angular/router';
import { DataSourcesService } from "../data-sources.service";
import { dynamicReportService } from 'src/app/services/dynamic-report.service';
import { environment } from 'src/environments/environment';

@Component({
  selector: 'app-dynamic-component',
  templateUrl: './dynamic-component.component.html',
  styleUrls: ['./dynamic-component.component.css']
})
export class DynamicComponentComponent implements OnInit, OnDestroy {
  dataSource: any;
  cardList: any;
  private sub: any;
  card
  hideReport = environment.mapName
  program

  reportGroup = ""

  title = 'detect-route-change';
  currentRoute: string[];
  constructor(public sourceService: DataSourcesService, public route: Router, public configServic: dynamicReportService) {
    this.currentRoute = [];
    this.route.events.subscribe((event: Event) => {
      if (event instanceof NavigationStart) {
        
      }

      if (event instanceof NavigationEnd) {
        // Hide progress spinner or progress bar
        document.getElementById('spinner').style.display = "none"
        this.currentRoute = event.url.split("/");
        this.fetchCardConfig()

      }

      if (event instanceof NavigationError) {
        // Hide progress spinner or progress bar
        document.getElementById('spinner').style.display = "none"
        // Present error to user
        console.log(event.error);
      }
    });

  }

  ngOnInit(): void {
    this.dataSource = this.sourceService.dataSources;

  }

  ngOnDestroy() {
    // this.sub.unsubscribe();
  }

  navigate(data) {

  }

  fetchCardConfig() {

    this.configServic.configurableCardProperty().subscribe(res => {
      document.getElementById('spinner').style.display = "none"
      this.cardList = res['data']

      this.cardList = this.cardList.filter(card => card.report_name.toLowerCase() == this.currentRoute[2].toLowerCase())

      this.cardList = this.cardList.filter(card => this.hideReport === "none" ? card.report_type !== 'map' : card);


    })


  }

}
