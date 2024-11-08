export default class HarmonyListBean {
  links: HMLinks = new HMLinks()
  open_sources: HMOpenSources = new HMOpenSources()
  tools: HMTools = new HMTools()
}

export class HMLinks {
  name: string = ''
  articleList: Array<ArticlesData> = []
}

export class HMOpenSources {
  name: string = ''
  articleList: Array<ArticlesData> = []
}

export class HMTools {
  name: string = ''
  articleList: Array<ArticlesData> = []
}

export class ArticlesData {
  id: number = 0
  title: string = ''
  author: string = ''
  superChapterName: string = '' //所属类别名称
  chapterName: string = ''
  desc:string=''
  link:string=''
}
