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

## Set Title
```lua
Input:SetTitle('New Title')
```
## Set Desc
```lua
Input:SetDesc('New Desc')
```
## Destroy Element
```lua
Input:Close()
```
