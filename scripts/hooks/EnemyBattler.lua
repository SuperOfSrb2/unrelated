local EnemyBattler, super = Class("EnemyBattler", true)

function EnemyBattler:update()
    local target_y = 135
    local going_down = false
    local going_up = false
    if self.hurt_timer > 0 then
        self.hurt_timer = Utils.approach(self.hurt_timer, 0, DT)

        if self.hurt_timer == 0 then
            self:onHurtEnd()
        end
    end
    
    if (Game.battle.state ~= "TRANSITION") then
        if (Game.battle.state == "DEFENDING") or (Game.battle.state == "ENEMYDIALOGUE") or (Game.battle.state == "DIALOGUEEND") or (Game.battle.state == "TRANSITIONOUT") or (Game.battle.state == "DEFENDINGBEGIN") or (Game.battle.state == "VICTORY") or (Game.battle.state == "DEFENDINGEND") or (Game.battle.state == "ATTACKING") or (Game.battle.state == "ACTIONSDONE") then
            target_y = 135.3
            going_down = false
            if self.y ~= target_y then
                going_up = true
            end
        else
            target_y = 250.3
            going_up = false
            if self.y ~= target_y then
                going_down = true
            end
        end

        if (self.y < target_y + self.default_y) and (going_down) then
            self.y = self.y + 15
        elseif going_down == true then
            --self.y = target_y
        end

        if (self.y > target_y + self.default_y) and (going_up) then
            self.y = self.y - 15
        elseif going_up == true then
            --self.y = target_y
        end
    end


    super.update(self)
end

return EnemyBattler