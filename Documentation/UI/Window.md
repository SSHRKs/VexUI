## Creating Window
```luau
local Window = UI:CreateWindow({
    Name = "Super Pisun",
    Icon = "door-open",
    SideBarWidth = 160,
    Theme = "Dark",
    Folder = "FolderName",
    Transparent = true,
    ToggleKey = Enum.KeyCode.F,
    Size = UDim2.new(0, 480, 0, 360),
    --Author = "By .s.h.ark.",
    --[[User = {
        Enabled = true,
        Anonymous = true,
    },--]]
    --[[KeySystem = {
        Title = "Super Pisun",
        Desc = "Key Desc",
        KeyValidator = function(key)
            return key == "1234"
        end,
        URL = "1234", --LINK TO GET KEY
    },--]] -- Key System Not Finalized!
})
```

## Creating TopBar Button / Toggle
```luau
VexUI:CreateTopbarToggle({ --TOGGLE
    Order = 4,
    EnableIcon = "banana",
    DisableIcon = "at-sign",
    Default = true,
    EnableBackground = Color3.fromRGB(155, 25, 25),
    Callback = function(Value)
        print(Value)
    end
})

VexUI:CreateTopbarButton({ --BUTTON
    Order = 4,
    Icon = "bird",
    Callback = function()
        print("Pisun")
    end
})
```

##Creating Dialog
```lua
VexUI:Dialog({
    Title = "Dialog Title",
    Desc = "Dialog Description",
    --Image = "rbxassetid://14309518613",
    Buttons = {
        {Text = "Button 1", Callback = function() print("Button 1") end},
        {Text = "Button 2", Callback = function() print("Button 2") end},
    }
})
```
## Setting Library

## Set Theme
```lua
Window:SetTheme("Dark")
```
## Set Transparency
```lua
Window:SetTransparency(false) --true / false
```
## Set ToggleKey
```lua
Window:SetToggleKey(Enum.KeyCode.F)
```


## User
## Set UserEnabled
```lua
Window:UserEnabled(true)
```
## Set Anonymous
```lua
Window:Anonymous(true)
```
