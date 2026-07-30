local character, super = Class(PartyMember, "harriet")

function character:init()
    super.init(self)

    -- Display name
    self.name = "Harriet"

    -- Actor (handles overworld/battle sprites)
    self:setActor("harriet")
    -- Light World Actor (handles overworld/battle sprites in light world maps) (optional)
    --self:setLightActor("kris_lw")

    -- Display level (saved to the save file)
    self.level = Game.chapter
    -- Default title / class (saved to the save file)
    self.title = ""

    -- Determines which character the soul comes from (higher number = higher priority)
    self.soul_priority = 5
    -- The color of this character's soul (optional, defaults to red)
    self.soul_color = {1, 0, 0}

    -- Whether the party member can act / use spells
    self.has_act = true
    self.has_spells = false

    -- Whether the party member can use their X-Action
    self.has_xact = true
    -- X-Action name (displayed in this character's spell menu)
    self.xact_name = "?-Action"

    -- Spells
    self:addSpell("heal_prayer")
    self:addSpell("adrenoheal")
    self:addSpell("supra_heal")
    self:addSpell("unreasonably_complex_heal")
    self:addAttack("sweepingedge")

    -- Attacks
    self.attackname = "Slash"

    -- Current health (saved to the save file)
    self.health = 100

    -- Base stats (saved to the save file)
    self.stats = {
        health = 100,
        attack = 10,
        defense = 2,
        magic = 0,
        adrenaline = 5
    }

    -- Weapon icon in equip menu
    self.weapon_icon = "ui/menu/equip/sword"

    -- Equipment (saved to the save file)
    self:setWeapon("wood_blade")
    self:setArmor(1, nil)
    self:setArmor(2, nil)

    -- Default light world equipment item IDs (saves current equipment)
    self.lw_weapon_default = "light/pencil"
    self.lw_armor_default = "light/bandage"

    -- Character color (for action box outline and hp bar)
    self.color = {53/255, 47/255, 226/255}
    -- Damage color (for the number when attacking enemies) (defaults to the main color)
    self.dmg_color = nil
    -- Attack bar color (for the target bar used in attack mode) (defaults to the main color)
    self.attack_bar_color = nil
    -- Attack box color (for the attack area in attack mode) (defaults to darkened main color)
    self.attack_box_color = nil
    -- X-Action color (for the color of X-Action menu items) (defaults to the main color)
    self.xact_color = nil

    -- Head icon in the equip / power menu
    self.menu_icon = "party/harriet/head"
    -- Path to head icons used in battle
    self.head_icons = "party/harriet/icon"
    -- Path to status icons used in battle
    self.status_icons = "party/harriet/status"
    -- Name sprite (optional)
    self.name_sprite = "party/harriet/name"

    -- Effect shown above enemy after attacking it
    self.attack_sprite = "effects/attack/cut"
    -- Sound played when this character attacks
    self.attack_sound = "laz_c"
    -- Pitch of the attack sound
    self.attack_pitch = 1

    -- Battle position offset (optional)
    self.battle_offset = nil
    -- Head icon position offset (optional)
    self.head_icon_offset = nil
    -- Menu icon position offset (optional)
    self.menu_icon_offset = nil

    -- Message shown on gameover (optional)
    self.gameover_message = nil
end

-- Function overrides go here

return character