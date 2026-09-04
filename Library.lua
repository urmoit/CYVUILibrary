--[[
    CYVUI Library v1.1.0 — Redesign
    Ironite-inspired layout: header + 75px sidebar + subtab row + two-column page
    Home + Settings share the same dashboard structure across hubs
    
    Public API:
      Library:CreateWindow(opts) -> Window
      Library:Notify(title, body, duration, kind?) -> nil
      Library:SetTheme(accent, accent2?) -> nil
      Library:GetFlag(name) -> any
      Library:SetFlag(name, value) -> nil
      Library:GetIcon(name) -> string
    
    Window:SetHeader(libraryName, libraryTag, updatedText?) -> nil
    Window:SetTitle(libraryName, libraryTag, updatedText?) -> nil  (alias)
    
    Window:CreateTab(opts) -> Tab
    Tab:AddSubtab(name) -> Subtab
    Tab:CreateHomeLayout(opts) -> HomeRefs
    Tab:CreateSettingsLayout(opts?) -> nil
    
    Subtab:CreateSection(name, opts?) -> Section
    Subtab:Select() -> nil
    
    Section:AddToggle, AddSlider, AddDropdown, AddTextbox, AddKeybind,
             AddColorPicker, AddButton, AddLabel, AddParagraph
]]

local Players          = game:GetService("Players")
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService       = game:GetService("RunService")
local HttpService      = game:GetService("HttpService")
local CoreGui          = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer

local Library = {
    Version     = "1.1.0",
    Name        = "CYVUI",
    Windows     = {},
    Flags       = {},
    Theme       = {},
    _Lucide     = nil,
}

-- ═══════════════════════════════════════════
-- THEME — Ironite-inspired palette
-- ═══════════════════════════════════════════
Library.Theme = {
    Background    = Color3.fromRGB(19, 20, 25),
    Sidebar       = Color3.fromRGB(19, 20, 25),
    Page          = Color3.fromRGB(16, 17, 21),
    Panel         = Color3.fromRGB(17, 18, 22),
    SectionHdr    = Color3.fromRGB(19, 20, 25),
    Input         = Color3.fromRGB(24, 25, 32),
    Border        = Color3.fromRGB(28, 30, 38),
    Liner         = Color3.fromRGB(31, 31, 45),
    Accent        = Color3.fromRGB(254, 254, 254),
    AccentDim     = Color3.fromRGB(147, 147, 147),
    Inactive      = Color3.fromRGB(69, 71, 90),
    Muted         = Color3.fromRGB(204, 204, 209),
    Text          = Color3.fromRGB(254, 254, 254),
    TextDim       = Color3.fromRGB(160, 160, 170),
    TextFaint     = Color3.fromRGB(94, 94, 107),
    Success       = Color3.fromRGB(74, 222, 128),
    Warning       = Color3.fromRGB(250, 204, 21),
    Error         = Color3.fromRGB(248, 113, 113),
    PillBg        = Color3.fromRGB(247, 247, 247),
    SubPillBg     = Color3.fromRGB(254, 254, 254),
    ScrollBar     = Color3.fromRGB(60, 60, 70),
    Accent2       = Color3.fromRGB(34, 211, 238),
    AccentSoft    = Color3.fromRGB(40, 30, 60),
    ToggleOff     = Color3.fromRGB(24, 25, 32),
    ToggleOn      = Color3.fromRGB(254, 254, 254),
}

local T = Library.Theme
local themeBindings = {}

local function bindTheme(inst, prop, key)
    if not inst or not prop then return end
    table.insert(themeBindings, { inst = inst, prop = prop, key = key })
    if T[key] ~= nil then inst[prop] = T[key] end
end

local function applyTheme()
    for _, b in ipairs(themeBindings) do
        if b.inst and b.inst.Parent then
            pcall(function()
                if b._dynamic then
                    b.inst[b.prop] = b._dynamic()
                elseif T[b.key] ~= nil then
                    b.inst[b.prop] = T[b.key]
                end
            end)
        end
    end
end

function Library:SetTheme(accent, accent2)
    if accent then T.Accent = accent end
    if accent2 then T.Accent2 = accent2 end
    applyTheme()
end

-- ═══════════════════════════════════════════
-- LUCIDE
-- ═══════════════════════════════════════════
local LUCIDE_FALLBACK = {
    house            = "rbxassetid://98755624629571",
    home             = "rbxassetid://98755624629571",
    code             = "rbxassetid://107380207681249",
    layout           = "rbxassetid://107380207681249",
    settings         = "rbxassetid://80758916183665",
    x                = "rbxassetid://110786993356448",
    ["message-circle"] = "rbxassetid://127255077587058",
    server           = "rbxassetid://15269177520",
    terminal         = "rbxassetid://10734982144",
    ["scroll-text"]  = "rbxassetid://10734982144",
    user             = "rbxassetid://10734982144",
    eye              = "rbxassetid://10734982144",
    clock            = "rbxassetid://10734984606",
    info             = "rbxassetid://10734982144",
    palette          = "rbxassetid://80758916183665",
    bookmark         = "rbxassetid://10734982144",
    keyboard         = "rbxassetid://10734982144",
    ["chevron-down"] = "rbxassetid://110786993356448",
    ["chevron-up"]   = "rbxassetid://110786993356448",
    ["circle-check"] = "rbxassetid://83899464799881",
    ["circle-x"]     = "rbxassetid://110786993356448",
    ["triangle-alert"] = "rbxassetid://110786993356448",
    swords           = "rbxassetid://10734982144",
    crosshair        = "rbxassetid://10734982144",
    trash            = "rbxassetid://10734982144",
}

pcall(function()
    Library._Lucide = loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/Footagesus/Icons/main/Main-v2.lua"))()
    if Library._Lucide and Library._Lucide.SetIconsType then
        Library._Lucide.SetIconsType("lucide")
    end
end)

function Library:GetIcon(name)
    name = tostring(name or ""):lower():gsub("%s+", "-")
    if self._Lucide then
        local ok, result = pcall(function()
            return self._Lucide.GetIcon(name)
        end)
        if ok and result then
            if type(result) == "string" then return result end
            if type(result) == "table" then
                if type(result[1]) == "string" and result[1]:find("rbxassetid") then
                    return result[1]
                end
                if result.Image then return result.Image end
            end
        end
    end
    return LUCIDE_FALLBACK[name] or LUCIDE_FALLBACK.house
end

-- ═══════════════════════════════════════════
-- UTILS
-- ═══════════════════════════════════════════
local FONT_FACE = "rbxassetid://12187365364"

local function make(class, props)
    local inst = Instance.new(class)
    if props then
        for k, v in pairs(props) do
            if k ~= "Parent" then inst[k] = v end
        end
        if props.Parent then inst.Parent = props.Parent end
    end
    return inst
end

local function corner(parent, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r or 8)
    c.Parent = parent
    return c
end

local function stroke(parent, color, thickness, transparency)
    local s = Instance.new("UIStroke")
    s.Color = color or T.Border
    s.Thickness = thickness or 1
    s.Transparency = transparency or 0
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent = parent
    return s
end

local function padding(parent, t, b, l, r)
    local p = Instance.new("UIPadding")
    p.PaddingTop = UDim.new(0, t or 0)
    p.PaddingBottom = UDim.new(0, b or 0)
    p.PaddingLeft = UDim.new(0, l or 0)
    p.PaddingRight = UDim.new(0, r or 0)
    p.Parent = parent
    return p
end

local function listLayout(parent, pad, dir)
    local l = Instance.new("UIListLayout")
    l.Padding = UDim.new(0, pad or 6)
    l.FillDirection = dir or Enum.FillDirection.Vertical
    l.SortOrder = Enum.SortOrder.LayoutOrder
    l.Parent = parent
    return l
end

local function tween(obj, props, dur, style)
    local tw = TweenService:Create(obj, TweenInfo.new(dur or 0.16, style or Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props)
    tw:Play()
    return tw
end

local function protectGui(gui)
    if syn and syn.protect_gui then
        syn.protect_gui(gui)
        gui.Parent = CoreGui
    elseif gethui then
        gui.Parent = gethui()
    else
        pcall(function() gui.Parent = CoreGui end)
        if not gui.Parent then
            gui.Parent = LocalPlayer:WaitForChild("PlayerGui")
        end
    end
end

local function makeDraggable(frame, handle)
    local dragging, dragStart, startPos
    handle = handle or frame
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
        end
    end)
    -- Sampled globally (not just on the handle) so a fast drag that outruns the
    -- cursor still tracks instead of dropping the frame mid-move.
    local function onMove(input)
        if not dragging then return end
        if input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch then return end
        local d = input.Position - dragStart
        frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
    end
    handle.InputChanged:Connect(onMove)
    UserInputService.InputChanged:Connect(onMove)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

local function animateButton(button, defaultBg, hoverBg)
    local scale = button:FindFirstChildOfClass("UIScale")
    if not scale then
        scale = Instance.new("UIScale")
        scale.Scale = 1
        scale.Parent = button
    end
    button.MouseEnter:Connect(function()
        tween(button, { BackgroundColor3 = hoverBg }, 0.14)
        tween(scale, { Scale = 1.03 }, 0.14)
    end)
    button.MouseLeave:Connect(function()
        tween(button, { BackgroundColor3 = defaultBg }, 0.14)
        tween(scale, { Scale = 1 }, 0.14)
    end)
    button.MouseButton1Down:Connect(function()
        tween(scale, { Scale = 0.97 }, 0.08)
    end)
    button.MouseButton1Up:Connect(function()
        tween(scale, { Scale = 1.03 }, 0.12)
    end)
end

local function iconImage(parent, name, size, color, themeKey)
    local img = make("ImageLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.new(0, size or 16, 0, size or 16),
        Image = Library:GetIcon(name),
        ImageColor3 = color or T.Inactive,
        ScaleType = Enum.ScaleType.Fit,
        Parent = parent,
    })
    if themeKey then bindTheme(img, "ImageColor3", themeKey) end
    return img
end

-- White-to-gray gradient on a control's ImageColor3 (for active icons)
local function addWhiteGradient(img)
    local g = Instance.new("UIGradient")
    g.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(254, 254, 254)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(147, 147, 147)),
    })
    g.Parent = img
    return g
end

-- ═══════════════════════════════════════════
-- NOTIFY
-- ═══════════════════════════════════════════
function Library:Notify(title, message, duration, notifType)
    duration = duration or 3
    notifType = (notifType or "info"):lower()

    local styles = {
        success = { accent = Color3.fromRGB(34, 197, 94),  bg = Color3.fromRGB(12, 28, 18), title = "Success" },
        warning = { accent = Color3.fromRGB(234, 179, 8),  bg = Color3.fromRGB(32, 26, 10), title = "Warning" },
        error   = { accent = Color3.fromRGB(239, 68, 68),  bg = Color3.fromRGB(32, 12, 14), title = "Error"   },
        info    = { accent = T.Accent2,                   bg = Color3.fromRGB(16, 20, 32), title = "Info"    },
    }
    local style = styles[notifType] or styles.info
    local displayTitle = title or style.title

    if not self._NotifyHolder or not self._NotifyHolder.Parent then
        local holder = make("ScreenGui", {
            Name = "CYVUI_Notifications",
            ResetOnSpawn = false,
            DisplayOrder = 999,
            ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        })
        protectGui(holder)
        self._NotifyHolder = holder
        local list = make("Frame", {
            Name = "List",
            BackgroundTransparency = 1,
            Size = UDim2.new(0, 320, 0, 400),
            Position = UDim2.new(1, -340, 0, 18),
            Parent = holder,
        })
        local lay = listLayout(list, 10)
        lay.VerticalAlignment = Enum.VerticalAlignment.Top
        lay.HorizontalAlignment = Enum.HorizontalAlignment.Right
        self._NotifyList = list
    end

    -- cap to 4 stacked
    local count = 0
    for _, c in ipairs(self._NotifyList:GetChildren()) do
        if c:IsA("Frame") then count = count + 1 end
    end
    if count >= 4 then
        for _, c in ipairs(self._NotifyList:GetChildren()) do
            if c:IsA("Frame") then c:Destroy(); break end
        end
    end

    local card = make("Frame", {
        BackgroundColor3 = style.bg,
        Size = UDim2.new(0, 280, 0, 60),
        ClipsDescendants = true,
        Parent = self._NotifyList,
    })
    corner(card, 10)
    stroke(card, style.accent, 1, 0.5)

    local bar = make("Frame", {
        BackgroundColor3 = style.accent,
        Size = UDim2.new(0, 3, 1, 0),
        BorderSizePixel = 0,
        Parent = card,
    })
    corner(bar, 2)

    make("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 16, 0, 8),
        Size = UDim2.new(1, -28, 0, 18),
        FontFace = Font.new(FONT_FACE, Enum.FontWeight.Bold),
        Text = displayTitle, TextColor3 = Color3.new(1, 1, 1), TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left, Parent = card,
    })
    make("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 16, 0, 30),
        Size = UDim2.new(1, -28, 0, 24),
        FontFace = Font.new(FONT_FACE, Enum.FontWeight.Medium),
        Text = message or "", TextColor3 = Color3.fromRGB(200, 200, 210),
        TextSize = 12, TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left, Parent = card,
    })

    local function dismiss()
        if not card or not card.Parent then return end
        tween(card, { BackgroundTransparency = 1 }, 0.18)
        task.delay(0.2, function()
            if card and card.Parent then card:Destroy() end
        end)
    end
    task.delay(duration, dismiss)
end

-- ═══════════════════════════════════════════
-- WINDOW
-- ═══════════════════════════════════════════
function Library:CreateWindow(config)
    config = config or {}
    local title     = config.Title     or "CYVHUB"
    local libraryTag = config.GameName  or ""
    local version   = config.Version   or "v1.1.0"
    local size      = config.Size      or UDim2.fromOffset(695, 489)

    -- Destroy previous windows
    for _, old in ipairs(self.Windows) do
        if old and old.ScreenGui then old.ScreenGui:Destroy() end
    end
    table.clear(self.Windows)
    self._NotifyHolder = nil
    self._NotifyList   = nil

    local screenGui = make("ScreenGui", {
        Name = "CYVUI_" .. HttpService:GenerateGUID(false):sub(1, 8),
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        DisplayOrder = 50,
    })
    protectGui(screenGui)

    local main = make("Frame", {
        Name = "MainFrame",
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = T.Background,
        ClipsDescendants = true,
        Position = UDim2.fromScale(0.5, 0.5),
        Size = size,
        Parent = screenGui,
    })
    corner(main, 11)

    -- ═══ HEADER ═══
    local header = make("Frame", {
        Name = "Header",
        AnchorPoint = Vector2.new(0.5, 0),
        BackgroundTransparency = 1,
        Position = UDim2.fromScale(0.5, 0),
        Size = UDim2.fromOffset(695, 37),
        Parent = main,
    })

    local liner = make("Frame", {
        Name = "Liner",
        AnchorPoint = Vector2.new(0, 1),
        BackgroundColor3 = T.Liner,
        BorderSizePixel = 0,
        Position = UDim2.fromScale(0, 1),
        Size = UDim2.new(1, 0, 0, 2),
        Parent = header,
    })

    local libIcon = make("ImageLabel", {
        Name = "LibraryIcon",
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundTransparency = 1,
        Image = "rbxassetid://108488788823423",
        Position = UDim2.new(0, 12, 0.5, 0),
        ScaleType = Enum.ScaleType.Fit,
        Size = UDim2.fromOffset(20, 20),
        Parent = header,
    })

    local libName = make("TextLabel", {
        Name = "LibraryName",
        AnchorPoint = Vector2.new(0, 0.5),
        AutomaticSize = Enum.AutomaticSize.XY,
        BackgroundTransparency = 1,
        FontFace = Font.new(FONT_FACE, Enum.FontWeight.Medium, Enum.FontStyle.Normal),
        Position = UDim2.new(0, 38, 0.5, 0),
        RichText = true,
        Size = UDim2.fromOffset(1, 1),
        Text = title,
        TextColor3 = Color3.new(1, 1, 1),
        TextSize = 14,
        Parent = header,
    })

    local lastUpdated = make("TextLabel", {
        Name = "LastUpdated",
        AnchorPoint = Vector2.new(1, 0.5),
        AutomaticSize = Enum.AutomaticSize.XY,
        BackgroundTransparency = 1,
        FontFace = Font.new(FONT_FACE, Enum.FontWeight.Medium, Enum.FontStyle.Normal),
        Position = UDim2.new(1, -12, 0.5, 0),
        RichText = true,
        Size = UDim2.fromOffset(1, 1),
        Text = "",
        TextColor3 = Color3.new(1, 1, 1),
        TextSize = 12,
        Parent = header,
    })

    local clockIcon = make("ImageLabel", {
        Name = "ClockIcon",
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundTransparency = 1,
        Image = "rbxassetid://84304363968016",
        Position = UDim2.new(0, -22, 0.5, 0),
        Size = UDim2.fromOffset(15, 15),
        Parent = lastUpdated,
    })

    -- ═══ SIDEBAR ═══
    local sidebar = make("Frame", {
        Name = "Sidebar",
        AnchorPoint = Vector2.new(0, 1),
        BackgroundTransparency = 1,
        Position = UDim2.fromScale(0, 1),
        Size = UDim2.fromOffset(75, 453),
        Parent = main,
    })

    local sidebarLiner = make("Frame", {
        Name = "Liner",
        AnchorPoint = Vector2.new(1, 0.5),
        BackgroundColor3 = T.Liner,
        BorderSizePixel = 0,
        Position = UDim2.fromScale(1, 0.5),
        Size = UDim2.new(0, 2, 1, 0),
        Parent = sidebar,
    })

    local sidebarHolder = make("Frame", {
        Name = "Holder",
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(75, 453),
        Parent = sidebar,
    })
    listLayout(sidebarHolder, 5, Enum.FillDirection.Vertical)
    padding(sidebarHolder, 10, 10, 9, 0)

    -- ═══ CONTENT (right side: subtab row + page) ═══
    local subtabBar = make("Frame", {
        Name = "SubHeader",
        AnchorPoint = Vector2.new(0.5, 0),
        BackgroundTransparency = 1,
        Position = UDim2.fromScale(0.5547, 0.128),
        Size = UDim2.fromOffset(621, 51),
        Visible = false,
        ClipsDescendants = true,
        Parent = main,
    })
    local subtabLayout = listLayout(subtabBar, 8, Enum.FillDirection.Horizontal)
    padding(subtabBar, 4, 4, 25, 0)

    local page = make("Frame", {
        Name = "Page",
        AnchorPoint = Vector2.new(1, 1),
        BackgroundColor3 = T.Page,
        ClipsDescendants = true,
        Position = UDim2.fromScale(1, 1),
        Size = UDim2.fromOffset(620, 401),
        Parent = main,
    })
    corner(page, 11)

    -- Container holds section rows
    local container = make("ScrollingFrame", {
        Name = "Container",
        Active = true,
        BackgroundTransparency = 1,
        Position = UDim2.fromScale(0.5, 0.5),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Size = UDim2.fromOffset(620, 401),
        ScrollBarImageColor3 = T.ScrollBar,
        ScrollBarThickness = 1,
        BorderSizePixel = 0,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Parent = page,
    })
    listLayout(container, 12, Enum.FillDirection.Vertical)
    padding(container, 12, 12, 12, 12)

    local window = {
        ScreenGui    = screenGui,
        Main         = main,
        Header       = header,
        Sidebar      = sidebar,
        SidebarList  = sidebarHolder,
        SubtabBar    = subtabBar,
        Page         = page,
        Container    = container,
        Tabs         = {},
        CurrentTab   = nil,
        Config       = config,
        TitleName    = libName,
        TitleUpdated = lastUpdated,
    }

    -- Header setters
    function window:SetHeader(name, tag, updatedText)
        local safeName = tostring(name or "")
        local safeTag  = tostring(tag or "")
        if safeTag ~= "" then
            libName.Text = safeName .. ' <font color="#45475a">' .. safeTag .. '</font>'
        else
            libName.Text = safeName
        end
        if updatedText and updatedText ~= "" then
            lastUpdated.Text = 'Updated Last <font color="#45475a">' .. updatedText .. '</font>'
        else
            lastUpdated.Text = ""
        end
    end
    function window:SetTitle(name, tag, updatedText)
        return self:SetHeader(name, tag, updatedText)
    end
    window:SetHeader(title, libraryTag, version)

    makeDraggable(main, header)

    -- ═══════════════════════════════════════════
    -- TAB + SUBTAB CREATION
    -- ═══════════════════════════════════════════

    local function rebuildSubtabBar(tab)
        -- Clear bar, re-add subtabs of current tab
        for _, c in ipairs(subtabBar:GetChildren()) do
            if not c:IsA("UIPadding") and not c:IsA("UIListLayout") then
                c:Destroy()
            end
        end
        if not tab or #tab.Subtabs == 0 then
            subtabBar.Visible = false
            return
        end
        subtabBar.Visible = true
        for i, sub in ipairs(tab.Subtabs) do
            local entry = sub.Button
            entry.Parent = subtabBar
        end
    end

    local function activateSubtab(subtab)
        local tab = subtab.Tab
        tab.CurrentSubtab = subtab
        for _, s in ipairs(tab.Subtabs) do
            local active = (s == subtab)
            s.Button.BackgroundTransparency = active and 0.2 or 1
            s.Pill.BackgroundTransparency = active and 0 or 1
            s.Label.TextColor3 = active and Color3.new(1, 1, 1) or T.Inactive
            s.Label.TextTransparency = active and 0 or 0.15
        end
        for _, row in ipairs(tab.ContainerRows) do
            row.Visible = (row.Subtab == subtab)
        end
        if tab.Container then
            local visibleRows = {}
            for _, row in ipairs(tab.ContainerRows) do
                if row.Visible then table.insert(visibleRows, row) end
            end
            tab.Container.Visible = #visibleRows > 0 or tab.AllowEmptyPage ~= false
        end
        if tab.OnSelectSubtab then pcall(tab.OnSelectSubtab, subtab) end
    end

    function window:CreateTab(tabConfig)
        tabConfig = tabConfig or {}
        local tabName = tabConfig.Name or "Tab"
        local tabIcon = tabConfig.Icon or "house"
        local isHome     = tabConfig.Home == true
        local isSettings = tabConfig.Settings == true

        -- Sidebar tab button
        local tabBtn = make("TextButton", {
            Name = tabName,
            BackgroundTransparency = 1,
            BackgroundColor3 = Color3.new(0, 0, 0),
            Size = UDim2.fromOffset(55, 60),
            Text = "",
            AutoButtonColor = false,
            Parent = sidebarHolder,
        })
        corner(tabBtn, 5)

        local tabIconImg = make("ImageLabel", {
            Name = "Icon",
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundTransparency = 1,
            Image = Library:GetIcon(tabIcon),
            Position = UDim2.new(0.5, 0, 0.5, -8),
            Size = UDim2.fromOffset(24, 22),
            Parent = tabBtn,
        })

        local tabLbl = make("TextLabel", {
            Name = "TextLabel",
            AnchorPoint = Vector2.new(0.5, 0.5),
            AutomaticSize = Enum.AutomaticSize.XY,
            BackgroundTransparency = 1,
            FontFace = Font.new(FONT_FACE, Enum.FontWeight.Bold, Enum.FontStyle.Normal),
            Position = UDim2.new(0.5, 0, 0.5, 20),
            Text = tabName,
            TextColor3 = T.Inactive,
            TextSize = 12,
            Parent = tabIconImg,
        })

        -- Active-state pill (white-to-gray gradient)
        local activePill = make("Frame", {
            Name = "Pill",
            AnchorPoint = Vector2.new(0.5, 1),
            BackgroundColor3 = Color3.fromRGB(31, 31, 45),
            BackgroundTransparency = 1,
            Position = UDim2.new(0.5, 0, 1, 3),
            Size = UDim2.fromOffset(25, 6),
            Parent = tabBtn,
        })
        corner(activePill, 12)
        local pillGrad = Instance.new("UIGradient")
        pillGrad.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(254, 254, 254)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(147, 147, 147)),
        })
        pillGrad.Parent = activePill

        local tab = {
            Name = tabName,
            Button = tabBtn,
            Icon = tabIconImg,
            Label = tabLbl,
            Pill = activePill,
            Subtabs = {},
            CurrentSubtab = nil,
            ContainerRows = {},
            IsHome = isHome,
            IsSettings = isSettings,
        }

        local function selectTab()
            for _, t in ipairs(window.Tabs) do
                local active = (t == tab)
                t.Button.BackgroundColor3 = active and Color3.fromRGB(247, 247, 247) or Color3.new(0, 0, 0)
                t.Button.BackgroundTransparency = active and 0.9 or 1
                t.Pill.BackgroundTransparency = active and 0 or 1
                t.Icon.ImageColor3 = active and Color3.new(1, 1, 1) or T.Inactive
                if active then
                    addWhiteGradient(t.Icon)
                    t.Label.TextColor3 = Color3.new(1, 1, 1)
                    t.Label.FontFace = Font.new(FONT_FACE, Enum.FontWeight.Bold)
                else
                    t.Label.TextColor3 = T.Inactive
                end
            end
            window.CurrentTab = tab
            -- Show subtab bar if needed, hide rows from other tabs
            for _, t in ipairs(window.Tabs) do
                for _, row in ipairs(t.ContainerRows) do
                    row.Visible = (t == tab) and (row.Subtab == tab.CurrentSubtab or (not row.Subtab and not tab.CurrentSubtab))
                end
            end
            rebuildSubtabBar(tab)
            if tab.AllowEmptyPage == nil then tab.AllowEmptyPage = false end
            if tab.Container and tab ~= window.CurrentTab then
                -- ensure visibility logic is correct
            end
        end
        tabBtn.MouseButton1Click:Connect(selectTab)

        -- ═══════════════════════════════════════════
        -- SUBTAB
        -- ═══════════════════════════════════════════
        function tab:AddSubtab(name)
            name = tostring(name or "Subtab")
            local entry = make("Frame", {
                Name = "SubTab",
                AutomaticSize = Enum.AutomaticSize.X,
                BackgroundTransparency = 1,
                Size = UDim2.fromOffset(80, 49),
                Parent = subtabBar,
            })
            local tabName = make("TextLabel", {
                Name = "TabName",
                AnchorPoint = Vector2.new(0.5, 0.5),
                AutomaticSize = Enum.AutomaticSize.XY,
                BackgroundTransparency = 1,
                FontFace = Font.new(FONT_FACE, Enum.FontWeight.Medium, Enum.FontStyle.Normal),
                Position = UDim2.new(0.5, 0, 0.5, -3),
                Text = name,
                TextColor3 = T.Inactive,
                TextSize = 13,
                TextTransparency = 0.15,
                Parent = entry,
            })
            corner(tabName, 4)
            padding(tabName, 10, 10, 8, 8)
            local nmGrad = Instance.new("UIGradient")
            nmGrad.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(254, 254, 254)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(147, 147, 147)),
            })
            nmGrad.Parent = tabName

            local pill = make("Frame", {
                Name = "Pill",
                AnchorPoint = Vector2.new(0.5, 1),
                BackgroundColor3 = Color3.fromRGB(31, 31, 45),
                BackgroundTransparency = 1,
                Position = UDim2.new(0.5, 0, 1, 2),
                Size = UDim2.fromOffset(34, 6),
                Parent = entry,
            })
            corner(pill, 12)
            local pGrad = Instance.new("UIGradient")
            pGrad.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(254, 254, 254)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(147, 147, 147)),
            })
            pGrad.Parent = pill

            local subtab = {
                Name = name,
                Tab = tab,
                Button = entry,
                Label = tabName,
                Pill = pill,
                Sections = {},
            }

            function subtab:Select()
                activateSubtab(self)
                rebuildSubtabBar(tab)
            end

            entry.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    subtab:Select()
                end
            end)

            -- Current row tracking for section pairing
            local currentRow = nil

            function subtab:CreateSection(name, opts)
                opts = opts or {}
                local sectionName = name or "Section"

                -- Find or create row (2-column pairing)
                if not currentRow or currentRow._count >= 2 then
                    currentRow = make("Frame", {
                        Name = "Row",
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1, 0, 0, 0),
                        AutomaticSize = Enum.AutomaticSize.Y,
                        Parent = container,
                    })
                    local rl = Instance.new("UIListLayout")
                    rl.FillDirection = Enum.FillDirection.Horizontal
                    rl.Padding = UDim.new(0, 20)
                    rl.SortOrder = Enum.SortOrder.LayoutOrder
                    rl.Parent = currentRow
                    currentRow._count = 0
                    currentRow.Subtab = subtab
                    table.insert(subtab.Tab.ContainerRows, currentRow)
                end
                currentRow._count = currentRow._count + 1

                local section = make("Frame", {
                    Name = "Section",
                    AutomaticSize = Enum.AutomaticSize.Y,
                    BackgroundColor3 = T.Panel,
                    ClipsDescendants = true,
                    Size = UDim2.fromOffset(281, 60),
                    Parent = currentRow,
                })
                corner(section, 6)

                -- Section header
                local sectionHeader = make("Frame", {
                    Name = "Header",
                    AnchorPoint = Vector2.new(0.5, 0),
                    BackgroundColor3 = T.SectionHdr,
                    Position = UDim2.fromScale(0.5, 0),
                    Size = UDim2.fromOffset(281, 30),
                    Parent = section,
                })
                corner(sectionHeader, 6)
                local headerLiner = make("Frame", {
                    Name = "Liner",
                    AnchorPoint = Vector2.new(0.5, 1),
                    BackgroundColor3 = T.Liner,
                    BorderSizePixel = 0,
                    Position = UDim2.fromScale(0.5, 1),
                    Size = UDim2.new(1, 0, 0, 1),
                    Parent = sectionHeader,
                })

                local headerHolder = make("Frame", {
                    Name = "HeaderHolder",
                    AnchorPoint = Vector2.new(0.5, 0.5),
                    BackgroundTransparency = 1,
                    ClipsDescendants = true,
                    Position = UDim2.fromScale(0.5, 0.5),
                    Size = UDim2.fromOffset(281, 30),
                    Parent = sectionHeader,
                })

                local accentBar = make("Frame", {
                    Name = "Line",
                    AnchorPoint = Vector2.new(0, 0.5),
                    BackgroundColor3 = Color3.new(1, 1, 1),
                    Position = UDim2.new(0, -3, 0.5, 0),
                    Size = UDim2.fromOffset(6, 20),
                    Parent = headerHolder,
                })
                corner(accentBar, 30)
                local accentGrad = Instance.new("UIGradient")
                accentGrad.Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Color3.fromRGB(254, 254, 254)),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(147, 147, 147)),
                })
                accentGrad.Parent = accentBar

                if opts.Icon then
                    iconImage(headerHolder, opts.Icon, 15, Color3.new(1, 1, 1)).Position = UDim2.new(0, 12, 0.5, 0)
                end

                local headerName = make("TextLabel", {
                    Name = "SectionName",
                    AnchorPoint = Vector2.new(0, 0.5),
                    AutomaticSize = Enum.AutomaticSize.XY,
                    BackgroundTransparency = 1,
                    FontFace = Font.new(FONT_FACE, Enum.FontWeight.Medium, Enum.FontStyle.Normal),
                    Position = UDim2.new(0, opts.Icon and 35 or 18, 0.5, 0),
                    Text = sectionName,
                    TextColor3 = Color3.new(1, 1, 1),
                    TextSize = 12,
                    Parent = headerHolder,
                })

                -- Optional section master toggle
                local sectionToggle = nil
                if opts.Toggle then
                    local togCfg = opts.Toggle
                    sectionToggle = make("Frame", {
                        Name = "Toggle",
                        AnchorPoint = Vector2.new(1, 0.5),
                        BackgroundColor3 = togCfg.Default and T.ToggleOn or T.ToggleOff,
                        Position = UDim2.new(1, -12, 0.5, 0),
                        Size = UDim2.fromOffset(16, 16),
                        Parent = headerHolder,
                    })
                    corner(sectionToggle, 3)
                    local togStroke = stroke(sectionToggle, T.Border, 1, togCfg.Default and 1 or 0)
                    if togCfg.Default then
                        local ck = make("ImageLabel", {
                            BackgroundTransparency = 1,
                            AnchorPoint = Vector2.new(0.5, 0.5),
                            Image = "rbxassetid://83899464799881",
                            Position = UDim2.fromScale(0.5, 0.5),
                            Size = UDim2.fromOffset(8, 7),
                            Parent = sectionToggle,
                        })
                        local g = Instance.new("UIGradient")
                        g.Color = ColorSequence.new({
                            ColorSequenceKeypoint.new(0, Color3.fromRGB(254, 254, 254)),
                            ColorSequenceKeypoint.new(1, Color3.fromRGB(147, 147, 147)),
                        })
                        g.Parent = sectionToggle
                    end
                    local state = togCfg.Default and true or false
                    if togCfg.Flag then Library.Flags[togCfg.Flag] = state end
                    sectionToggle.InputBegan:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                            state = not state
                            sectionToggle.BackgroundColor3 = state and T.ToggleOn or T.ToggleOff
                            togStroke.Transparency = state and 1 or 0
                            if togCfg.Flag then Library.Flags[togCfg.Flag] = state end
                            if togCfg.Callback then pcall(togCfg.Callback, state) end
                        end
                    end)
                end

                -- Element list area (below header)
                local holder = make("Frame", {
                    Name = "Holder",
                    AnchorPoint = Vector2.new(0.5, 0),
                    AutomaticSize = Enum.AutomaticSize.XY,
                    BackgroundTransparency = 1,
                    Position = UDim2.fromScale(0.5, 1),
                    Size = UDim2.fromOffset(1, 1),
                    Parent = section,
                })
                listLayout(holder, 4)
                padding(holder, 45, 5, 0, 0)

                local sec = {
                    Frame = section,
                    Header = sectionHeader,
                    Holder = holder,
                    Name = sectionName,
                    Elements = {},
                    Order = 0,
                }
                local orderCounter = 0
                local function nextOrder()
                    orderCounter = orderCounter + 1
                    return orderCounter
                end

                -- ═══ WIDGETS ═══

                function sec:AddLabel(text)
                    local lbl = make("TextLabel", {
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1, 0, 0, 0),
                        AutomaticSize = Enum.AutomaticSize.Y,
                        FontFace = Font.new(FONT_FACE, Enum.FontWeight.Medium, Enum.FontStyle.Normal),
                        Text = text or "",
                        TextColor3 = T.TextDim,
                        TextSize = 13,
                        TextWrapped = true,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        LayoutOrder = nextOrder(),
                        Parent = holder,
                    })
                    table.insert(sec.Elements, lbl)
                    return lbl
                end
                function sec:AddParagraph(text) return self:AddLabel(text) end

                function sec:AddButton(cfg)
                    cfg = cfg or {}
                    local btnWrap = make("Frame", {
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1, 0, 0, 40),
                        LayoutOrder = nextOrder(),
                        Parent = holder,
                    })
                    local btn = make("TextButton", {
                        BackgroundColor3 = cfg.Color or T.Input,
                        AnchorPoint = Vector2.new(0.5, 0.5),
                        Position = UDim2.fromScale(0.5, 0.5),
                        Size = UDim2.fromOffset(251, 30),
                        Text = "",
                        AutoButtonColor = false,
                        Parent = btnWrap,
                    })
                    corner(btn, 3)
                    local btnStroke = stroke(btn, cfg.Color or T.Border, 1, cfg.Color and 0.5 or 0)
                    if cfg.Color then
                        btn.BackgroundTransparency = 0.95
                    end
                    local txt = make("TextLabel", {
                        BackgroundTransparency = 1,
                        AnchorPoint = Vector2.new(0.5, 0.5),
                        AutomaticSize = Enum.AutomaticSize.XY,
                        FontFace = Font.new(FONT_FACE, Enum.FontWeight.Medium, Enum.FontStyle.Normal),
                        Position = UDim2.fromScale(0.5, 0.5),
                        Text = cfg.Text or "Button",
                        TextColor3 = cfg.Color or T.Inactive,
                        TextSize = 13,
                        Parent = btn,
                    })
                    if cfg.Color then
                        local g = Instance.new("UIGradient")
                        g.Color = ColorSequence.new({
                            ColorSequenceKeypoint.new(0, cfg.Color),
                            ColorSequenceKeypoint.new(1, T.AccentDim),
                        })
                        g.Parent = txt
                    end
                    btn.MouseButton1Click:Connect(function()
                        if cfg.Callback then pcall(cfg.Callback) end
                    end)
                    table.insert(sec.Elements, btnWrap)
                    return btn
                end

                function sec:AddToggle(cfg)
                    cfg = cfg or {}
                    local flag, default = cfg.Flag, cfg.Default == true
                    if flag then Library.Flags[flag] = default end

                    local row = make("Frame", {
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1, 0, 0, 30),
                        LayoutOrder = nextOrder(),
                        Parent = holder,
                    })

                    local togStroke
                    local tog = make("Frame", {
                        AnchorPoint = Vector2.new(0, 0.5),
                        BackgroundColor3 = default and T.ToggleOn or T.ToggleOff,
                        Position = UDim2.new(0, 25, 0.5, 0),
                        Size = UDim2.fromOffset(14, 14),
                        Parent = row,
                    })
                    corner(tog, 3)
                    togStroke = stroke(tog, T.Border, 1, default and 1 or 0)

                    local check
                    if default then
                        check = make("ImageLabel", {
                            AnchorPoint = Vector2.new(0.5, 0.5),
                            BackgroundTransparency = 1,
                            Image = "rbxassetid://83899464799881",
                            Position = UDim2.fromScale(0.5, 0.5),
                            Size = UDim2.fromOffset(8, 7),
                            Parent = tog,
                        })
                        local g = Instance.new("UIGradient")
                        g.Color = ColorSequence.new({
                            ColorSequenceKeypoint.new(0, Color3.fromRGB(254, 254, 254)),
                            ColorSequenceKeypoint.new(1, Color3.fromRGB(147, 147, 147)),
                        })
                        g.Parent = tog
                    end

                    local nameLbl = make("TextLabel", {
                        BackgroundTransparency = 1,
                        AnchorPoint = Vector2.new(0, 0.5),
                        AutomaticSize = Enum.AutomaticSize.XY,
                        FontFace = Font.new(FONT_FACE, Enum.FontWeight.Medium, Enum.FontStyle.Normal),
                        Position = UDim2.new(0, 48, 0.5, 0),
                        Text = cfg.Text or "Toggle",
                        TextColor3 = default and Color3.new(1, 1, 1) or T.Inactive,
                        TextSize = 12,
                        Parent = row,
                    })

                    local state = default
                    local function setState(v, fire)
                        state = v
                        if flag then Library.Flags[flag] = v end
                        tog.BackgroundColor3 = v and T.ToggleOn or T.ToggleOff
                        togStroke.Transparency = v and 1 or 0
                        nameLbl.TextColor3 = v and Color3.new(1, 1, 1) or T.Inactive
                        if v and not check then
                            check = make("ImageLabel", {
                                AnchorPoint = Vector2.new(0.5, 0.5),
                                BackgroundTransparency = 1,
                                Image = "rbxassetid://83899464799881",
                                Position = UDim2.fromScale(0.5, 0.5),
                                Size = UDim2.fromOffset(8, 7),
                                Parent = tog,
                            })
                            local g = Instance.new("UIGradient")
                            g.Color = ColorSequence.new({
                                ColorSequenceKeypoint.new(0, Color3.fromRGB(254, 254, 254)),
                                ColorSequenceKeypoint.new(1, Color3.fromRGB(147, 147, 147)),
                            })
                            g.Parent = tog
                        elseif not v and check then
                            check:Destroy()
                            check = nil
                        end
                        if fire and cfg.Callback then pcall(cfg.Callback, v) end
                    end
                    row.InputBegan:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                            setState(not state, true)
                        end
                    end)
                    table.insert(sec.Elements, row)
                    return {
                        Set = function(_, v) setState(v, true) end,
                        Get = function() return state end,
                        Frame = row,
                    }
                end

                function sec:AddSlider(cfg)
                    cfg = cfg or {}
                    local minV, maxV = cfg.Min or 0, cfg.Max or 100
                    local default = cfg.Default or minV
                    local decimals = cfg.Decimals or 0
                    local flag = cfg.Flag
                    if flag then Library.Flags[flag] = default end

                    local row = make("Frame", {
                        Active = true,
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1, 0, 0, 40),
                        LayoutOrder = nextOrder(),
                        Parent = holder,
                    })
                    local valueLbl = make("TextLabel", {
                        AnchorPoint = Vector2.new(1, 0.5),
                        AutomaticSize = Enum.AutomaticSize.XY,
                        BackgroundTransparency = 1,
                        FontFace = Font.new(FONT_FACE, Enum.FontWeight.Medium, Enum.FontStyle.Normal),
                        Position = UDim2.new(1, -22, 0.5, -8),
                        Text = tostring(default),
                        TextColor3 = Color3.new(1, 1, 1),
                        TextSize = 14,
                        Parent = row,
                    })
                    make("TextLabel", {
                        AnchorPoint = Vector2.new(0, 0.5),
                        AutomaticSize = Enum.AutomaticSize.XY,
                        BackgroundTransparency = 1,
                        FontFace = Font.new(FONT_FACE, Enum.FontWeight.Medium, Enum.FontStyle.Normal),
                        Position = UDim2.new(0, 23, 0.5, -8),
                        Text = cfg.Text or "Slider",
                        TextColor3 = T.Inactive,
                        TextSize = 14,
                        Parent = row,
                    })

                    local trackBg = make("Frame", {
                        AnchorPoint = Vector2.new(0, 0.5),
                        BackgroundColor3 = T.Input,
                        Position = UDim2.new(0, 22, 0.5, 8),
                        Size = UDim2.fromOffset(266, 4),
                        Parent = row,
                    })
                    corner(trackBg)
                    stroke(trackBg, T.Border, 1, 0)

                    local rel0 = math.clamp((default - minV) / math.max(maxV - minV, 1), 0, 1)
                    local progress = make("Frame", {
                        AnchorPoint = Vector2.new(0, 0.5),
                        BackgroundColor3 = Color3.fromRGB(232, 232, 232),
                        Position = UDim2.fromScale(0, 0.5),
                        Size = UDim2.fromOffset(171, 7),
                        ClipsDescendants = true,
                        Parent = trackBg,
                    })
                    corner(progress)
                    local pgrad = Instance.new("UIGradient")
                    pgrad.Color = ColorSequence.new({
                        ColorSequenceKeypoint.new(0, Color3.fromRGB(254, 254, 254)),
                        ColorSequenceKeypoint.new(1, Color3.fromRGB(147, 147, 147)),
                    })
                    pgrad.Parent = progress

                    local pointer = make("Frame", {
                        AnchorPoint = Vector2.new(1, 0.5),
                        BackgroundColor3 = Color3.new(1, 1, 1),
                        Position = UDim2.fromScale(1, 0.5),
                        Size = UDim2.fromOffset(6, 6),
                        Parent = progress,
                    })
                    corner(pointer)
                    local design = make("Frame", {
                        AnchorPoint = Vector2.new(0.5, 0.5),
                        BackgroundColor3 = Color3.new(1, 1, 1),
                        BackgroundTransparency = 0.5,
                        Position = UDim2.fromScale(0.5, 0.5),
                        Size = UDim2.fromOffset(14, 14),
                        Parent = pointer,
                    })
                    corner(design)

                    -- initial sizing
                    progress.Size = UDim2.fromOffset(math.max(7, 266 * rel0), 7)

                    local sliding = false
                    local function update(input)
                        local absX = trackBg.AbsolutePosition.X
                        local absW = trackBg.AbsoluteSize.X
                        local rel = math.clamp((input.X - absX) / math.max(absW, 1), 0, 1)
                        local val = minV + (maxV - minV) * rel
                        if decimals == 0 then val = math.floor(val + 0.5)
                        else val = math.floor(val * (10 ^ decimals) + 0.5) / (10 ^ decimals) end
                        progress.Size = UDim2.fromOffset(math.max(7, absW * rel), 7)
                        valueLbl.Text = tostring(val)
                        if flag then Library.Flags[flag] = val end
                        if cfg.Callback then pcall(cfg.Callback, val) end
                    end
                    trackBg.InputBegan:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                            sliding = true
                            update(input.Position)
                        end
                    end)
                    UserInputService.InputChanged:Connect(function(input)
                        if sliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                            update(input.Position)
                        end
                    end)
                    UserInputService.InputEnded:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                            sliding = false
                        end
                    end)

                    table.insert(sec.Elements, row)
                    return {
                        Frame = row,
                        Set = function(_, v)
                            local rel = math.clamp((v - minV) / math.max(maxV - minV, 1), 0, 1)
                            progress.Size = UDim2.fromOffset(math.max(7, 266 * rel), 7)
                            valueLbl.Text = tostring(v)
                            if flag then Library.Flags[flag] = v end
                        end,
                        Get = function()
                            return tonumber(valueLbl.Text) or default
                        end,
                    }
                end

                function sec:AddDropdown(cfg)
                    cfg = cfg or {}
                    local options = cfg.Options or { "Option 1" }
                    local multi = cfg.Multi == true
                    local default = cfg.Default
                    if multi then
                        if type(default) ~= "table" then
                            default = default and { default } or {}
                        end
                    else
                        default = default or options[1]
                    end
                    local flag = cfg.Flag
                    if flag then Library.Flags[flag] = default end

                    local selected = {}
                    if multi then
                        for _, v in ipairs(default) do selected[v] = true end
                    end

                    local wrap = make("Frame", {
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1, 0, 0, 55),
                        LayoutOrder = nextOrder(),
                        Parent = holder,
                    })

                    make("TextLabel", {
                        BackgroundTransparency = 1,
                        AutomaticSize = Enum.AutomaticSize.XY,
                        FontFace = Font.new(FONT_FACE, Enum.FontWeight.Medium, Enum.FontStyle.Normal),
                        Position = UDim2.fromOffset(25, 12),
                        Text = cfg.Text or "Dropdown",
                        TextColor3 = T.Muted,
                        TextSize = 12,
                        Parent = wrap,
                    })

                    local function labelText()
                        if multi then
                            local list = {}
                            for _, opt in ipairs(options) do
                                if selected[opt] then table.insert(list, opt) end
                            end
                            if #list == 0 then return "None" end
                            return table.concat(list, ", ")
                        end
                        return tostring(default)
                    end

                    local box = make("TextButton", {
                        AnchorPoint = Vector2.new(0.5, 1),
                        BackgroundColor3 = T.Input,
                        ClipsDescendants = true,
                        Position = UDim2.fromScale(0.5032, 1),
                        Size = UDim2.fromOffset(264, 22),
                        Text = "",
                        AutoButtonColor = false,
                        Parent = wrap,
                    })
                    corner(box, 2)
                    stroke(box, T.Border, 1, 0)

                    local optLbl = make("TextLabel", {
                        BackgroundTransparency = 1,
                        AnchorPoint = Vector2.new(0, 0.5),
                        AutomaticSize = Enum.AutomaticSize.XY,
                        FontFace = Font.new(FONT_FACE, Enum.FontWeight.Medium, Enum.FontStyle.Normal),
                        Position = UDim2.fromScale(0.025, 0.5),
                        Text = labelText(),
                        TextColor3 = Color3.new(1, 1, 1),
                        TextSize = 13,
                        Parent = box,
                    })
                    local optGrad = Instance.new("UIGradient")
                    optGrad.Color = ColorSequence.new({
                        ColorSequenceKeypoint.new(0, Color3.fromRGB(254, 254, 254)),
                        ColorSequenceKeypoint.new(1, Color3.fromRGB(147, 147, 147)),
                    })
                    optGrad.Parent = optLbl

                    -- chevron (two rounded vertical bars)
                    local chevR = make("Frame", {
                        AnchorPoint = Vector2.new(1, 0.5),
                        BackgroundColor3 = Color3.new(1, 1, 1),
                        Position = UDim2.new(1, 4, 0.5, 0),
                        Size = UDim2.fromOffset(6, 13),
                        Parent = box,
                    })
                    corner(chevR, 30)
                    local chevRgrad = Instance.new("UIGradient")
                    chevRgrad.Color = ColorSequence.new({
                        ColorSequenceKeypoint.new(0, Color3.fromRGB(254, 254, 254)),
                        ColorSequenceKeypoint.new(1, Color3.fromRGB(147, 147, 147)),
                    })
                    chevRgrad.Parent = chevR
                    local chevL = make("Frame", {
                        AnchorPoint = Vector2.new(0, 0.5),
                        BackgroundColor3 = Color3.new(1, 1, 1),
                        Position = UDim2.new(0, -4, 0.5, 0),
                        Size = UDim2.fromOffset(6, 13),
                        Parent = box,
                    })
                    corner(chevL, 30)
                    local chevLgrad = Instance.new("UIGradient")
                    chevLgrad.Color = ColorSequence.new({
                        ColorSequenceKeypoint.new(0, Color3.fromRGB(254, 254, 147)),
                        ColorSequenceKeypoint.new(1, Color3.fromRGB(147, 147, 147)),
                    })
                    chevLgrad.Parent = chevL

                    local listFrame = make("Frame", {
                        AnchorPoint = Vector2.new(0.5, 0),
                        BackgroundColor3 = T.Input,
                        ClipsDescendants = true,
                        Position = UDim2.fromScale(0.5, 1),
                        Size = UDim2.fromOffset(264, 0),
                        Visible = false,
                        ZIndex = 50,
                        Parent = wrap,
                    })
                    corner(listFrame, 4)
                    stroke(listFrame, T.Border, 1, 0)
                    listLayout(listFrame, 2)

                    local optScroll = make("ScrollingFrame", {
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1, 0, 1, 0),
                        CanvasSize = UDim2.new(0, 0, 0, 0),
                        AutomaticCanvasSize = Enum.AutomaticSize.Y,
                        ScrollBarThickness = 2,
                        ScrollBarImageColor3 = T.ScrollBar,
                        BorderSizePixel = 0,
                        ZIndex = 51,
                        Parent = listFrame,
                    })
                    listLayout(optScroll, 0)
                    padding(optScroll, 4, 4, 4, 4)

                    local optButtons = {}
                    local function fireChange()
                        if multi then
                            local list = {}
                            for _, opt in ipairs(options) do
                                if selected[opt] then table.insert(list, opt) end
                            end
                            if flag then Library.Flags[flag] = list end
                            optLbl.Text = labelText()
                            if cfg.Callback then pcall(cfg.Callback, list) end
                        else
                            if flag then Library.Flags[flag] = default end
                            optLbl.Text = tostring(default)
                            if cfg.Callback then pcall(cfg.Callback, default) end
                        end
                    end

                    local function makeOpt(opt)
                        local row = make("TextButton", {
                            BackgroundTransparency = 1,
                            Size = UDim2.new(1, 0, 0, 22),
                            Text = "",
                            AutoButtonColor = false,
                            ZIndex = 52,
                            Parent = optScroll,
                        })
                        local lbl = make("TextLabel", {
                            BackgroundTransparency = 1,
                            AnchorPoint = Vector2.new(0, 0.5),
                            AutomaticSize = Enum.AutomaticSize.XY,
                            FontFace = Font.new(FONT_FACE, Enum.FontWeight.Medium, Enum.FontStyle.Normal),
                            Position = UDim2.new(0, 8, 0.5, 0),
                            Text = opt,
                            TextColor3 = T.TextDim,
                            TextSize = 12,
                            ZIndex = 53,
                            Parent = row,
                        })
                        row.InputBegan:Connect(function(input)
                            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                                if multi then
                                    selected[opt] = not selected[opt]
                                    lbl.TextColor3 = selected[opt] and Color3.new(1,1,1) or T.TextDim
                                else
                                    default = opt
                                    for _, o in ipairs(optButtons) do
                                        o.lbl.TextColor3 = (o.opt == default) and Color3.new(1,1,1) or T.TextDim
                                    end
                                    listFrame.Visible = false
                                    listFrame.Size = UDim2.fromOffset(264, 0)
                                end
                                fireChange()
                            end
                        end)
                        table.insert(optButtons, { row = row, lbl = lbl, opt = opt })
                    end
                    for _, opt in ipairs(options) do makeOpt(opt) end

                    local open = false
                    local function setOpen(state)
                        open = state
                        listFrame.Visible = open
                        if open then
                            local h = math.min(#options * 24 + 8, 140)
                            listFrame.Size = UDim2.fromOffset(264, h)
                        else
                            listFrame.Size = UDim2.fromOffset(264, 0)
                        end
                    end
                    box.InputBegan:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                            setOpen(not open)
                        end
                    end)

                    table.insert(sec.Elements, wrap)
                    return {
                        Frame = wrap,
                        Set = function(_, v)
                            if multi then
                                selected = {}
                                if type(v) == "table" then
                                    for _, x in ipairs(v) do selected[x] = true end
                                end
                                for _, o in ipairs(optButtons) do
                                    o.lbl.TextColor3 = selected[o.opt] and Color3.new(1,1,1) or T.TextDim
                                end
                            else
                                default = v
                                for _, o in ipairs(optButtons) do
                                    o.lbl.TextColor3 = (o.opt == default) and Color3.new(1,1,1) or T.TextDim
                                end
                            end
                            fireChange()
                        end,
                        Get = function()
                            if multi then
                                local list = {}
                                for _, opt in ipairs(options) do
                                    if selected[opt] then table.insert(list, opt) end
                                end
                                return list
                            end
                            return default
                        end,
                    }
                end

                function sec:AddTextbox(cfg)
                    cfg = cfg or {}
                    local flag = cfg.Flag
                    if flag then Library.Flags[flag] = cfg.Default or "" end
                    local wrap = make("Frame", {
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1, 0, 0, 50),
                        LayoutOrder = nextOrder(),
                        Parent = holder,
                    })
                    if cfg.Text then
                        make("TextLabel", {
                            BackgroundTransparency = 1,
                            AutomaticSize = Enum.AutomaticSize.XY,
                            FontFace = Font.new(FONT_FACE, Enum.FontWeight.Medium, Enum.FontStyle.Normal),
                            Position = UDim2.fromOffset(25, 6),
                            Text = cfg.Text,
                            TextColor3 = T.Muted,
                            TextSize = 12,
                            Parent = wrap,
                        })
                    end
                    local box = make("TextBox", {
                        AnchorPoint = Vector2.new(0.5, 1),
                        BackgroundColor3 = T.Input,
                        Position = UDim2.fromScale(0.5, 1),
                        Size = UDim2.fromOffset(264, 26),
                        Text = cfg.Default or "",
                        PlaceholderText = cfg.Placeholder or "...",
                        PlaceholderColor3 = T.TextFaint,
                        FontFace = Font.new(FONT_FACE, Enum.FontWeight.Medium, Enum.FontStyle.Normal),
                        TextColor3 = Color3.new(1, 1, 1),
                        TextSize = 12,
                        ClearTextOnFocus = false,
                        Parent = wrap,
                    })
                    corner(box, 4)
                    stroke(box, T.Border, 1, 0)
                    padding(box, 0, 0, 8, 8)
                    box.FocusLost:Connect(function()
                        if flag then Library.Flags[flag] = box.Text end
                        if cfg.Callback then pcall(cfg.Callback, box.Text) end
                    end)
                    table.insert(sec.Elements, wrap)
                    return box
                end

                function sec:AddKeybind(cfg)
                    cfg = cfg or {}
                    local default = cfg.Default or Enum.KeyCode.Unknown
                    local flag = cfg.Flag
                    if flag then Library.Flags[flag] = default end

                    local row = make("Frame", {
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1, 0, 0, 50),
                        LayoutOrder = nextOrder(),
                        Parent = holder,
                    })

                    make("TextLabel", {
                        AnchorPoint = Vector2.new(0, 0.5),
                        BackgroundTransparency = 1,
                        AutomaticSize = Enum.AutomaticSize.XY,
                        FontFace = Font.new(FONT_FACE, Enum.FontWeight.Medium, Enum.FontStyle.Normal),
                        Position = UDim2.new(0, 25, 0.5, 0),
                        Text = cfg.Text or "Keybind",
                        TextColor3 = Color3.new(1, 1, 1),
                        TextSize = 12,
                        Parent = row,
                    })

                    local keyHolder = make("Frame", {
                        AnchorPoint = Vector2.new(1, 0.5),
                        AutomaticSize = Enum.AutomaticSize.X,
                        BackgroundColor3 = T.Input,
                        ClipsDescendants = true,
                        Position = UDim2.new(1, -23, 0.5, 0),
                        Size = UDim2.fromOffset(16, 16),
                        Parent = row,
                    })
                    corner(keyHolder, 3)
                    stroke(keyHolder, T.Border, 1, 0)
                    listLayout(keyHolder, 0, Enum.FillDirection.Horizontal)
                    padding(keyHolder, 0, 0, 4, 4)

                    local keyIcon = make("ImageLabel", {
                        BackgroundTransparency = 1,
                        Image = "rbxassetid://127406982390736",
                        ImageColor3 = Color3.new(1, 1, 1),
                        ScaleType = Enum.ScaleType.Fit,
                        Size = UDim2.fromOffset(15, 15),
                        Parent = keyHolder,
                    })
                    local keyGrad = Instance.new("UIGradient")
                    keyGrad.Color = ColorSequence.new({
                        ColorSequenceKeypoint.new(0, Color3.fromRGB(254, 254, 254)),
                        ColorSequenceKeypoint.new(1, Color3.fromRGB(147, 147, 147)),
                    })
                    keyGrad.Parent = keyIcon

                    local keyValue = make("TextLabel", {
                        BackgroundTransparency = 1,
                        AutomaticSize = Enum.AutomaticSize.XY,
                        FontFace = Font.new(FONT_FACE, Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
                        Text = default == Enum.KeyCode.Unknown and "NONE" or default.Name,
                        TextColor3 = Color3.new(1, 1, 1),
                        TextSize = 10,
                        Parent = keyHolder,
                    })
                    padding(keyValue, 4, 6, 0, 10)

                    local listening = false
                    keyHolder.InputBegan:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                            listening = true
                            keyValue.Text = "..."
                        end
                    end)
                    UserInputService.InputBegan:Connect(function(input)
                        if not listening then return end
                        if input.UserInputType == Enum.UserInputType.Keyboard then
                            local key = input.KeyCode
                            if key == Enum.KeyCode.Escape then
                                key = Enum.KeyCode.Unknown
                                keyValue.Text = "NONE"
                            else
                                keyValue.Text = key.Name
                            end
                            listening = false
                            if flag then Library.Flags[flag] = key end
                            if cfg.Callback then pcall(cfg.Callback, key) end
                        end
                    end)
                    table.insert(sec.Elements, row)
                    return {
                        Frame = row,
                        Set = function(_, k)
                            keyValue.Text = (k == Enum.KeyCode.Unknown) and "NONE" or k.Name
                            if flag then Library.Flags[flag] = k end
                        end,
                        Get = function() return flag and Library.Flags[flag] or Enum.KeyCode.Unknown end,
                    }
                end

                function sec:AddColorPicker(cfg)
                    cfg = cfg or {}
                    local default = cfg.Default or T.Accent2
                    local flag = cfg.Flag
                    if flag then Library.Flags[flag] = default end
                    local current = default

                    local function hsvToRgb(h, s, v)
                        local i = math.floor(h * 6)
                        local f = h * 6 - i
                        local p = v * (1 - s)
                        local q = v * (1 - f * s)
                        local t = v * (1 - (1 - f) * s)
                        i = i % 6
                        local r, g, b
                        if i == 0 then r, g, b = v, t, p
                        elseif i == 1 then r, g, b = q, v, p
                        elseif i == 2 then r, g, b = p, v, t
                        elseif i == 3 then r, g, b = p, q, v
                        elseif i == 4 then r, g, b = t, p, v
                        else r, g, b = v, p, q end
                        return Color3.new(r, g, b)
                    end
                    local function rgbToHsv(c)
                        local r, g, b = c.R, c.G, c.B
                        local maxc, minc = math.max(r, g, b), math.min(r, g, b)
                        local d = maxc - minc
                        local h = 0
                        if d ~= 0 then
                            if maxc == r then h = ((g - b) / d) % 6
                            elseif maxc == g then h = (b - r) / d + 2
                            else h = (r - g) / d + 4 end
                            h = h / 6
                        end
                        local s = maxc == 0 and 0 or d / maxc
                        return h, s, maxc
                    end
                    local function toHex(c)
                        return string.format("#%02X%02X%02X",
                            math.floor(c.R * 255 + 0.5),
                            math.floor(c.G * 255 + 0.5),
                            math.floor(c.B * 255 + 0.5))
                    end

                    local h, s, v = rgbToHsv(current)

                    local row = make("Frame", {
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1, 0, 0, 30),
                        LayoutOrder = nextOrder(),
                        Parent = holder,
                    })

                    make("TextLabel", {
                        BackgroundTransparency = 1,
                        AnchorPoint = Vector2.new(0, 0.5),
                        AutomaticSize = Enum.AutomaticSize.XY,
                        FontFace = Font.new(FONT_FACE, Enum.FontWeight.Medium, Enum.FontStyle.Normal),
                        Position = UDim2.new(0, 25, 0.5, 0),
                        Text = cfg.Text or "Color",
                        TextColor3 = Color3.new(1, 1, 1),
                        TextSize = 12,
                        Parent = row,
                    })

                    local swatch = make("Frame", {
                        AnchorPoint = Vector2.new(1, 0.5),
                        BackgroundColor3 = current,
                        Position = UDim2.new(1, -23, 0.5, 0),
                        Size = UDim2.fromOffset(24, 13),
                        Parent = row,
                    })
                    corner(swatch, 4)

                    -- Floating popup on ScreenGui
                    local popup = make("Frame", {
                        Name = "ColorPopup",
                        BackgroundColor3 = T.Background,
                        Size = UDim2.fromOffset(220, 180),
                        Visible = false,
                        ZIndex = 200,
                        Parent = screenGui,
                    })
                    corner(popup, 11)
                    stroke(popup, T.Accent, 1, 0.5)

                    local closeBtn = make("TextButton", {
                        AnchorPoint = Vector2.new(1, 0),
                        BackgroundTransparency = 1,
                        Position = UDim2.new(1, -22, 0, 4),
                        Size = UDim2.fromOffset(18, 18),
                        Text = "",
                        ZIndex = 201,
                        AutoButtonColor = false,
                        Parent = popup,
                    })
                    local closeIcon = iconImage(closeBtn, "x", 12, T.Inactive)
                    closeIcon.Position = UDim2.fromScale(0.5, 0.5)
                    closeIcon.AnchorPoint = Vector2.new(0.5, 0.5)

                    local preview = make("Frame", {
                        BackgroundColor3 = current,
                        Position = UDim2.fromOffset(12, 12),
                        Size = UDim2.fromOffset(28, 28),
                        ZIndex = 201,
                        Parent = popup,
                    })
                    corner(preview, 6)

                    local satBox = make("Frame", {
                        BackgroundColor3 = Color3.new(1, 1, 1),
                        Position = UDim2.fromOffset(48, 12),
                        Size = UDim2.fromOffset(130, 120),
                        ZIndex = 201,
                        Parent = popup,
                    })
                    corner(satBox, 6)
                    local satFill = make("Frame", {
                        BackgroundColor3 = hsvToRgb(h, 1, 1),
                        Size = UDim2.new(1, 0, 1, 0),
                        BorderSizePixel = 0,
                        ZIndex = 201,
                        Parent = satBox,
                    })
                    corner(satFill, 6)
                    local whiteGrad = Instance.new("UIGradient")
                    whiteGrad.Transparency = NumberSequence.new({
                        NumberSequenceKeypoint.new(0, 0),
                        NumberSequenceKeypoint.new(1, 1),
                    })
                    whiteGrad.Parent = satFill
                    local blackOverlay = make("Frame", {
                        BackgroundColor3 = Color3.new(0, 0, 0),
                        Size = UDim2.new(1, 0, 1, 0),
                        BorderSizePixel = 0,
                        ZIndex = 202,
                        Parent = satBox,
                    })
                    corner(blackOverlay, 6)
                    local blackGrad = Instance.new("UIGradient")
                    blackGrad.Rotation = 90
                    blackGrad.Transparency = NumberSequence.new({
                        NumberSequenceKeypoint.new(0, 1),
                        NumberSequenceKeypoint.new(1, 0),
                    })
                    blackGrad.Parent = blackOverlay
                    local cursor = make("Frame", {
                        BackgroundColor3 = Color3.new(1, 1, 1),
                        Position = UDim2.new(s, -6, 1 - v, -6),
                        Size = UDim2.fromOffset(12, 12),
                        ZIndex = 203,
                        Parent = satBox,
                    })
                    corner(cursor, 6)
                    stroke(cursor, Color3.new(0, 0, 0), 1, 0)

                    local hueBar = make("Frame", {
                        BackgroundColor3 = Color3.new(1, 1, 1),
                        Position = UDim2.fromOffset(186, 12),
                        Size = UDim2.fromOffset(12, 120),
                        ZIndex = 201,
                        Parent = popup,
                    })
                    corner(hueBar, 6)
                    local hueGrad = Instance.new("UIGradient")
                    hueGrad.Rotation = 90
                    hueGrad.Color = ColorSequence.new({
                        ColorSequenceKeypoint.new(0,    Color3.fromRGB(255, 0, 0)),
                        ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 255, 0)),
                        ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)),
                        ColorSequenceKeypoint.new(0.5,  Color3.fromRGB(0, 255, 255)),
                        ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 0, 255)),
                        ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 0, 255)),
                        ColorSequenceKeypoint.new(1,    Color3.fromRGB(255, 0, 0)),
                    })
                    hueGrad.Parent = hueBar
                    local hueCursor = make("Frame", {
                        BackgroundColor3 = Color3.new(1, 1, 1),
                        Position = UDim2.new(0, -2, h, -2),
                        Size = UDim2.new(1, 4, 0, 4),
                        ZIndex = 203,
                        Parent = hueBar,
                    })
                    corner(hueCursor, 2)
                    stroke(hueCursor, Color3.new(0, 0, 0), 1, 0)

                    make("TextLabel", {
                        BackgroundTransparency = 1,
                        Position = UDim2.fromOffset(48, 138),
                        Size = UDim2.fromOffset(60, 14),
                        FontFace = Font.new(FONT_FACE, Enum.FontWeight.Bold, Enum.FontStyle.Normal),
                        Text = "HEX", TextColor3 = T.TextFaint, TextSize = 10,
                        TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 201, Parent = popup,
                    })
                    local hexBox = make("TextBox", {
                        BackgroundColor3 = T.Input,
                        Position = UDim2.fromOffset(48, 154),
                        Size = UDim2.fromOffset(100, 22),
                        Text = toHex(current),
                        FontFace = Font.new(FONT_FACE, Enum.FontWeight.Medium, Enum.FontStyle.Normal),
                        TextColor3 = Color3.new(1, 1, 1),
                        TextSize = 12,
                        ClearTextOnFocus = false,
                        ZIndex = 201, Parent = popup,
                    })
                    corner(hexBox, 4)
                    stroke(hexBox, T.Border, 1, 0)
                    padding(hexBox, 0, 0, 6, 6)

                    local function applyColor(fire)
                        current = hsvToRgb(h, s, v)
                        swatch.BackgroundColor3 = current
                        preview.BackgroundColor3 = current
                        satFill.BackgroundColor3 = hsvToRgb(h, 1, 1)
                        hexBox.Text = toHex(current)
                        if flag then Library.Flags[flag] = current end
                        if fire and cfg.Callback then pcall(cfg.Callback, current) end
                    end

                    local function positionPopup()
                        local ap = swatch.AbsolutePosition
                        local as = swatch.AbsoluteSize
                        local cam = workspace.CurrentCamera
                        local vp = cam and cam.ViewportSize or Vector2.new(1920, 1080)
                        local x = math.clamp(ap.X + as.X - 220, 8, vp.X - 232)
                        local y = math.clamp(ap.Y + as.Y + 6, 8, vp.Y - 188)
                        popup.Position = UDim2.fromOffset(x, y)
                    end

                    local draggingSV, draggingH = false, false
                    satBox.InputBegan:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                            draggingSV = true
                        end
                    end)
                    hueBar.InputBegan:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                            draggingH = true
                        end
                    end)
                    UserInputService.InputChanged:Connect(function(input)
                        if input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch then return end
                        if draggingSV then
                            local relX = math.clamp((input.Position.X - satBox.AbsolutePosition.X) / math.max(satBox.AbsoluteSize.X, 1), 0, 1)
                            local relY = math.clamp((input.Position.Y - satBox.AbsolutePosition.Y) / math.max(satBox.AbsoluteSize.Y, 1), 0, 1)
                            s, v = relX, 1 - relY
                            cursor.Position = UDim2.new(s, -6, 1 - v, -6)
                            applyColor(true)
                        elseif draggingH then
                            local relY = math.clamp((input.Position.Y - hueBar.AbsolutePosition.Y) / math.max(hueBar.AbsoluteSize.Y, 1), 0, 1)
                            h = relY
                            hueCursor.Position = UDim2.new(0, -2, h, -2)
                            applyColor(true)
                        end
                    end)
                    UserInputService.InputEnded:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                            draggingSV, draggingH = false, false
                        end
                    end)
                    hexBox.FocusLost:Connect(function()
                        local hex = hexBox.Text:gsub("#", "")
                        if #hex == 6 then
                            local r = tonumber(hex:sub(1, 2), 16)
                            local g = tonumber(hex:sub(3, 4), 16)
                            local b = tonumber(hex:sub(5, 6), 16)
                            if r and g and b then
                                current = Color3.fromRGB(r, g, b)
                                h, s, v = rgbToHsv(current)
                                cursor.Position = UDim2.new(s, -6, 1 - v, -6)
                                hueCursor.Position = UDim2.new(0, -2, h, -2)
                                applyColor(true)
                            end
                        end
                    end)

                    local open = false
                    local function setOpen(state)
                        open = state
                        if open then positionPopup() end
                        popup.Visible = open
                    end
                    swatch.InputBegan:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                            setOpen(not open)
                        end
                    end)
                    closeBtn.InputBegan:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                            setOpen(false)
                        end
                    end)
                    UserInputService.InputBegan:Connect(function(input)
                        if not open then return end
                        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                            local p = input.Position
                            local pa, ps = popup.AbsolutePosition, popup.AbsoluteSize
                            local sa, ss = swatch.AbsolutePosition, swatch.AbsoluteSize
                            local inPopup = p.X >= pa.X and p.X <= pa.X + ps.X and p.Y >= pa.Y and p.Y <= pa.Y + ps.Y
                            local inSwatch = p.X >= sa.X and p.X <= sa.X + ss.X and p.Y >= sa.Y and p.Y <= sa.Y + ss.Y
                            if not inPopup and not inSwatch then setOpen(false) end
                        end
                    end)

                    table.insert(sec.Elements, row)
                    return {
                        Frame = row,
                        Set = function(_, c)
                            current = c
                            h, s, v = rgbToHsv(c)
                            cursor.Position = UDim2.new(s, -6, 1 - v, -6)
                            hueCursor.Position = UDim2.new(0, -2, h, -2)
                            applyColor(true)
                        end,
                        Get = function() return current end,
                    }
                end

                table.insert(subtab.Sections, sec)
                return sec
            end

            table.insert(tab.Subtabs, subtab)
            -- Auto-select first subtab
            if #tab.Subtabs == 1 then
                subtab:Select()
            else
                rebuildSubtabBar(tab)
            end
            return subtab
        end

        -- Direct CreateSection on a Tab creates a default subtab
        function tab:CreateSection(name, opts)
            local defaultSub
            if #tab.Subtabs == 0 then
                defaultSub = self:AddSubtab("Main")
            else
                defaultSub = tab.Subtabs[1]
            end
            return defaultSub:CreateSection(name, opts)
        end

        table.insert(window.Tabs, tab)

        -- Auto-select first tab (or set Home/Settings)
        if isHome then
            selectTab()
        elseif #window.Tabs == 1 then
            selectTab()
        end
        if isSettings then
            tab.AllowEmptyPage = true
        end
        return tab
    end

    -- ═══════════════════════════════════════════
    -- HOME LAYOUT
    -- ═══════════════════════════════════════════
    function tab:CreateHomeLayout(homeConfig)
        homeConfig = homeConfig or {}

        -- Use a special home subtab
        if #self.Subtabs == 0 then
            self:AddSubtab("Home")
        end
        local subtab = self.Subtabs[1]

        -- Top row: Profile + About
        local topRow = make("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            LayoutOrder = 1,
            Parent = container,
        })
        local trL = Instance.new("UIListLayout")
        trL.FillDirection = Enum.FillDirection.Horizontal
        trL.Padding = UDim.new(0, 20)
        trL.SortOrder = Enum.SortOrder.LayoutOrder
        trL.Parent = topRow

        local profileCard = make("Frame", {
            BackgroundColor3 = T.Panel,
            AutomaticSize = Enum.AutomaticSize.Y,
            Size = UDim2.fromOffset(281, 100),
            Parent = topRow,
        })
        corner(profileCard, 6)
        local avatar = make("ImageLabel", {
            Position = UDim2.fromOffset(14, 14),
            Size = UDim2.fromOffset(56, 56),
            BackgroundColor3 = Color3.fromRGB(18, 18, 24),
            Parent = profileCard,
        })
        corner(avatar, 30)
        local ring = make("Frame", {
            Position = UDim2.fromOffset(12, 12),
            Size = UDim2.fromOffset(60, 60),
            BackgroundColor3 = T.Accent,
            BackgroundTransparency = 1,
            Parent = profileCard,
        })
        corner(ring, 30)
        stroke(ring, T.Accent, 2, 0)
        task.spawn(function()
            local ok, content = pcall(function()
                return Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
            end)
            if ok and content then avatar.Image = content end
        end)
        make("TextLabel", {
            BackgroundTransparency = 1,
            Position = UDim2.fromOffset(84, 24),
            Size = UDim2.new(1, -98, 0, 22),
            FontFace = Font.new(FONT_FACE, Enum.FontWeight.Bold),
            Text = "@" .. (homeConfig.Username or LocalPlayer.DisplayName or LocalPlayer.Name),
            TextColor3 = Color3.new(1, 1, 1), TextSize = 18,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd,
            Parent = profileCard,
        })
        make("TextLabel", {
            BackgroundTransparency = 1,
            Position = UDim2.fromOffset(84, 50),
            Size = UDim2.new(1, -98, 0, 18),
            FontFace = Font.new(FONT_FACE, Enum.FontWeight.Medium),
            Text = homeConfig.Welcome or "welcome back",
            TextColor3 = T.TextDim, TextSize = 13,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = profileCard,
        })

        local aboutCard = make("Frame", {
            BackgroundColor3 = T.Panel,
            AutomaticSize = Enum.AutomaticSize.Y,
            Size = UDim2.fromOffset(281, 100),
            Parent = topRow,
        })
        corner(aboutCard, 6)
        padding(aboutCard, 14, 14, 16, 16)
        make("TextLabel", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 18),
            FontFace = Font.new(FONT_FACE, Enum.FontWeight.Bold),
            Text = homeConfig.AboutTitle or "ABOUT",
            TextColor3 = T.TextDim, TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = aboutCard,
        })
        make("TextLabel", {
            BackgroundTransparency = 1,
            Position = UDim2.fromOffset(0, 24),
            Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            FontFace = Font.new(FONT_FACE, Enum.FontWeight.Medium),
            Text = homeConfig.AboutText or "CYVUI dashboard.",
            TextColor3 = T.TextDim, TextSize = 13,
            TextWrapped = true,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Top,
            Parent = aboutCard,
        })

        -- Middle row: Discord + Server + Executor
        local midRow = make("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            LayoutOrder = 2,
            Parent = container,
        })
        local mrL = Instance.new("UIListLayout")
        mrL.FillDirection = Enum.FillDirection.Horizontal
        mrL.Padding = UDim.new(0, 20)
        mrL.SortOrder = Enum.SortOrder.LayoutOrder
        mrL.Parent = midRow

        local discordCard = make("Frame", {
            BackgroundColor3 = T.Panel,
            AutomaticSize = Enum.AutomaticSize.Y,
            Size = UDim2.fromOffset(281, 96),
            Parent = midRow,
        })
        corner(discordCard, 6)
        padding(discordCard, 14, 14, 14, 14)
        local dHeader = make("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 18), Parent = discordCard })
        iconImage(dHeader, "message-circle", 14, T.Muted).Position = UDim2.new(0, 0, 0.5, -7)
        make("TextLabel", {
            BackgroundTransparency = 1, Position = UDim2.new(0, 20, 0, 0), Size = UDim2.new(1, -20, 1, 0),
            FontFace = Font.new(FONT_FACE, Enum.FontWeight.Bold),
            Text = "Discord", TextColor3 = Color3.new(1, 1, 1), TextSize = 13,
            TextXAlignment = Enum.TextXAlignment.Left, Parent = dHeader,
        })
        local copyBtn = make("TextButton", {
            BackgroundColor3 = T.Input,
            Position = UDim2.new(0, 0, 0, 32),
            Size = UDim2.new(1, 0, 0, 34),
            Text = "", AutoButtonColor = false,
            Parent = discordCard,
        })
        corner(copyBtn, 4)
        stroke(copyBtn, T.Border, 1, 0)
        make("TextLabel", {
            BackgroundTransparency = 1, AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.fromScale(0.5, 0.5), AutomaticSize = Enum.AutomaticSize.XY,
            FontFace = Font.new(FONT_FACE, Enum.FontWeight.Bold),
            Text = "Copy Link", TextColor3 = Color3.new(1, 1, 1), TextSize = 12,
            Parent = copyBtn,
        })
        copyBtn.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                local link = homeConfig.DiscordLink or "https://discord.gg/vTe3sNTsDM"
                if setclipboard then setclipboard(link); Library:Notify("Discord", "Invite copied!", 2, "success")
                else Library:Notify("Discord", link, 4) end
            end
        end)

        local serverCard = make("Frame", {
            BackgroundColor3 = T.Panel,
            AutomaticSize = Enum.AutomaticSize.Y,
            Size = UDim2.fromOffset(281, 96),
            Parent = midRow,
        })
        corner(serverCard, 6)
        padding(serverCard, 14, 14, 16, 16)
        local sHeader = make("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 18), Parent = serverCard })
        iconImage(sHeader, "server", 14, T.Muted).Position = UDim2.new(0, 0, 0.5, -7)
        make("TextLabel", {
            BackgroundTransparency = 1, Position = UDim2.new(0, 20, 0, 0), Size = UDim2.new(1, -20, 1, 0),
            FontFace = Font.new(FONT_FACE, Enum.FontWeight.Bold),
            Text = "Server Info", TextColor3 = Color3.new(1, 1, 1), TextSize = 13,
            TextXAlignment = Enum.TextXAlignment.Left, Parent = sHeader,
        })
        local statsRow = make("Frame", {
            BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 40),
            Position = UDim2.new(0, 0, 0, 32), Parent = serverCard,
        })
        local function makeStat(i, label)
            local cell = make("Frame", {
                BackgroundTransparency = 1, Size = UDim2.new(1 / 3, -4, 1, 0),
                Position = UDim2.new((i - 1) / 3, 0, 0, 0), Parent = statsRow,
            })
            local num = make("TextLabel", {
                BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 22),
                FontFace = Font.new(FONT_FACE, Enum.FontWeight.Bold),
                Text = "—", TextColor3 = Color3.new(1, 1, 1), TextSize = 18,
                TextXAlignment = Enum.TextXAlignment.Left, Parent = cell,
            })
            make("TextLabel", {
                BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 14),
                Position = UDim2.new(0, 0, 0, 24),
                FontFace = Font.new(FONT_FACE, Enum.FontWeight.Medium),
                Text = label, TextColor3 = T.TextFaint, TextSize = 10,
                TextXAlignment = Enum.TextXAlignment.Left, Parent = cell,
            })
            return num
        end
        local playersLbl = makeStat(1, "PLAYERS")
        local uptimeLbl = makeStat(2, "UPTIME")
        local pingLbl = makeStat(3, "PING")

        local sessionStart = os.clock()
        local function formatUptime(sec)
            sec = math.floor(sec)
            local h = math.floor(sec / 3600)
            local m = math.floor((sec % 3600) / 60)
            local s = sec % 60
            if h > 0 then return string.format("%dh %dm", h, m) end
            if m > 0 then return string.format("%dm %ds", m, s) end
            return string.format("%ds", s)
        end
        local function refreshServerStats()
            playersLbl.Text = tostring(#Players:GetPlayers())
            uptimeLbl.Text = formatUptime(os.clock() - sessionStart)
            local pingMs = 0
            pcall(function()
                pingMs = math.floor((LocalPlayer:GetNetworkPing() or 0) * 1000)
            end)
            if pingMs <= 0 then
                pcall(function()
                    local Stats = game:GetService("Stats")
                    local net = Stats.Network
                    local pingStat = net.ServerStatsItem and net.ServerStatsItem["Data Ping"]
                    if pingStat then
                        local v = pingStat:GetValue()
                        pingMs = math.floor(tonumber(v) or 0)
                    end
                end)
            end
            pingLbl.Text = tostring(pingMs) .. "ms"
        end
        refreshServerStats()
        task.spawn(function()
            while serverCard.Parent do
                refreshServerStats()
                task.wait(1)
            end
        end)

        local execCard = make("Frame", {
            BackgroundColor3 = T.Panel,
            AutomaticSize = Enum.AutomaticSize.Y,
            Size = UDim2.fromOffset(281, 96),
            Parent = midRow,
        })
        corner(execCard, 6)
        padding(execCard, 12, 12, 12, 12)
        local eHeader = make("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 18), Parent = execCard })
        iconImage(eHeader, "terminal", 14, T.Muted).Position = UDim2.new(0, 0, 0.5, -7)
        make("TextLabel", {
            BackgroundTransparency = 1, Position = UDim2.new(0, 20, 0, 0), Size = UDim2.new(1, -20, 1, 0),
            FontFace = Font.new(FONT_FACE, Enum.FontWeight.Bold),
            Text = "Executor", TextColor3 = Color3.new(1, 1, 1), TextSize = 13,
            TextXAlignment = Enum.TextXAlignment.Left, Parent = eHeader,
        })
        local execBox = make("Frame", {
            BackgroundColor3 = T.Input,
            Position = UDim2.new(0, 0, 0, 32),
            Size = UDim2.new(1, 0, 0, 34),
            ClipsDescendants = true, Parent = execCard,
        })
        corner(execBox, 4)
        stroke(execBox, T.Border, 1, 0)
        make("TextLabel", {
            BackgroundTransparency = 1, Size = UDim2.new(1, -64, 1, 0), Position = UDim2.fromOffset(10, 0),
            FontFace = Font.new(FONT_FACE, Enum.FontWeight.Medium),
            Text = homeConfig.ExecutorName or (identifyexecutor and identifyexecutor() or "Unknown"),
            TextColor3 = T.TextDim, TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd, Parent = execBox,
        })
        local badge = make("TextLabel", {
            BackgroundColor3 = Color3.fromRGB(20, 50, 55),
            Size = UDim2.fromOffset(46, 18),
            Position = UDim2.new(1, -50, 0.5, -9),
            Text = "Active",
            FontFace = Font.new(FONT_FACE, Enum.FontWeight.Bold),
            TextColor3 = T.Accent2, TextSize = 10,
            Parent = execBox,
        })
        corner(badge, 4)

        -- Changelog row (single column)
        local changeCard = make("Frame", {
            Name = "Changelog",
            BackgroundColor3 = T.Panel,
            AutomaticSize = Enum.AutomaticSize.Y,
            Size = UDim2.new(1, 0, 0, 200),
            LayoutOrder = 3,
            Parent = container,
        })
        corner(changeCard, 6)
        padding(changeCard, 14, 14, 16, 16)
        local chHeader = make("Frame", {
            BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 22), Parent = changeCard,
        })
        iconImage(chHeader, "scroll-text", 14, T.Muted).Position = UDim2.new(0, 0, 0.5, -7)
        make("TextLabel", {
            BackgroundTransparency = 1, Position = UDim2.new(0, 20, 0, 0), Size = UDim2.new(0.5, 0, 1, 0),
            FontFace = Font.new(FONT_FACE, Enum.FontWeight.Bold),
            Text = "Changelog", TextColor3 = Color3.new(1, 1, 1), TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left, Parent = chHeader,
        })
        local entries = homeConfig.Changelog or {
            { Version = "v1.1.0", Date = "2026-09-04", Text = "Ironite-inspired redesign: header, sidebar, subtab row, two-column page." },
            { Version = "v1.0.4", Date = "2026-08-31", Text = "Mobile toggle, floating color popup, Settings spacing/theme highlight fixes." },
            { Version = "v1.0.3", Date = "2026-08-30", Text = "Popup color picker, CreateRow two-column layouts, improved Home changelog cards." },
            { Version = "v1.0.2", Date = "2026-08-30", Text = "Working color picker, multi-select dropdown + search/All, live server stats." },
            { Version = "v1.0.1", Date = "2026-08-29", Text = "Notification redesign, badge overflow fix, new banner." },
            { Version = "v1.0.0", Date = "2026-08-29", Text = "Initial CYVUI release." },
        }
        local changeScroll = make("ScrollingFrame", {
            BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, -28),
            Position = UDim2.new(0, 0, 0, 28),
            CanvasSize = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            ScrollBarThickness = 2, ScrollBarImageColor3 = T.ScrollBar,
            BorderSizePixel = 0, Parent = changeCard,
        })
        listLayout(changeScroll, 8)
        for i, entry in ipairs(entries) do
            local card = make("Frame", {
                BackgroundColor3 = Color3.fromRGB(13, 14, 19),
                Size = UDim2.new(1, -4, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                LayoutOrder = i, Parent = changeScroll,
            })
            corner(card, 4)
            stroke(card, i == 1 and T.Accent or T.Border, 1, i == 1 and 0.5 or 0)
            padding(card, 10, 10, 12, 12)
            listLayout(card, 6)
            local head = make("Frame", {
                BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 20), Parent = card,
            })
            local ver = make("TextLabel", {
                BackgroundColor3 = i == 1 and Color3.fromRGB(40, 28, 70) or Color3.fromRGB(24, 25, 32),
                Size = UDim2.fromOffset(54, 18),
                Text = entry.Version or "?",
                FontFace = Font.new(FONT_FACE, Enum.FontWeight.Bold),
                TextColor3 = i == 1 and Color3.new(1, 1, 1) or T.Muted,
                TextSize = 11, Parent = head,
            })
            corner(ver, 4)
            make("TextLabel", {
                BackgroundTransparency = 1, Position = UDim2.fromOffset(62, 0),
                Size = UDim2.new(0.5, 0, 1, 0),
                FontFace = Font.new(FONT_FACE, Enum.FontWeight.Medium),
                Text = entry.Date or "", TextColor3 = T.TextFaint, TextSize = 11,
                TextXAlignment = Enum.TextXAlignment.Left, Parent = head,
            })
            if i == 1 then
                local lat = make("TextLabel", {
                    BackgroundColor3 = Color3.fromRGB(20, 50, 55),
                    Size = UDim2.fromOffset(48, 16),
                    Position = UDim2.new(1, -48, 0.5, -8),
                    Text = "Latest",
                    FontFace = Font.new(FONT_FACE, Enum.FontWeight.Bold),
                    TextColor3 = T.Accent2, TextSize = 10, Parent = head,
                })
                corner(lat, 4)
            end
            local bodyText = entry.Text or ""
            if entry.Items and type(entry.Items) == "table" then
                bodyText = "• " .. table.concat(entry.Items, "\n• ")
            end
            make("TextLabel", {
                BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                FontFace = Font.new(FONT_FACE, Enum.FontWeight.Medium),
                Text = bodyText, TextColor3 = T.TextDim, TextSize = 12,
                TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left,
                Parent = card,
            })
        end

        table.insert(subtab.Tab.ContainerRows, topRow)
        table.insert(subtab.Tab.ContainerRows, midRow)
        table.insert(subtab.Tab.ContainerRows, changeCard)
        topRow.Subtab  = subtab
        midRow.Subtab  = subtab
        changeCard.Subtab = subtab
        subtab:Select()
    end

    -- ═══════════════════════════════════════════
    -- SETTINGS LAYOUT
    -- ═══════════════════════════════════════════
    function tab:CreateSettingsLayout(setConfig)
        setConfig = setConfig or {}
        if #self.Subtabs == 0 then
            self:AddSubtab("Settings")
        end
        local subtab = self.Subtabs[1]

        local themeSec = subtab:CreateSection("Theme", { Icon = "palette" })
        local presets = setConfig.Themes or {
            { Name = "Default", Accent = Color3.fromRGB(254, 254, 254), Accent2 = Color3.fromRGB(34, 211, 238) },
            { Name = "Mono",    Accent = Color3.fromRGB(226, 232, 240), Accent2 = Color3.fromRGB(148, 163, 184) },
            { Name = "Blue",    Accent = Color3.fromRGB(96, 165, 250),  Accent2 = Color3.fromRGB(129, 140, 248) },
        }
        local presetRow = make("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 30),
            LayoutOrder = 1, Parent = themeSec.Holder,
        })
        local activeStroke
        for i, p in ipairs(presets) do
            local sw = make("TextButton", {
                BackgroundColor3 = p.Accent,
                Size = UDim2.fromOffset(26, 26),
                Position = UDim2.new(0, (i - 1) * 34, 0, 2),
                Text = "", AutoButtonColor = false,
                Parent = presetRow,
            })
            corner(sw, 13)
            local st = stroke(sw, Color3.fromRGB(255, 255, 255), 2, 1)
            if i == 1 then st.Transparency = 0; activeStroke = st end
            sw.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    if activeStroke then activeStroke.Transparency = 1 end
                    st.Transparency = 0
                    activeStroke = st
                    Library:SetTheme(p.Accent, p.Accent2)
                    Library:Notify("Theme", p.Name, 1.6, "success")
                    if setConfig.OnTheme then pcall(setConfig.OnTheme, p) end
                end
            end)
        end

        themeSec:AddSlider({
            Text = "UI Transparency", Min = 40, Max = 100, Default = 100, Flag = "UITransparency",
            Callback = function(v)
                Library.Flags.UITransparency = v
                local alpha = math.clamp(v / 100, 0.4, 1)
                if window.Main then
                    for _, d in ipairs(window.Main:GetDescendants()) do
                        if d:IsA("Frame") and d.Name ~= "Header" and d.BackgroundColor3 == T.Panel then
                            d.BackgroundTransparency = 1 - alpha
                        end
                    end
                end
            end,
        })

        local configSec = subtab:CreateSection("Config", { Icon = "bookmark" })
        configSec:AddDropdown({
            Text = "Load Config",
            Options = setConfig.Configs or { "default" },
            Default = "default",
            Flag = "ConfigName",
        })
        configSec:AddButton({ Text = "Save Config", Color = T.Accent2, Callback = function()
            if setConfig.OnSave then pcall(setConfig.OnSave) else Library:Notify("Config", "Saved flags locally", 2, "success") end
        end })
        configSec:AddButton({ Text = "Load Config", Callback = function()
            if setConfig.OnLoad then pcall(setConfig.OnLoad) else Library:Notify("Config", "No loader hooked", 2, "warning") end
        end })
        configSec:AddToggle({ Text = "Auto Load On Join", Default = true, Flag = "AutoLoad" })

        local gen = subtab:CreateSection("General", { Icon = "settings" })
        gen:AddKeybind({ Text = "Minimize Keybind", Default = Enum.KeyCode.LeftControl, Flag = "MinimizeKey" })
        gen:AddToggle({ Text = "Watermark", Default = true, Flag = "Watermark" })
        gen:AddToggle({ Text = "Notifications", Default = true, Flag = "Notifications" })
        gen:AddParagraph("Settings are stored locally per-config.")
        gen:AddButton({ Text = "Destroy UI", Callback = function() screenGui:Destroy() end })
    end

    -- ═══════════════════════════════════════════
    -- KEYBOARD HANDLERS
    -- ═══════════════════════════════════════════
    local function toggleUI()
        main.Visible = not main.Visible
    end
    UserInputService.InputBegan:Connect(function(input, gp)
        if gp then return end
        if input.KeyCode == Enum.KeyCode.RightControl then toggleUI() end
        local mk = Library.Flags.MinimizeKey
        if mk and input.KeyCode == mk then toggleUI() end
    end)

    -- ═══════════════════════════════════════════
    -- MOBILE TOGGLE
    -- ═══════════════════════════════════════════
    if UserInputService.TouchEnabled or config.MobileToggle == true then
        local mobileBtn = make("TextButton", {
            Name = "CYVUI_MobileToggle",
            BackgroundColor3 = T.Accent,
            Size = UDim2.fromOffset(52, 52),
            Position = UDim2.new(1, -68, 0.5, -26),
            Text = "",
            AutoButtonColor = false,
            ZIndex = 300,
            Parent = screenGui,
        })
        corner(mobileBtn, 16)
        stroke(mobileBtn, Color3.new(1, 1, 1), 1, 0.7)
        make("ImageLabel", {
            BackgroundTransparency = 1,
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.fromScale(0.5, 0.5),
            Size = UDim2.fromOffset(24, 24),
            Image = Library:GetIcon("layout"),
            ImageColor3 = Color3.new(1, 1, 1),
            ZIndex = 301,
            Parent = mobileBtn,
        })
        makeDraggable(mobileBtn, mobileBtn)
        mobileBtn.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                toggleUI()
            end
        end)
        window.MobileToggle = mobileBtn
    end

    -- Responsive shrink on small viewports
    pcall(function()
        local cam = workspace.CurrentCamera
        if cam and cam.ViewportSize.X < 700 then
            main.Size = UDim2.fromOffset(math.min(size.X.Offset, cam.ViewportSize.X - 24), math.min(size.Y.Offset, cam.ViewportSize.Y - 48))
            main.Position = UDim2.fromScale(0.5, 0.5) - UDim2.fromOffset(main.Size.X.Offset / 2, main.Size.Y.Offset / 2) + UDim2.fromOffset(0, 0)
        end
    end)

    -- Built-in Settings tab (always last in sidebar)
    local settingsTab = window:CreateTab({ Name = "Settings", Icon = "settings", Settings = true })
    settingsTab:CreateSettingsLayout({})

    table.insert(self.Windows, window)
    return window
end

function Library:GetFlag(name) return self.Flags[name] end
function Library:SetFlag(name, value) self.Flags[name] = value end

return Library