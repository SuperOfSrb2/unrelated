local Lib = {}

function Lib:init()
    print("Loaded Attacks Lib " .. self.info.version .. "!")
	
	Utils.hook(Utils, "dump", function(orig, o)
		if type(o) == "table" and isClass(o) and o.__tostring then
			return tostring(o)
		end
		return orig(o)
	end)

    Utils.hook(PartyMember, "addAttack", function(orig, self, attack)
        if type(attack) == "string" then
            attack = Lib:createAttack(attack)
        end
        table.insert(self.attacks, attack)
    end)

    Utils.hook(PartyMember, "replaceAttack", function(orig, self, attack, replacement)
        local tempattacks = {}
        for _,v in ipairs(self.attacks) do
            if v == attack or (type(attack) == "string" and v.id == attack) then
                table.insert(tempattacks, Lib:createAttack(replacement))
            else
                table.insert(tempattacks, v)
            end
        end
        self.attacks = tempattacks
    end)

    Utils.hook(PartyMember, "loadAttacks", function(orig, self, data)
        self.attacks = {}
        for _,v in ipairs(data) do
            if Lib:getAttack(v) then
                self:addAttack(v)
            else
                Kristal.Console:error("Could not load attack \"".. (v or "nil") .."\"")
            end
        end
    end)

    Utils.hook(PartyMember, "getAttack", function(orig, self, attack)
        if type(attack) == "string" then
            attack = Lib:createAttack(attack)
        end
        return attack
    end)

end

function Lib:onRegistered()
    Mod.attacks = {}
    print("11 dom")

    for _,path,attack in Registry.iterScripts("data/attacks") do
        assert(attack ~= nil, '"attacks/'..path..'.lua" does not return value')
        print("ez 1 "..path)
        attack.id = attack.id or path
        Mod.attacks[attack.id] = attack
    end
end

function Lib:registerAttack(id, class)
    Mod.attacks[id] = class
end

function Lib:getAttack(id)
    return Mod.attacks[id]
end

function Lib:createAttack(id, ...)
    if Mod.attacks[id] then
        return Mod.attacks[id](...)
    else
        error("Attempt to create non existent attack \"" .. tostring(id) .. "\"")
    end
end

return Lib