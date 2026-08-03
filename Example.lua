local VexUI = loadstring(game:HttpGet("https://github.com/SSHRKs/VexUI/releases/latest/download/main.lua"))()
local Window = VexUI:CreateWindow({
    Name = "VexUI Example",
    Icon = "door-open",
    SideBarWidth = 160,
    Theme = "Dark",
    Transparent = true,
    Author = "By .s.h.ark.",
    User = {
        Enabled = true,
        Anonymous = true,
    },
    KeySystem = {
        Title = "VexUI Example",
        Desc = "This is an example of a key system using VexUI. \nKey: 1234 <key-round>",
        KeyValidator = function(key)
            return key == "1234"
        end,
        URL = "1234",
    },
})

Window:EditOpenButton({
    Title = "Open VexUI",
    Icon = "door-open",
    Transparency = 0.2,
    StrokeThickness = 1,
    Rotation = 0,
    Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 255, 80)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 90, 255))
    },
    AutoRotation = true,
    Speed = 15,
    CornerRadius = UDim.new(0,16),
})

VexUI:CreateTopbarButton({
    Order = 4,
    Callback = function()
        print("Pisun")
    end
})
VexUI:CreateTopbarToggle({
    Order = 4,
    EnableIcon = "banana",
    DisableIcon = "at-sign",
    Callback = function(Value)
        print(Value)
    end
})

local DisplayElements = Window:Tab({Title = "Display Elements",Icon = "picture-in-picture",Border = true,})
local ManagementTab = Window:Tab({Title = "Management", Icon = "chart-no-axes-gantt",Border = true,})
local InputTab = Window:Tab({Title = "Input Elements", Icon = "file-input",Border = true,})
local NotificationTab = Window:Tab({Title = "Notification", Icon = "message-square-dot",Border = true,})
local LockedTab = Window:Tab({Title = "Locked Elements", Icon = "lock-keyhole",Border = true,})
local GroupTab = Window:Tab({Title = "Group", Icon = "group",Border = true,})
Window:SelectTab(1)
local Section = Window:Section({ Title = "Other", Icon = "hash" })
local Settings = Section:Tab({ Title = "Settings", Icon = "settings",Border = true})

DisplayElements:Section({Title = "Section"})
DisplayElements:Paragraph({
    Title = "Paragraph",
    Desc = "This is a Paragraph",
})
DisplayElements:Paragraph({
    Title = "Paragraph Icon <smile>",
    Desc = "This is a Paragraph",
    Icon = "bird"
})
DisplayElements:Devider()
DisplayElements:Paragraph({
    Title = "Paragraph Thumbnail",
    Desc = "This is a Paragraph",
    Thumbnail = "rbxassetid://78903626783621",
    Icon = "solar:lock-keyhole-unlocked-broken"
})
DisplayElements:Section({Title = "Color Paragraph", Icon = "paintbrush"})
local Colors = {"Red", "Coral", "Orange", "Yellow", "Green", "Mint", "Cyan", "Blue", "Purple", "Pink"}
local ColorCount = 0
for i = 1, 10 do
    ColorCount = ColorCount + 1
    DisplayElements:Paragraph({Title = Colors[ColorCount],Color = Colors[ColorCount]})
end

--#ManagementTab
ManagementTab:Button({
    Title = "Button",
    Desc = "This is a button",
    Callback = function()
        print("Click")
    end
})
ManagementTab:Button({
    Title = "Test Text Icon <bird> bebebe",
    Desc = "This is a button <bird> bebebe",
    Callback = Utility:Debounce(function()
        print("bebebe")
    end, 10)
})
ManagementTab:Toggle({
    Title = "Toggle <toggle-left>",
    Desc = "This is a toggle",
    Callback = function(Value)
        print(Value)
    end
})
ManagementTab:Slider({
    Title = "Slider <settings-2>",
    Desc = "This is a slider",
    Value = {
        Min = 0,
        Max = 100,
        Default = 25,
    },
    Step = 1,
    Callback = function(Value)
        print(Value)
    end
})

ManagementTab:Dropdown({
	Title = "Dropdown <layout-template>",
    Desc = "This is a dropdown",
	Multi = false,
	Option = {"Option 1", "Option 2", "Option 3", "Option 4", "Option 5", "Option 6", "Option 7", "Option 8", "Option 9", "Option 10", "Option 11", "Option 12",
			"Option 13", "Option 14", "Option 15", "Option 16", "Option 17", "Option 18", "Option 19", "Option 20", "Option 21", "Option 22", "Option 23", "Option 24",
			"Option 25", "Option 26", "Option 27", "Option 28", "Option 29", "Option 30", "Pisun"},
	Value = "Option 1",
	Callback = function(Value)
		print(Value)
	end
})

ManagementTab:Dropdown({
	Title = "Multi Dropdown <layout-template>",
    Desc = "This is a multi dropdown",
	Multi = true,
	Option = {"Option 1", "Option 2", "Option 3", "Option 4", "Option 5", "Option 6", "Option 7", "Option 8", "Option 9", "Option 10", "Option 11", "Option 12",
			"Option 13", "Option 14", "Option 15", "Option 16", "Option 17", "Option 18", "Option 19", "Option 20", "Option 21", "Option 22", "Option 23", "Option 24",
			"Option 25", "Option 26", "Option 27", "Option 28", "Option 29", "Option 30", "Pisun"},
	Value = "Option 1",
	Callback = function(Value)
		print(unpack(Value))
	end
})

--#InputTab
local Input = InputTab:Input({
    Title = "Input <text-cursor-input>",
    Desc = "This is an input",
    Callback = function(input)
        print(input)
    end
})

local Input = InputTab:Input({
    Title = "Input Limit",
    MaxSymbols = 10,
    Desc = "This is an input",
    Callback = function(input)
        print(input)
    end
})

local Keybind = InputTab:Keybind({
    Title = "Keybind",
    Callback = function(key)
        print(key)
    end
})

NotificationTab:Button({
    Title = "Notification Icon",
    Callback = function()
        VexUI:Notification({
            Title = "Title",
            Icon = "bird",
            Desc = "Pisun",
            Duration = 5
        })
    end
})
NotificationTab:Button({
    Title = "Notification",
    Callback = function()
        VexUI:Notification({
            Title = "Title",
            Desc = "Pisun",
            Duration = 5
        })
    end
})

local LockBtn = LockedTab:Button({
    Title = "Button",
    Locked = true,
    Callback = function()
        print("Pisun")
    end
})

local LockTog = LockedTab:Toggle({
    Title = "Toggle",
    Locked = true,
    Callback = function(Value)
        print(Value)
    end
})

local LockSlider = LockedTab:Slider({
    Title = "Slider",
    Locked = true,
    Value = {
        Min = 0,
        Max = 100,
        Default = 25,
    },
    Step = 1,
    Callback = function(Value)
        print(Value)
    end
})

local LockDrop = LockedTab:Dropdown({
	Title = "Dropdown",
    Locked = true,
	Multi = false,
	Option = {"Option 1", "Option 2", "Option 3", "Option 4", "Option 5", "Option 6", "Option 7", "Option 8", "Option 9", "Option 10", "Option 11", "Option 12",
			"Option 13", "Option 14", "Option 15", "Option 16", "Option 17", "Option 18", "Option 19", "Option 20", "Option 21", "Option 22", "Option 23", "Option 24",
			"Option 25", "Option 26", "Option 27", "Option 28", "Option 29", "Option 30", "Pisun"},
	Value = "Option 1",
	Callback = function(Value)
		print(Value)
	end
})

local LockInp = LockedTab:Input({
    Title = "Input",
    Locked = true,
    Callback = function(input)
        print(input)
    end
})

local LockKey = LockedTab:Keybind({
    Title = "Keybind",
    Locked = true,
    Callback = function(key)
        print(key)
    end
})

LockedTab:Toggle({
    Title = "Lock / UnLock",
    Default = true,
    Callback = function(Value)
        if Value then
            LockBtn:Lock()
            LockTog:Lock()
            LockSlider:Lock()
            LockDrop:Lock()
            LockInp:Lock()
            LockKey:Lock()
        else
            LockBtn:UnLock()
            LockTog:UnLock()
            LockSlider:UnLock()
            LockDrop:UnLock()
            LockInp:UnLock()
            LockKey:UnLock()
        end
    end
})

GroupTab:Section({Title = "Group"})
local grid = GroupTab:Group({})
grid:Toggle({ Title = "One Element", Callback = function(v) print(v) end })
local grid = GroupTab:Group({})
grid:Toggle({ Title = "Aimbot", Callback = function(v) print(v) end })
grid:Toggle({ Title = "Triggerbot", Callback = function(v) print(v) end })
local grid = GroupTab:Group({})
grid:Toggle({ Title = "Test", Callback = function(v) print(v) end })
grid:Toggle({ Title = "Test", Callback = function(v) print(v) end })
grid:Toggle({ Title = "Test", Callback = function(v) print(v) end })

GroupTab:Section({Title = "Locked"})
local grid = GroupTab:Group({})
grid:Toggle({ Title = "Toggle", Locked = true,Callback = function(v) print(v) end })
grid:Toggle({ Title = "Toggle", Locked = true,Callback = function(v) print(v) end })
local grid = GroupTab:Group({})
grid:Toggle({ Title = "Toggle", Locked = true,Callback = function(v) print(v) end })
grid:Toggle({ Title = "Toggle", Locked = false,Callback = function(v) print(v) end })


Settings:Section({Title = "Window"})
Settings:Dropdown({
	Title = "Theme",
	Option = {"Dark","Light","Forest","Amethyst"},
	Value = "Dark",
	Callback = function(Value)
		Window:SetTheme(Value)
        VexUI:Notification({
            Title = "Selected Theme: " .. Value,
            Icon = "bird",
            Duration = 2
        })
	end
})
Settings:Toggle({
    Title = "Transparent",
    Callback = function(Value)
        Window:SetTransparency(Value)
    end
})
Settings:Keybind({
    Title = "Toggle Key Window",
    Callback = function(key)
        Window:SetToggleKey(Enum.KeyCode[key])
    end
})
Settings:Section({Title = "User"})
Settings:Toggle({
    Title = "Enabled",
    Callback = function(Value)
        Window:UserEnabled(Value)
    end
})
Settings:Toggle({
    Title = "Anonymous",
    Callback = function(Value)
        Window:Anonymous(Value)
    end
})

Settings:Section({Title = "Other"})
Settings:Button({
    Title = "Destroy UI",
    Callback = function()
        Window:Destroy()
    end
})--]]
