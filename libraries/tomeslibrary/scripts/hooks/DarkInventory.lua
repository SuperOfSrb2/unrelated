---@class DarkInventory : DarkInventory
---@overload fun(...) : DarkInventory
local DarkInventory, super = Class("DarkInventory", true)

function DarkInventory:init()
    super.init(self)

    self.storage_for_type = {
        ["item"]   = "items",
        ["key"]    = "key_items",
        ["weapon"] = "weapons",
        ["armor"]  = "armors",
        ["tome"] = "tomes",
    }

    self.storage_enabled = Game:getConfig("enableStorage")

    -- Order the storages are converted to the light world
    self.convert_order = {"key_items", "light", "weapons", "armors", "tomes", "items", "storage"}
end

function DarkInventory:clear()
    super.clear(self)

    self.storages = {
        ["items"]     = {id = "items",     max = 12, sorted = true,  name = "ITEMs",       fallback = "storage"},
        ["key_items"] = {id = "key_items", max = 12, sorted = true,  name = "KEY ITEMs",   fallback = nil      },
        ["weapons"]   = {id = "weapons",   max = 48, sorted = false, name = "WEAPONs",     fallback = nil      },
        ["armors"]    = {id = "armors",    max = 48, sorted = false, name = "ARMORs",      fallback = nil      },
        ["tomes"]    = {id = "tomes",    max = 48, sorted = false, name = "TOMEs",      fallback = nil      },
        ["storage"]   = {id = "storage",   max = 24, sorted = false, name = "STORAGE",     fallback = nil      },

        ["light"]     = {id = "light",     max = 28, sorted = true,  name = "LIGHT ITEMs", fallback = nil      },
    }

    Kristal.callEvent("createDarkInventory", self)
end

return DarkInventory