@Component
export struct InputComponent {
  inputTitle: string = ''
  placeholder: string = '请输入内容'
  @Link inputContent: string

  build() {

    Row({ space: 10 }) {
      Text(this.inputTitle)
        .fontColor(Color.Grey)
        .fontSize(14)
      TextInput({
        placeholder: this.placeholder,
        text: $$this.inputContent,
      })
        .height('100%')
        .layoutWeight(1)
    }.width('100%')
    .height(60)
    .padding({ left: 15, right: 15 })
  }
}