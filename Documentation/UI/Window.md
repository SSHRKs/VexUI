```luau
local Window = UI:CreateWindow({
    Name = "VexUI Example",
    Icon = "bird",
    Author = "By .s.h.ark."
})
```

```luau
UI:CreateTopbarButton({
    Order = 4,
    Callback = function()
        print("Pisun")
    end
})
```
