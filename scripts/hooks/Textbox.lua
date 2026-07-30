local Textbox, super = Class("Textbox", true)

function Textbox:init(x, y, width, height, default_font, default_font_size, battle_box)
    super.init(self, x, y, width, height, default_font, default_font_size, battle_box)

    self.wrap_add_w = battle_box and -195 or 14
end

return Textbox