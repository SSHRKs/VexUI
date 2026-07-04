## Creating Dropdown
```lua
local Dropdown = Tab:Dropdown({
	Title = "Dropdown",
  Desc = "This is a dropdown",
	Multi = false,
	Option = {"Option 1", "Option 2", "Option 3",},
	Value = "Option 1",
	Callback = function(option)
		print(option)
	end
})
```

## Set Title
```lua
Dropdown:SetTitle('New Title')
```
## Set Desc
```lua
Dropdown:SetDesc('New Desc')
```
## Refresh Option
```lua
Dropdown:Refresh({"New Option 1", "New Option 2"})
```
## Destroy Element
```lua
Dropdown:Close()
```
