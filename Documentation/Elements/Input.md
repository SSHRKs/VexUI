## Creating Input
```lua
local Input = Tab:Input({
    Title = "Input",
    Desc = "This is an input",
    --MaxSymbols = 10,
    Callback = function(input)
        print(input)
    end
})
```
## Properties
- `Title = string`
- `Desc = string`
- `MaxSymbols = number`
- `Callback = function`
## Methods
- `:SetTitle('New Title')`
- `:SetDesc('New Desc')`
- `:SetMaxSymbols(999)`
- `:SetValue('New Value')`
- `:Close()`
