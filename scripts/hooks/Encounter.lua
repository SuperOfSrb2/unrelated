---@class Encounter : Encounter
---@overload fun(...) : Encounter
local Encounter, super = Class("Encounter", true)

function Encounter:getPartyPosition(index)
    local x, y = 0, SCREEN_HEIGHT
    if #Game.battle.party == 1 then
        x = SCREEN_WIDTH/2
    elseif #Game.battle.party == 2 then
        x = 2*SCREEN_WIDTH/7 + (3*(index-1)*SCREEN_WIDTH/7)
    elseif #Game.battle.party == 3 then
        x = index*SCREEN_WIDTH/6 + (index-1)*SCREEN_WIDTH/6
    end

    local battler = Game.battle.party[index]
    local ox, oy = battler.chara:getBattleOffset()
    x = x + (battler.actor:getWidth()/2 + ox) * 2
    y = y + (battler.actor:getHeight()  + oy) * 2
    return x, y
end

return Encounter