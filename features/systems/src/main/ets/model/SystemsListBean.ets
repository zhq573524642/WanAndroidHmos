export class SystemsListBean {
  name: string = ''
  id: number = 0
  children: Array<SystemChildrenList> = []
}

export class SystemChildrenList {
  name: string = ''
  id: number = 0
}