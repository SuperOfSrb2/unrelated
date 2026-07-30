local spell, super = Class(Spell, "unreasonably_complex_heal")

function spell:init()
    super.init(self)

    -- Display name
    self.name = "UnrCompHeal"
    -- Name displayed when cast (optional)
    self.cast_name = "Unreasonably Complex Heal"

    -- Battle description
    self.effect = "Heal\nSome\nGuys"
    -- Menu description
    self.description = "Whatever dude."

    -- TP cost
    self.cost = 16
    self.adcost = 4

    -- Target mode (ally, party, enemy, enemies, or none)
    self.target = "party"

    -- Tags that apply to this spell
    self.tags = {"heal"}
end

function spell:onCast(user, target)
    for _,battler in ipairs(target) do
        battler:heal((user.chara:getStat("defense") * 5.5))
    end
end

return spell