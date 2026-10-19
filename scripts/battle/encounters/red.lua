local Red, super = Class(Encounter)

function Red:init()
    super.init(self)

    -- Text displayed at the bottom of the screen at the start of the encounter
    self.text = "* The dummy is here."

    self.music = "testbattle/mirrorboss"
    -- Enables the purple grid battle background
    self.background = true

    -- Add the dummy enemy to the encounter
    self:addEnemy("red", 3*270/3 + 23, 0 + 70)
    --self:addEnemy("megadummy", 4*270/3 + 23, 25 + 70)
    --self:addEnemy("dummy")
    --self:addEnemy("dummy")

    --- Uncomment this line to add another!
    --self:addEnemy("dummy")
end

return Red