---@class WaveBG : Interactable
---@overload fun(...) : WaveBG
local WaveBG, super = Class(Interactable)

function WaveBG:init()
  super.init(self)

  
  local background = Sprite("npcs/starwalker")


  self:addChild(background) -- add it to the object\\

  self:setSprite("world/events/savepoint", 1/6)

  background:setScale(2)

  background.layer = 1

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
        ["wave_mag"] = function () return 4 end,
        ["wave_height"] = function () return 4 end,
        ["texsize"] = {SCREEN_WIDTH, SCREEN_HEIGHT}
    }, false, 1)

    self:addFX(wave_fx, "wave_fx")
    print("Waving")
end


return WaveBG