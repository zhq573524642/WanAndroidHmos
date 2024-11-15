import { FeatureUtils } from "lib_components"
import { ToastUtil } from "utils"
import { DateUtil } from "utils/src/main/ets/utils/DateUtil"

@CustomDialog
export struct CreateTodoDialog {
  controller: CustomDialogController
  @State todoTitle: string = ''
  @State todoDesc: string = ''
  @State currentDate: Date = new Date()
  @State todoDate: string = DateUtil.getTodayStr('yyyy-MM-dd')
  @State type: number = 1
  @State priority: number = 1
  onSaveCreateTodoCallback?: (title: string, desc: string, date: string, type: number, priority: number) => void

  build() {
    Column() {
      Text('新建待办清单').fontColor(Color.Black).fontSize(18).fontWeight(FontWeight.Bold)
        .margin({ top: 15, bottom: 15 })
      this.SelectTodoTypeView()
      this.SelectTodoPriorityView()
      Row() {
        Text('标题：').fontColor(Color.Black).fontSize(13)
        TextInput({ placeholder: '请输入标题（必填）', text: $$this.todoTitle })
          .height(45)
          .layoutWeight(1)
      }.padding({ left: 25, right: 25 })
      .width('100%')
      .margin({ top: 15 })

      Row() {
        Text('详情：').fontColor(Color.Black).fontSize(13)
        TextArea({ placeholder: '请输入详情（选填）', text: $$this.todoDesc })
          .layoutWeight(1)
          .constraintSize({
            minHeight: 60,
            maxHeight: 200
          })
          .maxLines(5)//最大行数
          .maxLength(100)//最大输入字符数
          .showCounter(true, {
            thresholdPercentage: 10, //thresholdPercentage是可输入字符数占最大字符限制的百分比值。大于百分比时显示
            highlightBorder: true
          })
          .enterKeyType(EnterKeyType.Done) //设置输入法回车键类型

      }.padding({ left: 25, right: 25 })
      .width('100%')
      .margin({ top: 12 })

      Row() {
        Text('时间：').fontColor(Color.Black).fontSize(13)
        TextInput({ placeholder: '请输入时间（必填）', text: $$this.todoDate })
          .height(45)
          .layoutWeight(1)
          .focusable(false)
          .onClick(() => {
            this.DatePickerDialogShow()
          })
      }.padding({ left: 25, right: 25 })
      .width('100%')
      .margin({ top: 12 })

      Row() {
        Button('取消')
          .backgroundColor(FeatureUtils.getGrayBgColor())
          .fontSize(14)
          .fontColor($r('app.color.color_999999'))
          .width(100)
          .onClick(() => {
            this.controller.close()
          })
        Button('保存')
          .backgroundColor($r('app.color.app_theme_color'))
          .fontSize(14)
          .fontColor(Color.White)
          .width(100)
          .onClick(() => {
            if (this.todoTitle == '') {
              ToastUtil.showCenterToast('请输入标题')
              return
            }
            this.onSaveCreateTodoCallback?.(this.todoTitle, this.todoDesc, this.todoDate, this.type, this.priority)
          })
      }.width('100%')
      .justifyContent(FlexAlign.SpaceEvenly)
      .margin({ bottom: 20, top: 20 })
    }.width('100%')
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  SelectTodoTypeView() {
    Row({ space: 18 }) {
      this.TodoRadioItem('todo_type', '工作', this.type == 1, 1, (isCheck: boolean, value: number) => {
        if (isCheck) {
          this.type = value
        }
      })
      this.TodoRadioItem('todo_type', '学习', this.type == 2, 2, (isCheck: boolean, value: number) => {
        if (isCheck) {
          this.type = value
        }
      })
      this.TodoRadioItem('todo_type', '生活', this.type == 3, 3, (isCheck: boolean, value: number) => {
        if (isCheck) {
          this.type = value
        }
      })
    }.alignItems(VerticalAlign.Center)
  }

  @Builder
  SelectTodoPriorityView() {
    Row({ space: 18 }) {
      this.TodoRadioItem('todo_priority', '重要', this.priority == 1, 1, (isCheck: boolean, value: number) => {
        if (isCheck) {
          this.priority = value
        }
      })
      this.TodoRadioItem('todo_priority', '一般', this.priority == 2, 2, (isCheck: boolean, value: number) => {
        if (isCheck) {
          this.priority = value
        }
      })
    }.alignItems(VerticalAlign.Center)
  }

  @Builder
  customRadioStyle() {
    Image($r('app.media.ic_smile_face')).width(20).height(20)
      .objectFit(ImageFit.Fill)
  }

  @Builder
  TodoRadioItem(group: string, title: string, check: boolean, value: number,
    onItemCheck: (isCheck: boolean, value: number) => void) {

    Row({ space: 10 }) {
      Radio({
        value: value + '',
        group: group,
        indicatorType: RadioIndicatorType.CUSTOM,
        indicatorBuilder: this.customRadioStyle()
      })
        .checked(check)
        .onChange((isCheck: boolean) => {
          onItemCheck(isCheck, value)
        })
        .width(25)
        .height(25)
      Text(title)
        .fontSize(12)
        .fontColor(Color.Black)
    }.alignItems(VerticalAlign.Center)
  }

  private DatePickerDialogShow() {
    DatePickerDialog.show({
      start: DateUtil.getTodayByFormatStr('yyyy-MM-dd'),
      end: new Date(2100, 12, 31),
      selected: this.currentDate,
      lunarSwitch: true, //是否展示切换农历的开关
      alignment: DialogAlignment.Bottom, //dialog展示的位置
      backgroundBlurStyle: BlurStyle.COMPONENT_ULTRA_THIN, //弹窗背板模糊材质
      shadow: ShadowStyle.OUTER_FLOATING_MD,
      onDateAccept: (value: Date) => {
        this.todoDate = DateUtil.getFormatDateStr(value, 'yyyy-MM-dd')
      },
      onCancel: () => {

      },
      onDateChange: (value: Date) => {
        this.currentDate = value
      }
    })
  }
}