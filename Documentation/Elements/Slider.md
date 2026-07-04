## Creating Slider
```lua
local Slider = Tab:Slider({
    Title = "Slider",
    Desc = "This is a slider",
    Value = {
        Min = 0,
        Max = 100,
        Default = 25,
    },
    Step = 1,
    Callback = function(value)
        print(value)
    end
})
```

## Set Title
```lua
Slider:SetTitle('New Title')
```
## Set Desc
```lua
Slider:SetDesc('New Desc')
```
## Destroy Element
```lua
Slider:Close()
```
