export default class HomeArticleListBean {
  curPage: number = 0
  //当前页码
  offset: number = 0
  over: boolean = false
  //是否全部加载完
  pageCount: number = 0
  //总页数
  size: number = 20
  //煤业数据量
  total: number = 0
  //数据总量
  datas: Array<ArticlesData> = []
}

@Observed
export class ArticlesData {
  fresh: boolean = false //是否最新的
  title: string = ''
  author: string = ''
  shareUser: string = '' //此处不为空，则author为空
  superChapterName: string = '' //所属类别名称
  chapterName: string = ''
  niceDate: string = '' //时间
  collect: boolean = false //是否收藏
  name: string = ''
  id: number = 0
}