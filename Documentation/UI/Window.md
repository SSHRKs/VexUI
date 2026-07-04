## Creating Window
```luau
local Window = UI:CreateWindow({
    Name = "Super Pisun",
    Icon = "door-open",
    SideBarWidth = 160,
    Theme = "Dark",
    Transparent = true,
    --Author = "By .s.h.ark.",
    --[[User = {
        Enabled = true,
        Anonymous = true,
    },--]]
    --[[KeySystem = {
        Title = "Super Pisun",
        Desc = "Key Desc",
        KeyValidator = function(key)
            local validKeys = {"key1", "key2", "key3"}
            return table.find(validKeys, key) ~= nil
        end,
        URL = "1234", --LINK TO GET KEY
    },--]] -- Key System Not Finalized!
})
```

## Creating TopBar Button / Toggle
```luau
UI:CreateTopbarToggle({ --TOGGLE
    Order = 4,
    EnableIcon = "banana",
    DisableIcon = "at-sign",
    Default = true,
    EnableBackground = Color3.fromRGB(155, 25, 25),
    Callback = function(Value)
        print(Value)
    end
})

UI:CreateTopbarButton({ --BUTTON
    Order = 4,
    Callback = function()
        print("Pisun")
    end
})
```
