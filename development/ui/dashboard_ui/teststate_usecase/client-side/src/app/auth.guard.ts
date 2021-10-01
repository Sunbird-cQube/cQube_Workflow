import { Injectable } from '@angular/core';
import { CanActivate, CanActivateChild, CanLoad, Route, UrlSegment, ActivatedRouteSnapshot, RouterStateSnapshot, UrlTree, Router } from '@angular/router';
import { Observable } from 'rxjs';

@Injectable({
  providedIn: 'root'
})
export class AuthGuard implements CanActivate, CanActivateChild {
  data: boolean;
  constructor(private router: Router) { }
  public role = localStorage.getItem('roleName');
  public useCase = localStorage.getItem('usecase');
  canActivate(
    next: ActivatedRouteSnapshot,
    state: RouterStateSnapshot): Observable<boolean | UrlTree> | Promise<boolean | UrlTree> | boolean | UrlTree {
    var data = Object.values(next.data);
    if (data.includes(this.role)) {
    return true;
    }
    //this.router.navigate(['/**']);
    return false;
  }
  canActivateChild(
    next: ActivatedRouteSnapshot,
    state: RouterStateSnapshot): Observable<boolean | UrlTree> | Promise<boolean | UrlTree> | boolean | UrlTree {
    var data = Object.values(next.data);
    if (data.includes(this.role)) {
    return true;
    }
    //this.router.navigate(['/**']);
    return false;
  }
}
