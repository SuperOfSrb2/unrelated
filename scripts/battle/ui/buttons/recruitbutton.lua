---@class RecruitButton : ActionButton
---@overload fun(...) : RecruitButton
local RecruitButton, super = Class(Object)

---@param battler PartyBattler
---@param x number
---@param y number
function RecruitButton:init(battler, x, y)
    super.init(self, x, y, 31, 32)

    self.battler = battler

    self:setOrigin(0.5, 13 / 32)

    self.hovered = false
    self.disabled = false
end


function RecruitButton:hasSpecial()
    return false
end

function RecruitButton:isActive()
    return self.battler == Game.battle.party[Game.battle.current_selecting]
end

function RecruitButton:setPartyBattler(battler)
    self.battler = battler
end

function RecruitButton:getTexture()
    return Assets.getTexture("ui/battle/btn/recruit")
end

function RecruitButton:getTextTexture()
    return Assets.getTexture("ui/battle/btn/recruit_b")
end

function RecruitButton:getHoveredTexture()
    return Assets.getTexture("ui/battle/btn/recruit_h")
end

function RecruitButton:getSpecialTexture()
    return Assets.getTexture("ui/battle/btn/recruit_a")
end

function RecruitButton:getDisabledTexture()
    return Assets.getTexture("ui/battle/btn/recruit_d")
end

function RecruitButton:select()
    Game.battle:setState("ENEMYSELECT", "RECRUIT")
end

function RecruitButton:update()
    self.battler = Game.battle.party[Game.battle.current_selecting]
end

function RecruitButton:draw()
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

return RecruitButton
