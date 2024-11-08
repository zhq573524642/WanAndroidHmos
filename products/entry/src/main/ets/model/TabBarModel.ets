/*
 * Copyright (c) 2023 Huawei Device Co., Ltd.
 * Licensed under the Apache License,Version 2.0 (the 'License');
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an 'AS IS' BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

export interface TabBarData {
  id: TabBarType;
  title: ResourceStr;
  activeIcon: ResourceStr;
  defaultIcon: ResourceStr;
}

export enum TabBarType {
  HOME = 0,
  HMOS,
  SYSTEMS,
  QUESTIONS,
  MINE
}

export const TabsInfo: TabBarData[] = [
  {
    id: TabBarType.HOME,
    title: $r('app.string.str_tab_home'),
    activeIcon: $r('app.media.ic_main_1_select'),
    defaultIcon: $r('app.media.ic_main_1_unselect')
  },
  {
    id: TabBarType.HMOS,
    title: $r("app.string.str_tab_hmos"),
    activeIcon: $r('app.media.ic_hm_select'),
    defaultIcon: $r('app.media.ic_hm_unselect')
  },
  {
    id: TabBarType.SYSTEMS,
    title: $r('app.string.str_tab_systems'),
    activeIcon: $r('app.media.ic_main_3_select'),
    defaultIcon: $r('app.media.ic_main_3_unselect')
  },
  {
    id: TabBarType.QUESTIONS,
    title: $r("app.string.str_tab_question"),
    activeIcon: $r('app.media.ic_main_wenda_select'),
    defaultIcon: $r('app.media.ic_main_wenda_unselect')
  },
  {
    id: TabBarType.MINE,
    title: $r('app.string.str_tab_mine'),
    activeIcon: $r('app.media.ic_main_5_select'),
    defaultIcon: $r('app.media.ic_main_5_unselect')
  }
]