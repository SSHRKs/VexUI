```luau
local Window = UI:CreateWindow({
    Name = "VexUI Example",
    Icon = "bird",
    Author = "By .s.h.ark."
})
```

```luau
UI:CreateTopbarToggle({ --TOGGLE
    Order = 4,
    EnableIcon = "banana",
    DisableIcon = "at-sign",
    Default = true,
    EnableBackground = Color3.fromRGB(155, 25, 25),
    Callback = function(Value)
        print(Value)
    end
})

UI:CreateTopbarButton({ --BUTTON
    Order = 4,
    Callback = function()
        print("Pisun")
    end
})
```
