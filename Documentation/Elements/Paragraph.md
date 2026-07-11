```lua
local Paragraph = Tab:Paragraph({
    Title = "Paragraph",
    Desc = "This is a Paragraph",
    Icon = "bird"
})
```
## Properties
- `Title = string`
- `Desc = string`
- `Color = string`
- `Thumbnail = string`
- `ScaleType = string`
- `ThumbnailSize = number`
## Methods
- `:SetTitle('New Title')`
- `:SetDesc('New Desc')`
- `:Close()`

## Dedault Colors
```lua
Red    = Color3.fromRGB(255, 45, 85),
Green  = Color3.fromRGB(52, 255, 130),
Blue   = Color3.fromRGB(64, 156, 255),
Orange = Color3.fromRGB(255, 159, 10),
Purple = Color3.fromRGB(191, 90, 255),
Yellow = Color3.fromRGB(255, 224, 20),
Pink   = Color3.fromRGB(255, 55, 130),
Cyan   = Color3.fromRGB(50, 220, 255),
Mint   = Color3.fromRGB(50, 255, 200),
Coral  = Color3.fromRGB(255, 100, 60),
 ```
 ## Custom Color
 ```lua
local Paragraph = Tab:Paragraph({
    Title = "Paragraph",
    Color = Color3.fromRGB(73, 182, 255),
})
 ```
