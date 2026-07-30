local spell, super = Class(Spell, "adrenoheal")

function spell:init()
    super.init(self)

    -- Display name
    self.name = "AdrenoHeal"
    -- Name displayed when cast (optional)
    self.cast_name = nil

    -- Battle description
    if Game.chapter <= 3 then
        self.effect = "Heal\nAlly"
    else
        self.effect = "Heal\nally"
    end
    -- Menu description
    self.description = "Burning adrenaline restores a little HP to\none party member. Depends on Attack."

    -- TP cost
    self.cost = 0
    self.adcost = 2

    -- Target mode (ally, party, enemy, enemies, or none)
    self.target = "ally"

    -- Tags that apply to this spell
    self.tags = {"heal"}
end

function spell:onCast(user, target)
    target:heal(user.chara:getStat("attack") * 5)
end

function spell:hasWorldUsage(chara)
    return true
end

function spell:onWorldCast(chara)
    Game.world:heal(chara, 100)
end

return spell