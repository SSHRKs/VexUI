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
## Set MaxSymbols
```lua
Input:SetMaxSymbols(999)
```
## Set Input Value
```lua
Input:SetValue('New Value')
```
## Destroy Element
```lua
Input:Close()
```
