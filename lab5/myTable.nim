import wNim/[wApp, wFrame, wMacros, wListBox, wButton]

type
  wMyTable* = ref object of wFrame
    # Поля класу - графічні елементи
    # Це дає змогу взаємодіяти з елементами вікна
    # через сам об'єкт
    list: wListBox
    btnRemove*, btnChoose*, btnClear*: wButton

wClass(wMyTable of wFrame):
  
  proc add*(self: wMyTable, str: string) =
    self.list.append(str)

  proc remove*(self: wMyTable, index = self.list.len - 1) =
    self.list.delete(index)

  proc clear*(self: wMyTable) =
    self.list.clear()

  proc getIndex*(self: wMyTable): int =
    return self.list.getSelection()

  proc init*(self: wMyTable) =
    # Створимо вікно
    wFrame(self).init(title="MyTable", size=(310, 260),
      style=wCaption or wModalFrame)
    # У вікні - елемент ListBox (присвоїмо до поля екземляру класу,
    # щоб можна бул мати доступ до елементу через об'єкт)
    self.list = self.ListBox(pos=(0,0), size=(300, 150),
      style=wLbSingle or wLbAlwaysScroll)

    # Створимо кнопки "Видалити", "Позначити" та "Стерти все"
    # Вони теж присвоєні до полів екземпляру класу
    self.btnRemove = Button(parent=self, label="Видалити", pos=(0, 170),
      size=(90, 40), style=wBuLeft)
    self.btnChoose = Button(parent=self, label="Позначити", pos=(100, 170),
      size=(90, 40), style=wBuLeft)
    self.btnClear = Button(parent=self, label="Стерти все", pos=(200, 170),
      size=(90, 40), style=wBuRight)

let myTableSingleton = MyTable()

proc getMyTableInstance*(): wMyTable =
  return myTableSingleton