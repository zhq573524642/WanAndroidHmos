import { LoginPage } from 'login';
import { AppConstant, PreferenceManager, RouterUtil } from 'utils';
import { AppConstants } from '../constants/AppConstants';

import('login/src/main/ets/components/LoginPage');

@Entry
@Component
struct SplashPage {
  @State message: string = 'Hello World';

  aboutToAppear(): void {
    PreferenceManager.getInstance().getValue<string | null>(AppConstant.KEY_USERNAME)
      .then((username: string | null) => {
        if (username !== null) {
          setTimeout(() => {
            RouterUtil.replaceUrl('pages/Index')
          }, 2000)
        } else {
          RouterUtil.replaceNamedRoute('LoginPage')
        }
      })
  }

  build() {
    RelativeContainer() {
      Text(this.message)
        .id('SplashPageHelloWorld')
        .fontSize(50)
        .fontWeight(FontWeight.Bold)
        .alignRules({
          center: { anchor: '__container__', align: VerticalAlign.Center },
          middle: { anchor: '__container__', align: HorizontalAlign.Center }
        })
    }
    .height('100%')
    .width('100%')
  }
}