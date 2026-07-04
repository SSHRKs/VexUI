local Slider = Tab:Slider({
    Title = "Slider",
    Desc = "This is a slider",
    Value = {
        Min = 0,
        Max = 100,
        Default = 25,
    },
    Step = 1,
    Callback = function(value)
        print(value)
    end
})
