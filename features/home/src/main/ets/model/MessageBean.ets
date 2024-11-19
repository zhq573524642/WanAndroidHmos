@Observed
export class MessageBean {
  /**
   * "category": 999,
   "date": 1715734764000,
   "fromUser": "鸿洋",
   "fromUserId": 2,
   "fullLink": "https://developer.huawei.com/consumer/cn/activity/digixActivity/digixcmsdetail/401714100209201933?ha_source=infoq&amp;ha_sourceId=89000463",
   "id": 976063,
   "isRead": 1,
   "link": "https://developer.huawei.com/consumer/cn/activity/digixActivity/digixcmsdetail/401714100209201933?ha_source=infoq&amp;ha_sourceId=89000463",
   "message": "鸿蒙 24 年极客马拉松，奖励金几十万，此外还能提前解锁鸿蒙开发套件等，目前参赛队伍还比较少，建议学生、独立开发者可以关注一波。",
   "niceDate": "2024-05-15 08:59",
   "tag": "系统消息",
   "title": "鸿蒙编程赛，奖金几十万，推荐学生、独立开发者不要错过",
   "userId": 15630
   */

  title: string = ''
  message: string = ''
  niceDate: string = ''
  tag: string = ''
  id: string = ''
  fromUser: string = ''
  fromUserId: number = 0
  fullLink:string=''

}