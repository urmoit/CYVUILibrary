--[[
    CYVUI Library v1.0.3
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
    Version     = "1.0.3",
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
    local version  = config.Version or "v1.0.3"
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
        -- Two-column row: Tab:CreateRow() then pass row as parent via opts.Parent or use row:Section
        function tab:CreateRow()
            local row = create("Frame", {
                Name = "Row", BackgroundTransparency = 1,
                Size = UDim2.new(1, -4, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
                LayoutOrder = #tab.Sections + 1, Parent = page,
            })
            local rl = Instance.new("UIListLayout")
            rl.FillDirection = Enum.FillDirection.Horizontal
            rl.Padding = UDim.new(0, 12)
            rl.SortOrder = Enum.SortOrder.LayoutOrder
            rl.Parent = row
            local rowObj = { Frame = row, _count = 0 }
            function rowObj:Section(sectionName, opts)
                opts = opts or {}
                opts.Parent = row
                opts.Side = true
                return tab:CreateSection(sectionName, opts)
            end
            return rowObj
        end

        function tab:CreateSection(sectionName, opts)
            opts = opts or {}
            local parent = opts.Parent or page
            local side = opts.Side == true
            local section = create("Frame", {
                Name = sectionName or "Section", BackgroundColor3 = T.Panel,
                Size = side and UDim2.new(0.5, -8, 0, 0) or UDim2.new(1, -4, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y, BorderSizePixel = 0,
                LayoutOrder = #tab.Sections + 1, Parent = parent,
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

                local function selectedList()
                    local list = {}
                    for _, opt in ipairs(options) do
                        if selected[opt] then table.insert(list, opt) end
                    end
                    return list
                end

                local function labelText()
                    if multi then
                        local list = selectedList()
                        if #list == 0 then return "None" end
                        if #list <= 2 then return table.concat(list, ", ") end
                        return list[1] .. " +" .. tostring(#list - 1)
                    end
                    return tostring(default)
                end

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
                    Font = Enum.Font.Gotham, Text = labelText(), TextColor3 = T.Text, TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, Parent = box,
                })
                local chevron = iconImage(box, "chevron-down", 14, T.TextFaint)
                chevron.Position = UDim2.new(1, -24, 0.5, -7)

                local open = false
                local listFrame = create("Frame", {
                    BackgroundColor3 = Color3.fromRGB(22, 22, 28), Size = UDim2.new(1, 0, 0, 0),
                    Visible = false, ZIndex = 40, ClipsDescendants = true, LayoutOrder = 2, Parent = wrap,
                })
                corner(listFrame, 10)
                stroke(listFrame, T.Border, 1, 0.25)
                padding(listFrame, 6, 6, 6, 6)
                local listLay = listLayout(listFrame, 4)

                -- Search row
                local searchRow = create("Frame", {
                    BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 30), ZIndex = 41, LayoutOrder = 0, Parent = listFrame,
                })
                local searchBox = create("TextBox", {
                    BackgroundColor3 = T.Input, Size = multi and UDim2.new(1, -52, 1, 0) or UDim2.new(1, 0, 1, 0),
                    Text = "", PlaceholderText = "Search...", PlaceholderColor3 = T.TextFaint,
                    Font = Enum.Font.Gotham, TextColor3 = T.Text, TextSize = 12, ClearTextOnFocus = false, ZIndex = 41, Parent = searchRow,
                })
                corner(searchBox, 7)
                stroke(searchBox, T.Border, 1, 0.4)
                padding(searchBox, 0, 0, 8, 8)

                local allToggle
                local allState = false
                if multi then
                    allToggle = create("TextButton", {
                        BackgroundColor3 = T.Input, Size = UDim2.new(0, 46, 1, 0), Position = UDim2.new(1, -46, 0, 0),
                        Text = "All", Font = Enum.Font.GothamBold, TextColor3 = T.TextDim, TextSize = 11,
                        AutoButtonColor = false, ZIndex = 41, Parent = searchRow,
                    })
                    corner(allToggle, 7)
                    stroke(allToggle, T.Border, 1, 0.4)
                end

                local optScroll = create("ScrollingFrame", {
                    BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 120),
                    CanvasSize = UDim2.new(0, 0, 0, 0), AutomaticCanvasSize = Enum.AutomaticSize.Y,
                    ScrollBarThickness = 3, ScrollBarImageColor3 = T.ScrollBar, BorderSizePixel = 0,
                    ZIndex = 41, LayoutOrder = 1, Parent = listFrame,
                })
                listLayout(optScroll, 2)

                local optButtons = {}

                local function fireChange()
                    if multi then
                        local list = selectedList()
                        if flag then Library.Flags[flag] = list end
                        boxLbl.Text = labelText()
                        if cfg.Callback then pcall(cfg.Callback, list) end
                    else
                        if flag then Library.Flags[flag] = default end
                        boxLbl.Text = tostring(default)
                        if cfg.Callback then pcall(cfg.Callback, default) end
                    end
                end

                local function refreshAllVisual()
                    if not multi then return end
                    local allOn = true
                    for _, opt in ipairs(options) do
                        if not selected[opt] then allOn = false break end
                    end
                    allState = allOn
                    if allToggle then
                        allToggle.BackgroundColor3 = allState and T.Accent or T.Input
                        allToggle.TextColor3 = allState and T.Text or T.TextDim
                    end
                end

                local function makeOpt(opt)
                    local row = create("TextButton", {
                        BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 28),
                        Text = "", AutoButtonColor = false, ZIndex = 42, Parent = optScroll,
                    })
                    corner(row, 7)
                    local check
                    if multi then
                        check = create("Frame", {
                            BackgroundColor3 = selected[opt] and T.Accent or T.Input,
                            Size = UDim2.new(0, 16, 0, 16), Position = UDim2.new(0, 6, 0.5, -8),
                            ZIndex = 43, Parent = row,
                        })
                        corner(check, 4)
                        stroke(check, T.Border, 1, 0.3)
                    end
                    local lbl = create("TextLabel", {
                        BackgroundTransparency = 1,
                        Size = multi and UDim2.new(1, -30, 1, 0) or UDim2.new(1, -8, 1, 0),
                        Position = multi and UDim2.new(0, 28, 0, 0) or UDim2.new(0, 8, 0, 0),
                        Font = Enum.Font.Gotham,
                        Text = opt,
                        TextColor3 = (multi and selected[opt] or (not multi and opt == default)) and T.Accent2 or T.TextDim,
                        TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 43, Parent = row,
                    })
                    row.MouseEnter:Connect(function() tween(row, { BackgroundTransparency = 0.92 }, 0.1) end)
                    row.MouseLeave:Connect(function() tween(row, { BackgroundTransparency = 1 }, 0.1) end)
                    row.MouseButton1Click:Connect(function()
                        if multi then
                            selected[opt] = not selected[opt]
                            if check then check.BackgroundColor3 = selected[opt] and T.Accent or T.Input end
                            lbl.TextColor3 = selected[opt] and T.Accent2 or T.TextDim
                            refreshAllVisual()
                            fireChange()
                        else
                            default = opt
                            for _, o in ipairs(optButtons) do
                                o.lbl.TextColor3 = o.opt == default and T.Accent2 or T.TextDim
                            end
                            fireChange()
                            open = false
                            listFrame.Visible = false
                            listFrame.Size = UDim2.new(1, 0, 0, 0)
                        end
                    end)
                    table.insert(optButtons, { row = row, lbl = lbl, opt = opt, check = check })
                    return row
                end

                for _, opt in ipairs(options) do
                    makeOpt(opt)
                end
                refreshAllVisual()

                local function filterOptions(query)
                    query = string.lower(query or "")
                    for _, o in ipairs(optButtons) do
                        o.row.Visible = query == "" or string.find(string.lower(o.opt), query, 1, true) ~= nil
                    end
                end
                searchBox:GetPropertyChangedSignal("Text"):Connect(function()
                    filterOptions(searchBox.Text)
                end)

                if multi and allToggle then
                    allToggle.MouseButton1Click:Connect(function()
                        allState = not allState
                        for _, o in ipairs(optButtons) do
                            selected[o.opt] = allState
                            if o.check then o.check.BackgroundColor3 = allState and T.Accent or T.Input end
                            o.lbl.TextColor3 = allState and T.Accent2 or T.TextDim
                        end
                        refreshAllVisual()
                        fireChange()
                    end)
                end

                local function setOpen(state)
                    open = state
                    listFrame.Visible = open
                    if open then
                        local h = math.min(36 + #options * 30, 180)
                        listFrame.Size = UDim2.new(1, 0, 0, h)
                        optScroll.Size = UDim2.new(1, 0, 0, h - 42)
                        searchBox.Text = ""
                        filterOptions("")
                    else
                        listFrame.Size = UDim2.new(1, 0, 0, 0)
                    end
                end

                box.MouseButton1Click:Connect(function()
                    setOpen(not open)
                end)

                table.insert(sec.Elements, wrap)
                return {
                    Frame = wrap,
                    Set = function(_, value)
                        if multi then
                            selected = {}
                            if type(value) == "table" then
                                for _, v in ipairs(value) do selected[v] = true end
                            end
                            for _, o in ipairs(optButtons) do
                                local on = selected[o.opt] == true
                                if o.check then o.check.BackgroundColor3 = on and T.Accent or T.Input end
                                o.lbl.TextColor3 = on and T.Accent2 or T.TextDim
                            end
                            refreshAllVisual()
                            fireChange()
                        else
                            default = value
                            for _, o in ipairs(optButtons) do
                                o.lbl.TextColor3 = o.opt == default and T.Accent2 or T.TextDim
                            end
                            fireChange()
                        end
                    end,
                    Get = function()
                        if multi then return selectedList() end
                        return default
                    end,
                }
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
                    return string.format("#%02X%02X%02X", math.floor(c.R * 255 + 0.5), math.floor(c.G * 255 + 0.5), math.floor(c.B * 255 + 0.5))
                end

                local h, s, v = rgbToHsv(current)

                local row = create("Frame", {
                    BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 28), LayoutOrder = nextOrder(), Parent = section,
                })
                create("TextLabel", {
                    BackgroundTransparency = 1, Size = UDim2.new(1, -110, 1, 0),
                    Font = Enum.Font.Gotham, Text = cfg.Text or "Color", TextColor3 = T.TextDim, TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left, Parent = row,
                })
                local trigger = create("TextButton", {
                    BackgroundColor3 = T.Input, Size = UDim2.new(0, 100, 0, 26),
                    Position = UDim2.new(1, -100, 0.5, -13), Text = "", AutoButtonColor = false, Parent = row,
                })
                corner(trigger, 8)
                stroke(trigger, T.Border, 1, 0.35)
                local swatch = create("Frame", {
                    BackgroundColor3 = current, Size = UDim2.new(0, 16, 0, 16),
                    Position = UDim2.new(0, 8, 0.5, -8), Parent = trigger,
                })
                corner(swatch, 4)
                local hexLbl = create("TextLabel", {
                    BackgroundTransparency = 1, Size = UDim2.new(1, -40, 1, 0), Position = UDim2.new(0, 28, 0, 0),
                    Font = Enum.Font.Code, Text = toHex(current), TextColor3 = T.Text, TextSize = 11,
                    TextXAlignment = Enum.TextXAlignment.Left, Parent = trigger,
                })
                local chev = iconImage(trigger, "chevron-down", 12, T.TextFaint)
                chev.Position = UDim2.new(1, -16, 0.5, -6)

                -- Popup (parented to ScreenGui layer via window later; use section ancestor for z)
                local popup = create("Frame", {
                    BackgroundColor3 = Color3.fromRGB(20, 20, 28), Size = UDim2.new(0, 220, 0, 250),
                    Visible = false, ZIndex = 100, Parent = section,
                })
                corner(popup, 12)
                stroke(popup, T.Border, 1, 0.25)
                padding(popup, 10, 10, 10, 10)

                local function positionPopup()
                    local abs = trigger.AbsolutePosition
                    local size = trigger.AbsoluteSize
                    local parentAbs = section.AbsolutePosition
                    popup.Position = UDim2.new(0, math.clamp(abs.X - parentAbs.X + size.X - 220, 0, 400), 0, abs.Y - parentAbs.Y + size.Y + 6)
                end

                local satBox = create("Frame", {
                    BackgroundColor3 = Color3.new(1, 1, 1), Size = UDim2.new(1, -22, 0, 140), Position = UDim2.new(0, 0, 0, 0), ZIndex = 101, Parent = popup,
                })
                corner(satBox, 8)
                local satFill = create("Frame", {
                    BackgroundColor3 = hsvToRgb(h, 1, 1), Size = UDim2.new(1, 0, 1, 0), BorderSizePixel = 0, ZIndex = 101, Parent = satBox,
                })
                corner(satFill, 8)
                local whiteGrad = Instance.new("UIGradient")
                whiteGrad.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 1) })
                whiteGrad.Parent = satFill
                local blackOverlay = create("Frame", {
                    BackgroundColor3 = Color3.new(0, 0, 0), Size = UDim2.new(1, 0, 1, 0), BorderSizePixel = 0, ZIndex = 102, Parent = satBox,
                })
                corner(blackOverlay, 8)
                local blackGrad = Instance.new("UIGradient")
                blackGrad.Rotation = 90
                blackGrad.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(1, 0) })
                blackGrad.Parent = blackOverlay
                local cursor = create("Frame", {
                    BackgroundColor3 = Color3.new(1, 1, 1), Size = UDim2.new(0, 12, 0, 12),
                    Position = UDim2.new(s, -6, 1 - v, -6), ZIndex = 103, Parent = satBox,
                })
                corner(cursor, 6)
                stroke(cursor, Color3.new(0, 0, 0), 1, 0)

                local hueBar = create("Frame", {
                    BackgroundColor3 = Color3.new(1, 1, 1), Size = UDim2.new(0, 14, 0, 140),
                    Position = UDim2.new(1, -14, 0, 0), ZIndex = 101, Parent = popup,
                })
                corner(hueBar, 6)
                local hueGrad = Instance.new("UIGradient")
                hueGrad.Rotation = 90
                hueGrad.Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
                    ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 255, 0)),
                    ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)),
                    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
                    ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 0, 255)),
                    ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 0, 255)),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0)),
                })
                hueGrad.Parent = hueBar
                local hueCursor = create("Frame", {
                    BackgroundColor3 = Color3.new(1, 1, 1), Size = UDim2.new(1, 4, 0, 4),
                    Position = UDim2.new(0, -2, h, -2), ZIndex = 103, Parent = hueBar,
                })
                corner(hueCursor, 2)
                stroke(hueCursor, Color3.new(0, 0, 0), 1, 0)

                local hsvLbl = create("TextLabel", {
                    BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 16), Position = UDim2.new(0, 0, 0, 148),
                    Font = Enum.Font.GothamBold, Text = "HSV", TextColor3 = T.TextFaint, TextSize = 11,
                    TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 101, Parent = popup,
                })
                local hsvVals = create("TextLabel", {
                    BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 16), Position = UDim2.new(0, 0, 0, 166),
                    Font = Enum.Font.Code, Text = "", TextColor3 = T.TextDim, TextSize = 11,
                    TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 101, Parent = popup,
                })
                local hexRow = create("TextBox", {
                    BackgroundColor3 = T.Input, Size = UDim2.new(1, 0, 0, 28), Position = UDim2.new(0, 0, 0, 190),
                    Text = toHex(current), Font = Enum.Font.Code, TextColor3 = T.Text, TextSize = 12,
                    ClearTextOnFocus = false, ZIndex = 101, Parent = popup,
                })
                corner(hexRow, 8)
                stroke(hexRow, T.Border, 1, 0.35)
                padding(hexRow, 0, 0, 10, 10)

                local function applyColor(fire)
                    current = hsvToRgb(h, s, v)
                    swatch.BackgroundColor3 = current
                    satFill.BackgroundColor3 = hsvToRgb(h, 1, 1)
                    hexLbl.Text = toHex(current)
                    hexRow.Text = toHex(current)
                    hsvVals.Text = string.format("H %d  S %d  V %d", math.floor(h * 360 + 0.5), math.floor(s * 100 + 0.5), math.floor(v * 100 + 0.5))
                    if flag then Library.Flags[flag] = current end
                    if fire and cfg.Callback then pcall(cfg.Callback, current) end
                end
                applyColor(false)

                local draggingSV, draggingH = false, false
                satBox.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then draggingSV = true end
                end)
                hueBar.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then draggingH = true end
                end)
                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then draggingSV, draggingH = false, false end
                end)
                UserInputService.InputChanged:Connect(function(input)
                    if input.UserInputType ~= Enum.UserInputType.MouseMovement then return end
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
                hexRow.FocusLost:Connect(function()
                    local hex = hexRow.Text:gsub("#", "")
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
                trigger.MouseButton1Click:Connect(function()
                    open = not open
                    if open then positionPopup() end
                    popup.Visible = open
                end)
                UserInputService.InputBegan:Connect(function(input)
                    if not open then return end
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        local p = input.Position
                        local pa, ps = popup.AbsolutePosition, popup.AbsoluteSize
                        local ta, ts = trigger.AbsolutePosition, trigger.AbsoluteSize
                        local inPopup = p.X >= pa.X and p.X <= pa.X + ps.X and p.Y >= pa.Y and p.Y <= pa.Y + ps.Y
                        local inTrig = p.X >= ta.X and p.X <= ta.X + ts.X and p.Y >= ta.Y and p.Y <= ta.Y + ts.Y
                        if not inPopup and not inTrig then
                            open = false
                            popup.Visible = false
                        end
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

            table.insert(tab.Sections, sec)
            return sec
        end

        -- Two-column grid helper for Main/Settings style
        function tab:CreateGrid(columns)
            columns = columns or 2
            local grid = create("Frame", {
                BackgroundTransparency = 1, Size = UDim2.new(1, -4, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = #tab.Sections + 1, Parent = page,
            })
            local gl = Instance.new("UIGridLayout")
            gl.CellSize = UDim2.new(1 / columns, -10, 0, 200)
            gl.CellPadding = UDim2.new(0, 12, 0, 12)
            gl.SortOrder = Enum.SortOrder.LayoutOrder
            gl.FillDirectionMaxCells = columns
            gl.Parent = grid
            local gridObj = { Frame = grid }

            function gridObj:Section(sectionName, opts)
                opts = opts or {}
                opts.Parent = grid
                opts.Side = true
                opts.Grid = true
                local sec = tab:CreateSection(sectionName, opts)
                -- stretch cell height with content: approximate via AbsoluteSize listener
                return sec
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
            local function makeStat(i, label)
                local cell = create("Frame", {
                    BackgroundTransparency = 1, Size = UDim2.new(1 / 3, -4, 1, 0),
                    Position = UDim2.new((i - 1) / 3, 0, 0, 0), Parent = statsRow,
                })
                local num = create("TextLabel", {
                    BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 22),
                    Font = Enum.Font.GothamBold, Text = "—", TextColor3 = T.Text, TextSize = 18,
                    TextXAlignment = Enum.TextXAlignment.Left, Parent = cell,
                })
                create("TextLabel", {
                    BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 14), Position = UDim2.new(0, 0, 0, 24),
                    Font = Enum.Font.Gotham, Text = label, TextColor3 = T.TextFaint, TextSize = 10,
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
                Size = UDim2.new(1, -8, 0, 250), Position = UDim2.new(0, 0, 0, 220),
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
                { Version = "v1.0.3", Date = "2026-08-30", Text = "Popup color picker, CreateRow two-column layouts, improved Home changelog cards." },
                { Version = "v1.0.2", Date = "2026-08-30", Text = "Working color picker, multi-select dropdown + search/All, live server stats." },
                { Version = "v1.0.1", Date = "2026-08-29", Text = "Notification redesign, badge overflow fix, new banner." },
                { Version = "v1.0.0", Date = "2026-08-29", Text = "Initial CYVUI release — dashboard Home, Lucide icons, Settings themes." },
            }
            if entries[1] then
                local latest = create("TextLabel", {
                    BackgroundColor3 = Color3.fromRGB(20, 50, 55), Size = UDim2.new(0, 52, 0, 18),
                    Position = UDim2.new(1, -52, 0, 2), Text = entries[1].Version or "v1.0.3",
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
            listLayout(changeScroll, 8)

            for i, entry in ipairs(entries) do
                local card = create("Frame", {
                    BackgroundColor3 = Color3.fromRGB(18, 18, 24), Size = UDim2.new(1, -4, 0, 0),
                    AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = i, Parent = changeScroll,
                })
                corner(card, 10)
                stroke(card, i == 1 and T.Accent or T.Border, 1, i == 1 and 0.45 or 0.55)
                padding(card, 10, 10, 12, 12)
                listLayout(card, 6)

                local head = create("Frame", {
                    BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 20), Parent = card,
                })
                local ver = create("TextLabel", {
                    BackgroundColor3 = i == 1 and Color3.fromRGB(40, 28, 70) or Color3.fromRGB(28, 28, 36),
                    Size = UDim2.new(0, 54, 0, 18), Text = entry.Version or "?",
                    Font = Enum.Font.GothamBold, TextColor3 = i == 1 and T.Accent2 or T.Text, TextSize = 11, Parent = head,
                })
                corner(ver, 7)
                if i == 1 then bindTheme(ver, "TextColor3", "Accent2") end
                create("TextLabel", {
                    BackgroundTransparency = 1, Position = UDim2.new(0, 62, 0, 0), Size = UDim2.new(0.5, 0, 1, 0),
                    Font = Enum.Font.Gotham, Text = entry.Date or "", TextColor3 = T.TextFaint, TextSize = 11,
                    TextXAlignment = Enum.TextXAlignment.Left, Parent = head,
                })
                if i == 1 then
                    local latest = create("TextLabel", {
                        BackgroundColor3 = Color3.fromRGB(20, 50, 55), Size = UDim2.new(0, 48, 0, 16),
                        Position = UDim2.new(1, -48, 0.5, -8), Text = "Latest",
                        Font = Enum.Font.GothamBold, TextColor3 = T.Accent2, TextSize = 10, Parent = head,
                    })
                    corner(latest, 7)
                    bindTheme(latest, "TextColor3", "Accent2")
                end

                local bodyText = entry.Text or ""
                -- Support bullet lists via \n or table entry.Items
                if entry.Items and type(entry.Items) == "table" then
                    bodyText = "• " .. table.concat(entry.Items, "\n• ")
                end
                create("TextLabel", {
                    BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
                    Font = Enum.Font.Gotham, Text = bodyText, TextColor3 = T.TextDim, TextSize = 12,
                    TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left, Parent = card,
                })
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
                Text = "UI Transparency", Min = 20, Max = 100, Default = 100, Flag = "UITransparency",
                Callback = function(v)
                    Library.Flags.UITransparency = v
                    local alpha = math.clamp(v / 100, 0.35, 1)
                    -- Soften panel opacity for cards inside current pages
                    if window.Main then
                        for _, d in ipairs(window.Main:GetDescendants()) do
                            if d:IsA("Frame") and d.Name ~= "TitleBar" and d.BackgroundTransparency < 0.5 and d.BackgroundColor3 == T.Panel then
                                d.BackgroundTransparency = 1 - alpha
                            end
                        end
                    end
                end,
            })

            local configSec = tab:CreateSection("Config", { Icon = "bookmark" })
            configSec:AddDropdown({
                Text = "Load Config", Options = setConfig.Configs or { "default" }, Default = "default", Flag = "ConfigName",
            })
            configSec:AddButton({ Text = "Save Config", Accent = true, Callback = function()
                if setConfig.OnSave then pcall(setConfig.OnSave) else Library:Notify("Config", "Saved flags locally", 2, "success") end
            end })
            configSec:AddButton({ Text = "Load Config", Callback = function()
                if setConfig.OnLoad then pcall(setConfig.OnLoad) else Library:Notify("Config", "No loader hooked", 2, "warning") end
            end })
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
