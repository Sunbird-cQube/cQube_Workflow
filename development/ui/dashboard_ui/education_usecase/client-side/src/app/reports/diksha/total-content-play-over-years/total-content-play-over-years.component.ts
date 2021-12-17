import { ChangeDetectorRef, Component, OnInit } from "@angular/core";
import * as Highcharts from "highcharts";
import _ from "lodash";

// import addMore from "highcharts/highcharts-more";
import HC_exportData from "highcharts/modules/export-data";
import { AppServiceComponent } from "src/app/app.service";
import { ContentUsagePieService } from "src/app/services/content-usage-pie.service";
import { TotalContentPlayLineCahrtService } from "src/app/services/total-content-play-line-cahrt.service";
HC_exportData(Highcharts);
// addMore(Highcharts)

@Component({
  selector: "app-total-content-play-over-years",
  templateUrl: "./total-content-play-over-years.component.html",
  styleUrls: ["./total-content-play-over-years.component.css"],
})
export class TotalContentPlayOverYearsComponent implements OnInit {
  Highcharts: typeof Highcharts = Highcharts;
  chartOptions;

  public state;
  public reportName = "overTheYears"
  constructor(
    private changeDetection: ChangeDetectorRef,
    public commonService: AppServiceComponent,
    public service: TotalContentPlayLineCahrtService,
    public metaService: ContentUsagePieService
  ) {}

  width = window.innerWidth;
  height = window.innerHeight;
  onResize() {
    this.width = window.innerWidth;
    this.height = window.innerHeight;
  }

  ngOnInit(): void {
    this.commonService.errMsg();
    this.changeDetection.detectChanges();
    this.state = this.commonService.state;
    document.getElementById("accessProgressCard").style.display = "none";
    document.getElementById("backBtn")
      ? (document.getElementById("backBtn").style.display = "none")
      : "";
    this.getStateData();
    // this.getDistrict()
  }

  public data;
  public reportData: any = [];
  public catgory = [];
  public chartData: any = [];
  public fileName = "Total_content_play_over_years";

  emptyChart() {
    this.chartData = [];
    this.reportData = [];
    this.fileName = "Total_content_play_over_years";
    // this.districtHierarchy = {};
    // this.blockHierarchy = {};
    // this.clusterHierarchy = {};
  }

  clickHome() {
    this.selectedDist = '';
    this.emptyChart();
    this.getStateData();
  }

  getStateData() {
    this.stateLevel = true;
    this.dist = false;
    try {
      this.service.getTotalCotentPlayLine().subscribe((res) => {
        this.data = res["data"];
        this.reportData = res["downloadData"]["data"];
        // let arr =[]
        this.data.data.forEach((element) => {
          this.chartData.push({
            name: element.month,
            y: element.plays,
          });
          this.catgory.push(element.month);
        });
        this.createLineChart(this.chartData);
        this.getDistMeta();
        this.commonService.loaderAndErr(this.chartData);
      });
    } catch (error) {
      this.chartData = [];
      this.commonService.loaderAndErr(this.chartData);
    }
  }
  public distData;
  public distChartData;

  getDistrict() {
    try {
      this.service.getDistTotalCotentPlayLine().subscribe((res) => {
        this.distData = res["data"];
      });
    } catch (error) {
      this.distData = [];
    }
  }

  public distMetaData;
  public selectedDistricts;
  public distToDropDown;
  /// distMeta
  getDistMeta() {
    try {
      this.metaService.diskshaPieMeta().subscribe((res) => {
        this.distMetaData = res["data"];
        this.selectedDistricts = [];
        this.distToDropDown = this.distMetaData.Districts.map((dist: any) => {
          this.selectedDistricts.push(dist.district_id);
          return dist;
        });

        this.distToDropDown.sort((a, b) =>
          a.district_name.localeCompare(b.district_name)
        );
        this.getDistrict();
      });
    } catch (error) {
      console.log(error);
    }
  }

  public selectedDist;
  public dist;
  public stateLevel;
  public distName;

  onDistSelected(data) {
    this.dist = true;
    this.stateLevel = false;
    this.chartData = [];
    this.selectedDist = data;
    try {
      this.distToDropDown.filter((distName) => {
        if (distName.district_id === this.selectedDist) {
          this.distName = distName.district_name;
        }
      });

      this.fileName = `Total_content_play_${this.distName}`;
      this.distChartData = this.distData.data.filter((dist) => {
        return dist.district_id == this.selectedDist;
      });

      this.distChartData.forEach((dist) => {
        this.distName = dist.district_name;
        this.chartData.push({
          name: dist.month,
          y: dist.plays,
        });
      });

      // this.reportData = this.chartData;
      this.createLineChart(this.chartData);
    } catch (error) {
      this.chartData = [];
      this.commonService.loaderAndErr(this.chartData);
    }
  }

  //to filter downloadable data
  public dataToDownload;

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

  // downloadReport() {
  //   this.dataToDownload = [];
  //   this.reportData.forEach((element) => {
  //     if(this.dist){
  //       this.selectedDistricts.forEach(district => {
  //        let distData = this.distData.data.filter((dist) => {
  //           return dist.district_id == district
  //         });
  //         // let distData = this.distData[district];
  //         let distName = distData[0].district_name;
  //         let objectValue = distData.find(metric => metric.month === element.month);
          
  //         element[distName] = objectValue && objectValue.plays ? objectValue.plays : 0;
  //       });
  //     }
     

  //     // }
  //     this.newDownload(element);
  //   });
  //   this.commonService.download(this.fileName, this.dataToDownload);
  // }


  downloadReport() {
    this.dataToDownload = [];
     let selectedDistricts = []
     
    if(this.selectedDist){
       selectedDistricts = this.distToDropDown.filter(districtData => {
          return districtData.district_id === this.selectedDist
        })
    }else{
       selectedDistricts = this.distToDropDown.slice()
    }
     let reportData = _.cloneDeep(this.reportData);
    reportData.forEach((element) => {
     selectedDistricts.forEach((district) => {
       
      //  let distData = this.distData[district.district_id]
        let distData = this.distData.data.filter(districtData => {
          return districtData.district_id === district.district_id
        })
            
        let objectValue = distData.find(
          (metric) => metric.month === element.month
        );

        let distName = district.district_name;

        element[distName] =
          objectValue && objectValue.plays
            ? objectValue.plays
            : 0;
       
      });
      this.newDownload(element);
    });
    this.commonService.download(this.fileName, this.dataToDownload, this.reportName);
  }


  changeingStringCases(str) {
    return str.replace(/\w\S*/g, function (txt) {
      return txt.charAt(0).toUpperCase() + txt.substr(1).toLowerCase();
    });
  }

  createLineChart(data) {
    // var pointStart = Date.UTC(2020,5,1);
    this.chartOptions = {
      chart: {
        type: "area",
        plotBackgroundColor: "transparent",
        plotBorderWidth: null,
        plotShadow: false,
        backgroundColor: "transparent",
      },
      title: {
        text: "",
      },
      yAxis: {
        title: {
          text: "Total Content Play",
        },
        style: {
          color: 'black',
          fontWeight: 'bold',
          fontSize: this.height > 1760 ? "30px" : this.height > 1160 && this.height < 1760 ? "20px" : this.height > 667 && this.height < 1160 ? "12px" : "10px"
        },
        // formatter: function () {
        //   return this.value.toString().replace(/(\d)(?=(\d\d)+\d$)/g, "$1,");
        // }
        labels: {
          formatter: function () {
              var label = this.axis.defaultLabelFormatter.call(this);

              // Use thousands separator for four-digit numbers too
              if (/^[0-9]{4}$/.test(label)) {
                  return Highcharts.numberFormat(this.value, 0);
              }
              return label;
          }
      }
      },

      xAxis: {
        title: {
          text: "Months",
          fontWeight: 900,
        },
        margin :"5px",
        style: {
          fontWeight: "900",
          color: 'black',
          fontSize: this.height > 1760 ? "30px" : this.height > 1160 && this.height < 1760 ? "20px" : this.height > 667 && this.height < 1160 ? "12px" : "10px"
        },
        label:{
          style:{
            fontWeight: "900"
          }
        },
        type: "datetime",
        // categories: []
        categories: this.catgory,
        // labels: {
        //   formatter: function() {
        //     return Highcharts.dateFormat('%b/%e/%Y', this.value);
        //   }
        // }
      },

      // xAxis: {
      //   title: {
      //     text: 'Days'
      // },
      //   min:Date.UTC(2020, 5, 1),
      //   max:Date.UTC(2021, 10, 1),
      //   //allowDecimals: false,
      //   type           : 'datetime',
      //   tickInterval   : 24 * 3600 * 1000*30, //one day
      //   labels         : {
      //       rotation : 0
      //   },
      // },
      credits: {
        enabled: false,
      },
      tooltip: {
        style: {
          fontSize: this.height > 1760 ? "32px" : this.height > 1160 && this.height < 1760 ? "22px" : this.height > 667 && this.height < 1160 ? "12px" : "10px",
          opacity: 1,
          backgroundColor: "white"
        },
        formatter: function () {
          if (this.point.category != 0) {
            return '<span> <b>  Month:' +' '+ this.x +
            '</b>'+ '<br>' +'<b> Total Content Play:' + ' '+ this.y.toLocaleString('en-IN')+ '</b></span>';
          } else {
            return false;
          }
        }
      },
      // legend: {
      //   layout: "vertical",
      //   align: "right",
      //   verticalAlign: "middle",
      // },

      plotOptions: {
        series: {
          events: {
            legendItemClick: function (e) {
              e.preventDefault();
            },
          },

          // pointStart      : pointStart,
          // pointInterval   : 24 * 3600 * 1000*30
        },
      },

      series: [
        {
          name: "Total Content Plays",
          data: data,
        },
      ],

      responsive: {
        rules: [
          {
            condition: {
              maxWidth: 500,
            },
            chartOptions: {
              legend: {
                layout: "horizontal",
                align: "center",
                verticalAlign: "bottom",
              },
            },
          },
        ],
      },
    };
    this.Highcharts.chart("container", this.chartOptions);
  }
}
