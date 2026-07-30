---@class Savepoint : Interactable
---@overload fun(...) : Savepoint
local Savepoint, super = Class(Interactable)

function Savepoint:init(x, y, properties)
    super.init(self, x, y, nil, nil, properties)

    properties = properties or {}

    self.marker = properties["marker"]
    self.simple_menu = properties["simple"]
    self.text_once = properties["text_once"]
    self.heals = properties["heals"] ~= false

    self.solid = true

    self:setOrigin(0.5, 0.5)
    self:setSprite("world/events/savepoint", 1/6)

    self.used = false


    self.colors = {}

    -- The hitbox is ALMOST half the size of the sprite, but not quite.
    -- It's 9 pixels tall, 10 pixels away from the top.
    -- So divide by 2, round, then multiply by 2 to get the right size for 2x.
    local width, height = self:getSize()
    self:setHitbox(0, math.ceil(height / 4) * 2, width, math.floor(height / 4) * 2)

    myShader = love.graphics.newShader([[
        extern vec4 Color;
        vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords ) {
            vec4 pixel = Texel(texture, texture_coords );
            return pixel * Color;
          }
  ]])
end

function Savepoint:onInteract(player, dir)
    Assets.playSound("power")

    if self.text_once and self.used then
        self:onTextEnd()
        return
    end

    if self.text_once then
        self.used = true
    end

    Game.world.timer:tween(10, self.colors[r], {r = 0}, 'linear', function() fade = false end)

    super.onInteract(self, player, dir)
    return true
end

function Savepoint:update()
    --if self.tweening == false then
        self.colors[r] = self.colors[r] - Utils.random(1)
        self.colors[g] = self.colors[g] - Utils.random(1)
        self.colors[b] = self.colors[b] - Utils.random(1)
        if self.colors[r] > 1 then
            self.colors[r] = self.colors[r] - 1
        elseif self.colors[r] < 0 then
            self.colors[r] = self.colors[r] + 1
        end
        if self.colors[g] > 1 then
            self.colors[g] = self.colors[g] - 1
        elseif self.colors[g] < 0 then
            self.colors[g] = self.colors[g] + 1
        end
        if self.colors[b] > 1 then
            self.colors[b] = self.colors[b] - 1
        elseif self.colors[b] < 0 then
            self.colors[b] = self.colors[b] + 1
        end
    --else
        --Timer:tween(5,pr,r)
        --Timer:tween(5,pg,g)
        --Timer:tween(5,pb,b)
    --end
    super.update(self)
end

function Savepoint:onTextEnd()
    if not self.world then return end

    if self.heals then
        for _,party in ipairs(Game.party) do
            party:heal(math.huge, false)
        end
    end

    if Game:isLight() then
        self.world:openMenu(LightSaveMenu(Game.save_id, self.marker))
    elseif self.simple_menu or (self.simple_menu == nil and Game:getConfig("smallSaveMenu")) then
        self.world:openMenu(SimpleSaveMenu(Game.save_id, self.marker))
    else
        self.world:openMenu(SaveMenu(self.marker))
    end
end

function Savepoint:draw()
    love.graphics.setShader(myShader) --draw something here
    myShader:sendColor("Color", {self.colors[r], self.colors[g], self.colors[b], self.colors[a]})
        super.draw(self)
    love.graphics.setShader()
end

return Savepoint