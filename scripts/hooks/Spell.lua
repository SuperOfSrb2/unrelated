local Spell, super = Class("Spell", true)

function Spell:init()
    super.init(self)

    self.adcost = 0
end

function Spell:getADCost(chara) return self.adcost end

return Spell