import { environment } from 'src/environments/environment';
import { themeProperties } from './themes.config';

export interface Theme {
  name: string;
  properties: any;
}

let selectedTheme = themeProperties[`${environment.theme}`];

export const defaultTheme: Theme = {
  name: "default",
  properties: {
    "--theme-bg-header-color": selectedTheme.themeHeaderBackground,
    "--theme-bg-sidenav-color": selectedTheme.themeSideNavBackground,
    "--theme-bg-sidenav-user-info": selectedTheme.themeSideNavUserInfo,
    "--theme-report-header-bg-color": selectedTheme.themeReportHeaderBackground,
    "--theme-dark-button-color": selectedTheme.themeLogoutButtonBackgroundColor,
    "--theme-button-border-color": selectedTheme.themeButtonBorderColor,
    "--theme-back-button-color": selectedTheme.themeBackButtonBackgroundColor,
    "--theme-report-button-color": selectedTheme.themeReportButtonBackgroundColor,
    "--theme-back-button-border-color": selectedTheme.themeBackButtonBorderColor,
    "--theme-bg-container-color": selectedTheme.themeContainerBackgroundColor,
    "--theme-report-heading-color": selectedTheme.themeReportHeadingColor,
    "--theme-access-progress-card-btn-color": selectedTheme.themeAccessProgressCardButtonBackgroundColor,
    "--theme-download-btn-color": selectedTheme.themeDownloadButtonBackgroundColor,
    "--theme-report-selected-level-color": selectedTheme.themeReportSelectedLevelColor,
    "--theme-text-color": selectedTheme.themeSideNavTextColor,
    "--theme-user-info-bg-image": selectedTheme.themeUserInfoBackgroundImage,
    "--theme-container-bg-image": selectedTheme.themeContainerBackgroundImage,
    "--theme-icon-color": selectedTheme.themeToggleIconColor
  }
};

// export const greenTheme: Theme = {
//   name: "greenTheme",
//   properties: {
//     "--theme-bg-header-color": "#18ce0f",
//     "--theme-bg-sidenav-color": "#53ff4b",
//     "--theme-bg-sidenav-user-info": "#a8ffa4",
//     "--theme-bg-container-color": "#d2fdd0",
//     "--theme-report-header-bg-color": "#d2fdd0",
//     "--theme-dark-button-color": "#18ce0f",
//     "--theme-button-border-color": "#18ce0f",
//     "--theme-back-button-color": "#a8ffa4",
//     "--theme-report-button-color": "#18ce0f",
//     "--theme-back-button-border-color": "#a8ffa4",
//     "--theme-report-heading-color": "#287500",
//     "--theme-report-selected-level-color": "#74c749",
//     "--theme-text-color": "#000",
//     "--theme-access-progress-card-btn-color": "#2d670f",
//     "--theme-download-btn-color": "#2d670f",
//     "--theme-icon-color": "#a8ffa4",
//     "--theme-user-info-bg-image": "url('../../../assets/images/bg-icon.png')",
//     "--theme-container-bg-image": "url('../../../assets/images/user-info-bg-icon.svg')"
//   }
// };


// //   export const red: Theme = {
// //     name: "red",
// //     properties: {
// //         "--theme-bg-color":"#374AA0"
// //     }
// // }
// // export const green: Theme = {
// //     name: "green",
// //     properties: {
// //         "--theme-bg-color":"#18ce0f"
// //     }
// // }
// // export const blue: Theme = {
// //   name: "blue",
// //   properties: {
// //    "--theme-bg-color":"#2ca8ff"
// //   }
// // };
