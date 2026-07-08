```lua
local Button = Tab:Button({
    Title = "Button",
    Desc = "This is a button",
    Callback = function()
        print("Hello Pisun")
    end
})
```
## Properties
- `Title = string`
- `Desc = string`
- `Callback = function`
## Methods
- `:SetTitle('New Title')`
- `:SetDesc('New Desc')`
- `:Close()`
