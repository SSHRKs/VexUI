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
## Methods
- `:SetTitle('New Title')`
- `:SetDesc('New Desc')`
- `:Close()`

## Set Title
```lua
Paragraph:SetTitle('New Title')
```
## Set Desc
```lua
Paragraph:SetDesc('New Desc')
```
## Destroy Element
```lua
Paragraph:Close()
```
