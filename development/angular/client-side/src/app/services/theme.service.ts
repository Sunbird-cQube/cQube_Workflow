import { Injectable } from "@angular/core";
import { Theme, defaultTheme } from "../theme.model";

@Injectable({
  providedIn: 'root'
})
export class ThemeService {
  private active: Theme = defaultTheme;
  private availableThemes: Theme[] = [defaultTheme];


  constructor() {
    this.setTheme(this.active);
  }

  getAvailableThemes(): Theme[] {
    return this.availableThemes;
  }

  getActiveTheme(): Theme {
    return this.active;
  }

  isDarkTheme(): boolean {
    return this.active.name === defaultTheme.name;
  }
  setActiveTheme(theme: Theme): void {
    this.active = theme;

    Object.keys(this.active.properties).forEach(property => {
      document.documentElement.style.setProperty(
        property,
        this.active.properties[property]
      );
    });
  }


  setTheme(code): void {
    switch (code) {
      case "defaultTheme":
        this.setActiveTheme(defaultTheme);
        break;
    }
  }
}