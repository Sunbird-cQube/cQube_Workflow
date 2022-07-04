import { Component, OnInit } from '@angular/core';
import { ActivatedRoute } from '@angular/router';
import { DataSourcesService } from "../data-sources.service";
import { dynamicReportService } from 'src/app/services/dynamic-report.service';
@Component({
  selector: 'app-dynamic-component',
  templateUrl: './dynamic-component.component.html',
  styleUrls: ['./dynamic-component.component.css']
})
export class DynamicComponentComponent implements OnInit {
  dataSource: any;
  cardList: any;
  card

  constructor(public sourceService: DataSourcesService, public route: ActivatedRoute, public configServic: dynamicReportService) {
    const filter = this.route.snapshot.queryParamMap.get(':id');
    
  }

  ngOnInit(): void {
    this.dataSource = this.sourceService.dataSources;
     this.fetchCardConfig()
  }

  navigate(data) {
  
  }

  fetchCardConfig(){
    this.configServic.configurableCardProperty().subscribe(res =>{
      this.cardList = res['data']
    })
  }

}
