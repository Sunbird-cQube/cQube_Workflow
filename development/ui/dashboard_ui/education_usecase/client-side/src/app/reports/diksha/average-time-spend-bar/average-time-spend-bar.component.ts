import { ChangeDetectorRef, Component, OnInit } from "@angular/core";
import * as Highcharts from "highcharts";
import _ from "lodash";

import HC_exportData from "highcharts/modules/export-data";
import { AppServiceComponent } from "src/app/app.service";
import { AverageTimeSpendBarService } from "src/app/services/average-time-spend-bar.service";
import { ContentUsagePieService } from "src/app/services/content-usage-pie.service";
HC_exportData(Highcharts);

@Component({
  selector: "app-average-time-spend-bar",
  templateUrl: "./average-time-spend-bar.component.html",
  styleUrls: ["./average-time-spend-bar.component.css"],
})
export class AverageTimeSpendBarComponent implements OnInit {
  Highcharts: typeof Highcharts = Highcharts;
  chartOptions;

  public state;
  public reportName = "averageTimeSpend";
  public tooltipData = [];

  // to hide and show the hierarchy details
  public skul: boolean = true;
  public dist: boolean = false;
  public blok: boolean = false;
  public clust: boolean = false;

  public xAxisLabel: String = "Average Time ( Minutes )";

  public dataToDownload: any = [];
  public reportData: any = [];

  public fileName;

  constructor(
    private changeDetection: ChangeDetectorRef,
    public commonService: AppServiceComponent,
    public service: AverageTimeSpendBarService,
    public metaService: ContentUsagePieService
  ) {}

  width = window.innerWidth;
  height = window.innerHeight;
  onResize() {
    this.width = window.innerWidth;
    this.height = window.innerHeight;
  }

  ngOnInit(): void {
    this.changeDetection.detectChanges();
    this.state = this.commonService.state;
    document.getElementById("accessProgressCard").style.display = "none";
    document.getElementById("backBtn")
      ? (document.getElementById("backBtn").style.display = "none")
      : "";

    this.getStateData();
    this.getDistdata();
  }

  public data;
  public chartData = [];
  public catgory = [];

  emptyChart() {
    this.data = [];
    this.chartData = [];
    this.catgory = [];
  }

  getStateData() {
    this.fileName = `Average_Time_Spent_${this.state}`;
    try {
      this.service.getavgTimeSpendState().subscribe((res) => {
        this.data = res["data"]["data"];
        this.reportData = res["downloadData"]["data"];

        let obj = [];
        this.restructureBarChartData(this.data);
        
        this.getDistMeta();
        this.commonService.loaderAndErr(this.data);
      });
    } catch (error) {
      this.data = [];
      this.emptyChart();
      this.commonService.loaderAndErr(this.data);
    }
  }

  clickHome() {
    this.dist = false;
    this.skul = true;
    this.emptyChart();
    this.selectedDist = "";
    this.getStateData();
  }

  public distData;
  getDistdata() {
    this.emptyChart();
    this.distWiseData = [];

    try {
      this.service.getAvgTimespendDist().subscribe((res) => {
        this.distData = res["data"]["data"];
        this.commonService.loaderAndErr(this.distData);
      });
    } catch (error) {
      this.distData = [];
      this.emptyChart();
      this.commonService.loaderAndErr(this.distData);
    }
  }

  public result;
  restructureBarChartData(pieData) {
    this.emptyChart();
    this.chartData = [];
    this.result = pieData;
    try {
      if (this.result.length <= 25) {
        for (let i = 0; i <= 25; i++) {
          this.catgory.push(
            this.result[i]?.collection_name
              ? this.result[i]?.collection_name
              : " "
          );
        }
      } else {
        this.result.forEach((element) => {
          this.catgory.push(element.collection_name);
        });
      }

      this.result.forEach((element) => {
        this.chartData.push(element.avg_time_spent);
        this.tooltipData.push(element);
        this.commonService.loaderAndErr(this.chartData);
      });
    } catch (error) {
      this.chartData = [];
      this.emptyChart();
      this.commonService.loaderAndErr(this.chartData);
    }
  }

  public distMetaData;
  public distToDropDown;

  /// distMeta
  getDistMeta() {
    try {
      this.metaService.diskshaPieMeta().subscribe((res) => {
        this.distMetaData = res["data"];
        this.distToDropDown = this.distMetaData.Districts.map((dist: any) => {
          return dist;
        });
        this.distToDropDown.sort((a, b) =>
          a.district_name.localeCompare(b.district_name)
        );
      });
    } catch (error) {
      //  console.log(error)
    }
  }

  public selectedDist;
  public distWiseData = [];
  public distPieData;
  public distName;

  onDistSelected(data) {
    this.emptyChart();
    this.data = [];
    this.distPieData = [];
    this.dist = true;
    this.skul = false;
    this.distName = "";

    try {
      this.selectedDist = data;
      document.getElementById("spinner").style.display = "block";
      this.distToDropDown.filter((distName) => {
        if (distName.district_id === this.selectedDist) {
          this.distName = distName.district_name;
        }
      });
      this.fileName = `Average_time_spend_${this.distName}`;
      this.distWiseData = this.distData[this.selectedDist];
     
      setTimeout(() => {
        this.restructureBarChartData(this.distWiseData);
      }, 300);

    } catch (error) {
      this.distWiseData = [];
      this.emptyChart();
    }
  }

  //to filter downloadable data

  newDownload(element) {
    var data1 = {},
      data2 = {},
      data3 = {};
    Object.keys(element).forEach((key) => {
      data1[key] = element[key];
    });

    this.dataToDownload.push(data1);
  }

  //download UI data::::::::::::

  downloadReport() {
    this.dataToDownload = [];
    let selectedDistricts = [];

    if (this.selectedDist) {
      selectedDistricts = this.distToDropDown.filter((districtData) => {
        return districtData.district_id === this.selectedDist;
      });
    } else {
      selectedDistricts = this.distToDropDown.slice();
    }
    let reportData = _.cloneDeep(this.reportData);
    reportData.forEach((element) => {
  if(this.selectedDist === undefined){
    selectedDistricts.forEach((district) => {
      let distData = this.distData[district.district_id];
      let objectValue = distData.find(
        (metric) => metric.collection_name === element.collection_name
      );
      let distName = `${district.district_name}_Average_Time_Spent`;
      let distName1 = `${district.district_name}_Total_Enrolled`;

      element[distName] =
        objectValue !== undefined && objectValue.avg_time_spent
          ? objectValue.avg_time_spent
          : 0;

          element[distName1] =
        objectValue !== undefined && objectValue.total_enrolled
          ? objectValue.total_enrolled
          : 0;
    });
  }else{
    selectedDistricts.forEach((district) => {
      let distData = this.distData[district.district_id];
      let objectValue = distData.find(
        (metric) => metric.collection_name === element.collection_name
      );
      let distName = `${district.district_name}_Average_Time_Spent`;
      let distName1 = `${district.district_name}_Total_Enrolled`;

      element[distName] =
        objectValue && objectValue.avg_time_spent
          ? objectValue.avg_time_spent
          : 0;

          element[distName1] =
        objectValue && objectValue.total_enrolled
          ? objectValue.total_enrolled
          : 0;
    });
  }
      
      this.newDownload(element);
    });
    this.commonService.download(this.fileName, this.dataToDownload);
  }
  changeingStringCases(str) {
    return str.replace(/\w\S*/g, function (txt) {
      return txt.charAt(0).toUpperCase() + txt.substr(1).toLowerCase();
    });
  }
}
