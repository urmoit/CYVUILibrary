--[[
    CYVUI Library v1.0.1
    Dark modern Roblox UI — dashboard mockup style
    Home + Main widgets + Settings consistent across hubs
    Lucide icons via Footagesus Icons v2
]]

local Players          = game:GetService("Players")
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService       = game:GetService("RunService")
local HttpService      = game:GetService("HttpService")
local CoreGui          = game:GetService("CoreGui")
local TextService      = game:GetService("TextService")

local LocalPlayer = Players.LocalPlayer

local Library = {
    Version     = "1.0.1",
    Name        = "CYVUI",
    Windows     = {},
    Flags       = {},
    Theme       = {},
    Connections = {},
    _Lucide     = nil,
}

-- ═══════════════════════════════════════════
-- THEME (dashboard CSS vars)
-- ═══════════════════════════════════════════
Library.Theme = {
    Background   = Color3.fromRGB(10, 10, 13),
    Sidebar      = Color3.fromRGB(12, 12, 15),
    Panel        = Color3.fromRGB(24, 24, 30),
    PanelHover   = Color3.fromRGB(30, 30, 38),
    Input        = Color3.fromRGB(22, 22, 28),
    Border       = Color3.fromRGB(40, 40, 48),
    Accent       = Color3.fromRGB(139, 92, 246),
    Accent2      = Color3.fromRGB(34, 211, 238),
    AccentSoft   = Color3.fromRGB(40, 30, 60),
    Text         = Color3.fromRGB(243, 243, 246),
    TextDim      = Color3.fromRGB(154, 154, 166),
    TextFaint    = Color3.fromRGB(94, 94, 107),
    Success      = Color3.fromRGB(74, 222, 128),
    Warning      = Color3.fromRGB(250, 204, 21),
    Error        = Color3.fromRGB(248, 113, 113),
    ToggleOff    = Color3.fromRGB(40, 40, 48),
    ToggleOn     = Color3.fromRGB(139, 92, 246),
    ScrollBar    = Color3.fromRGB(60, 60, 70),
    TitleBar     = Color3.fromRGB(10, 10, 13),
    TrafficGreen = Color3.fromRGB(39, 201, 63),
    TrafficYellow= Color3.fromRGB(255, 189, 46),
    TrafficRed   = Color3.fromRGB(255, 95, 86),
}

local T = Library.Theme
local themeBindings = {} -- { inst, prop, key } key is Theme field name or "Accent"/"Accent2"

local function bindTheme(inst, prop, key)
    table.insert(themeBindings, { inst = inst, prop = prop, key = key })
    if inst and prop and T[key] ~= nil then
        inst[prop] = T[key]
    end
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
    if accent then
        T.Accent = accent
        T.ToggleOn = accent
        T.AccentSoft = Color3.new(accent.R * 0.35, accent.G * 0.25, accent.B * 0.45)
    end
    if accent2 then
        T.Accent2 = accent2
    end
    applyTheme()
end

-- ═══════════════════════════════════════════
-- LUCIDE
-- ═══════════════════════════════════════════
local LUCIDE_FALLBACK = {
    house = "rbxassetid://98755624629571",
    home = "rbxassetid://98755624629571",
    code = "rbxassetid://107380207681249",
    layout = "rbxassetid://107380207681249",
    wrench = "rbxassetid://112148279212860",
    settings = "rbxassetid://80758916183665",
    x = "rbxassetid://110786993356448",
    ["message-circle"] = "rbxassetid://127255077587058",
    server = "rbxassetid://15269177520",
    terminal = "rbxassetid://10734982144",
    ["scroll-text"] = "rbxassetid://10734982144",
    user = "rbxassetid://10734982144",
    eye = "rbxassetid://10734982144",
    clock = "rbxassetid://10734984606",
    info = "rbxassetid://10734982144",
    palette = "rbxassetid://80758916183665",
    bookmark = "rbxassetid://10734982144",
    keyboard = "rbxassetid://10734982144",
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
local function corner(parent, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r or 10)
    c.Parent = parent
    return c
end

local function stroke(parent, color, thickness, transparency)
    local s = Instance.new("UIStroke")
    s.Color = color or T.Border
    s.Thickness = thickness or 1
    s.Transparency = transparency or 0.5
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
    l.Padding = UDim.new(0, pad or 8)
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

local function create(class, props)
    local inst = Instance.new(class)
    for k, v in pairs(props or {}) do
        if k ~= "Parent" then inst[k] = v end
    end
    if props and props.Parent then inst.Parent = props.Parent end
    return inst
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
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    handle.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local d = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
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
    local fast = TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
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
    local img = create("ImageLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.new(0, size or 16, 0, size or 16),
        Image = Library:GetIcon(name),
        ImageColor3 = color or T.TextDim,
        ScaleType = Enum.ScaleType.Fit,
        Parent = parent,
    })
    if themeKey then
        bindTheme(img, "ImageColor3", themeKey)
    end
    return img
end

-- ═══════════════════════════════════════════
-- NOTIFY
-- ═══════════════════════════════════════════
function Library:Notify(title, message, duration, notifType)
    duration = duration or 3
    notifType = (notifType or "info"):lower()

    local styles = {
        success = {
            accent = Color3.fromRGB(34, 197, 94),
            bg = Color3.fromRGB(12, 28, 18),
            border = Color3.fromRGB(34, 197, 94),
            title = "Success",
            icon = "circle-check",
        },
        warning = {
            accent = Color3.fromRGB(234, 179, 8),
            bg = Color3.fromRGB(32, 26, 10),
            border = Color3.fromRGB(234, 179, 8),
            title = "Warning",
            icon = "triangle-alert",
        },
        error = {
            accent = Color3.fromRGB(239, 68, 68),
            bg = Color3.fromRGB(32, 12, 14),
            border = Color3.fromRGB(239, 68, 68),
            title = "Error",
            icon = "circle-x",
        },
        info = {
            accent = T.Accent2,
            bg = Color3.fromRGB(16, 20, 32),
            border = T.Accent2,
            title = "Info",
            icon = "info",
        },
    }
    local style = styles[notifType] or styles.info
    local displayTitle = title or style.title

    if not self._NotifyHolder or not self._NotifyHolder.Parent then
        local holder = create("ScreenGui", {
            Name = "CYVUI_Notifications",
            ResetOnSpawn = false,
            DisplayOrder = 999,
            ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        })
        protectGui(holder)
        self._NotifyHolder = holder
        local list = create("Frame", {
            Name = "List",
            BackgroundTransparency = 1,
            Size = UDim2.new(0, 340, 0, 420),
            Position = UDim2.new(1, -360, 0, 18),
            Parent = holder,
        })
        local lay = listLayout(list, 10)
        lay.VerticalAlignment = Enum.VerticalAlignment.Top
        lay.HorizontalAlignment = Enum.HorizontalAlignment.Right
        self._NotifyList = list
    end

    -- Cap stacked notifications
    local count = 0
    for _, c in ipairs(self._NotifyList:GetChildren()) do
        if c:IsA("Frame") then count += 1 end
    end
    if count >= 4 then
        for _, c in ipairs(self._NotifyList:GetChildren()) do
            if c:IsA("Frame") then c:Destroy(); break end
        end
    end

    local card = create("Frame", {
        BackgroundColor3 = style.bg,
        Size = UDim2.new(0, 300, 0, 72),
        ClipsDescendants = true,
        Parent = self._NotifyList,
    })
    corner(card, 14)
    local cardStroke = stroke(card, style.border, 1.5, 0.15)

    -- Left accent glow bar
    local bar = create("Frame", {
        BackgroundColor3 = style.accent,
        Size = UDim2.new(0, 3, 1, 0),
        BorderSizePixel = 0,
        Parent = card,
    })
    corner(bar, 2)

    -- Icon circle
    local iconWrap = create("Frame", {
        BackgroundColor3 = style.accent,
        BackgroundTransparency = 0.85,
        Size = UDim2.new(0, 28, 0, 28),
        Position = UDim2.new(0, 14, 0.5, -14),
        Parent = card,
    })
    corner(iconWrap, 14)
    local iconStroke = stroke(iconWrap, style.accent, 1, 0.35)
    local iconImg = create("ImageLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 16, 0, 16),
        Position = UDim2.new(0.5, -8, 0.5, -8),
        Image = Library:GetIcon(style.icon),
        ImageColor3 = style.accent,
        ScaleType = Enum.ScaleType.Fit,
        Parent = iconWrap,
    })

    local titleLbl = create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 52, 0, 12),
        Size = UDim2.new(1, -88, 0, 18),
        Font = Enum.Font.GothamBold,
        Text = displayTitle,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = card,
    })
    local msgLbl = create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 52, 0, 32),
        Size = UDim2.new(1, -88, 0, 28),
        Font = Enum.Font.Gotham,
        Text = message or "",
        TextColor3 = Color3.fromRGB(200, 200, 210),
        TextSize = 12,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        Parent = card,
    })

    -- Close button
    local closeBtn = create("TextButton", {
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 22, 0, 22),
        Position = UDim2.new(1, -28, 0, 8),
        Text = "",
        AutoButtonColor = false,
        Parent = card,
    })
    local closeIcon = create("ImageLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 12, 0, 12),
        Position = UDim2.new(0.5, -6, 0.5, -6),
        Image = Library:GetIcon("x"),
        ImageColor3 = Color3.fromRGB(160, 160, 170),
        ScaleType = Enum.ScaleType.Fit,
        Parent = closeBtn,
    })

    local function dismiss()
        if not card or not card.Parent then return end
        tween(card, { BackgroundTransparency = 1 }, 0.18)
        tween(titleLbl, { TextTransparency = 1 }, 0.18)
        tween(msgLbl, { TextTransparency = 1 }, 0.18)
        tween(cardStroke, { Transparency = 1 }, 0.18)
        tween(iconImg, { ImageTransparency = 1 }, 0.18)
        tween(closeIcon, { ImageTransparency = 1 }, 0.18)
        task.delay(0.2, function()
            if card and card.Parent then card:Destroy() end
        end)
    end
    closeBtn.MouseButton1Click:Connect(dismiss)
    closeBtn.MouseEnter:Connect(function()
        closeIcon.ImageColor3 = Color3.fromRGB(255, 255, 255)
    end)
    closeBtn.MouseLeave:Connect(function()
        closeIcon.ImageColor3 = Color3.fromRGB(160, 160, 170)
    end)

    -- Enter animation
    card.BackgroundTransparency = 1
    titleLbl.TextTransparency = 1
    msgLbl.TextTransparency = 1
    cardStroke.Transparency = 1
    iconImg.ImageTransparency = 1
    tween(card, { BackgroundTransparency = 0 }, 0.2)
    tween(titleLbl, { TextTransparency = 0 }, 0.2)
    tween(msgLbl, { TextTransparency = 0 }, 0.2)
    tween(cardStroke, { Transparency = 0.15 }, 0.2)
    tween(iconImg, { ImageTransparency = 0 }, 0.2)

    task.delay(duration, dismiss)
end


function Library:CreateWindow(config)
    config = config or {}
    local title    = config.Title or "CYVHUB"
    local gameName = config.GameName or "game name"
    local version  = config.Version or "v1.0.1"
    local size     = config.Size or UDim2.new(0, 900, 0, 560)

    for _, old in ipairs(self.Windows) do
        if old and old.ScreenGui then old.ScreenGui:Destroy() end
    end
    table.clear(self.Windows)

    local screenGui = create("ScreenGui", {
        Name = "CYVUI_" .. HttpService:GenerateGUID(false):sub(1, 8),
        ResetOnSpawn = false, ZIndexBehavior = Enum.ZIndexBehavior.Sibling, DisplayOrder = 50,
    })
    protectGui(screenGui)

    local main = create("Frame", {
        Name = "Main", BackgroundColor3 = T.Background, Size = size,
        Position = UDim2.new(0.5, -size.X.Offset / 2, 0.5, -size.Y.Offset / 2),
        BorderSizePixel = 0, ClipsDescendants = true, Parent = screenGui,
    })
    corner(main, 16)
    stroke(main, T.Border, 1, 0.4)

    -- Title bar
    local titleBar = create("Frame", {
        Name = "TitleBar", BackgroundColor3 = T.TitleBar, Size = UDim2.new(1, 0, 0, 40),
        BorderSizePixel = 0, Parent = main,
    })
    corner(titleBar, 16)
    create("Frame", {
        BackgroundColor3 = T.TitleBar, Size = UDim2.new(1, 0, 0, 14),
        Position = UDim2.new(0, 0, 1, -14), BorderSizePixel = 0, Parent = titleBar,
    })
    create("Frame", {
        BackgroundColor3 = T.Border, BackgroundTransparency = 0.5,
        Size = UDim2.new(1, 0, 0, 1), Position = UDim2.new(0, 0, 1, 0), BorderSizePixel = 0, Parent = titleBar,
    })

    local titleText = create("TextLabel", {
        BackgroundTransparency = 1, Position = UDim2.new(0, 16, 0, 0), Size = UDim2.new(0.6, 0, 1, 0),
        Font = Enum.Font.GothamBold, Text = string.format("%s  |  %s  |  %s", title, gameName, version),
        TextColor3 = T.TextDim, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, Parent = titleBar,
    })

    local traffic = create("Frame", {
        BackgroundTransparency = 1, Size = UDim2.new(0, 70, 1, 0), Position = UDim2.new(1, -78, 0, 0), Parent = titleBar,
    })
    listLayout(traffic, 8, Enum.FillDirection.Horizontal)
    padding(traffic, 0, 0, 0, 10)
    local trafficLayout = traffic:FindFirstChildOfClass("UIListLayout")
    if trafficLayout then
        trafficLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
        trafficLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    end

    local contentHolder
    local minimized = false

    local function trafficBtn(color, cb)
        local btn = create("TextButton", {
            BackgroundColor3 = color, Size = UDim2.new(0, 12, 0, 12), Text = "", AutoButtonColor = false, Parent = traffic,
        })
        corner(btn, 6)
        btn.MouseButton1Click:Connect(function() if cb then cb() end end)
        return btn
    end

    trafficBtn(T.TrafficGreen, function() end)
    trafficBtn(T.TrafficYellow, function()
        minimized = not minimized
        if contentHolder then contentHolder.Visible = not minimized end
        main.Size = minimized and UDim2.new(0, size.X.Offset, 0, 40) or size
    end)
    trafficBtn(T.TrafficRed, function() screenGui:Destroy() end)

    makeDraggable(main, titleBar)

    contentHolder = create("Frame", {
        Name = "Content", BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, -40), Position = UDim2.new(0, 0, 0, 40), Parent = main,
    })

    -- Sidebar
    local sidebar = create("Frame", {
        Name = "Sidebar", BackgroundColor3 = T.Sidebar, Size = UDim2.new(0, 170, 1, 0), BorderSizePixel = 0, Parent = contentHolder,
    })
    create("Frame", {
        BackgroundColor3 = T.Border, BackgroundTransparency = 0.5,
        Size = UDim2.new(0, 1, 1, 0), Position = UDim2.new(1, -1, 0, 0), BorderSizePixel = 0, Parent = sidebar,
    })

    local sidebarList = create("Frame", {
        Name = "Tabs", BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, -56), Position = UDim2.new(0, 0, 0, 12), Parent = sidebar,
    })
    listLayout(sidebarList, 4)
    padding(sidebarList, 0, 0, 10, 10)

    local settingsBtn = create("TextButton", {
        Name = "SettingsTab", BackgroundTransparency = 1,
        Size = UDim2.new(1, -20, 0, 40), Position = UDim2.new(0, 10, 1, -50),
        Text = "", AutoButtonColor = false, Parent = sidebar,
    })
    corner(settingsBtn, 10)
    local settingsIcon = iconImage(settingsBtn, "settings", 16, T.TextDim)
    settingsIcon.Position = UDim2.new(0, 12, 0.5, -8)
    local settingsLabel = create("TextLabel", {
        BackgroundTransparency = 1, Size = UDim2.new(1, -44, 1, 0), Position = UDim2.new(0, 36, 0, 0),
        Font = Enum.Font.GothamMedium, Text = "Settings", TextColor3 = T.TextDim, TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left, Parent = settingsBtn,
    })

    local pages = create("Frame", {
        Name = "Pages", BackgroundTransparency = 1,
        Size = UDim2.new(1, -190, 1, -16), Position = UDim2.new(0, 178, 0, 8), Parent = contentHolder,
    })

    local window = {
        ScreenGui = screenGui, Main = main, TitleBar = titleBar, Sidebar = sidebar,
        SidebarList = sidebarList, Pages = pages, SettingsBtn = settingsBtn,
        Tabs = {}, CurrentTab = nil, Config = config,
    }

    function window:SetTitle(t, g, v)
        titleText.Text = string.format("%s  |  %s  |  %s", t or title, g or gameName, v or version)
    end

    -- ── Tab ──
    function window:CreateTab(tabConfig)
        tabConfig = tabConfig or {}
        local tabName = tabConfig.Name or "Tab"
        local tabIcon = tabConfig.Icon or "house"
        local isHome  = tabConfig.Home == true
        local isSettings = tabConfig.Settings == true

        local tabBtn
        if isSettings then
            tabBtn = settingsBtn
        else
            tabBtn = create("TextButton", {
                Name = tabName .. "Tab", BackgroundTransparency = isHome and 0 or 1,
                BackgroundColor3 = isHome and T.AccentSoft or Color3.new(0, 0, 0),
                Size = UDim2.new(1, 0, 0, 40), Text = "", AutoButtonColor = false,
                LayoutOrder = #window.Tabs + 1, Parent = sidebarList,
            })
            corner(tabBtn, 10)
            if isHome then
                local hs = stroke(tabBtn, T.Accent, 1, 0.55)
                bindTheme(hs, "Color", "Accent")
            end
        end

        local iconImg = tabBtn:FindFirstChildOfClass("ImageLabel")
        if not iconImg then
            iconImg = iconImage(tabBtn, tabIcon, 16, isHome and T.Text or T.TextDim)
            iconImg.Position = UDim2.new(0, 12, 0.5, -8)
        else
            iconImg.Image = Library:GetIcon(tabIcon)
            iconImg.ImageColor3 = isHome and T.Text or T.TextDim
        end

        local nameLbl = tabBtn:FindFirstChild("Label") or tabBtn:FindFirstChildWhichIsA("TextLabel")
        if not nameLbl or nameLbl == settingsLabel then
            if not isSettings then
                nameLbl = create("TextLabel", {
                    Name = "Label", BackgroundTransparency = 1,
                    Size = UDim2.new(1, -44, 1, 0), Position = UDim2.new(0, 36, 0, 0),
                    Font = Enum.Font.GothamMedium, Text = tabName,
                    TextColor3 = isHome and T.Text or T.TextDim, TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Left, Parent = tabBtn,
                })
            else
                nameLbl = settingsLabel
            end
        end

        local page = create("ScrollingFrame", {
            Name = tabName .. "Page", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0),
            CanvasSize = UDim2.new(0, 0, 0, 0), ScrollBarThickness = 4,
            ScrollBarImageColor3 = T.ScrollBar, BorderSizePixel = 0,
            Visible = isHome, AutomaticCanvasSize = Enum.AutomaticSize.Y, Parent = pages,
        })
        padding(page, 8, 16, 6, 10)
        local pageLayout = listLayout(page, 14)
        pageLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left

        local tab = {
            Name = tabName, Button = tabBtn, Page = page, Icon = iconImg, Label = nameLbl,
            Sections = {}, IsHome = isHome, IsSettings = isSettings,
        }

        local function selectTab()
            for _, t in ipairs(window.Tabs) do
                t.Page.Visible = false
                if not t.IsSettings then
                    t.Button.BackgroundTransparency = 1
                    t.Button.BackgroundColor3 = Color3.new(0, 0, 0)
                    local st = t.Button:FindFirstChildOfClass("UIStroke")
                    if st then st.Transparency = 1 end
                else
                    t.Button.BackgroundTransparency = 1
                end
                if t.Icon then t.Icon.ImageColor3 = T.TextDim end
                if t.Label then t.Label.TextColor3 = T.TextDim end
            end
            page.Visible = true
            if not isSettings then
                tabBtn.BackgroundTransparency = 0
                tabBtn.BackgroundColor3 = T.AccentSoft
                local st = tabBtn:FindFirstChildOfClass("UIStroke")
                if not st then
                    st = stroke(tabBtn, T.Accent, 1, 0.55)
                    bindTheme(st, "Color", "Accent")
                else
                    st.Transparency = 0.55
                    st.Color = T.Accent
                end
            else
                tabBtn.BackgroundTransparency = 0
                tabBtn.BackgroundColor3 = T.AccentSoft
            end
            if iconImg then iconImg.ImageColor3 = T.Text end
            if nameLbl then nameLbl.TextColor3 = T.Text end
            window.CurrentTab = tab
        end

        tabBtn.MouseButton1Click:Connect(selectTab)
        if not isSettings then
            tabBtn.MouseEnter:Connect(function()
                if window.CurrentTab ~= tab then tween(tabBtn, { BackgroundTransparency = 0.7 }, 0.12) end
            end)
            tabBtn.MouseLeave:Connect(function()
                if window.CurrentTab ~= tab then tween(tabBtn, { BackgroundTransparency = 1 }, 0.12) end
            end)
        end
        if isHome then window.CurrentTab = tab end

        -- ── Section (widget card) ──
        function tab:CreateSection(sectionName, opts)
            opts = opts or {}
            local section = create("Frame", {
                Name = sectionName or "Section", BackgroundColor3 = T.Panel,
                Size = UDim2.new(opts.FullWidth and 1 or 1, opts.FullWidth and -4 or -4, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y, BorderSizePixel = 0,
                LayoutOrder = #tab.Sections + 1, Parent = page,
            })
            corner(section, 14)
            stroke(section, T.Border, 1, 0.55)
            padding(section, 16, 16, 18, 18)
            listLayout(section, 12)

            local header = create("Frame", {
                BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 20), LayoutOrder = 0, Parent = section,
            })
            if opts.Icon then
                local hi = iconImage(header, opts.Icon, 15, T.Accent2)
                hi.Position = UDim2.new(0, 0, 0.5, -7)
                bindTheme(hi, "ImageColor3", "Accent2")
            end
            create("TextLabel", {
                BackgroundTransparency = 1,
                Position = UDim2.new(0, opts.Icon and 22 or 0, 0, 0),
                Size = UDim2.new(1, opts.Icon and -22 or 0, 1, 0),
                Font = Enum.Font.GothamBold, Text = sectionName or "Section",
                TextColor3 = T.Text, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left, Parent = header,
            })

            local sec = { Frame = section, Header = header, Elements = {} }

            local function nextOrder()
                return #sec.Elements + 1
            end

            function sec:AddLabel(text)
                local lbl = create("TextLabel", {
                    BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
                    Font = Enum.Font.Gotham, Text = text or "", TextColor3 = T.TextDim, TextSize = 13,
                    TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left, LayoutOrder = nextOrder(), Parent = section,
                })
                table.insert(sec.Elements, lbl)
                return lbl
            end

            function sec:AddParagraph(text)
                return sec:AddLabel(text)
            end

            function sec:AddButton(cfg)
                cfg = cfg or {}
                local btn = create("TextButton", {
                    BackgroundColor3 = cfg.Accent and T.Accent or T.Input,
                    Size = UDim2.new(1, 0, 0, 36), Text = cfg.Text or "Button",
                    Font = Enum.Font.GothamMedium, TextColor3 = T.Text, TextSize = 13,
                    AutoButtonColor = false, LayoutOrder = nextOrder(), Parent = section,
                })
                corner(btn, 9)
                if cfg.Accent then bindTheme(btn, "BackgroundColor3", "Accent") end
                local def, hov = cfg.Accent and T.Accent or T.Input, cfg.Accent and Color3.fromRGB(167, 139, 250) or T.PanelHover
                animateButton(btn, def, hov)
                btn.MouseButton1Click:Connect(function()
                    if cfg.Callback then pcall(cfg.Callback) end
                end)
                table.insert(sec.Elements, btn)
                return btn
            end

            function sec:AddToggle(cfg)
                cfg = cfg or {}
                local flag, default = cfg.Flag, cfg.Default or false
                if flag then Library.Flags[flag] = default end

                local row = create("Frame", {
                    BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 28), LayoutOrder = nextOrder(), Parent = section,
                })
                create("TextLabel", {
                    BackgroundTransparency = 1, Size = UDim2.new(1, -52, 1, 0),
                    Font = Enum.Font.GothamMedium, Text = cfg.Text or "Toggle", TextColor3 = T.Text, TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Left, Parent = row,
                })
                local track = create("Frame", {
                    BackgroundColor3 = default and T.ToggleOn or T.ToggleOff,
                    Size = UDim2.new(0, 40, 0, 22), Position = UDim2.new(1, -40, 0.5, -11), Parent = row,
                })
                corner(track, 11)
                stroke(track, T.Border, 1, default and 1 or 0.4)
                local knob = create("Frame", {
                    BackgroundColor3 = default and Color3.new(1, 1, 1) or Color3.fromRGB(200, 200, 210),
                    Size = UDim2.new(0, 16, 0, 16),
                    Position = default and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8), Parent = track,
                })
                corner(knob, 8)

                local state = default
                local function setState(v, fire)
                    state = v
                    if flag then Library.Flags[flag] = v end
                    tween(track, { BackgroundColor3 = v and T.ToggleOn or T.ToggleOff }, 0.18)
                    tween(knob, { Position = v and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8), BackgroundColor3 = v and Color3.new(1,1,1) or Color3.fromRGB(200,200,210) }, 0.18)
                    if fire and cfg.Callback then pcall(cfg.Callback, v) end
                end
                -- keep track color in theme bindings for live updates when on
                table.insert(themeBindings, {
                    inst = track, prop = "BackgroundColor3", key = "ToggleOn",
                    _dynamic = function()
                        return state and T.ToggleOn or T.ToggleOff
                    end,
                })
                create("TextButton", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0), Text = "", Parent = row }).MouseButton1Click:Connect(function()
                    setState(not state, true)
                end)
                table.insert(sec.Elements, row)
                return { Set = function(_, v) setState(v, true) end, Get = function() return state end, Frame = row }
            end

            function sec:AddSlider(cfg)
                cfg = cfg or {}
                local minV, maxV = cfg.Min or 0, cfg.Max or 100
                local default = cfg.Default or minV
                local flag = cfg.Flag
                if flag then Library.Flags[flag] = default end

                local row = create("Frame", {
                    BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 44), LayoutOrder = nextOrder(), Parent = section,
                })
                create("TextLabel", {
                    BackgroundTransparency = 1, Size = UDim2.new(0.7, 0, 0, 18),
                    Font = Enum.Font.GothamMedium, Text = cfg.Text or "Slider", TextColor3 = T.Text, TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Left, Parent = row,
                })
                local valueLbl = create("TextLabel", {
                    BackgroundTransparency = 1, Size = UDim2.new(0, 40, 0, 18), Position = UDim2.new(1, -40, 0, 0),
                    Font = Enum.Font.GothamBold, Text = tostring(default), TextColor3 = T.Accent2, TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Right, Parent = row,
                })
                bindTheme(valueLbl, "TextColor3", "Accent2")
                local barBg = create("Frame", {
                    BackgroundColor3 = T.Input, Size = UDim2.new(1, 0, 0, 6), Position = UDim2.new(0, 0, 0, 28), Parent = row,
                })
                corner(barBg, 3)
                local fill = create("Frame", {
                    BackgroundColor3 = T.Accent, Size = UDim2.new((default - minV) / math.max(maxV - minV, 1), 0, 1, 0), Parent = barBg,
                })
                corner(fill, 3)
                bindTheme(fill, "BackgroundColor3", "Accent")
                -- gradient feel
                local knob = create("Frame", {
                    BackgroundColor3 = Color3.new(1, 1, 1), Size = UDim2.new(0, 14, 0, 14),
                    Position = UDim2.new((default - minV) / math.max(maxV - minV, 1), -7, 0.5, -7), ZIndex = 2, Parent = barBg,
                })
                corner(knob, 7)
                stroke(knob, T.Accent, 2, 0)

                local sliding = false
                local function update(input)
                    local rel = math.clamp((input.X - barBg.AbsolutePosition.X) / math.max(barBg.AbsoluteSize.X, 1), 0, 1)
                    local val = minV + (maxV - minV) * rel
                    if not cfg.Decimals or cfg.Decimals == 0 then val = math.floor(val + 0.5)
                    else val = math.floor(val * 10 ^ cfg.Decimals + 0.5) / 10 ^ cfg.Decimals end
                    fill.Size = UDim2.new(rel, 0, 1, 0)
                    knob.Position = UDim2.new(rel, -7, 0.5, -7)
                    valueLbl.Text = tostring(val)
                    if flag then Library.Flags[flag] = val end
                    if cfg.Callback then pcall(cfg.Callback, val) end
                end
                barBg.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then sliding = true; update(input.Position) end
                end)
                UserInputService.InputChanged:Connect(function(input)
                    if sliding and input.UserInputType == Enum.UserInputType.MouseMovement then update(input.Position) end
                end)
                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then sliding = false end
                end)
                table.insert(sec.Elements, row)
                return row
            end

            function sec:AddDropdown(cfg)
                cfg = cfg or {}
                local options = cfg.Options or { "Option 1" }
                local default = cfg.Default or options[1]
                local flag = cfg.Flag
                if flag then Library.Flags[flag] = default end

                local wrap = create("Frame", {
                    BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
                    LayoutOrder = nextOrder(), ClipsDescendants = false, Parent = section,
                })
                listLayout(wrap, 6)
                create("TextLabel", {
                    BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 16),
                    Font = Enum.Font.Gotham, Text = cfg.Text or "Dropdown", TextColor3 = T.TextDim, TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left, LayoutOrder = 0, Parent = wrap,
                })
                local box = create("TextButton", {
                    BackgroundColor3 = T.Input, Size = UDim2.new(1, 0, 0, 34), Text = "",
                    AutoButtonColor = false, LayoutOrder = 1, Parent = wrap,
                })
                corner(box, 9)
                stroke(box, T.Border, 1, 0.4)
                local boxLbl = create("TextLabel", {
                    BackgroundTransparency = 1, Size = UDim2.new(1, -30, 1, 0), Position = UDim2.new(0, 12, 0, 0),
                    Font = Enum.Font.Gotham, Text = default, TextColor3 = T.Text, TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Left, Parent = box,
                })
                local chevron = iconImage(box, "chevron-down", 14, T.TextFaint)
                chevron.Position = UDim2.new(1, -24, 0.5, -7)
                chevron.Image = Library:GetIcon("chevron-down") ~= LUCIDE_FALLBACK.house and Library:GetIcon("chevron-down") or ""

                local open = false
                local listFrame = create("Frame", {
                    BackgroundColor3 = Color3.fromRGB(24, 24, 30), Size = UDim2.new(1, 0, 0, 0),
                    Visible = false, ZIndex = 30, ClipsDescendants = true, LayoutOrder = 2, Parent = wrap,
                })
                corner(listFrame, 10)
                stroke(listFrame, T.Border, 1, 0.3)
                padding(listFrame, 4, 4, 4, 4)
                listLayout(listFrame, 2)

                for _, opt in ipairs(options) do
                    local optBtn = create("TextButton", {
                        BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 28),
                        Text = opt, Font = Enum.Font.Gotham, TextColor3 = opt == default and T.Accent2 or T.TextDim,
                        TextSize = 13, AutoButtonColor = false, ZIndex = 31, Parent = listFrame,
                    })
                    corner(optBtn, 7)
                    optBtn.MouseButton1Click:Connect(function()
                        boxLbl.Text = opt
                        if flag then Library.Flags[flag] = opt end
                        if cfg.Callback then pcall(cfg.Callback, opt) end
                        open = false
                        listFrame.Visible = false
                        listFrame.Size = UDim2.new(1, 0, 0, 0)
                        for _, c in ipairs(listFrame:GetChildren()) do
                            if c:IsA("TextButton") then c.TextColor3 = c.Text == opt and T.Accent2 or T.TextDim end
                        end
                    end)
                    optBtn.MouseEnter:Connect(function() tween(optBtn, { BackgroundTransparency = 0.9 }, 0.1) end)
                    optBtn.MouseLeave:Connect(function() tween(optBtn, { BackgroundTransparency = 1 }, 0.1) end)
                end

                box.MouseButton1Click:Connect(function()
                    open = not open
                    listFrame.Visible = open
                    local h = math.min(#options * 30 + 8, 180)
                    listFrame.Size = open and UDim2.new(1, 0, 0, h) or UDim2.new(1, 0, 0, 0)
                end)
                table.insert(sec.Elements, wrap)
                return wrap
            end

            function sec:AddTextbox(cfg)
                cfg = cfg or {}
                local flag = cfg.Flag
                if flag then Library.Flags[flag] = cfg.Default or "" end
                local wrap = create("Frame", {
                    BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
                    LayoutOrder = nextOrder(), Parent = section,
                })
                listLayout(wrap, 6)
                if cfg.Text then
                    create("TextLabel", {
                        BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 16),
                        Font = Enum.Font.Gotham, Text = cfg.Text, TextColor3 = T.TextDim, TextSize = 12,
                        TextXAlignment = Enum.TextXAlignment.Left, Parent = wrap,
                    })
                end
                local box = create("TextBox", {
                    BackgroundColor3 = T.Input, Size = UDim2.new(1, 0, 0, 34),
                    Text = cfg.Default or "", PlaceholderText = cfg.Placeholder or "...",
                    PlaceholderColor3 = T.TextFaint, Font = Enum.Font.Gotham, TextColor3 = T.Text, TextSize = 13,
                    ClearTextOnFocus = false, Parent = wrap,
                })
                corner(box, 9)
                stroke(box, T.Border, 1, 0.4)
                padding(box, 0, 0, 12, 12)
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
                local wrap = create("Frame", {
                    BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
                    LayoutOrder = nextOrder(), Parent = section,
                })
                listLayout(wrap, 6)
                if cfg.Text then
                    create("TextLabel", {
                        BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 16),
                        Font = Enum.Font.GothamMedium, Text = cfg.Text, TextColor3 = T.Text, TextSize = 13,
                        TextXAlignment = Enum.TextXAlignment.Left, Parent = wrap,
                    })
                end
                local keyBtn = create("TextButton", {
                    BackgroundColor3 = T.Input, Size = UDim2.new(0, 120, 0, 30),
                    Text = default == Enum.KeyCode.Unknown and "None" or default.Name,
                    Font = Enum.Font.GothamMedium, TextColor3 = T.TextDim, TextSize = 12,
                    AutoButtonColor = false, Parent = wrap,
                })
                corner(keyBtn, 8)
                stroke(keyBtn, T.Border, 1, 0.4)
                local listening = false
                keyBtn.MouseButton1Click:Connect(function()
                    listening = true
                    keyBtn.Text = "Press a key..."
                    keyBtn.TextColor3 = T.Accent2
                end)
                UserInputService.InputBegan:Connect(function(input)
                    if not listening then return end
                    if input.UserInputType == Enum.UserInputType.Keyboard then
                        local key = input.KeyCode
                        if key == Enum.KeyCode.Escape then
                            key = Enum.KeyCode.Unknown
                            keyBtn.Text = "None"
                        else
                            keyBtn.Text = key.Name
                        end
                        keyBtn.TextColor3 = T.TextDim
                        if flag then Library.Flags[flag] = key end
                        listening = false
                        if cfg.Callback then pcall(cfg.Callback, key) end
                    end
                end)
                table.insert(sec.Elements, wrap)
                return keyBtn
            end

            function sec:AddColorPicker(cfg)
                cfg = cfg or {}
                local default = cfg.Default or T.Accent2
                local flag = cfg.Flag
                if flag then Library.Flags[flag] = default end
                local row = create("Frame", {
                    BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 28), LayoutOrder = nextOrder(), Parent = section,
                })
                create("TextLabel", {
                    BackgroundTransparency = 1, Size = UDim2.new(1, -100, 1, 0),
                    Font = Enum.Font.Gotham, Text = cfg.Text or "Color", TextColor3 = T.TextDim, TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left, Parent = row,
                })
                local swatch = create("Frame", {
                    BackgroundColor3 = default, Size = UDim2.new(0, 22, 0, 22),
                    Position = UDim2.new(1, -90, 0.5, -11), Parent = row,
                })
                corner(swatch, 6)
                local hex = create("TextLabel", {
                    BackgroundTransparency = 1, Size = UDim2.new(0, 64, 1, 0), Position = UDim2.new(1, -64, 0, 0),
                    Font = Enum.Font.Code, Text = string.format("#%02X%02X%02X", default.R*255, default.G*255, default.B*255),
                    TextColor3 = T.TextDim, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left, Parent = row,
                })
                table.insert(sec.Elements, row)
                return { Frame = row, Set = function(_, c)
                    swatch.BackgroundColor3 = c
                    hex.Text = string.format("#%02X%02X%02X", c.R*255, c.G*255, c.B*255)
                    if flag then Library.Flags[flag] = c end
                    if cfg.Callback then pcall(cfg.Callback, c) end
                end }
            end

            table.insert(tab.Sections, sec)
            return sec
        end

        -- Two-column grid helper for Main/Settings style
        function tab:CreateGrid()
            local grid = create("Frame", {
                BackgroundTransparency = 1, Size = UDim2.new(1, -4, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = #tab.Sections + 1, Parent = page,
            })
            local gl = Instance.new("UIGridLayout")
            gl.CellSize = UDim2.new(0.5, -8, 0, 0)
            gl.CellPadding = UDim2.new(0, 14, 0, 14)
            gl.SortOrder = Enum.SortOrder.LayoutOrder
            gl.FillDirectionMaxCells = 2
            gl.Parent = grid
            -- Auto height cells via sections parented into grid frames
            local gridObj = { Frame = grid, Columns = {} }

            function gridObj:AddColumn()
                local col = create("Frame", {
                    BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0),
                    AutomaticSize = Enum.AutomaticSize.Y, Parent = grid,
                })
                listLayout(col, 14)
                table.insert(gridObj.Columns, col)
                return col
            end

            -- CreateSection that parents into a column frame
            function gridObj:CreateSection(parentCol, sectionName, opts)
                opts = opts or {}
                local section = create("Frame", {
                    Name = sectionName or "Section", BackgroundColor3 = T.Panel,
                    Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
                    BorderSizePixel = 0, Parent = parentCol,
                })
                corner(section, 14)
                stroke(section, T.Border, 1, 0.55)
                padding(section, 16, 16, 18, 18)
                listLayout(section, 12)
                local header = create("Frame", {
                    BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 20), LayoutOrder = 0, Parent = section,
                })
                if opts.Icon then
                    local hi = iconImage(header, opts.Icon, 15, T.Accent2)
                    hi.Position = UDim2.new(0, 0, 0.5, -7)
                end
                create("TextLabel", {
                    BackgroundTransparency = 1, Position = UDim2.new(0, opts.Icon and 22 or 0, 0, 0),
                    Size = UDim2.new(1, opts.Icon and -22 or 0, 1, 0),
                    Font = Enum.Font.GothamBold, Text = sectionName or "Section",
                    TextColor3 = T.Text, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left, Parent = header,
                })
                -- Reuse element methods by attaching a thin proxy to tab:CreateSection logic is heavy;
                -- instead return a section-like with same API via metatable to tab.CreateSection internal
                local fakeTab = { Sections = {}, Page = parentCol }
                -- Simpler: call tab:CreateSection then reparent
                return nil
            end

            return gridObj
        end

        -- ── Home layout (fixed structure, customizable content) ──
        function tab:CreateHomeLayout(homeConfig)
            homeConfig = homeConfig or {}
            for _, child in ipairs(page:GetChildren()) do
                if child:IsA("UIListLayout") or child:IsA("UIPadding") then child:Destroy() end
            end
            padding(page, 8, 16, 6, 14)

            -- Top row: Profile | About
            local topRow = create("Frame", {
                Name = "TopRow", BackgroundTransparency = 1,
                Size = UDim2.new(1, -8, 0, 100), Position = UDim2.new(0, 0, 0, 0), Parent = page,
            })

            local profileCard = create("Frame", {
                BackgroundColor3 = T.Panel, Size = UDim2.new(0.38, -8, 1, 0), Parent = topRow,
            })
            corner(profileCard, 14)
            stroke(profileCard, T.Border, 1, 0.55)

            local avatarRing = create("Frame", {
                Size = UDim2.new(0, 56, 0, 56), Position = UDim2.new(0, 16, 0.5, -28),
                BackgroundColor3 = T.Accent, BorderSizePixel = 0, Parent = profileCard,
            })
            corner(avatarRing, 32)
            stroke(avatarRing, T.Accent2, 2, 0)
            local avatar = create("ImageLabel", {
                Size = UDim2.new(1, -6, 1, -6), Position = UDim2.new(0, 3, 0, 3),
                BackgroundColor3 = Color3.fromRGB(18, 18, 24), BorderSizePixel = 0, Image = "", Parent = avatarRing,
            })
            corner(avatar, 32)
            task.spawn(function()
                local ok, content = pcall(function()
                    return Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
                end)
                if ok and content then avatar.Image = content end
            end)

            local userName = create("TextLabel", {
                BackgroundTransparency = 1, Position = UDim2.new(0, 86, 0, 24), Size = UDim2.new(1, -98, 0, 24),
                Font = Enum.Font.GothamBold, Text = "@" .. (homeConfig.Username or LocalPlayer.DisplayName or LocalPlayer.Name),
                TextColor3 = T.Text, TextSize = 18, TextXAlignment = Enum.TextXAlignment.Left,
                TextTruncate = Enum.TextTruncate.AtEnd, Parent = profileCard,
            })
            local welcome = create("TextLabel", {
                BackgroundTransparency = 1, Position = UDim2.new(0, 86, 0, 50), Size = UDim2.new(1, -98, 0, 18),
                Font = Enum.Font.Gotham, Text = (homeConfig.Welcome or "welcome back"),
                TextColor3 = T.TextDim, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, Parent = profileCard,
            })

            local aboutCard = create("Frame", {
                BackgroundColor3 = T.Panel, Size = UDim2.new(0.62, -8, 1, 0), Position = UDim2.new(0.38, 8, 0, 0), Parent = topRow,
            })
            corner(aboutCard, 14)
            stroke(aboutCard, T.Border, 1, 0.55)
            padding(aboutCard, 16, 16, 18, 18)
            create("TextLabel", {
                BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 18),
                Font = Enum.Font.GothamBold, Text = homeConfig.AboutTitle or "ABOUT",
                TextColor3 = T.TextDim, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, Parent = aboutCard,
            })
            local aboutBody = create("TextLabel", {
                BackgroundTransparency = 1, Position = UDim2.new(0, 0, 0, 24), Size = UDim2.new(1, 0, 1, -28),
                Font = Enum.Font.Gotham, Text = homeConfig.AboutText or "CYVHUB script hub.",
                TextColor3 = T.TextDim, TextSize = 13, TextWrapped = true,
                TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top, Parent = aboutCard,
            })

            -- Mid row: Discord | Server Info | Executor
            local midRow = create("Frame", {
                Name = "MidRow", BackgroundTransparency = 1,
                Size = UDim2.new(1, -8, 0, 96), Position = UDim2.new(0, 0, 0, 112), Parent = page,
            })

            local discordCard = create("Frame", {
                BackgroundColor3 = T.Panel, Size = UDim2.new(0.24, -10, 1, 0), Parent = midRow,
            })
            corner(discordCard, 14)
            stroke(discordCard, T.Border, 1, 0.55)
            padding(discordCard, 14, 14, 14, 14)
            local dHeader = create("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 18), Parent = discordCard })
            iconImage(dHeader, "message-circle", 14, T.Accent2, "Accent2").Position = UDim2.new(0, 0, 0.5, -7)
            create("TextLabel", {
                BackgroundTransparency = 1, Position = UDim2.new(0, 20, 0, 0), Size = UDim2.new(1, -20, 1, 0),
                Font = Enum.Font.GothamBold, Text = "Discord", TextColor3 = T.Text, TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left, Parent = dHeader,
            })
            local copyBtn = create("TextButton", {
                BackgroundColor3 = T.Accent, Size = UDim2.new(1, 0, 0, 34), Position = UDim2.new(0, 0, 0, 32),
                Text = "Copy Link", Font = Enum.Font.GothamBold, TextColor3 = T.Text, TextSize = 12,
                AutoButtonColor = false, Parent = discordCard,
            })
            corner(copyBtn, 9)
            bindTheme(copyBtn, "BackgroundColor3", "Accent")
            animateButton(copyBtn, T.Accent, Color3.fromRGB(167, 139, 250))
            -- rebind hover colors on theme change via weak refresh
            table.insert(themeBindings, { inst = copyBtn, prop = "BackgroundColor3", key = "Accent" })
            copyBtn.MouseButton1Click:Connect(function()
                local link = homeConfig.DiscordLink or "https://discord.gg/vTe3sNTsDM"
                if setclipboard then setclipboard(link); Library:Notify("Discord", "Invite copied!", 2, "success")
                else Library:Notify("Discord", link, 4) end
            end)

            local serverCard = create("Frame", {
                BackgroundColor3 = T.Panel, Size = UDim2.new(0.46, -10, 1, 0), Position = UDim2.new(0.24, 8, 0, 0), Parent = midRow,
            })
            corner(serverCard, 14)
            stroke(serverCard, T.Border, 1, 0.55)
            padding(serverCard, 14, 14, 16, 16)
            local sHeader = create("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 18), Parent = serverCard })
            iconImage(sHeader, "server", 14, T.Accent2, "Accent2").Position = UDim2.new(0, 0, 0.5, -7)
            create("TextLabel", {
                BackgroundTransparency = 1, Position = UDim2.new(0, 20, 0, 0), Size = UDim2.new(1, -20, 1, 0),
                Font = Enum.Font.GothamBold, Text = "Server Info", TextColor3 = T.Text, TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left, Parent = sHeader,
            })
            local statsRow = create("Frame", {
                BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 40), Position = UDim2.new(0, 0, 0, 32), Parent = serverCard,
            })
            local serverInfo = homeConfig.ServerStats or {
                { Num = tostring(#Players:GetPlayers()), Label = "PLAYERS" },
                { Num = "—", Label = "UPTIME" },
                { Num = "—", Label = "PING" },
            }
            for i, st in ipairs(serverInfo) do
                local cell = create("Frame", {
                    BackgroundTransparency = 1, Size = UDim2.new(1 / #serverInfo, -4, 1, 0),
                    Position = UDim2.new((i - 1) / #serverInfo, 0, 0, 0), Parent = statsRow,
                })
                create("TextLabel", {
                    BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 22),
                    Font = Enum.Font.GothamBold, Text = st.Num, TextColor3 = T.Text, TextSize = 18,
                    TextXAlignment = Enum.TextXAlignment.Left, Parent = cell,
                })
                create("TextLabel", {
                    BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 14), Position = UDim2.new(0, 0, 0, 24),
                    Font = Enum.Font.Gotham, Text = st.Label, TextColor3 = T.TextFaint, TextSize = 10,
                    TextXAlignment = Enum.TextXAlignment.Left, Parent = cell,
                })
            end

            local executorCard = create("Frame", {
                BackgroundColor3 = T.Panel, Size = UDim2.new(0.30, -12, 1, 0), Position = UDim2.new(0.70, 8, 0, 0),
                ClipsDescendants = true, Parent = midRow,
            })
            corner(executorCard, 14)
            stroke(executorCard, T.Border, 1, 0.55)
            padding(executorCard, 12, 12, 12, 12)
            local eHeader = create("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 18), Parent = executorCard })
            iconImage(eHeader, "terminal", 14, T.Accent2, "Accent2").Position = UDim2.new(0, 0, 0.5, -7)
            create("TextLabel", {
                BackgroundTransparency = 1, Position = UDim2.new(0, 20, 0, 0), Size = UDim2.new(1, -20, 1, 0),
                Font = Enum.Font.GothamBold, Text = "Executor", TextColor3 = T.Text, TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left, Parent = eHeader,
            })
            local execBox = create("Frame", {
                BackgroundColor3 = T.Input, Size = UDim2.new(1, 0, 0, 34), Position = UDim2.new(0, 0, 0, 32),
                ClipsDescendants = true, Parent = executorCard,
            })
            corner(execBox, 9)
            stroke(execBox, T.Border, 1, 0.5)
            local execName = create("TextLabel", {
                BackgroundTransparency = 1, Size = UDim2.new(1, -64, 1, 0), Position = UDim2.new(0, 10, 0, 0),
                Font = Enum.Font.Gotham, Text = homeConfig.ExecutorName or (identifyexecutor and identifyexecutor() or "Unknown"),
                TextColor3 = T.TextDim, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left,
                TextTruncate = Enum.TextTruncate.AtEnd, Parent = execBox,
            })
            local badge = create("TextLabel", {
                BackgroundColor3 = Color3.fromRGB(20, 50, 55), Size = UDim2.new(0, 46, 0, 18),
                Position = UDim2.new(1, -50, 0.5, -9), Text = "Active", Font = Enum.Font.GothamBold,
                TextColor3 = T.Accent2, TextSize = 10, Parent = execBox,
            })
            corner(badge, 9)
            bindTheme(badge, "TextColor3", "Accent2")

            -- Changelog
            local changeCard = create("Frame", {
                Name = "Changelog", BackgroundColor3 = T.Panel,
                Size = UDim2.new(1, -8, 0, 240), Position = UDim2.new(0, 0, 0, 220),
                ClipsDescendants = true, Parent = page,
            })
            corner(changeCard, 14)
            stroke(changeCard, T.Border, 1, 0.55)
            padding(changeCard, 14, 14, 16, 16)

            local chHeader = create("Frame", {
                BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 22), Parent = changeCard,
            })
            iconImage(chHeader, "scroll-text", 14, T.Accent2, "Accent2").Position = UDim2.new(0, 0, 0.5, -7)
            create("TextLabel", {
                BackgroundTransparency = 1, Position = UDim2.new(0, 20, 0, 0), Size = UDim2.new(0.5, 0, 1, 0),
                Font = Enum.Font.GothamBold, Text = "Changelog", TextColor3 = T.Text, TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left, Parent = chHeader,
            })
            local entries = homeConfig.Changelog or {
                { Version = "v1.0.1", Date = "2026-08-29", Text = "Notification redesign (success/warning/error), badge overflow fix, new banner." },
                { Version = "v1.0.0", Date = "2026-08-29", Text = "Initial CYVUI release — dashboard Home, Lucide icons, Settings themes." },
            }
            if entries[1] then
                local latest = create("TextLabel", {
                    BackgroundColor3 = Color3.fromRGB(20, 50, 55), Size = UDim2.new(0, 52, 0, 18),
                    Position = UDim2.new(1, -52, 0, 2), Text = entries[1].Version or "v1.0.1",
                    Font = Enum.Font.GothamBold, TextColor3 = T.Accent2, TextSize = 10, Parent = chHeader,
                })
                corner(latest, 8)
                bindTheme(latest, "TextColor3", "Accent2")
            end

            local changeScroll = create("ScrollingFrame", {
                BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, -30), Position = UDim2.new(0, 0, 0, 28),
                CanvasSize = UDim2.new(0, 0, 0, 0), AutomaticCanvasSize = Enum.AutomaticSize.Y,
                ScrollBarThickness = 3, ScrollBarImageColor3 = T.ScrollBar, BorderSizePixel = 0, Parent = changeCard,
            })
            listLayout(changeScroll, 10)

            for i, entry in ipairs(entries) do
                local line = create("Frame", {
                    BackgroundTransparency = 1, Size = UDim2.new(1, -4, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
                    LayoutOrder = i, Parent = changeScroll,
                })
                local titleRow = create("TextLabel", {
                    BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 18),
                    Font = Enum.Font.GothamBold,
                    Text = string.format("%s  %s", entry.Version or "?", entry.Date or ""),
                    TextColor3 = T.Text, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, Parent = line,
                })
                local body = create("TextLabel", {
                    BackgroundTransparency = 1, Position = UDim2.new(0, 0, 0, 20), Size = UDim2.new(1, 0, 0, 0),
                    AutomaticSize = Enum.AutomaticSize.Y, Font = Enum.Font.Gotham,
                    Text = entry.Text or "", TextColor3 = T.TextDim, TextSize = 12, TextWrapped = true,
                    TextXAlignment = Enum.TextXAlignment.Left, Parent = line,
                })
                if entry.Tags then
                    -- optional tag chips in text prefix
                end
            end

            return {
                ProfileCard = profileCard, AboutCard = aboutCard, DiscordCard = discordCard,
                ServerCard = serverCard, ExecutorCard = executorCard, ChangelogCard = changeCard,
                SetUsername = function(_, n) userName.Text = "@" .. n end,
                SetAbout = function(_, t) aboutBody.Text = t end,
                SetExecutor = function(_, n) execName.Text = n end,
            }
        end

        -- ── Default Settings layout (same structure every UI) ──
        function tab:CreateSettingsLayout(setConfig)
            setConfig = setConfig or {}
            -- Theme section
            local theme = tab:CreateSection("Theme", { Icon = "palette" })
            theme:AddLabel("Accent Color")
            -- simple accent presets as buttons row
            local presets = setConfig.Themes or {
                { Name = "Violet", Accent = Color3.fromRGB(139, 92, 246), Accent2 = Color3.fromRGB(34, 211, 238) },
                { Name = "Pink", Accent = Color3.fromRGB(244, 114, 182), Accent2 = Color3.fromRGB(251, 146, 60) },
                { Name = "Green", Accent = Color3.fromRGB(52, 211, 153), Accent2 = Color3.fromRGB(163, 230, 53) },
                { Name = "Blue", Accent = Color3.fromRGB(96, 165, 250), Accent2 = Color3.fromRGB(129, 140, 248) },
            }
            local presetRow = create("Frame", {
                BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 28), LayoutOrder = 99, Parent = theme.Frame,
            })
            for i, p in ipairs(presets) do
                local sw = create("TextButton", {
                    BackgroundColor3 = p.Accent, Size = UDim2.new(0, 24, 0, 24),
                    Position = UDim2.new(0, (i - 1) * 32, 0, 2), Text = "", AutoButtonColor = false, Parent = presetRow,
                })
                corner(sw, 12)
                sw.MouseButton1Click:Connect(function()
                    Library:SetTheme(p.Accent, p.Accent2)
                    Library:Notify("Theme", p.Name, 1.8, "success")
                    if setConfig.OnTheme then pcall(setConfig.OnTheme, p) end
                end)
            end

            theme:AddSlider({
                Text = "UI Transparency", Min = 20, Max = 100, Default = 72, Flag = "UITransparency",
                Callback = function(v)
                    -- v is 20-100; map to BackgroundTransparency 0.0-0.5 on main panels
                    local t = math.clamp((100 - v) / 100 * 0.55, 0, 0.55)
                    if window.Main then
                        -- keep solid for readability; soft-tint panels via Theme Panel if needed
                    end
                    Library.Flags.UITransparency = v
                end,
            })

            local configSec = tab:CreateSection("Config", { Icon = "bookmark" })
            configSec:AddDropdown({
                Text = "Load Config", Options = setConfig.Configs or { "default" }, Default = "default", Flag = "ConfigName",
            })
            configSec:AddButton({ Text = "Save Config", Accent = true, Callback = setConfig.OnSave })
            configSec:AddButton({ Text = "Load Config", Callback = setConfig.OnLoad })
            configSec:AddToggle({ Text = "Auto Load On Join", Default = true, Flag = "AutoLoad" })

            local gen = tab:CreateSection("General", { Icon = "settings" })
            gen:AddKeybind({ Text = "Minimize Keybind", Default = Enum.KeyCode.LeftControl, Flag = "MinimizeKey" })
            gen:AddToggle({ Text = "Watermark", Default = true, Flag = "Watermark" })
            gen:AddToggle({ Text = "Notifications", Default = true, Flag = "Notifications" })
            gen:AddParagraph("Settings are stored locally per-config.")
            gen:AddButton({
                Text = "Destroy UI", Callback = function() screenGui:Destroy() end,
            })
        end

        table.insert(window.Tabs, tab)
        return tab
    end

    -- Built-in Settings tab
    local settingsTab = window:CreateTab({ Name = "Settings", Icon = "settings", Settings = true })
    settingsTab:CreateSettingsLayout({})

    settingsBtn.MouseButton1Click:Connect(function()
        -- select settings via same path
        for _, t in ipairs(window.Tabs) do
            if t.IsSettings then
                t.Page.Visible = true
                if t.Icon then t.Icon.ImageColor3 = T.Text end
                if t.Label then t.Label.TextColor3 = T.Text end
            else
                t.Page.Visible = false
                t.Button.BackgroundTransparency = 1
                if t.Icon then t.Icon.ImageColor3 = T.TextDim end
                if t.Label then t.Label.TextColor3 = T.TextDim end
            end
        end
        settingsBtn.BackgroundTransparency = 0
        settingsBtn.BackgroundColor3 = T.AccentSoft
        window.CurrentTab = settingsTab
    end)

    UserInputService.InputBegan:Connect(function(input, gp)
        if gp then return end
        if input.KeyCode == Enum.KeyCode.RightControl then
            main.Visible = not main.Visible
        end
    end)

    table.insert(self.Windows, window)
    return window
end

function Library:GetFlag(name) return self.Flags[name] end
function Library:SetFlag(name, value) self.Flags[name] = value end

return Library
