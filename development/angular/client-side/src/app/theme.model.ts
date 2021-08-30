export interface Theme {
    name: string;
    properties: any;
  }
  
  export const light: Theme = {
    name: "light",
    properties: {
     "--theme-bg-color":"#fff",
    }
  };
  export const dark: Theme = {
    name: "dark",
    properties: {
      "--theme-bg-header-color":"#2ca8ff",
      "--theme-bg-sidenav-color":"#92cbf3",
      "--theme-bg-sidenav-user-info":"#d6e9f7",
      "--theme-dark-button-color": "#2ca8ff",
      "--theme-button-border-color": "#2ca8ff",
      "--theme-back-button-color": "#d6e9f7",
      "--theme-back-button-border-color": "#d6e9f7",
      "--theme-report-button-color": "#2ca8ff",
      "--theme-bg-container-color": "#daeefb",
      "--theme-report-header-bg-color": "#daeefb",
      "--theme-report-heading-color": "#023a61",
      "--theme-report-selected-level-color": "#2483c5",
      "--theme-text-color": "#000",
      "--theme-access-progress-card-btn-color": "#195b8a",
      "--theme-download-btn-color": "#195b8a",
      "--theme-user-info-bg-image":"url('../../../assets/images/bg-icon.png')",
      "--theme-container-bg-image":"url('../../../assets/images/user-info-bg-icon.svg')",
      "--theme-icon-color": "#d6e9f7"
      
    }
  };
  export const defaultTheme: Theme = {
    name: "default",
    properties: {
     "--theme-bg-header-color":"#fff",
     "--theme-bg-sidenav-color":"#FFC400",
     "--theme-bg-sidenav-user-info":"#FFE07B",
     "--theme-report-header-bg-color": "#ffebcc",
     "--theme-dark-button-color": "#0C54C6",
     "--theme-button-border-color": "#0C54C6",
     "--theme-back-button-color": "#dcdcdc",
     "--theme-report-button-color": "#98A0A3",
      "--theme-back-button-border-color": "#dcdcdc",
     "--theme-bg-container-color": "#ffebcc",
     "--theme-report-heading-color": "#000",
     "--theme-access-progress-card-btn-color": "#0545a5",
     "--theme-download-btn-color": "#0545a5",
     "--theme-report-selected-level-color": "#777",
     "--theme-text-color": "#000",
     "--theme-user-info-bg-image":"url('../../../assets/images/user-info-bg-icon.svg')",
     "--theme-container-bg-image":"url('../../../assets/images/bg-icon.png')",
     "--theme-icon-color": "#000"
    }
  };

  export const greenTheme: Theme = {
    name: "greenTheme",
    properties: {
     "--theme-bg-header-color":"#18ce0f",
     "--theme-bg-sidenav-color":"#53ff4b",
     "--theme-bg-sidenav-user-info":"#a8ffa4",
     "--theme-bg-container-color": "#d2fdd0",
     "--theme-report-header-bg-color": "#d2fdd0",
     "--theme-dark-button-color": "#18ce0f",
     "--theme-button-border-color": "#18ce0f",
     "--theme-back-button-color": "#a8ffa4",
     "--theme-report-button-color": "#18ce0f",
      "--theme-back-button-border-color": "#a8ffa4",
     "--theme-report-heading-color": "#287500",
     "--theme-report-selected-level-color": "#74c749",
     "--theme-text-color": "#000",
     "--theme-access-progress-card-btn-color": "#2d670f",
     "--theme-download-btn-color": "#2d670f",
     "--theme-icon-color": "#a8ffa4",
     "--theme-user-info-bg-image":"url('../../../assets/images/bg-icon.png')",
     "--theme-container-bg-image":"url('../../../assets/images/user-info-bg-icon.svg')"
    }
  };
  
  
//   export const red: Theme = {
//     name: "red",
//     properties: {
//         "--theme-bg-color":"#374AA0"
//     }
// }
// export const green: Theme = {
//     name: "green",
//     properties: {
//         "--theme-bg-color":"#18ce0f"
//     }
// }
// export const blue: Theme = {
//   name: "blue",
//   properties: {
//    "--theme-bg-color":"#2ca8ff"
//   }
// };
