local spell, super = Class(Spell, "supra_heal")

function spell:init()
    super.init(self)

    -- Display name
    self.name = "Supra Heal"
    -- Name displayed when cast (optional)
    self.cast_name = nil

    -- Battle description
    self.effect = "Heal\nAll"
    -- Menu description
    self.description = "Supreme radiance restores a little HP to\nall party members. Depends on Attack & Magic."

    -- TP cost
    self.cost = 25
    self.adcost = 5

    -- Target mode (ally, party, enemy, enemies, or none)
    self.target = "party"

    -- Tags that apply to this spell
    self.tags = {"heal"}
end

function spell:onCast(user, target)
    for _,battler in ipairs(target) do
        battler:heal((user.chara:getStat("magic") * 5.5) + (user.chara:getStat("attack") * 5.5))
    end
end

return spell