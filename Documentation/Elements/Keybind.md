## Creating Keybind
```lua
local Keybind = Tab:Keybind({
    Title = "Keybind",
    Callback = function(key)
        print(key)
    end
})
```

## Set Title
```lua
Keybind:SetTitle('New Title')
```
## Set Desc
```lua
Keybind:SetDesc('New Desc')
```
## Destroy Element
```lua
Keybind:Close()
```
