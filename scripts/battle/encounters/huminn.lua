local Huminn, super = Class(Encounter)

function Huminn:init()
    super.init(self)

    -- Text displayed at the bottom of the screen at the start of the encounter
    self.text = "* The raven swoops in."

    -- Battle music ("battle" is rude buster)
    self.music = "battle"
    -- Enables the purple grid battle background
    self.background = true

    -- Add the dummy enemy to the encounter
    self:addEnemy("huminn", SCREEN_WIDTH/2, 75)

end

return Huminn