---@class BattleSelectionBox : Object 
---@overload fun(...) : BattleSelectionBox
local BattleSelectionBox, super = Class(Object)

--TacticButton = require("mods.unrelated.scripts.battle.ui.buttons.tacticbutton")
--RecruitButton = require("mods.unrelated.scripts.battle.ui.buttons.recruitbutton")

function BattleSelectionBox:init(x, y)
    super.init(self, 32 + x, -100 + y)

    self.selection_siner = 0

    self.xoffset = x
    self.yoffset = y
    self.layer = -9999999999
    self.ui = nil

    for index,battler in ipairs(Game.battle.party) do
        self.battler = battler
    end

    self.selected_button = 1
    
    self.buttons = {}

    self.animation_done = true
    self.animation_timer = 0
    self.animate_out = false

    self.animation_y = 0
    self.animation_y_lag = 0

    self.shown = false

    self.begun = false
    self.lastselected = {}

    self:createButtons()
end

function BattleSelectionBox:draw()
    if (Game.battle.current_selecting == 1) or (Game.battle.current_selecting == 2) or (Game.battle.current_selecting == 3) then
        local nuts = Game.battle.current_selecting
        Draw.setColor({0, 0, 0})
        love.graphics.rectangle("fill", 0, 0, SCREEN_WIDTH - 140 + 45 + 32, 140)
        Draw.setColor(Game.battle.party[nuts].chara:getColor())
        love.graphics.setLineWidth(3)
        love.graphics.rectangle("line", 0, 0, SCREEN_WIDTH - 140 + 45 + 32, 140)
        love.graphics.line(110, 0, 110, 140)

        local oneoff = 0
        local twooff = 38
        if Game.battle.state == "ACTIONSELECT" then
            oneoff = -113
            twooff = -427
        end
        
        local r,g,b,a = Game.battle.party[nuts].chara:getColor()

        for i = 0, 11 do
            local siner = self.selection_siner + (i * (10 * math.pi))

            love.graphics.setLineWidth(2)
            Draw.setColor(r, g, b, a * math.sin(siner / 60) - 0.3)
            if math.cos(siner / 60) < 0 then
                love.graphics.line(1 - (math.sin(siner / 60) * 30) + 30 + 111 + oneoff, 1, 1 - (math.sin(siner / 60) * 30) + 30 + 111 + oneoff, 138)
                love.graphics.line(211 + (math.sin(siner / 60) * 30) - 30 + 326 + twooff, 1, 211 + (math.sin(siner / 60) * 30) - 30 + 326 + twooff, 138)
            end
        end
    else
        Draw.setColor({0, 0, 0})
        love.graphics.rectangle("fill", 0, 0, SCREEN_WIDTH - 140 + 40, 140)
        Draw.setColor({1, 1, 1})
        love.graphics.setLineWidth(3)
        love.graphics.rectangle("line", 0, 0, SCREEN_WIDTH - 140 + 40, 140)
        love.graphics.line(110, 0, 110, 140)
    end
    Draw.setColor(1, 1, 1, 1)
    self.ui:drawState()
    
    super.draw(self)
end

function BattleSelectionBox:select()
    self.buttons[self.selected_button]:select()
    self.lastselected[#self.lastselected + 1] = self.selected_button
    self.selected_button = 1
end

function BattleSelectionBox:cancel()
    if #self.lastselected ~= 0 then
        self.selected_button = self.lastselected[#self.lastselected]
        table.remove(self.lastselected, #self.lastselected)
    end
end

function BattleSelectionBox:createButtons()
    for _,button in ipairs(self.buttons or {}) do
        button:remove()
    end

    self.buttons = {}

    local btn_types = {"fight", "act", "item", "spare", "defend", "magic", "recruit", "tactic"}

    --if not self.battler.chara:hasAct() then Utils.removeFromTable(btn_types, "act") end
    --if not self.battler.chara:hasSpells() then Utils.removeFromTable(btn_types, "magic") end

    for lib_id,_ in Kristal.iterLibraries() do
        btn_types = Kristal.libCall(lib_id, "getActionButtons", self.battler, btn_types) or btn_types
    end
    btn_types = Kristal.modCall("getActionButtons", self.battler, btn_types) or btn_types

    local start_x = 77

    if (#btn_types <= 5) and Game:getConfig("oldUIPositions") then
        start_x = start_x - 5.5
    end

    for i, button in ipairs(btn_types) do
        if not Game.battle:hasActionButton(button) then
            Game.battle:registerActionButton("fight", function(battler, x, y) return FightButton(battler, x, y) end)
            Game.battle:registerActionButton("act", function(battler, x, y) return ActButton(battler, x, y) end)
            Game.battle:registerActionButton("magic", function(battler, x, y) return MagicButton(battler, x, y) end)
            Game.battle:registerActionButton("item", function(battler, x, y) return ItemButton(battler, x, y) end)
            Game.battle:registerActionButton("defend", function(battler, x, y) return DefendButton(battler, x, y) end)
            Game.battle:registerActionButton("spare", function(battler, x, y) return SpareButton(battler, x, y) end)
            Game.battle:registerActionButton("recruit", function(battler, x, y) return RecruitButton(battler, x, y) end)
            Game.battle:registerActionButton("tactic", function(battler, x, y) return TacticButton(battler, x, y) end)
        end
        local button_x = math.floor(start_x + ((i - 1) * 35)) + 0.5
        local button_y = 21
        local j = 0
        local h = 0
        if i > 4 then
            j = i - 5
            h = 1
        else
            j = i - 1 
        end

        if type(button) == "string" then
            -- It's a string, we should create this
            local new_button = Game.battle:createActionButton(button, self.battler, 30 + h*48, 16 + (j)*31)
            table.insert(self.buttons, new_button)
            new_button.posx = 0 + h*48
            new_button.offset = 0
            new_button.actbox = self
            print("DEBUG - Button value:", new_button, button) 
            self:addChild(new_button)
        elseif isClass(button) and button:includes(ActionButton) then
            -- We're passing in an ActionButton instance, so...
            button:setPosition(button_x, button_y)
            button:setPartyBattler(self.battler)
            table.insert(self.buttons, button)
            button.posx = 0 + h*48
            button.offset = 0
            button.actbox = self
            self:addChild(button)
        elseif type(button) == "boolean" then
            -- Nothing, just an empty space
        else
            Logging.warnNotify("Attempted to create invalid action button: ", button)
        end
    end

    self.selected_button = Utils.clamp(self.selected_button, 1 - 4, 8 + 4)
end

function BattleSelectionBox:transitionIn()
    if not self.shown then
        self.animate_out = false
        self.animation_timer = 0
        self.animation_done = false
        self.shown = true
    end
end

function BattleSelectionBox:transitionOut()
    -- TODO: Accurate transition-out animation
    if self.shown then
        self.animate_out = true
        self.animation_timer = 0
        self.animation_done = false
        self.animation_y_lag = self.y
        self.shown = false
    end
end

function BattleSelectionBox:getTransitionBounds()
    return 480-464, 325-464
end

function BattleSelectionBox:update()

    if not self.animation_done then
        self.animation_timer = self.animation_timer + DTMULT

        local max_time = self.animate_out and 6 or 12

        if self.animation_timer > max_time + 1 then
            self.animation_done = true
            self.animation_timer = max_time + 1
        end

        local lower, upper = self:getTransitionBounds()
        local target = lower - upper -118

        if not self.animate_out then
            if self.animation_y < target then
                if target - self.animation_y < 40 then
                    self.animation_y = self.animation_y + math.ceil((target - self.animation_y) / 2.5) * DTMULT
                else
                    self.animation_y = self.animation_y + 30 * DTMULT
                end
            else
                self.animation_y = target
            end
        else
            self.animation_y_lag = Utils.approach(self.animation_y_lag, self.y, 30 * DTMULT)

            if self.animation_y > -118 then
                if math.floor((target - self.animation_y) / 5) > 15 then
                    self.animation_y = self.animation_y - math.floor((target - self.animation_y) / 2.5) * DTMULT
                else
                    self.animation_y = self.animation_y - 30 * DTMULT
                end
            else
                self.animation_y = -118
            end
        end

        self.y = lower + self.animation_y - self.ui.y - 45  
    end

    if (Game.battle.state ~= "INTRO") and (Game.battle.state ~= "TRANSITION") and (self.begun ~= true) then
        self.begun = true
        self:transitionIn()
    end

    if (Game.battle.state == "ACTIONSELECT") then
        if Input.pressed("cancel") then
            self:cancel()
        end
    end

    if (Game.battle.state == "DEFENDING") or (Game.battle.state == "ENEMYDIALOGUE") or (Game.battle.state == "DIALOGUEEND") or (Game.battle.state == "TRANSITIONOUT") or (Game.battle.state == "DEFENDINGBEGIN") or (Game.battle.state == "VICTORY") or (Game.battle.state == "DEFENDINGEND") or (Game.battle.state == "ATTACKING") or (Game.battle.state == "ACTIONSDONE") and (self.begun == true) then
        self:transitionOut()
    elseif (self.begun == true) then
        self:transitionIn()
    end
    
    for i,button in ipairs(self.buttons) do
        button.selectable = true
        button.hovered = (self.selected_button == i)
    end
    self.selection_siner = self.selection_siner + 2 * DTMULT

    super.update(self)
end
return BattleSelectionBox