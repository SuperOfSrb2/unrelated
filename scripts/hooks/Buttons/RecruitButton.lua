---@class RecruitButton : RecruitionButton
---@overload fun(...) : RecruitButton
local RecruitButton, super = Class(RecruitionButton)

---@param battler PartyBattler
---@param x number
---@param y number
function RecruitButton:init(battler, x, y)
    super.init(self, battler, x, y)
end

function RecruitButton:getTexture()
    return Assets.getTexture("ui/battle/btn/Recruit")
end

function RecruitButton:getTextTexture()
    return Assets.getTexture("ui/battle/btn/Recruit_b")
end

function RecruitButton:getHoveredTexture()
    return Assets.getTexture("ui/battle/btn/Recruit_h")
end

function RecruitButton:getSpecialTexture()
    return Assets.getTexture("ui/battle/btn/Recruit_a")
end

function RecruitButton:getDisabledTexture()
    return Assets.getTexture("ui/battle/btn/Recruit_d")
end

function RecruitButton:select()
    Game.battle:setState("ENEMYSELECT", "Recruit")
end

return RecruitButton
