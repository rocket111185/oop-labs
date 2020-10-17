import wNim/[wApp, wStatusBar, wMemoryDC, wPaintDC]

# Оголосимо тип, який є батьком (і походить
# від внутрішнього типу "вікно")
type
  wEditor* = ref object of wFrame
    mMemDc*: wMemoryDC

# Ця функція записує інформацію на нижній рядок
proc information*(self: wEditor, msg: string) =  
  self.statusBar.setStatusText(msg)

# Ця функція очищає екран
proc clearScreen*(self: wEditor) =
  self.mMemDc.clear()
  self.refresh(eraseBackground=false)

# Ця функція переносить графічну інформацію з пам'яті
# на дисплей (інакше нічого не бачитимемо)
proc repaint*(self: wEditor) =
  var dc = PaintDC(self)
  let size = dc.size
  dc.blit(source=self.mMemDc, width=size.width, height=size.height)
  dc.delete
