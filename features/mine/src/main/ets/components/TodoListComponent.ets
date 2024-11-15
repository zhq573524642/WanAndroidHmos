import { BasePage } from "commons"
import { DefaultStateEnum } from "commons/src/main/ets/components/defaultState/DefaultStateEnum"
import { FooterLoadMoreStatus, HeaderRefreshStatus } from "commons/src/main/ets/components/SVRefresh/SVRefresh"
import { CommonPagingBean, FeatureUtils } from "lib_components"
import { AppConstant, DateUtil, EmitterUtils, ResponseResultC, ToastUtil } from "utils"
import LazyDataSource from "utils/src/main/ets/utils/LazyDataSource"
import { TodoList } from "../model/TodoListBean"
import mTodoViewModel from "../viewmodel/TodoViewModel"
import { emitter } from "@kit.BasicServicesKit"
import { CreateTodoDialog } from "./CreateTodoDialog"

@Component
export struct TodoListComponent {
  @State pageState: DefaultStateEnum = DefaultStateEnum.LOADING
  @State refreshStatus: HeaderRefreshStatus = HeaderRefreshStatus.inactive
  @State loadMoreStatus: FooterLoadMoreStatus = FooterLoadMoreStatus.inactive
  @State pageIndex: number = 1
  @State isAllLoadOver: boolean = false
  @State todoList: LazyDataSource<TodoList> = new LazyDataSource()
  @State msgError: string = '数据异常'
  @State type: number = 0 //工作1；生活2；娱乐3；
  @State status: number = 0 // 0未完成，1为完成
  @State priority: number = 0 //1重要 2一般
  @State orderby: number = 0 //1:完成日期顺序；2.完成日期逆序；3.创建日期顺序；4.创建日期逆序(默认)；
  //更新Todo
  @State updateTodoTitle: string = ''
  @State updateTodoDesc: string = ''
  @State updateTodoDate: string = DateUtil.getTodayStr('yyyy-MM-dd')
  @State updateType: number = 1
  @State updatePriority: number = 1
  @State updateTodoId: string = ''
  @State updateTodoIndex: number = 0
  updateTodoDialogController: CustomDialogController = new CustomDialogController({
    builder: CreateTodoDialog({
      todoTitle: this.updateTodoTitle,
      todoDesc: this.updateTodoDesc,
      todoDate: this.updateTodoDate,
      currentDate: DateUtil.getDateByDateStr(this.updateTodoDate),
      type: this.updateType,
      priority: this.updatePriority,
      onSaveCreateTodoCallback: (title: string, desc: string, date: string,
        type: number, priority: number) => {
        this.updateTodo(title, desc, date, type, priority)
      }
    }),
    backgroundColor: Color.White,
    autoCancel: true,
    alignment: DialogAlignment.Center,
    cornerRadius: 10
  })

  private updateTodo(title: string, desc: string, date: string,
    type: number, priority: number) {
    mTodoViewModel.updateTodo(this.updateTodoId, title, desc, date, type, priority)
      .then((data: ResponseResultC<''>) => {
        if (data.errorCode === 0) {
          ToastUtil.showCenterToast('修改成功')
          this.updateTodoDialogController.close()
          // this.todoList.dataArray.forEach((value: TodoList) => {
          //   if (value.id === this.updateTodoId) {
          //     value.title = title
          //     value.content = desc
          //     value.dateStr = date
          //     value.type = type
          //     value.priority = priority
          //   }
          // })
          // this.todoList.notifyDataReload()
        }
      })
      .catch((msg: string) => {
        ToastUtil.showCenterToast(msg)
      })
  }

  aboutToAppear(): void {
    EmitterUtils.getInstance().on(AppConstant.FLAG_CREATE_TODO, (eventData: emitter.EventData) => {
      this.pageIndex = 1
      this.getTodoList()
    })
    EmitterUtils.getInstance().on(AppConstant.FLAG_UPDATE_TODO, (eventData: emitter.EventData) => {
      this.pageIndex = 1
      this.getTodoList()
    })
    this.getTodoList()
  }

  aboutToDisappear(): void {
    EmitterUtils.getInstance().unregister(AppConstant.FLAG_CREATE_TODO)
  }

  build() {
    Column() {
      BasePage({
        pageState: this.pageState,
        refreshStatus: this.refreshStatus,
        loadMoreStatus: this.loadMoreStatus,
        msgError: this.msgError,
        ContentViewPage: (_scroller: Scroller) => {
          this.ItemListView(_scroller)
        },
        onRefreshing: () => {
          this.pageIndex = 1
          this.getTodoList()
        },
        onLoadingMore: () => {
          if (this.isAllLoadOver) {
            this.loadMoreStatus = FooterLoadMoreStatus.inactive
            ToastUtil.showToast('暂无更多数据')
            return
          }
          this.getTodoList()
        }
      })
    }.width('100%')
    .backgroundColor(FeatureUtils.getGrayBgColor())
    .layoutWeight(1)
  }

  @Builder
  ItemListView(scroller: Scroller) {
    List({ scroller: scroller }) {
      LazyForEach(this.todoList, (item: TodoList, index: number) => {
        ListItem() {
          TodoItemView({
            item: item,
            status: this.status
          })
        }
        .margin({
          left: 12,
          right: 12,
          top: index == 0 ? 12 : 6,
          bottom: 6
        })
        .swipeAction({
          end: {
            builder: () => {
              this.status == 0 ? this.ItemEndView(item, index) : undefined
            }
          }
        })
      }, (item: TodoList) => item.id)
    }.cachedCount(4)
  }

  @Builder
  ItemEndView(item: TodoList, index: number) {

    Row() {
      Stack() {
        Image($r("app.media.ic_todo_modify"))
          .width(25)
          .height(25)
          .objectFit(ImageFit.Cover)
      }.backgroundColor(Color.Gray)
      .width(80)
      .height(80)
      .onClick(() => {
        this.updateTodoTitle = item.title
        this.updateTodoDesc = item.content
        this.updateTodoDate = item.dateStr
        this.updateType = item.type
        this.updatePriority = item.priority
        this.updateTodoId = item.id
        this.updateTodoIndex = index
        this.updateTodoDialogController.open()
      })

      Stack() {
        Image($r("app.media.ic_todo_delete"))
          .width(25)
          .height(25)
          .objectFit(ImageFit.Cover)
      }.backgroundColor(Color.Red)
      .width(80)
      .height(80)
      .borderRadius({
        topLeft: 0,
        topRight: 10,
        bottomLeft: 0,
        bottomRight: 10
      })
    }.width(160)
    .height(80)
  }

  private getTodoList() {
    mTodoViewModel.getTodoList(this.pageIndex, this.status, this.type, this.orderby, this.priority)
      .then((data: CommonPagingBean<TodoList>) => {
        this.isAllLoadOver = data.over
        this.refreshStatus = HeaderRefreshStatus.inactive
        this.loadMoreStatus = FooterLoadMoreStatus.inactive
        if (data.total > 0) {
          this.pageState = DefaultStateEnum.NORMAL
        } else {
          this.pageState = DefaultStateEnum.EMPTY
        }
        if (data.curPage == 1) {
          this.pageIndex = 1
          this.todoList.clear()
        }
        this.pageIndex++
        this.todoList.appendArrayData(data.datas)
      })
      .catch((msg: string) => {
        this.msgError = msg
        this.pageState = DefaultStateEnum.ERROR
        this.refreshStatus = HeaderRefreshStatus.inactive
        this.loadMoreStatus = FooterLoadMoreStatus.inactive
      })
  }
}

@Component
struct TodoItemView {
  item: TodoList = new TodoList()
  status: number = 0

  build() {
    Stack({ alignContent: Alignment.End }) {
      Row() {
        Image(this.status == 0 ? $r('app.media.ic_todo_finish') : $r('app.media.ic_todo_back'))
          .width(28)
          .height(28)
          .objectFit(ImageFit.Fill)
        Column() {
          Text(this.item.title).fontColor(Color.Black).fontSize(15)
            .maxLines(1).textOverflow({ overflow: TextOverflow.Ellipsis })
          Text(this.item.content)
            .fontColor(Color.Gray)
            .fontSize(13)
            .margin({ top: 8 })
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
          Text(this.status == 0 ? '创建时间：' + this.item.dateStr
            : '完成时间：' + this.item.completeDateStr).fontColor(Color.Gray).fontSize(11)
            .margin({ top: 4 })

        }.layoutWeight(1)
        .margin({ left: 20 })
        .alignItems(HorizontalAlign.Start)
      }.width('100%')
      .padding({ left: 20, right: 20 })
      .height(80)
      .alignItems(VerticalAlign.Center)

      if (this.status == 1) {
        Image($r('app.media.ic_todo_finish_tag'))
          .width(60)
          .height(60)
          .margin({ right: 10 })
          .objectFit(ImageFit.Fill)
          .opacity(0.3)
      }
    }.backgroundColor(Color.White)
    .borderRadius(10)

  }
}