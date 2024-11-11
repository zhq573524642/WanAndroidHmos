import { BaseViewModel } from 'commons';
import { httpARequestGet, ResponseResultC } from 'utils';
import { MineApi } from '../api/MineApi';
import { NavigationData } from '../model/NavigationData';

class NavigationViewModel extends BaseViewModel {
  getNavigationData(): Promise<Array<NavigationData>> {
    return new Promise<Array<NavigationData>>(async (resolve, reject) => {
      httpARequestGet<ResponseResultC<Array<NavigationData>>>(MineApi.API_NAVIGATION_LIST)
        .then((data: ResponseResultC<Array<NavigationData>>) => {
          if (data.errorCode === 0) {
            resolve(data.data)
          } else {
            reject(data.errorMsg)
          }
        })
        .catch((error: string) => {
          reject(error)
        })
    })
  }
}

let mNavigationViewModel = new NavigationViewModel()

export default mNavigationViewModel as NavigationViewModel