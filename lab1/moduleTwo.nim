import wNim/[wApp, wFrame, wListBox, wTextCtrl, wButton]

proc funcModuleTwo*(txt: wTextCtrl) =
  # Створимо вікно з назвою Модуль 2 та певними розмірами  
  let internalFrame = Frame(title="Module 2", size=(300,260))

  # Розмістимо у ньому елемент ListBox
  let list = ListBox(internalFrame, pos=(0,0), size=(300, 150), style=wLbNeededScroll)

  # Та наповнимо цей елемент ітеративно
  for i in 1..6:
    # В даному разі & -- це оператор конкатенації (склеювання тексту),
    # а $ приводить примітив до текстового типу даних.
    list.append("ІП-9" & $i)
  
  # Створимо кнопки "Так" та "Відміна"
  let btnYes = Button(parent=internalFrame, label="Так", pos=(0, 170),
    size=(120, 40), style=wBuLeft)
  let btnCancel = Button(parent=internalFrame, label="Відміна", pos=(160, 170),
    size=(120, 40), style=wBuRight)
  
  # Якщо ми натиснули на клавішу "Так"...
  btnYes.wEvent_Button do ():
    # Отримаємо індекс обраного елемента у ListBox
    let index = getSelection(list)
    # Якщо нічого не обрано, отримаємо -1

    # Таким чином, якщо елемент таки обрано
    if index > -1:
      # Додаємо назву групи в кінець поля вводу
      txt.appendText(list[index] & " ")
      # Закриваємо вікно модуля
      internalFrame.delete()
  
  # Якщо натиснули клавішу "Відміна"
  btnCancel.wEvent_Button do ():
    # Закриваємо вікно модуля
    internalFrame.delete()
  
  # Розмістити вікно у центрі дисплею
  internalFrame.center()
  # Камера, мотор!
  internalFrame.show()