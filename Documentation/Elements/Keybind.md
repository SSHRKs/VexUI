## Creating Keybind
```lua
local Keybind = Tab:Keybind({
    Title = "Keybind",
    Callback = function(key)
        print(key)
    end
})
```
## Properties
- `Title = string`
- `Desc = string`
- `Value = string`
- `Callback = function`
## Methods
- `:SetTitle('New Title')`
- `:SetDesc('New Desc')`
- `:SetValue('F')`
- `:Close()`
