---@class BattleUI : Object
---@overload fun(...) : BattleUI
local BattleUI, super = Class(Object)

function BattleUI:init()
    super.init(self, 0, 560)

    self.layer = BATTLE_LAYERS["ui"]

    self.current_encounter_text = Game.battle.encounter.text

    self.xbox_offset = 165 - 40
    self.ybox_offset = -485
    self.boxcondense_offset = -64

    self.selection_box = BattleSelectionBox(0, -700)
    self.selection_box.ui = self
    self.selection_box.layer = -999999998234824828428341111111111111111111111111
    self:addChild(self.selection_box)
    --self.battle.selection_box = self.selection_box

    self.battlebarwidth = 0
    
    self.encounter_text = Textbox(30 + self.xbox_offset, 56 + self.ybox_offset, SCREEN_WIDTH - 30, SCREEN_HEIGHT - 53, "main_mono", nil, true)
    self.encounter_text.text.line_offset = 0
    self.encounter_text:setText("")
    self.encounter_text.debug_rect = {-30, -12, SCREEN_WIDTH+1, 124}
    self:addChild(self.encounter_text)

    self.choice_box = Choicebox(200 + self.xbox_offset, -425 + self.ybox_offset, 529, 103, true)
    self.choice_box.active = false
    self.choice_box.visible = false
    self:addChild(self.choice_box)

    self.short_act_text_1 = DialogueText("", 30 + self.xbox_offset, 51 + self.ybox_offset, SCREEN_WIDTH - 30, SCREEN_HEIGHT - 53, {wrap = false, line_offset = 0})
    self.short_act_text_2 = DialogueText("", 30 + self.xbox_offset, 51 + 30 + self.ybox_offset, SCREEN_WIDTH - 30, SCREEN_HEIGHT - 53, {wrap = false, line_offset = 0})
    self.short_act_text_3 = DialogueText("", 30 + self.xbox_offset, 51 + 30 + 30 + self.ybox_offset, SCREEN_WIDTH - 30, SCREEN_HEIGHT - 53, {wrap = false, line_offset = 0})
    self:addChild(self.short_act_text_1)
    self:addChild(self.short_act_text_2)
    self:addChild(self.short_act_text_3)

    self.action_boxes = {}
    self.attack_boxes = {}

    self.attacking = false

    local size_offset = 0
    local box_gap = 0
    
    if #Game.battle.party == 3 then
        size_offset = 0
        box_gap = 0
    elseif #Game.battle.party == 2 then
        size_offset = 108
        box_gap = 1
        if Game:getConfig("oldUIPositions") then
            size_offset = 106
            box_gap = 7
        end
    elseif #Game.battle.party == 1 then
        size_offset = 213
        box_gap = 0
    end

    for index,battler in ipairs(Game.battle.party) do
        local action_box = ActionBox(size_offset+ (index - 1) * (213 + box_gap), 0, index, battler)
        self:addChild(action_box)
        table.insert(self.action_boxes, action_box)
        battler.chara:onActionBox(action_box, false)
    end

    self.parallax_x = 0
    self.parallax_y = 0

    self.animation_done = true
    self.animation_timer = 0
    self.animate_out = false

    self.animation_y = 0
    self.animation_y_lag = 0

    self.shown = false

    self.heart_sprite = Assets.getTexture("player/heart")
    self.arrow_sprite = Assets.getTexture("ui/page_arrow_down")

    self.sparestar = Assets.getTexture("ui/battle/sparestar")
    self.tiredmark = Assets.getTexture("ui/battle/tiredmark")
end

function BattleUI:clearEncounterText()
    self.encounter_text:setActor(nil)
    self.encounter_text:setFace(nil)
    self.encounter_text:setFont()
    self.encounter_text:setAlign("left")
    self.encounter_text:setSkippable(true)
    self.encounter_text:setAdvance(true)
    self.encounter_text:setAuto(false)
    self.encounter_text:setText("")
end

function BattleUI:beginAttack()
    local attack_order = Utils.pickMultiple(Game.battle.normal_attackers, #Game.battle.normal_attackers)

    for _,box in ipairs(self.attack_boxes) do
        box:remove()
    end
    self.attack_boxes = {}

    local last_offset = -1
    local offset = 0
    for i = 1, #attack_order do
        offset = offset + last_offset

        local battler = attack_order[i]
        local index = Game.battle:getPartyIndex(battler.chara.id)
        local attack_box = AttackBox(battler, 30 + offset, index, 0, 40 + (38 * (index - 1)))
        attack_box.layer = -10 + (index * 0.01)
        self:addChild(attack_box)
        table.insert(self.attack_boxes, attack_box)

        if i < #attack_order and last_offset ~= 0 then
            last_offset = Utils.pick{0, 10, 15}
        else
            last_offset = Utils.pick{10, 15}
        end
    end

    self.attacking = true
end

function BattleUI:endAttack()
    Game.battle.cancel_attack = false
    for _,box in ipairs(self.attack_boxes) do
        box:endAttack()
    end
end

function BattleUI:transitionIn()
    if not self.shown then
        self.animate_out = false
        self.animation_timer = 0
        self.animation_done = false
        self.shown = true
    end
end

function BattleUI:transitionOut()
    -- TODO: Accurate transition-out animation
    if self.shown then
        self.animate_out = true
        self.animation_timer = 0
        self.animation_done = false
        self.animation_y_lag = self.y
        self.shown = false
    end
end

function BattleUI:update()
    self.encounter_text.y = self.selection_box.y + 7
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

            if self.animation_y > 0 then
                if math.floor((target - self.animation_y) / 5) > 15 then
                    self.animation_y = self.animation_y - math.floor((target - self.animation_y) / 2.5) * DTMULT
                else
                    self.animation_y = self.animation_y - 30 * DTMULT
                end
            else
                self.animation_y = 0
            end
        end
        
        self.y = lower - self.animation_y

        for _, box in ipairs(self.action_boxes) do
            if not self.animate_out then
                box.data_offset = self.animation_y - target
            else
                box.data_offset = self.y - self.animation_y_lag
            end
        end
    end

    if self.attacking then
        local all_done = true

        for _,box in ipairs(self.attack_boxes) do
            if not box.removing or box.fade_rect.alpha < 1 then
                all_done = false
                break
            end
        end

        if all_done then
            for _,box in ipairs(self.attack_boxes) do
                box:remove()
            end
            self.attack_boxes = {}
            self.attacking = false
        end
    end

    super.update(self)
end

function BattleUI:getTransitionBounds()
    return 480, 325
end

function BattleUI:draw()
    self:drawActionArena()
    self:drawActionStrip()
    super.draw(self)
end

function BattleUI:drawActionStrip()
    -- Draw the top line of the action strip
    Draw.setColor(PALETTE["action_strip"])
    love.graphics.rectangle("fill", 0, Game:getConfig("oldUIPositions") and 1 or 0, 640, Game:getConfig("oldUIPositions") and 3 or 2)
    -- Draw the background of the action strip
    Draw.setColor(PALETTE["action_fill"])
    love.graphics.rectangle("fill", 0, Game:getConfig("oldUIPositions") and 4 or 2, 640, Game:getConfig("oldUIPositions") and 33 or 35)
end

function BattleUI:drawActionArena()
    -- Draw the top line of the action area
    Draw.setColor(PALETTE["action_strip"])
    love.graphics.rectangle("fill", 0, 37, 640, 3)
    -- Draw the background of the action area
    Draw.setColor(PALETTE["action_fill"])
    love.graphics.rectangle("fill", 0, 40, 640, 115)
    --self:drawState()
end

function BattleUI:drawState()
    local xof = 120
    local xof2 = xof/2 + 10
    local xof3 = -493
    local xof4 = 2*xof/3
    local yof = -45
    local yof2 = 5
    local xdist = 215
    if Game.battle.state == "MENUSELECT" then
        local page = math.ceil(Game.battle.current_menu_y / 3) - 1
        local max_page = math.ceil(#Game.battle.menu_items / 6) - 1

        local x = 0
        local y = 0
        Draw.setColor(Game.battle.encounter:getSoulColor())
        Draw.draw(self.heart_sprite, 5 + ((Game.battle.current_menu_x - 1) * xdist) + xof, 30 + ((Game.battle.current_menu_y - (page*3)) * 30) + yof)

        local font = Assets.getFont("main")
        love.graphics.setFont(font)

        local page_offset = page * 6
        for i = page_offset+1, math.min(page_offset+6, #Game.battle.menu_items) do
            local item = Game.battle.menu_items[i]

            Draw.setColor(1, 1, 1, 1)
            local text_offset = 0
            -- Are we able to select this?
            local able = Game.battle:canSelectMenuItem(item)
            if item.party then
                if not able then
                    -- We're not able to select this, so make the heads gray.
                    Draw.setColor(COLORS.gray)
                end

                for index, party_id in ipairs(item.party) do
                    local chara = Game:getPartyMember(party_id)

                    -- Draw head only if it isn't the currently selected character
                    if Game.battle:getPartyIndex(party_id) ~= Game.battle.current_selecting then
                        local ox, oy = chara:getHeadIconOffset()
                        Draw.draw(Assets.getTexture(chara:getHeadIcons() .. "/head"), text_offset + 30 + (x * xdist) + ox + xof - 7, 50 + (y * 30) + oy + yof + 2)
                        text_offset = text_offset + 30
                    end
                end
            end

            if item.icons then
                if not able then
                    -- We're not able to select this, so make the heads gray.
                    Draw.setColor(COLORS.gray)
                end

                for _, icon in ipairs(item.icons) do
                    if type(icon) == "string" then
                        icon = {icon, false, 0, 0, nil}
                    end
                    if not icon[2] then
                        local texture = Assets.getTexture(icon[1])
                        Draw.draw(texture, text_offset + 30 + (x * xdist) + (icon[3] or 0) + xof, 50 + (y * 30) + (icon[4] or 0) + yof)
                        text_offset = text_offset + (icon[5] or texture:getWidth())
                    end
                end
            end

            if able then
                --Draw.setColor(item.color or {1, 1, 1, 1})
                Draw.setColor({1, 1, 1, 1})
            else
                Draw.setColor(COLORS.gray)
            end
            love.graphics.print(item.name, text_offset + 30 + (x * xdist) + xof, 50 + (y * 30) + yof)
            text_offset = text_offset + font:getWidth(item.name)

            if item.icons then
                if able then
                    Draw.setColor(1, 1, 1)
                end

                for _, icon in ipairs(item.icons) do
                    if type(icon) == "string" then
                        icon = {icon, false, 0, 0, nil}
                    end
                    if icon[2] then
                        local texture = Assets.getTexture(icon[1])
                        Draw.draw(texture, text_offset + 30 + (x * xdist) + (icon[3] or 0) + xof, 50 + (y * 30) + (icon[4] or 0) + yof)
                        text_offset = text_offset + (icon[5] or texture:getWidth())
                    end
                end
            end

            if x == 0 then
                x = 1
            else
                x = 0
                y = y + 1
            end
        end

        -- Print information about currently selected item
        local tp_offset, _ = 0, nil --initialize placeholdder variable so it doenst go in global scope
        local current_item = Game.battle.menu_items[Game.battle:getItemIndex()]
        if current_item.description then
            Draw.setColor(COLORS.gray)
            love.graphics.print(current_item.description, 260 + 240 + xof3, 50 + yof)
            Draw.setColor(1, 1, 1, 1)
            _, tp_offset = current_item.description:gsub('\n', '\n')
            tp_offset = tp_offset + 1
        end

        local compact_tp = false

        if current_item.tp and current_item.tp ~= 0 then
            if tp_offset >= 3 and current_item.ad and current_item.ad ~= 0 then
                compact_tp = true
                Draw.setColor(PALETTE["tension_desc"])
                love.graphics.print(math.floor((current_item.tp / Game:getMaxTension()) * 100) .. "% ", 260 + 240 + xof3, 50 + (tp_offset * 32) + yof)
            else
                Draw.setColor(PALETTE["tension_desc"])
                love.graphics.print(math.floor((current_item.tp / Game:getMaxTension()) * 100) .. "% "..Game:getConfig("tpName"), 260 + 240 + xof3, 50 + (tp_offset * 32) + yof)
                tp_offset = tp_offset + 1
            end
            Game:setTensionPreview(current_item.tp)
        else
            Game:setTensionPreview(0)
        end

        local adrenstring = " Adren."
        local adrenoff = 0

        if current_item.ad and current_item.ad ~= 0 then
            if compact_tp then
                adrenstring = " AD"
                adrenoff = 49
            end
            Draw.setColor({0, 0.95, 0.95})
            love.graphics.print(current_item.ad .. adrenstring, 260 + 240 + xof3 + adrenoff, 50 + (tp_offset * 32) + yof)
            --Game:setTensionPreview(current_item.ad)
        else
            --Game:setTensionPreview(0)
        end

        Draw.setColor(1, 1, 1, 1)
        if page < max_page then
            Draw.draw(self.arrow_sprite, 470 - xof - 15, 120 + (math.sin(Kristal.getTime()*6) * 2) + yof/2)
        end
        if page > 0 then
            Draw.draw(self.arrow_sprite, 470 - xof - 15, 70 - (math.sin(Kristal.getTime()*6) * 2) + yof, 0, 1, -1)
        end

    elseif Game.battle.state == "ENEMYSELECT" or Game.battle.state == "XACTENEMYSELECT" then
        local enemies = Game.battle.enemies_index

        local page = math.ceil(Game.battle.current_menu_y / 3) - 1
        local max_page = math.ceil(#enemies / 3) - 1
        local page_offset = page * 3

        Draw.setColor(Game.battle.encounter:getSoulColor())
        Draw.draw(self.heart_sprite, 55 + xof2, 30 + ((Game.battle.current_menu_y - page_offset) * 30) + yof)

        local font = Assets.getFont("main")
        love.graphics.setFont(font)

        local draw_mercy = Game:getConfig("mercyBar")
        local draw_percents = Game:getConfig("enemyBarPercentages")

        Draw.setColor(1, 1, 1, 1)

        if draw_mercy then
            if Game.battle.state == "ENEMYSELECT" then
                love.graphics.print("HP", 424 - xof4, 39 + yof + yof2, 0, 1, 0.5)
            end
            love.graphics.print("MERCY", 524 - xof4, 39 + yof + yof2, 0, 1, 0.5)
        end
        
        local xact_x_offset = 142
        for _,enemy in ipairs(Game.battle:getActiveEnemies()) do
            if xact_x_offset < font:getWidth(enemy.name) + 142 then
                xact_x_offset = font:getWidth(enemy.name) + 142
            end
        end

        for index = page_offset+1, math.min(page_offset+3, #enemies) do
            local enemy = enemies[index]
            local y_off = (index - page_offset - 1) * 30

            if enemy then
                local name_colors = enemy:getNameColors()
                if type(name_colors) ~= "table" then
                    name_colors = {name_colors}
                end

                if #name_colors <= 1 then
                    Draw.setColor(name_colors[1] or enemy.selectable and {1, 1, 1} or {0.5, 0.5, 0.5})
                    love.graphics.print(enemy.name, 80 + xof2, 50 + y_off + yof)
                else
                    -- Draw the enemy name to a canvas first
                    local canvas = Draw.pushCanvas(font:getWidth(enemy.name) + xof, font:getHeight() + yof)
                    Draw.setColor(1, 1, 1)
                    love.graphics.print(enemy.name)
                    Draw.popCanvas()

                    -- Define our gradient
                    local color_canvas = Draw.pushCanvas(#name_colors, 1)
                    for i = 1, #name_colors do
                        -- Draw a pixel for the color
                        Draw.setColor(name_colors[i])
                        love.graphics.rectangle("fill", i-1, 0, 1, 1)
                    end
                    Draw.popCanvas()

                    -- Reset the color
                    Draw.setColor(1, 1, 1)

                    -- Use the dynamic gradient shader for the spare/tired colors
                    local shader = Kristal.Shaders["DynGradient"]
                    love.graphics.setShader(shader)
                    -- Send the gradient colors
                    shader:send("colors", color_canvas)
                    shader:send("colorSize", {#name_colors, 1})
                    -- Draw the canvas from before to apply the gradient over it
                    Draw.draw(canvas, 80 + xof2, 50 + y_off + yof)
                    -- Disable the shader
                    love.graphics.setShader()
                end

                Draw.setColor(1, 1, 1)

                local spare_icon = false
                local tired_icon = false
                if enemy.tired and enemy:canSpare() then
                    Draw.draw(self.sparestar, 80 + font:getWidth(enemy.name) + 20 + xof2, 60 + y_off + yof)
                    Draw.draw(self.tiredmark, 80 + font:getWidth(enemy.name) + 40 + xof2, 60 + y_off + yof)
                    spare_icon = true
                    tired_icon = true
                elseif enemy.tired then
                    Draw.draw(self.tiredmark, 80 + font:getWidth(enemy.name) + 40 + xof2, 60 + y_off + yof)
                    tired_icon = true
                elseif enemy.mercy >= 100 then
                    Draw.draw(self.sparestar, 80 + font:getWidth(enemy.name) + 20 + xof2, 60 + y_off + yof)
                    spare_icon = true
                end

                for i = 1, #enemy.icons do
                    if enemy.icons[i] then
                        if (spare_icon and (i == 1)) or (tired_icon and (i == 2)) then
                            -- Skip the custom icons if we're already drawing spare/tired ones
                        else
                            Draw.setColor(1, 1, 1, 1)
                            Draw.draw(enemy.icons[i], 80 + font:getWidth(enemy.name) + (i * 20) + xof, 60 + y_off + yof)
                        end
                    end
                end

                if Game.battle.state == "XACTENEMYSELECT" then
                    Draw.setColor(Game.battle.party[Game.battle.current_selecting].chara:getXActColor())
                    if Game.battle.selected_xaction.id == 0 then
                        love.graphics.print(enemy:getXAction(Game.battle.party[Game.battle.current_selecting]), xact_x_offset + xof, 50 + y_off + yof)
                    else
                        love.graphics.print(Game.battle.selected_xaction.name, xact_x_offset + xof, 50 + y_off + yof)
                    end
                end

                if Game.battle.state == "ENEMYSELECT" then
                    local namewidth = font:getWidth(enemy.name)

                    Draw.setColor(128/255, 128/255, 128/255, 1)

                    if ((80 + namewidth + 60 + (font:getWidth(enemy.comment) / 2)) < 415) then
                        love.graphics.print(enemy.comment, 80 + namewidth + 60 + xof, 50 + y_off + yof)
                    else
                        love.graphics.print(enemy.comment, 80 + namewidth + 60 + xof, 50 + y_off + yof, 0, 0.5, 1)
                    end


                    local hp_percent = enemy.health / enemy.max_health

                    local hp_x = draw_mercy and 420 or 510

                    if enemy.selectable then
                        -- Draw the enemy's HP
                        Draw.setColor(PALETTE["action_health_bg"])
                        love.graphics.rectangle("fill", hp_x - xof4, 55 + y_off + yof + yof2, 81, 16)

                        Draw.setColor(PALETTE["action_health"])
                        love.graphics.rectangle("fill", hp_x - xof4, 55 + y_off + yof + yof2, math.ceil(hp_percent * 81), 16)

                        if draw_percents then
                            Draw.setColor(PALETTE["action_health_text"])
                            love.graphics.print(math.ceil(hp_percent * 100) .. "%", hp_x + 4 - xof4, 55 + y_off + yof + yof2, 0, 1, 0.5)
                        end
                    end
                end

                if draw_mercy then
                    -- Draw the enemy's MERCY
                    if enemy.selectable then
                        Draw.setColor(PALETTE["battle_mercy_bg"])
                    else
                        Draw.setColor(127/255, 127/255, 127/255, 1)
                    end
                    love.graphics.rectangle("fill", 520 - xof4, 55 + y_off + yof + yof2, 81, 16)

                    if enemy.disable_mercy then
                        Draw.setColor(PALETTE["battle_mercy_text"])
                        love.graphics.setLineWidth(2)
                        love.graphics.line(520 - xof4, 56 + y_off + yof + yof2, 520 + 81, 56 + y_off + 16 - 1)
                        love.graphics.line(520 - xof4, 56 + y_off + 16 - 1 + yof + yof2, 520 + 81, 56 + y_off)
                    else
                        Draw.setColor(1, 1, 0, 1)
                        love.graphics.rectangle("fill", 520 - xof4, 55 + y_off + yof + yof2, ((enemy.mercy / 100) * 81), 16)

                        if draw_percents and enemy.selectable then
                            Draw.setColor(PALETTE["battle_mercy_text"])
                            love.graphics.print(math.ceil(enemy.mercy) .. "%", 524 - xof4, 55 + y_off + yof + yof2, 0, 1, 0.5)
                        end
                    end
                end
            end
        end

        Draw.setColor(1, 1, 1, 1)
        local arrow_down = page_offset + 3
        while true do
            arrow_down = arrow_down + 1
            if arrow_down > #enemies then
                arrow_down = false
                break
            elseif enemies[arrow_down] then
                arrow_down = true
                break
            end
        end
        local arrow_up = page_offset + 1
        while true do
            arrow_up = arrow_up - 1
            if arrow_up < 1 then
                arrow_up = false
                break
            elseif enemies[arrow_up] then
                arrow_up = true
                break
            end
        end
        if arrow_down then
            Draw.draw(self.arrow_sprite, 20, 120 + (math.sin(Kristal.getTime()*6) * 2) + yof)
        end
        if arrow_up then
            Draw.draw(self.arrow_sprite, 20, 70 - (math.sin(Kristal.getTime()*6) * 2) + yof, 0, 1, -1)
        end
    elseif Game.battle.state == "PARTYSELECT" then
        local page = math.ceil(Game.battle.current_menu_y / 3) - 1
        local max_page = math.ceil(#Game.battle.party / 3) - 1
        local page_offset = page * 3

        Draw.setColor(Game.battle.encounter:getSoulColor())
        Draw.draw(self.heart_sprite, 55 + xof2, 30 + ((Game.battle.current_menu_y - page_offset) * 30) + yof)

        local font = Assets.getFont("main")
        love.graphics.setFont(font)

        for index = page_offset+1, math.min(page_offset+3, #Game.battle.party) do
            Draw.setColor(1, 1, 1, 1)
            love.graphics.print(Game.battle.party[index].chara:getName(), 80 + xof2, 50 + ((index - page_offset - 1) * 30) + yof)

            Draw.setColor(PALETTE["action_health_bg"])
            love.graphics.rectangle("fill", 400, 55 + ((index - page_offset - 1) * 30) + yof, 101, 16)

            local percentage = Game.battle.party[index].chara:getHealth() / Game.battle.party[index].chara:getStat("health")
            Draw.setColor(PALETTE["action_health"])
            love.graphics.rectangle("fill", 400, 55 + ((index - page_offset - 1) * 30) + yof, math.ceil(percentage * 101), 16)
        end

        Draw.setColor(1, 1, 1, 1)
        if page < max_page then
            Draw.draw(self.arrow_sprite, 20, 120 + (math.sin(Kristal.getTime()*6) * 2) + yof)
        end
        if page > 0 then
            Draw.draw(self.arrow_sprite, 20, 70 - (math.sin(Kristal.getTime()*6) * 2) + yof, 0, 1, -1)
        end
    end
    if Game.battle.state == "ATTACKING" or self.attacking then
        self:drawBattleBar(true)
        Draw.setColor(PALETTE["battle_attack_lines"])
        if not Game:getConfig("oldUIPositions") then
            -- Chapter 2 attack lines
            love.graphics.rectangle("fill", 79, 78, 224, 2)
            love.graphics.rectangle("fill", 79, 116, 224, 2)
        else
            -- Chapter 1 attack lines
            local has_index = {}
            for _,box in ipairs(self.attack_boxes) do
                has_index[box.index] = true
            end
            love.graphics.rectangle("fill", has_index[2] and 77 or 2, 78, has_index[2] and 226 or 301, 3)
            love.graphics.rectangle("fill", has_index[3] and 77 or 2, 116, has_index[3] and 226 or 301, 3)
        end
    else
        self:drawBattleBar(false)
    end
end

function BattleUI:drawBattleBar(open)
    local alphamult = 1
    local alphamulten = 0.2
    if open then
        alphamult = 2
        alphamulten = 0
        if self.battlebarwidth < 1 then
            if self.battlebarwidth + 0.06 >= 1 then
                self.battlebarwidth = 1
            else
                self.battlebarwidth = self.battlebarwidth + 0.06
            end
        else
            self.battlebarwidth = 1
        end
    else
        if self.battlebarwidth > 0 then
            if self.battlebarwidth - 0.07 <= 0 then
                self.battlebarwidth = 0
            else
                self.battlebarwidth = self.battlebarwidth - 0.07
            end
        else
            self.battlebarwidth = 0
        end
    end
    
    Draw.setColor({1, 1, 1, self.battlebarwidth*alphamult})
    Draw.draw(Assets.getTexture("ui/battle/attackbarfull"), 0 - self.selection_box.x + SCREEN_WIDTH/2, -265 - self.selection_box.y, 0, self.battlebarwidth, 1, 510/2)
    for _,enemy in ipairs(Game.battle:getActiveEnemies()) do
        local enemycenter = SCREEN_WIDTH/2 - enemy.x + enemy.width - 5 - self.selection_box.x
        enemy.enemycenter = enemycenter
        local dir = -1
        Draw.setColor({1, 1, 1, self.battlebarwidth*alphamult - alphamulten}) --Just ignore all this dumbass code btw
        Draw.draw(Assets.getTexture("ui/battle/attackreticle"), 0 - self.selection_box.x + SCREEN_WIDTH/2 + dir*self.battlebarwidth*enemycenter - enemy.width*self.battlebarwidth + (enemy.width/1)*self.battlebarwidth + 17*self.battlebarwidth, -262 - self.selection_box.y, 0, 1, 1, 36/2)
        Draw.draw(Assets.getTexture("ui/battle/attackcursor_1"), (-self.selection_box.x + SCREEN_WIDTH/2 - 255 + 510*Game.battle.reticleprogress)*self.battlebarwidth, -262 + 6 - self.selection_box.y, 0, 1, 1, 36/2)
    end
    Draw.setColor({1, 1, 1, 1})
end

return BattleUI