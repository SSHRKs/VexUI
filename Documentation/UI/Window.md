```luau
local Window = UI:CreateWindow({
    Name = "VexUI Example",
    Icon = "bird",
    Author = "By .s.h.ark."
})
```

```luau
UI:CreateTopbarToggle({
    Order = 4,
    EnableIcon = "banana",
    DisableIcon = "at-sign",
    Default = true,
    EnableBackground = Color3.fromRGB(155, 25, 25),
    Callback = function(Value)
        print(Value)
    end
})
```
