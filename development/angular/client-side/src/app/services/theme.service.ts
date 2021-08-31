import { Injectable } from "@angular/core";
import { Theme, light, dark,  defaultTheme, greenTheme } from "../theme.model";

@Injectable({
    providedIn: 'root'
  })
  export class ThemeService {
    private active: Theme = light;
    private availableThemes: Theme[] = [light, dark];
  

constructor (){
  this.setTheme(this.active)
}

    getAvailableThemes(): Theme[] {
      return this.availableThemes;
    }
  
    getActiveTheme(): Theme {
      return this.active;
    }
  
    isDarkTheme(): boolean {
      return this.active.name === dark.name;
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
        switch (code){
            case "dark":
                this.setActiveTheme(dark);
                break;
             case "light":
                this.setActiveTheme(light);
                break; 
            case "greenTheme":
                this.setActiveTheme(greenTheme);
                break;
            //  case "red":
            //     this.setActiveTheme(red);
            //     break; 
          
            // case "blue":
            //     this.setActiveTheme(blue);
            //     break;
            case "defaultTheme":
                this.setActiveTheme(defaultTheme);
                break;
        }
      }


    
  }