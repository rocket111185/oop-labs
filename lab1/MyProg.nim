import sugar
import nigui
import moduleOne

const buttonWidth = 150

app.init()

var window = newWindow()
var mainContainer = newLayoutContainer(Layout_Vertical)
window.add(mainContainer)

var buttons = newLayoutContainer(Layout_Horizontal)
mainContainer.add(buttons)

var textArea = newTextArea()
mainContainer.add(textArea)
textArea.addLine("Встановлено логування.")

var button1 = newButton("Модуль 1")
buttons.add(button1)
button1.width = buttonWidth
button1.onClick = (event: ClickEvent) =>
  func_mod_one(window, textArea)

window.show()
app.run()