---@class PartyMember : PartyMember
---@overload fun(...) : PartyMember
local PartyMember, super = Class("PartyMember", true)

function PartyMember:init()
    super.init(self)
    
    self.status_icons = "party/empty/status"
    self.status_icon_offset = nil
    self.attacks = {}
    self.attackname = "Attack"

    self.adrenaline = 5
    self.pastadrenaline = 5

    self.stats = {
        health = 100,
        attack = 10,
        defense = 2,
        magic = 0,
        adrenaline = 5
    }
end

function PartyMember:getAdrenaline() return self.adrenaline end
function PartyMember:getPastAdrenaline() return self.pastadrenaline end

function PartyMember:addAdrenaline(adrenaline)
    self.pastadrenaline = self.adrenaline 
    self.adrenaline = self.adrenaline + adrenaline 
end
function PartyMember:removeAdrenaline(adrenaline)
    self.pastadrenaline = self.adrenaline
    self.adrenaline = self.adrenaline - adrenaline 
end

function PartyMember:updateAdrenaline()

    local diff = math.abs(self.pastadrenaline - self.adrenaline)
    local dir = -1
    if self.pastadrenaline < self.adrenaline then dir = 1 end
    if diff > 3 then
        self.pastadrenaline = self.pastadrenaline + dir*1
    elseif diff > 1 then
        self.pastadrenaline = self.pastadrenaline + dir*0.5
    elseif diff > 0.5 then
        self.pastadrenaline = self.pastadrenaline + dir*0.2
    elseif diff >= 0.01 then
        self.pastadrenaline = self.pastadrenaline + dir*0.1
    elseif diff < 0.01 then
        --self.pastadrenaline = self.adrenaline
    end


end

function PartyMember:getStandardAttack()
    return self.attackname
end

function PartyMember:getAttacks()
    return self.attacks
end

function PartyMember:removeAttack(attack)
    for i,v in ipairs(self.attacks) do
        if v == attack or (type(attack) == "string" and v.id == attack) then
            table.remove(self.attack, i)
            return
        end
    end
end

function PartyMember:hasAttack(attack)
    for i,v in ipairs(self.attacks) do
        if v == attack or (type(attack) == "string" and v.id == attack) then
            return true
        end
    end
    return false
end

function PartyMember:saveAttacks()
    local result = {}
    for _,v in pairs(self.attacks) do
        table.insert(result, v.id)
    end
    return result
end

function PartyMember:save()
    local data = {
        id = self.id,
        title = self.title,
        level = self.level,
        health = self.health,
        stats = self.stats,
        lw_lv = self.lw_lv,
        lw_exp = self.lw_exp,
        lw_health = self.lw_health,
        lw_stats = self.lw_stats,
        spells = self:saveSpells(),
        attacks = self:saveAttacks(),
        equipped = self:saveEquipment(),
        flags = self.flags
    }
    self:onSave(data)
    return data
end

function PartyMember:load(data)
    self.title = data.title or self.title
    self.level = data.level or self.level
    self.stats = data.stats or self.stats
    self.lw_lv = data.lw_lv or self.lw_lv
    self.lw_exp = data.lw_exp or self.lw_exp
    self.lw_stats = data.lw_stats or self.lw_stats
    if data.spells then
        self:loadSpells(data.spells)
    end
    if data.attacks then
        self:loadAttacks(data.attacks)
    end
    if data.equipped then
        self:loadEquipment(data.equipped)
    end
    self.flags = data.flags or self.flags
    self.health = data.health or self:getStat("health", 0, false)
    self.lw_health = data.lw_health or self:getStat("health", 0, true)

    self:onLoad(data)
end

function PartyMember:getStatusIcons() return self.status_icons end
function PartyMember:getStatusIconOffset() return unpack(self.status_icon_offset or {0, 0}) end

return PartyMember