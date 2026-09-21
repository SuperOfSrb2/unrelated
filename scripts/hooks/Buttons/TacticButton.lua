---@class TacticButton : TacticionButton
---@overload fun(...) : TacticButton
local TacticButton, super = Class(TacticionButton)

---@param battler PartyBattler
---@param x number
---@param y number
function TacticButton:init(battler, x, y)
    super.init(self, battler, x, y)
end

function TacticButton:getTexture()
    return Assets.getTexture("ui/battle/btn/Tactic")
end

function TacticButton:getTextTexture()
    return Assets.getTexture("ui/battle/btn/Tactic_b")
end


function TacticButton:getHoveredTexture()
    return Assets.getTexture("ui/battle/btn/Tactic_h")
end

function TacticButton:getSpecialTexture()
    return Assets.getTexture("ui/battle/btn/Tactic_a")
end

function TacticButton:getDisabledTexture()
    return Assets.getTexture("ui/battle/btn/Tactic_d")
end

function TacticButton:select()
    Game.battle:setState("ENEMYSELECT", "Tactic")
end

return TacticButton
