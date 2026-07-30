--- attacks are data files that extend this `attack` class to define a castable attack. \
--- attacks are stored in `scripts/data/attacks`, and their filepath starting at this location becomes their id, unless an id for them is specified as the second argument to `Class()`.
--- attacks are learned by [`PartyMember`](lua://PartyMember.init)s, and they can be given a attack by calling [`PartyMember:addattack()`](lua://PartyMember.addattack) (likewise, [`PartyMember:removeAttack()`](lua://PartyMember.removeAttack) removes a attack).
---
---@class Attack : Class
---
---@field name string           The display name of the attack
---@field cast_name string?     The disaply name of the attack when cast (optional)
---
---@field effect string         The battle description of the attack
---@field description string    The overworld menu description of the attack
---
---@field cost number           The TP cost of the attack
---@field usable boolean        Whether the attack can be cast
---
---@field target string         The target mode of the attack - valid options are `"ally"`, `"party"`, `"enemy"`, `"enemies"`, and `"none"`
---
--- Tags that apply to this attack \
--- Tags are used to identify properties of the attack that can be checked by other pieces of code for certain effects, For example: \
--- The built in tag `spare_tired` will cause the attack to be highlighted if an enemy is TIRED
---@field tags string[]
---
---@overload fun(...) : Attack
local Attack = Class()

function Attack:init()
    self.name = "Test Attack"
    self.cast_name = nil

    self.effect = ""
    self.description = ""

    self.cost = 0
    self.usable = true

    self.target = "none"

    self.tags = {}
    self.adcost = 0
end

---@return string
function Attack:getName() return self.name end
---@return string
function Attack:getCastName() return self.cast_name or self:getName():upper() end

---@return string
function Attack:getDescription() return self.description end
---@return string
function Attack:getBattleDescription() return self.effect end

--- Gets the TP required to cast this attack
---@param chara PartyMember The `PartyMember` that is casting the attack
---@return number
function Attack:getTPCost(chara) return self.cost end
function Attack:getADCost(chara) return self.adcost end
--- *(Override)* Gets whether the attack is currently castable
---@param chara PartyMember The `PartyMember` the check is being run for
---@return boolean
function Attack:isUsable(chara) return self.usable end

--- *(Override)* Gets whether the attack can be cast in the world \
--- *(Always false by default)*
---@param chara PartyMember The `PartyMember` the check is being run for
---@return boolean
function Attack:hasWorldUsage(chara) return false end

--- *(Override)* Called whenever the attack is cast in the overworld \
--- Code that controls the effect of the attack when cast in the overworld goes here
---@param chara PartyMember
function Attack:onWorldCast(chara) end

--- Checks whether the attack has a specific tag attached to it
---@param tag string
---@return boolean
function Attack:hasTag(tag)
    return Utils.containsValue(self.tags, tag)
end

--- *(Override)* Gets the message that appears when this attack is cast in battle
---@param user PartyBattler
---@param target Battler[]|EnemyBattler|PartyBattler|EnemyBattler[]|PartyBattler[]
---@return string
function Attack:getCastMessage(user, target)
    return "* "..user.chara:getName().." cast "..self:getCastName().."!"
end

--- *(Override)* Called when the attack is cast \
--- The code for the effects of the attack (such as damage or healing) should go into this function
---@param user PartyBattler
---@param target Battler[]|EnemyBattler|PartyBattler|EnemyBattler[]|PartyBattler[]
---@return boolean? finish_action   Whether the attack action finishes automatically, when `false` the action can be manually ended with `Game.battle:finishActionBy(user)` (defaults to `true`) 
function Attack:onCast(user, target)
    -- Returning false here allows you to call 'Game.battle:finishActionBy(user)' yourself
end

--- Called at the start of a attack cast, manages internal functionality \
--- Don't use this function for attack effects - see [`Attack:onCast()`](lua://Attack.onCast) instead
---@param user PartyBattler
---@param target Battler[]|EnemyBattler|PartyBattler|EnemyBattler[]|PartyBattler[]
function Attack:onStart(user, target)
    Game.battle:battleText(self:getCastMessage(user, target))
    user:setAnimation("battle/attack", function()
        Game.battle:clearActionIcon(user)
        local result = self:onCast(user, target)
        if result or result == nil then
            Game.battle:finishActionBy(user)
        end
    end)
end

--- *(Override)* Called whenever the attack is selected for use in battle
---@param user PartyBattler
---@param target Battler[]|EnemyBattler|PartyBattler|EnemyBattler[]|PartyBattler[]
function Attack:onSelect(user, target) end
--- *(Override)* Called whenever the attack use is undone in battle
---@param user PartyBattler
---@param target Battler[]|EnemyBattler|PartyBattler|EnemyBattler[]|PartyBattler[]
function Attack:onDeselect(user, target) end

return Attack