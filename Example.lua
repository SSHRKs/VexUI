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

local Section = Window:Section({ Title = "Other", Icon = "hash" })
local Settings = Section:Tab({ Title = "Settings", Icon = "settings",Border = true})

--DisplayElements
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
--#ManagementTab
ManagementTab:Button({
    Title = "Button",
    Desc = "This is a button",
    Callback = function()
    end
})
ManagementTab:Button({
    Title = "Test Text Icon <bird> bebebe",
    Desc = "This is a button <bird> bebebe",
    Callback = function()
        print("Button Clicked")
    end
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
    Title = "Notification",
    Callback = function()
        VexUI:Notification({
	        Title = "Title",
	        Icon = "bird",
	        Desc = "Pisun",
	        Duration = 5
        })
    end
})

Settings:Section({Title = "Window"})
Settings:Dropdown({
	Title = "Theme",
	Option = {"Dark","Light", "Forest"},
	Value = "Dark",
	Callback = function(Value)
		Window:SetTheme(Value)
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
    end
})
