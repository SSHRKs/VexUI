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
## Set Keybind Value
```lua
Keybind:SetValue('F')
```
## Destroy Element
```lua
Keybind:Close()
```
