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
## Properties
- `Title = string`
- `Desc = string`
- `Default = bool`
- `Callback = function`
## Methods
- `:SetTitle('New Title')`
- `:SetDesc('New Desc')`
- `:SetValue(true)`
- `:Close()`
