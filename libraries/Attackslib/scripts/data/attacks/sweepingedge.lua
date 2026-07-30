local attack, super = Class(Attack, "sweepingedge")
--local sweepingedge, super = Class(Attack)

function attack:init()
    super.init(self)

    -- Display name
    self.name = "SweepingEdge"
    -- Name displayed when cast (optional)
    self.cast_name = nil

    -- Battle description
    self.effect = "Damage\nto all\nenemies"
    -- Menu description
    self.description = "Aim for the center to\nhit all the enemies!"

    -- TP cost
    self.cost = 22

    -- Target mode (ally, party, enemy, enemies, or none)
    self.target = "enemies"

    -- Tags that apply to this attack
    self.tags = {"damage"}
end

function attack:getAttackDamage(user, target)
    local min_magic = Utils.clamp(user.chara:getStat("magic") - 10, 1, 999)

    return math.ceil((min_magic * 30) + 90 + Utils.random(10))
end

return attack