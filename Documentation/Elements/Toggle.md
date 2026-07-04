```lua
local Toggle = Tab:Toggle({
    Title = "Toggle",
    Desc = "This is a toggle",
    Default = false,
    Callback = function(status)
        print(status)
    end
})
```
