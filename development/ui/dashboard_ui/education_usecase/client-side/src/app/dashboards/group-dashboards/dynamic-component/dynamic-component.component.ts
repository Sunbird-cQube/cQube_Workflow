import { Component, OnDestroy, OnInit } from '@angular/core';
import { ActivatedRoute } from '@angular/router';
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
  constructor(public sourceService: DataSourcesService, public route: ActivatedRoute, public configServic: dynamicReportService) {


  }

  ngOnInit(): void {
    this.dataSource = this.sourceService.dataSources;
     this.program = this.route.snapshot.paramMap.get('id');
   
    this.sub = this.route.params.subscribe(params => {
      this.program = params['id']; // (+) converts string 'id' to a number

      
    });
    
    this.fetchCardConfig()

  }

  ngOnDestroy() {
    this.sub.unsubscribe();
  }

  navigate(data) {

  }

  fetchCardConfig() {
    this.configServic.configurableCardProperty().subscribe(res => {
      this.cardList = res['data']

      
    })
  }

}
