---@class AttackBox : Object
---@overload fun(...) : AttackBox
local AttackBox, super = Class("AttackBox", true)

AttackBox.BOLTSPEED = 8

function AttackBox:getClose()
    --return MathUtils.round((self.bolt.x - self.bolt_target) / AttackBox.BOLTSPEED)
    local closest_enemy = Game.battle:getActiveEnemies()[1]
    local closest_record = 99999999
    for _,enemy in ipairs(Game.battle:getActiveEnemies()) do
        local enemycenter = enemy.x - 6--SCREEN_WIDTH/2 - enemy.x + enemy.width - 5 - Game.battle.battle_ui.selection_box.x
        local reticlex = -Game.battle.battle_ui.selection_box.x + SCREEN_WIDTH/2 - 245 + 510*Game.battle.reticleprogress
        local dist = math.abs(enemycenter - reticlex)
        local sparkle = Sprite("effects/criticalswing/sparkle", enemycenter, 160)
        sparkle:play(4 / 30, true)
        sparkle:setScale(2)
        sparkle.layer = BATTLE_LAYERS["above_battlers"]
        Game.battle:addChild(sparkle)
        if dist < closest_record then
            closest_record = dist
            closest_enemy = enemy
        end
    end
    return closest_record
end

return AttackBox