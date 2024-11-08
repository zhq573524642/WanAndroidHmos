@Observed
export class CommonPagingBean<T> {
  curPage: number = 0
  offset: number = 0
  over: boolean = false
  pageCount: number = 0
  size: number = 0
  total: number = 0
  datas: Array<T> = []
}