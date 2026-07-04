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

## Set Title
```lua
Toggle:SetTitle('New Title')
```
## Set Desc
```lua
Toggle:SetDesc('New Desc')
```
## Set Value
```lua
Toggle:SetValue(true)
```
## Destroy Element
```lua
Toggle:Close()
```
