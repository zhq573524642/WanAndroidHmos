

@Observed
export class TodoList {
  /**
   *  "completeDate": null,
   "completeDateStr": "",
   "content": "44444555555555555555",
   "date": 1731686400000,
   "dateStr": "2024-11-16",
   "id": 37992,
   "priority": 0,
   "status": 0,
   "title": "4444444444444",
   "type": 0,
   "userId": 15630
   */
  title: string = ''
  content: string = ''
  dateStr: string = ''
  completeDateStr:string=''
  id: string = ''
  status: number = 0// 0为未完成，1为完成
  type: number = 0//工作1；学习2；生活3；
  userId: number = 0
  priority:number=0//1重要 2一般
}