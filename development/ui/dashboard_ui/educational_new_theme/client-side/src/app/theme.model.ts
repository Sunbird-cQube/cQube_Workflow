import { themeProperties } from './themes.config';

export interface Theme {
  name: string;
  properties: any;
}

export const defaultTheme: Theme = {
  name: "default",
  properties: {
    "--theme-bg-header-color": themeProperties.themeHeaderBackground,
    "--theme-bg-sidenav-color": themeProperties.themeSideNavBackground,
    "--theme-bg-sidenav-user-info": themeProperties.themeSideNavUserInfo,
    "--theme-report-header-bg-color": themeProperties.themeReportHeaderBackground,
    "--theme-dark-button-color": themeProperties.themeLogoutButtonBackgroundColor,
    "--theme-button-border-color": themeProperties.themeButtonBorderColor,
    "--theme-back-button-color": themeProperties.themeBackButtonBackgroundColor,
    "--theme-report-button-color": themeProperties.themeReportButtonBackgroundColor,
    "--theme-back-button-border-color": themeProperties.themeBackButtonBorderColor,
    "--theme-bg-container-color": themeProperties.themeContainerBackgroundColor,
    "--theme-report-heading-color": themeProperties.themeReportHeadingColor,
    "--theme-access-progress-card-btn-color": themeProperties.themeAccessProgressCardButtonBackgroundColor,
    "--theme-download-btn-color": themeProperties.themeDownloadButtonBackgroundColor,
    "--theme-report-selected-level-color": themeProperties.themeReportSelectedLevelColor,
    "--theme-text-color": themeProperties.themeSideNavTextColor,
    "--theme-user-info-bg-image": themeProperties.themeUserInfoBackgroundImage,
    "--theme-container-bg-image": themeProperties.themeContainerBackgroundImage,
    "--theme-icon-color": themeProperties.themeToggleIconColor
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
