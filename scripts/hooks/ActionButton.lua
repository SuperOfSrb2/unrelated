---@class ActionButton : Object
---@overload fun(...) : ActionButton
local ActionButton, super = HookSystem.hookScript(ActionButton)

function ActionButton:select()
    if Game.battle.encounter:onActionSelect(self.battler, self) then return end
    if Kristal.callEvent(KRISTAL_EVENT.onActionSelect, self.battler, self) then return end
    if self.type == "fight" then
        Game.battle:clearMenuItems()
        --Add standard attack
        attack = self.battler.chara:getAttack("standard")
            Game.battle:addMenuItem({
                ["name"] = attack:getName(),
                ["tp"] = attack:getTPCost(self.battler.chara),
                ["ad"] = attack:getADCost(self.battler.chara),
                ["unusable"] = not attack:isUsable(self.battler.chara),
                ["description"] = attack:getBattleDescription(),
                ["party"] = attack.party,
                ["color"] = color,
                ["data"] = attack,
                ["callback"] = function(menu_item)
                    Game.battle.selected_attack = menu_item

                    if not attack.target or attack.target == "none" then
                        Game.battle:setState("ENEMYSELECT", "ATTACK")
                    elseif attack.target == "enemy" then
                        Game.battle:setState("ENEMYSELECT", "ATTACK")
                    elseif attack.target == "enemies" then
                        Game.battle:pushAction("ATTACK", Game.battle:getActiveEnemies(), menu_item)
                    end
                end
            })
        -- Now, register ATTACKs as menu items.
        for _,attack in ipairs(self.battler.chara:getAttacks()) do
            local color = attack.color or {1, 1, 1, 1}
            Game.battle:addMenuItem({
                ["name"] = attack:getName(),
                ["tp"] = attack:getTPCost(self.battler.chara),
                ["ad"] = attack:getADCost(self.battler.chara),
                ["unusable"] = not attack:isUsable(self.battler.chara),
                ["description"] = attack:getBattleDescription(),
                ["party"] = attack.party,
                ["color"] = color,
                ["data"] = attack,
                ["callback"] = function(menu_item)
                    Game.battle.selected_attack = menu_item

                    if not attack.target or attack.target == "none" then
                        Game.battle:pushAction("ATTACK", nil, menu_item)
                    elseif attack.target == "enemy" then
                        Game.battle:setState("ENEMYSELECT", "ATTACK")
                    elseif attack.target == "enemies" then
                        Game.battle:pushAction("ATTACK", Game.battle:getActiveEnemies(), menu_item)
                    end
                end
            })
        end

        Game.battle:setState("MENUSELECT", "ATTACK")
    elseif self.type == "act" then
        Game.battle:setState("ENEMYSELECT", "ACT")
    elseif self.type == "magic" then
        Game.battle:clearMenuItems()

        -- First, register X-Actions as menu items.

        if Game.battle.encounter.default_xactions and self.battler.chara:hasXAct() then
            local spell = {
                ["name"] = Game.battle.enemies[1]:getXAction(self.battler),
                ["target"] = "xact",
                ["id"] = 0,
                ["default"] = true,
                ["party"] = {},
                ["tp"] = 0
            }

            Game.battle:addMenuItem({
                ["name"] = self.battler.chara:getXActName() or "X-Action",
                ["tp"] = 0,
                ["color"] = {self.battler.chara:getXActColor()},
                ["data"] = spell,
                ["callback"] = function(menu_item)
                    Game.battle.selected_xaction = spell
                    Game.battle:setState("XACTENEMYSELECT", "SPELL")
                end
            })
        end

        for id, action in ipairs(Game.battle.xactions) do
            if action.party == self.battler.chara.id then
                local spell = {
                    ["name"] = action.name,
                    ["target"] = "xact",
                    ["id"] = id,
                    ["default"] = false,
                    ["party"] = {},
                    ["tp"] = action.tp or 0
                }

                Game.battle:addMenuItem({
                    ["name"] = action.name,
                    ["tp"] = action.tp or 0,
                    ["description"] = action.description,
                    ["color"] = action.color or {1, 1, 1, 1},
                    ["data"] = spell,
                    ["callback"] = function(menu_item)
                        Game.battle.selected_xaction = spell
                        Game.battle:setState("XACTENEMYSELECT", "SPELL")
                    end
                })
            end
        end

        -- Now, register SPELLs as menu items.
        for _,spell in ipairs(self.battler.chara:getSpells()) do
            local color = spell.color or {1, 1, 1, 1}
            if spell:hasTag("spare_tired") then
                local has_tired = false
                for _,enemy in ipairs(Game.battle:getActiveEnemies()) do
                    if enemy.tired then
                        has_tired = true
                        break
                    end
                end
                if has_tired then
                    color = {0, 178/255, 1, 1}
                end
            end
            Game.battle:addMenuItem({
                ["name"] = spell:getName(),
                ["tp"] = spell:getTPCost(self.battler.chara),
                ["ad"] = spell:getADCost(self.battler.chara),
                ["unusable"] = not spell:isUsable(self.battler.chara),
                ["description"] = spell:getBattleDescription(),
                ["party"] = spell.party,
                ["color"] = color,
                ["data"] = spell,
                ["callback"] = function(menu_item)
                    Game.battle.selected_spell = menu_item

                    if not spell.target or spell.target == "none" then
                        Game.battle:pushAction("SPELL", nil, menu_item)
                    elseif spell.target == "ally" then
                        Game.battle:setState("PARTYSELECT", "SPELL")
                    elseif spell.target == "enemy" then
                        Game.battle:setState("ENEMYSELECT", "SPELL")
                    elseif spell.target == "party" then
                        Game.battle:pushAction("SPELL", Game.battle.party, menu_item)
                    elseif spell.target == "enemies" then
                        Game.battle:pushAction("SPELL", Game.battle:getActiveEnemies(), menu_item)
                    end
                end
            })
        end

        Game.battle:setState("MENUSELECT", "SPELL")
    elseif self.type == "item" then
        Game.battle:clearMenuItems()
        for i,item in ipairs(Game.inventory:getStorage("items")) do
            Game.battle:addMenuItem({
                ["name"] = item:getName(),
                ["unusable"] = item.usable_in ~= "all" and item.usable_in ~= "battle",
                ["description"] = item:getBattleDescription(),
                ["data"] = item,
                ["callback"] = function(menu_item)
                    Game.battle.selected_item = menu_item

                    if not item.target or item.target == "none" then
                        Game.battle:pushAction("ITEM", nil, menu_item)
                    elseif item.target == "ally" then
                        Game.battle:setState("PARTYSELECT", "ITEM")
                    elseif item.target == "enemy" then
                        Game.battle:setState("ENEMYSELECT", "ITEM")
                    elseif item.target == "party" then
                        Game.battle:pushAction("ITEM", Game.battle.party, menu_item)
                    elseif item.target == "enemies" then
                        Game.battle:pushAction("ITEM", Game.battle:getActiveEnemies(), menu_item)
                    end
                end
            })
        end
        if #Game.battle.menu_items > 0 then
            Game.battle:setState("MENUSELECT", "ITEM")
        end
    elseif self.type == "spare" then
        Game.battle:setState("ENEMYSELECT", "SPARE")
    elseif self.type == "defend" then
        Game.battle:pushAction("DEFEND", nil, {tp = -16})
    end
end

function ActionButton:unselect()
    -- Do nothing ?
end

function ActionButton:hasSpecial()
    if self.type == "magic" then
        if self.battler then
            local has_tired = false
            for _,enemy in ipairs(Game.battle:getActiveEnemies()) do
                if enemy.tired then
                    has_tired = true
                    break
                end
            end
            if has_tired then
                local has_pacify = false
                for _,spell in ipairs(self.battler.chara:getSpells()) do
                    if spell and spell:hasTag("spare_tired") then
                        if spell:isUsable(self.battler.chara) and spell:getTPCost(self.battler.chara) <= Game:getTension() then
                            has_pacify = true
                            break
                        end
                    end
                end
                return has_pacify
            end
        end
    elseif self.type == "spare" then
        for _,enemy in ipairs(Game.battle:getActiveEnemies()) do
            if enemy.mercy >= 100 then
                return true
            end
        end
    end
    return false
end

function ActionButton:draw()
    self.hovered_texttexture = Assets.getTexture("ui/battle/btn/txt_" .. self.type .. "_h")
    self.texttexture = Assets.getTexture("ui/battle/btn/txt_" .. self.type)
    if self.selectable and self.hovered then
        if (Game.battle.state == "ACTIONSELECT") then
            Draw.draw(self.hovered_texttexture, 20-self.x, 139-self.y)
            Draw.draw(self.hovered_texture or self.texture)
        else
            Draw.draw(self.hovered_texttexture, 20-self.x, 139-self.y)
        end
    else
        if (Game.battle.state == "ACTIONSELECT") then
            Draw.draw(self.texture)
            if self.selectable and self.special_texture and self:hasSpecial() then
                local r,g,b,a = self:getDrawColor()
                Draw.setColor(r,g,b,a * (0.4 + math.sin((Kristal.getTime() * 30) / 6) * 0.4))
                Draw.draw(self.special_texture)
            end
        end
    end
    super.draw(self)
end

function ActionButton:update()
    for index,battler in ipairs(Game.battle.party) do
        if index == Game.battle.current_selecting then
            self.battler = battler
        end
    end

    super.update(self)
end

return ActionButton