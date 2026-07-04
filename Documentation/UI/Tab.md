## Creating Tab
```lua
local Tab = Window:Tab({
    Title = "Tab",
    Icon = "bird",
    Border = true,
})
```

## Creating Section
```lua
local Section = Window:Section({
    Title = "Other",
    Icon = "hash",
    Opened = true,
})
local Tab = Section:Tab({Title = "Tab"})
```
