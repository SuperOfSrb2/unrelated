---@class ActionBoxDisplay : Object
---@overload fun(...) : ActionBoxDisplay
local ActionBoxDisplay, super = Class(Object)

function ActionBoxDisplay:init(actbox, x, y)
    super.init(self, x, y)

    self.font = Assets.getFont("smallnumbers")
    self.font2 = Assets.getFont("name")

    self.actbox = actbox
end

function ActionBoxDisplay:draw()
    if 1 == 1 then
        Draw.setColor(self.actbox.battler.chara:getColor())
    else
        Draw.setColor(PALETTE["action_strip"], 1)
    end

    love.graphics.setLineWidth(2)
    love.graphics.line(0, -27, 213, -27)

    love.graphics.setLineWidth(2)
    if 1 == 1 then
        love.graphics.line(1  , -26, 1,   37)
        love.graphics.line(212, -26, 212, 37)
    end

    Draw.setColor(PALETTE["action_fill"])
    love.graphics.rectangle("fill", 2, -26, 209, 63)

    Draw.setColor(PALETTE["action_health_bg"])
    love.graphics.rectangle("fill", 114, 22 - self.actbox.data_offset, 90, 9)

    local health = (self.actbox.battler.chara:getHealth() / self.actbox.battler.chara:getStat("health")) * 90

    if health > 0 then
        Draw.setColor(self.actbox.battler.chara:getColor())
        love.graphics.rectangle("fill", 114, 22 - self.actbox.data_offset, math.ceil(health), 9)
    end

    Draw.setColor(PALETTE["action_health_bg"])
    love.graphics.rectangle("fill", 114, -4 - self.actbox.data_offset, 90, 9)

    local adrenaline = (self.actbox.battler.chara:getPastAdrenaline() / self.actbox.battler.chara:getStat("adrenaline")) * 90

    if adrenaline > 0 then
        Draw.setColor({0, 1, 1})
        love.graphics.rectangle("fill", 114, -4 - self.actbox.data_offset, math.ceil(adrenaline), 9)
    end

    local colorad = PALETTE["action_health_text"]
    if adrenaline <= 0 then
        colorad = PALETTE["action_health_text_down"]
    elseif (self.actbox.battler.chara:getHealth() <= (self.actbox.battler.chara:getStat("health") / 4)) then
        colorad = PALETTE["action_health_text_low"]
    else
        colorad = PALETTE["action_health_text"]
    end


    local health_offset = 0
    health_offset = (#tostring(self.actbox.battler.chara:getHealth()) - 1) * 8

    Draw.setColor(color)
    love.graphics.setFont(self.font)
    love.graphics.print(self.actbox.battler.chara:getHealth(), 152 - health_offset, 9 - self.actbox.data_offset)
    Draw.setColor(PALETTE["action_health_text"])
    love.graphics.print("/", 161, 9 - self.actbox.data_offset)
    local string_width = self.font:getWidth(tostring(self.actbox.battler.chara:getStat("health")))
    Draw.setColor(color)
    love.graphics.print(self.actbox.battler.chara:getStat("health"), 205 - string_width, 9 - self.actbox.data_offset)

    local health_offset = 0
    health_offset = (#tostring(self.actbox.battler.chara:getAdrenaline()) - 1) * 8

    Draw.setColor(colorad)
    love.graphics.setFont(self.font)
    love.graphics.print(self.actbox.battler.chara:getAdrenaline(), 152 - health_offset, -17 - self.actbox.data_offset)
    Draw.setColor(PALETTE["action_health_text"])
    love.graphics.print("/", 161, -17 - self.actbox.data_offset)
    local string_width = self.font:getWidth(tostring(self.actbox.battler.chara:getStat("adrenaline")))
    Draw.setColor(colorad)
    love.graphics.print(self.actbox.battler.chara:getStat("adrenaline"), 205 - string_width, -17 - self.actbox.data_offset)

    love.graphics.setFont(self.font2)
    local name_width = self.font2:getWidth(self.actbox.battler.chara.name)
    Draw.setColor(PALETTE["action_health_text"])
    love.graphics.printf(string.upper(self.actbox.battler.chara.name), -2, -16 - self.actbox.data_offset, 120, "center")

    super.draw(self)
end

function ActionBoxDisplay:update()
    self.actbox.battler.chara:updateAdrenaline()

    super.update(self)
end

return ActionBoxDisplay