local attack, super = Class(Attack, "standard")

function attack:init()
    super.init(self)

    -- Display name
    self.name = "Standard"
    -- Name displayed when cast (optional)
    self.cast_name = nil

    -- Battle description
    self.effect = ""
    -- Menu description
    self.description = "Default attack anyone can use."

    -- TP cost
    self.cost = 0

    -- Target mode (ally, party, enemy, enemies, or none)
    self.target = "none"

    -- Tags that apply to this attack
    self.tags = {"damage"}
end

function attack:getName() return Game.battle.party[Game.battle.current_selecting].chara:getStandardAttack() end

return attack