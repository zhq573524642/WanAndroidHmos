/*
 * Copyright (c) 2023 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { window } from '@kit.ArkUI';
import { AbilityConstant, common } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import Logger from './Logger';


const TAG: string = '[WindowUtil]';

export class WindowUtil {
  public static setWindowLayoutFullScreen(context: common.BaseContext, isLayoutFullScreen: boolean) {
    window.getLastWindow(context).then((windowClass: window.Window) => {
      let promise: Promise<void> = windowClass.setWindowLayoutFullScreen(isLayoutFullScreen);
      promise.then(() => {
        AppStorage.setOrCreate<boolean>('layoutfullscreen', isLayoutFullScreen);
        Logger.info(TAG, 'Succeeded in setting the window layout to full-screen mode.');
      }).catch((err: BusinessError) => {
        Logger.error(TAG, 'Failed to set the window layout to full-screen mode. Cause:' + JSON.stringify(err));
      });
    });
  }

  public static updateStatusBarEnable(context: common.BaseContext, isEnable: boolean) {
    window.getLastWindow(context, (err, w) => {
      let names: Array<'status' | 'navigation'> = isEnable ? ['status', 'navigation'] : []
      w.setWindowSystemBarEnable(names, (err) => {
        if (err.code) {
          console.error('Failed to set the system bar to be visible. Cause:' + JSON.stringify(err));
          return;
        }
        console.info('Succeeded in setting the system bar to be visible.');
      });

    })
  }

  public static updateStatusBarColor(context: common.BaseContext, statusBarContentColor?: string,
    statusBarColor?: string) {
    window.getLastWindow(context).then((windowClass: window.Window) => {
      try {
        windowClass.setWindowSystemBarProperties({
          statusBarContentColor: statusBarContentColor ? statusBarContentColor : '#ffffff',
          statusBarColor: statusBarColor ? statusBarColor : '#0090ff'
        }, (err) => {
          if (err.code) {
            Logger.error(TAG, 'Failed to set the system bar properties. Cause: ' + JSON.stringify(err));
            return;
          }
          Logger.info(TAG, 'Succeeded in setting the system bar properties.');
        });
      } catch (exception) {
        Logger.error(TAG, 'Failed to set the system bar properties. Cause: ' + JSON.stringify(exception));
      }
    });
  }

  public static requestFullScreen(windowStage: window.WindowStage, context: Context): void {
    windowStage.getMainWindow((err: BusinessError, data: window.Window) => {
      if (err.code) {
        Logger.error(TAG, 'Failed to obtain the main window. Cause: ' + JSON.stringify(err));
        return;
      }
      let windowClass: window.Window = data;
      Logger.info(TAG, 'Succeeded in obtaining the main window. Data: ' + JSON.stringify(data));

      // Realize the immersive effect
      let isLayoutFullScreen = true;
      try {
        // Get status bar height.
        let area: window.AvoidArea = windowClass.getWindowAvoidArea(window.AvoidAreaType.TYPE_SYSTEM);
        let naviBarArea: window.AvoidArea =
          windowClass.getWindowAvoidArea(window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR);
        Logger.info(TAG,
          'Succeeded get the window navigation indicator HEIGHT: ' + px2vp(naviBarArea.bottomRect.height) + ' area: ' +
          JSON.stringify(naviBarArea));
        WindowUtil.getDeviceSize(context, area, naviBarArea);
        if (area.topRect.height > 0) {
          let promise: Promise<void> = windowClass.setWindowLayoutFullScreen(isLayoutFullScreen);
          promise.then(() => {
            AppStorage.setOrCreate<boolean>('layoutfullscreen', isLayoutFullScreen);
            Logger.info(TAG, 'Succeeded in setting the window layout to full-screen mode.');
          }).catch((err: BusinessError) => {
            Logger.error(TAG, 'Failed to set the window layout to full-screen mode. Cause:' + JSON.stringify(err));
          });
        }
      } catch {
        Logger.error(TAG, 'Failed to set the window layout to full-screen mode. ');
      }
    });
  }

  public static setDeviceSize(windowStage: window.WindowStage, context: Context) {
    windowStage.getMainWindow((err: BusinessError, data: window.Window) => {
      if (err.code) {
        Logger.error(TAG, 'Failed to obtain the main window. Cause: ' + JSON.stringify(err));
        return;
      }
      let windowClass: window.Window = data;
      Logger.info(TAG, 'Succeeded in obtaining the main window. Data: ' + JSON.stringify(data));
      try {
        let area: window.AvoidArea = windowClass.getWindowAvoidArea(window.AvoidAreaType.TYPE_SYSTEM);
        let naviBarArea: window.AvoidArea =
          windowClass.getWindowAvoidArea(window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR);
        Logger.info(TAG,
          'Succeeded get the window navigation indicator HEIGHT: ' + px2vp(naviBarArea.bottomRect.height) + ' area: ' +
          JSON.stringify(naviBarArea));
        WindowUtil.getDeviceSize(context, area, naviBarArea);
      } catch {
        Logger.error(TAG, 'Failed to set the window layout to full-screen mode. ');
      }
    });
  }

  static getDeviceSize(context: common.BaseContext, area: window.AvoidArea, naviBarArea: window.AvoidArea): void {
    // Get device height.
    window.getLastWindow(context).then((data: window.Window) => {
      let properties = data.getWindowProperties();
      AppStorage.setOrCreate<number>('statusBarHeight', px2vp(area.topRect.height));
      AppStorage.setOrCreate<number>('naviIndicatorHeight', px2vp(naviBarArea.bottomRect.height));
      AppStorage.setOrCreate<number>('deviceHeight', px2vp(properties.windowRect.height));
      AppStorage.setOrCreate<number>('deviceWidth', px2vp(properties.windowRect.width));
    });
  }

  static setMainWindowRestricted(context: Context): void {
    window.getLastWindow(context).then((windowClass: window.Window) => {
      if (windowClass === undefined) {
        Logger.error(`MainWindowClass is undefined`);
        return;
      }
      // Setting restricted display.
      windowClass.setPreferredOrientation(window.Orientation.AUTO_ROTATION_RESTRICTED);
    });
  }

  static setMainWindowPortrait(context: Context): void {
    window.getLastWindow(context).then((windowClass: window.Window) => {
      if (windowClass === undefined) {
        Logger.error(`MainWindowClass is undefined`);
        return;
      }
      // Setting restricted display.
      windowClass.setPreferredOrientation(window.Orientation.PORTRAIT);
    });
  }

  static setMissionContinueActive(context: common.UIAbilityContext, active: boolean) {
    let activeState = active ? AbilityConstant.ContinueState.ACTIVE : AbilityConstant.ContinueState.INACTIVE;
    context.setMissionContinueState(activeState).then(() => {
      Logger.info('setMissionContinueState success');
    }).catch((err: BusinessError) => {
      Logger.error(`setMissionContinueState failed, code is ${err.code}, message is ${err.message}`);
    });
  }

  /**
   * 是否全屏获取
   * @param context
   * @returns
   */
  public static getIsFullScreen(context: common.BaseContext): Promise<boolean> {
    return new Promise(async (resolve: Function) => {
      window.getLastWindow(context).then((windowClass: window.Window) => {
        let isFull = windowClass.getWindowProperties().isLayoutFullScreen
        resolve(isFull)
      }).catch((err: BusinessError) => {
        Logger.error(`getIsFullScreen failed, code is ${err.code}, message is ${err.message}`);
      });
    });
  }

  public static setWindowPrivacy(context: common.BaseContext,isPrivacyMode: boolean) {
    window.getLastWindow(context).then((windowClass: window.Window) => {
      windowClass.setWindowPrivacyMode(isPrivacyMode)
    }).catch((err: BusinessError) => {
    });
  }
}