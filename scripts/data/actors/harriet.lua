local actor, super = Class(Actor, "harriet")

function actor:init()
    -- Display name (optional)
    super.init(self)
    self.name = "Harriet"

    -- Width and height for this actor, used to determine its center
    self.width = 18
    self.height = 38

    -- Hitbox for this actor in the overworld (optional, uses width and height by default)
    self.hitbox = {0, 25, 19, 14}

    -- Color for this actor used in outline areas (optional, defaults to red)
    self.color = {1, 0, 0}

    -- Whether this actor flips horizontally (optional, values are "right" or "left", indicating the flip direction)
    self.flip = left

    -- Path to this actor's sprites (defaults to "")
    self.path = "party/harriet/dark"
    -- This actor's default sprite or animation, relative to the path (defaults to "")
    self.default = "walk"
    --mirror
    self.mirror_sprites = {
        ["walk/down"] = "walk/up",
        ["walk/up"] = "walk/down",
        ["walk/left"] = "walk/left",
        ["walk/right"] = "walk/right",
    }
    -- Sound to play when this actor speaks (optional)
    self.voice = nil
    -- Path to this actor's portrait for dialogue (optional)
    self.portrait_path = nil
    -- Offset position for this actor's portrait (optional)
    self.portrait_offset = nil

    -- Whether this actor as a follower will blush when close to the player
    self.can_blush = false

    -- Table of talk sprites and their talk speeds (default 0.25)
    self.talk_sprites = {}

    -- Table of sprite animations
    self.animations = {}

    -- Table of sprite offsets (indexed by sprite name)
    self.offsets = {

        ["walk/left"] = {-0.5, 0},
        ["walk/right"] = {-0.5, 0},
        ["walk/up"] = {-0.5, 0},
        ["walk/down"] = {-0.5, 0},

    }
end

-- Function overrides go here

return actor