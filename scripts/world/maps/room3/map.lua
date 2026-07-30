local Room3, super = Class(Map)

function Room3:load()
    super.load(self)

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
        ["wave_mag"] = function () return 6 end,
        ["wave_height"] = function () return 2 end,
        ["texsize"] = {SCREEN_WIDTH, SCREEN_HEIGHT}
    }, false, 1)

    self:getImageLayer("geyser"):addFX(wave_fx, "wave_fx")
    print("Waving")
end

function Room3:update()
    super.update(self)

    local geyser = self:getImageLayer("geyser")

    --geyser.offsety = geyser.offsety + 2
    
end

return Room3