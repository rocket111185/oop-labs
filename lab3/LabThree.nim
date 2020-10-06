import wNim/[wApp, wFrame]
import shapeEditor

# Надто просто. Створити екземпляр вікна, показати в
# центрі, крутити цикл додатку.
let app = App()
let frame = ShapeObjectsEditor(title="Paint Editor")

frame.center()
frame.show()
app.mainLoop()

# Всього лише кілька рядків, і уже маємо готовий Paint.
# Звісно, якщо не враховувати реалізацію модулів.