
const ICONS = {
  doc: `<rect x="5" y="3" width="14" height="18" rx="2"/><path d="M8 8h8M8 12h8M8 16h5"/>`,
  download: `<path d="M12 3v12"/><path d="m7 10 5 5 5-5"/><path d="M5 21h14"/>`,
  palette: `<circle cx="12" cy="12" r="9"/><circle cx="9" cy="10" r="1.2"/><circle cx="12" cy="7.5" r="1.2"/><circle cx="15" cy="10" r="1.2"/><circle cx="12" cy="14.5" r="1.2"/>`,
  window: `<rect x="3" y="4" width="18" height="16" rx="2"/><path d="M3 9h18"/>`,
  key: `<circle cx="7.5" cy="12" r="3.2"/><path d="M10.5 12h9.5M16.5 12v3.2M19.5 12v3.2"/>`,
  layers: `<path d="M12 3 3 8l9 5 9-5-9-5Z"/><path d="M3 14l9 5 9-5"/>`,
  message: `<rect x="3" y="4" width="18" height="13" rx="2"/><path d="m7 17-2 4 5-4"/>`,
  bell: `<path d="M6 10a6 6 0 0 1 12 0c0 5 2 6 2 6H4s2-1 2-6Z"/><path d="M10 20a2 2 0 0 0 4 0"/>`,
  folder: `<path d="M3 6a2 2 0 0 1 2-2h4l2 2h8a2 2 0 0 1 2 2v10a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V6Z"/>`,
  square: `<rect x="4" y="4" width="16" height="16" rx="3"/>`,
  pointer: `<path d="M4 4l7 16 2-7 7-2L4 4Z"/>`,
  toggle: `<rect x="2" y="7" width="20" height="10" rx="5"/><circle cx="16" cy="12" r="3"/>`,
  sliders: `<circle cx="8" cy="7" r="2"/><path d="M2 7h4M12 7h10"/><circle cx="16" cy="14" r="2"/><path d="M2 14h12M20 14h2"/><circle cx="10" cy="19" r="2"/><path d="M2 19h6M14 19h8"/>`,
  cursor: `<path d="M9 4v16M15 4v16"/>`,
  chevronBox: `<rect x="3" y="5" width="18" height="14" rx="2"/><path d="m9 11 3 3 3-3"/>`,
  keyboard: `<rect x="2" y="6" width="20" height="12" rx="2"/><path d="M6 10h.01M10 10h.01M14 10h.01M18 10h.01M6 14h12"/>`,
  columns: `<rect x="3" y="4" width="8" height="16" rx="2"/><rect x="13" y="4" width="8" height="16" rx="2"/>`,
  italic: `<line x1="19" y1="4" x2="10" y2="4"/><line x1="14" y1="20" x2="5" y2="20"/><line x1="15" y1="4" x2="9" y2="20"/>`,
};

function icon(name, size = 15){
  return `<svg width="${size}" height="${size}" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">${ICONS[name] || ICONS.square}</svg>`;
}

const NAV = [
  {
    title: "Setup",
    items: [
      { id: "loadstring", title: "Loadstring", icon: "download" },
      { id: "themes", title: "Themes", icon: "palette" },
    ]
  },
  {
    title: "UI",
    items: [
      { id: "window", title: "Window", icon: "window" },
      { id: "tab", title: "Tab", icon: "layers" },
      { id: "dialog", title: "Dialog", icon: "message" },
      { id: "notification", title: "Notification", icon: "bell" },
    ]
  },
  {
    title: "Elements",
    items: [
      { id: "section", title: "Section", icon: "square" },
      { id: "button", title: "Button", icon: "pointer" },
      { id: "toggle", title: "Toggle", icon: "toggle" },
      { id: "paragraph", title: "Paragraph", icon: "italic" },
      { id: "slider", title: "Slider", icon: "sliders" },
      { id: "input", title: "Input", icon: "cursor" },
      { id: "dropdown", title: "Dropdown", icon: "chevronBox" },
      { id: "keybind", title: "Keybind", icon: "keyboard" },
    ]
  }
];

const FLAT_PAGES = NAV.flatMap(g => g.items.map(i => ({ ...i, group: g.title })));

function highlightLua(src){
  src = src
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;");

  const KEYWORDS = "local|function|end|then|else|elseif|if|return|true|false|nil|and|or|not|for|in|do|while|repeat|until|break";
  const TOKEN = new RegExp(
    `(--.*)` +
    `|("(?:[^"\\\\]|\\\\.)*"|'(?:[^'\\\\]|\\\\.)*')` +
    `|\\b(${KEYWORDS})\\b` +                      
    `|\\b(\\d+(?:\\.\\d+)?)\\b` +                 
    `|\\b([A-Za-z_][A-Za-z0-9_.]*)(?=\\()` +  
    `|\\b([A-Za-z_][A-Za-z0-9_]*)\\b(?=\\s*=(?!=))`,
    "g"
  );

  return src.replace(TOKEN, (m, com, str, kw, num, fn, prop) => {
    if (com !== undefined) return `<span class="c-com">${com}</span>`;
    if (str !== undefined) return `<span class="c-str">${str}</span>`;
    if (kw  !== undefined) return `<span class="c-key">${kw}</span>`;
    if (num !== undefined) return `<span class="c-num">${num}</span>`;
    if (fn  !== undefined) return `<span class="c-fn">${fn}</span>`;
    if (prop!== undefined) return `<span class="c-prop">${prop}</span>`;
    return m;
  });
}

function code(lang, raw){
  return `<div class="code-block"><div class="code-head"><span>${lang}</span><span class="copy-btn" onclick="copyCode(this)">Copy</span></div><pre>${highlightLua(raw)}</pre></div>`;
}

function widgetRow(iconName, title, desc, controlHtml){
  return `<div class="widget-row">
    <div class="wr-left">
      <div class="wr-icon">${icon(iconName, 14)}</div>
      <div>
        <div class="wr-title">${title}</div>
        <div class="wr-desc">${desc}</div>
      </div>
    </div>
    ${controlHtml}
  </div>`;
}
function ctlToggle(on){ return `<div class="ctl-toggle ${on?'on':''}"></div>`; }
function ctlSlider(pct){ return `<div class="ctl-slider"><span style="left:${pct}%"></span></div>`; }
function ctlChip(text){ return `<div class="ctl-chip">${text}${icon('chevronBox',12)}</div>`; }
function preview(rowsHtml){
  return `<div class="ui-mock" style="margin:18px 0;"><div class="ui-mock-body">${rowsHtml}</div></div>`;
}
function bulletList(items){
  return `<ul class="bullet-list">${items.map(i => `<li><code>${i}</code></li>`).join('')}</ul>`;
}

// Segmented pill switcher for alternate code examples, e.g.
// codeTabs('window-ex', [
//   { label: "Basic", code: `...` },
//   { label: "Full",  code: `...` },
// ])
let codeTabsCount = 0;
function codeTabs(variants){
  const id = `ct-${++codeTabsCount}`;
  const buttons = variants.map((v, i) =>
    `<button class="seg-btn ${i===0?'active':''}" onclick="switchCodeTab('${id}', ${i}, this)">${v.label}</button>`
  ).join('');
  const blocks = variants.map((v, i) =>
    `<div class="code-variant" data-idx="${i}" style="${i===0?'':'display:none'}">${code('lua', v.code)}</div>`
  ).join('');
  return `<div class="code-tabs" id="${id}">
    <div class="segmented">${buttons}</div>
    ${blocks}
  </div>`;
}

const PAGES = {
  loadstring: {
    title: "Loadstring",
    subtitle: "Load VexUI",
    html: `
      <h2>Basic usage</h2>
      <p>VexUI is distributed as a single Luau module hosted on GitHub. Load it with a standard <code>loadstring</code> call:</p>
      ${code("lua", `local VexUI = loadstring(game:HttpGet("https://github.com/SSHRKs/VexUI/releases/latest/download/main.lua"))()`)}

      <h2>Pinning a version</h2>
      <p>For production scripts, pin a release tag instead of <code>main</code> so updates can't break your interface without warning:</p>
      ${code("lua", `local Version = "1.0.3"
    local VexUI = loadstring(game:HttpGet("https://github.com/SSHRKs/VexUI/releases/download/".. Version .."/main.lua"))()`)}
    `
  },

  themes: {
    title: "Themes",
    subtitle: "",
    html: `
      <h2>Set theme</h2>
      ${code("lua", `Window:SetTheme("Dark")`)}
      <h2>Or Window</h2>
      ${code("lua", `local Window = VexUI:CreateWindow({
    Theme = "Dark",`)}
      ${codeTabs([
        {
          label: "Basic",
          code: `VexUI:AddTheme({
  Name = "Dark",
  Background = Color3.fromRGB(20, 20, 20),
  SideBar = Color3.fromRGB(28, 28, 28),
  Text = Color3.fromRGB(255, 255, 255),
  ElementColor = Color3.fromRGB(42, 42, 42),
  Outline = Color3.fromRGB(62, 62, 62),
  Placeholder = Color3.fromRGB(20, 20, 20),
  IconColor = Color3.fromRGB(255, 255, 255),
})`
        },
        {
          label: "Advanced",
          code: `VexUI:AddTheme({
  Name = "Dark",
  Background = Color3.fromRGB(20, 20, 20),
  SideBar = Color3.fromRGB(28, 28, 28),
  Text = Color3.fromRGB(255, 255, 255),
  ElementColor = Color3.fromRGB(42, 42, 42),
  Outline = Color3.fromRGB(62, 62, 62),
  Placeholder = Color3.fromRGB(20, 20, 20),
  IconColor = Color3.fromRGB(255, 255, 255),
  Search = {
    Background = nil,
    Text = nil,
    IconColor = nil,
  },
  Tab = {
    Background = Color3.fromRGB(50, 50, 50),
    Text = nil,
    IconColor = nil
  },
  Paragraph = {
    Background = nil,
    Text = nil,
    Icon = nil,
  },
  Button = {
    Background = nil,
    Text = nil,
    Icon = nil,
  },
  Toggle = {
    Background = nil,
    Placeholder = Color3.fromRGB(20, 20, 20),
    Text = nil,
    ToggleVal = Color3.fromRGB(255, 255, 255),
  },
  Slider = {
    Background = nil,
    Placeholder = Color3.fromRGB(20, 20, 20),
    Text = nil,
    SliderPart = Color3.fromRGB(255, 255, 255),
  },
  Input = {
    Background = nil,
    Placeholder = Color3.fromRGB(20, 20, 20),
    Text = nil,
  },
  Keybind = {
  Background = nil,
  Placeholder = nil,
  Text = nil,
  }
})`
        },
      ])}


      <h2>Themes</h2>
      <table class="ptable">
        <tr><th>Available Themes</th></tr>
        <tr><td>Dark</td></tr>
        <tr><td>Light</td></tr>
        <tr><td>Forest</td></tr>
      </table>
    `
  },

  window: {
    title: "Window",
    subtitle: "",
    html: `
      <h2>Creating a window</h2>
      ${codeTabs([
        {
          label: "Basic",
          code: `local Window = VexUI:CreateWindow({
    Name = "Super Pisun",
    Icon = "door-open",
    Theme = "Dark",
})`
        },
        {
          label: "Full",
          code: `local Window = VexUI:CreateWindow({
    Name = "Super Pisun",
    Icon = "door-open",
    SideBarWidth = 160,
    Theme = "Dark",
    Folder = "FolderName",
    Transparent = true,
    ToggleKey = Enum.KeyCode.F,
    Size = UDim2.new(0, 480, 0, 360),
    Author = "By .s.h.ark.",
    User = {
        Enabled = true,
        Anonymous = true,
    },
    KeySystem = {
        Title = "Super Pisun",
        Desc = "Key Desc",
        KeyValidator = function(key)
            return key == "1234"
        end,
        URL = "1234", --LINK TO GET KEY
    },
})`
        },
      ])}
      <h2>Creating TopBar Button / Toggle</h2>
      ${codeTabs([
        {
          label: "Button",
          code: `VexUI:CreateTopbarButton({
    Order = 4,
    Icon = "bird",
    Callback = function()
        print("Pisun")
    end
})`
        },
        {
          label: "Toggle",
          code: `VexUI:CreateTopbarToggle({
    Order = 4,
    EnableIcon = "banana",
    DisableIcon = "at-sign",
    Default = true,
    EnableBackground = Color3.fromRGB(155, 25, 25),
    Callback = function(Value)
        print(Value)
    end
})`
        },
      ])}

      <h2>Methods</h2>
      ${bulletList([
        ":SetTitle('New Name')",
        ":SetAuthor('New Author')",
        ":ToCenter()",
        ":SetTransparency(false)",
        ":SetTheme('Dark')",
        ":GetTheme()",
        ":SetToggleKey(Enum.KeyCode.F)",
        ":Destroy()",
        ":Open()",
        ":Close()",
      ])}
      <h2>User Methods</h2>
      ${bulletList([
        ":UserEnabled(true)",
        ":Anonymous(true)",
      ])}
    `
  },

  tab: {
    title: "Tab",
    subtitle: "",
    html: `
      <h2>Creating a tab</h2>
      ${code("lua", `local Tab = Window:Tab({
    Title = "Tab",
    Icon = "bird",
    Border = true,
})`)}
      <h2>Creating Section</h2>
      ${code("lua", `local Section = Window:Section({
    Title = "Other",
    Icon = "hash",
    Opened = true,
})
local Tab = Section:Tab({Title = "Tab"})`)}
    `
  },

  dialog: {
    title: "Dialog",
    subtitle: "",
    html: `
      <h2>Basic dialog</h2>
      ${code("lua", `VexUI:Dialog({
    Title = "Dialog Title",
    Desc = "Dialog Description",
    --Image = "rbxassetid://14309518613",
    Buttons = {
        {Text = "Button 1", Callback = function() print("Button 1") end},
        {Text = "Button 2", Callback = function() print("Button 2") end},
    }
})`)}
    `
  },

  notification: {
    title: "Notification",
    subtitle: "",
    html: `
      <h2>Sending a notification</h2>
      ${code("lua", `VexUI:Notification({
    Title = "Title",
    Icon = "bird",
    Desc = "Pisun",
    Duration = 5
})`)}
    `
  },

  section: {
    title: "Section",
    subtitle: "",
    html: `
      <h2>Creating a section</h2>
      ${code("lua", `local Section = Tab:Section({
    Title = "Section",
    Icon = "bird",
    TextSize = 18,
})`)}
      `
  },

  button: {
    title: "Button",
    subtitle: "A single-action control.",
    html: `
      ${code("lua", `local Button = Tab:Button({
    Title = "Button",
    Desc = "This is a button",
    Callback = function()
        print("Hello Pisun")
    end
})`)}
      <h2>Properties</h2>
      <table class="ptable">
        <tr><th>Name</th><th>Type</th></tr>
        <tr><td>Title</td><td>string</td></tr>
        <tr><td>Desc</td><td>string</td></tr>
        <tr><td>Callback</td><td>function()</td></tr>
      </table>
      <h2>Methods</h2>
      ${bulletList([
        ":SetTitle('New Title')",
        ":SetDesc('New Desc')",
        ":Close()",
      ])}
    `
  },

  toggle: {
    title: "Toggle",
    subtitle: "A two-state boolean switch.",
    html: `
      ${code("lua", `local Toggle = Tab:Toggle({
    Title = "Toggle",
    Desc = "This is a toggle",
    Default = false,
    Callback = function(status)
        print(status)
    end
})`)}
      <h2>Properties</h2>
      <table class="ptable">
        <tr><th>Name</th><th>Type</th></tr>
        <tr><td>Title</td><td>string</td></tr>
        <tr><td>Desc</td><td>string</td></tr>
        <tr><td>Default</td><td>bool</td></tr>
        <tr><td>Callback</td><td>function()</td></tr>
      </table>
      <h2>Methods</h2>
      ${bulletList([
        ":SetTitle('New Title')",
        ":SetDesc('New Desc')",
        ":SetValue(true)",
        ":Close()",
      ])}
    `
  },

  paragraph: {
    title: "Paragraph",
    subtitle: "",
    html: `
      ${codeTabs([
        {
          label: "Basic",
          code: `local Paragraph = Tab:Paragraph({
    Title = "Paragraph",
    Desc = "This is a Paragraph",
    Icon = "bird"
})`
        },
        {
          label: "Full",
          code: `local Paragraph = Tab:Paragraph({
    Title = "Paragraph",
    Desc = "This is a Paragraph",
    Icon = "bird",
    Color = "red",
    Thumbnail = "",
    ThumbnailSize = 90,
})`
        },
      ])}

      <h2>Properties</h2>
      <table class="ptable">
        <tr><th>Name</th><th>Type</th></tr>
        <tr><td>Title</td><td>string</td></tr>
        <tr><td>Desc</td><td>string</td></tr>
        <tr><td>Icon</td><td>string</td></tr>
        <tr><td>Color</td><td>string</td></tr>
        <tr><td>Thumbnail</td><td>string</td></tr>
        <tr><td>ScaleType</td><td>string</td></tr>
        <tr><td>ThumbnailSize</td><td>number</td></tr>
      </table>
      <h2>Methods</h2>
      ${bulletList([
        ":SetTitle('New Title')",
        ":SetDesc('New Desc')",
        ":Close()",
      ])}
    `
  },

  slider: {
    title: "Slider",
    subtitle: "A bounded numeric input.",
    html: `
      ${code("lua", `local Slider = Tab:Slider({
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
})`)}
      <h2>Properties</h2>
      <table class="ptable">
        <tr><th>Name</th><th>Type</th></tr>
        <tr><td>Title</td><td>string</td></tr>
        <tr><td>Desc</td><td>string</td></tr>
        <tr><td>Value.Min</td><td>number</td></tr>
        <tr><td>Value.Max</td><td>number</td></tr>
        <tr><td>Value.Default</td><td>number</td></tr>
        <tr><td>Step</td><td>string</td></tr>
        <tr><td>Callback</td><td>function()</td></tr>
      </table>
      <h2>Methods</h2>
      ${bulletList([
        ":SetTitle('New Title')",
        ":SetDesc('New Desc')",
        ":SetValue(220)",
        ":Close()",
      ])}
    `
  },

  input: {
    title: "Input",
    subtitle: "A single-line text field with an optional character counter.",
    html: `
      ${code("lua", `local Input = Tab:Input({
    Title = "Input",
    Desc = "This is an input",
    --MaxSymbols = 10,
    Callback = function(input)
        print(input)
    end
})`)}
      <h2>Properties</h2>
      <table class="ptable">
        <tr><th>Name</th><th>Type</th></tr>
        <tr><td>Title</td><td>string</td></tr>
        <tr><td>Desc</td><td>string</td></tr>
        <tr><td>MaxSymbols</td><td>number</td></tr>
        <tr><td>Callback</td><td>function()</td></tr>
      </table>
      <h2>Methods</h2>
      ${bulletList([
        ":SetTitle('New Title')",
        ":SetDesc('New Desc')",
        ":SetMaxSymbols(999)",
        ":SetValue('New Value')",
        ":Close()",
      ])}
    `
  },

  dropdown: {
    title: "Dropdown",
    subtitle: "Single or multi-select list, with search.",
    html: `
      ${code("lua", `local Dropdown = Tab:Dropdown({
	Title = "Dropdown",
  Desc = "This is a dropdown",
	Multi = false,
	Option = {"Option 1", "Option 2", "Option 3",},
	Value = "Option 1",
	Callback = function(option)
	  print(option)
	end
})`)}
      <h2>Properties</h2>
      <table class="ptable">
        <tr><th>Name</th><th>Type</th></tr>
        <tr><td>Title</td><td>string</td></tr>
        <tr><td>Desc</td><td>string</td></tr>
        <tr><td>Multi</td><td>bool</td></tr>
        <tr><td>Option</td><td>table</td></tr>
        <tr><td>Value</td><td>string</td></tr>
        <tr><td>Callback</td><td>function()</td></tr>
      </table>
      <h2>Methods</h2>
      ${bulletList([
        ":SetTitle('New Title')",
        ":SetDesc('New Desc')",
        ":Refresh({'New Option 1', 'New Option 2'}",
        ":Close()",
      ])}
    `
  },

  keybind: {
    title: "Keybind",
    subtitle: "Captures a key or mouse button as a hotkey.",
    html: `
      ${code("lua", `local Keybind = Tab:Keybind({
    Title = "Keybind",
    Callback = function(key)
        print(key)
    end
})`)}
      <h2>Properties</h2>
      <table class="ptable">
        <tr><th>Name</th><th>Type</th></tr>
        <tr><td>Title</td><td>string</td></tr>
        <tr><td>Desc</td><td>string</td></tr>
        <tr><td>Value</td><td>string</td></tr>
        <tr><td>Callback</td><td>function()</td></tr>
      </table>
      <h2>Methods</h2>
      ${bulletList([
        ":SetTitle('New Title')",
        ":SetDesc('New Desc')",
        ":SetValue('F')",
        ":Close()",
      ])}
    `
  },
};
