local Utility = {}
local TweenService = game:GetService("TweenService")

function Utility:TweenObject(obj, properties, duration, ...)
    TweenService:Create(obj, TweenInfo.new(duration, ...), properties):Play() 
end

local activeNotifs = 0
local UI, VexUI = {
    Theme = nil,
    Themes = {},
    Notifications = 0,
    DefaultProps = {},
    IslandOpen = true,
}, {
    Objects = {},
}

VexUI.DefaultProps = {
    TextButton = {
        AutoButtonColor = false,
        TextTransparency = 1,
        BorderSizePixel = 0,
        Font = Enum.Font.GothamSemibold,
        TextSize = 12,
        ZIndex = 1,
    },
    TextLabel = {
        BorderSizePixel = 0,
        FontFace = Font.new([[rbxassetid://12187365364]], Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
        TextSize = 12,
        ZIndex = 1,
    },
    ImageLabel = {
        BorderSizePixel = 0,
        ZIndex = 1,
    },
    Frame = {
        BorderSizePixel = 0,
        ZIndex = 1,
    },
    ScrollingFrame = {
        BorderSizePixel = 0,
        ScrollBarThickness = 4,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ZIndex = 1,
    },
}

VexUI.Themes = {
    Dark = {
        Name = "Dark",
        Background = Color3.fromRGB(15, 15, 15),
        SideBar = Color3.fromRGB(25, 25, 25),
        Text = Color3.fromRGB(255, 255, 255),
        ElementColor = Color3.fromRGB(38, 38, 38),
        Outline = Color3.fromRGB(57, 57, 57),
        Placeholder = Color3.fromRGB(15, 15, 15),
        IconColor = Color3.fromRGB(255, 255, 255),
    },
    Light = {
        Name = "Light",
        Background = Color3.fromRGB(245, 245, 245),
        SideBar = Color3.fromRGB(235, 235, 235),
        Text = Color3.fromRGB(20, 20, 20),
        ElementColor = Color3.fromRGB(200, 200, 200),
        Outline = Color3.fromRGB(220, 220, 220),
        Placeholder = Color3.fromRGB(180, 180, 180),
        IconColor = Color3.fromRGB(20, 20, 20),
    },
    Forest = {
        Name = "Forest",
        Background = Color3.fromRGB(20, 24, 22),
        SideBar = Color3.fromRGB(28, 32, 30),
        Text = Color3.fromRGB(225, 235, 225),
        ElementColor = Color3.fromRGB(50, 60, 55),
        Outline = Color3.fromRGB(80, 95, 85),
        Placeholder = Color3.fromRGB(28, 32, 30),
        IconColor = Color3.fromRGB(225, 235, 225),
    },
}

UI.Theme = VexUI.Themes["Dark"]

function VexUI:Create(class, properties, children)
    local inst = Instance.new(class)

    local defaults = VexUI.DefaultProps[class]
    if defaults then
        for prop, val in next, defaults do
            if properties[prop] == nil then
                properties[prop] = val
            end
        end
    end

    for property, Value in next, properties or {} do
        if property ~= "ThemeID" then
            inst[property] = Value
        end
    end

    for _, Child in next, children or {} do
        Child.Parent = inst
    end

    if properties.ThemeID then
        VexUI:AddThemeObject(inst, properties.ThemeID)
    end
    return inst
end


function VexUI:GetThemeProperty(property, theme, fallbackProperty)
    local function resolve(t, key)
        for _, part in ipairs(string.split(key, ".")) do
            if type(t) ~= "table" then return nil end
            t = t[part]
        end
        return t
    end

    return resolve(theme, property) 
        or resolve(VexUI.Themes["Dark"], property)
        or (fallbackProperty and (resolve(theme, fallbackProperty) or resolve(VexUI.Themes["Dark"], fallbackProperty)))
end

function VexUI:AddThemeObject(object, properties)
    VexUI.Objects[object] = { Object = object, Properties = properties }
    VexUI:UpdateTheme(object, false)
    return object
end

function VexUI:UpdateTheme(targetObject, isTween)
    local function ApplyTheme(objData)
        for property, colorKey in pairs(objData.Properties or {}) do
            local color = nil
            for _, key in ipairs(string.split(colorKey, "|")) do
                key = key:gsub("%s+", "")
                color = VexUI:GetThemeProperty(key, UI.Theme)
                if color then break end
            end

            if color then
                if not isTween then
                    objData.Object[property] = color
                else
                    Utility:TweenObject(objData.Object, { [property] = color }, 0)
                end
            end
        end
    end

    if targetObject then
        local objData = VexUI.Objects[targetObject]
        if objData then ApplyTheme(objData) end
    else
        for _, objData in pairs(VexUI.Objects) do
            ApplyTheme(objData)
        end
    end
end

function VexUI:SetTheme(themeName)
    local theme = VexUI.Themes[themeName]
    if not theme then
        warn("Theme '" .. tostring(themeName) .. "' not found.")
        return
    end

    UI.Theme = theme
    VexUI:UpdateTheme(nil, true)
end

function VexUI:AddTheme(i)
    VexUI.Themes[i.Name] = i
    return i
end

local IconsV2 = loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/Footagesus/Icons/main/Main-v2.lua"))()
IconsV2.SetIconsType("lucide")

local function enableDragging(frame)
    local dragging = false
    local dragInput, mousePos, framePos

    local function update(input)
        local delta = input.Position - mousePos
        frame.Position = UDim2.new(framePos.X.Scale, framePos.X.Offset + delta.X, framePos.Y.Scale, framePos.Y.Offset + delta.Y)
    end

    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            mousePos = input.Position
            framePos = frame.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)

            local userInputService = game:GetService("UserInputService")
            dragInput = userInputService.InputChanged:Connect(function(inputChanged)
                if dragging and (inputChanged.UserInputType == Enum.UserInputType.MouseMovement or inputChanged.UserInputType == Enum.UserInputType.Touch) then
                    update(inputChanged)
                end
            end)
        end
    end)

    frame.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
            if dragInput then
                dragInput:Disconnect()
                dragInput = nil
            end
        end
    end)
end

function CreateRichIconText(parent, text, textProps, children)
    text = (text or ""):gsub("\n", "\\n")

    local container = VexUI:Create("Frame", {
        BackgroundTransparency = textProps.BackgroundTransparency or 1,
        AutomaticSize = textProps.AutomaticSize or "XY",
        Size = textProps.Size or UDim2.new(0, 0, 0, 0),
        LayoutOrder = textProps.LayoutOrder,
        Position = textProps.Position,
        ZIndex = textProps.ZIndex,
        Visible = textProps.Visible ~= nil and textProps.Visible or true,
        Parent = textProps.Parent or parent,
    }, {
        VexUI:Create("UIListLayout", {
            FillDirection = Enum.FillDirection.Vertical,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 2),
        })
    })

    if children then
        for _, child in ipairs(children) do
            child.Parent = container
        end
    end

    local function Render(newText)
        newText = (newText or ""):gsub("\n", "\\n")

        for _, child in ipairs(container:GetChildren()) do
            if not child:IsA("UIListLayout") and not child:IsA("UIPadding") then
                child:Destroy()
            end
        end

        local layoutOrder = 0
        for _, line in ipairs(string.split(newText, "\\n")) do
            local row = VexUI:Create("Frame", {
                BackgroundTransparency = 1,
                AutomaticSize = "XY",
                ClipsDescendants = true,
                Size = UDim2.new(0, 0, 0, 0),
                LayoutOrder = layoutOrder,
                Parent = container,
            }, {
                VexUI:Create("UIListLayout", {
                    FillDirection = Enum.FillDirection.Horizontal,
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    Padding = UDim.new(0, 0),
                    VerticalAlignment = Enum.VerticalAlignment.Center,
                })
            })
            layoutOrder += 1

            local tokens = {}
            local remaining = line

            while #remaining > 0 do
                local iconStart, iconEnd, iconName = string.find(remaining, "<([%w_%-]+)>")
                if iconStart then
                    if iconStart > 1 then
                        local textBefore = string.sub(remaining, 1, iconStart - 1)
                        if #string.gsub(textBefore, "%s", "") > 0 then
                            table.insert(tokens, { type = "text", value = textBefore })
                        end
                    end
                    table.insert(tokens, { type = "icon", value = iconName })
                    remaining = string.sub(remaining, iconEnd + 1)
                else
                    if #string.gsub(remaining, "%s", "") > 0 then
                        table.insert(tokens, { type = "text", value = remaining })
                    end
                    break
                end
            end

            local tokenOrder = 0
            for _, token in ipairs(tokens) do
                tokenOrder += 1

                if token.type == "text" then
                    VexUI:Create("TextLabel", {
                        BackgroundTransparency = 1,
                        AutomaticSize = "XY",
                        Size = UDim2.new(0, 0, 0, 0),
                        LayoutOrder = tokenOrder,
                        Text = token.value,
                        RichText = textProps.RichText or false,
                        TextSize = textProps.TextSize or 13,
                        FontFace = textProps.FontFace or Font.new("rbxasset://fonts/families/GothamSSm.json"),
                        TextColor3 = textProps.TextColor3 or Color3.fromRGB(255, 255, 255),
                        TextTransparency = textProps.TextTransparency or 0,
                        TextWrapped = textProps.TextWrapped or false,
                        TextXAlignment = textProps.TextXAlignment or Enum.TextXAlignment.Left,
                        TextYAlignment = Enum.TextYAlignment.Center,
                        ZIndex = textProps.ZIndex,
                        Parent = row,
                        ThemeID = textProps.ThemeID or nil,
                    })

                elseif token.type == "icon" then
                    if not IconsV2.GetIcon(token.value) then
                        warn("IconsV2: Icon Not Found — " .. token.value)
                    end

                    if textProps.ThemeID and textProps.ThemeID.TextColor3 then
                        imageThemeID = { ImageColor3 = textProps.ThemeID.TextColor3 }
                    end
                    local imageLabel = VexUI:Create("ImageLabel", {
                        BackgroundTransparency = 1,
                        Size = UDim2.new(0, textProps.TextSize or 13, 0, textProps.TextSize or 13),
                        LayoutOrder = tokenOrder,
                        ScaleType = Enum.ScaleType.Fit,
                        ImageColor3 = textProps.TextColor3 or Color3.fromRGB(255, 255, 255),
                        ImageTransparency = textProps.TextTransparency or 0,
                        ZIndex = textProps.ZIndex,
                        Image = "",
                        ThemeID = imageThemeID,
                        Parent = row,
                    })

                    if IconsV2.GetIcon(token.value) then
                        if typeof(IconsV2.GetIcon(token.value)) == "table" then
                            imageLabel.Image = IconsV2.GetIcon(token.value).Image or ""
                            if IconsV2.GetIcon(token.value).ImageRectOffset then
                                imageLabel.ImageRectOffset = IconsV2.GetIcon(token.value).ImageRectOffset
                            end
                            if IconsV2.GetIcon(token.value).ImageRectSize then
                                imageLabel.ImageRectSize = IconsV2.GetIcon(token.value).ImageRectSize
                            end
                        elseif typeof(IconsV2.GetIcon(token.value)) == "string" then
                            imageLabel.Image = IconsV2.GetIcon(token.value)
                        end
                    end
                end
            end
        end
    end
    Render(text)
    return {
        Frame = container,
        SetText = Render,
        UIPadding = container:FindFirstChildOfClass("UIPadding"),
    }
end

    local UIScreen = VexUI:Create("ScreenGui", {
        Parent = game:GetService("CoreGui"),
        --ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        ResetOnSpawn = false
    })

    local Island = VexUI:Create("Frame", {
        Parent = UIScreen,
        BorderSizePixel = 0,
        Size = UDim2.new(0, 30, 0, 36), 
        AnchorPoint = Vector2.new(0.5, 0.1),
        Position = UDim2.new(0.5, 0, -0.2, 0),
        ZIndex = 100,
        ThemeID = {
            BackgroundColor3 = "Background"
        }
    },{
        VexUI:Create("UICorner", { CornerRadius = UDim.new(0, 16) }),
        VexUI:Create("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalAlignment = "Left",
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 3),
        }),
        VexUI:Create("UIPadding", {
            PaddingTop = UDim.new(0, 3),
            PaddingLeft = UDim.new(0, 2),
            PaddingRight = UDim.new(0, 2),
        })
    })

    Island.UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        Utility:TweenObject(Island, {Size = UDim2.new(0, Island.UIListLayout.AbsoluteContentSize.X + 5, 0, 36)}, 0, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    end)
    task.defer(function()
        Utility:TweenObject(Island, {Size = UDim2.new(0, Island.UIListLayout.AbsoluteContentSize.X + 5, 0, 35)}, 0, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    end)
function UI:CreateWindow(Config)
    local Window = {
        Name = Config.Name or "VexUI",
        Author = Config.Author or nil,
        Icon = Config.Icon or nil,
        ToggleKey = Config.ToggleKey or Enum.KeyCode.F,
        Transparent = Config.Transparent or false,
        Theme = Config.Theme or "Dark",
        Folder = Config.Folder,
        KeySystem = Config.KeySystem or {},
        Default = Config.Default or "Default", --Default, Minimize
        Topbar = {
            Height = Config.Height or 35,
        },
        Themes = VexUI.Themes,
        Size = Config.Size and UDim2.new(
            0, math.clamp(Config.Size.X.Offset, 420, 580),
            0, math.clamp(Config.Size.Y.Offset, 280, 450)
        ) or UDim2.new(0, 480, 0, 360),
        SideBarWidth = Config.SideBarWidth or 145,
        BackpackHotbar = Config.BackpackHotbar or game:GetService("CoreGui"):WaitForChild("RobloxGui"):WaitForChild("Backpack"):WaitForChild("Hotbar"),
        User = Config.User or {},
        Tabs = {},
        AllElements = {},
        CurrentTab = {},
        TabOrder = {},
        SearchIndex = {},
    }
    Window.IslandOpen = true

    function Window:SetTheme(themeName)
        Window.Theme = themeName
        local theme = VexUI.Themes[themeName]
        if not theme then
            warn("Theme '" .. tostring(themeName) .. "' not found.")
            return
        end
        
        UI.Theme = theme
        VexUI:UpdateTheme(nil, true)
    end

    Window:SetTheme(Window.Theme)

    --UIMinimized
    local Main
    local MinzUI = VexUI:Create("TextButton", {
        Parent = Island,
        LayoutOrder = 1,
        Size = UDim2.new(0, 0, 0, 30), --X 80
        ClipsDescendants = true,
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.new(0, 0, 0.5, 0),
        ZIndex = 150,
        Visible = false,
        Text = "",
        AutoButtonColor = false,
        ThemeID = {
            BackgroundColor3 = "SideBar"
        }
    },{
        VexUI:Create("UIPadding", {
            PaddingLeft = UDim.new(0, 5),
            --PaddingTop = UDim.new(0, 5),
            PaddingRight = UDim.new(0, 5),
        }),
        VexUI:Create("UIStroke", {Parent = ButtonModule,
            Parent = MinimizedFrame,
            Color = Color3.fromRGB(255, 255, 255),
            LineJoinMode = "Round",
            Thickness = 1,
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        },{
            VexUI:Create("UIGradient", {
                Rotation = 45,
                Transparency = NumberSequence.new(0),
            })
        }),
        VexUI:Create("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalAlignment = "Left",
            VerticalAlignment = Enum.VerticalAlignment.Center,
        }),
        VexUI:Create("UICorner", { CornerRadius = UDim.new(0, 16) }),
        VexUI:Create("TextLabel", {
            BackgroundTransparency = 1,
            AnchorPoint = Vector2.new(0, 0.5),
            Position = UDim2.new(0, 0, 0.5, 0),
            Size = UDim2.new(0, 0, 1, 0),
            ClipsDescendants = true,
            AutomaticSize = "X",
            FontFace = Font.new([[rbxassetid://12187365364]], Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
            Text = Window.Name,
            TextSize = 12,
            ZIndex = 151,
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextXAlignment = Enum.TextXAlignment.Left,
            ThemeID = {
                TextColor3 = "Text"
            }
        },{
            VexUI:Create("UIListLayout", {
                FillDirection = Enum.FillDirection.Horizontal,
                HorizontalAlignment = "Left",
                VerticalAlignment = Enum.VerticalAlignment.Center,
            }),
            VexUI:Create("UIPadding", {
                PaddingLeft = UDim.new(0, 5),
            })
        }),
    })

    local UIIcon
    if Window.Icon then
        UIIcon = VexUI:Create("ImageLabel", {
            AnchorPoint = Vector2.new(0, 0.5),
            --Image = IconsV2.GetIcon(Window.Icon),
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 5, 0.5, 0),
            Size = UDim2.new(0, 20, 0, 20),
            ZIndex = 150,
            Parent = MinzUI,
        })
        if Window.Icon and IconsV2.Icon(Window.Icon) then
            UIIcon.Image = IconsV2.GetIcon(Window.Icon)
        elseif Window.Icon and string.find(Window.Icon, "rbxassetid://") then
            UIIcon.Image = Window.Icon
        end
    end

    function Window:EditOpenButton(Config)
        local Edit = {
            Title = Config.Title or Window.Name,
            Icon = Config.Icon or Window.Icon,
            Color = Config.Color or nil,
            --SizeX = Config.SizeX or 120,
            Transparency = Config.Transparency or 0.2,
            Rotation = Config.Rotation or 45,
            AutoRotation = Config.AutoRotation or false,
            Speed = Config.Speed or 15,
            StrokeThickness = Config.StrokeThickness or 1,
            CornerRadius = Config.CornerRadius or UDim.new(0,16),
        }
        --MinimizedFrame.Visible = true
        MinzUI.TextLabel.Text = Edit.Title
        MinzUI.UICorner.CornerRadius = Edit.CornerRadius

        if Window.Icon and IconsV2.Icon(Edit.Icon) then
            UIIcon.Image = IconsV2.GetIcon(Edit.Icon)
        elseif Edit.Icon and string.find(Edit.Icon, "rbxassetid://") then
            UIIcon.Image = Edit.Icon
        end

        if Edit.Color then
            MinzUI.UIStroke.UIGradient.Color = Edit.Color
        end
        MinzUI.BackgroundTransparency = Edit.Transparency
        MinzUI.UIStroke.UIGradient.Rotation = Edit.Rotation
        MinzUI.UIStroke.Thickness = Edit.StrokeThickness
        if Edit.AutoRotation then
            coroutine.wrap(function()
                while Edit.AutoRotation do MinzUI.UIStroke.UIGradient.Rotation = (MinzUI.UIStroke.UIGradient.Rotation + Edit.Speed * task.wait()) % 360 end
            end)()
        end
        return Window, Edit
    end

    if Window.KeySystem then
        local KeyFrame = VexUI:Create("Frame", {
            Parent = UIScreen,
            Size = UDim2.new(0, 220, 0, 85),
            ClipsDescendants = true,
            Active = true,
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.new(0.5, 0, 0.5, 0),
            BackgroundColor3 = Color3.fromRGB(25, 25, 25),
            ThemeID = {
                BackgroundColor3 = "Background"
            }
        }, {
            VexUI:Create("UICorner", {
                CornerRadius = UDim.new(0, 16),
            }),
            VexUI:Create("Frame", {
                Size = UDim2.new(0, 94, 0, 26),
                ClipsDescendants = true,
                Active = true,
                AnchorPoint = Vector2.new(0.04, 0.5),
                Position = UDim2.new(0.04, 0, 0.5, 0),
                BackgroundColor3 = Color3.fromRGB(25, 25, 25),
                ThemeID = {
                    BackgroundColor3 = "SideBar"
                },
            }, {
                VexUI:Create("UICorner", {
                    CornerRadius = UDim.new(0, 16),
                }),
                VexUI:Create("TextBox", {
                    BackgroundTransparency = 1,
                    ClipsDescendants = true,
                    ClearTextOnFocus = true,
                    Size = UDim2.new(1, 0, 1, 0),
                    FontFace = Font.new([[rbxassetid://12187365364]], Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
                    Text = "Key . . .",
                    TextTransparency = 0.5,
                    TextSize = 10,
                    ZIndex = 101,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ThemeID = {
                        TextColor3 = "Text",
                    }
                }, {
                    VexUI:Create("UIPadding", {
                        PaddingLeft = UDim.new(0, 5),
                    })
                }),
                VexUI:Create("UIStroke", {
                    Color = Color3.fromRGB(255, 255, 255),
                    LineJoinMode = "Round",
                    Thickness = 0.6,
                    ThemeID = {
                        Color = "Outline"
                    }
                },{
                    VexUI:Create("UIGradient", {
                        Color = ColorSequence.new(
                            Color3.fromRGB(255, 255, 255), 
                            Color3.fromRGB(255, 255, 255)
                        ),
                        Transparency = NumberSequence.new({
                            NumberSequenceKeypoint.new(0, 0.1),
                            NumberSequenceKeypoint.new(0.5, 1),
                            NumberSequenceKeypoint.new(1, 1)
                        }),
                        Rotation = -110
                    })
                }),
            })
        })
        if not isfolder("VexUI/" .. (Window.Folder or "Temp")) then makefolder("VexUI/" .. (Window.Folder or "Temp")) end
        if isfile("VexUI/" .. (Window.Folder or "Temp") .. "/key.json") then
            KeyFrame.Frame.TextBox.Text = game:GetService("HttpService"):JSONDecode(readfile("VexUI/" .. (Window.Folder or "Temp") .. "/key.json")).key or ""
        end

        if Window.KeySystem.Title then
            local KTitle = CreateRichIconText(KeyFrame, Window.KeySystem.Title, {
                AnchorPoint = Vector2.new(0.035, 0.05),
                Position = UDim2.new(0.035, 0, 0.05, 0),
                Size = UDim2.new(0, 100, 0, 0),
                AutomaticSize = "Y",
                ZIndex = 100,
                FontFace = Font.new([[rbxassetid://12187365364]], Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
                TextSize = 11,
                TextColor3 = Color3.fromRGB(255, 255, 255),
                RichText = true,
                TextWrapped = true,
                TextXAlignment = Enum.TextXAlignment.Left,
                ThemeID = {
                    TextColor3 = "Text"
                }
            })
        end
        local Kframe1 = VexUI:Create("Frame", {
            Size = UDim2.new(0, 118, 0, 85),
            ClipsDescendants = true,
            Active = true,
            AnchorPoint = Vector2.new(1, 0),
            Position = UDim2.new(1, 0, 0, 0),
            Parent =    KeyFrame,
            ThemeID = {
                BackgroundColor3 = "SideBar"
            }
        }, {
            VexUI:Create("UICorner", {
                CornerRadius = UDim.new(0, 16),
            }),
            VexUI:Create("Frame", {
                Size = UDim2.new(0, 0, 0, 25), --x 55
                AnchorPoint = Vector2.new(0.95, 0.03),
                --BackgroundTransparency = 1,
                ClipsDescendants = true,
                Active = true,
                LayoutOrder = 3,
                AutomaticSize = "X",
                Position = UDim2.new(0.95, 0, 0.03, 0),
                ZIndex = 100,
                ThemeID = {
                    BackgroundColor3 = "Background"
                }
            },{
                VexUI:Create("UIListLayout", {
                    FillDirection = Enum.FillDirection.Horizontal,
                    HorizontalAlignment = "Right",
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    Padding = UDim.new(0, 3),
                }),
                VexUI:Create("UIPadding", {
                    PaddingLeft = UDim.new(0, 5),
                    PaddingRight = UDim.new(0, 5),
                    PaddingTop = UDim.new(0, 3),
                }),
                VexUI:Create("UICorner", {
                    CornerRadius = UDim.new(0, 16),
                }),
                VexUI:Create("ImageButton", {
                    Name = "Cross",
                    AnchorPoint = Vector2.new(0, 0.5),
                    Image = IconsV2.GetIcon("x"),
                    BackgroundTransparency = 1,
                    LayoutOrder = 2,
                    Position = UDim2.new(0, 12, 0.5, 0),
                    BorderColor3 = Color3.new(0, 0, 0),
                    Size = UDim2.new(0, 20, 0, 20),
                    ZIndex = 101,
                    ThemeID = {
                        ImageColor3 = "IconColor"
                    }
                }),
                --[[VexUI:Create("ImageButton", {
                    AnchorPoint = Vector2.new(0, 0.5),
                    Image = IconsV2.GetIcon("minus"),
                    BackgroundTransparency = 1,
                    LayoutOrder = 1,
                    Position = UDim2.new(0, 12, 0.5, 0),
                    BorderColor3 = Color3.new(0, 0, 0),
                    Size = UDim2.new(0, 20, 0, 20),
                    ZIndex = 101,
                    ThemeID = {
                        ImageColor3 = "IconColor"
                    }
                }),--]]
                VexUI:Create("UIPadding", {
                    --PaddingLeft = UDim.new(0, 5),
                    --PaddingRight = UDim.new(0, 5),
                    PaddingTop = UDim.new(0, 4),
                }),
            }),
            VexUI:Create("Frame", {
                Size = UDim2.new(0, 16, 1, 0),
                Active = true,
                ZIndex = 100,
                ThemeID = {
                    BackgroundColor3 = "SideBar"
                }
            })
        })
        Kframe1.Frame.Cross.MouseButton1Click:connect(function()
            UIScreen:Destroy()
        end)
        if Window.KeySystem.Desc then
            local KDesc = CreateRichIconText(Kframe1, Window.KeySystem.Desc, {
                AnchorPoint = Vector2.new(0.03, 0.65),
                Position = UDim2.new(0.03, 0, 0.65, 0),
                Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = "Y",
                ZIndex = 100,
                TextTransparency = 0.3,
                FontFace = Font.new([[rbxassetid://12187365364]], Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
                TextSize = 9,
                TextColor3 = Color3.fromRGB(255, 255, 255),
                RichText = true,
                TextWrapped = true,
                TextXAlignment = Enum.TextXAlignment.Left,
                ThemeID = {
                    TextColor3 = "Text"
                }
            })
        end
        local Kframe2 = VexUI:Create("Frame", {
            Parent = Kframe1,
            Size = UDim2.new(1, 0, 0, 20),
            AnchorPoint = Vector2.new(0, 0.5),
            BackgroundTransparency = 1,
            Active = true,
            LayoutOrder = 3,
            AutomaticSize = "X",
            Position = UDim2.new(0, 0, 0.5, 0),
            BorderSizePixel = 0,
            ZIndex = 100,
            },{
                VexUI:Create("UIListLayout", {
                    FillDirection = Enum.FillDirection.Horizontal,
                    HorizontalAlignment = "Left",
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    Padding = UDim.new(0, 3),
                }),
                VexUI:Create("UIPadding", {
                    PaddingLeft = UDim.new(0, 5),
                }),
        })
        local Abutton = VexUI:Create("TextButton", {
            Parent = Kframe2,
            TextSize = 12,
            Size = UDim2.new(0, 57, 0, 20),
            Text = "Apply",
            FontFace = Font.new([[rbxassetid://12187365364]], Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
            TextTransparency = 0,
            AutoButtonColor = true,
            ZIndex = 101,
            ThemeID = {
                BackgroundColor3 = "ElementColor",
                TextColor3 = "Text",
            },
        },{
            VexUI:Create("UICorner", {
                CornerRadius = UDim.new(0, 16),
            }),
        })

        local thread = coroutine.running()
        Abutton.MouseButton1Click:Connect(function()
            local inputKey = KeyFrame.Frame.TextBox.Text:gsub("%s+", "")
            if inputKey == "" then return end
            Abutton.Text = "..."
            local valid = false
            if Window.KeySystem.KeyValidator then
                local ok, result = pcall(Window.KeySystem.KeyValidator, inputKey)
                valid = ok and result == true
            end
            if valid then
                writefile("VexUI/" .. (Window.Folder or "Temp") .. "/key.json",
                    game:GetService("HttpService"):JSONEncode({ key = inputKey })
                )
                Abutton.Text = "Success"
                task.wait(0.5)
                KeyFrame:Destroy()
                coroutine.resume(thread)
            else
                Abutton.Text = "Invalid"
                task.wait(1)
                Abutton.Text = "Apply"
            end
        end)
        local Gbutton = VexUI:Create("TextButton", {
            Parent = Kframe2,
            TextSize = 12,
            Size = UDim2.new(0, 48, 0, 20),
            Text = "Get",
            FontFace = Font.new([[rbxassetid://12187365364]], Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
            TextTransparency = 0,
            AutoButtonColor = true,
            ZIndex = 101,
            ThemeID = {
                BackgroundColor3 = "Background",
                TextColor3 = "Text",
            },
        },{
            VexUI:Create("UICorner", {
                CornerRadius = UDim.new(0, 16),
            }),
        })

        Gbutton.MouseButton1Click:Connect(function()
            setclipboard(Window.KeySystem.URL)
            Gbutton.Text = "Copied!"
            task.wait(1)
            Gbutton.Text = "Get"
        end)
        coroutine.yield()
    end

    local Main = VexUI:Create("Frame", {
        Name = Window.Name,
        Size = UDim2.new(0, Window.Size.X.Offset, 0, Window.Size.Y.Offset),
        ClipsDescendants = true,
        Active = true,
        BorderColor3 = Color3.new(0, 0, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        BackgroundTransparency = (Window.Transparent and 0.1 or 0),
        BorderSizePixel = 0,
        BackgroundColor3 = Color3.fromRGB(25, 25, 25),
        Parent = UIScreen,
        ThemeID = {
            BackgroundColor3 = "Background"
        }
    }, {
        VexUI:Create("UICorner", {
            CornerRadius = UDim.new(0, 16),
        }),
        VexUI:Create("Frame", {
            Size = UDim2.new(0, Window.Size.X.Offset, 0, Window.Size.Y.Offset-8),--Window.Topbar.Height),
            --ClipsDescendants = true,
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            Active = true,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 0, 0, 8),
            BorderSizePixel = 0,
            ZIndex = 2,
        }, {
            VexUI:Create("UIPadding", {
                PaddingLeft = UDim.new(0, 5),
            }),
            VexUI:Create("UIListLayout", {
                FillDirection = Enum.FillDirection.Horizontal,
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 5),
            }),
        }),
    })
    enableDragging(Main)

    local TopBarF1 = VexUI:Create("Frame", {
        Parent = Main.Frame,
        Size = UDim2.new(0, Window.Size.X.Offset - 182 + 133 + 5, 0, Window.Topbar.Height), --Window.Size.X.Offset - 10 + 133 + 5
        --ClipsDescendants = true,
        BackgroundColor3 = Color3.fromRGB(33, 33, 33),
        Active = true,
        BackgroundTransparency = 0.1,
        LayoutOrder = 1,
        Position = UDim2.new(0, 0, 0, 8),
        BorderSizePixel = 0,
        ZIndex = 3,
        ThemeID = {
            BackgroundColor3 = "SideBar"
        }
    }, {
        VexUI:Create("UICorner", {
            CornerRadius = UDim.new(0, 16),
        }),
        VexUI:Create("UIStroke", {
            Color = Color3.fromRGB(255, 255, 255),
            LineJoinMode = "Round",
            Thickness = 0.6,
            ThemeID = {
                Color = "Outline"
            }
        },{
            VexUI:Create("UIGradient", {
                Color = ColorSequence.new(
                    Color3.fromRGB(255, 255, 255), 
                    Color3.fromRGB(255, 255, 255)
                ),
                Transparency = NumberSequence.new({
                    NumberSequenceKeypoint.new(0, 0.1),
                    NumberSequenceKeypoint.new(0.5, 1),
                    NumberSequenceKeypoint.new(1, 1)
                }),
                Rotation = -110
            })
        }),
        VexUI:Create("Frame", {
            Size = UDim2.new(1, 0, 1, 0),
            --ClipsDescendants = true,
            BackgroundColor3 = Color3.fromRGB(33, 33, 33),
            Active = true,
            BackgroundTransparency = 1,
            LayoutOrder = 1,
            Position = UDim2.new(0, 0, 0, 0),
            BorderSizePixel = 0,
            ZIndex = 3,
        }, {
            VexUI:Create("UIPadding", {
                --PaddingLeft = UDim.new(0, 5),
                PaddingRight = UDim.new(0, 0),
                PaddingTop = UDim.new(0, 0),
            }),
        }),
    })
    TopBarF1.Size = UDim2.new(0,Window.Size.X.Offset - 5 - 5 - 5- 187,0,Window.Topbar.Height)

    local LibName = VexUI:Create("TextLabel", {
        Parent = TopBarF1.Frame,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        RichText = true,
        Size = UDim2.new(1, 0, 0, 35),
        FontFace = Font.new([[rbxassetid://12187365364]], Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
        Text = Window.Name,
        AutomaticSize = "Y",
        TextSize = 13,
        ZIndex = 5,
        TextWrapped = true,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Window.Author and Enum.TextYAlignment.Top or Enum.TextYAlignment.Center,
        ThemeID = {
            TextColor3 = "Text"
        }
    }, {
        VexUI:Create("UIPadding", {
            PaddingLeft = UDim.new(0, Window.Icon and 45 or 12),
            PaddingTop = Window.Author and UDim.new(0, 6) or UDim.new(0, 0),
        })
    })

    local LibAuthor = VexUI:Create("TextLabel", {
        Parent = TopBarF1.Frame,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        RichText = true,
        Size = UDim2.new(1, 0, 0, 35),
        FontFace = Font.new([[rbxassetid://12187365364]], Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
        Text = Window.Author or "",
        AutomaticSize = "Y",
        TextTransparency = 0.5,
        TextSize = 13,
        ZIndex = 5,
        TextWrapped = true,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextXAlignment = Enum.TextXAlignment.Left,
        Visible = Window.Author,
        ThemeID = {
            TextColor3 = "Text"
        }
    }, {
        VexUI:Create("UIPadding", {
            PaddingLeft = UDim.new(0, Window.Icon and 45 or 12),
            PaddingTop = UDim.new(0, 13),
        })
    })

    if Window.Icon then
        local UIIcon = VexUI:Create("ImageLabel", {
            AnchorPoint = Vector2.new(0, 0.5),
            --Image = IconsV2.GetIcon(Window.Icon),
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 12, 0.5, 0),
            BorderColor3 = Color3.new(0, 0, 0),
            Size = UDim2.new(0, 25, 0, 25),
            BorderSizePixel = 0,
            ZIndex = 5,
            Parent = TopBarF1,
            ThemeID = { ImageColor3 = "IconColor"}
        })
        if Window.Icon and IconsV2.Icon(Window.Icon) then
            UIIcon.Image = IconsV2.GetIcon(Window.Icon)
        elseif Window.Icon and string.find(Window.Icon, "rbxassetid://") then
            UIIcon.Image = Window.Icon
        end
    end

    local TopBarF2 = VexUI:Create("Frame", {
        Parent = Main.Frame,
        Size = UDim2.new(0, 133, 0, Window.Topbar.Height),
        ClipsDescendants = true,
        BackgroundColor3 = Color3.fromRGB(33, 33, 33),
        Active = true,
        Visible = false,
        LayoutOrder = 2,
        BackgroundTransparency = 0.1,
        Position = UDim2.new(0, 0, 0, 8),
        BorderSizePixel = 0,
        ZIndex = 3,
        ThemeID = {
            BackgroundColor3 = "SideBar"
        }
    }, {
        VexUI:Create("UICorner", {
            CornerRadius = UDim.new(0, 16),
        }),
        VexUI:Create("UIStroke", {
            Color = Color3.fromRGB(255, 255, 255),
            LineJoinMode = "Round",
            Thickness = 0.6,
            ThemeID = {
                Color = "Outline"
            }
        },{
            VexUI:Create("UIGradient", {
                Color = ColorSequence.new(
                    Color3.fromRGB(255, 255, 255), 
                    Color3.fromRGB(255, 255, 255)
                ),
                Transparency = NumberSequence.new({
                    NumberSequenceKeypoint.new(0, 0.1),
                    NumberSequenceKeypoint.new(0.5, 1),
                    NumberSequenceKeypoint.new(1, 1)
                }),
                Rotation = -110
            })
        }),
        VexUI:Create("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalAlignment = "Right",
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 5),
        }),
        VexUI:Create("UIPadding", {
            --PaddingLeft = UDim.new(0, 5),
            PaddingRight = UDim.new(0, 5),
            PaddingTop = UDim.new(0, 4),
        }),
    })

    local TopBarF3 = VexUI:Create("Frame", {
        Parent = Main.Frame,
        Size = UDim2.new(0, 187, 0, Window.Topbar.Height),
        --ClipsDescendants = true,
        BackgroundColor3 = Color3.fromRGB(33, 33, 33),
        Active = true,
        LayoutOrder = 3,
        BackgroundTransparency = 0.1,
        Position = UDim2.new(0, 0, 0, 8),
        BorderSizePixel = 0,
        ZIndex = 3,
        ThemeID = {
            BackgroundColor3 = "SideBar"
        }
    }, {
        VexUI:Create("UICorner", {
            CornerRadius = UDim.new(0, 16),
        }),
        VexUI:Create("UIStroke", {
            Color = Color3.fromRGB(255, 255, 255),
            LineJoinMode = "Round",
            Thickness = 0.6,
            ThemeID = {
                Color = "Outline"
            }
        },{
            VexUI:Create("UIGradient", {
                Color = ColorSequence.new(
                    Color3.fromRGB(255, 255, 255), 
                    Color3.fromRGB(255, 255, 255)
                ),
                Transparency = NumberSequence.new({
                    NumberSequenceKeypoint.new(0, 0.1),
                    NumberSequenceKeypoint.new(0.5, 1),
                    NumberSequenceKeypoint.new(1, 1)
                }),
                Rotation = -110
            })
        }),
    })

    function UI:Dialog(Config)
        local Dialog = {
            Title = Config.Title or "Dialog",
            Desc = Config.Desc or nil,
            Buttons = Config.Buttons or {},
        }

        local Overlay = VexUI:Create("Frame", {
            Parent = Main,
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundColor3 = Color3.fromRGB(0, 0, 0),
            BackgroundTransparency = 0.5,
            BorderSizePixel = 0,
            ZIndex = 149,
        })

        local DialogFrame = VexUI:Create("Frame", {
            Parent = Main,
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.new(0.5, 0, 0.5, 0),
            Size = UDim2.new(0, 190, 0, 0),
            AutomaticSize = "Y",
            BackgroundColor3 = Color3.fromRGB(33, 33, 33),
            BorderSizePixel = 0,
            ZIndex = 150,
            ThemeID = {
                BackgroundColor3 = "Background"
            }
        }, {
            VexUI:Create("UICorner", {
                CornerRadius = UDim.new(0, 12),
            }),
            VexUI:Create("UIListLayout", {
                FillDirection = Enum.FillDirection.Vertical,
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 6),
            }),
            VexUI:Create("UIPadding", {
                PaddingTop = UDim.new(0, 10),
                PaddingBottom = UDim.new(0, 10),
                PaddingLeft = UDim.new(0, 10),
                PaddingRight = UDim.new(0, 10),
            }),
        })

        -- Title
        VexUI:Create("TextLabel", {
            Parent = DialogFrame,
            LayoutOrder = 1,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            RichText = true,
            Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = "Y",
            FontFace = Font.new([[rbxassetid://12187365364]], Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
            Text = Dialog.Title,
            TextSize = 14,
            ZIndex = 152,
            TextWrapped = true,
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextXAlignment = Enum.TextXAlignment.Left,
            ThemeID = {
                TextColor3 = "Text"
            }
        })

        -- Desc
        if Dialog.Desc then
            VexUI:Create("TextLabel", {
                Parent = DialogFrame,
                LayoutOrder = 2,
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                RichText = true,
                Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = "Y",
                FontFace = Font.new([[rbxassetid://12187365364]], Enum.FontWeight.Regular, Enum.FontStyle.Normal),
                Text = Dialog.Desc,
                TextSize = 12,
                TextTransparency = 0.5,
                ZIndex = 152,
                TextWrapped = true,
                TextColor3 = Color3.fromRGB(255, 255, 255),
                TextXAlignment = Enum.TextXAlignment.Left,
                ThemeID = {
                    TextColor3 = "Text"
                }
            })
        end
        return Dialog
    end
    local TopBarBC = 0
    function UI:CreateTopbarButton(Config)
        TopBarF2.Visible = true
        TopBarBC += 1

        if TopBarBC > 4 then
            TopBarBC = 4
        end
        TopBarF2.Size = UDim2.new(0, (37 * TopBarBC) + (-5 * (TopBarBC - 1)), 0, 35)
        TopBarF1.Size = UDim2.new(0,Window.Size.X.Offset - 5 - 5 - 5 - 5 -TopBarF2.Size.X.Offset - 187,0,35)
        --TopBarF2.Size = UDim2.new(0, (37 * TopBarBC) + (-5 * (TopBarBC - 1)), 0, 35)
        --Window.Size.X.Offset - 173 + 133 + 5
        --TopBarF1.Size = UDim2.new(0, Window.Size.X.Offset - 208 - TopBarF2.Size.X.Offset, 0, 35)
        --TopBarF1.Size = UDim2.new(0, 270 - TopBarF2.Size.X.Offset, 0, 35)

        local TopBarButton = {
            Icon = Config.Icon or "bird",
            Callback = Config.Callback or function() end,
            Order = Config.Order or 1,
        }
        local TopButton = VexUI:Create("Frame", {
            Parent = TopBarF2,
            Size = UDim2.new(0, 27, 0, 27),
            BackgroundTransparency = 0.6,
            ClipsDescendants = true,
            BackgroundColor3 = Color3.fromRGB(44, 44, 44),
            Active = true,
            LayoutOrder = TopBarButton.Order,
            Position = UDim2.new(0, 0, 0, 8),
            BorderSizePixel = 0,
            ZIndex = 3,
            ThemeID = {
                BackgroundColor3 = "Background"
            }
        }, {
            VexUI:Create("UICorner", {
                CornerRadius = UDim.new(0, 8),
            }),
            VexUI:Create("UIStroke", {
                Color = Color3.fromRGB(255, 255, 255),
                LineJoinMode = "Round",
                Thickness = 0.6,
                ThemeID = {
                    Color = "Outline"
                }
            },{
                VexUI:Create("UIGradient", {
                    Color = ColorSequence.new(
                        Color3.fromRGB(255, 255, 255), 
                        Color3.fromRGB(255, 255, 255)
                    ),
                    Transparency = NumberSequence.new({
                        NumberSequenceKeypoint.new(0, 0.1),
                        NumberSequenceKeypoint.new(0.5, 1),
                        NumberSequenceKeypoint.new(1, 1)
                    }),
                    Rotation = -110
                })
            }),
        })
        local Icon = VexUI:Create("ImageButton", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            Image = IconsV2.GetIcon(TopBarButton.Icon),
            BackgroundTransparency = 1,
            Position = UDim2.new(0.5, 0, 0.5, 0),
            BorderColor3 = Color3.new(0, 0, 0),
            Size = UDim2.new(0, 16, 0, 16),
            BorderSizePixel = 0,
            ZIndex = 5,
            Parent = TopButton,
            ThemeID = {
                ImageColor3 = "IconColor"
            }
        })

        Icon.MouseButton1Click:Connect(function()
            spawn(function() pcall(TopBarButton.Callback) end)
            Utility:TweenObject(TopButton, {Transparency = 0}, 0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
            task.wait(0.1)
            Utility:TweenObject(TopButton, {Transparency = 0.6}, 0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
        end)
    end
    function UI:CreateTopbarToggle(Config)
        TopBarF2.Visible = true
        TopBarBC += 1
        if TopBarBC > 4 then
            TopBarBC = 4
        end
        TopBarF2.Size = UDim2.new(0, (37 * TopBarBC) + (-5 * (TopBarBC - 1)), 0, 35)
        TopBarF1.Size = UDim2.new(0,Window.Size.X.Offset - 5 - 5 - 5 - 5 -TopBarF2.Size.X.Offset - 187,0,35)

        local TopBarToggle = {
            Icon = Config.Icon or "bird",
            Callback = Config.Callback or function() end,
            Order = Config.Order or 1,
            Default = Config.Default or false,
            EnableIcon = Config.EnableIcon or Config.Icon,
            DisableIcon = Config.DisableIcon or Config.Icon,
            EnableBackground = Config.EnableBackground or nil,
            DisableBackground = Config.DisableBackground or nil,
        }
        local TopToggle = VexUI:Create("Frame", {
            Parent = TopBarF2,
            Size = UDim2.new(0, 27, 0, 27),
            BackgroundTransparency = 0.6,
            ClipsDescendants = true,
            BackgroundColor3 = Color3.fromRGB(44, 44, 44),
            Active = true,
            LayoutOrder = TopBarToggle.Order,
            Position = UDim2.new(0, 0, 0, 8),
            BorderSizePixel = 0,
            ZIndex = 3,
            ThemeID = {
                BackgroundColor3 = "Background"
            }
        }, {
            VexUI:Create("UICorner", {
                CornerRadius = UDim.new(0, 8),
            }),
            VexUI:Create("UIStroke", {
                Color = Color3.fromRGB(255, 255, 255),
                LineJoinMode = "Round",
                Thickness = 0.6,
                ThemeID = {
                    Color = "Outline"
                }
            },{
                VexUI:Create("UIGradient", {
                    Color = ColorSequence.new(
                        Color3.fromRGB(255, 255, 255), 
                        Color3.fromRGB(255, 255, 255)
                    ),
                    Transparency = NumberSequence.new({
                        NumberSequenceKeypoint.new(0, 0.1),
                        NumberSequenceKeypoint.new(0.5, 1),
                        NumberSequenceKeypoint.new(1, 1)
                    }),
                    Rotation = -110
                })
            }),
        })
        local Icon = VexUI:Create("ImageButton", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            Image = IconsV2.GetIcon(TopBarToggle.Icon),
            BackgroundTransparency = 1,
            Position = UDim2.new(0.5, 0, 0.5, 0),
            BorderColor3 = Color3.new(0, 0, 0),
            Size = UDim2.new(0, 16, 0, 16),
            BorderSizePixel = 0,
            ZIndex = 5,
            Parent = TopToggle,
            ThemeID = {
                ImageColor3 = "IconColor"
            }
        })

		local function updateToggleState()
    		Utility:TweenObject(TopToggle, {BackgroundTransparency = TopBarToggle.Default and 0 or 0.6}, 0.2)
            Utility:TweenObject(TopToggle, {BackgroundColor3 = (TopBarToggle.Default and TopBarToggle.EnableBackground and TopBarToggle.EnableBackground or Color3.fromRGB(44, 44, 44) or TopBarToggle.DisableBackground and TopBarToggle.DisableBackground or Color3.fromRGB(44, 44, 44))}, 0.2)
            Icon.Image = not TopBarToggle.Default and IconsV2.GetIcon(TopBarToggle.EnableIcon) or IconsV2.GetIcon(TopBarToggle.DisableIcon)
    		--Utility:TweenObject(ToggleScroll, {BackgroundColor3 = Toggle.Default and UI.Theme.ToggleModule.ScrollNew or UI.Theme.ToggleModule.Scroll}, 0.2)
    		task.spawn(function()
        		pcall(TopBarToggle.Callback, TopBarToggle.Default)
    		end)
		end

		updateToggleState()

		Icon.MouseButton1Click:Connect(function()
    		TopBarToggle.Default = not TopBarToggle.Default
    		updateToggleState()
		end)
		return TopBarToggle
    end

    local SearchF1 = VexUI:Create("Frame", {
        Parent = TopBarF3,
        AnchorPoint = Vector2.new(0, 0.5),
        Size = UDim2.new(0, 27, 0, 25),
        ClipsDescendants = true,
        BackgroundColor3 = Color3.fromRGB(25, 25, 25),
        Active = true,
        LayoutOrder = 3,
        Position = UDim2.new(0, 7, 0.5, 0),
        BorderSizePixel = 0,
        ZIndex = 3,
        ThemeID = {
            BackgroundColor3 = "Search.Background|Background"
        }
    }, {
        VexUI:Create("Frame", {
            Size = UDim2.new(0, 16, 0, 25),
            AnchorPoint = Vector2.new(1, 0.5),
            ClipsDescendants = true,
            BackgroundColor3 = Color3.fromRGB(25, 25, 25),
            Active = true,
            LayoutOrder = 3,
            Position = UDim2.new(1, 0, 0.5, 0),
            BorderSizePixel = 0,
            ZIndex = 3,
            ThemeID = {
                BackgroundColor3 = "Search.Background|Background"
            },
        }),
        VexUI:Create("ImageLabel", {
            AnchorPoint = Vector2.new(0, 0.5),
            Image = IconsV2.GetIcon("search"),
            BackgroundTransparency = 1,
            LayoutOrder = 1,
            Position = UDim2.new(0, 6, 0.5, 0),
            BorderColor3 = Color3.new(0, 0, 0),
            Size = UDim2.new(0, 15, 0, 15),
            BorderSizePixel = 0,
            ZIndex = 5,
            Parent = TopBarF1,
            ThemeID = {
                ImageColor3 = "IconColor"
            }
        }),
        VexUI:Create("UICorner", {
            CornerRadius = UDim.new(0, 16),
        }),
        VexUI:Create("UIStroke", {
            Color = Color3.fromRGB(255, 255, 255),
            LineJoinMode = "Round",
            Thickness = 0.6,
            ThemeID = {
                Color = "Outline"
            }
        },{
            VexUI:Create("UIGradient", {
                Color = ColorSequence.new(
                    Color3.fromRGB(255, 255, 255), 
                    Color3.fromRGB(255, 255, 255)
                ),
                Transparency = NumberSequence.new({
                    NumberSequenceKeypoint.new(0, 0.1),
                    NumberSequenceKeypoint.new(0.5, 1),
                    NumberSequenceKeypoint.new(1, 1)
                }),
                Rotation = -110
            })
        }),
    })

    local SearchF2 = VexUI:Create("Frame", {
        Parent = TopBarF3,
        AnchorPoint = Vector2.new(0, 0.5),
        Size = UDim2.new(0, 75, 0, 25),
        ClipsDescendants = true,
        BackgroundColor3 = Color3.fromRGB(25, 25, 25),
        Active = true,
        LayoutOrder = 3,
        Position = UDim2.new(0, 38, 0.5, 0),
        BorderSizePixel = 0,
        ZIndex = 3,
        ThemeID = {
            BackgroundColor3 = "Search.Background|Background"
        }
    }, {
        VexUI:Create("Frame", {
            Size = UDim2.new(0, 16, 0, 25),
            AnchorPoint = Vector2.new(0, 0.5),
            ClipsDescendants = true,
            BackgroundColor3 = Color3.fromRGB(25, 25, 25),
            Active = true,
            LayoutOrder = 3,
            Position = UDim2.new(0, 0, 0.5, 0),
            BorderSizePixel = 0,
            ZIndex = 3,
            ThemeID = {
                BackgroundColor3 = "Search.Background|Background"
            }
        }),
        VexUI:Create("UICorner", {
            CornerRadius = UDim.new(0, 16),
        }),
        VexUI:Create("UIStroke", {
            Color = Color3.fromRGB(255, 255, 255),
            LineJoinMode = "Round",
            Thickness = 0.6,
            ThemeID = {
                Color = "Outline"
            }
        },{
            VexUI:Create("UIGradient", {
                Color = ColorSequence.new(
                    Color3.fromRGB(255, 255, 255), 
                    Color3.fromRGB(255, 255, 255)
                ),
                Transparency = NumberSequence.new({
                    NumberSequenceKeypoint.new(0, 0.1),
                    NumberSequenceKeypoint.new(0.5, 1),
                    NumberSequenceKeypoint.new(1, 1)
                }),
                Rotation = -110
            })
        }),
    })

    local WinElements = VexUI:Create("Frame", {
        Parent = TopBarF3,
        Size = UDim2.new(0, 51, 0, 35),
        AnchorPoint = Vector2.new(0.95, 0.5),
        BackgroundTransparency = 1,
        ClipsDescendants = true,
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        Active = true,
        LayoutOrder = 3,
        Position = UDim2.new(0.95, 0, 0.5, 0),
        BorderSizePixel = 0,
        ZIndex = 100,
    },{
        VexUI:Create("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalAlignment = "Right",
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 3),
        }),
        VexUI:Create("ImageButton", {
            Name = "Cross",
            AnchorPoint = Vector2.new(0, 0.5),
            Image = IconsV2.GetIcon("x"),
            BackgroundTransparency = 1,
            LayoutOrder = 2,
            Position = UDim2.new(0, 12, 0.5, 0),
            BorderColor3 = Color3.new(0, 0, 0),
            Size = UDim2.new(0, 25, 0, 25),
            BorderSizePixel = 0,
            ZIndex = 101,
            Parent = TopBarF1,
            ThemeID = {
                ImageColor3 = "IconColor"
            }
        }),
        VexUI:Create("ImageButton", {
            AnchorPoint = Vector2.new(0, 0.5),
            Image = IconsV2.GetIcon("minus"),
            BackgroundTransparency = 1,
            LayoutOrder = 1,
            Position = UDim2.new(0, 12, 0.5, 0),
            BorderColor3 = Color3.new(0, 0, 0),
            Size = UDim2.new(0, 25, 0, 25),
            BorderSizePixel = 0,
            ZIndex = 101,
            Parent = TopBarF1,
            ThemeID = {
                ImageColor3 = "IconColor"
            }
        }),
        VexUI:Create("UIPadding", {
            --PaddingLeft = UDim.new(0, 5),
            --PaddingRight = UDim.new(0, 5),
            PaddingTop = UDim.new(0, 4),
        }),
    })

    local SearchBox = VexUI:Create("TextBox", {
        Parent = SearchF2,
        BackgroundColor3 = Color3.new(1, 1, 1),
        BackgroundTransparency = 1,
        BorderColor3 = Color3.new(0, 0, 0),
        BorderSizePixel = 0,
        ClipsDescendants = true,
        ClearTextOnFocus = true,
        Size = UDim2.new(1, 0, 1, 0),
        FontFace = Font.new([[rbxassetid://12187365364]], Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
        Text = "Search . . .",
        TextColor3 = Color3.new(1, 1, 1),
        TextSize = 11,
        ZIndex = 101,
        TextStrokeColor3 = Color3.new(1, 1, 1),
        TextXAlignment = Enum.TextXAlignment.Left,
        ThemeID = {
            TextColor3 = "Search.Text|Text",
            TextStrokeColor3 = "Search.Text|Text"
        }
    },{
        VexUI:Create("UIPadding", {
            PaddingLeft = UDim.new(0, 5),
            --PaddingRight = UDim.new(0, 0),
        })
    })

    local SearchFrame = VexUI:Create("Frame", {
            Parent = TopBarF3,
            Size = UDim2.new(1, 0, 0, 0),
            AnchorPoint = Vector2.new(0, 0),
            Position = UDim2.new(0, 0, 0, 25),
            BackgroundColor3 = Color3.fromRGB(25, 25, 25),
            Active = true,
            LayoutOrder = 3,
            BorderSizePixel = 0,
            ZIndex = 50,
            BackgroundTransparency = 1,
            ThemeID = {
                BackgroundColor3 = "Search.Background|Background"
            }
    },{
        VexUI:Create("UICorner", {
            CornerRadius = UDim.new(0, 16),
        }),
        VexUI:Create("UIStroke", {
            Color = Color3.fromRGB(255, 255, 255),
            LineJoinMode = "Round",
            Thickness = 0,
            ThemeID = {
                Color = "Outline"
            }
        },{
            VexUI:Create("UIGradient", {
                Color = ColorSequence.new(
                    Color3.fromRGB(255, 255, 255), 
                    Color3.fromRGB(255, 255, 255)
                ),
                Transparency = NumberSequence.new({
                    NumberSequenceKeypoint.new(0, 0.1),
                    NumberSequenceKeypoint.new(0.5, 1),
                    NumberSequenceKeypoint.new(1, 1)
                }),
                Rotation = -110
            })
        }),
    })
    local SearchScroll = VexUI:Create("ScrollingFrame", {
        Parent = SearchFrame,
        Active = true,
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 1.000,
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        BorderSizePixel = 0,
        AutomaticCanvasSize = "Y",
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(1, 0, 0.96, 0),
        ZIndex = 250,
        ScrollBarThickness = 0
    },{
        VexUI:Create("UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 5)
        }),
        VexUI:Create("UIPadding", {
            PaddingLeft = UDim.new(0, 5),
            PaddingTop = UDim.new(0, 10),
        })
    })

    function ClearSearchResults()
        for _, v in ipairs(SearchScroll:GetChildren()) do
            if not v:IsA("UIListLayout") and not v:IsA("UIPadding") then
                v:Destroy()
            end
        end
    end

    function CreateSearchRow(entry)
        local Row = VexUI:Create("TextButton", {
            Parent = SearchScroll,
            Size = UDim2.new(1, -10, 0, 32),
            BackgroundTransparency = 0.2,
            BackgroundColor3 = Color3.fromRGB(40,40,40),
            Active = true,
            Text = "",
            ZIndex = 251,
            ThemeID = {
                BackgroundColor3 = "Seach.Background|ElementColor"
            }
        }, {
            VexUI:Create("UICorner", { CornerRadius = UDim.new(0, 16) }),
            VexUI:Create("UIPadding", { PaddingTop = UDim.new(0, 10) }),
        })

        local Icon = VexUI:Create("ImageLabel", {
            Parent = Row,
            Size = UDim2.new(0, 16, 0, 16),
            Position = UDim2.new(0, 10, 0, -2),
            BackgroundTransparency = 1,
            ZIndex = 252,
            Image = IconsV2.GetIcon(entry.Icon or "circle"),
            ThemeID = {
                ImageColor3 = "Search.Icon|IconColor"
            }
        })

        CreateRichIconText(Row, entry.Title, {
            FontFace = Font.new([[rbxassetid://12187365364]], Enum.FontWeight.SemiBold),
            Size = UDim2.new(1, -20, 1, 0),
            Position = UDim2.new(0, 35, 0, 0),
            BackgroundTransparency = 1,
            ZIndex = 252,
            TextSize = 12,
            TextColor3 = Color3.fromRGB(255,255,255),
            TextXAlignment = Enum.TextXAlignment.Left,
            ThemeID = {
                TextColor3 = "Search.Text|Text"
            }
        })

        Row.MouseButton1Click:Connect(function()
            entry.SelectFn()
            SearchBox.Text = ""
            ClearSearchResults()
        end)
        SearchScroll.UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            SearchScroll.CanvasSize = UDim2.new(0, 0, 0, SearchScroll.UIListLayout.AbsoluteContentSize.Y)
        end)
    end


    local function RenderSearch(query)
        ClearSearchResults()

        local q = string.lower(query)

        for _, entry in ipairs(Window.SearchIndex) do
            local haystack = string.lower(entry.Title .. " " .. (entry.Desc or ""))

            if q ~= "" and string.find(haystack, q, 1, true) then
                CreateSearchRow(entry)
            end
        end
    end

    SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
        RenderSearch(SearchBox.Text)
    end)

    SearchBox.Focused:Connect(function()
        Utility:TweenObject(SearchFrame, {BackgroundTransparency = 0.2, Size = UDim2.new(1, 0, 0, 135), Position = UDim2.new(0, 0, 0, Window.Topbar.Height + 5)}, 0.2)
        Utility:TweenObject(SearchFrame.UIStroke, {Thickness = 0.6}, 0.1)
        --Utility:TweenObject(SearchFrame, {Size = UDim2.new(1, 0, 0, 200)}, 0.2)
        SearchBox.TextTransparency = 0
    end)

    SearchBox.FocusLost:Connect(function()
        task.wait(0.1)
        Utility:TweenObject(SearchFrame, {BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0), Position = UDim2.new(0, 0, 0, 0)}, 0.2)
        Utility:TweenObject(SearchFrame.UIStroke, {Thickness = 0}, 0.1)
        SearchBox.Text = "Search . . ."
        SearchBox.TextTransparency = 0.5
        ClearSearchResults()
    end)

    local TabFrame = VexUI:Create("Frame", {
        Name = Window.Name,
        Size = UDim2.new(0, Window.SideBarWidth, 0, Window.Size.Y.Offset - Window.Topbar.Height - 13),
        ClipsDescendants = true,
        Active = true,
        BorderColor3 = Color3.new(0, 0, 0),
        Position = UDim2.new(0, 0, 0, Window.Topbar.Height+13),
        BorderSizePixel = 0,
        ZIndex = 3,
        BackgroundTransparency = (Window.Transparent and 1 or 0),
        BackgroundColor3 = Color3.fromRGB(33, 33, 33),
        Parent = Main,
        ThemeID = {
            BackgroundColor3 = "SideBar"
        }
    },{
        VexUI:Create("Frame", {
            AnchorPoint = Vector2.new(0, 0),
            Position = UDim2.new(0, 0, 0, 0),
            BorderColor3 = Color3.new(0, 0, 0),
            BackgroundTransparency = (Window.Transparent and 1 or 0),
            Size = UDim2.new(0, 16, 0, 16),
            BackgroundColor3 = Color3.fromRGB(33, 33, 33),
            BorderSizePixel = 0,
            ZIndex = 4,
            ThemeID = {
                BackgroundColor3 = "SideBar"
            }
        }),
        VexUI:Create("Frame", {
            AnchorPoint = Vector2.new(1, 1),
            Position = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = (Window.Transparent and 1 or 0),
            BorderColor3 = Color3.new(0, 0, 0),
            Size = UDim2.new(0, 16, 0, 16),
            BackgroundColor3 = Color3.fromRGB(33, 33, 33),
            BorderSizePixel = 0,
            ZIndex = 4,
            ThemeID = {
                BackgroundColor3 = "SideBar"
            }
        }),
        VexUI:Create("UICorner", {
            CornerRadius = UDim.new(0, 16),
        }),
    })

    --USER
    local UserFrame = VexUI:Create("Frame", {
        Parent = TabFrame,
        AnchorPoint = Vector2.new(0.5, 0.96),
        Position = UDim2.new(0.5, 0, 0.96, 0),
        BorderColor3 = Color3.new(0, 0, 0),
        ClipsDescendants = true,
        Size = UDim2.new(0, Window.SideBarWidth - 20, 0, 40),
        BackgroundColor3 = Color3.fromRGB(33, 33, 33),
        BorderSizePixel = 0,
        ZIndex = 10,
        ThemeID = {
            BackgroundColor3 = "Background"
        }
    },{
        VexUI:Create("UICorner", {
            CornerRadius = UDim.new(0, 16),
        }),
        VexUI:Create("ImageLabel", {
            AnchorPoint = Vector2.new(0.075, 0.5),
            BackgroundTransparency = 0.7,
            Position = UDim2.new(0.075, 0, 0.5, 0),
            Size = UDim2.new(0, 25, 0, 25),
            BorderSizePixel = 0,
            ZIndex = 11,
            Image = (function()
                return game:GetService("Players"):GetUserThumbnailAsync(Window.User.Anonymous and 1 or game.Players.LocalPlayer.UserId,Enum.ThumbnailType.HeadShot,Enum.ThumbnailSize.Size150x150)
            end)(),
        },{
            VexUI:Create("UICorner", {
                CornerRadius = UDim.new(0, 64),
            }),
        }),
        VexUI:Create("TextButton", {
            Visible = Window.User.Callback and true or false,
            AnchorPoint = Vector2.new(0, 0),
            Position = UDim2.new(0, 0, 0, 0),
            BorderColor3 = Color3.new(0, 0, 0),
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            TextTransparency = 1,
            BorderSizePixel = 0,
            ZIndex = 100,
        }),
    })
    UserFrame.TextButton.MouseButton1Click:Connect(function()
        task.spawn(Window.User.Callback)
    end)
    local UserTitle = VexUI:Create("TextLabel", {
        Parent = UserFrame,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        RichText = true,
        Size = UDim2.new(1, 0, 1, 0),
        FontFace = Font.new([[rbxassetid://12187365364]], Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
        Text = Window.User.Anonymous and "Anonymous" or game.Players.LocalPlayer.DisplayName,
        TextTransparency = 0,
        TextSize = 13,
        ZIndex = 11,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextXAlignment = Enum.TextXAlignment.Left,
        Visible = Window.Author,
        ThemeID = {
            TextColor3 = "User.Text|Text"
        }
    }, {
        VexUI:Create("UIPadding", {
            PaddingLeft = UDim.new(0,40),
            PaddingBottom = UDim.new(0,15)
        })
    })
    local UserSub = VexUI:Create("TextLabel", {
        Parent = UserFrame,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        RichText = true,
        Size = UDim2.new(1, 0, 1, 0),
        FontFace = Font.new([[rbxassetid://12187365364]], Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
        Text = Window.User.Anonymous and "@Anonymous" or "@"..game.Players.LocalPlayer.Name,
        TextTransparency = 0.6,
        TextSize = 13,
        ZIndex = 11,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextXAlignment = Enum.TextXAlignment.Left,
        Visible = Window.Author,
        ThemeID = {
            TextColor3 = "User.Text|Text"
        }
    }, {
        VexUI:Create("UIPadding", {
            PaddingLeft = UDim.new(0,40),
            PaddingTop = UDim.new(0,15)
        })
    })

    UserFrame.Visible = Window.User.Enabled or false
    --endUser

    local LeftScroll = VexUI:Create("ScrollingFrame", {
        Parent = TabFrame,
        Active = true,
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 1,
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0., 0),
        Size = UDim2.new(1, 0, 1, 0),
        ScrollBarThickness = 0
    },{
        VexUI:Create("UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 5)
        }),
        VexUI:Create("UIPadding", {
            PaddingLeft = UDim.new(0, 5),
            PaddingTop = UDim.new(0, 10),
        })
    })

    local ElementFolder = VexUI:Create("Folder", {
        Parent = Main,
    })
    function Window:Tab(Config, type)
        local Tab = {
            Title = Config.Title or "Tab",
            Icon = Config.Icon or nil,
            Border = Config.Border or false,
            Callback = Config.Callback or function() end
        }

        local TabBack = VexUI:Create("Frame", {
            Parent = type or LeftScroll,
            AnchorPoint = Vector2.new(0, 0),
            Position = UDim2.new(0, 0, 0, 0),
            AutomaticSize = "Y",
            BorderColor3 = Color3.new(0, 0, 0),
            BackgroundTransparency = Tab.Border and 0.6 or 1,
            Size = UDim2.new(0, Window.SideBarWidth - 10, 0, 25),
            BackgroundColor3 = Color3.fromRGB(59, 59, 59),
            BorderSizePixel = 0,
            ZIndex = 4,
            ThemeID = {
                BackgroundColor3 = "Tab.Background|ElementColor"
            }
        },{
            VexUI:Create("TextButton", {
                AnchorPoint = Vector2.new(0, 0),
                Position = UDim2.new(0, 0, 0, 0),
                BorderColor3 = Color3.new(0, 0, 0),
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                TextTransparency = 1,
                BorderSizePixel = 0,
                ZIndex = 6,
            }),
            VexUI:Create("UICorner", {
                CornerRadius = UDim.new(0, 8),
            }),
            VexUI:Create("UIStroke", {
                Color = Color3.fromRGB(255, 255, 255),
                LineJoinMode = "Round",
                Thickness = 0.6,
                ThemeID = {
                    Color = "Outline"
                }
            },{
                VexUI:Create("UIGradient", {
                    Color = ColorSequence.new(
                        Color3.fromRGB(255, 255, 255), 
                        Color3.fromRGB(255, 255, 255)
                    ),
                    Transparency = NumberSequence.new({
                        NumberSequenceKeypoint.new(0, 0.1),
                        NumberSequenceKeypoint.new(0.5, 1),
                        NumberSequenceKeypoint.new(1, 1)
                    }),
                    Rotation = -110
                })
            }),
            VexUI:Create("UIPadding", {
                PaddingBottom = UDim.new(0, 5),
                PaddingTop = UDim.new(0, 5),
            })
        })
        local TabTitle = VexUI:Create("TextLabel", {
            Parent = TabBack,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            RichText = true,
            Size = UDim2.new(1, 0, 0, 25),
            FontFace = Font.new([[rbxassetid://12187365364]], Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
            Text = Tab.Title,
            AutomaticSize = "Y",
            TextTransparency = 0,
            TextSize = 13,
            ZIndex = 5,
            TextWrapped = true,
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextXAlignment = Enum.TextXAlignment.Left,
            Visible = Window.Author,
            ThemeID = {
                TextColor3 = "Tab.Text|Text"
            }
        }, {
            VexUI:Create("UIPadding", {
                PaddingLeft = UDim.new(0,10)
            })
        })
        local TabIcon
        if Tab.Icon then
            TabIcon = VexUI:Create("ImageLabel", {
                AnchorPoint = Vector2.new(.1, 0.5),
                --Image = IconsV2.GetIcon(Window.Icon),
                BackgroundTransparency = 1,
                Position = UDim2.new(.1, 0, 0.5, 0),
                BorderColor3 = Color3.new(0, 0, 0),
                Size = UDim2.new(0, 19, 0, 19),
                BorderSizePixel = 0,
                ZIndex = 5,
                Parent = TabBack,
                ThemeID = {
                    ImageColor3 = "Tab.IconColor|IconColor"
                }
            })
            TabTitle.UIPadding.PaddingLeft = UDim.new(0,38)
            if Tab.Icon and IconsV2.Icon(Tab.Icon) then
                TabIcon .Image = IconsV2.GetIcon(Tab.Icon)
            elseif Tab.Icon and string.find(Tab.Icon, "rbxassetid://") then
                TabIcon.Image = Tab.Icon
            end
        end
        TabBack.BackgroundTransparency = 1
        TabTitle.TextTransparency = 0.5
        TabBack.UIStroke.Transparency = 1
        if TabIcon then
            TabIcon.ImageTransparency = 0.5
        end
        
        local ElementFrame = VexUI:Create("Frame", {
            Parent = ElementFolder,
            AnchorPoint = Vector2.new(.93, 0),
            Position = UDim2.new(.93, 0, 0, Window.Topbar.Height+13),
            BorderColor3 = Color3.new(0, 0, 0),
            ClipsDescendants = true,
            BackgroundTransparency = 0.6,
            Size = UDim2.new(0, Window.Size.X.Offset-Window.SideBarWidth - 15, 0, 0),
            BackgroundColor3 = Color3.fromRGB(33, 33, 33),
            BorderSizePixel = 0,
            ZIndex = 4,
            ThemeID = {
                BackgroundColor3 = "SideBar"
            }
        },{
            VexUI:Create("UICorner", {
                CornerRadius = UDim.new(0, 16),
            }),
        })
        local RightScroll = VexUI:Create("ScrollingFrame", {
            Parent = ElementFrame,
            Active = true,
            BackgroundTransparency = 1,
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            BorderSizePixel = 0,
            CanvasSize = UDim2.new(0,0,0,0),
            Position = UDim2.new(0,0,0),
            Size = UDim2.new(1, 0, 0.95, 0),
            ScrollBarThickness = 3,
            ZIndex = 10,
            --AutomaticSize = Y
        },{
            VexUI:Create("UIListLayout", {
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 5)
            }),
            VexUI:Create("UIPadding", {
                PaddingTop = UDim.new(0,5),
                PaddingBottom = UDim.new(0,5),
                PaddingLeft = UDim.new(0,5)
            })
        })

        RightScroll.UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            RightScroll.CanvasSize = UDim2.new(0, RightScroll.UIListLayout.AbsoluteContentSize.X, 0, RightScroll.UIListLayout.AbsoluteContentSize.Y)
        end)
       local function SelectTab()
            for i, v in next, ElementFolder:GetChildren() do
                if v:IsA("GuiObject") then
                    v.Visible = false
                    v.Size = UDim2.new(0, Window.Size.X.Offset-Window.SideBarWidth - 15, 0, 0)
                end
            end
            ElementFrame.Visible = true
            RightScroll.Visible = true
            Utility:TweenObject(ElementFrame, {Size = UDim2.new(0, Window.Size.X.Offset-Window.SideBarWidth - 15, 0, Window.Size.Y.Offset - Window.Topbar.Height)}, 0.15)
            Utility:TweenObject(ElementFrame, {BackgroundTransparency = 0.2}, 0.2)
            for _, v in next, Window.Tabs do
                Utility:TweenObject(v, {BackgroundTransparency = 1}, 0.2)
                for _, obj in ipairs(v:GetChildren()) do
                    if obj:IsA("TextLabel") then
                        Utility:TweenObject(obj, {TextTransparency = 0.5}, 0.2)
                    elseif obj:IsA("UIStroke") then
                        Utility:TweenObject(obj, {Transparency = 1}, 0.2)
                    elseif obj:IsA("ImageLabel") then
                        Utility:TweenObject(obj, {ImageTransparency = 0.5}, 0.2)
                    end
                end
            end
            Utility:TweenObject(TabBack, {BackgroundTransparency = (Tab.Border and 0.6 or 1)}, 0.2)
            Utility:TweenObject(TabBack.UIStroke, {Transparency = (Tab.Border and 0 or 1)}, 0.2)
            Utility:TweenObject(TabTitle, {TextTransparency = 0}, 0.2)
            if TabIcon then
                Utility:TweenObject(TabIcon, {ImageTransparency = 0}, 0.2)
            end
            Tab.Callback()
        end

        TabBack.TextButton.MouseButton1Click:Connect(SelectTab)
        Tab.Select = SelectTab

        table.insert(Window.Tabs, TabBack)
        table.insert(Window.TabOrder, Tab.Title)
        --Window.SearchIndex[Tab.Title] = {}

        --print(Config.Parent)
        function Tab:Paragraph(Config,type)
            local Paragraph = {
                Title = Config.Title or "Paragraph",
                Desc = Config.Desc or nil,
                Icon = Config.Icon or nil,
                SizeY = 40
            }
            local ParagraphFrame = VexUI:Create("Frame", {
                Parent = RightScroll,
                AnchorPoint = Vector2.new(0, 0),
                Position = UDim2.new(0, 0, 0, 0),
                BorderColor3 = Color3.new(0, 0, 0),
                AutomaticSize = "Y",
                ClipsDescendants = true,
                BackgroundTransparency = 0.5,
                Size = UDim2.new(0, ElementFrame.Size.X.Offset - 10, 0, Paragraph.SizeY),
                BackgroundColor3 = Color3.fromRGB(43, 43, 43),
                BorderSizePixel = 0,
                ZIndex = 15,
                ThemeID = {
                    BackgroundColor3 = "Paragraph.Background|ElementColor"
                }
            },{
                VexUI:Create("UIStroke", {
                    Color = Color3.fromRGB(255, 255, 255),
                    LineJoinMode = "Round",
                    Thickness = 0.6,
                    ThemeID = {
                        Color = "Outline"
                    }
                },{
                    VexUI:Create("UIGradient", {
                        Color = ColorSequence.new(
                            Color3.fromRGB(255, 255, 255), 
                            Color3.fromRGB(255, 255, 255)
                        ),
                        Transparency = NumberSequence.new({
                            NumberSequenceKeypoint.new(0, 0.1),
                            NumberSequenceKeypoint.new(0.5, 1),
                            NumberSequenceKeypoint.new(1, 1)
                        }),
                        Rotation = -110
                    })
                }),
                VexUI:Create("UICorner", {
                    CornerRadius = UDim.new(0, 12),
                }),
                VexUI:Create("UIPadding", {
                    PaddingTop = UDim.new(0,5),
                    PaddingBottom = UDim.new(0,5)
                }),
                VexUI:Create("Frame", {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 1, 0),
                    ClipsDescendants = true,
                    ZIndex = 16,
                },{
                    VexUI:Create("UIListLayout", {
                        SortOrder = Enum.SortOrder.LayoutOrder,
                        Padding = UDim.new(0, 1)
                    }),
                    VexUI:Create("UIPadding", {
                        PaddingTop = UDim.new(0,9),
                    })
                })
            })

            local Title = CreateRichIconText(ParagraphFrame.Frame, Paragraph.Title, {
                Size = UDim2.new(1, 0, 0, 5),
                AutomaticSize = "Y",
                ZIndex = 16,
                FontFace = Font.new([[rbxassetid://12187365364]], Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
                TextSize = 13,
                TextColor3 = Color3.fromRGB(255, 255, 255),
                RichText = true,
                TextWrapped = true,
                TextXAlignment = Enum.TextXAlignment.Left,
                ThemeID = {
                    TextColor3 = "Paragraph.Text|Text"
                }
            }, {
                VexUI:Create("UIPadding", {
                    PaddingLeft = UDim.new(0, 10)
                })
            })
            Title.Position = UDim2.new(0, 0, 0, 0)
            local Desc = CreateRichIconText(ParagraphFrame.Frame, Paragraph.Desc, {
                Size = UDim2.new(1, 0, 0, 5),
                AutomaticSize = "Y",
                ZIndex = 16,
                FontFace = Font.new([[rbxassetid://12187365364]], Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
                TextSize = 12,
                TextTransparency = 0.7,
                TextColor3 = Color3.fromRGB(255, 255, 255),
                RichText = true,
                TextWrapped = true,
                TextXAlignment = Enum.TextXAlignment.Left,
                Visible = Paragraph.Desc ~= nil,
                ThemeID = {
                    TextColor3 = "Paragraph.Text|Text"
                }
            }, {
                VexUI:Create("UIPadding", {
                    PaddingLeft = UDim.new(0, 10)
                })
            })
            local Icon
            if Paragraph.Icon then
                Icon = VexUI:Create("ImageLabel", {
                    AnchorPoint = Vector2.new(.03, 0.5),
                    --Image = IconsV2.GetIcon(Window.Icon),
                    BackgroundTransparency = 1,
                    Position = UDim2.new(.03, 0, 0.5, 0),
                    BorderColor3 = Color3.new(0, 0, 0),
                    Size = UDim2.new(0, 22, 0, 22),
                    ZIndex = 17,
                    Parent = ParagraphFrame,
                    ImageTransparency = 0,
                    ThemeID = {
                        ImageColor3 = "Paragraph.IconColor|IconColor"
                    }
                })
                Title.UIPadding.PaddingLeft = UDim.new(0,38)
                Desc.UIPadding.PaddingLeft = UDim.new(0,38)
                if Paragraph.Icon and IconsV2.Icon(Paragraph.Icon) then
                    Icon.Image = IconsV2.GetIcon(Paragraph.Icon)
                elseif Paragraph.Icon and string.find(Paragraph.Icon, "rbxassetid://") then
                    Icon.Image = Paragraph.Icon
                end
            end

            function Paragraph:SetTitle(Text)
                Title.SetText(Text)
            end
            table.insert(Window.SearchIndex, {
                Title = Paragraph.Title, Desc = Paragraph.Desc, Icon = Paragraph.Icon,
                Type = "Paragraph", TabTitle = Tab.Title,
                SelectFn = SelectTab, Frame = ParagraphFrame, RightScroll = RightScroll,
            })
            return Paragraph
        end

        function Tab:Button(Config,type)
            local Button = {
                Title = Config.Title or "Button",
                Desc = Config.Desc,
                Icon = Config.Icon or "mouse-pointer-click",
                SizeY = Config.SizeY or 40,
                Callback = Config.Callback or function() end
            }
            local Beeee = VexUI:Create("Frame", {
                Parent = RightScroll,
                BackgroundTransparency = 1,
                AutomaticSize = "Y",
                Size = UDim2.new(0, ElementFrame.Size.X.Offset - 10, 0, Button.SizeY),
                ZIndex = 15,
            })
            local ButtonFrame = VexUI:Create("Frame", {
                Parent = Beeee,
                AnchorPoint = Vector2.new(0, 0),
                Position = UDim2.new(0, 0, 0, 0),
                BorderColor3 = Color3.new(0, 0, 0),
                AutomaticSize = "Y",
                ClipsDescendants = true,
                BackgroundTransparency = 0.5,
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundColor3 = Color3.fromRGB(43, 43, 43),
                BorderSizePixel = 0,
                ZIndex = 15,
                ThemeID = {
                    BackgroundColor3 = "Button.Background|ElementColor"
                }
            },{
                VexUI:Create("UIStroke", {
                    Color = Color3.fromRGB(255, 255, 255),
                    LineJoinMode = "Round",
                    Thickness = 0.6,
                    ThemeID = {
                        Color = "Outline"
                    }
                },{
                    VexUI:Create("UIGradient", {
                        Color = ColorSequence.new(
                            Color3.fromRGB(255, 255, 255), 
                            Color3.fromRGB(255, 255, 255)
                        ),
                        Transparency = NumberSequence.new({
                            NumberSequenceKeypoint.new(0, 0.1),
                            NumberSequenceKeypoint.new(0.5, 1),
                            NumberSequenceKeypoint.new(1, 1)
                        }),
                        Rotation = -110
                    })
                }),
                VexUI:Create("UICorner", {
                    CornerRadius = UDim.new(0, 12),
                }),
                VexUI:Create("UIPadding", {
                    PaddingTop = UDim.new(0,5),
                    PaddingBottom = UDim.new(0,5)
                }),

                VexUI:Create("Frame", {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 1, 0),
                    ClipsDescendants = true,
                    ZIndex = 16,
                },{
                    VexUI:Create("UIListLayout", {
                        SortOrder = Enum.SortOrder.LayoutOrder,
                        Padding = UDim.new(0, 1)
                    }),
                    VexUI:Create("UIPadding", {
                        PaddingTop = UDim.new(0,9),
                    })
                })
            })

            local ButtonTRG = VexUI:Create("TextButton", {
                Parent = Beeee,
                Size = UDim2.new(1, 0, 1, 0),
                TextTransparency = 1,
                BackgroundTransparency = 1,
                ZIndex = 25,
            })

            local Title = CreateRichIconText(ButtonFrame.Frame, Button.Title, {
                Size = UDim2.new(1, 0, 0, 5),
                AutomaticSize = "Y",
                ZIndex = 16,
                FontFace = Font.new([[rbxassetid://12187365364]], Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
                TextSize = 13,
                TextColor3 = Color3.fromRGB(255, 255, 255),
                RichText = true,
                TextWrapped = true,
                TextXAlignment = Enum.TextXAlignment.Left,
                ThemeID = {
                    TextColor3 = "Button.Text|Text"
                }
            }, {
                VexUI:Create("UIPadding", {
                    PaddingLeft = UDim.new(0, 10)
                })
            })
            Title.Position = UDim2.new(0, 0, 0, 0)
            local Desc = CreateRichIconText(ButtonFrame.Frame, Button.Desc, {
                Size = UDim2.new(1, 0, 0, 5),
                AutomaticSize = "Y",
                ZIndex = 16,
                FontFace = Font.new([[rbxassetid://12187365364]], Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
                TextSize = 12,
                TextTransparency = 0.7,
                TextColor3 = Color3.fromRGB(255, 255, 255),
                RichText = true,
                TextWrapped = true,
                TextXAlignment = Enum.TextXAlignment.Left,
                Visible = Button.Desc ~= nil,
                ThemeID = {
                    TextColor3 = "Button.Text|Text"
                }
            }, {
                VexUI:Create("UIPadding", {
                    PaddingLeft = UDim.new(0, 10)
                })
            })
            local Icon
            if Button.Icon then
                Icon = VexUI:Create("ImageLabel", {
                    AnchorPoint = Vector2.new(.96, 0.5),
                    --Image = IconsV2.GetIcon(Window.Icon),
                    BackgroundTransparency = 1,
                    Position = UDim2.new(.96, 0, 0.5, 0),
                    BorderColor3 = Color3.new(0, 0, 0),
                    Size = UDim2.new(0, 20, 0, 20),
                    BorderSizePixel = 0,
                    ZIndex = 16,
                    Parent = ButtonFrame,
                    ThemeID = {
                        ImageColor3 = "Button.IconColor|IconColor"
                    }
                })
                --Title.UIPadding.PaddingLeft = UDim.new(0,38)
                --Desc.UIPadding.PaddingLeft = UDim.new(0,38)
                if Button.Icon and IconsV2.Icon(Button.Icon) then
                    Icon.Image = IconsV2.GetIcon(Button.Icon)
                elseif Button.Icon and string.find(Button.Icon, "rbxassetid://") then
                    Icon.Image = Button.Icon
                end
            end

            function Button:SetTitle(Text)
                Title.SetText(Text)
            end

            function Button:SetDesc(Text)
                Desc.Visible = true
                Desc.SetText(Text)
            end

            function Button:Close()
                Button:Destroy()
            end

            if Button.Desc then
                Button:SetDesc(Button.Desc)
            end

            ButtonTRG.MouseEnter:Connect(function()
                Utility:TweenObject(ButtonFrame, {BackgroundTransparency = 0.6}, 0.1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
            end)
            ButtonTRG.MouseLeave:Connect(function()
                Utility:TweenObject(ButtonFrame, {BackgroundTransparency = 0.5}, 0.1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
            end)
            ButtonTRG.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.Touch then
                    Utility:TweenObject(ButtonFrame, {BackgroundTransparency = 0.6}, 0.1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
                end
            end)
            ButtonTRG.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.Touch then
                    Utility:TweenObject(ButtonFrame, {BackgroundTransparency = 0.5}, 0.1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
                end
            end)

            ButtonTRG.MouseButton1Click:Connect(function()
                spawn(function()
                    pcall(Button.Callback)
                end)
                Utility:TweenObject(ButtonFrame, {BackgroundTransparency = 0}, 0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
                wait(0.1)
                Utility:TweenObject(ButtonFrame, {BackgroundTransparency = 0.5}, 0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
            end)
            table.insert(Window.SearchIndex, {
                Title = Button.Title, Desc = Button.Desc, Icon = "mouse-pointer-click",
                Type = "Button", TabTitle = Tab.Title,
                SelectFn = SelectTab, Frame = Beeee, RightScroll = RightScroll,
            })
            return Button
        end
        function Tab:Toggle(Config,type)
            local Togglee = {
                Title = Config.Title or "Toggle",
                Desc = Config.Desc,
                Icon = Config.Icon or "mouse-pointer-click",
                SizeY = Config.SizeY or 40,
                Callback = Config.Callback or function() end
            }
            local Beeee = VexUI:Create("Frame", {
                Parent = RightScroll,
                BackgroundTransparency = 1,
                AutomaticSize = "Y",
                Size = UDim2.new(0, ElementFrame.Size.X.Offset - 10, 0, Togglee.SizeY),
                ZIndex = 15,
            })
            local ToggleFrame = VexUI:Create("Frame", {
                Parent = Beeee,
                AnchorPoint = Vector2.new(0, 0),
                Position = UDim2.new(0, 0, 0, 0),
                BorderColor3 = Color3.new(0, 0, 0),
                AutomaticSize = "Y",
                ClipsDescendants = true,
                BackgroundTransparency = 0.5,
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundColor3 = Color3.fromRGB(43, 43, 43),
                BorderSizePixel = 0,
                ZIndex = 15,
                ThemeID = {
                    BackgroundColor3 = "Toggle.Background|ElementColor"
                }
            },{
                VexUI:Create("UIStroke", {
                    Color = Color3.fromRGB(255, 255, 255),
                    LineJoinMode = "Round",
                    Thickness = 0.6,
                    ThemeID = {
                        Color = "Outline"
                    }
                },{
                    VexUI:Create("UIGradient", {
                        Color = ColorSequence.new(
                            Color3.fromRGB(255, 255, 255), 
                            Color3.fromRGB(255, 255, 255)
                        ),
                        Transparency = NumberSequence.new({
                            NumberSequenceKeypoint.new(0, 0.1),
                            NumberSequenceKeypoint.new(0.5, 1),
                            NumberSequenceKeypoint.new(1, 1)
                        }),
                        Rotation = -110
                    })
                }),
                VexUI:Create("UICorner", {
                    CornerRadius = UDim.new(0, 12),
                }),
                VexUI:Create("UIPadding", {
                    PaddingTop = UDim.new(0,5),
                    PaddingBottom = UDim.new(0,5)
                }),

                VexUI:Create("Frame", {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 1, 0),
                    ClipsDescendants = true,
                    ZIndex = 16,
                },{
                    VexUI:Create("UIListLayout", {
                        SortOrder = Enum.SortOrder.LayoutOrder,
                        Padding = UDim.new(0, 1)
                    }),
                    VexUI:Create("UIPadding", {
                        PaddingTop = UDim.new(0,9),
                    })
                })
            })

            local ToggleTRG = VexUI:Create("TextButton", {
                Parent = Beeee,
                Size = UDim2.new(1, 0, 1, 0),
                TextTransparency = 1,
                BackgroundTransparency = 1,
                ZIndex = 25,
            })

            local Title = CreateRichIconText(ToggleFrame.Frame, Togglee.Title, {
                Size = UDim2.new(1, 0, 0, 5),
                AutomaticSize = "Y",
                ZIndex = 16,
                FontFace = Font.new([[rbxassetid://12187365364]], Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
                TextSize = 13,
                TextColor3 = Color3.fromRGB(255, 255, 255),
                RichText = true,
                TextWrapped = true,
                TextXAlignment = Enum.TextXAlignment.Left,
                ThemeID = {
                    TextColor3 = "Toggle.Text|Text"
                }
            }, {
                VexUI:Create("UIPadding", {
                    PaddingLeft = UDim.new(0, 10)
                })
            })
            Title.Position = UDim2.new(0, 0, 0, 0)
            local Desc = CreateRichIconText(ToggleFrame.Frame, Togglee.Desc, {
                Size = UDim2.new(1, 0, 0, 5),
                AutomaticSize = "Y",
                ZIndex = 16,
                FontFace = Font.new([[rbxassetid://12187365364]], Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
                TextSize = 12,
                TextTransparency = 0.7,
                TextColor3 = Color3.fromRGB(255, 255, 255),
                RichText = true,
                TextWrapped = true,
                TextXAlignment = Enum.TextXAlignment.Left,
                Visible = Togglee.Desc ~= nil,
                ThemeID = {
                    TextColor3 = "Toggle.Text|Text"
                }
            }, {
                VexUI:Create("UIPadding", {
                    PaddingLeft = UDim.new(0, 10)
                })
            })
            local ToggleV = VexUI:Create("Frame", {
                Parent = ToggleFrame,
                AnchorPoint = Vector2.new(.96, 0.5),
                Position = UDim2.new(.96, 0, 0.5, 0),
                BorderColor3 = Color3.new(0, 0, 0),
                ClipsDescendants = true,
                BackgroundTransparency = 0.5,
                Size = UDim2.new(0, 38, 0, 24),
                BorderSizePixel = 0,
                ZIndex = 15,
                ThemeID = {
                    BackgroundColor3 = "Toggle.Placeholder|Placeholder"
                }
            },{
                VexUI:Create("Frame", {
                    AnchorPoint = Vector2.new(.96, 0.5),
                    Position = UDim2.new(0, 18, 0.5, 0),
                    BorderColor3 = Color3.new(0, 0, 0),
                    ClipsDescendants = true,
                    BackgroundTransparency = 0.8,
                    Size = UDim2.new(0, 15, 0, 15),
                    BorderSizePixel = 0,
                    ZIndex = 15,
                    ThemeID = {
                        BackgroundColor3 = "Toggle.ToggleVal|Text"
                    }
                },{
                    VexUI:Create("UICorner", {
                        CornerRadius = UDim.new(0, 32),
                    }),
                }),
                VexUI:Create("UICorner", {
                    CornerRadius = UDim.new(0, 12),
                }),
            })

            function Togglee:SetTitle(Text)
                Title.SetText(Text)
            end

            function Togglee:SetDesc(Text)
                Desc.Visible = true
                Desc.SetText(Text)
            end

            function Togglee:Close()
                Togglee:Destroy()
            end

            if Togglee.Desc then
                Togglee:SetDesc(Togglee.Desc)
            end

            local Val = Togglee.Default

            function Togglee:SetValue(newValue)
                Val = newValue
                if newValue then
                    Utility:TweenObject(ToggleV.Frame, {Position = UDim2.new(0, 33, 0.5, 0),BackgroundTransparency = 0}, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
                else
                    Utility:TweenObject(ToggleV.Frame, {Position = UDim2.new(0, 18,0.5, 0),BackgroundTransparency = 0.8}, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
                end
                    
                spawn(function()
                    pcall(Togglee.Callback, Val)
                end)
                return Togglee
            end

            Togglee:SetValue(Val)
            ToggleTRG.MouseButton1Down:Connect(function()
                Utility:TweenObject(ToggleV.Frame, {Size = UDim2.new(0, 15, 0, 8),BackgroundTransparency = (Val and 0 or 0.8)}, 0.15, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
            end)
            ToggleTRG.MouseButton1Up:Connect(function()
                Utility:TweenObject(ToggleV.Frame, {Size = UDim2.new(0, 15, 0, 15),BackgroundTransparency = (Val and 0 or 0.8)}, 0.15, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
            end)
            ToggleTRG.MouseLeave:Connect(function()
                Utility:TweenObject(ToggleV.Frame, {Size = UDim2.new(0, 15, 0, 15),BackgroundTransparency = (Val and 0 or 0.8)}, 0.15, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
            end)
            ToggleTRG.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.Touch then
                    Utility:TweenObject(ToggleV.Frame, {Size = UDim2.new(0, 15, 0, 15),BackgroundTransparency = (Val and 0 or 0.8)}, 0.15, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
                end
            end)
            ToggleTRG.MouseButton1Click:Connect(function()
                Val = not Val
                Togglee:SetValue(Val)
            end)
            table.insert(Window.SearchIndex, {
                Title = Togglee.Title, Desc = Togglee.Desc, Icon = "toggle-left",
                Type = "Toggle", TabTitle = Tab.Title,
                SelectFn = SelectTab, Frame = Beeee, RightScroll = RightScroll,
            })
            return Togglee
        end
        function Tab:Slider(Config)
            local Slider = {
                Title = Config.Title or "Slider",
                Desc = Config.Desc or nil,
                Locked = Config.Locked or false,
                Step = Config.Step or 1,
                Value = Config.Value or { Min = 0, Max = 100, Default = 50 },
                Callback = Config.Callback or function() end,
                SizeY = Config.SizeY or 40,
            }

            local Beeee = VexUI:Create("Frame", {
                Parent = RightScroll,
                BackgroundTransparency = 1,
                AutomaticSize = "Y",
                Size = UDim2.new(0, ElementFrame.Size.X.Offset - 10, 0, Slider.SizeY),
                ZIndex = 15,
            })

            local SliderElement = VexUI:Create("Frame", {
                Parent = Beeee,
                AnchorPoint = Vector2.new(0, 0),
                Position = UDim2.new(0, 0, 0, 0),
                AutomaticSize = "Y",
                ClipsDescendants = true,
                BackgroundTransparency = 0.5,
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundColor3 = Color3.fromRGB(43, 43, 43),
                BorderSizePixel = 0,
                ZIndex = 15,
                ThemeID = {
                    BackgroundColor3 = "Slider.Background|ElementColor"
                }
            }, {
                VexUI:Create("UIStroke", {
                    LineJoinMode = "Round",
                    Thickness = 0.6,
                    ThemeID = {
                        Color = "Outline"
                    }
                }, {
                    VexUI:Create("UIGradient", {
                        Color = ColorSequence.new(
                            Color3.fromRGB(255, 255, 255),
                            Color3.fromRGB(255, 255, 255)
                        ),
                        Transparency = NumberSequence.new({
                            NumberSequenceKeypoint.new(0, 0.1),
                            NumberSequenceKeypoint.new(0.5, 1),
                            NumberSequenceKeypoint.new(1, 1)
                        }),
                        Rotation = -110
                    })
                }),
                VexUI:Create("UICorner", {
                    CornerRadius = UDim.new(0, 12),
                }),
                VexUI:Create("UIPadding", {
                    PaddingTop = UDim.new(0, 5),
                    PaddingBottom = UDim.new(0, 5),
                }),
            })

            local TextContainer = VexUI:Create("Frame", {
                Parent = SliderElement,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 1, 0),
                ClipsDescendants = true,
                ZIndex = 16,
            }, {
                VexUI:Create("UIListLayout", {
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    Padding = UDim.new(0, 1),
                }),
                VexUI:Create("UIPadding", {
                    PaddingTop = UDim.new(0, 9),
                }),
            })

            local Title = CreateRichIconText(TextContainer, Slider.Title, {
                Size = UDim2.new(1, 0, 0, 5),
                AutomaticSize = "Y",
                ZIndex = 16,
                FontFace = Font.new([[rbxassetid://12187365364]], Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
                TextSize = 13,
                TextColor3 = Color3.fromRGB(255, 255, 255),
                RichText = true,
                TextWrapped = true,
                TextXAlignment = Enum.TextXAlignment.Left,
                ThemeID = {
                    TextColor3 = "Slider.Text|Text"
                }
            }, {
                VexUI:Create("UIPadding", {
                    PaddingLeft = UDim.new(0, 10)
                })
            })

            local Desc = CreateRichIconText(TextContainer, Slider.Desc, {
                Size = UDim2.new(1, 0, 0, 5),
                AutomaticSize = "Y",
                ZIndex = 16,
                FontFace = Font.new([[rbxassetid://12187365364]], Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
                TextSize = 12,
                TextTransparency = 0.7,
                TextColor3 = Color3.fromRGB(255, 255, 255),
                RichText = true,
                TextWrapped = true,
                TextXAlignment = Enum.TextXAlignment.Left,
                Visible = Slider.Desc ~= nil,
                ThemeID = {
                    TextColor3 = "Slider.Text|Text"
                }
            }, {
                VexUI:Create("UIPadding", {
                    PaddingLeft = UDim.new(0, 10)
                })
            })

            local ValueFrame = VexUI:Create("Frame", {
                Parent = SliderElement,
                AnchorPoint = Vector2.new(0.96, 0.5),
                Position = UDim2.new(0.96, -40, 0.5, 0),
                ClipsDescendants = true,
                BackgroundTransparency = 0.5,
                Size = UDim2.new(0, 110, 0, 16),
                BorderSizePixel = 0,
                ZIndex = 15,
                ThemeID = {
                    BackgroundColor3 = "Slider.Placeholder|Placeholder"
                }
            }, {
                VexUI:Create("UICorner", {
                    CornerRadius = UDim.new(0, 12),
                }),
                VexUI:Create("UIStroke", {
                    LineJoinMode = "Round",
                    Thickness = 0.6,
                    ThemeID = {
                        Color = "Outline"
                    }
                }, {
                    VexUI:Create("UIGradient", {
                        Color = ColorSequence.new(
                            Color3.fromRGB(255, 255, 255),
                            Color3.fromRGB(255, 255, 255)
                        ),
                        Transparency = NumberSequence.new({
                            NumberSequenceKeypoint.new(0, 0.1),
                            NumberSequenceKeypoint.new(0.5, 1),
                            NumberSequenceKeypoint.new(1, 1)
                        }),
                        Rotation = -100
                    })
                }),
            })

            local DropValue = VexUI:Create("Frame", {
                Parent = ValueFrame,
                BorderSizePixel = 0,
                ClipsDescendants = true,
                BackgroundTransparency = 0,
                Size = UDim2.new(0, 0, 1, 0),
                ZIndex = 16,
                ThemeID = {
                    BackgroundColor3 = "Slider.SliderPart|Text"
                }
            }, {
                VexUI:Create("UICorner", {
                    CornerRadius = UDim.new(0, 12),
                }),
            })

            local BGFrame = VexUI:Create("Frame", {
                Parent = SliderElement,
                AnchorPoint = Vector2.new(0.96, 0.5),
                Position = UDim2.new(0.96, 0, 0.5, 0),
                BackgroundColor3 = Color3.fromRGB(20, 20, 20),
                BackgroundTransparency = 0.5,
                Size = UDim2.new(0, 29, 0, 22),
                BorderSizePixel = 0,
                ZIndex = 15,
                ThemeID = {
                    BackgroundColor3 = "Slider.Placeholder|Placeholder"
                }
            }, {
                VexUI:Create("UICorner", {
                    CornerRadius = UDim.new(0, 10),
                }),
                VexUI:Create("UIStroke", {
                    LineJoinMode = "Round",
                    Thickness = 0.6,
                    ThemeID = {
                        Color = "Outline"
                    }
                }, {
                    VexUI:Create("UIGradient", {
                        Color = ColorSequence.new(
                            Color3.fromRGB(255, 255, 255),
                            Color3.fromRGB(255, 255, 255)
                        ),
                        Transparency = NumberSequence.new({
                            NumberSequenceKeypoint.new(0, 0.1),
                            NumberSequenceKeypoint.new(0.5, 1),
                            NumberSequenceKeypoint.new(1, 1)
                        }),
                        Rotation = -110
                    })
                }),
            })
            local SliderTRG = VexUI:Create("TextButton", {
                Parent = ValueFrame,
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                TextTransparency = 1,
                ZIndex = 25,
            })

            local BGBox = VexUI:Create("TextBox", {
                Parent = BGFrame,
                AnchorPoint = Vector2.new(0.5, 0.5),
                Position = UDim2.new(0.5, 0, 0.5, 0),
                BackgroundTransparency = 1,
                TextTransparency = 0,
                ZIndex = 16,
                Size = UDim2.new(1, 0, 1, 0),
                Text = tostring(Slider.Value.Default or 0),
                TextColor3 = Color3.fromRGB(255, 255, 255),
                FontFace = Font.new([[rbxassetid://12187365364]], Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
                TextSize = 10,
                ThemeID = {
                    TextColor3 = "Slider.Text|Text"
                }
            })

            local ScrollFrame = VexUI:Create("Frame", {
                Parent = DropValue,
                AnchorPoint = Vector2.new(0, 1),
                Position = UDim2.new(0, 0, -1.5, -5),
                BackgroundColor3 = Color3.fromRGB(30, 30, 30),
                BackgroundTransparency = 1,
                Size = UDim2.new(0, 35, 0, 20),
                BorderSizePixel = 0,
                Visible = false,
                ZIndex = 30,
                ThemeID = {
                    BackgroundColor3 = "Slider.Placeholder|Placeholder"
                }
            }, {
                VexUI:Create("UICorner", {
                    CornerRadius = UDim.new(0, 6),
                }),
                VexUI:Create("TextLabel", {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 1, 0),
                    TextColor3 = Color3.fromRGB(255, 255, 255),
                    TextTransparency = 1,
                    TextSize = 11,
                    ZIndex = 31,
                    FontFace = Font.new([[rbxassetid://12187365364]], Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
                    ThemeID = {
                        TextColor3 = "Slider.Text|Text"
                    }
                }),
            })

            local Value
            local moveconnection
            local releaseconnection
            local isTouch = false
            local isFocusing = false

            BGBox.Focused:Connect(function()
                isFocusing = true
            end)

            BGBox.FocusLost:Connect(function()
                isFocusing = false
                if tonumber(BGBox.Text) then
                    local inputValue = tonumber(BGBox.Text)
                    local clampedValue = math.clamp(inputValue, Slider.Value.Min, Slider.Value.Max)
                    local roundedValue = math.round(clampedValue / Slider.Step) * Slider.Step
                    Value = roundedValue
                    BGBox.Text = tostring(Value)
                    DropValue.Size = UDim2.new(
                        (roundedValue - Slider.Value.Min) / (Slider.Value.Max - Slider.Value.Min),
                        0, 1, 0
                    )
                    task.spawn(Slider.Callback, roundedValue)
                end
            end)

            local clampedDefault = math.clamp(Slider.Value.Default, Slider.Value.Min, Slider.Value.Max)
            Value = clampedDefault
            DropValue.Size = UDim2.new(
                (clampedDefault - Slider.Value.Min) / (Slider.Value.Max - Slider.Value.Min),
                0, 1, 0
            )
            BGBox.Text = tostring(clampedDefault)
            task.spawn(Slider.Callback, clampedDefault)

            SliderTRG.InputBegan:Connect(function(input)
                if not isFocusing and not HoldingSlider and (
                    input.UserInputType == Enum.UserInputType.MouseButton1 or
                    input.UserInputType == Enum.UserInputType.Touch
                ) then
                    isTouch = (input.UserInputType == Enum.UserInputType.Touch)
                    HoldingSlider = true

                    ScrollFrame.Visible = true
                    Utility:TweenObject(ScrollFrame, { BackgroundTransparency = 0.1 }, 0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
                    Utility:TweenObject(ScrollFrame:FindFirstChildOfClass("TextLabel"), { TextTransparency = 0 }, 0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)

                    if moveconnection then moveconnection:Disconnect() end
                    if releaseconnection then releaseconnection:Disconnect() end

                    moveconnection = game:GetService("RunService").RenderStepped:Connect(function()
                        local inputPosition
                        if isTouch then
                            inputPosition = input.Position.X
                        else
                            inputPosition = game:GetService("UserInputService"):GetMouseLocation().X
                        end

                        local delta = math.clamp(
                            (inputPosition - ValueFrame.AbsolutePosition.X) / ValueFrame.AbsoluteSize.X,
                            0, 1
                        )
                        Value = math.floor(
                            (Slider.Value.Min + delta * (Slider.Value.Max - Slider.Value.Min)) / Slider.Step + 0.5
                        ) * Slider.Step

                        Utility:TweenObject(DropValue, { Size = UDim2.new(delta, 0, 1, 0) }, 0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)

                        BGBox.Text = tostring(Value)
                        ScrollFrame:FindFirstChildOfClass("TextLabel").Text = tostring(Value)
                        ScrollFrame.Position = UDim2.new(delta, 0, -1.5, -5)

                        task.spawn(Slider.Callback, Value)
                    end)

                    releaseconnection = game:GetService("UserInputService").InputEnded:Connect(function(endInput)
                        if (
                            endInput.UserInputType == Enum.UserInputType.MouseButton1 or
                            endInput.UserInputType == Enum.UserInputType.Touch
                        ) and input == endInput then
                            if moveconnection then moveconnection:Disconnect() moveconnection = nil end
                            if releaseconnection then releaseconnection:Disconnect() releaseconnection = nil end
                            HoldingSlider = false

                            Utility:TweenObject(ScrollFrame, { BackgroundTransparency = 1 }, 0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
                            Utility:TweenObject(ScrollFrame:FindFirstChildOfClass("TextLabel"), { TextTransparency = 1 }, 0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
                            task.wait(0.1)
                            ScrollFrame.Visible = false
                        end
                    end)
                end
            end)

            function Slider:SetValue(val)
                local clamped = math.clamp(val, Slider.Value.Min, Slider.Value.Max)
                local rounded = math.round(clamped / Slider.Step) * Slider.Step
                Value = rounded
                BGBox.Text = tostring(rounded)
                Utility:TweenObject(DropValue, {Size = UDim2.new((rounded - Slider.Value.Min) / (Slider.Value.Max - Slider.Value.Min),0, 1, 0)}, 0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
                task.spawn(Slider.Callback, rounded)
            end

            function Slider:SetDesc(val)
                Desc.Frame.Visible = true
                Desc.SetText(val)
            end

            function Slider:Close()
                Beeee:Destroy()
            end
            table.insert(Window.SearchIndex, {
                Title = Slider.Title, Desc = Slider.Desc, Icon = "settings-2",
                Type = "Slider", TabTitle = Tab.Title,
                SelectFn = SelectTab, Frame = Beeee, RightScroll = RightScroll,
            })
            return Slider
        end
        function Tab:Dropdown(Config)
            local Dropdown = {
                Title = Config.Title or "Dropdown",
                Desc = Config.Desc,
                Value = Config.Value or "",
                Locked = Config.Locked or false,
                Multi = Config.Multi or false,
                Option = Config.Option or {},
                Options = {},
                Callback = Config.Callback or function() end,
                ASpeed = 0.2
            }

            local DropDownElement = VexUI:Create("Frame", {
                Parent = RightScroll,
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                AutomaticSize = "Y",
                Size = UDim2.new(0, ElementFrame.Size.X.Offset - 10, 0, 40),
            }, {
                VexUI:Create("UICorner", { CornerRadius = UDim.new(0, 10) }),
                VexUI:Create("UIListLayout", {
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    Padding = UDim.new(0, 0)
                })
            })

            local DropFrame = VexUI:Create("Frame", {
                Parent = DropDownElement,
                BackgroundColor3 = Color3.fromRGB(43, 43, 43),
                BackgroundTransparency = 0.5,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, 40),
                ZIndex = 15,
                ThemeID = {
                    BackgroundColor3 = "Dropdown.Background|ElementColor"
                }
            }, {
                VexUI:Create("UICorner", { CornerRadius = UDim.new(0, 12) }),
                VexUI:Create("UIStroke", {
                    Color = Color3.fromRGB(255, 255, 255),
                    LineJoinMode = "Round",
                    Thickness = 0.6,
                    ThemeID = { Color = "Outline" }
                }, {
                    VexUI:Create("UIGradient", {
                        Color = ColorSequence.new(Color3.fromRGB(255,255,255), Color3.fromRGB(255,255,255)),
                        Transparency = NumberSequence.new({
                            NumberSequenceKeypoint.new(0, 0.1),
                            NumberSequenceKeypoint.new(0.5, 1),
                            NumberSequenceKeypoint.new(1, 1)
                        }),
                        Rotation = -110
                    })
                }),
                VexUI:Create("UIPadding", {
                    PaddingTop = UDim.new(0,5),
                    PaddingBottom = UDim.new(0,5)
                }),
                VexUI:Create("Frame", {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 1, 0),
                    ClipsDescendants = true,
                    ZIndex = 16,
                },{
                    VexUI:Create("UIListLayout", {
                        SortOrder = Enum.SortOrder.LayoutOrder,
                        Padding = UDim.new(0, 1)
                    }),
                    VexUI:Create("UIPadding", {
                        PaddingTop = UDim.new(0,9),
                    })
                })
            })

            local Title = CreateRichIconText(DropFrame.Frame, Dropdown.Title, {
                Size = UDim2.new(1, 0, 1, 0),
                AutomaticSize = "Y",
                ZIndex = 16,
                FontFace = Font.new([[rbxassetid://12187365364]], Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
                TextSize = 13,
                TextColor3 = Color3.fromRGB(255, 255, 255),
                RichText = true,
                TextWrapped = true,
                TextXAlignment = Enum.TextXAlignment.Left,
                ThemeID = {
                    TextColor3 = "Dropdown.Text|Text"
                }
            }, {
                VexUI:Create("UIPadding", {
                    PaddingLeft = UDim.new(0, 10),
                })
            })

            local Desc = CreateRichIconText(DropFrame, Dropdown.Desc, {
                Size = UDim2.new(1, -130, 0, 0),
                AutomaticSize = "Y",
                Position = UDim2.new(0, 10, 0, 22),
                ZIndex = 16,
                FontFace = Font.new([[rbxassetid://12187365364]], Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
                TextSize = 12,
                TextTransparency = 0.7,
                TextColor3 = Color3.fromRGB(255, 255, 255),
                RichText = true,
                TextWrapped = true,
                TextXAlignment = Enum.TextXAlignment.Left,
                ThemeID = {
                    TextColor3 = "Dropdown.Text|Text"
                }
            })

            local DropValueFrame = VexUI:Create("Frame", {
                Parent = DropFrame,
                AnchorPoint = Vector2.new(1, 0.5),
                Position = UDim2.new(1, -10, 0.5, 0),
                BackgroundColor3 = Color3.fromRGB(20, 20, 20),
                BackgroundTransparency = 0.5,
                BorderSizePixel = 0,
                Size = UDim2.new(0, 119, 0, 25),
                ZIndex = 15,
                ThemeID = {
                    BackgroundColor3 = "Dropdown.Placeholder|Placeholder"
                }
            }, {
                VexUI:Create("UICorner", { CornerRadius = UDim.new(0, 12) }),
                VexUI:Create("UIStroke", {
                    Color = Color3.fromRGB(255, 255, 255),
                    Thickness = 0.6,
                    ThemeID = { Color = "Outline" }
                }, {
                    VexUI:Create("UIGradient", {
                        Color = ColorSequence.new(Color3.fromRGB(255,255,255), Color3.fromRGB(255,255,255)),
                        Transparency = NumberSequence.new({
                            NumberSequenceKeypoint.new(0, 0.1),
                            NumberSequenceKeypoint.new(0.5, 1),
                            NumberSequenceKeypoint.new(1, 1)
                        }),
                        Rotation = -110
                    })
                })
            })

            local DropIcon = VexUI:Create("ImageLabel", {
                Parent = DropValueFrame,
                AnchorPoint = Vector2.new(1, 0.5),
                Position = UDim2.new(1, -4, 0.5, 0),
                BackgroundTransparency = 1,
                Size = UDim2.new(0, 17, 0, 17),
                Image = IconsV2.GetIcon("chevron-down"),
                ZIndex = 16,
                ThemeID = {
                    ImageColor3 = "Dropdown.IconColor|IconColor"
                }
            })

            local DropOptionBox = VexUI:Create("TextBox", {
                Parent = DropValueFrame,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 8, 0, 0),
                Size = UDim2.new(1, -30, 1, 0),
                Text = Dropdown.Value,
                TextColor3 = Color3.fromRGB(255, 255, 255),
                FontFace = Font.new([[rbxassetid://12187365364]], Enum.FontWeight.SemiBold),
                TextSize = 10,
                ZIndex = 100,
                TextXAlignment = Enum.TextXAlignment.Left,
                ThemeID = {
                    TextColor3 = "Dropdown.Text|Text"
                }
            })

            local DropDownTRG = VexUI:Create("TextButton", {
                Parent = DropFrame,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 1, 0),
                Text = "",
                ZIndex = 25,
            })

            local DropElementFrame = VexUI:Create("Frame", {
                Parent = DropDownElement,
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                ClipsDescendants = true,
                Size = UDim2.new(1, 0, 0, 0),
                ZIndex = 15,
            })

            local ScrollingFrame = VexUI:Create("ScrollingFrame", {
                Parent = DropElementFrame,
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Position = UDim2.new(0, 0, 0, 0),
                Size = UDim2.new(1, 0, 1, 0),
                AutomaticCanvasSize = "Y",
                ScrollingDirection = "Y",
                CanvasSize = UDim2.new(0, 0, 0, 0),
                ScrollBarThickness = 2,
                ZIndex = 15,
            }, {
                VexUI:Create("UIPadding", {
                    PaddingTop = UDim.new(0, 0),
                    PaddingBottom = UDim.new(0, 0),
                    PaddingLeft = UDim.new(0, 2),
                    PaddingRight = UDim.new(0, 2),
                })
            })

            local ListLayout = VexUI:Create("UIListLayout", {
                Parent = ScrollingFrame,
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 5),
            })

            local DropOpen = false
            local isUserTyping = false

            DropOptionBox.Focused:Connect(function()
                isUserTyping = true
            end)

            DropOptionBox.FocusLost:Connect(function()
                isUserTyping = false
            end)

            local function openDropdown()
                DropOpen = true
                task.defer(function()
                    local contentH = ListLayout.AbsoluteContentSize.Y
                    if contentH == 0 then contentH = #Dropdown.Option * 30 end
                    local totalH = math.min(contentH + 12, 200)

                    Utility:TweenObject(DropElementFrame, {Size = UDim2.new(1, 0, 0, totalH)}, Dropdown.ASpeed, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
                    Utility:TweenObject(ScrollingFrame.UIPadding, {PaddingTop = UDim.new(0, 6), PaddingBottom = UDim.new(0, 6)}, Dropdown.ASpeed, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
                    Utility:TweenObject(DropIcon, {Rotation = 180}, 0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
                end)
            end

            DropOptionBox:GetPropertyChangedSignal("Text"):Connect(function()
                local query = DropOptionBox.Text
                if not isUserTyping or query == "" then
                    for _, v in next, ScrollingFrame:GetChildren() do
                        if v:IsA("Frame") then v.Visible = true end
                    end
                    return
                end
                local lower = string.lower(query)
                for _, v in next, ScrollingFrame:GetChildren() do
                    if v:IsA("Frame") then
                        local btn = v:FindFirstChildOfClass("TextButton")
                        openDropdown()
                        v.Visible = btn and string.lower(btn.Text):find(lower) ~= nil
                    end
                end
                task.defer(function()
                    local contentH = ListLayout.AbsoluteContentSize.Y
                    ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, contentH)

                    if DropOpen then
                        local totalH = math.min(contentH + 12, 149)
                        DropElementFrame.Size = UDim2.new(1, 0, 0, totalH)
                    end
                end)
            end)

            local function closeDropdown()
                DropOpen = false
                Utility:TweenObject(DropElementFrame, {Size = UDim2.new(1, 0, 0, 0)}, Dropdown.ASpeed, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
                Utility:TweenObject(ScrollingFrame.UIPadding, {PaddingTop = UDim.new(0, 0), PaddingBottom = UDim.new(0, 0)}, Dropdown.ASpeed, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
                Utility:TweenObject(DropIcon, {Rotation = 0}, 0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
            end

            DropDownTRG.MouseButton1Click:Connect(function()
                if DropOpen then
                    closeDropdown()
                else
                    openDropdown()
                end
            end)

            function Dropdown:Refresh(options)
                Dropdown.Option = options or Dropdown.Option

                for _, v in next, ScrollingFrame:GetChildren() do
                    if v:IsA("Frame") then v:Destroy() end
                end

                local Items = {}

                for _, Item in ipairs(Dropdown.Option) do
                    local DropElement = VexUI:Create("Frame", {
                        Parent = ScrollingFrame,
                        Name = Item,
                        BackgroundColor3 = Color3.fromRGB(43, 43, 43),
                        BackgroundTransparency = 0.5,
                        BorderSizePixel = 0,
                        Size = UDim2.new(1, -4, 0, 24),
                        ZIndex = 16,
                        ThemeID = {
                            BackgroundColor3 = "Dropdown.Background|ElementColor"
                        }
                    }, {
                        VexUI:Create("UICorner", { CornerRadius = UDim.new(0, 12) }),
                        VexUI:Create("UIStroke", {
                            Color = Color3.fromRGB(255, 255, 255),
                            Thickness = 0.6,
                            ThemeID = { Color = "Outline" }
                        }, {
                            VexUI:Create("UIGradient", {
                                Color = ColorSequence.new(Color3.fromRGB(255,255,255), Color3.fromRGB(255,255,255)),
                                Transparency = NumberSequence.new({
                                    NumberSequenceKeypoint.new(0, 0.1),
                                    NumberSequenceKeypoint.new(0.5, 1),
                                    NumberSequenceKeypoint.new(1, 1)
                                }),
                                Rotation = -110
                            })
                        })
                    })

                    local DropElementTRG = VexUI:Create("TextButton", {
                        Parent = DropElement,
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1, 0, 1, 0),
                        Text = Item,
                        TextColor3 = Color3.fromRGB(255, 255, 255),
                        TextTransparency = 0.4,
                        FontFace = Font.new([[rbxassetid://12187365364]], Enum.FontWeight.SemiBold),
                        TextSize = 11,
                        ZIndex = 17,
                        ThemeID = {
                            TextColor3 = "Dropdown.Text|Text"
                        }
                    }, {
                        VexUI:Create("UIPadding", { PaddingLeft = UDim.new(0, 8) })
                    })

                    local itemEntry = { DropElement = DropElement, Selected = false }
                    Items[#Items + 1] = itemEntry

                    DropElementTRG.MouseButton1Click:Connect(function()
                        if not Dropdown.Multi then
                            for _, entry in pairs(Items) do
                                entry.Selected = false
                                Utility:TweenObject(entry.DropElement, {BackgroundTransparency = 0.5}, 0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
                                local btn = entry.DropElement:FindFirstChildOfClass("TextButton")
                                if btn then
                                    Utility:TweenObject(btn, {TextTransparency = 0.4}, 0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
                                end
                            end

                            itemEntry.Selected = true
                            Utility:TweenObject(DropElement, {BackgroundTransparency = 0}, 0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
                            Utility:TweenObject(DropElementTRG, {TextTransparency = 0}, 0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)

                            Dropdown.Value = Item
                            DropOptionBox.Text = Item

                            closeDropdown()
                            task.spawn(Dropdown.Callback, Item)
                        else
                            itemEntry.Selected = not itemEntry.Selected

                            if itemEntry.Selected then
                                table.insert(Dropdown.Options, Item)
                                Utility:TweenObject(DropElement, {BackgroundTransparency = 0}, 0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
                                Utility:TweenObject(DropElementTRG, {TextTransparency = 0}, 0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
                            else
                                for i = #Dropdown.Options, 1, -1 do
                                    if Dropdown.Options[i] == Item then
                                        table.remove(Dropdown.Options, i)
                                        break
                                    end
                                end
                                Utility:TweenObject(DropElement, {BackgroundTransparency = 0.5}, 0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
                                Utility:TweenObject(DropElementTRG, {TextTransparency = 0.4}, 0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
                            end

                            DropOptionBox.Text = table.concat(Dropdown.Options, ", ")
                            task.spawn(Dropdown.Callback, Dropdown.Options)
                        end
                    end)
                end

                task.defer(function()
                    ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, ListLayout.AbsoluteContentSize.Y)
                end)

                return Dropdown, Items
            end

            function Dropdown:Close()
                DropDownElement:Destroy()
            end

            function Dropdown:SetTitle(Value)
                Title.Text = Value
            end

            function Dropdown:SetDesc(Text)
                Desc.Visible = true
                Desc.SetText(Text)
            end

            if Dropdown.Desc then
                Dropdown:SetDesc(Dropdown.Desc)
            end

            function Dropdown:SetValue(Value)
                DropOptionBox.Text = Value
                Dropdown.Value = Value
            end

            Dropdown:Refresh(Dropdown.Option)
            table.insert(Window.SearchIndex, {
                Title = Dropdown.Title, Desc = Dropdown.Desc, Icon = "list",
                Type = "Dropdown", TabTitle = Tab.Title,
                SelectFn = SelectTab, Frame = DropDownElement,
                RightScroll = RightScroll,
            })
            return Dropdown
        end

        function Tab:Input(Config)
            local Input = {
                Title = Config.Title or "Input",
                Desc = Config.Desc or nil,
                Value = Config.Value or "",
                Locked = Config.Locked or false,
                MaxSymbols = Config.MaxSymbols or nil,
                Callback = Config.Callback or function() end,
                SizeY = 40
            }

            local Beeee = VexUI:Create("Frame", {
                Parent = RightScroll,
                BackgroundTransparency = 1,
                AutomaticSize = "Y",
                Size = UDim2.new(0, ElementFrame.Size.X.Offset - 10, 0, Input.SizeY),
                ZIndex = 15,
            })
            local InputElement = VexUI:Create("Frame", {
                Parent = Beeee,
                BackgroundColor3 = Color3.fromRGB(43, 43, 43),
                BackgroundTransparency = 0.5,
                BorderSizePixel = 0,
                AutomaticSize = Enum.AutomaticSize.Y,
                Size = UDim2.new(1, 0, 1, 0),
                ZIndex = 15,
                ThemeID = { BackgroundColor3 = "Input.Background|ElementColor" }
            },{
                VexUI:Create("UIStroke", {
                    Color = Color3.fromRGB(255, 255, 255),
                    LineJoinMode = "Round",
                    Thickness = 0.6,
                    ThemeID = {
                        Color = "Outline"
                    }
                },{
                    VexUI:Create("UIGradient", {
                        Color = ColorSequence.new(
                            Color3.fromRGB(255, 255, 255), 
                            Color3.fromRGB(255, 255, 255)
                        ),
                        Transparency = NumberSequence.new({
                            NumberSequenceKeypoint.new(0, 0.1),
                            NumberSequenceKeypoint.new(0.5, 1),
                            NumberSequenceKeypoint.new(1, 1)
                        }),
                        Rotation = -110
                    })
                }),
                VexUI:Create("UICorner", {
                    CornerRadius = UDim.new(0, 12),
                }),
                VexUI:Create("UIPadding", {
                    PaddingTop = UDim.new(0,5),
                    PaddingBottom = UDim.new(0,5)
                }),

                VexUI:Create("Frame", {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 1, 0),
                    ClipsDescendants = true,
                    ZIndex = 16,
                },{
                    VexUI:Create("UIListLayout", {
                        SortOrder = Enum.SortOrder.LayoutOrder,
                        Padding = UDim.new(0, 1)
                    }),
                    VexUI:Create("UIPadding", {
                        PaddingTop = UDim.new(0,9),
                    })
                })
            })

            local Title = CreateRichIconText(InputElement.Frame, Input.Title, {
                Size = UDim2.new(1, 0, 0, 5),
                AutomaticSize = "Y",
                ZIndex = 16,
                FontFace = Font.new([[rbxassetid://12187365364]], Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
                TextSize = 13,
                TextColor3 = Color3.fromRGB(255, 255, 255),
                RichText = true,
                TextWrapped = true,
                TextXAlignment = Enum.TextXAlignment.Left,
                ThemeID = {
                    TextColor3 = "Input.Text|Text"
                }
            }, {
                VexUI:Create("UIPadding", {
                    PaddingLeft = UDim.new(0, 10)
                })
            })
            Title.Position = UDim2.new(0, 0, 0, 0)
            local Desc = CreateRichIconText(InputElement.Frame, Input.Desc, {
                Size = UDim2.new(1, 0, 0, 5),
                AutomaticSize = "Y",
                ZIndex = 16,
                FontFace = Font.new([[rbxassetid://12187365364]], Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
                TextSize = 12,
                TextTransparency = 0.7,
                TextColor3 = Color3.fromRGB(255, 255, 255),
                RichText = true,
                TextWrapped = true,
                TextXAlignment = Enum.TextXAlignment.Left,
                Visible = Input.Desc ~= nil,
                ThemeID = {
                    TextColor3 = "Input.Text|Text"
                }
            }, {
                VexUI:Create("UIPadding", {
                    PaddingLeft = UDim.new(0, 10)
                })
            })

            local InputFrame = VexUI:Create("Frame", {
                Parent = InputElement,
                AnchorPoint = Vector2.new(1, 0.5),
                Position = UDim2.new(1, -10, 0.5, 0),
                BackgroundColor3 = Color3.fromRGB(20, 20, 20),
                BackgroundTransparency = 0.5,
                BorderSizePixel = 0,
                Size = UDim2.new(0, Input.MaxSymbols and 130 or 130, 0, 25),
                ZIndex = 15,
                ThemeID = { BackgroundColor3 = "Input.Placeholder|Placeholder" }
            }, {
                VexUI:Create("UICorner", { CornerRadius = UDim.new(0, 12) }),
                VexUI:Create("UIStroke", {
                    Color = Color3.fromRGB(255, 255, 255),
                    Thickness = 0.6,
                    ThemeID = { Color = "Outline" }
                }, {
                    VexUI:Create("UIGradient", {
                        Color = ColorSequence.new(Color3.fromRGB(255,255,255), Color3.fromRGB(255,255,255)),
                        Transparency = NumberSequence.new({
                            NumberSequenceKeypoint.new(0, 0.1),
                            NumberSequenceKeypoint.new(0.5, 1),
                            NumberSequenceKeypoint.new(1, 1)
                        }),
                        Rotation = -110
                    })
                })
            })

            local InputBox = VexUI:Create("TextBox", {
                Parent = InputFrame,
                BackgroundTransparency = 1,
                ClearTextOnFocus = false,
                Position = UDim2.new(0, 0, 0, 0),
                Size = UDim2.new(1, Input.MaxSymbols and -36 or -8, 1, 0),
                Text = Input.Value,
                TextColor3 = Color3.fromRGB(255, 255, 255),
                FontFace = Font.new([[rbxassetid://12187365364]], Enum.FontWeight.SemiBold),
                TextSize = 10,
                ZIndex = 16,
                TextXAlignment = Enum.TextXAlignment.Left,
                ThemeID = { TextColor3 = "Text" }
            }, {
                VexUI:Create("UIPadding", {
                    PaddingLeft = UDim.new(0, 8),
                    PaddingRight = UDim.new(0, 4)
                })
            })

            local MaxLabel
            if Input.MaxSymbols then
                MaxLabel = VexUI:Create("TextLabel", {
                    Parent = InputFrame,
                    AnchorPoint = Vector2.new(1, 0.5),
                    Position = UDim2.new(1, -6, 0.5, 0),
                    BackgroundTransparency = 1,
                    Size = UDim2.new(0, 30, 0, 17),
                    Text = "0/" .. Input.MaxSymbols,
                    TextColor3 = Color3.fromRGB(255, 255, 255),
                    TextTransparency = 0.5,
                    FontFace = Font.new([[rbxassetid://12187365364]], Enum.FontWeight.SemiBold),
                    TextSize = 9,
                    ZIndex = 16,
                    ThemeID = { TextColor3 = "Text" }
                })

                InputBox.Changed:Connect(function(prop)
                    if prop == "Text" then
                        if #InputBox.Text > Input.MaxSymbols then
                            InputBox.Text = string.sub(InputBox.Text, 1, Input.MaxSymbols)
                        end
                        MaxLabel.Text = #InputBox.Text .. "/" .. Input.MaxSymbols
                    end
                end)
            end

            function Input:SetDesc(Value)
                Desc.Visible = true
                Desc.Text = Value
            end

            if Input.Desc then Input:SetDesc(Input.Desc) end

            local function fireCallback()
                local val = Input.MaxSymbols
                    and string.sub(InputBox.Text, 1, Input.MaxSymbols)
                    or InputBox.Text
                task.spawn(Input.Callback, val)
            end

            fireCallback()

            InputBox.FocusLost:Connect(function(enterPressed)
                if not enterPressed then return end
                fireCallback()
            end)

            function Input:SetValue(Val)
                InputBox.Text = Val
                task.spawn(Input.Callback, Val)
            end

            function Input:SetTitle(Value)
                TitleLabel.Text = Value
            end

            if Input.Desc then
                Input:SetDesc(Input.Desc)
            end

            function Input:SetMaxSymbols(number)
                Input.MaxSymbols = number
                InputBox.MaxVisibleGraphemes = number
                if MaxLabel then
                    MaxLabel.Text = #InputBox.Text .. "/" .. number
                end
            end

            function Input:Close()
                InputElement:Destroy()
            end
            table.insert(Window.SearchIndex, {
                Title = Input.Title, Desc = Input.Desc, Icon = "text-cursor-input",
                Type = "Input", TabTitle = Tab.Title,
                SelectFn = SelectTab, Frame = Beeee, RightScroll = RightScroll,
            })
            return Input
        end
        function Tab:Keybind(Config)
            local Keybind = {
                Title = Config.Title or "Keybind",
                Desc = Config.Desc or nil,
                Value = Config.Value or "F",
                Locked = Config.Locked or false,
                Callback = Config.Callback or function() end,
                SizeY = 40
            }

            local Beeee = VexUI:Create("Frame", {
                Parent = RightScroll,
                BackgroundTransparency = 1,
                AutomaticSize = "Y",
                Size = UDim2.new(0, ElementFrame.Size.X.Offset - 10, 0, Keybind.SizeY),
                ZIndex = 15,
            })

            local KeybindElement = VexUI:Create("Frame", {
                Parent = Beeee,
                BackgroundTransparency = 0.5,
                BackgroundColor3 = Color3.fromRGB(43, 43, 43),
                AutomaticSize = Enum.AutomaticSize.Y,
                Size = UDim2.new(1, 0, 1, 0),
                ZIndex = 15,
                ThemeID = {BackgroundColor3 = "Keybind.Background|ElementColor"}
            }, {
                VexUI:Create("UIStroke", {
                    Color = Color3.fromRGB(255, 255, 255),
                    LineJoinMode = "Round",
                    Thickness = 0.6,
                    ThemeID = { Color = "Outline" }
                }, {
                    VexUI:Create("UIGradient", {
                        Color = ColorSequence.new(
                            Color3.fromRGB(255, 255, 255),
                            Color3.fromRGB(255, 255, 255)
                        ),
                        Transparency = NumberSequence.new({
                            NumberSequenceKeypoint.new(0, 0.1),
                            NumberSequenceKeypoint.new(0.5, 1),
                            NumberSequenceKeypoint.new(1, 1)
                        }),
                        Rotation = -110
                    })
                }),
                VexUI:Create("UICorner", { CornerRadius = UDim.new(0, 12) }),
                VexUI:Create("UIPadding", {
                    PaddingTop = UDim.new(0, 5),
                    PaddingBottom = UDim.new(0, 5)
                }),
                VexUI:Create("Frame", {
                    Name = "Frame",
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 1, 0),
                    ClipsDescendants = true,
                    ZIndex = 16,
                }, {
                    VexUI:Create("UIListLayout", {
                        SortOrder = Enum.SortOrder.LayoutOrder,
                        Padding = UDim.new(0, 1)
                    }),
                    VexUI:Create("UIPadding", {
                        PaddingTop = UDim.new(0, 9),
                    })
                })
            })

            local Title = CreateRichIconText(KeybindElement.Frame, Keybind.Title, {
                Size = UDim2.new(1, 0, 0, 5),
                AutomaticSize = "Y",
                ZIndex = 16,
                FontFace = Font.new([[rbxassetid://12187365364]], Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
                TextSize = 13,
                TextColor3 = Color3.fromRGB(255, 255, 255),
                RichText = true,
                TextWrapped = true,
                TextXAlignment = Enum.TextXAlignment.Left,
                ThemeID = { TextColor3 = "Keybind.Text|Text" }
            }, {
                VexUI:Create("UIPadding", { PaddingLeft = UDim.new(0, 10) })
            })
            Title.Position = UDim2.new(0, 0, 0, 0)

            local Desc = CreateRichIconText(KeybindElement.Frame, Keybind.Desc or "", {
                Size = UDim2.new(1, 0, 0, 5),
                AutomaticSize = "Y",
                ZIndex = 16,
                FontFace = Font.new([[rbxassetid://12187365364]], Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
                TextSize = 12,
                TextTransparency = 0.7,
                TextColor3 = Color3.fromRGB(255, 255, 255),
                RichText = true,
                TextWrapped = true,
                TextXAlignment = Enum.TextXAlignment.Left,
                Visible = Keybind.Desc ~= nil,
                ThemeID = { TextColor3 = "Keybind.Text|Text" }
            }, {
                VexUI:Create("UIPadding", { PaddingLeft = UDim.new(0, 10) })
            })

            local KeyFrame = VexUI:Create("TextButton", {
                Parent = KeybindElement,
                AnchorPoint = Vector2.new(1, 0.5),
                Position = UDim2.new(1, -10, 0.5, 0),
                BackgroundColor3 = Color3.fromRGB(20, 20, 20),
                BackgroundTransparency = 0,
                BorderSizePixel = 0,
                Size = UDim2.new(0, 28, 0, 20),
                TextTransparency = 0,
                ZIndex = 17,
                FontFace = Font.new([[rbxassetid://12187365364]], Enum.FontWeight.SemiBold),
                Text = Keybind.Value,
                TextColor3 = Color3.fromRGB(255, 255, 255),
                TextSize = 11,
                ThemeID = {
                    BackgroundColor3 = "Keybind.Placeholder|Placeholder",
                    TextColor3 = "Keybind.Text|Text"
                }
            }, {
                VexUI:Create("UICorner", { CornerRadius = UDim.new(0, 6) }),
                VexUI:Create("UIStroke", {
                    Color = Color3.fromRGB(255, 255, 255),
                    Thickness = 0.6,
                    ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                    ThemeID = { Color = "Outline" }
                }, {
                    VexUI:Create("UIGradient", {
                        Color = ColorSequence.new(Color3.fromRGB(255,255,255), Color3.fromRGB(255,255,255)),
                        Transparency = NumberSequence.new({
                            NumberSequenceKeypoint.new(0, 0.1),
                            NumberSequenceKeypoint.new(0.5, 1),
                            NumberSequenceKeypoint.new(1, 1)
                        }),
                        Rotation = -110
                    })
                })
            })
            local listening = false

            KeyFrame.MouseButton1Click:Connect(function()
                if listening then return end
                listening = true
                KeyFrame.Text = "..."

                local conn
                conn = game:GetService("UserInputService").InputBegan:Connect(function(input)
                    if input.KeyCode ~= Enum.KeyCode.Unknown then
                        conn:Disconnect()
                        listening = false
                        local keyName = input.KeyCode.Name
                        KeyFrame.Text = keyName
                        Keybind.Value = keyName
                        task.spawn(Keybind.Callback, keyName)
                    end
                end)
            end)

            function Keybind:SetDesc(Value)
                Desc.Visible = true
                Desc.Text = Value
            end

            if Keybind.Desc then Keybind:SetDesc(Keybind.Desc) end

            function Keybind:SetValue(Val)
                KeyFrame.Text = Val
                Keybind.Value = Val
                task.spawn(Keybind.Callback, Val)
            end

            function Keybind:SetTitle(Value)
                Title.Text = Value
            end

            function Keybind:Close()
                Beeee:Destroy()
            end

            task.spawn(Keybind.Callback, Keybind.Value)
            table.insert(Window.SearchIndex, {
                Title = Keybind.Title, Desc = Keybind.Desc, Icon = "keyboard",
                Type = "Keybind", TabTitle = Tab.Title,
                SelectFn = SelectTab, Frame = Beeee, RightScroll = RightScroll,
            })
            return Keybind
        end
        function Tab:Section(Config)
            local Section = {
                Title = Config.Title or "Section",
                Icon = Config.Icon,
                TextSize = Config.TextSize or 18,
                UIPadding = Config.UIPadding or UDim.new(0, 0),
            }
            local SectionElement = VexUI:Create("Frame", {
                Parent = RightScroll,
                BackgroundColor3 = Color3.new(1, 1, 1),
                BackgroundTransparency = 1,
                BorderColor3 = Color3.new(0, 0, 0),
                ZIndex = 20,
                Position = UDim2.new(0, 0, 0.3038, 0),
                Size = UDim2.new(0, ElementFrame.Size.X.Offset - 10, 0, 30),
            })

            local SectionLabel = VexUI:Create("TextLabel", {
                Parent = SectionElement,
                BackgroundTransparency = 1,
                RichText = true,
                Position = UDim2.new(0, 0, 0, 0),
                Size = UDim2.new(1, 0, 1, 0),
                FontFace = Font.new([[rbxassetid://12187365364]], Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
                Text = Section.Title,
                TextSize = Section.TextSize,
                ZIndex = 20,
                TextXAlignment = Enum.TextXAlignment.Left,
                ThemeID = {
                    TextColor3 = "Section.Text|Text"
                },
            },{
                VexUI:Create("UIPadding", {
                    PaddingLeft = UDim.new(0, 0),
                })
            })

            local Icon
            if Section.Icon then
            SectionLabel.UIPadding.PaddingLeft = Section.UIPadding + UDim.new(0, 22)
                local Icon = VexUI:Create("ImageLabel", {
                    AnchorPoint = Vector2.new(0, 0.5),
                    --Image = IconsV2.GetIcon(Window.Icon),
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 0, 0.5, 0),
                    Size = UDim2.new(0, 20, 0, 20),
                    ZIndex = 20,
                    Parent = SectionElement,
                    ThemeID = {
                        ImageColor3 = "Section.Icon|IconColor"
                    }
                })
                if Section.Icon and IconsV2.Icon(Section.Icon) then
                    Icon.Image = IconsV2.GetIcon(Section.Icon)
                elseif Section.Icon and string.find(Section.Icon, "rbxassetid://") then
                    Icon.Image = SectionIcon
                end
            end

            function Section:Close()
                SectionElement:Destroy()
            end

            function Section:SetTitle(Value)
                SectionLabel.Text = Value
            end
            return Section
        end
        function Window:UserEnabled(Value)
            Utility:TweenObject(UserFrame, {BackgroundTransparency = Value and 0 or 1}, 0.2)
            Utility:TweenObject(UserTitle, {TextTransparency = Value and 0 or 1}, 0.2)
            Utility:TweenObject(UserSub, {TextTransparency = Value and 0.6 or 1}, 0.2)
            Utility:TweenObject(UserFrame.ImageLabel, {ImageTransparency = Value and 0 or 1,BackgroundTransparency = Value and 0 or 1}, 0.2)
            UserFrame.Visible = Value
            LeftScroll.Size = UDim2.new(0, Window.SideBarWidth, 1, Value and -50 or 0)
        end
        function Window:Anonymous(Value)
            UserTitle.Text = Value and "Anonymous" or game.Players.LocalPlayer.DisplayName
            UserSub.Text = Value and "@Anonymous" or "@"..game.Players.LocalPlayer.Name
            UserFrame.ImageLabel.Image = (function()
                return game:GetService("Players"):GetUserThumbnailAsync(Value and 1 or game.Players.LocalPlayer.UserId,Enum.ThumbnailType.HeadShot,Enum.ThumbnailSize.Size150x150)
            end)()
        end
        return Tab
    end

    function Window:Section(Config)
        local Section = {
            Title = Config.Title or "Section",
            Icon = Config.Icon or nil,
            Opened = Config.Opened or true,
        }

        local isOpen = Section.Opened

        local SectionFrame = VexUI:Create("Frame", {
            Parent = LeftScroll,
            AutomaticSize = "Y",
            BackgroundTransparency = 1,
            Size = UDim2.new(0, Window.SideBarWidth - 5, 0, 0),
            BorderSizePixel = 0,
            ZIndex = 5,
        }, {
            VexUI:Create("UIListLayout", {
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 5),
            }),
        })

        local SectionBTN = VexUI:Create("TextButton", {
            Parent = SectionFrame,
            Size = UDim2.new(1, 0, 0, 25),
            BackgroundTransparency = 1,
            TextTransparency = 1,
            ZIndex = 50,
        },{
            VexUI:Create("UIPadding", {
                PaddingTop = UDim.new(0, 9),
            }),
            VexUI:Create("ImageLabel", {
                AnchorPoint = Vector2.new(1, 0.5),
                Position = UDim2.new(1, -10, 0.5, 0),
                BackgroundTransparency = 1,
                Size = UDim2.new(0, 12, 0, 12),
                Image = IconsV2.GetIcon("chevron-down"),
                Rotation = isOpen and -180 or 0,
                ZIndex = 16,
                ThemeID = { ImageColor3 = "Text" }
            })
        })

        --[[SectionBTN.MouseButton1Click:Connect(function()
            isOpen = not isOpen
            --SectionRoll.Visible = isOpen
            Utility:TweenObject(SectionBTN.ImageLabel, {Rotation = isOpen and 0 or -180}, 0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
        end)--]]

        local SecTitle = CreateRichIconText(SectionBTN, Section.Title, {
            Size = UDim2.new(1, 0, 1, 0),
            AutomaticSize = "Y",
            ZIndex = 16,
            FontFace = Font.new([[rbxassetid://12187365364]], Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
            TextSize = 14,
            TextColor3 = Color3.fromRGB(255, 255, 255),
            RichText = true,
            TextWrapped = true,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 49,
            ThemeID = { TextColor3 = "Text" }
        }, {
            VexUI:Create("UIPadding", { PaddingLeft = UDim.new(0, 12) })
        })
        SecTitle.Position = UDim2.new(0, 0, 0, 0)

        local Icon
        if Section.Icon then
            Icon = VexUI:Create("ImageLabel", {
                AnchorPoint = Vector2.new(.02, 0.5),
                --Image = IconsV2.GetIcon(Window.Icon),
                BackgroundTransparency = 1,
                Position = UDim2.new(.02, 0, 0.5, 0),
                BorderColor3 = Color3.new(0, 0, 0),
                Size = UDim2.new(0, 15, 0, 15),
                BorderSizePixel = 0,
                ZIndex = 49,
                Parent = SectionBTN,
                ThemeID = {
                    ImageColor3 = "IconColor"
                }
            })
            SecTitle.UIPadding.PaddingLeft = UDim.new(0,20)
            if Section.Icon and IconsV2.Icon(Section.Icon) then
                Icon.Image = IconsV2.GetIcon(Section.Icon)
            elseif Section.Icon and string.find(Section.Icon, "rbxassetid://") then
                Icon.Image = Section.Icon
            end
        end

        local SectionRoll = VexUI:Create("Frame", {
            Parent = SectionFrame,
            AutomaticSize = "Y",
            ClipsDescendants = true,
            BackgroundTransparency = 1,
            Size = UDim2.new(0, Window.SideBarWidth, 0, 0),
            BorderSizePixel = 0,
            ZIndex = 5,
        }, {
            VexUI:Create("UIListLayout", {
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 5),
            }),
        })

        SectionBTN.MouseButton1Click:Connect(function()
            isOpen = not isOpen
            Utility:TweenObject(SectionBTN.ImageLabel, {Rotation = isOpen and -180 or 0}, 0.16)
            SectionRoll.Size = UDim2.new(1, 0, 0, SectionRoll.AbsoluteSize.Y)
            SectionRoll.AutomaticSize = Enum.AutomaticSize.None
            if isOpen then
                Utility:TweenObject(SectionRoll, {Size = UDim2.new(1, 0, 0, SectionRoll.UIListLayout.AbsoluteContentSize.Y)}, 0.2)
            else
                Utility:TweenObject(SectionRoll, {Size = UDim2.new(1, 0, 0, 0)}, 0.2)
            end
        end)

        function Section:Tab(Config)
            return Window:Tab(Config, SectionRoll.UIListLayout and SectionRoll or SectionRoll)
        end
        return Section
    end
    function Window:Open()
        Island.Visible = true
        Utility:TweenObject(Island, {Position = UDim2.new(0.5, 0, -0.2, 0)}, 0.3)

        Window.IslandOpen = true
        Main.Visible = true
        Window.Default = "Default"
        Utility:TweenObject(TabFrame, {Size = UDim2.new(0, Window.SideBarWidth, 0, Window.Size.Y.Offset - Window.Topbar.Height - 10)}, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
        Utility:TweenObject(TabFrame, {BackgroundTransparency = 0}, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
        Utility:TweenObject(TabFrame.Frame, {BackgroundTransparency = 0}, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
        Utility:TweenObject(LeftScroll, {Size = UDim2.new(1, 0, 1, 0)}, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
        Utility:TweenObject(Main.Frame, {Size = UDim2.new(0, Window.Size.X.Offset - 182 + 133 + 5, 0, Window.Topbar.Height)}, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out) --0, Window.Size.X.Offset, 0, Window.Size.Y.Offset-8
        Main.Frame.Visible = true
        Utility:TweenObject(Main, {Size = UDim2.new(0, Window.Size.X.Offset, 0, Window.Size.Y.Offset)}, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out) --UDim2.new(0, Window.Size.X.Offset, 0, Window.Size.Y.Offset)
        Utility:TweenObject(Main, {BackgroundTransparency = 0}, 0.2, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out)

        if UI.Notifications == 0 then
            Utility:TweenObject(Island, {Position = UDim2.new(0.5, 0, -0.2, 0)}, 0.3)
        end
        task.defer(function()
                Utility:TweenObject(Island, {Size = UDim2.new(0, Island.UIListLayout.AbsoluteContentSize.X + 5, 0, 35)}, 0, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
                task.wait(0.1)
                Utility:TweenObject(MinzUI, {Size = UDim2.new(0, MinzUI.UIListLayout.AbsoluteContentSize.X + 10, 0, 30)}, 0.3, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
        end)
        task.wait(0.25)
        MinzUI.Visible = false
    end
    function Window:Close()
        Island.Visible = true
        Utility:TweenObject(Island, {Position = UDim2.new(0.5, 0, -0.08, 0)}, 0.3)

        Window.IslandOpen = false
        Window.Default = "Minimize"
        Utility:TweenObject(TabFrame, {Size = UDim2.new(0, Window.SideBarWidth, 0, 0)}, 0.3, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
        Utility:TweenObject(TabFrame, {BackgroundTransparency = 1}, 0.3, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
        Utility:TweenObject(TabFrame.Frame, {BackgroundTransparency = 1}, 0.3, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
        Utility:TweenObject(LeftScroll, {Size = UDim2.new(1, 0, 0, 0)}, 0.3, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
        Utility:TweenObject(Main.Frame, {Size = UDim2.new(0, Window.Size.X.Offset, 0, 0)}, 0.3, Enum.EasingStyle.Linear, Enum.EasingDirection.Out) --0, Window.Size.X.Offset, 0, Window.Size.Y.Offset-8
        Main.Frame.Visible = false
        Utility:TweenObject(Main, {Size = UDim2.new(0, Window.Size.X.Offset, 0, 0)}, 0.3, Enum.EasingStyle.Linear, Enum.EasingDirection.Out) --UDim2.new(0, Window.Size.X.Offset, 0, Window.Size.Y.Offset)
        Utility:TweenObject(Main, {BackgroundTransparency = 1}, 0.3, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)

        Utility:TweenObject(Island, {Position = UDim2.new(0.5, 0, -0.08, 0)}, 0.3, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
        task.defer(function()
            Utility:TweenObject(Island, {Size = UDim2.new(0, Island.UIListLayout.AbsoluteContentSize.X + 5, 0, 35)}, 0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
            task.wait(0.1)
            Utility:TweenObject(MinzUI, {Size = UDim2.new(0, MinzUI.UIListLayout.AbsoluteContentSize.X + 10, 0, 30)}, 0.3, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
        end)
        task.wait(0.3)
        Main.Visible = false
        MinzUI.Visible = true
    end    

    WinElements.ImageButton.MouseButton1Click:Connect(function()
        if Window.IslandOpen then
            Window:Close()
        end
    end)

    MinzUI.MouseButton1Click:Connect(function()
        if not Window.IslandOpen then
            Window:Open()
        end
    end)

    WinElements.Cross.MouseButton1Click:connect(function()
        Window.IslandOpen = false
        Utility:TweenObject(TabFrame, {Size = UDim2.new(0, Window.SideBarWidth, 0, 0)}, 0.3, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
        Utility:TweenObject(TabFrame, {BackgroundTransparency = 1}, 0.3, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
        Utility:TweenObject(TabFrame.Frame, {BackgroundTransparency = 1}, 0.3, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
        Utility:TweenObject(LeftScroll, {Size = UDim2.new(1, 0, 0, 0)}, 0.3, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
        Utility:TweenObject(Main.Frame, {Size = UDim2.new(0, Window.Size.X.Offset, 0, 0)}, 0.3, Enum.EasingStyle.Linear, Enum.EasingDirection.Out) --0, Window.Size.X.Offset, 0, Window.Size.Y.Offset-8
        Main.Frame.Visible = false
        Utility:TweenObject(Main, {Size = UDim2.new(0, Window.Size.X.Offset, 0, 0)}, 0.3, Enum.EasingStyle.Linear, Enum.EasingDirection.Out) --UDim2.new(0, Window.Size.X.Offset, 0, Window.Size.Y.Offset)
        Utility:TweenObject(Main, {BackgroundTransparency = 1}, 0.3, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
        task.wait(0.3)
        UIScreen:Destroy()
    end)

    function Window:Destroy()
        Window.IslandOpen = false
        Utility:TweenObject(TabFrame, {Size = UDim2.new(0, Window.SideBarWidth, 0, 0)}, 0.3, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
        Utility:TweenObject(TabFrame, {BackgroundTransparency = 1}, 0.3, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
        Utility:TweenObject(TabFrame.Frame, {BackgroundTransparency = 1}, 0.3, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
        Utility:TweenObject(LeftScroll, {Size = UDim2.new(1, 0, 0, 0)}, 0.3, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
        Utility:TweenObject(Main.Frame, {Size = UDim2.new(0, Window.Size.X.Offset, 0, 0)}, 0.3, Enum.EasingStyle.Linear, Enum.EasingDirection.Out) --0, Window.Size.X.Offset, 0, Window.Size.Y.Offset-8
        Main.Frame.Visible = false
        Utility:TweenObject(Main, {Size = UDim2.new(0, Window.Size.X.Offset, 0, 0)}, 0.3, Enum.EasingStyle.Linear, Enum.EasingDirection.Out) --UDim2.new(0, Window.Size.X.Offset, 0, Window.Size.Y.Offset)
        Utility:TweenObject(Main, {BackgroundTransparency = 1}, 0.3, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
        task.wait(0.3)
        UIScreen:Destroy()
    end

    local TogValue = true
    game:GetService("UserInputService").InputBegan:Connect(function(input, i)
        if not i then
            if input.KeyCode == Window.ToggleKey then
                if not Window.IslandOpen then
                    Window:Open()
                else
                    Window:Close()
                end
            end
        end
    end)

    function Window:SetToggleKey(Value)
        Window.ToggleKey = Value
        return Window
    end

    function Window:SetTitle(v)
        LibName.Text = v
    end
    function Window:SetAuthor(v)
        LibName.LibAuthor = v
    end
    function Window:ToCenter()
        Utility:TweenObject(Main, {Position = UDim2.new(0.5,0,0.5,0)}, 0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
    end
    function Window:SetTransparency(Value)
        Utility:TweenObject(Main, {Transparency = Value and 0.1 or 0}, 0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
        Utility:TweenObject(TabFrame, {Transparency = Value and 1 or 0}, 0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
        Utility:TweenObject(TabFrame.Frame, {Transparency = Value and 1 or 0}, 0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
        return Window
    end
    UI.Window = Window
    return Window
end

function UI:Notification(Config)
    coroutine.wrap(function()
        local Notification = {
            Title = Config.Title or "Notification",
            Desc = Config.Desc or nil,
            Icon = Config.Icon or nil,
            Duration = Config.Duration or 5,
            Interactive = Config.Interactive
        }

        local NotifFrame = VexUI:Create("Frame", {
            Parent = Island,
            BackgroundColor3 = Color3.fromRGB(20, 20, 20),
            BackgroundTransparency = 0.2,
            BorderSizePixel = 0,
            ClipsDescendants = true,
            LayoutOrder = 2,
            Size = UDim2.new(0, 0, 0, 30),
            ZIndex = 150,
            ThemeID = { BackgroundColor3 = "SideBar"}
        }, {
            VexUI:Create("UICorner", { CornerRadius = UDim.new(0, 12) }),
            VexUI:Create("UIPadding", { PaddingTop = UDim.new(0, 9) }),
            VexUI:Create("UIStroke", {
                LineJoinMode = "Round",
                Thickness = 0.6,
                ThemeID = {
                    Color = "Outline"
                }
            }, {
                VexUI:Create("UIGradient", {
                    Color = ColorSequence.new(
                        Color3.fromRGB(255, 255, 255),
                        Color3.fromRGB(255, 255, 255)
                    ),
                    Transparency = NumberSequence.new({
                        NumberSequenceKeypoint.new(0, 0.1),
                        NumberSequenceKeypoint.new(0.5, 1),
                        NumberSequenceKeypoint.new(1, 1)
                    }),
                    Rotation = -100
                })
            }),
        })

        local Title = CreateRichIconText(NotifFrame, Notification.Title, {
            Size = UDim2.new(1, 0, 1, 0),
            AutomaticSize = "X",
            ZIndex = 16,
            FontFace = Font.new([[rbxassetid://12187365364]], Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
            TextSize = 11,
            TextColor3 = Color3.fromRGB(255, 255, 255),
            RichText = true,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 151,
            ThemeID = { TextColor3 = "Text" }
        }, {
            VexUI:Create("UIPadding", { PaddingLeft = UDim.new(0, 33) })
        })

        local Desc
        if Notification.Desc then
            Title.UIPadding.PaddingBottom = UDim.new(0, 12)
            Desc = CreateRichIconText(NotifFrame, Notification.Desc, {
                Size = UDim2.new(1, 0, 1, 0),
                AutomaticSize = "X",
                ZIndex = 16,
                FontFace = Font.new([[rbxassetid://12187365364]], Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
                TextSize = 10,
                TextColor3 = Color3.fromRGB(255, 255, 255),
                RichText = true,
                TextTransparency = 0.3,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 151,
                ThemeID = { TextColor3 = "Text" }
            }, {
                VexUI:Create("UIPadding", { PaddingLeft = UDim.new(0, 33),PaddingTop = UDim.new(0, 10)})
            })

        end
    local Icon
    if Notification.Icon then
        local Icon = VexUI:Create("ImageLabel", {
            AnchorPoint = Vector2.new(0, 0.5),
            --Image = IconsV2.GetIcon(Window.Icon),
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 7, 0.3, 0),
            Size = UDim2.new(0, 20, 0, 20),
            ZIndex = 150,
            Parent = NotifFrame,
            ThemeID = {
                ImageColor3 = "Notification.Icon|IconColor"
            }
        })
        if Notification.Icon and IconsV2.Icon(Notification.Icon) then
            Icon.Image = IconsV2.GetIcon(Notification.Icon)
        elseif Notification.Icon and string.find(Notification.Icon, "rbxassetid://") then
            Icon.Image = Notification.Icon
        end
    end
        activeNotifs += 1
        UI.Notifications = activeNotifs
        if UI.Window and (UI.Window.IslandOpen or UI.IslandOpen) and UI.Window.Default == "Default" then
            Utility:TweenObject(Island, {Position = UDim2.new(0.5, 0, -0.08, 0)}, 0.3)
        else
            Utility:TweenObject(Island, {Position = UDim2.new(0.5, 0, -0.08, 0)}, 0.3)
        end

    local NotifDelay = VexUI:Create("Frame", {
        Parent = NotifFrame,
        ClipsDescendants = true,
        AnchorPoint = Vector2.new(0,1),
        Position = UDim2.new(0, 16, 1, 0),
        Size = UDim2.new(0, 0, 0, 1),
        ZIndex = 155,
        ThemeID = { BackgroundColor3 = "Text"}
    }, {
        VexUI:Create("UICorner", { CornerRadius = UDim.new(0, 16) }),
    })

    NotifFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            Utility:TweenObject(NotifFrame, {Size = UDim2.new(0, 0, 0, 30)}, 0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
            activeNotifs -= 1
            UI.Notifications = activeNotifs

            if UI.Window and (UI.Window.IslandOpen or UI.IslandOpen) and UI.Window.Default == "Default" then
                Utility:TweenObject(Island, {Position = UDim2.new(0.5, 0, -0.08, 0)}, 0.3)
            else
                Utility:TweenObject(Island, {Position = UDim2.new(0.5, 0, -0.08, 0)}, 0.3)
            end
            if activeNotifs == 0 then
                if UI.Window and (UI.Window.IslandOpen or UI.IslandOpen) and UI.Window.Default == "Default" then
                    Utility:TweenObject(Island, {Position = UDim2.new(0.5, 0, -0.2, 0)}, 0.3)
                else
                    Utility:TweenObject(Island, {Position = UDim2.new(0.5, 0, -0.08, 0)}, 0.3)
                end
            end
            task.wait(0.3)
            NotifFrame:Destroy()
        end
    end)

    --[[local NotifFrame1 = VexUI:Create("Frame", {
        Parent = NotifFrame,
        BackgroundTransparency = 0.1,
        BorderSizePixel = 0,
        LayoutOrder = 2,
        ClipsDescendants = true,
        AnchorPoint = Vector2.new(0,0),
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(1, 0, 1, 0),
        ZIndex = 120,
        ThemeID = { BackgroundColor3 = "Background"}
    }, {
        VexUI:Create("UICorner", { CornerRadius = UDim.new(0, 12) }),
    })

    NotifFrame.MouseEnter:connect(function()
        Utility:TweenObject(NotifFrame1, {Size = UDim2.new(0, 150, 0, 100)}, 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        Utility:TweenObject(NotifFrame1, {Position = UDim2.new(0, 0, 0, 28)}, 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    end)

    NotifFrame.MouseLeave:connect(function()
        Utility:TweenObject(NotifFrame1, {Size = UDim2.new(1, 0, 1, 0)}, 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        Utility:TweenObject(NotifFrame1, {Position = UDim2.new(0, 0, 0, 0)}, 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    end)--]]  -- Soon :>

        Utility:TweenObject(NotifFrame, {Size = UDim2.new(0, 150, 0, 30)}, 0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        coroutine.wrap(function()
            Utility:TweenObject(NotifDelay, {Size = UDim2.new(0, 118, 0, 1)}, 0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
            task.wait(0.5)
            Utility:TweenObject(NotifDelay, {Size = UDim2.new(0, 0, 0, 1)}, Notification.Duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        end)()
        task.wait(Notification.Duration)
        Utility:TweenObject(NotifFrame, {Size = UDim2.new(0, 0, 0, 30)}, 0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

        activeNotifs -= 1
        UI.Notifications = activeNotifs

        task.wait(0.05)

        if activeNotifs == 0 then
            if UI.Window and (UI.Window.IslandOpen or UI.IslandOpen) and UI.Window.Default == "Default" then
                Utility:TweenObject(Island, {Position = UDim2.new(0.5, 0, -0.2, 0)}, 0.3)
                --Utility:TweenObject(Title, {TextTransparency = 1}, 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
                --Utility:TweenObject(Desc, {TextTransparency = 1}, 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
                --Utility:TweenObject(Icon, {ImageTransparency = 1}, 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
            else
                Utility:TweenObject(Island, {Position = UDim2.new(0.5, 0, -0.08, 0)}, 0.3)
            end
        end
        task.wait(0.3)
        NotifFrame:Destroy()
    end)()
end

return UI


--[[local Window = UI:CreateWindow({
    Name = "VexUI Example",
    Icon = "door-open",
    SideBarWidth = 160,
    Theme = "ExDark",
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

UI:CreateTopbarButton({
    Order = 4,
    Callback = function()
        print("Pisun")
    end
})
UI:CreateTopbarToggle({
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
        UI:Notification({
        Title = "Title",
        Icon = "bird",
        Desc = "Hui",
        Duration = 5
        })
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
        UI:Notification({
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
        UI:Notification({
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
