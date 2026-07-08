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
## Properties
- `Title = string`
- `Desc = string`
- `Value = table`
- `Min = number`
- `Max = number`
- `Default = number`
- `Step = number`
- `Callback = function`
## Methods
- `:SetTitle('New Title')`
- `:SetDesc('New Desc')`
- `:SetValue(220)`
- `:Close()`
