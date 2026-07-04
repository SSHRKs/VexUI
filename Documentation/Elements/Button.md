```lua
local Button = Tab:Button({
    Title = "Button",
    Desc = "This is a button",
    Callback = function()
        print("Hello Pisun")
    end
})
```

## Set Title
```lua
Button:SetTitle('New Title')
```
## Set Desc
```lua
Button:SetDesc('New Desc')
```
## Destroy Element
```lua
Button:Close()
```
