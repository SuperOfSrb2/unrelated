---@class ItemButton : ActionButton
---@overload fun(...) : ItemButton
local ItemButton, super = HookSystem.hookScript(ItemButton)

---@param battler PartyBattler
---@param x number
---@param y number
function ItemButton:init(battler, x, y)
    super.init(self, battler, x, y)
end

function ItemButton:getTexture()
    return Assets.getTexture("ui/battle/btn/item")
end

function ItemButton:getTextTexture()
    return Assets.getTexture("ui/battle/btn/item_b")
end


function ItemButton:getHoveredTexture()
    return Assets.getTexture("ui/battle/btn/item_h")
end

function ItemButton:getSpecialTexture()
    return Assets.getTexture("ui/battle/btn/item_a")
end

function ItemButton:getDisabledTexture()
    return Assets.getTexture("ui/battle/btn/item_d")
end

function ItemButton:select()
    Game.battle:enterItemsMenu()
end

return ItemButton
