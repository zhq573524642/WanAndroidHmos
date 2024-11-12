import { IntegralBean } from "./IntegralBean";

export class UserInfoBean {
  coinInfo: IntegralBean = new IntegralBean()
  collectArticleInfo: CollectArticleInfo = new CollectArticleInfo()
  userInfo: UserInfo = new UserInfo()
}

class CollectArticleInfo {
  count: number = 0
}

export class UserInfo {
  /**
   * "admin": false,
   "chapterTops": [],
   "coinCount": 1500,
   "collectIds": [],
   "email": "",
   "icon": "",
   "id": 15630,
   "nickname": "17610676602",
   "password": "",
   "publicName": "17610676602",
   "token": "",
   "type": 0,
   "username": "17610676602"
   */
  coinCount: string = ''
  id: string = ''
  nickname: string = ''
  publicName: string = ''
  username: string = ''
}
