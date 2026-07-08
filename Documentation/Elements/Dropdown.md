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
## Properties
- `Title = string`
- `Desc = string`
- `Multi = bool`
- `Callback = function`
- `Option = table`
- `Value = string`
- `Callback = function()`
## Methods
- `:SetTitle('New Title')`
- `:SetDesc('New Desc')`
- `:Refresh({"New Option 1", "New Option 2"})`
- `:Close()`
