-- Create an item and specify its ID (id is optional, defaults to file path)
local item, super = Class(Item, "test_tome")
local vampire = false

function item:init()
    super.init(self)

    -- Display name
    self.name = "Test Tome"
    -- Name displayed when used in battle (optional)
    self.use_name = nil

    -- Item type (item, key, weapon, armor)
    self.type = "tome"
    -- Item icon (for equipment)
    self.icon = "ui/menu/icon/tome"

    -- Battle description
    self.effect = "Toumua...!"
    -- Shop description
    self.shop = "Tome."
    -- Menu description
    self.description = "Example tome."

    -- Default shop price (sell price is halved)
    self.price = 0
    -- Whether the item can be sold
    self.can_sell = true

    -- Consumable target mode (ally, party, enemy, enemies, or none)
    self.target = "none"
    -- Where this item can be used (world, battle, all, or none)
    self.usable_in = "all"
    -- Item this item will get turned into when consumed
    self.result_item = nil
    -- Will this item be instantly consumed in battles?
    self.instant = false

    -- Equip bonuses (for weapons and armor)
    -- Works same for tomes
    self.bonuses = {
        attack = 99,
        magic  = 99,
    }
    -- Bonus name and icon (displayed in equip menu)
    -- Probably shouldn't do this since you are putting the tome in the fourth slot, but may add compatability later
    self.bonus_name = nil
    self.bonus_icon = nil

    -- Equippable characters (default true for armors, false for weapons)
    -- Works same for tomes, default true
    self.can_equip = {
        kris = true,
        susie = true,
        ralsei = true,
        noelle = true,
    }

    -- Character reactions (key = party member id)
    self.reactions = {
        kris = "I have the powa!",
        susie = "Wow! Who knew reading was so fun!",
        ralsei = "These spells are... powerful.",
        noelle = "...It's just a notebook????",
    }
end

-- Function overrides go here

--[[function PartyMember:replaceSpell(origspell, replacement)
    local tempspells = {}
    for _,spell in ipairs(char:getSpells()) do
            if spell = origspell or (type(origspell) == "string" and spell.id == origspell) then
                table.insert(tempspells, Registry.createSpell(replacement))
            else
                table.insert(tempspells, spell)
            end
        end
    end
    char.spells = tempspells
end]]

function item:onEquip(char, replacement)
    if char.name == "Kris" then -- Custom Effect, add Spell Menu
        if char.has_spells == true then
            char.flags["hadspells"] = true
        else
            char.flags["hadspells"] = false
        end
        if char.flags["hadspells"] == false then
            char.has_spells = true
        end
        char.flags["vampire"] = true -- Does nothing, but a custom effect could be used, for example, or even Susie's uncontrollable mode from Chapter 1
    elseif char.name == "Susie" then -- Spell Replacing
        for _,spell in ipairs(char:getSpells()) do
            if spell.name == "Red Buster" then
                char.flags["hadredbuster"] = true
            else
                char.flags["hadredbuster"] = false
            end
        end
        char:replaceSpell("rude_buster","red_buster")
    elseif char.name == "Noelle" then -- Spell Addition
        for _,spell in ipairs(char:getSpells()) do
            if spell.name == "SnowGrave" then
                char.flags["hadsnowgrave"] = true
            else
                char.flags["hadsnowgrave"] = false
            end
        end
        if char.flags["hadsnowgrave"] == false then
            char:addSpell("snowgrave")
        end
    elseif char.name == "Ralsei" then -- Add act menu and remove X-Action
        if char.has_act == true then
            char.flags["hadact"] = true
        else
            char.flags["hadact"] = false
        end
        if char.has_xact == true then
            char.flags["hadxact"] = true
        else
            char.flags["hadxact"] = false
        end
        if char.flags["hadact"] == false then
            char.has_act = true
        end
        char.has_xact = false
    end
return true
end

function item:onUnequip(char, replacement)
    if char.name == "Kris" then -- Custom effect & Spell Menu
        char.flags["vampire"] = false
        if char.flags["hadspells"] == false then
            char.has_spells = false
        end
    elseif char.name == "Susie" then -- Spell Replacing
        if char.flags["hadredbuster"] == false then
            char:replaceSpell("red_buster","rude_buster")
        end
    elseif char.name == "Noelle" then -- Spell Addition
        if char.flags["hadsnowgrave"] == false then
            char:removeSpell("snowgrave")
        end
    elseif char.name == "Ralsei" then -- Add act menu and remove X-Action
        if char.flags["hadact"] == false then
            char.has_act = false
        end
        char.has_xact = true
    end
return true
end

return item