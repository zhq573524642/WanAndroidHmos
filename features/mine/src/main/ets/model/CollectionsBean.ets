@Observed
export class CollectionsBean {
  curPage: number = 0
  offset: number = 0
  over: boolean = false
  pageCount: number = 0
  size: number = 0
  total: number = 0
  datas: Array<CollectionsList> = []
}

@Observed
export class CollectionsList {
  author: string = ''
  title: string = ''
  chapterName: string = ''
  niceDate: string = ''
  id: string = ''
}