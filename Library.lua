--[[
    CYVUI Library
    Dark modern Roblox UI library matching the CYVHUB home layout.
    Modules: Window, Tabs, Sidebar, Cards, Toggles, Buttons, Labels, etc.
]]

local Players          = game:GetService("Players")
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService       = game:GetService("RunService")
local HttpService      = game:GetService("HttpService")
local CoreGui          = game:GetService("CoreGui")
local TextService      = game:GetService("TextService")

local LocalPlayer = Players.LocalPlayer
local Mouse       = LocalPlayer:GetMouse()

local Library = {
    Version   = "1.0.0",
    Name      = "CYVUI",
    Windows   = {},
    Flags     = {},
    Theme     = {},
    Connections = {},
}

-- ═══════════════════════════════════════════
-- THEME
-- ═══════════════════════════════════════════
Library.Theme = {
    Background     = Color3.fromRGB(12, 12, 14),
    Sidebar        = Color3.fromRGB(16, 16, 18),
    Panel          = Color3.fromRGB(22, 22, 26),
    Card           = Color3.fromRGB(28, 28, 34),
    CardHover      = Color3.fromRGB(34, 34, 42),
    Input          = Color3.fromRGB(32, 32, 38),
    Divider        = Color3.fromRGB(40, 40, 48),
    Accent         = Color3.fromRGB(82, 190, 255),
    AccentDim      = Color3.fromRGB(50, 130, 180),
    AccentGlow     = Color3.fromRGB(130, 215, 255),
    Text           = Color3.fromRGB(235, 238, 245),
    TextDim        = Color3.fromRGB(140, 145, 155),
    TextMuted      = Color3.fromRGB(90, 95, 105),
    Success        = Color3.fromRGB(80, 200, 120),
    Warning        = Color3.fromRGB(230, 180, 50),
    Error          = Color3.fromRGB(230, 80, 90),
    ToggleOff      = Color3.fromRGB(50, 52, 60),
    ToggleOn       = Color3.fromRGB(82, 190, 255),
    ScrollBar      = Color3.fromRGB(60, 65, 75),
    TitleBar       = Color3.fromRGB(18, 18, 22),
    TrafficGreen   = Color3.fromRGB(80, 200, 100),
    TrafficYellow  = Color3.fromRGB(230, 180, 50),
    TrafficRed     = Color3.fromRGB(230, 80, 80),
}

local T = Library.Theme

-- ═══════════════════════════════════════════
-- UTILITIES
-- ═══════════════════════════════════════════
local function corner(parent, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 8)
    c.Parent = parent
    return c
end

local function padding(parent, top, bottom, left, right)
    local p = Instance.new("UIPadding")
    p.PaddingTop    = UDim.new(0, top or 0)
    p.PaddingBottom = UDim.new(0, bottom or 0)
    p.PaddingLeft   = UDim.new(0, left or 0)
    p.PaddingRight  = UDim.new(0, right or 0)
    p.Parent = parent
    return p
end

local function listLayout(parent, paddingPx, direction, horizontalAlign, verticalAlign)
    local l = Instance.new("UIListLayout")
    l.Padding = UDim.new(0, paddingPx or 6)
    l.FillDirection = direction or Enum.FillDirection.Vertical
    l.HorizontalAlignment = horizontalAlign or Enum.HorizontalAlignment.Left
    l.VerticalAlignment = verticalAlign or Enum.VerticalAlignment.Top
    l.SortOrder = Enum.SortOrder.LayoutOrder
    l.Parent = parent
    return l
end

local function stroke(parent, color, thickness, transparency)
    local s = Instance.new("UIStroke")
    s.Color = color or T.Divider
    s.Thickness = thickness or 1
    s.Transparency = transparency or 0.6
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent = parent
    return s
end

local function tween(obj, props, duration, style, dir)
    local info = TweenInfo.new(
        duration or 0.18,
        style or Enum.EasingStyle.Quad,
        dir or Enum.EasingDirection.Out
    )
    local tw = TweenService:Create(obj, info, props)
    tw:Play()
    return tw
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
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    handle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            if dragging then
                local delta = input.Position - dragStart
                frame.Position = UDim2.new(
                    startPos.X.Scale, startPos.X.Offset + delta.X,
                    startPos.Y.Scale, startPos.Y.Offset + delta.Y
                )
            end
        end
    end)
end

local function addShadow(frame)
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxassetid://6014261993"
    shadow.ImageColor3 = Color3.new(0, 0, 0)
    shadow.ImageTransparency = 0.55
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(49, 49, 450, 450)
    shadow.Size = UDim2.new(1, 40, 1, 40)
    shadow.Position = UDim2.new(0, -20, 0, -16)
    shadow.ZIndex = frame.ZIndex - 1
    shadow.Parent = frame
    return shadow
end

local function create(class, props)
    local inst = Instance.new(class)
    for k, v in pairs(props or {}) do
        if k ~= "Parent" then
            inst[k] = v
        end
    end
    if props and props.Parent then
        inst.Parent = props.Parent
    end
    return inst
end

local function protectGui(gui)
    if syn and syn.protect_gui then
        syn.protect_gui(gui)
        gui.Parent = CoreGui
    elseif gethui then
        gui.Parent = gethui()
    else
        pcall(function()
            gui.Parent = CoreGui
        end)
        if not gui.Parent then
            gui.Parent = LocalPlayer:WaitForChild("PlayerGui")
        end
    end
end

-- ═══════════════════════════════════════════
-- NOTIFICATIONS
-- ═══════════════════════════════════════════
function Library:Notify(title, message, duration, notifType)
    duration = duration or 3
    local color = T.Accent
    if notifType == "success" then color = T.Success
    elseif notifType == "warning" then color = T.Warning
    elseif notifType == "error" then color = T.Error end

    local holder = self._NotifyHolder
    if not holder then
        holder = create("ScreenGui", {
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
            Size = UDim2.new(0, 320, 1, 0),
            Position = UDim2.new(1, -340, 0, 20),
            Parent = holder,
        })
        listLayout(list, 8, Enum.FillDirection.Vertical, Enum.HorizontalAlignment.Right, Enum.VerticalAlignment.Top)
        self._NotifyList = list
    end

    local card = create("Frame", {
        Name = "Notif",
        BackgroundColor3 = T.Card,
        Size = UDim2.new(0, 300, 0, 0),
        ClipsDescendants = true,
        Parent = self._NotifyList,
    })
    corner(card, 10)
    stroke(card, color, 1.5, 0.3)

    local accentBar = create("Frame", {
        BackgroundColor3 = color,
        Size = UDim2.new(0, 4, 1, 0),
        BorderSizePixel = 0,
        Parent = card,
    })
    corner(accentBar, 2)

    local titleLbl = create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 16, 0, 10),
        Size = UDim2.new(1, -28, 0, 20),
        Font = Enum.Font.GothamBold,
        Text = title or "Notification",
        TextColor3 = T.Text,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = card,
    })

    local msgLbl = create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 16, 0, 32),
        Size = UDim2.new(1, -28, 0, 40),
        Font = Enum.Font.Gotham,
        Text = message or "",
        TextColor3 = T.TextDim,
        TextSize = 12,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        Parent = card,
    })

    local textBounds = TextService:GetTextSize(message or "", 12, Enum.Font.Gotham, Vector2.new(272, 200))
    local height = math.clamp(textBounds.Y + 50, 60, 140)
    card.Size = UDim2.new(0, 300, 0, height)

    card.BackgroundTransparency = 1
    titleLbl.TextTransparency = 1
    msgLbl.TextTransparency = 1
    tween(card, { BackgroundTransparency = 0 }, 0.25)
    tween(titleLbl, { TextTransparency = 0 }, 0.25)
    tween(msgLbl, { TextTransparency = 0 }, 0.25)

    task.delay(duration, function()
        tween(card, { BackgroundTransparency = 1 }, 0.3)
        tween(titleLbl, { TextTransparency = 1 }, 0.3)
        tween(msgLbl, { TextTransparency = 1 }, 0.3)
        task.wait(0.35)
        card:Destroy()
    end)
end

-- ═══════════════════════════════════════════
-- WINDOW
-- ═══════════════════════════════════════════
function Library:CreateWindow(config)
    config = config or {}
    local title      = config.Title or "CYVHUB"
    local gameName   = config.GameName or "game name"
    local version    = config.Version or "v1.0"
    local size       = config.Size or UDim2.new(0, 720, 0, 480)
    local minSize    = config.MinSize or Vector2.new(560, 360)

    -- Destroy previous
    for _, old in ipairs(self.Windows) do
        if old and old.ScreenGui then
            old.ScreenGui:Destroy()
        end
    end
    table.clear(self.Windows)

    local screenGui = create("ScreenGui", {
        Name = "CYVUI_" .. HttpService:GenerateGUID(false):sub(1, 8),
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        DisplayOrder = 50,
    })
    protectGui(screenGui)

    local main = create("Frame", {
        Name = "Main",
        BackgroundColor3 = T.Background,
        Size = size,
        Position = UDim2.new(0.5, -size.X.Offset / 2, 0.5, -size.Y.Offset / 2),
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Parent = screenGui,
    })
    corner(main, 14)
    stroke(main, T.Divider, 1, 0.5)
    addShadow(main)

    -- Title bar
    local titleBar = create("Frame", {
        Name = "TitleBar",
        BackgroundColor3 = T.TitleBar,
        Size = UDim2.new(1, 0, 0, 36),
        BorderSizePixel = 0,
        Parent = main,
    })
    corner(titleBar, 14)
    -- Fix bottom corners of title bar
    local titleFix = create("Frame", {
        BackgroundColor3 = T.TitleBar,
        Size = UDim2.new(1, 0, 0, 14),
        Position = UDim2.new(0, 0, 1, -14),
        BorderSizePixel = 0,
        Parent = titleBar,
    })

    local titleText = create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 14, 0, 0),
        Size = UDim2.new(1, -100, 1, 0),
        Font = Enum.Font.GothamMedium,
        Text = string.format("%s  |  %s  |  %s", title, gameName, version),
        TextColor3 = T.TextDim,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = titleBar,
    })

    -- Traffic lights
    local traffic = create("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 70, 0, 36),
        Position = UDim2.new(1, -78, 0, 0),
        Parent = titleBar,
    })
    listLayout(traffic, 8, Enum.FillDirection.Horizontal, Enum.HorizontalAlignment.Right, Enum.VerticalAlignment.Center)
    padding(traffic, 0, 0, 0, 10)

    local function trafficBtn(color, callback)
        local btn = create("TextButton", {
            BackgroundColor3 = color,
            Size = UDim2.new(0, 12, 0, 12),
            Text = "",
            AutoButtonColor = false,
            Parent = traffic,
        })
        corner(btn, 6)
        btn.MouseButton1Click:Connect(function()
            if callback then callback() end
        end)
        return btn
    end

    local minimized = false
    local contentHolder

    trafficBtn(T.TrafficGreen, function()
        -- maximize / restore (no-op for now, keep size)
    end)
    trafficBtn(T.TrafficYellow, function()
        minimized = not minimized
        if contentHolder then
            contentHolder.Visible = not minimized
        end
        main.Size = minimized and UDim2.new(0, size.X.Offset, 0, 36) or size
    end)
    trafficBtn(T.TrafficRed, function()
        screenGui:Destroy()
    end)

    makeDraggable(main, titleBar)

    -- Body
    contentHolder = create("Frame", {
        Name = "Content",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, -36),
        Position = UDim2.new(0, 0, 0, 36),
        Parent = main,
    })

    -- Sidebar
    local sidebar = create("Frame", {
        Name = "Sidebar",
        BackgroundColor3 = T.Sidebar,
        Size = UDim2.new(0, 140, 1, 0),
        BorderSizePixel = 0,
        Parent = contentHolder,
    })

    local sidebarList = create("Frame", {
        Name = "Tabs",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, -50),
        Position = UDim2.new(0, 0, 0, 8),
        Parent = sidebar,
    })
    listLayout(sidebarList, 4)
    padding(sidebarList, 4, 4, 8, 8)

    local settingsBtn = create("TextButton", {
        Name = "SettingsTab",
        BackgroundColor3 = T.Card,
        Size = UDim2.new(1, -16, 0, 34),
        Position = UDim2.new(0, 8, 1, -42),
        Text = "",
        AutoButtonColor = false,
        Parent = sidebar,
    })
    corner(settingsBtn, 8)

    local settingsIcon = create("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 28, 1, 0),
        Position = UDim2.new(0, 6, 0, 0),
        Font = Enum.Font.GothamBold,
        Text = "⚙",
        TextColor3 = T.TextDim,
        TextSize = 16,
        Parent = settingsBtn,
    })

    local settingsLabel = create("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -40, 1, 0),
        Position = UDim2.new(0, 34, 0, 0),
        Font = Enum.Font.GothamMedium,
        Text = "Settings",
        TextColor3 = T.TextDim,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = settingsBtn,
    })

    -- Pages container
    local pages = create("Frame", {
        Name = "Pages",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -148, 1, -12),
        Position = UDim2.new(0, 148, 0, 6),
        Parent = contentHolder,
    })

    local window = {
        ScreenGui     = screenGui,
        Main          = main,
        TitleBar      = titleBar,
        Sidebar       = sidebar,
        SidebarList   = sidebarList,
        Pages         = pages,
        SettingsBtn   = settingsBtn,
        Tabs          = {},
        CurrentTab    = nil,
        Config        = config,
    }

    function window:SetTitle(newTitle, newGame, newVer)
        titleText.Text = string.format("%s  |  %s  |  %s",
            newTitle or title,
            newGame or gameName,
            newVer or version
        )
    end

    function window:CreateTab(tabConfig)
        tabConfig = tabConfig or {}
        local tabName  = tabConfig.Name or "Tab"
        local tabIcon  = tabConfig.Icon or "•"
        local isHome   = tabConfig.Home == true

        local tabBtn = create("TextButton", {
            Name = tabName .. "Tab",
            BackgroundColor3 = isHome and T.Card or Color3.fromRGB(0, 0, 0),
            BackgroundTransparency = isHome and 0 or 1,
            Size = UDim2.new(1, 0, 0, 36),
            Text = "",
            AutoButtonColor = false,
            LayoutOrder = #window.Tabs + 1,
            Parent = sidebarList,
        })
        corner(tabBtn, 8)

        local iconLbl = create("TextLabel", {
            BackgroundTransparency = 1,
            Size = UDim2.new(0, 28, 1, 0),
            Position = UDim2.new(0, 6, 0, 0),
            Font = Enum.Font.GothamBold,
            Text = tabIcon,
            TextColor3 = isHome and T.Text or T.TextDim,
            TextSize = 15,
            Parent = tabBtn,
        })

        local nameLbl = create("TextLabel", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, -40, 1, 0),
            Position = UDim2.new(0, 34, 0, 0),
            Font = Enum.Font.GothamMedium,
            Text = tabName,
            TextColor3 = isHome and T.Text or T.TextDim,
            TextSize = 13,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = tabBtn,
        })

        local page = create("ScrollingFrame", {
            Name = tabName .. "Page",
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            CanvasSize = UDim2.new(0, 0, 0, 0),
            ScrollBarThickness = 4,
            ScrollBarImageColor3 = T.ScrollBar,
            BorderSizePixel = 0,
            Visible = isHome,
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            Parent = pages,
        })
        padding(page, 4, 12, 4, 8)
        local pageLayout = listLayout(page, 10)
        pageLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left

        local tab = {
            Name     = tabName,
            Button   = tabBtn,
            Page     = page,
            Icon     = iconLbl,
            Label    = nameLbl,
            Sections = {},
            IsHome   = isHome,
        }

        local function selectTab()
            for _, t in ipairs(window.Tabs) do
                t.Page.Visible = false
                t.Button.BackgroundTransparency = 1
                t.Button.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
                t.Icon.TextColor3 = T.TextDim
                t.Label.TextColor3 = T.TextDim
            end
            -- Settings special
            settingsBtn.BackgroundColor3 = T.Card
            settingsBtn.BackgroundTransparency = 1
            settingsIcon.TextColor3 = T.TextDim
            settingsLabel.TextColor3 = T.TextDim

            page.Visible = true
            tabBtn.BackgroundTransparency = 0
            tabBtn.BackgroundColor3 = T.Card
            iconLbl.TextColor3 = T.Text
            nameLbl.TextColor3 = T.Text
            window.CurrentTab = tab
        end

        tabBtn.MouseButton1Click:Connect(selectTab)
        tabBtn.MouseEnter:Connect(function()
            if window.CurrentTab ~= tab then
                tween(tabBtn, { BackgroundTransparency = 0.7 }, 0.12)
            end
        end)
        tabBtn.MouseLeave:Connect(function()
            if window.CurrentTab ~= tab then
                tween(tabBtn, { BackgroundTransparency = 1 }, 0.12)
            end
        end)

        if isHome then
            window.CurrentTab = tab
        end

        -- Section / Card helpers
        function tab:CreateSection(sectionName)
            local section = create("Frame", {
                Name = sectionName or "Section",
                BackgroundColor3 = T.Card,
                Size = UDim2.new(1, -8, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                BorderSizePixel = 0,
                LayoutOrder = #tab.Sections + 1,
                Parent = page,
            })
            corner(section, 12)
            padding(section, 12, 12, 14, 14)
            listLayout(section, 8)

            local header = create("TextLabel", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 20),
                Font = Enum.Font.GothamBold,
                Text = sectionName or "Section",
                TextColor3 = T.Text,
                TextSize = 15,
                TextXAlignment = Enum.TextXAlignment.Left,
                LayoutOrder = 0,
                Parent = section,
            })

            local sec = { Frame = section, Header = header, Elements = {} }

            function sec:AddLabel(text)
                local lbl = create("TextLabel", {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 0),
                    AutomaticSize = Enum.AutomaticSize.Y,
                    Font = Enum.Font.Gotham,
                    Text = text or "",
                    TextColor3 = T.TextDim,
                    TextSize = 13,
                    TextWrapped = true,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    LayoutOrder = #sec.Elements + 1,
                    Parent = section,
                })
                table.insert(sec.Elements, lbl)
                return lbl
            end

            function sec:AddButton(btnConfig)
                btnConfig = btnConfig or {}
                local btn = create("TextButton", {
                    BackgroundColor3 = T.Input,
                    Size = UDim2.new(1, 0, 0, 34),
                    Text = btnConfig.Text or "Button",
                    Font = Enum.Font.GothamMedium,
                    TextColor3 = T.Text,
                    TextSize = 13,
                    AutoButtonColor = false,
                    LayoutOrder = #sec.Elements + 1,
                    Parent = section,
                })
                corner(btn, 8)

                btn.MouseEnter:Connect(function()
                    tween(btn, { BackgroundColor3 = T.CardHover }, 0.12)
                end)
                btn.MouseLeave:Connect(function()
                    tween(btn, { BackgroundColor3 = T.Input }, 0.12)
                end)
                btn.MouseButton1Click:Connect(function()
                    tween(btn, { BackgroundColor3 = T.Accent }, 0.08)
                    task.wait(0.08)
                    tween(btn, { BackgroundColor3 = T.Input }, 0.15)
                    if btnConfig.Callback then
                        pcall(btnConfig.Callback)
                    end
                end)

                table.insert(sec.Elements, btn)
                return btn
            end

            function sec:AddToggle(togConfig)
                togConfig = togConfig or {}
                local flag = togConfig.Flag
                local default = togConfig.Default or false
                if flag then Library.Flags[flag] = default end

                local row = create("Frame", {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 32),
                    LayoutOrder = #sec.Elements + 1,
                    Parent = section,
                })

                local label = create("TextLabel", {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, -60, 1, 0),
                    Font = Enum.Font.Gotham,
                    Text = togConfig.Text or "Toggle",
                    TextColor3 = T.Text,
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = row,
                })

                local track = create("Frame", {
                    BackgroundColor3 = default and T.ToggleOn or T.ToggleOff,
                    Size = UDim2.new(0, 44, 0, 24),
                    Position = UDim2.new(1, -44, 0.5, -12),
                    Parent = row,
                })
                corner(track, 12)

                local knob = create("Frame", {
                    BackgroundColor3 = T.Text,
                    Size = UDim2.new(0, 18, 0, 18),
                    Position = default and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9),
                    Parent = track,
                })
                corner(knob, 9)

                local state = default
                local function setState(v, fire)
                    state = v
                    if flag then Library.Flags[flag] = v end
                    tween(track, { BackgroundColor3 = v and T.ToggleOn or T.ToggleOff }, 0.18)
                    tween(knob, { Position = v and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9) }, 0.18)
                    if fire and togConfig.Callback then
                        pcall(togConfig.Callback, v)
                    end
                end

                local hit = create("TextButton", {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 1, 0),
                    Text = "",
                    Parent = row,
                })
                hit.MouseButton1Click:Connect(function()
                    setState(not state, true)
                end)

                table.insert(sec.Elements, row)
                return {
                    Set = function(_, v) setState(v, true) end,
                    Get = function() return state end,
                    Frame = row,
                }
            end

            function sec:AddSlider(sliderConfig)
                sliderConfig = sliderConfig or {}
                local minV = sliderConfig.Min or 0
                local maxV = sliderConfig.Max or 100
                local default = sliderConfig.Default or minV
                local flag = sliderConfig.Flag
                local decimals = sliderConfig.Decimals or 0
                if flag then Library.Flags[flag] = default end

                local row = create("Frame", {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 48),
                    LayoutOrder = #sec.Elements + 1,
                    Parent = section,
                })

                local label = create("TextLabel", {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(0.7, 0, 0, 18),
                    Font = Enum.Font.Gotham,
                    Text = sliderConfig.Text or "Slider",
                    TextColor3 = T.Text,
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = row,
                })

                local valueLbl = create("TextLabel", {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(0.3, 0, 0, 18),
                    Position = UDim2.new(0.7, 0, 0, 0),
                    Font = Enum.Font.GothamMedium,
                    Text = tostring(default),
                    TextColor3 = T.Accent,
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Right,
                    Parent = row,
                })

                local barBg = create("Frame", {
                    BackgroundColor3 = T.Input,
                    Size = UDim2.new(1, 0, 0, 8),
                    Position = UDim2.new(0, 0, 0, 28),
                    Parent = row,
                })
                corner(barBg, 4)

                local fill = create("Frame", {
                    BackgroundColor3 = T.Accent,
                    Size = UDim2.new((default - minV) / (maxV - minV), 0, 1, 0),
                    Parent = barBg,
                })
                corner(fill, 4)

                local knob = create("Frame", {
                    BackgroundColor3 = T.Text,
                    Size = UDim2.new(0, 14, 0, 14),
                    Position = UDim2.new((default - minV) / (maxV - minV), -7, 0.5, -7),
                    Parent = barBg,
                    ZIndex = 2,
                })
                corner(knob, 7)

                local sliding = false
                local function update(input)
                    local rel = math.clamp((input.X - barBg.AbsolutePosition.X) / barBg.AbsoluteSize.X, 0, 1)
                    local val = minV + (maxV - minV) * rel
                    if decimals > 0 then
                        val = math.floor(val * (10 ^ decimals) + 0.5) / (10 ^ decimals)
                    else
                        val = math.floor(val + 0.5)
                    end
                    fill.Size = UDim2.new(rel, 0, 1, 0)
                    knob.Position = UDim2.new(rel, -7, 0.5, -7)
                    valueLbl.Text = tostring(val)
                    if flag then Library.Flags[flag] = val end
                    if sliderConfig.Callback then
                        pcall(sliderConfig.Callback, val)
                    end
                end

                barBg.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        sliding = true
                        update(input.Position)
                    end
                end)
                UserInputService.InputChanged:Connect(function(input)
                    if sliding and input.UserInputType == Enum.UserInputType.MouseMovement then
                        update(input.Position)
                    end
                end)
                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        sliding = false
                    end
                end)

                table.insert(sec.Elements, row)
                return row
            end

            function sec:AddDropdown(dropConfig)
                dropConfig = dropConfig or {}
                local options = dropConfig.Options or { "Option 1" }
                local default = dropConfig.Default or options[1]
                local flag = dropConfig.Flag
                if flag then Library.Flags[flag] = default end

                local row = create("Frame", {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 34),
                    LayoutOrder = #sec.Elements + 1,
                    ClipsDescendants = false,
                    Parent = section,
                })

                local label = create("TextLabel", {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(0.4, 0, 1, 0),
                    Font = Enum.Font.Gotham,
                    Text = dropConfig.Text or "Dropdown",
                    TextColor3 = T.Text,
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = row,
                })

                local box = create("TextButton", {
                    BackgroundColor3 = T.Input,
                    Size = UDim2.new(0.58, 0, 0, 30),
                    Position = UDim2.new(0.42, 0, 0.5, -15),
                    Text = default,
                    Font = Enum.Font.Gotham,
                    TextColor3 = T.Text,
                    TextSize = 12,
                    AutoButtonColor = false,
                    Parent = row,
                })
                corner(box, 6)

                local open = false
                local listFrame = create("Frame", {
                    BackgroundColor3 = T.Panel,
                    Size = UDim2.new(0.58, 0, 0, 0),
                    Position = UDim2.new(0.42, 0, 1, 4),
                    Visible = false,
                    ZIndex = 20,
                    ClipsDescendants = true,
                    Parent = row,
                })
                corner(listFrame, 6)
                stroke(listFrame, T.Divider, 1, 0.4)
                local listLay = listLayout(listFrame, 2)
                padding(listFrame, 4, 4, 4, 4)

                for _, opt in ipairs(options) do
                    local optBtn = create("TextButton", {
                        BackgroundColor3 = T.Input,
                        Size = UDim2.new(1, 0, 0, 26),
                        Text = opt,
                        Font = Enum.Font.Gotham,
                        TextColor3 = T.Text,
                        TextSize = 12,
                        AutoButtonColor = false,
                        ZIndex = 21,
                        Parent = listFrame,
                    })
                    corner(optBtn, 4)
                    optBtn.MouseButton1Click:Connect(function()
                        box.Text = opt
                        if flag then Library.Flags[flag] = opt end
                        if dropConfig.Callback then pcall(dropConfig.Callback, opt) end
                        open = false
                        listFrame.Visible = false
                        listFrame.Size = UDim2.new(0.58, 0, 0, 0)
                    end)
                    optBtn.MouseEnter:Connect(function()
                        tween(optBtn, { BackgroundColor3 = T.CardHover }, 0.1)
                    end)
                    optBtn.MouseLeave:Connect(function()
                        tween(optBtn, { BackgroundColor3 = T.Input }, 0.1)
                    end)
                end

                box.MouseButton1Click:Connect(function()
                    open = not open
                    listFrame.Visible = open
                    local h = math.min(#options * 30 + 8, 160)
                    listFrame.Size = open and UDim2.new(0.58, 0, 0, h) or UDim2.new(0.58, 0, 0, 0)
                end)

                table.insert(sec.Elements, row)
                return row
            end

            function sec:AddTextbox(tbConfig)
                tbConfig = tbConfig or {}
                local flag = tbConfig.Flag
                local default = tbConfig.Default or ""
                if flag then Library.Flags[flag] = default end

                local row = create("Frame", {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 34),
                    LayoutOrder = #sec.Elements + 1,
                    Parent = section,
                })

                local label = create("TextLabel", {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(0.35, 0, 1, 0),
                    Font = Enum.Font.Gotham,
                    Text = tbConfig.Text or "Input",
                    TextColor3 = T.Text,
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = row,
                })

                local box = create("TextBox", {
                    BackgroundColor3 = T.Input,
                    Size = UDim2.new(0.63, 0, 0, 30),
                    Position = UDim2.new(0.37, 0, 0.5, -15),
                    Text = default,
                    PlaceholderText = tbConfig.Placeholder or "...",
                    PlaceholderColor3 = T.TextMuted,
                    Font = Enum.Font.Gotham,
                    TextColor3 = T.Text,
                    TextSize = 12,
                    ClearTextOnFocus = false,
                    Parent = row,
                })
                corner(box, 6)
                padding(box, 0, 0, 8, 8)

                box.FocusLost:Connect(function()
                    if flag then Library.Flags[flag] = box.Text end
                    if tbConfig.Callback then pcall(tbConfig.Callback, box.Text) end
                end)

                table.insert(sec.Elements, row)
                return box
            end

            function sec:AddKeybind(kbConfig)
                kbConfig = kbConfig or {}
                local default = kbConfig.Default or Enum.KeyCode.Unknown
                local flag = kbConfig.Flag
                if flag then Library.Flags[flag] = default end

                local row = create("Frame", {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 32),
                    LayoutOrder = #sec.Elements + 1,
                    Parent = section,
                })

                local label = create("TextLabel", {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, -90, 1, 0),
                    Font = Enum.Font.Gotham,
                    Text = kbConfig.Text or "Keybind",
                    TextColor3 = T.Text,
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = row,
                })

                local keyBtn = create("TextButton", {
                    BackgroundColor3 = T.Input,
                    Size = UDim2.new(0, 80, 0, 26),
                    Position = UDim2.new(1, -80, 0.5, -13),
                    Text = default == Enum.KeyCode.Unknown and "None" or default.Name,
                    Font = Enum.Font.GothamMedium,
                    TextColor3 = T.TextDim,
                    TextSize = 12,
                    AutoButtonColor = false,
                    Parent = row,
                })
                corner(keyBtn, 6)

                local listening = false
                keyBtn.MouseButton1Click:Connect(function()
                    listening = true
                    keyBtn.Text = "..."
                    keyBtn.TextColor3 = T.Accent
                end)

                local conn
                conn = UserInputService.InputBegan:Connect(function(input, gp)
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
                        if kbConfig.Callback then pcall(kbConfig.Callback, key) end
                    end
                end)

                table.insert(sec.Elements, row)
                return keyBtn
            end

            function sec:AddParagraph(text)
                local lbl = create("TextLabel", {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 0),
                    AutomaticSize = Enum.AutomaticSize.Y,
                    Font = Enum.Font.Gotham,
                    Text = text or "",
                    TextColor3 = T.TextDim,
                    TextSize = 12,
                    TextWrapped = true,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    LayoutOrder = #sec.Elements + 1,
                    Parent = section,
                })
                table.insert(sec.Elements, lbl)
                return lbl
            end

            table.insert(tab.Sections, sec)
            return sec
        end

        -- Home-specific layout matching the screenshot
        function tab:CreateHomeLayout(homeConfig)
            homeConfig = homeConfig or {}
            -- Clear default layout for custom grid
            for _, child in ipairs(page:GetChildren()) do
                if child:IsA("UIListLayout") or child:IsA("UIPadding") then
                    child:Destroy()
                end
            end
            padding(page, 4, 12, 4, 8)

            local topRow = create("Frame", {
                Name = "TopRow",
                BackgroundTransparency = 1,
                Size = UDim2.new(1, -8, 0, 110),
                Position = UDim2.new(0, 0, 0, 0),
                Parent = page,
            })

            -- User card
            local userCard = create("Frame", {
                BackgroundColor3 = T.Card,
                Size = UDim2.new(0.38, -6, 1, 0),
                Parent = topRow,
            })
            corner(userCard, 12)

            local avatar = create("Frame", {
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                Size = UDim2.new(0, 64, 0, 64),
                Position = UDim2.new(0, 16, 0.5, -32),
                Parent = userCard,
            })
            corner(avatar, 32)

            -- Try real avatar
            local avatarImg = create("ImageLabel", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 1, 0),
                Image = "",
                Parent = avatar,
            })
            corner(avatarImg, 32)
            task.spawn(function()
                local ok, content = pcall(function()
                    return Players:GetUserThumbnailAsync(
                        LocalPlayer.UserId,
                        Enum.ThumbnailType.HeadShot,
                        Enum.ThumbnailSize.Size100x100
                    )
                end)
                if ok and content then
                    avatarImg.Image = content
                    avatar.BackgroundTransparency = 1
                end
            end)

            local userName = create("TextLabel", {
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 96, 0, 28),
                Size = UDim2.new(1, -110, 0, 24),
                Font = Enum.Font.GothamBold,
                Text = homeConfig.Username or LocalPlayer.DisplayName or LocalPlayer.Name,
                TextColor3 = T.Text,
                TextSize = 18,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextTruncate = Enum.TextTruncate.AtEnd,
                Parent = userCard,
            })

            local welcome = create("TextLabel", {
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 96, 0, 54),
                Size = UDim2.new(1, -110, 0, 20),
                Font = Enum.Font.Gotham,
                Text = homeConfig.Welcome or "welcome back",
                TextColor3 = T.TextDim,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = userCard,
            })

            -- About card
            local aboutCard = create("Frame", {
                BackgroundColor3 = T.Card,
                Size = UDim2.new(0.62, -6, 1, 0),
                Position = UDim2.new(0.38, 6, 0, 0),
                Parent = topRow,
            })
            corner(aboutCard, 12)
            padding(aboutCard, 12, 12, 14, 14)

            local aboutTitle = create("TextLabel", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 20),
                Font = Enum.Font.GothamBold,
                Text = homeConfig.AboutTitle or "About",
                TextColor3 = T.Text,
                TextSize = 15,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = aboutCard,
            })

            local aboutBody = create("TextLabel", {
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 0, 0, 24),
                Size = UDim2.new(1, 0, 1, -28),
                Font = Enum.Font.Gotham,
                Text = homeConfig.AboutText or "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",
                TextColor3 = T.TextDim,
                TextSize = 12,
                TextWrapped = true,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextYAlignment = Enum.TextYAlignment.Top,
                Parent = aboutCard,
            })

            -- Mid row: Discord | Server Info | Executor
            local midRow = create("Frame", {
                Name = "MidRow",
                BackgroundTransparency = 1,
                Size = UDim2.new(1, -8, 0, 90),
                Position = UDim2.new(0, 0, 0, 122),
                Parent = page,
            })

            local discordCard = create("Frame", {
                BackgroundColor3 = T.Card,
                Size = UDim2.new(0.22, -6, 1, 0),
                Parent = midRow,
            })
            corner(discordCard, 12)
            padding(discordCard, 12, 12, 12, 12)

            local discordTitle = create("TextLabel", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 22),
                Font = Enum.Font.GothamBold,
                Text = "Discord",
                TextColor3 = T.Text,
                TextSize = 15,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = discordCard,
            })

            local copyBtn = create("TextButton", {
                BackgroundColor3 = T.Input,
                Size = UDim2.new(1, 0, 0, 28),
                Position = UDim2.new(0, 0, 0, 36),
                Text = "Copy Link",
                Font = Enum.Font.GothamMedium,
                TextColor3 = T.Text,
                TextSize = 12,
                AutoButtonColor = false,
                Parent = discordCard,
            })
            corner(copyBtn, 8)
            copyBtn.MouseButton1Click:Connect(function()
                local link = homeConfig.DiscordLink or "https://discord.gg/cyvhub"
                if setclipboard then
                    setclipboard(link)
                    Library:Notify("Discord", "Invite link copied!", 2, "success")
                else
                    Library:Notify("Discord", link, 4)
                end
            end)
            copyBtn.MouseEnter:Connect(function()
                tween(copyBtn, { BackgroundColor3 = T.CardHover }, 0.12)
            end)
            copyBtn.MouseLeave:Connect(function()
                tween(copyBtn, { BackgroundColor3 = T.Input }, 0.12)
            end)

            local serverCard = create("Frame", {
                BackgroundColor3 = T.Card,
                Size = UDim2.new(0.48, -6, 1, 0),
                Position = UDim2.new(0.22, 6, 0, 0),
                Parent = midRow,
            })
            corner(serverCard, 12)
            padding(serverCard, 12, 12, 14, 14)

            local serverTitle = create("TextLabel", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 20),
                Font = Enum.Font.GothamBold,
                Text = "Server Info",
                TextColor3 = T.Text,
                TextSize = 15,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = serverCard,
            })

            local serverBody = create("TextLabel", {
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 0, 0, 28),
                Size = UDim2.new(1, 0, 1, -32),
                Font = Enum.Font.Gotham,
                Text = homeConfig.ServerInfo or string.format("Players: %d\nJobId: %s", #Players:GetPlayers(), game.JobId:sub(1, 12) .. "..."),
                TextColor3 = T.TextDim,
                TextSize = 12,
                TextWrapped = true,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextYAlignment = Enum.TextYAlignment.Top,
                Parent = serverCard,
            })

            local executorCard = create("Frame", {
                BackgroundColor3 = T.Card,
                Size = UDim2.new(0.3, -6, 1, 0),
                Position = UDim2.new(0.7, 6, 0, 0),
                Parent = midRow,
            })
            corner(executorCard, 12)
            padding(executorCard, 12, 12, 14, 14)

            local execTitle = create("TextLabel", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 20),
                Font = Enum.Font.GothamBold,
                Text = "Executor",
                TextColor3 = T.Text,
                TextSize = 15,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = executorCard,
            })

            local execName = create("TextLabel", {
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 0, 0, 32),
                Size = UDim2.new(1, 0, 0, 24),
                Font = Enum.Font.GothamMedium,
                Text = homeConfig.ExecutorName or (identifyexecutor and identifyexecutor() or "Unknown"),
                TextColor3 = T.TextDim,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = executorCard,
            })

            -- Changelog card
            local changeCard = create("Frame", {
                Name = "Changelog",
                BackgroundColor3 = T.Card,
                Size = UDim2.new(1, -8, 0, 160),
                Position = UDim2.new(0, 0, 0, 224),
                Parent = page,
            })
            corner(changeCard, 12)
            padding(changeCard, 12, 12, 14, 14)

            local changeTitle = create("TextLabel", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 22),
                Font = Enum.Font.GothamBold,
                Text = "Changelog",
                TextColor3 = T.Text,
                TextSize = 15,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = changeCard,
            })

            local changeScroll = create("ScrollingFrame", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 1, -28),
                Position = UDim2.new(0, 0, 0, 28),
                CanvasSize = UDim2.new(0, 0, 0, 0),
                AutomaticCanvasSize = Enum.AutomaticSize.Y,
                ScrollBarThickness = 3,
                ScrollBarImageColor3 = T.ScrollBar,
                BorderSizePixel = 0,
                Parent = changeCard,
            })
            listLayout(changeScroll, 6)

            local entries = homeConfig.Changelog or {
                { Version = "v1.0.0", Text = "Initial release of CYVUI Library." },
            }
            for i, entry in ipairs(entries) do
                local line = create("TextLabel", {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, -4, 0, 0),
                    AutomaticSize = Enum.AutomaticSize.Y,
                    Font = Enum.Font.Gotham,
                    Text = string.format("[%s]  %s", entry.Version or "?", entry.Text or ""),
                    TextColor3 = T.TextDim,
                    TextSize = 12,
                    TextWrapped = true,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    LayoutOrder = i,
                    Parent = changeScroll,
                })
            end

            return {
                UserCard = userCard,
                AboutCard = aboutCard,
                DiscordCard = discordCard,
                ServerCard = serverCard,
                ExecutorCard = executorCard,
                ChangelogCard = changeCard,
                SetUsername = function(_, name)
                    userName.Text = name
                end,
                SetAbout = function(_, text)
                    aboutBody.Text = text
                end,
                SetServerInfo = function(_, text)
                    serverBody.Text = text
                end,
                SetExecutor = function(_, name)
                    execName.Text = name
                end,
            }
        end

        table.insert(window.Tabs, tab)
        return tab
    end

    -- Settings tab wiring
    local settingsTab = window:CreateTab({ Name = "Settings", Icon = "⚙", Home = false })
    settingsTab.Button.Visible = false -- use bottom button instead

    settingsBtn.MouseButton1Click:Connect(function()
        for _, t in ipairs(window.Tabs) do
            t.Page.Visible = false
            t.Button.BackgroundTransparency = 1
            t.Icon.TextColor3 = T.TextDim
            t.Label.TextColor3 = T.TextDim
        end
        settingsTab.Page.Visible = true
        settingsBtn.BackgroundTransparency = 0
        settingsBtn.BackgroundColor3 = T.Card
        settingsIcon.TextColor3 = T.Text
        settingsLabel.TextColor3 = T.Text
        window.CurrentTab = settingsTab
    end)

    -- Default settings content
    local setSec = settingsTab:CreateSection("Appearance")
    setSec:AddDropdown({
        Text = "Accent Theme",
        Options = { "Cyan", "Green", "Purple", "Crimson", "Gold" },
        Default = "Cyan",
        Callback = function(opt)
            local map = {
                Cyan    = Color3.fromRGB(82, 190, 255),
                Green   = Color3.fromRGB(0, 200, 150),
                Purple  = Color3.fromRGB(170, 115, 255),
                Crimson = Color3.fromRGB(255, 80, 95),
                Gold    = Color3.fromRGB(230, 185, 40),
            }
            local c = map[opt] or map.Cyan
            T.Accent = c
            T.ToggleOn = c
            T.AccentDim = Color3.new(c.R * 0.6, c.G * 0.6, c.B * 0.6)
            Library:Notify("Theme", "Accent set to " .. opt, 2)
        end,
    })

    setSec:AddToggle({
        Text = "Show Keybind HUD",
        Default = false,
        Flag = "KeybindHUD",
    })

    local setSec2 = settingsTab:CreateSection("Window")
    setSec2:AddButton({
        Text = "Destroy UI",
        Callback = function()
            screenGui:Destroy()
        end,
    })

    -- Toggle UI with RightControl
    UserInputService.InputBegan:Connect(function(input, gp)
        if gp then return end
        if input.KeyCode == Enum.KeyCode.RightControl then
            main.Visible = not main.Visible
        end
    end)

    table.insert(self.Windows, window)
    return window
end

function Library:GetFlag(name)
    return self.Flags[name]
end

function Library:SetFlag(name, value)
    self.Flags[name] = value
end

return Library
