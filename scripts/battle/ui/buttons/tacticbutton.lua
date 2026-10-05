---@class TacticButton : ActionButton
---@overload fun(...) : TacticButton
local TacticButton, super = Class(Object)

---@param battler PartyBattler
---@param x number
---@param y number
function TacticButton:init(battler, x, y)
    super.init(self, x, y, 31, 32)

    self.battler = battler

    self:setOrigin(0.5, 13 / 32)

    self.hovered = false
    self.disabled = false
end


function TacticButton:hasSpecial()
    return false
end

function TacticButton:isActive()
    return self.battler == Game.battle.party[Game.battle.current_selecting]
end

function TacticButton:setPartyBattler(battler)
    self.battler = battler
end

function TacticButton:getTexture()
    return Assets.getTexture("ui/battle/btn/tactic")
end

function TacticButton:getTextTexture()
    return Assets.getTexture("ui/battle/btn/tactic_b")
end


function TacticButton:getHoveredTexture()
    return Assets.getTexture("ui/battle/btn/tactic_h")
end

function TacticButton:getSpecialTexture()
    return Assets.getTexture("ui/battle/btn/tactic_a")
end

function TacticButton:getDisabledTexture()
    return Assets.getTexture("ui/battle/btn/tactic_d")
end

function TacticButton:select()
    Game.battle:setState("ENEMYSELECT", "TACTIC")
end

function TacticButton:update()
    self.battler = Game.battle.party[Game.battle.current_selecting]
end

function TacticButton:draw()
    if Game.battle.state == "ACTIONSELECT" then
        if self.disabled then
            Draw.draw(self:getDisabledTexture())
        elseif self:isActive() and self.hovered then
            Draw.draw(self:getHoveredTexture())
            
        else
            Draw.draw(self:getTexture())
            if self:isActive() and self:hasSpecial() then
                local r, g, b, a = self:getDrawColor()
                Draw.setColor(r, g, b, a * (0.4 + math.sin((Kristal.getTime() * 30) / 6) * 0.4))
                Draw.draw(self:getSpecialTexture())
            end
        end
    end
    if self:isActive() and self.hovered then
        Draw.draw(self:getTextTexture(), -self.x + 18, -self.y + 139)
    end

    super.draw(self)
end

return TacticButton
