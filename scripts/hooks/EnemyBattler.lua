local EnemyBattler, super = Class("EnemyBattler", true)

function EnemyBattler:init(actor, use_overlay)
    super.init(self)
    self.name = "Test Enemy"

    if actor then
        self:setActor(actor, use_overlay)
    end

    self.max_health = 100
    self.health = 100
    self.attack = 1
    self.defense = 0

    self.money = 0
    self.experience = 0 -- currently useless, maybe in later chapters?

    self.tired = false
    self.mercy = 0

    self.spare_points = 0

    -- Whether this enemy runs/slides away when defeated/spared
    self.exit_on_defeat = true

    -- Whether this enemy is automatically spared at full mercy
    self.auto_spare = false

    self.can_freeze = true

    self.selectable = true

    self.dmg_sprites = {}
    self.dmg_sprite_offset = { 0, 0 }

    self.disable_mercy = false

    self.done_state = nil

    self.waves = {}

    self.check = "Remember to change\nyour check text!"

    self.text = {}

    self.low_health_text = nil
    self.tired_text = nil
    self.spareable_text = nil

    self.tired_percentage = 0.5
    self.low_health_percentage = 0.5

    -- This is set to nil in `battler.lua` as well, but it's here for completion's sake.

    -- Speech bubble style - defaults to "round" or "cyber", depending on chapter
    self.dialogue_bubble = nil

    self.dialogue_offset = { 0, 0 }

    self.dialogue = {}

    self.acts = {
        {
            ["name"] = "Check",
            ["description"] = Game:getConfig("checkActDescription") and "Useless\nanalysis" or "",
            ["party"] = {},
            ["character"] = "empty"
        },
        {
            ["name"] = "Tattle",
            ["description"] = Game:getConfig("checkActDescription") and "Useless\nanalysis" or "",
            ["party"] = {},
            ["character"] = "wolfye"
        },
        {
            ["name"] = "Peek",
            ["description"] = Game:getConfig("checkActDescription") and "Useless\nanalysis" or "",
            ["party"] = {},
            ["character"] = "harriet"
        }
    }

    self.hurt_timer = 0
    self.comment = ""
    self.icons = {}
    self.defeated = false

    self.current_target = "ANY"

    self.temporary_mercy = 0
    self.temporary_mercy_percent = nil

    self.graze_tension = 1.6 -- (1/10 of a defend, or cheap spell)
end

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