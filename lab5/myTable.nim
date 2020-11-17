import wNim/[wApp, wFrame, wMacros, wListBox, wButton]

type
  wMyTable* = ref object of wFrame
    list*: wListBox
    btnRemove*, btnClear*: wButton

wClass(wMyTable of wFrame):
  
  proc add*(self: wMyTable, str: string) =
    self.list.append(str)

  proc remove*(self: wMyTable, index = self.list.len - 1) =
    self.list.delete(index)

  proc clear*(self: wMyTable) =
    self.list.clear()

  proc init*(self: wMyTable) =
    wFrame(self).init(title="MyTable", size=(310, 260),
      style=wCaption)
    self.list = self.ListBox(pos=(0,0), size=(300, 150),
      style=wLbSingle or wLbAlwaysScroll)

    # Створимо кнопки "Так" та "Відміна"
    self.btnRemove = Button(parent=self, label="Видалити", pos=(0, 170),
      size=(120, 40), style=wBuLeft)
    self.btnClear = Button(parent=self, label="Стерти все", pos=(170, 170),
      size=(120, 40), style=wBuRight)

when isMainModule:
  let app = App()
  let table = MyTable()

  for i in 0..20:
    table.add($i)

  table.center()
  table.show()
  app.mainLoop()
