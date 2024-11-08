/*
 * Copyright (c) 2023 Huawei Device Co., Ltd.
 * Licensed under the Apache License,Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { ConfigurationConstant } from '@kit.AbilityKit';
import { BreakpointTypeEnum, BreakpointType } from 'utils/src/main/ets/utils/BreakpointSystem';
import { AppConstants } from '../constants/AppConstants';
import { TabBarData, TabBarType, TabsInfo } from '../model/TabBarModel';

@Component
export struct CustomTabBar {
  @Link currentIndex: TabBarType;
  @StorageLink('currentBreakpoint') currentBreakpoint: BreakpointTypeEnum = BreakpointTypeEnum.MD;
  @StorageProp('naviIndicatorHeight') naviIndicatorHeight: number = 0;

  onChange(index: TabBarType): void {
    this.currentIndex = index;
  }

  build() {
    Flex({
      direction: this.currentBreakpoint === BreakpointTypeEnum.LG ? FlexDirection.Column : FlexDirection.Row,
      alignItems: ItemAlign.Center,
      justifyContent: FlexAlign.SpaceAround
    }) {
      ForEach(TabsInfo, (item: TabBarData) => {
        TabItem({
          index: item.id,
          selectedIndex: this.currentIndex,
          onChange: (index: number) => this.onChange(index)
        })
      }, (item: TabBarData) => item.id.toString())
    }
    .backgroundColor(this.currentBreakpoint === BreakpointTypeEnum.LG && this.currentIndex === TabBarType.MINE ?
    $r('sys.color.ohos_id_color_switch_bg_off') : Color.White)
    .backgroundBlurStyle(this.currentBreakpoint === BreakpointTypeEnum.LG && this.currentIndex === TabBarType.MINE ?
    BlurStyle.BACKGROUND_THIN : BlurStyle.NONE)
    .border({
      width: this.currentBreakpoint === BreakpointTypeEnum.LG ? { right: 0.5 } : {
        top: 0.5
      },
      color: $r('sys.color.ohos_id_color_text_field_sub_bg')
    })
    .padding(this.currentBreakpoint === BreakpointTypeEnum.LG ? {
      top: AppConstants.TAB_PERCENT,
      bottom: AppConstants.TAB_PERCENT
    } : { bottom: this.naviIndicatorHeight })
    .clip(false)
    .height(new BreakpointType<Length>({
      sm: AppConstants.TAB_HEIGHT + (this.naviIndicatorHeight || 0),
      md: AppConstants.TAB_HEIGHT + (this.naviIndicatorHeight || 0),
      lg: AppConstants.FULL_PERCENT
    }).getValue(this.currentBreakpoint))
    .width(new BreakpointType<Length>({
      sm: AppConstants.FULL_PERCENT,
      md: AppConstants.FULL_PERCENT,
      lg: 96
    }).getValue(this.currentBreakpoint))
  }
}

@Component
struct TabItem {
  @Prop index: number
  @Prop selectedIndex: number;
  onChange: (index: number) => void = () => {
  };
  private mainRenderingSettings: RenderingContextSettings = new RenderingContextSettings(true);
  private mainCanvasRenderingContext: CanvasRenderingContext2D =
    new CanvasRenderingContext2D(this.mainRenderingSettings);
  @StorageLink('currentBreakpoint') currentBreakpoint: BreakpointTypeEnum = BreakpointTypeEnum.MD;

  build() {
    Column() {
      Image(this.selectedIndex === this.index ? TabsInfo[this.index].activeIcon :
      TabsInfo[this.index].defaultIcon)
        .size({ width: 24, height: 24 })
      Text(TabsInfo[this.index].title)
        .fontSize('10fp')
        .margin({ top: 5 })
        .fontWeight(AppConstants.TAB_FONT_WEIGHT)
        .fontColor(this.index === this.selectedIndex ?
        $r('app.color.color_515151') :
        $r('app.color.color_dbdbdb'))
    }
    .clip(false)
    .padding(this.currentBreakpoint === BreakpointTypeEnum.LG ?
      { top: 8, bottom: 8 } :
      { left: 8, right: 8 })
    .layoutWeight(1)
    .size(this.currentBreakpoint === BreakpointTypeEnum.LG ?
      { width: AppConstants.FULL_PERCENT } :
      { height: AppConstants.FULL_PERCENT })
    .justifyContent(FlexAlign.Center)
    .onClick(() => {
      if (this.selectedIndex !== this.index) {
        this.onChange(this.index);
      }
    })
  }
}