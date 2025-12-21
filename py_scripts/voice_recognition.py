from godot import exposed
from godot import *

@exposed
class ButtonPy(Button):
    lasbel: Label

    def _ready(self):
        self.lasbel = self.get_node("Label")
        self.connect("pressed", self, "button_pressed")

    def button_pressed(self):
        self.label.text = "another text"