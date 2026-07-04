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
