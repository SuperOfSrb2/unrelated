---@class PartyBattler : PartyBattler
---@overload fun(...) : PartyBattler
local PartyBattler, super = Class("PartyBattler", true)

function PartyBattler:getStatusIcon()
    if self.chara:getHealth() <= 0 then
        return "down"
    elseif self.sleeping then
        return "sleep"
    elseif self.defending then
        return "defend"
    elseif self.action and self.action.icon then
        return self.action.icon
    else
        return "none"
    end
end

return PartyBattler