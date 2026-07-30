---@class Battle : Battle
---@overload fun(...) : Battle
local Battle, super = Class("Battle", true)

function Battle:postInit(state, encounter)
    self.state = state

    self.reticleprogress = 0

    if type(encounter) == "string" then
        self.encounter = Registry.createEncounter(encounter)
    else
        self.encounter = encounter
    end

    if Game.world.music:isPlaying() and self.encounter.music then
        self.resume_world_music = true
        Game.world.music:pause()
    end

    if self.encounter.queued_enemy_spawns then
        for _,enemy in ipairs(self.encounter.queued_enemy_spawns) do
            if state == "TRANSITION" then
                enemy.target_x = enemy.x
                enemy.target_y = enemy.y
                enemy.y = -SCREEN_HEIGHT - 200
            end
            table.insert(self.enemies, enemy)
            table.insert(self.enemies_index, enemy)
            self:addChild(enemy)
        end
    end

    self.battle_ui = BattleUI()
    self:addChild(self.battle_ui)

    self.tension_bar = TensionBar(-25, 120, true)
    self.tension_bar.layer = 100
    self:addChild(self.tension_bar)

    self.battler_targets = {}
    for index, battler in ipairs(self.party) do
        local target_x, target_y = self.encounter:getPartyPosition(index)
        table.insert(self.battler_targets, {target_x, target_y})

        if state ~= "TRANSITION" then
            battler:setPosition(target_x, target_y)
        end
    end

    for _,enemy in ipairs(self.enemies) do
        enemy.default_y = enemy.y
        self.enemy_beginning_positions[enemy] = {enemy.x, enemy.y}
    end
    if Game.encounter_enemies then
        for _,from in ipairs(Game.encounter_enemies) do
            if not isClass(from) then
                local enemy = self:parseEnemyIdentifier(from[1])
                from[2].visible = false
                from[2].battler = enemy
                self.enemy_beginning_positions[enemy] = {from[2]:getScreenPos()}
                self.enemy_world_characters[enemy] = from[2]
                if state == "TRANSITION" then
                    enemy:setPosition(from[2]:getScreenPos())
                end
            else
                for _,enemy in ipairs(self.enemies) do
                    if enemy.actor and from.actor and enemy.actor.id == from.actor.id then
                        from.visible = false
                        from.battler = enemy
                        self.enemy_beginning_positions[enemy] = {from:getScreenPos()}
                        self.enemy_world_characters[enemy] = from
                        if state == "TRANSITION" then
                            enemy:setPosition(from:getScreenPos())
                        end
                        break
                    end
                end
            end
        end
    end

    if self.encounter_context and self.encounter_context:includes(ChaserEnemy) then
        for _,enemy in ipairs(self.encounter_context:getGroupedEnemies(true)) do
            enemy:onEncounterStart(enemy == self.encounter_context, self.encounter)
        end
    end

    if state == "TRANSITION" then
        self.transitioned = true
        self.transition_timer = 0
        self.afterimage_count = 0
    else
        self.transition_timer = 10

        if state ~= "INTRO" then
            self:nextTurn()
        end
    end

    if not self.encounter:onBattleInit() then
        self:setState(state)
    end
end

function Battle:handleActionSelectInput(key)
    local selection_box = self.battle_ui.selection_box
    local actbox = self.battle_ui.action_boxes[self.current_selecting]
    local old_selected_button = selection_box.selected_button

    if Input.isConfirm(key) then
        selection_box:select()
        self.ui_select:stop()
        self.ui_select:play()
        return
    elseif Input.isCancel(key) then
        local old_selecting = self.current_selecting

        self:previousParty()

        if self.current_selecting ~= old_selecting then
            self.ui_move:stop()
            self.ui_move:play()
            --self.battle_ui.selection_box[self.current_selecting]:unselect()
        end
        return
    elseif Input.is("left", key) then
        selection_box.selected_button = selection_box.selected_button - 4
    elseif Input.is("right", key) then
        selection_box.selected_button = selection_box.selected_button + 4
    elseif Input.is("up", key) then
        if selection_box.selected_button == 1 then
            selection_box.selected_button = 4
        elseif selection_box.selected_button == 5 then
            selection_box.selected_button = 8
        else
            selection_box.selected_button = selection_box.selected_button - 1
        end
    elseif Input.is("down", key) then
        if selection_box.selected_button == 4 then
            selection_box.selected_button = 1
        elseif selection_box.selected_button == 8 then
            selection_box.selected_button = 5
        else
            selection_box.selected_button = selection_box.selected_button + 1
        end
    end

    if selection_box.selected_button < 1 then
        selection_box.selected_button = selection_box.selected_button + 8
    end

    if selection_box.selected_button > #selection_box.buttons then
        selection_box.selected_button = selection_box.selected_button - 8
    end
    
    if old_selected_button ~= selection_box.selected_button then
        self.ui_move:stop()
        self.ui_move:play()
    end
end

function Battle:addMenuItem(tbl)
    -- Item colors in Ch3+ can be dynamic (e.g. pacify) so we should use functions for item color.
    -- Table colors can still be used, but we'll wrap them into functions.
    local color = tbl.color or {1, 1, 1, 1}
    local fcolor
    if type(color) == "table" then
        fcolor = function () return color end
    else
        fcolor = color
    end
    tbl = {
        ["name"] = tbl.name or "",
        ["tp"] = tbl.tp or 0,
        ["ad"] = tbl.ad or 0,
        ["unusable"] = tbl.unusable or false,
        ["description"] = tbl.description or "",
        ["party"] = tbl.party or {},
        ["color"] = fcolor,
        ["data"] = tbl.data or nil,
        ["callback"] = tbl.callback or function() end,
        ["highlight"] = tbl.highlight or nil,
        ["icons"] = tbl.icons or nil
    }
    table.insert(self.menu_items, tbl)
    return tbl
end

function Battle:getStatusIcons() return self.status_icons end
function Battle:getStatusIconOffset() return unpack(self.status_icon_offset or {0, 0}) end

function Battle:canSelectMenuItem(menu_item)
    if menu_item.unusable then
        return false
    end
    if menu_item.tp and (menu_item.tp > Game:getTension()) then
        return false
    end
    if menu_item.ad and (menu_item.ad > (Game.battle.party[Game.battle.current_selecting].chara:getAdrenaline())) then 
        return false
    end
    if menu_item.party then
        for _,party_id in ipairs(menu_item.party) do
            local party_index = self:getPartyIndex(party_id)
            local battler = self.party[party_index]
            local action = self.character_actions[party_index]
            if (not battler) or (not battler:isActive()) or (action and action.cancellable == false) then
                -- They're either down, asleep, or don't exist. Either way, they're not here to do the action.
                return false
            end
        end
    end
    return true
end


function Battle:commitSingleAction(action)
    local battler = self.party[action.character_id]

    battler.action = action
    self.character_actions[action.character_id] = action

    if Kristal.callEvent(KRISTAL_EVENT.onBattleActionCommit, action, action.action, battler, action.target) then
        return
    end

    if action.action == "ITEM" and action.data then
        local result = action.data:onBattleSelect(battler, action.target)
        if result ~= false then
            local storage, index = Game.inventory:getItemIndex(action.data)
            action.item_storage = storage
            action.item_index = index
            if action.data:hasResultItem() then
                local result_item = action.data:createResultItem()
                Game.inventory:setItem(storage, index, result_item)
                action.result_item = result_item
            else
                Game.inventory:removeItem(action.data)
            end
            action.consumed = true
        else
            action.consumed = false
        end
    end

    local anim = action.action:lower()
    if action.action == "SPELL" and action.data then
        local result = action.data:onSelect(battler, action.target)
        if result ~= false then
            if action.tp then
                if action.tp > 0 then
                    Game:giveTension(action.tp)
                elseif action.tp < 0 then
                    Game:removeTension(-action.tp)
                end
            end
            if action.ad then
                if action.ad > 0 then
                    Game.battle.party[Game.battle.current_selecting].chara:addAdrenaline(action.ad)
                elseif action.ad < 0 then
                    Game.battle.party[Game.battle.current_selecting].chara:removeAdrenaline(-action.ad)
                end
            end
            battler:setAnimation("battle/"..anim.."_ready")
            action.icon = anim
        end
    else
        if action.tp then
            if action.tp > 0 then
                Game:giveTension(action.tp)
            elseif action.tp < 0 then
                Game:removeTension(-action.tp)
            end
        end
        if action.ad then
            if action.ad > 0 then
                Game.battle.party[Game.battle.current_selecting].chara:addAdrenaline(action.ad)
            elseif action.ad < 0 then
                Game.battle.party[Game.battle.current_selecting].chara:removeAdrenaline(-action.ad)
            end
        end

        if action.action == "SKIP" and action.reason then
            anim = action.reason:lower()
        end

        if (action.action == "ITEM" and action.data and (not action.data.instant)) or (action.action ~= "ITEM") then
            battler:setAnimation("battle/"..anim.."_ready")
            action.icon = anim
        end
    end
end


function Battle:commitAction(battler, action_type, target, data, extra)
    data = data or {}
    extra = extra or {}

    local is_xact = action_type:upper() == "XACT"
    if is_xact then
        action_type = "ACT"
    end

    local tp_diff = 0
    if data.tp then
        tp_diff = Utils.clamp(-data.tp, -Game:getTension(), Game:getMaxTension() - Game:getTension())
    end

    local ad_diff = 0
    if data.ad then
        ad_diff = Utils.clamp(-data.ad, -battler.chara:getAdrenaline(), battler.chara:getStat("adrenaline") - battler.chara:getAdrenaline())
    end

    local party_id = self:getPartyIndex(battler.chara.id)

    -- Dont commit action for an inactive party member
    if not battler:isActive() then return end

    -- Make sure this action doesn't cancel any uncancellable actions
    if data.party then
        for _,v in ipairs(data.party) do
            local index = self:getPartyIndex(v)

            if index ~= party_id then
                local action = self.character_actions[index]
                if action then
                    if action.cancellable == false then
                        return
                    end
                    if action.act_parent then
                        local parent_action = self.character_actions[action.act_parent]
                        if parent_action.cancellable == false then
                            return
                        end
                    end
                end
            end
        end
    end

    self:commitSingleAction(Utils.merge({
        ["character_id"] = party_id,
        ["action"] = action_type:upper(),
        ["party"] = data.party,
        ["name"] = data.name,
        ["target"] = target,
        ["data"] = data.data,
        ["tp"] = tp_diff,
        ["ad"] = ad_diff,
        ["cancellable"] = data.cancellable,
    }, extra))

    if data.party then
        for _,v in ipairs(data.party) do
            local index = self:getPartyIndex(v)

            if index ~= party_id then
                local action = self.character_actions[index]
                if action then
                    if action.act_parent then
                        self:removeAction(action.act_parent)
                    else
                        self:removeAction(index)
                    end
                end

                self:commitSingleAction(Utils.merge({
                    ["character_id"] = index,
                    ["action"] = "SKIP",
                    ["reason"] = action_type:upper(),
                    ["name"] = data.name,
                    ["target"] = target,
                    ["data"] = data.data,
                    ["act_parent"] = party_id,
                    ["cancellable"] = data.cancellable,
                }, extra))
            end
        end
    end
end

function Battle:removeSingleAction(action)
    local battler = self.party[action.character_id]

    if Kristal.callEvent(KRISTAL_EVENT.onBattleActionUndo, action, action.action, battler, action.target) then
        battler.action = nil
        self.character_actions[action.character_id] = nil
        return
    end

    battler:resetSprite()

    if action.tp then
        if action.tp < 0 then
            Game:giveTension(-action.tp)
        elseif action.tp > 0 then
            Game:removeTension(action.tp)
        end
    end
    if action.ad then
        if action.ad > 0 then
            Game.battle.party[Game.battle.current_selecting].chara:addAdrenaline(-action.ad)
        elseif action.ad < 0 then
            Game.battle.party[Game.battle.current_selecting].chara:removeAdrenaline(action.ad)
        end
    end

    if action.action == "ITEM" and action.data then
        if action.item_index and action.consumed then
            if action.result_item then
                Game.inventory:setItem(action.item_storage, action.item_index, action.data)
            else
                Game.inventory:addItemTo(action.item_storage, action.item_index, action.data)
            end
        end
        action.data:onBattleDeselect(battler, action.target)
    elseif action.action == "SPELL" and action.data then
        action.data:onDeselect(battler, action.target)
    end

    battler.action = nil
    self.character_actions[action.character_id] = nil
end

return Battle