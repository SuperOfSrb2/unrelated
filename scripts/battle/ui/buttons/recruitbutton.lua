---@class RecruitButton : ActionButton
---@overload fun(...) : RecruitButton
local RecruitButton, super = Class(ActionButton)

---@param battler PartyBattler
---@param x number
---@param y number
function RecruitButton:init(battler, x, y)
    super.init(self, battler, x, y)
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

return RecruitButton
