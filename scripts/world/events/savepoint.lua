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

    self.r = 1
    self.g = 1
    self.b = 1

    -- The hitbox is ALMOST half the size of the sprite, but not quite.
    -- It's 9 pixels tall, 10 pixels away from the top.
    -- So divide by 2, round, then multiply by 2 to get the right size for 2x.
    local width, height = self:getSize()
    self:setHitbox(0, math.ceil(height / 4) * 2, width, math.floor(height / 4) * 2)
    self.recolor = self:addFX(RecolorFX())
    --self.alpha = self:addFX(AlphaFX())

    local wave_shader = love.graphics.newShader([[
    extern number wave_sine;
    extern number wave_mag;
    extern number wave_height;
    extern vec2 texsize;
    vec4 effect( vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords )
        {
            number i = texture_coords.y * texsize.y;
            vec2 coords = vec2(max(0.0, min(1.0, texture_coords.x + (sin((i / wave_height) + (wave_sine / 30.0)) * wave_mag) / texsize.x)), max(0.0, min(1.0, texture_coords.y + 0.0)));
            return Texel(texture, coords) * color;
        }
    ]])

    local wave_fx = ShaderFX(wave_shader, {
        ["wave_sine"] = function() return Kristal.getTime() * 100 end,
        ["wave_mag"] = function () return 2 end,
        ["wave_height"] = function () return 2 end,
        ["texsize"] = {SCREEN_WIDTH, SCREEN_HEIGHT}
    }, false, 1)

    self:addFX(wave_fx, "wave_fx")
    print("Waving")
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

    super.onInteract(self, player, dir)
    return true
end

function Savepoint:update()
    if tweening == nil then
        tweening = false
    end
    if tweening == false then
        self.r = self.r - Utils.random(0.5)
        self.g = self.g - Utils.random(0.5)
        self.b = self.b - Utils.random(0.5)
        if self.r > 1 then
            self.r = self.r - 1
        elseif self.r < 0 then
            self.r = self.r + 1
        end
        if self.g > 1 then
            self.g = self.g - 1
        elseif self.g < 0 then
            self.g = self.g + 1
        end
        if self.b > 1 then
            self.b = self.b - 1
        elseif self.b < 0 then
            self.b = self.b + 1
        end
    --self.recolor.color = Utils.lerp(self.recolor.color, {self.r, self.g, self.b}, 1 * DTMULT)
    Game.world.timer:tween(2.5, self.recolor.color, {self.r + 0.4, self.g + 0.4, self.b + 0.4}, linear)
    tweening = true
    --self.alpha = 1
    --self.alpha.alpha = 1
    else
        Game.world.timer:after(4, function() tweening = false end)
        self.recolor.color = {1, 1, 1}
        --Game.world.timer:tween(1, self.recolor.color, {1, 1, 1}, linear, function() tweening = false end)
    end
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

return Savepoint