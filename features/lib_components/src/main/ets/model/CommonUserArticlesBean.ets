import { CommonArticlesBean } from "./CommonArticlesBean"
import { CommonPagingBean } from "./CommonPagingBean"

export class CommonUserArticlesBean {
  shareArticles: CommonPagingBean<CommonArticlesBean> = new CommonPagingBean<CommonArticlesBean>()
  coinInfo: CoinInfo = new CoinInfo()
}

export class CoinInfo {
  /**
   * "coinCount": 72319,
   "level": 724,
   "nickname": "鸿洋",
   "rank": "18",
   "userId": 2,
   "username": "x**oyang"
   */
  coinCount: string = ''
  level: number = 0
  nickname: string = ''
  rank: number = 0
  userId: number = 0
  username: string = ''
}