export class MineApi {
  static readonly API_COLLECTIONS: string = 'lg/collect/list/'
  static readonly API_WXARTICLE_LIST: string = 'wxarticle/chapters/json'
  static readonly API_NAVIGATION_LIST: string = 'navi/json'
  static readonly API_INTEGRAL_RANK_LIST: string = 'coin/rank/'
  static readonly API_CANCEL_COLLECT_FOR_COLLECTION: string = 'lg/uncollect/'
  static readonly API_GET_USER_INFO: string = 'user/lg/userinfo/json'
  static readonly API_GET_INTEGRAL_RECORD_LIST: string = 'lg/coin/list/'
  static readonly API_TOOLS_LIST: string = 'tools/list/json'
  static readonly API_TODO_LIST: string = 'lg/todo/v2/list/'
  static readonly API_TODO_CREATE: string = 'lg/todo/add/json'
  static readonly API_TODO_UPDATE: string = 'lg/todo/update/'
  static readonly API_TODO_DELETE: string = 'lg/todo/delete/'
  static readonly API_TODO_DONE: string = 'lg/todo/done/'
  static readonly API_COLLECT_OUTER_ARTICLE = 'lg/collect/add/json';//收藏站外文章
  static readonly API_EDIT_COLLECT_ARTICLE:string='lg/collect/user_article/update/'
}