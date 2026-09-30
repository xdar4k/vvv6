-- ╔═════════════════════════════════════════════════════════════════════╗
-- ║  99 Nights in the Forest  |  Hard Mode  |  by xdar4k  v2.5         ║
-- ║  ✅ Speed  ✅ Teleports  ✅ Marker+Items  ✅ Chest ESP                ║
-- ║  ✅ GOD MODE  ✅ Чат→ТП предмета  ✅ FPS Flush  ✅ Optimize          ║
-- ║  ✅ SAPLING DUP  ✅ ТП ТИМЕЙТОВ + АВТО ХИЛ                          ║
-- ║  🆕 «Название me» в чат → все предметы ТП к написавшему             ║
-- ║  🔥 СЖОГ КУЛЬТИСТОВ → ТП культистов в костёр                        ║
-- ║  🔧 FIX: Brutal Cultist + Juggernaut Cultist теперь тепаются        ║
-- ║  💾 AUTO-SAVE: Автоматическое сохранение и загрузка настроек        ║
-- ╚═════════════════════════════════════════════════════════════════════╝

local Players           = game:GetService("Players")
local TweenService      = game:GetService("TweenService")
local UserInputService  = game:GetService("UserInputService")
local RunService        = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui           = game:GetService("CoreGui")
local Workspace         = game:GetService("Workspace")
local Lighting          = game:GetService("Lighting")
local ContentProvider   = game:GetService("ContentProvider")
local HttpService       = game:GetService("HttpService")

local Player    = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")
local Mouse     = Player:GetMouse()

-- ══ СИСТЕМА СОХРАНЕНИЯ НАСТРОЕК (CONFIG AUTO-SAVE) ══════════════
local CONFIG_FILE = "99Nights_Config.json"
local SavedSettings = {}
local autoRestoreList = {}

local function LoadSettings()
    pcall(function()
        if isfile and readfile and isfile(CONFIG_FILE) then
            local decoded = HttpService:JSONDecode(readfile(CONFIG_FILE))
            if type(decoded) == "table" then
                SavedSettings = decoded
            end
        end
    end)
end

local function SaveSettings()
    pcall(function()
        if writefile then
            writefile(CONFIG_FILE, HttpService:JSONEncode(SavedSettings))
        end
    end)
end

LoadSettings()

-- ══ УТИЛИТЫ ═════════════════════════════════════════════════════
local function New(cls, props, parent)
    local o = Instance.new(cls)
    for k, v in pairs(props) do o[k] = v end
    if parent then o.Parent = parent end
    return o
end

local function Tw(o, p, d, st, dir)
    st  = st  or Enum.EasingStyle.Quart
    dir = dir or Enum.EasingDirection.Out
    local t = TweenService:Create(o, TweenInfo.new(d, st, dir), p)
    t:Play()
    return t
end

local function Clamp(v, mn, mx) return math.max(mn, math.min(mx, v)) end
local function GetHum()  local c = Player.Character; return c and c:FindFirstChildOfClass("Humanoid") end
local function getChar() return Player.Character end
local function getHRP()  local c = getChar(); return c and c:FindFirstChild("HumanoidRootPart") end

-- ══ ЦВЕТА ═════════════════════════════════════════════════════════
local C = {
    BG      = Color3.fromRGB(6,4,10),
    PANEL   = Color3.fromRGB(14,9,22),
    PANEL2  = Color3.fromRGB(20,14,32),
    HEADER  = Color3.fromRGB(10,6,16),
    ACCENT  = Color3.fromRGB(120,60,200),
    NEON_R  = Color3.fromRGB(160,80,255),
    NEON_P  = Color3.fromRGB(180,60,255),
    NEON_B  = Color3.fromRGB(100,120,255),
    NEON_G  = Color3.fromRGB(0,210,90),
    NEON_GD = Color3.fromRGB(255,200,40),
    NEON_O  = Color3.fromRGB(249,115,22),
    NEON_Y  = Color3.fromRGB(255,210,0),
    NEON_SL = Color3.fromRGB(148,163,184),
    NEON_MOS= Color3.fromRGB(34,197,94),
    NEON_VOL= Color3.fromRGB(249,115,22),
    NEON_HC = Color3.fromRGB(168,85,247),
    NEON_COR= Color3.fromRGB(244,63,94),
    NEON_AQ = Color3.fromRGB(0,220,200),
    NEON_TM = Color3.fromRGB(50,220,255),
    NEON_FIRE=Color3.fromRGB(255,100,30),
    WHITE   = Color3.fromRGB(230,220,245),
    GRAY    = Color3.fromRGB(100,90,120),
    DGRAY   = Color3.fromRGB(50,36,72),
    BLACK   = Color3.fromRGB(0,0,0),
}

-- ══ СОСТОЯНИЕ ═════════════════════════════════════════════════════
local GuiOpen    = false
local ActiveTab  = "MAIN"
local WinW, WinH = 500, 580
local HEADER_H   = 44
local TAB_H      = 42
local dragging   = false
local dragOffX, dragOffY, dragType = 0, 0, nil
local TabScrolls, TabBtns = {}, {}
local WinFrame, ToggleGui, SwitchTab, UpdateTabLine

local TABS = {
    {id="MAIN",  label="MAIN",     color=C.NEON_R,  icon="🌙"},
    {id="FARM",  label="АВТОФАРМ", color=C.NEON_GD, icon="⚙️"},
    {id="DUP",   label="ДЮПЕР",    color=C.NEON_AQ, icon="🌱"},
    {id="TEAM",  label="ТИМЕЙТЫ",  color=C.NEON_TM, icon="👥"},
}

-- ══ SCREENGUI ═════════════════════════════════════════════════════
local ScreenGui = New("ScreenGui", {
    Name            = "NNF_HardMode_xdar4k",
    ResetOnSpawn    = false,
    IgnoreGuiInset  = true,
    DisplayOrder    = 999,
}, PlayerGui)

-- ══ УВЕДОМЛЕНИЕ ═════════════════════════════════════════════════════
local note = Instance.new("ScreenGui")
note.ResetOnSpawn = false
note.Parent = CoreGui
local nf = Instance.new("Frame", note)
nf.Size             = UDim2.new(0,440,0,46)
nf.Position         = UDim2.new(0.5,-220,0,12)
nf.BackgroundColor3 = Color3.fromRGB(6,4,10)
nf.BorderSizePixel  = 0
Instance.new("UICorner", nf).CornerRadius = UDim.new(0,10)
local nst = Instance.new("UIStroke", nf)
nst.Color = Color3.fromRGB(120,60,200); nst.Thickness = 1.5
local nl = Instance.new("TextLabel", nf)
nl.Size = UDim2.new(1,0,1,0); nl.BackgroundTransparency = 1
nl.Text = "🌙 99 Nights Hard v2.5 | xdar4k | 🔥 Cultist Fix — Brutal+Juggernaut"
nl.TextColor3 = Color3.fromRGB(160,80,255)
nl.TextSize = 11; nl.Font = Enum.Font.GothamBold
task.delay(3.5, function()
    local ti = TweenInfo.new(0.55, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
    TweenService:Create(nf,  ti, {BackgroundTransparency=1}):Play()
    TweenService:Create(nst, ti, {Transparency=1}):Play()
    TweenService:Create(nl,  ti, {TextTransparency=1}):Play()
    task.wait(0.6); note:Destroy()
end)

-- ══ КНОПКА TOGGLE ═════════════════════════════════════════════════════
local ToggleFrame = New("Frame", {
    Size = UDim2.new(0,58,0,58), Position = UDim2.new(0,16,0,16),
    BackgroundColor3 = C.BG, BorderSizePixel = 0, ZIndex = 500, Active = true,
}, ScreenGui)
New("UICorner",  {CornerRadius=UDim.new(0,14)},  ToggleFrame)
New("UIStroke",  {Color=C.NEON_R, Thickness=2.5}, ToggleFrame)
New("ImageLabel",{
    Size=UDim2.new(0,34,0,34), Position=UDim2.new(0.5,-17,0.5,-17),
    BackgroundTransparency=1, Image="rbxassetid://6570798175",
    ImageColor3=C.NEON_R, ZIndex=502,
}, ToggleFrame)
local TDot = New("Frame", {
    Size=UDim2.new(0,11,0,11), Position=UDim2.new(1,-4,0,-4),
    BackgroundColor3=C.NEON_R, BorderSizePixel=0, ZIndex=504,
}, ToggleFrame)
New("UICorner", {CornerRadius=UDim.new(1,0)}, TDot)
local ToggleHit = New("TextButton", {
    Size=UDim2.new(1,0,1,0), BackgroundTransparency=1,
    Text="", AutoButtonColor=false, ZIndex=503,
}, ToggleFrame)

local tbDrag, tbMoved, tbDragType = false, false, nil
local tbOffX, tbOffY = 0, 0
ToggleHit.InputBegan:Connect(function(inp)
    if inp.UserInputType ~= Enum.UserInputType.MouseButton1
    and inp.UserInputType ~= Enum.UserInputType.Touch then return end
    tbDrag=true; tbMoved=false; tbDragType=inp.UserInputType
    tbOffX=inp.Position.X-ToggleFrame.AbsolutePosition.X
    tbOffY=inp.Position.Y-ToggleFrame.AbsolutePosition.Y
end)
UserInputService.InputChanged:Connect(function(inp)
    if not tbDrag then return end
    if inp.UserInputType ~= Enum.UserInputType.MouseMovement
    and inp.UserInputType ~= Enum.UserInputType.Touch then return end
    tbMoved=true
    local vp = ScreenGui.AbsoluteSize
    ToggleFrame.Position = UDim2.new(0, Clamp(inp.Position.X-tbOffX,0,vp.X-58), 0, Clamp(inp.Position.Y-tbOffY,0,vp.Y-58))
end)
UserInputService.InputEnded:Connect(function(inp)
    if tbDrag and inp.UserInputType==tbDragType then
        tbDrag=false
        if not tbMoved then ToggleGui() end
    end
end)

-- ══ ОКНО ══════════════════════════════════════════════════════════════════
WinFrame = New("Frame", {
    Name="WinFrame", Size=UDim2.new(0,WinW,0,WinH),
    Position=UDim2.new(0,0,0,0), BackgroundColor3=C.BG,
    BorderSizePixel=0, ClipsDescendants=true,
    ZIndex=200, Visible=false, Active=true, BackgroundTransparency=1,
}, ScreenGui)
New("UICorner", {CornerRadius=UDim.new(0,16)}, WinFrame)
New("UIStroke",  {Color=C.ACCENT, Thickness=2}, WinFrame)

local Header = New("Frame", {
    Size=UDim2.new(1,0,0,HEADER_H), BackgroundColor3=C.HEADER,
    BorderSizePixel=0, ZIndex=210, Active=true,
}, WinFrame)
New("UICorner", {CornerRadius=UDim.new(0,16)}, Header)
New("TextLabel", {
    Size=UDim2.new(1,-120,1,0), Position=UDim2.new(0,40,0,0),
    BackgroundTransparency=1,
    Text="🌙 99 Nights | Hard Mode | by xdar4k",
    TextColor3=C.WHITE, Font=Enum.Font.GothamBold, TextSize=13,
    TextXAlignment=Enum.TextXAlignment.Left, ZIndex=212,
}, Header)
local RecDot = New("Frame", {
    Size=UDim2.new(0,8,0,8), Position=UDim2.new(0,14,0.5,-4),
    BackgroundColor3=C.NEON_R, BorderSizePixel=0, ZIndex=213,
}, Header)
New("UICorner", {CornerRadius=UDim.new(1,0)}, RecDot)
New("TextLabel", {
    Size=UDim2.new(0,70,0,22), Position=UDim2.new(1,-108,0.5,-11),
    BackgroundColor3=Color3.fromRGB(20,12,34), BorderSizePixel=0,
    Text="RightShift", TextColor3=C.GRAY, Font=Enum.Font.Code,
    TextSize=10, TextXAlignment=Enum.TextXAlignment.Center, ZIndex=213,
}, Header)
local MinBtn = New("TextButton", {
    Size=UDim2.new(0,30,0,30), Position=UDim2.new(1,-72,0.5,-15),
    BackgroundColor3=Color3.fromRGB(60,30,100), BorderSizePixel=0,
    Text="–", TextColor3=C.WHITE, Font=Enum.Font.GothamBold, TextSize=16,
    AutoButtonColor=false, ZIndex=215,
}, Header)
New("UICorner", {CornerRadius=UDim.new(0,8)}, MinBtn)
local CloseBtn = New("TextButton", {
    Size=UDim2.new(0,30,0,30), Position=UDim2.new(1,-36,0.5,-15),
    BackgroundColor3=Color3.fromRGB(100,30,160), BorderSizePixel=0,
    Text="✕", TextColor3=C.WHITE, Font=Enum.Font.GothamBold, TextSize=14,
    AutoButtonColor=false, ZIndex=215,
}, Header)
New("UICorner", {CornerRadius=UDim.new(0,8)}, CloseBtn)
CloseBtn.Activated:Connect(function() ToggleGui() end)

local minimized = false
local ContentHolder = New("Frame", {
    Name="ContentHolder", Size=UDim2.new(1,0,1,-HEADER_H),
    Position=UDim2.new(0,0,0,HEADER_H), BackgroundTransparency=1,
    BorderSizePixel=0, ZIndex=201, ClipsDescendants=true,
}, WinFrame)

MinBtn.Activated:Connect(function()
    minimized = not minimized
    ContentHolder.Visible = not minimized
    if minimized then
        Tw(WinFrame,{Size=UDim2.new(0,WinW,0,HEADER_H)},0.22,Enum.EasingStyle.Back,Enum.EasingDirection.In)
    else
        Tw(WinFrame,{Size=UDim2.new(0,WinW,0,WinH)},0.28,Enum.EasingStyle.Back,Enum.EasingDirection.Out)
    end
end)

Header.InputBegan:Connect(function(inp)
    if inp.UserInputType ~= Enum.UserInputType.MouseButton1
    and inp.UserInputType ~= Enum.UserInputType.Touch then return end
    dragging=true; dragType=inp.UserInputType
    dragOffX=inp.Position.X-WinFrame.AbsolutePosition.X
    dragOffY=inp.Position.Y-WinFrame.AbsolutePosition.Y
end)
UserInputService.InputChanged:Connect(function(inp)
    if not dragging then return end
    if inp.UserInputType ~= Enum.UserInputType.MouseMovement
    and inp.UserInputType ~= Enum.UserInputType.Touch then return end
    local vp = ScreenGui.AbsoluteSize
    WinFrame.Position = UDim2.new(0, Clamp(inp.Position.X-dragOffX,0,vp.X-WinW), 0, Clamp(inp.Position.Y-dragOffY,0,vp.Y-WinH))
end)
UserInputService.InputEnded:Connect(function(inp)
    if dragging and inp.UserInputType==dragType then dragging=false end
end)

-- ══ TAB BAR ═════════════════════════════════════════════════════════
local TabBar = New("Frame", {
    Size=UDim2.new(1,0,0,TAB_H), Position=UDim2.new(0,0,0,0),
    BackgroundColor3=C.PANEL, BorderSizePixel=0, ZIndex=220,
}, ContentHolder)

local TabLine = New("Frame", {
    Size=UDim2.new(1/#TABS,-6,0,3), Position=UDim2.new(0,3,1,-3),
    BackgroundColor3=C.NEON_R, BorderSizePixel=0, ZIndex=224,
}, TabBar)
New("UICorner", {CornerRadius=UDim.new(1,0)}, TabLine)

UpdateTabLine = function()
    for i, t in ipairs(TABS) do
        if t.id == ActiveTab then
            local f = 1/#TABS
            Tw(TabLine,{
                Position=UDim2.new((i-1)*f,3,1,-3),
                Size=UDim2.new(f,-6,0,3),
                BackgroundColor3=t.color,
            },0.28)
            break
        end
    end
end

for i, tab in ipairs(TABS) do
    local f = 1/#TABS
    local tb = New("TextButton",{
        Size=UDim2.new(f,0,1,0), Position=UDim2.new((i-1)*f,0,0,0),
        BackgroundTransparency=1,
        Text=tab.icon.." "..tab.label,
        TextColor3=i==1 and tab.color or C.GRAY,
        Font=Enum.Font.GothamBold, TextSize=10,
        AutoButtonColor=false, ZIndex=223,
    }, TabBar)
    local id = tab.id
    tb.Activated:Connect(function() SwitchTab(id) end)
    TabBtns[tab.id] = tb
end

local ContentArea = New("Frame",{
    Size=UDim2.new(1,0,1,-TAB_H), Position=UDim2.new(0,0,0,TAB_H),
    BackgroundTransparency=1, BorderSizePixel=0, ZIndex=205, ClipsDescendants=true,
}, ContentHolder)

-- ══ SCROLL FACTORY ════════════════════════════════════════════════════════
local function MakeScroll(tabId, color, vis)
    local sc = New("ScrollingFrame",{
        Name="Scroll_"..tabId, Size=UDim2.new(1,0,1,0),
        BackgroundTransparency=1, BorderSizePixel=0,
        ScrollBarThickness=5, ScrollBarImageColor3=color,
        CanvasSize=UDim2.new(0,0,0,0),
        AutomaticCanvasSize=Enum.AutomaticSize.Y,
        ZIndex=206, Visible=vis,
    }, ContentArea)
    New("UIListLayout",{
        SortOrder=Enum.SortOrder.LayoutOrder, Padding=UDim.new(0,6),
        FillDirection=Enum.FillDirection.Vertical,
        HorizontalAlignment=Enum.HorizontalAlignment.Center,
    }, sc)
    New("UIPadding",{
        PaddingTop=UDim.new(0,8), PaddingLeft=UDim.new(0,8),
        PaddingRight=UDim.new(0,8), PaddingBottom=UDim.new(0,8),
    }, sc)
    TabScrolls[tabId] = sc
    return sc
end

local scMain = MakeScroll("MAIN", C.NEON_R,  true)
local scFarm = MakeScroll("FARM", C.NEON_GD, false)
local scDup  = MakeScroll("DUP",  C.NEON_AQ, false)
local scTeam = MakeScroll("TEAM", C.NEON_TM, false)

-- ══ ВИДЖЕТЫ ═════════════════════════════════════════════════════════
local function MakeDivider(p, txt, ord)
    local d = New("Frame",{
        Size=UDim2.new(1,0,0,22), BackgroundTransparency=1, ZIndex=207, LayoutOrder=ord,
    }, p)
    New("TextLabel",{
        Size=UDim2.new(1,0,1,0), BackgroundTransparency=1,
        Text="── "..txt.." ──", TextColor3=C.GRAY,
        Font=Enum.Font.GothamBold, TextSize=11,
        TextXAlignment=Enum.TextXAlignment.Center, ZIndex=208,
    }, d)
    return d
end

local function MakeToggle(p, txt, color, ord, callback)
    local row = New("Frame",{
        Size=UDim2.new(1,0,0,44), BackgroundColor3=C.PANEL2,
        BorderSizePixel=0, ZIndex=207, LayoutOrder=ord,
    }, p)
    New("UICorner",{CornerRadius=UDim.new(0,10)}, row)
    New("TextLabel",{
        Size=UDim2.new(1,-68,1,0), Position=UDim2.new(0,12,0,0),
        BackgroundTransparency=1, Text=txt, TextColor3=color,
        Font=Enum.Font.GothamBold, TextSize=13,
        TextXAlignment=Enum.TextXAlignment.Left, ZIndex=208,
    }, row)
    local track = New("Frame",{
        Size=UDim2.new(0,44,0,22), Position=UDim2.new(1,-54,0.5,-11),
        BackgroundColor3=Color3.fromRGB(40,28,55), BorderSizePixel=0, ZIndex=208,
    }, row)
    New("UICorner",{CornerRadius=UDim.new(1,0)}, track)
    local thumb = New("Frame",{
        Size=UDim2.new(0,16,0,16), Position=UDim2.new(0,3,0.5,-8),
        BackgroundColor3=C.GRAY, BorderSizePixel=0, ZIndex=209,
    }, track)
    New("UICorner",{CornerRadius=UDim.new(1,0)}, thumb)
    local state = false
    local hit = New("TextButton",{
        Size=UDim2.new(1,0,1,0), BackgroundTransparency=1,
        Text="", AutoButtonColor=false, ZIndex=210,
    }, row)
    local function setState(s)
        state = s
        if state then
            Tw(thumb,{Position=UDim2.new(0,25,0.5,-8), BackgroundColor3=color},0.18)
            Tw(track,{BackgroundColor3=Color3.fromRGB(30,20,50)},0.18)
        else
            Tw(thumb,{Position=UDim2.new(0,3,0.5,-8), BackgroundColor3=C.GRAY},0.18)
            Tw(track,{BackgroundColor3=Color3.fromRGB(40,28,55)},0.18)
        end
        SavedSettings[txt] = state
        SaveSettings()
        if callback then callback(state) end
    end
    hit.Activated:Connect(function() setState(not state) end)

    table.insert(autoRestoreList, function()
        if SavedSettings[txt] == true then
            setState(true)
        end
    end)

    return row, function() return state end, function(s) setState(s) end
end

local function MakeBtn(p, txt, color, ord, callback)
    local btn = New("TextButton",{
        Size=UDim2.new(1,0,0,44), BackgroundColor3=C.PANEL,
        BorderSizePixel=0, Text=txt, TextColor3=color,
        Font=Enum.Font.GothamBold, TextSize=14,
        AutoButtonColor=false, ZIndex=207, LayoutOrder=ord,
    }, p)
    New("UICorner",{CornerRadius=UDim.new(0,10)}, btn)
    New("UIStroke",{Color=color, Thickness=1.5, Transparency=0.4}, btn)
    btn.MouseEnter:Connect(function() Tw(btn,{BackgroundColor3=color},0.15); btn.TextColor3=C.BLACK end)
    btn.MouseLeave:Connect(function() Tw(btn,{BackgroundColor3=C.PANEL},0.15); btn.TextColor3=color end)
    if callback then btn.Activated:Connect(callback) end
    return btn
end

local function MakeSlider(p, txt, color, minV, maxV, defV, ord, callback, displayFn)
    local row = New("Frame",{
        Size=UDim2.new(1,0,0,54), BackgroundColor3=C.PANEL2,
        BorderSizePixel=0, ZIndex=207, LayoutOrder=ord,
    }, p)
    New("UICorner",{CornerRadius=UDim.new(0,10)}, row)
    New("TextLabel",{
        Size=UDim2.new(1,-80,0,24), Position=UDim2.new(0,12,0,4),
        BackgroundTransparency=1, Text=txt, TextColor3=color,
        Font=Enum.Font.GothamBold, TextSize=12,
        TextXAlignment=Enum.TextXAlignment.Left, ZIndex=208,
    }, row)
    local valLbl = New("TextLabel",{
        Size=UDim2.new(0,70,0,24), Position=UDim2.new(1,-78,0,4),
        BackgroundTransparency=1,
        Text=displayFn and displayFn(defV) or tostring(defV),
        TextColor3=color,
        Font=Enum.Font.GothamBold, TextSize=12,
        TextXAlignment=Enum.TextXAlignment.Right, ZIndex=208,
    }, row)
    local track = New("Frame",{
        Size=UDim2.new(1,-24,0,6), Position=UDim2.new(0,12,0,36),
        BackgroundColor3=Color3.fromRGB(40,30,70), BorderSizePixel=0, ZIndex=208,
    }, row)
    New("UICorner",{CornerRadius=UDim.new(0,3)}, track)
    local pct = (defV-minV)/(maxV-minV)
    local fill = New("Frame",{
        Size=UDim2.new(pct,0,1,0), BackgroundColor3=color, BorderSizePixel=0, ZIndex=209,
    }, track)
    New("UICorner",{CornerRadius=UDim.new(0,3)}, fill)
    local handle = New("TextButton",{
        Size=UDim2.new(0,14,0,14), Position=UDim2.new(pct,-7,0.5,-7),
        BackgroundColor3=color, Text="", BorderSizePixel=0, ZIndex=210,
        AutoButtonColor=false,
    }, track)
    New("UICorner",{CornerRadius=UDim.new(1,0)}, handle)
    local sd = false
    handle.MouseButton1Down:Connect(function() sd = true end)
    track.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then sd = true end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then sd = false end
    end)
    UserInputService.InputChanged:Connect(function(inp)
        if not sd then return end
        if inp.UserInputType ~= Enum.UserInputType.MouseMovement then return end
        local tw = track.AbsoluteSize.X
        if tw <= 0 then return end
        local p2 = math.clamp((inp.Position.X - track.AbsolutePosition.X) / tw, 0, 1)
        local val = math.floor(minV + p2*(maxV-minV))
        fill.Size = UDim2.new(p2,0,1,0)
        handle.Position = UDim2.new(p2,-7,0.5,-7)
        valLbl.Text = displayFn and displayFn(val) or tostring(val)
        if callback then callback(val) end
    end)
    track.InputBegan:Connect(function(inp)
        if inp.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
        local tw = track.AbsoluteSize.X
        if tw <= 0 then return end
        local p2 = math.clamp((inp.Position.X - track.AbsolutePosition.X) / tw, 0, 1)
        local val = math.floor(minV + p2*(maxV-minV))
        fill.Size = UDim2.new(p2,0,1,0)
        handle.Position = UDim2.new(p2,-7,0.5,-7)
        valLbl.Text = displayFn and displayFn(val) or tostring(val)
        if callback then callback(val) end
    end)
    return row
end

-- ══ REMOTES / FOLDERS ═════════════════════════════════════════════════════
local remoteEvents, itemsFolder
pcall(function() remoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents",5) end)
pcall(function() itemsFolder  = Workspace:WaitForChild("Items",5) end)

-- ══════════════════════════════════════════════════════════════════════
--  🛡️  GOD MODE
-- ══════════════════════════════════════════════════════════════════════
local godModeActive = false
local godModeConn   = nil

local function getDmgRemote()
    local re = ReplicatedStorage:FindFirstChild("RemoteEvents")
    if re then return re:FindFirstChild("DamagePlayer") end
    return nil
end

local function startGodMode()
    if godModeConn then godModeConn:Disconnect(); godModeConn = nil end
    pcall(function()
        local dmg = getDmgRemote()
        if dmg then dmg:FireServer(-math.huge) end
    end)
    godModeConn = task.spawn(function()
        while godModeActive do
            pcall(function()
                local dmg = getDmgRemote()
                if dmg then dmg:FireServer(-math.huge) end
            end)
            task.wait(2)
        end
    end)
end

local function stopGodMode()
    godModeActive = false
    if godModeConn then
        pcall(function() task.cancel(godModeConn) end)
        godModeConn = nil
    end
end

Player.CharacterAdded:Connect(function()
    if godModeActive then task.wait(0.5); startGodMode() end
end)

-- ══════════════════════════════════════════════════════════════════════
--  🔥  СЖОГ КУЛЬТИСТОВ — ПОЛНЫЙ ФИКС
--  Ищем по всему workspace:GetDescendants() — находит ВСЕХ культистов
--  включая Brutal Cultist и Juggernaut Cultist в любых папках
-- ══════════════════════════════════════════════════════════════════════
local cultistBurnEnabled = false
local cultistBurnTask    = nil
local cultistStatusLbl   = nil

local CULTIST_TARGET_POS = CFrame.new(-0.06, 9.98, -0.77)

-- Таблица имён культистов для быстрого поиска
local CULTIST_NAMES = {
    ["Cultist"]            = true,
    ["Crossbow Cultist"]   = true,
    ["Brutal Cultist"]     = true,
    ["Juggernaut Cultist"] = true,
}

-- ╔══════════════════════════════════════════════════════════════╗
-- ║  ГЛАВНЫЙ ФИКС: ищем GetDescendants всего workspace,         ║
-- ║  телепортируем напрямую через CFrame всех BasePart            ║
-- ║  (так же как ТП тимейтов — это работает для NPC-моделей)     ║
-- ╚══════════════════════════════════════════════════════════════╝
local function runCultistBurnLoop()
    cultistBurnTask = task.spawn(function()
        while cultistBurnEnabled do
            -- Ищем по ВСЕМУ workspace рекурсивно (GetDescendants)
            -- Это находит культистов в любой папке: Enemies, Map, или напрямую
            for _, obj in ipairs(workspace:GetDescendants()) do
                if not cultistBurnEnabled then break end
                if obj:IsA("Model") and CULTIST_NAMES[obj.Name] then
                    -- Пробуем RequestStartDraggingItem (работает для некоторых)
                    pcall(function()
                        ReplicatedStorage.RemoteEvents.RequestStartDraggingItem:FireServer(obj)
                    end)
                    -- Телепортируем через PrimaryPart если есть
                    if obj.PrimaryPart then
                        pcall(function()
                            obj:SetPrimaryPartCFrame(CULTIST_TARGET_POS)
                        end)
                    end
                    -- Телепортируем ВСЕ BasePart напрямую (работает для Brutal/Juggernaut)
                    for _, part in ipairs(obj:GetDescendants()) do
                        if part:IsA("BasePart") then
                            pcall(function()
                                part.CFrame = CULTIST_TARGET_POS
                            end)
                        end
                    end
                    -- Также проверяем сам obj если это BasePart
                    if obj:IsA("BasePart") then
                        pcall(function()
                            obj.CFrame = CULTIST_TARGET_POS
                        end)
                    end
                    task.wait(0.05)
                    pcall(function()
                        ReplicatedStorage.RemoteEvents.StopDraggingItem:FireServer(obj)
                    end)
                end
            end
            task.wait(0.05)
        end
    end)
end

local function stopCultistBurn()
    cultistBurnEnabled = false
    if cultistStatusLbl then
        cultistStatusLbl.Text = "⛔ Сжог выключен"
        cultistStatusLbl.TextColor3 = Color3.fromRGB(180,80,80)
    end
end

-- ══════════════════════════════════════════════════════════════════════
--  MAIN TAB
-- ══════════════════════════════════════════════════════════════════════
MakeDivider(scMain, "ДВИЖЕНИЕ", 1)

local hackedWS  = 16
local speedConn = nil
local function startSpeedLoop(ws)
    if speedConn then speedConn:Disconnect(); speedConn=nil end
    if ws == 16 then return end
    speedConn = RunService.Heartbeat:Connect(function()
        local hum = GetHum()
        if hum and hum.WalkSpeed ~= ws then hum.WalkSpeed = ws end
    end)
end
Player.CharacterAdded:Connect(function() startSpeedLoop(hackedWS) end)

MakeToggle(scMain,"🏃  СПИД ХАК",C.NEON_B,2,function(on)
    hackedWS = on and 50 or 16
    local hum = GetHum(); if hum then hum.WalkSpeed = hackedWS end
    startSpeedLoop(hackedWS)
end)
MakeSlider(scMain,"Скорость",C.NEON_B,16,300,50,3,function(val)
    hackedWS = val
    local hum = GetHum(); if hum then hum.WalkSpeed = val end
    startSpeedLoop(val)
end)

MakeDivider(scMain,"🛡️ БЕССМЕРТИЕ",4)
MakeToggle(scMain,"🛡️  GOD MODE  (DamagePlayer -∞)",C.NEON_G,5,function(on)
    godModeActive = on
    if on then startGodMode() else stopGodMode() end
end)
do
    local fr = New("Frame",{Size=UDim2.new(1,0,0,22),BackgroundTransparency=1,ZIndex=207,LayoutOrder=6},scMain)
    New("TextLabel",{
        Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,
        Text="FireServer(DamagePlayer, -∞) → бесконечное HP  |  авто-рефреш 2с",
        TextColor3=C.NEON_G,Font=Enum.Font.Gotham,TextSize=10,
        TextXAlignment=Enum.TextXAlignment.Center,ZIndex=208,
    },fr)
end

MakeDivider(scMain,"ТЕЛЕПОРТЫ",7)
MakeBtn(scMain,"🏕️  ТП: Camp Site",  C.NEON_B, 8,function()
    local hrp=getHRP(); if hrp then hrp.CFrame=CFrame.new(0,8,0) end
end)
MakeBtn(scMain,"🛡️  ТП: Safe Zone",  C.NEON_G, 9,function()
    local hrp=getHRP(); if hrp then hrp.CFrame=CFrame.new(0,110,0) end
end)
MakeBtn(scMain,"🏰  ТП: Stronghold", C.NEON_GD,10,function()
    local hrp=getHRP(); if not hrp then return end
    local ok,tgt=pcall(function()
        return Workspace.Map.Landmarks.Stronghold.Functional.EntryDoors.DoorRight.Model
    end)
    if ok and tgt then
        local c2=tgt:GetChildren()[5]
        if c2 and c2:IsA("BasePart") then hrp.CFrame=c2.CFrame+Vector3.new(0,5,0) end
    end
end)

-- ══ СЖОГ КУЛЬТИСТОВ (встроено в MAIN) ════════════════════════════════
MakeDivider(scMain,"🔥 СЖОГ КУЛЬТИСТОВ",11)
MakeToggle(scMain,"🔥  Сжог Культистов (ТП в костёр)",C.NEON_FIRE,12,function(on)
    cultistBurnEnabled = on
    if on then
        runCultistBurnLoop()
        if cultistStatusLbl then
            cultistStatusLbl.Text = "🔥 Сжигаю: Cultist + Crossbow + Brutal + Juggernaut"
            cultistStatusLbl.TextColor3 = C.NEON_FIRE
        end
    else
        stopCultistBurn()
    end
end)
do
    local sf = New("Frame",{Size=UDim2.new(1,0,0,34),BackgroundColor3=Color3.fromRGB(26,8,0),BorderSizePixel=0,ZIndex=207,LayoutOrder=13},scMain)
    New("UICorner",{CornerRadius=UDim.new(0,10)},sf)
    New("UIStroke",{Color=C.NEON_FIRE,Thickness=1,Transparency=0.7},sf)
    cultistStatusLbl = New("TextLabel",{
        Size=UDim2.new(1,-16,1,0),Position=UDim2.new(0,8,0,0),BackgroundTransparency=1,
        Text="⛔ Сжог выключен",TextColor3=Color3.fromRGB(180,80,80),
        Font=Enum.Font.GothamBold,TextSize=11,TextXAlignment=Enum.TextXAlignment.Center,ZIndex=208,
    },sf)
end
do
    local hintFr=New("Frame",{Size=UDim2.new(1,0,0,46),BackgroundColor3=Color3.fromRGB(22,8,0),BorderSizePixel=0,ZIndex=207,LayoutOrder=14},scMain)
    New("UICorner",{CornerRadius=UDim.new(0,10)},hintFr)
    New("UIStroke",{Color=C.NEON_FIRE,Thickness=1,Transparency=0.75},hintFr)
    New("TextLabel",{
        Size=UDim2.new(1,-16,1,0),Position=UDim2.new(0,8,0,0),BackgroundTransparency=1,
        Text="🔧 FIX: GetDescendants по всему workspace\nCultist + Crossbow + Brutal + Juggernaut → костёр (-0.06, 9.98, -0.77)",
        TextColor3=Color3.fromRGB(255,150,80),Font=Enum.Font.Gotham,TextSize=10,
        TextXAlignment=Enum.TextXAlignment.Center,ZIndex=208,TextWrapped=true,
    },hintFr)
end

-- ══ CHEST ESP ═══════════════════════════════════════════════════════════════════
MakeDivider(scMain,"CHEST ESP",15)

local espEnabled     = false
local espByType      = {}
local autoOpenActive = false
local autoOpenBusy   = false

local CHEST_TYPES = {
    "Item Chest","StoneChest","Mossy Chest",
    "Volcanic Chest","Hardmode Crate","Corrupted Chest",
}
local CHEST_COLORS = {
    ["Item Chest"]      = C.NEON_B,
    ["StoneChest"]      = C.NEON_SL,
    ["Mossy Chest"]     = C.NEON_MOS,
    ["Volcanic Chest"]  = C.NEON_VOL,
    ["Hardmode Crate"]  = C.NEON_HC,
    ["Corrupted Chest"] = C.NEON_COR,
}
local OPEN_TOKENS = {"open","opened","empty","looted","claimed","used"}
local OPEN_KEYS   = {"Opened","IsOpened","Open","Looted","Claimed","Empty","Collected","Used"}
for _,t in ipairs(CHEST_TYPES) do espByType[t]=true end

local tracked = {}
local function isChestName(name)
    for _,ct in ipairs(CHEST_TYPES) do
        if name:find(ct,1,true) then return true,ct end
    end
    return false,nil
end
local function nameSuggestsOpened(name)
    local low=name:lower()
    for _,t in ipairs(OPEN_TOKENS) do if low:find(t,1,true) then return true end end
    return false
end
local function findAdornee(model)
    return model:FindFirstChild("HumanoidRootPart") or model:FindFirstChildWhichIsA("BasePart")
end
local function destroyEsp(model)
    local e=tracked[model]; if not e then return end
    if e.conns then for _,cc in ipairs(e.conns) do pcall(function() cc:Disconnect() end) end end
    if e.hl    and e.hl.Parent    then e.hl:Destroy() end
    if e.label and e.label.Parent then e.label:Destroy() end
    tracked[model]=nil
end
local function refreshAll()
    task.defer(function()
        for model,e in pairs(tracked) do
            if not model or not model.Parent then tracked[model]=nil
            elseif e.isOpen then
                if e.hl and e.hl.Parent then e.hl:Destroy() end
                if e.label and e.label.Parent then e.label:Destroy() end
                tracked[model]=nil
            else
                local vis=espEnabled and (espByType[e.chestType]==true)
                if e.hl then e.hl.Enabled=vis end
                if e.label then e.label.Enabled=vis end
            end
        end
    end)
end
local function applyEsp(model,chestType)
    if not model or not model.Parent then return end
    local adornee=findAdornee(model); if not adornee then return end
    local color=CHEST_COLORS[chestType] or Color3.new(1,1,1)
    local lvl=model.Name:match("(%d)")
    local disp=chestType..(lvl and (" [Lv."..lvl.."]" ) or "")
    local hl=Instance.new("Highlight")
    hl.Name="ChestESP_HL"; hl.Adornee=model
    hl.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop
    hl.FillColor=color; hl.OutlineColor=color:Lerp(Color3.new(1,1,1),0.25)
    hl.FillTransparency=0.65; hl.OutlineTransparency=0.05; hl.Parent=model
    local bb=Instance.new("BillboardGui")
    bb.Name="ChestESP_BB"; bb.Adornee=adornee
    bb.Size=UDim2.fromOffset(160,26); bb.StudsOffset=Vector3.new(0,3,0)
    bb.AlwaysOnTop=true; bb.Parent=model
    local tl=Instance.new("TextLabel",bb)
    tl.Size=UDim2.fromScale(1,1); tl.BackgroundTransparency=1
    tl.Font=Enum.Font.GothamBold; tl.TextScaled=true
    tl.TextStrokeTransparency=0.25
    tl.TextColor3=color:Lerp(Color3.new(1,1,1),0.35); tl.Text=disp
    local vis=espEnabled and (espByType[chestType]==true)
    hl.Enabled=vis; bb.Enabled=vis
    tracked[model]={hl=hl,label=bb,chestType=chestType,conns={},isOpen=false}
end
local function watchChest(model)
    local e=tracked[model]; if not e or e.watchReady then return end
    e.watchReady=true
    local function addC(cc) table.insert(e.conns,cc) end
    local function markOpen()
        local ee=tracked[model]; if not ee then return end
        ee.isOpen=true; destroyEsp(model)
    end
    addC(model:GetPropertyChangedSignal("Name"):Connect(function()
        if nameSuggestsOpened(model.Name) then markOpen() end
    end))
    addC(model.AncestryChanged:Connect(function(_,p)
        if p==nil then destroyEsp(model) end
    end))
    for _,k in ipairs(OPEN_KEYS) do
        pcall(function()
            addC(model:GetAttributeChangedSignal(k):Connect(function()
                local ok2,v=pcall(function() return model:GetAttribute(k) end)
                if ok2 and v==true then markOpen() end
            end))
        end)
    end
    local function bindDesc(obj)
        if obj:IsA("BoolValue") then
            local rel=nameSuggestsOpened(obj.Name)
            if not rel then for _,k in ipairs(OPEN_KEYS) do if obj.Name==k then rel=true;break end end end
            if rel then
                addC(obj:GetPropertyChangedSignal("Value"):Connect(function()
                    if obj.Value==true then markOpen() end
                end))
                if obj.Value==true then markOpen() end
            end
        end
        if obj:IsA("ProximityPrompt") then
            addC(obj:GetPropertyChangedSignal("Enabled"):Connect(function()
                local hasP,allOff=false,true
                for _,o in ipairs(model:GetDescendants()) do
                    if o:IsA("ProximityPrompt") then
                        hasP=true; if o.Enabled then allOff=false;break end
                    end
                end
                if hasP and allOff then markOpen() end
            end))
        end
    end
    for _,obj in ipairs(model:GetDescendants()) do bindDesc(obj) end
    addC(model.DescendantAdded:Connect(function(obj) bindDesc(obj) end))
end

local CHEST_FIRST={I=true,S=true,M=true,V=true,H=true,C=true}
local hasScanned=false
local function scanOnce()
    if hasScanned then return end; hasScanned=true
    for _,obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") and CHEST_FIRST[obj.Name:sub(1,1)] then
            local ok2,ct=isChestName(obj.Name)
            if ok2 and not tracked[obj] then applyEsp(obj,ct);watchChest(obj) end
        end
    end
    Workspace.DescendantAdded:Connect(function(obj)
        if not obj:IsA("Model") or not CHEST_FIRST[obj.Name:sub(1,1)] then return end
        local ok2,ct=isChestName(obj.Name)
        if ok2 and not tracked[obj] then applyEsp(obj,ct);watchChest(obj) end
    end)
end

local openChestRemote,analyticsRemote=nil,nil
local OPEN_REMOTE_NAMES={"RequestOpenItemChest","RequestOpenChest","OpenItemChest","OpenChest"}
local function resolveRemotes()
    if not remoteEvents then remoteEvents=ReplicatedStorage:FindFirstChild("RemoteEvents") end
    if not remoteEvents then return end
    if not analyticsRemote then analyticsRemote=remoteEvents:FindFirstChild("AnalyticsTimeFirstPerson") end
    if not openChestRemote or not openChestRemote.Parent then
        for _,n in ipairs(OPEN_REMOTE_NAMES) do
            local r=remoteEvents:FindFirstChild(n)
            if r and r:IsA("RemoteEvent") then openChestRemote=r;break end
        end
    end
end
local function tryOpenChest(model)
    if not model or not model.Parent then return end
    local e=tracked[model]; if e and e.isOpen then return end
    resolveRemotes()
    local hrp=getHRP(); local part=findAdornee(model)
    if hrp and part then
        if (hrp.Position-part.Position).Magnitude > 6 then
            hrp.CFrame=CFrame.new(part.Position+Vector3.new(0,3,0),part.Position)
            task.wait(0.1)
        end
    end
    if analyticsRemote then pcall(function() analyticsRemote:FireServer(0,60) end) end
    if openChestRemote then
        pcall(function()
            local target=model
            if itemsFolder and model:IsDescendantOf(itemsFolder) then
                local top=model
                while top and top.Parent and top.Parent~=itemsFolder do top=top.Parent end
                if top and top.Parent==itemsFolder then target=top end
            end
            openChestRemote:FireServer(target)
        end)
    end
end
local function getOpenQueue()
    local list={}
    for model,e in pairs(tracked) do
        if model and model.Parent and not e.isOpen and espEnabled and espByType[e.chestType] then
            table.insert(list,model)
        end
    end
    local hrp=getHRP()
    if hrp then
        table.sort(list,function(a,b)
            local pa=findAdornee(a);local pb=findAdornee(b)
            if not pa then return false end;if not pb then return true end
            return (hrp.Position-pa.Position).Magnitude<(hrp.Position-pb.Position).Magnitude
        end)
    end
    return list
end
local function runAutoOpen()
    if autoOpenBusy then return end; autoOpenBusy=true
    task.spawn(function()
        while autoOpenActive do
            local q=getOpenQueue()
            if #q==0 then task.wait(1.5)
            else
                for _,m in ipairs(q) do
                    if not autoOpenActive then break end
                    tryOpenChest(m); task.wait(0.5)
                end
            end
            task.wait(0.4)
        end
        autoOpenBusy=false
    end)
end

MakeToggle(scMain,"👁  ESP Всех Сундуков",   C.NEON_O,16,function(on)
    espEnabled=on; if on then scanOnce() end; refreshAll()
end)
MakeToggle(scMain,"⚡  Авто Открытие Сундуков",C.NEON_Y,17,function(on)
    autoOpenActive=on
    if on then espEnabled=true;scanOnce();refreshAll();runAutoOpen() end
end)

-- ══════════════════════════════════════════════════════════════════════
--  FARM TAB
-- ══════════════════════════════════════════════════════════════════════
local markerCFrame  = nil
local markerPart    = nil
local markerLblRef  = nil

local function placeMarker()
    local hrp=getHRP(); if not hrp then return end
    markerCFrame=hrp.CFrame
    if markerPart and markerPart.Parent then markerPart:Destroy() end
    local p=Instance.new("Part")
    p.Name="BringMarker"; p.Size=Vector3.new(1.5,0.3,1.5)
    p.Shape=Enum.PartType.Cylinder; p.Material=Enum.Material.Neon
    p.Color=Color3.fromRGB(180,60,255); p.Anchored=true; p.CanCollide=false
    p.CFrame=CFrame.new(hrp.Position.X,hrp.Position.Y-2.8,hrp.Position.Z)*CFrame.Angles(0,0,math.pi/2)
    p.Parent=Workspace; markerPart=p
    if markerLblRef then
        local pos=markerCFrame.Position
        markerLblRef.Text="📍 X="..string.format("%.1f",pos.X).."  Y="..string.format("%.1f",pos.Y).."  Z="..string.format("%.1f",pos.Z)
        markerLblRef.TextColor3=Color3.fromRGB(100,255,180)
    end
end

local function teleportItemToMarker(itemName)
    if not markerCFrame then
        if markerLblRef then
            markerLblRef.Text="⚠️ Сначала поставь метку!"
            markerLblRef.TextColor3=Color3.fromRGB(255,120,50)
        end
        return
    end
    if not itemsFolder then itemsFolder=Workspace:FindFirstChild("Items") end
    if not remoteEvents then remoteEvents=ReplicatedStorage:FindFirstChild("RemoteEvents") end
    local count=0
    local sources={}
    if itemsFolder then table.insert(sources,itemsFolder) end
    local tmp=ReplicatedStorage:FindFirstChild("TempStorage")
    if tmp then table.insert(sources,tmp) end
    for _,src in ipairs(sources) do
        for _,item in ipairs(src:GetChildren()) do
            if item.Name==itemName and item:IsA("Model") then
                local part=item.PrimaryPart or item:FindFirstChildWhichIsA("BasePart")
                if part then
                    local targetCF=markerCFrame+Vector3.new(0,count*2.5,0)
                    pcall(function()
                        if remoteEvents then
                            local dr=remoteEvents:FindFirstChild("RequestStartDraggingItem")
                            if dr then dr:FireServer(item) end
                            task.wait(0.05)
                        end
                        if item.PrimaryPart then item:SetPrimaryPartCFrame(targetCF)
                        else part.CFrame=targetCF end
                        task.wait(0.05)
                        if remoteEvents then
                            local sr=remoteEvents:FindFirstChild("StopDraggingItem")
                            if sr then sr:FireServer(item) end
                        end
                    end)
                    count=count+1
                end
            end
        end
    end
    if markerLblRef then
        if count>0 then
            markerLblRef.Text="✅ Притянуто "..count.."x "..itemName
            markerLblRef.TextColor3=Color3.fromRGB(0,220,100)
        else
            markerLblRef.Text="❌ Не найдено: "..itemName
            markerLblRef.TextColor3=Color3.fromRGB(255,80,80)
        end
        task.delay(3,function()
            if markerLblRef then
                markerLblRef.Text="📍 Метка активна"
                markerLblRef.TextColor3=Color3.fromRGB(100,255,180)
            end
        end)
    end
end

local chatTpActive = false
local chatTpConns  = {}
local chatMeTpStatusLbl = nil

local ITEM_SET = {
    ["Alpha Wolf Pelt"]=true,["Anvil Back"]=true,["Anvil Front"]=true,
    ["Apple"]=true,["Bandage"]=true,["Bear Corpse"]=true,["Bear Pelt"]=true,
    ["Berry"]=true,["Biofuel"]=true,["Bolt"]=true,["Broken Fan"]=true,
    ["Broken Microwave"]=true,["Bunny Foot"]=true,["Carrot"]=true,
    ["Chainsaw"]=true,["Coal"]=true,["Coin Stack"]=true,
    ["Cooked Morsel"]=true,["Cooked Steak"]=true,["Cultist Gem"]=true,
    ["Flower"]=true,["Fuel Canister"]=true,
    ["Gem of the Forest Fragment"]=true,["Giant Sack"]=true,
    ["Good Axe"]=true,["Good Sack"]=true,["Hologram Emitter"]=true,
    ["Iron Body"]=true,["Katana"]=true,["Kunai"]=true,
    ["Laser Fence Blueprint"]=true,["Laser Sword"]=true,
    ["Leather Body"]=true,["Log"]=true,["MedKit"]=true,["Morsel"]=true,
    ["Oil Barrel"]=true,["Old Car Engine"]=true,["Old Flashlight"]=true,
    ["Old Radio"]=true,["Raygun"]=true,["Revolver"]=true,
    ["Revolver Ammo"]=true,["Rifle"]=true,["Rifle Ammo"]=true,
    ["Sapling"]=true,["Sheet Metal"]=true,["Spear"]=true,["Steak"]=true,
    ["Strong Axe"]=true,["Thorn Body"]=true,["Tyre"]=true,
    ["UFO Component"]=true,["UFO Junk"]=true,
    ["Washing Machine"]=true,["Wolf Pelt"]=true,
}

local function teleportItemToPlayer(itemName, targetPlayer)
    if not targetPlayer then return 0 end
    local char = targetPlayer.Character
    if not char then return 0 end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return 0 end
    if not itemsFolder then itemsFolder = Workspace:FindFirstChild("Items") end
    if not remoteEvents then remoteEvents = ReplicatedStorage:FindFirstChild("RemoteEvents") end
    local count = 0
    local sources = {}
    if itemsFolder then table.insert(sources, itemsFolder) end
    local tmp = ReplicatedStorage:FindFirstChild("TempStorage")
    if tmp then table.insert(sources, tmp) end
    for _, src in ipairs(sources) do
        for _, item in ipairs(src:GetChildren()) do
            if item.Name == itemName and item:IsA("Model") then
                local part = item.PrimaryPart or item:FindFirstChildWhichIsA("BasePart")
                if part then
                    local targetCF = hrp.CFrame + Vector3.new(0, count * 2.5 + 1, 0)
                    pcall(function()
                        if remoteEvents then
                            local dr = remoteEvents:FindFirstChild("RequestStartDraggingItem")
                            if dr then dr:FireServer(item) end
                            task.wait(0.05)
                        end
                        if item.PrimaryPart then item:SetPrimaryPartCFrame(targetCF)
                        else part.CFrame = targetCF end
                        task.wait(0.05)
                        if remoteEvents then
                            local sr = remoteEvents:FindFirstChild("StopDraggingItem")
                            if sr then sr:FireServer(item) end
                        end
                    end)
                    count = count + 1
                end
            end
        end
    end
    return count
end

local function onChatMessage(msg, senderPlayer)
    if not chatTpActive then return end
    local trimmed = msg:match("^%s*(.-)%s*$")
    if not trimmed or trimmed == "" then return end
    local itemPart, suffix = trimmed:match("^(.-)%s+([Mm][Ee])$")
    if itemPart and suffix then
        if ITEM_SET[itemPart] and senderPlayer then
            task.spawn(function()
                local n = teleportItemToPlayer(itemPart, senderPlayer)
                if chatMeTpStatusLbl then
                    if n > 0 then
                        chatMeTpStatusLbl.Text = "📦→👤 "..n.."x "..itemPart.." → "..senderPlayer.Name
                        chatMeTpStatusLbl.TextColor3 = Color3.fromRGB(0,220,100)
                    else
                        chatMeTpStatusLbl.Text = "❌ Не найдено: "..itemPart
                        chatMeTpStatusLbl.TextColor3 = Color3.fromRGB(255,80,80)
                    end
                    task.delay(4, function()
                        if chatMeTpStatusLbl then
                            chatMeTpStatusLbl.Text = "💬 me-режим активен"
                            chatMeTpStatusLbl.TextColor3 = Color3.fromRGB(100,90,120)
                        end
                    end)
                end
            end)
        end
        return
    end
    if ITEM_SET[trimmed] then teleportItemToMarker(trimmed) end
end

local function startChatTp()
    for _,c in ipairs(chatTpConns) do pcall(function() c:Disconnect() end) end
    chatTpConns={}
    local function bindPlayer(p)
        local ok,conn=pcall(function()
            return p.Chatted:Connect(function(msg) onChatMessage(msg, p) end)
        end)
        if ok and conn then table.insert(chatTpConns,conn) end
    end
    for _,p in ipairs(Players:GetPlayers()) do bindPlayer(p) end
    local paConn=Players.PlayerAdded:Connect(function(p) if chatTpActive then bindPlayer(p) end end)
    table.insert(chatTpConns,paConn)
    pcall(function()
        local tcs=game:GetService("TextChatService")
        if tcs and tcs.MessageReceived then
            local conn=tcs.MessageReceived:Connect(function(msg)
                if not msg or not msg.Text then return end
                local sender = nil
                pcall(function()
                    if msg.TextSource then
                        sender = Players:GetPlayerByUserId(msg.TextSource.UserId)
                    end
                end)
                onChatMessage(msg.Text, sender)
            end)
            table.insert(chatTpConns,conn)
        end
    end)
end

local function stopChatTp()
    for _,c in ipairs(chatTpConns) do pcall(function() c:Disconnect() end) end
    chatTpConns={}
end

MakeDivider(scFarm,"ПРИТЯНУТЬ К МЕТКЕ",1)

local mBtn=New("TextButton",{
    Size=UDim2.new(1,0,0,44), BackgroundColor3=Color3.fromRGB(34,20,62),
    BorderSizePixel=0, Text="📍  Поставить метку (здесь)",
    TextColor3=C.WHITE, Font=Enum.Font.GothamBold, TextSize=13,
    AutoButtonColor=false, ZIndex=207, LayoutOrder=2,
}, scFarm)
New("UICorner",{CornerRadius=UDim.new(0,10)}, mBtn)
New("UIStroke",{Color=C.NEON_P, Thickness=1.5, Transparency=0.35}, mBtn)
mBtn.MouseEnter:Connect(function() Tw(mBtn,{BackgroundColor3=Color3.fromRGB(56,30,100)},0.14) end)
mBtn.MouseLeave:Connect(function() Tw(mBtn,{BackgroundColor3=Color3.fromRGB(34,20,62)},0.14) end)
mBtn.Activated:Connect(placeMarker)

local coordRow=New("Frame",{Size=UDim2.new(1,0,0,26),BackgroundTransparency=1,ZIndex=207,LayoutOrder=3},scFarm)
local coordLbl=New("TextLabel",{
    Size=UDim2.new(1,0,1,0), BackgroundTransparency=1,
    Text="📍 Метка не установлена", TextColor3=C.GRAY,
    Font=Enum.Font.Gotham, TextSize=11,
    TextXAlignment=Enum.TextXAlignment.Center, ZIndex=208,
}, coordRow)
markerLblRef=coordLbl

MakeDivider(scFarm,"💬 ЧАТ → ТП ПРЕДМЕТА",4)
MakeToggle(scFarm,"💬  Чат → ТП предмета к метке / игроку",C.NEON_P,5,function(on)
    chatTpActive=on
    if on then startChatTp() else stopChatTp() end
    if chatMeTpStatusLbl then
        chatMeTpStatusLbl.Text = on and "💬 me-режим активен" or "Выключено"
        chatMeTpStatusLbl.TextColor3 = on and Color3.fromRGB(100,90,120) or Color3.fromRGB(80,70,100)
    end
end)
do
    local fr=New("Frame",{Size=UDim2.new(1,0,0,48),BackgroundColor3=Color3.fromRGB(18,10,36),BorderSizePixel=0,ZIndex=207,LayoutOrder=6},scFarm)
    New("UICorner",{CornerRadius=UDim.new(0,10)},fr)
    New("UIStroke",{Color=C.NEON_P,Thickness=1,Transparency=0.6},fr)
    New("TextLabel",{
        Size=UDim2.new(1,-16,0,22),Position=UDim2.new(0,8,0,2),BackgroundTransparency=1,
        Text="📌 Пиши в чат: «Название» → к метке",
        TextColor3=C.GRAY,Font=Enum.Font.Gotham,TextSize=10,
        TextXAlignment=Enum.TextXAlignment.Left,ZIndex=208,
    },fr)
    New("TextLabel",{
        Size=UDim2.new(1,-16,0,22),Position=UDim2.new(0,8,0,24),BackgroundTransparency=1,
        Text="🆕 «Название me» → все предметы летят к тебе",
        TextColor3=C.NEON_P,Font=Enum.Font.GothamBold,TextSize=10,
        TextXAlignment=Enum.TextXAlignment.Left,ZIndex=208,
    },fr)
end
do
    local sf=New("Frame",{Size=UDim2.new(1,0,0,30),BackgroundColor3=Color3.fromRGB(14,8,28),BorderSizePixel=0,ZIndex=207,LayoutOrder=7},scFarm)
    New("UICorner",{CornerRadius=UDim.new(0,8)},sf)
    New("UIStroke",{Color=C.NEON_P,Thickness=1,Transparency=0.75},sf)
    chatMeTpStatusLbl=New("TextLabel",{
        Size=UDim2.new(1,-16,1,0),Position=UDim2.new(0,8,0,0),BackgroundTransparency=1,
        Text="Выключено",TextColor3=Color3.fromRGB(80,70,100),
        Font=Enum.Font.GothamBold,TextSize=11,
        TextXAlignment=Enum.TextXAlignment.Center,ZIndex=208,
    },sf)
end

MakeDivider(scFarm,"СКРЫТЬ ПРЕДМЕТЫ (FPS)",8)
local itemsHidden=false
local savedTransparency={}
local function setItemsVisibility(hide)
    if not itemsFolder then itemsFolder=Workspace:FindFirstChild("Items") end
    if not itemsFolder then return end
    if hide then
        savedTransparency={}
        for _,item in ipairs(itemsFolder:GetDescendants()) do
            if item:IsA("BasePart") or item:IsA("MeshPart") then
                savedTransparency[item]=item.LocalTransparencyModifier
                item.LocalTransparencyModifier=1
            end
        end
        if not itemsFolder:FindFirstChild("__HideConn") then
            local hc=Instance.new("StringValue"); hc.Name="__HideConn"; hc.Parent=itemsFolder
            itemsFolder.DescendantAdded:Connect(function(obj)
                if not itemsHidden then return end
                if obj:IsA("BasePart") or obj:IsA("MeshPart") then
                    savedTransparency[obj]=obj.LocalTransparencyModifier
                    obj.LocalTransparencyModifier=1
                end
            end)
        end
    else
        for part,origT in pairs(savedTransparency) do
            if part and part.Parent then part.LocalTransparencyModifier=origT end
        end
        savedTransparency={}
    end
end
MakeToggle(scFarm,"👁‍🗨  Скрыть все предметы",C.NEON_O,9,function(on)
    itemsHidden=on; setItemsVisibility(on)
end)

MakeDivider(scFarm,"FPS FLUSH (фикс просадки)",13)
local fpsFlushInterval=60
local fpsFlushConn=nil
local fpsFlushCount=0
local fpsFlushLbl=nil

local function doFpsFlush()
    fpsFlushCount=fpsFlushCount+1
    local gc_force={}
    for i=1,50000 do gc_force[i]=i end
    gc_force=nil
    task.spawn(function()
        for _,obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("Highlight") and (not obj.Adornee or not obj.Adornee.Parent) then pcall(function() obj:Destroy() end) end
            if obj:IsA("BillboardGui") and (not obj.Adornee or not obj.Adornee.Parent) then pcall(function() obj:Destroy() end) end
        end
    end)
    task.spawn(function() pcall(function() ContentProvider:PreloadAsync({}) end) end)
    task.spawn(function()
        local done=0
        for _,obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("BasePart") then
                pcall(function() obj.RenderFidelity=Enum.RenderFidelity.Automatic end)
                done=done+1; if done%300==0 then task.wait() end
            end
        end
    end)
    if fpsFlushLbl then
        fpsFlushLbl.Text="✅ Флаш #"..fpsFlushCount.." выполнен"
        fpsFlushLbl.TextColor3=Color3.fromRGB(0,220,100)
        task.delay(3,function()
            if fpsFlushLbl then
                fpsFlushLbl.Text="Авто-флаш каждые "..fpsFlushInterval.."с  |  #"..fpsFlushCount
                fpsFlushLbl.TextColor3=Color3.fromRGB(100,90,120)
            end
        end)
    end
end

local function startFpsFlushLoop()
    if fpsFlushConn then fpsFlushConn:Disconnect();fpsFlushConn=nil end
    local acc=0
    fpsFlushConn=RunService.Heartbeat:Connect(function(dt)
        acc=acc+dt; if acc>=fpsFlushInterval then acc=0;doFpsFlush() end
    end)
end
local function stopFpsFlushLoop()
    if fpsFlushConn then fpsFlushConn:Disconnect();fpsFlushConn=nil end
end

MakeToggle(scFarm,"🔄  Авто FPS Flush",Color3.fromRGB(0,210,180),14,function(on)
    if on then startFpsFlushLoop() else stopFpsFlushLoop() end
    if fpsFlushLbl then
        fpsFlushLbl.Text=on and ("Авто-флаш каждые "..fpsFlushInterval.."с") or "Выключено"
        fpsFlushLbl.TextColor3=on and Color3.fromRGB(0,210,180) or Color3.fromRGB(100,90,120)
    end
end)
do
    local fr=New("Frame",{Size=UDim2.new(1,0,0,20),BackgroundTransparency=1,ZIndex=207,LayoutOrder=15},scFarm)
    fpsFlushLbl=New("TextLabel",{
        Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,
        Text="Выключено",TextColor3=Color3.fromRGB(100,90,120),
        Font=Enum.Font.Gotham,TextSize=10,
        TextXAlignment=Enum.TextXAlignment.Center,ZIndex=208,
    },fr)
end
MakeBtn(scFarm,"⚡  Flush сейчас (ручной)",Color3.fromRGB(0,210,180),16,function() doFpsFlush() end)

MakeDivider(scFarm,"ОПТИМИЗАЦИЯ МИРА",17)
local optimizeActive=false
local origSettings={}
local origObjProps={}

local function saveAndOptimize()
    if optimizeActive then return end; optimizeActive=true
    local L=Lighting
    origSettings.GlobalShadows=L.GlobalShadows; origSettings.FogEnd=L.FogEnd
    origSettings.FogStart=L.FogStart; origSettings.Brightness=L.Brightness
    origSettings.EnvironmentDiffuseScale=L.EnvironmentDiffuseScale
    origSettings.EnvironmentSpecularScale=L.EnvironmentSpecularScale
    origSettings.ExposureCompensation=L.ExposureCompensation
    L.GlobalShadows=false; L.FogEnd=9e9; L.FogStart=9e9
    L.Brightness=2; L.EnvironmentDiffuseScale=0
    L.EnvironmentSpecularScale=0; L.ExposureCompensation=0
    local dfx={}
    for _,fx in ipairs(L:GetChildren()) do
        if fx:IsA("PostEffect") or fx:IsA("Atmosphere") then dfx[fx]=fx.Enabled;fx.Enabled=false end
    end
    origSettings.disabledFX=dfx
    pcall(function()
        local gs=UserSettings():GetService("UserGameSettings")
        origSettings.SavedQuality=gs.SavedQualityLevel
        origSettings.graphicsMode=gs.GraphicsMode
        gs.SavedQualityLevel=Enum.SavedQualitySetting.QualityLevel1
        gs.GraphicsMode=Enum.GraphicsMode.Manual
    end)
    local batch={}
    for _,obj in ipairs(Workspace:GetDescendants()) do table.insert(batch,obj) end
    task.spawn(function()
        local done=0
        for _,obj in ipairs(batch) do
            done=done+1
            local saved={}
            if obj:IsA("ParticleEmitter") or obj:IsA("Fire") or obj:IsA("Smoke") or obj:IsA("Sparkles") then
                saved.Enabled=obj.Enabled;obj.Enabled=false
            end
            if obj:IsA("Beam") or obj:IsA("Trail") then saved.Enabled=obj.Enabled;obj.Enabled=false end
            if obj:IsA("Decal") then saved.Transparency=obj.Transparency;obj.Transparency=1 end
            if obj:IsA("Texture") then
                saved.StudsPerTileU=obj.StudsPerTileU;saved.StudsPerTileV=obj.StudsPerTileV
                obj.StudsPerTileU=512;obj.StudsPerTileV=512
            end
            if obj:IsA("BasePart") then
                saved.RenderFidelity=obj.RenderFidelity
                pcall(function() obj.RenderFidelity=Enum.RenderFidelity.Disabled end)
            end
            if next(saved) then origObjProps[obj]=saved end
            if done%200==0 then task.wait() end
        end
    end)
    local oc=Workspace.DescendantAdded:Connect(function(obj)
        if not optimizeActive then return end
        if obj:IsA("ParticleEmitter") or obj:IsA("Fire") or obj:IsA("Smoke") or obj:IsA("Sparkles")
        or obj:IsA("Beam") or obj:IsA("Trail") then obj.Enabled=false end
        if obj:IsA("Decal") then obj.Transparency=1 end
        if obj:IsA("Texture") then obj.StudsPerTileU=512;obj.StudsPerTileV=512 end
        if obj:IsA("BasePart") then pcall(function() obj.RenderFidelity=Enum.RenderFidelity.Disabled end) end
    end)
    origSettings.optConn=oc
end

local function restoreAll()
    if not optimizeActive then return end; optimizeActive=false
    local L=Lighting
    for k,_ in pairs({GlobalShadows=true,FogEnd=true,FogStart=true,Brightness=true,
        EnvironmentDiffuseScale=true,EnvironmentSpecularScale=true,ExposureCompensation=true}) do
        if origSettings[k]~=nil then L[k]=origSettings[k] end
    end
    for fx,was in pairs(origSettings.disabledFX or {}) do
        if fx and fx.Parent then fx.Enabled=was end
    end
    if origSettings.optConn then pcall(function() origSettings.optConn:Disconnect() end) end
    local keys={}
    for obj in pairs(origObjProps) do table.insert(keys,obj) end
    task.spawn(function()
        local done=0
        for _,obj in ipairs(keys) do
            done=done+1
            local saved=origObjProps[obj]
            if obj and obj.Parent and saved then
                if saved.Enabled~=nil then pcall(function() obj.Enabled=saved.Enabled end) end
                if saved.Transparency~=nil then pcall(function() obj.Transparency=saved.Transparency end) end
                if saved.StudsPerTileU~=nil then pcall(function() obj.StudsPerTileU=saved.StudsPerTileU end) end
                if saved.StudsPerTileV~=nil then pcall(function() obj.StudsPerTileV=saved.StudsPerTileV end) end
                if saved.RenderFidelity~=nil then pcall(function() obj.RenderFidelity=saved.RenderFidelity end) end
            end
            if done%200==0 then task.wait() end
        end
        origObjProps={}
    end)
    pcall(function()
        local gs=UserSettings():GetService("UserGameSettings")
        if origSettings.SavedQuality then gs.SavedQualityLevel=origSettings.SavedQuality end
        if origSettings.graphicsMode then gs.GraphicsMode=origSettings.graphicsMode end
    end)
    origSettings={}
end

local _,_,setOptState=MakeToggle(scFarm,"🚀  Макс. Оптимизация (1×1 текстуры)",Color3.fromRGB(244,63,94),18,function(on)
    if on then saveAndOptimize() else restoreAll() end
end)
local restBtn=New("TextButton",{
    Size=UDim2.new(1,0,0,38),BackgroundColor3=Color3.fromRGB(30,14,14),
    BorderSizePixel=0,Text="↩️  Вернуть графику",TextColor3=Color3.fromRGB(244,63,94),
    Font=Enum.Font.GothamBold,TextSize=12,AutoButtonColor=false,ZIndex=207,LayoutOrder=19,
},scFarm)
New("UICorner",{CornerRadius=UDim.new(0,10)},restBtn)
New("UIStroke",{Color=Color3.fromRGB(244,63,94),Thickness=1.2,Transparency=0.5},restBtn)
restBtn.MouseEnter:Connect(function() Tw(restBtn,{BackgroundColor3=Color3.fromRGB(244,63,94)},0.14);restBtn.TextColor3=C.BLACK end)
restBtn.MouseLeave:Connect(function() Tw(restBtn,{BackgroundColor3=Color3.fromRGB(30,14,14)},0.14);restBtn.TextColor3=Color3.fromRGB(244,63,94) end)
restBtn.Activated:Connect(function() restoreAll();setOptState(false) end)

MakeDivider(scFarm,"ТП ПРЕДМЕТОВ К МЕТКЕ",20)

local possibleItems={
    "Alpha Wolf Pelt","Anvil Back","Anvil Front","Apple","Bandage",
    "Bear Corpse","Bear Pelt","Berry","Biofuel","Bolt","Broken Fan",
    "Broken Microwave","Bunny Foot","Carrot","Chainsaw","Coal","Coin Stack",
    "Cooked Morsel","Cooked Steak","Cultist Gem","Flower",
    "Fuel Canister","Gem of the Forest Fragment","Giant Sack",
    "Good Axe","Good Sack","Hologram Emitter","Iron Body",
    "Katana","Kunai","Laser Fence Blueprint","Laser Sword",
    "Leather Body","Log","MedKit","Morsel","Oil Barrel",
    "Old Car Engine","Old Flashlight","Old Radio","Raygun",
    "Revolver","Revolver Ammo","Rifle","Rifle Ammo","Sapling",
    "Sheet Metal","Spear","Steak","Strong Axe","Thorn Body",
    "Tyre","UFO Component","UFO Junk","Washing Machine","Wolf Pelt",
}
do
    local seen,clean={},{}
    for _,n in ipairs(possibleItems) do if not seen[n] then seen[n]=true;table.insert(clean,n) end end
    possibleItems=clean; table.sort(possibleItems)
end

local sBg=New("Frame",{Size=UDim2.new(1,0,0,40),BackgroundColor3=C.PANEL2,BorderSizePixel=0,ZIndex=207,LayoutOrder=21},scFarm)
New("UICorner",{CornerRadius=UDim.new(0,10)},sBg)
New("UIStroke",{Color=C.DGRAY,Thickness=1},sBg)
New("TextLabel",{Size=UDim2.new(0,28,1,0),Position=UDim2.new(0,6,0,0),BackgroundTransparency=1,Text="🔍",TextSize=14,Font=Enum.Font.GothamBold,ZIndex=209},sBg)
local SBox=New("TextBox",{
    Size=UDim2.new(1,-36,1,0),Position=UDim2.new(0,30,0,0),
    BackgroundTransparency=1,Text="",PlaceholderText="Поиск предмета...",
    TextColor3=C.WHITE,PlaceholderColor3=C.GRAY,TextSize=12,
    Font=Enum.Font.Gotham,TextXAlignment=Enum.TextXAlignment.Left,
    ClearTextOnFocus=false,ZIndex=209,
},sBg)

local FarmCount=New("TextLabel",{
    Size=UDim2.new(1,0,0,18),BackgroundTransparency=1,
    Text="Всего: "..#possibleItems,TextColor3=C.GRAY,
    Font=Enum.Font.Gotham,TextSize=10,
    TextXAlignment=Enum.TextXAlignment.Center,ZIndex=207,LayoutOrder=22,
},scFarm)

local farmItemBtns={}
for i,name in ipairs(possibleItems) do
    local ibtn=New("TextButton",{
        Size=UDim2.new(1,0,0,38),BackgroundColor3=Color3.fromRGB(26,16,46),
        BorderSizePixel=0,Text="📦  "..name,TextColor3=C.NEON_R,
        Font=Enum.Font.Gotham,TextSize=12,AutoButtonColor=false,
        ZIndex=208,LayoutOrder=23+i,TextXAlignment=Enum.TextXAlignment.Left,
    },scFarm)
    New("UICorner",{CornerRadius=UDim.new(0,8)},ibtn)
    New("UIPadding",{PaddingLeft=UDim.new(0,10)},ibtn)
    ibtn.MouseEnter:Connect(function() Tw(ibtn,{BackgroundColor3=C.ACCENT},0.13);ibtn.TextColor3=C.WHITE end)
    ibtn.MouseLeave:Connect(function() Tw(ibtn,{BackgroundColor3=Color3.fromRGB(26,16,46)},0.13);ibtn.TextColor3=C.NEON_R end)
    local n=name
    ibtn.Activated:Connect(function() teleportItemToMarker(n) end)
    farmItemBtns[i]={btn=ibtn,name=name:lower()}
end

local function farmFilter(q)
    q=q:lower():gsub("%s+","")
    local shown=0
    for _,e in ipairs(farmItemBtns) do
        local m=q=="" or e.name:find(q,1,true)
        e.btn.Visible=m; if m then shown=shown+1 end
    end
    FarmCount.Text=(q=="" and "Всего: " or "Найдено: ")..shown
    scFarm.CanvasPosition=Vector2.new(0,0)
end
SBox:GetPropertyChangedSignal("Text"):Connect(function() farmFilter(SBox.Text) end)

-- ══════════════════════════════════════════════════════════════════════
--  🌱  DUP TAB
-- ══════════════════════════════════════════════════════════════════════
local dupConfig = { plantDelay=0.1, plantAmount=10 }
local dupEnabled = false
local dupStatusLbl = nil

local function findSapling()
    local character = Player.Character
    if not character or not character.PrimaryPart then return nil end
    local playerPos = character.PrimaryPart.Position
    local nearest,shortest = nil,math.huge
    local items = Workspace:FindFirstChild("Items")
    if not items then return nil end
    for _, item in ipairs(items:GetChildren()) do
        if item.Name == "Sapling" and item.PrimaryPart then
            local dist = (item.PrimaryPart.Position - playerPos).Magnitude
            if dist < shortest then shortest=dist; nearest=item end
        end
    end
    return nearest
end

local function setDupStatus(txt, color)
    if dupStatusLbl then dupStatusLbl.Text=txt; dupStatusLbl.TextColor3=color or C.NEON_AQ end
end

local function runDupLoop()
    task.spawn(function()
        while dupEnabled do
            local sapling = findSapling()
            if not sapling or not sapling.PrimaryPart then
                setDupStatus("⏳ Саженец не найден, жду...", C.NEON_Y)
                task.wait(0.5); continue
            end
            local root = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
            if not root then task.wait(0.5); continue end
            local RS = game:GetService("ReplicatedStorage")
            local tempStorage = RS:FindFirstChild("TempStorage")
            if tempStorage then sapling.Parent = tempStorage end
            setDupStatus("🌱 Дюпим... x"..dupConfig.plantAmount, C.NEON_AQ)
            for i = 1, dupConfig.plantAmount do
                if not dupEnabled then break end
                local pos = Vector3.new(root.Position.X, root.Position.Y-3, root.Position.Z)
                pcall(function()
                    local remote = RS:FindFirstChild("RemoteEvents")
                    if remote then
                        local plantRemote = remote:FindFirstChild("RequestPlantItem")
                        if plantRemote then plantRemote:InvokeServer(sapling, pos) end
                    end
                end)
                task.wait(dupConfig.plantDelay)
            end
            setDupStatus("✅ Цикл завершён! Продолжаю...", C.NEON_G)
            task.wait(0.3)
        end
        setDupStatus("⛔ Дюп остановлен", Color3.fromRGB(200,80,80))
    end)
end

MakeDivider(scDup, "🌱 ДЮП САЖЕНЦЕВ", 1)
do
    local infoFr=New("Frame",{Size=UDim2.new(1,0,0,52),BackgroundColor3=Color3.fromRGB(0,30,20),BorderSizePixel=0,ZIndex=207,LayoutOrder=2},scDup)
    New("UICorner",{CornerRadius=UDim.new(0,10)},infoFr)
    New("UIStroke",{Color=C.NEON_AQ,Thickness=1.2,Transparency=0.5},infoFr)
    New("TextLabel",{
        Size=UDim2.new(1,-16,1,0),Position=UDim2.new(0,8,0,0),BackgroundTransparency=1,
        Text="Положи саженец рядом с собой в мире.\nСкрипт найдёт ближайший и задюпит его.",
        TextColor3=C.NEON_AQ,Font=Enum.Font.Gotham,TextSize=11,
        TextXAlignment=Enum.TextXAlignment.Center,ZIndex=208,TextWrapped=true,
    },infoFr)
end

MakeDivider(scDup,"ЗАДЕРЖКА (сек)",3)
MakeSlider(scDup,"Задержка между посадками",C.NEON_AQ,1,200,10,4,function(val)
    dupConfig.plantDelay=val/100
end,function(val) return string.format("%.2fс",val/100) end)
do
    local hintFr=New("Frame",{Size=UDim2.new(1,0,0,18),BackgroundTransparency=1,ZIndex=207,LayoutOrder=5},scDup)
    New("TextLabel",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text="Диапазон: 0.01с — 2.00с  |  по умолч. 0.10с",TextColor3=C.GRAY,Font=Enum.Font.Gotham,TextSize=10,TextXAlignment=Enum.TextXAlignment.Center,ZIndex=208},hintFr)
end

MakeDivider(scDup,"КОЛИЧЕСТВО ЗА ЦИКЛ",6)
MakeSlider(scDup,"Количество саженцев за цикл",C.NEON_AQ,1,100,10,7,function(val)
    dupConfig.plantAmount=val
end,function(val) return tostring(val).."шт" end)

MakeDivider(scDup,"ТОЧНЫЙ ВВОД",8)
do
    local inputRow=New("Frame",{Size=UDim2.new(1,0,0,44),BackgroundColor3=C.PANEL2,BorderSizePixel=0,ZIndex=207,LayoutOrder=9},scDup)
    New("UICorner",{CornerRadius=UDim.new(0,10)},inputRow)
    New("TextLabel",{Size=UDim2.new(0.45,0,1,0),Position=UDim2.new(0,12,0,0),BackgroundTransparency=1,Text="Задержка (сек):",TextColor3=C.NEON_AQ,Font=Enum.Font.GothamBold,TextSize=12,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=208},inputRow)
    local delayBox=New("TextBox",{Size=UDim2.new(0.45,-8,0,28),Position=UDim2.new(0.5,4,0.5,-14),BackgroundColor3=Color3.fromRGB(30,20,50),BorderSizePixel=0,Text="0.1",PlaceholderText="0.1",TextColor3=C.WHITE,PlaceholderColor3=C.GRAY,Font=Enum.Font.Gotham,TextSize=13,ClearTextOnFocus=false,ZIndex=209},inputRow)
    New("UICorner",{CornerRadius=UDim.new(0,6)},delayBox)
    New("UIStroke",{Color=C.NEON_AQ,Thickness=1,Transparency=0.6},delayBox)
    delayBox.FocusLost:Connect(function()
        local val=tonumber(delayBox.Text)
        if val and val>=0 then dupConfig.plantDelay=val else delayBox.Text=tostring(dupConfig.plantDelay) end
    end)
end
do
    local inputRow2=New("Frame",{Size=UDim2.new(1,0,0,44),BackgroundColor3=C.PANEL2,BorderSizePixel=0,ZIndex=207,LayoutOrder=10},scDup)
    New("UICorner",{CornerRadius=UDim.new(0,10)},inputRow2)
    New("TextLabel",{Size=UDim2.new(0.45,0,1,0),Position=UDim2.new(0,12,0,0),BackgroundTransparency=1,Text="Количество:",TextColor3=C.NEON_AQ,Font=Enum.Font.GothamBold,TextSize=12,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=208},inputRow2)
    local amountBox=New("TextBox",{Size=UDim2.new(0.45,-8,0,28),Position=UDim2.new(0.5,4,0.5,-14),BackgroundColor3=Color3.fromRGB(30,20,50),BorderSizePixel=0,Text="10",PlaceholderText="10",TextColor3=C.WHITE,PlaceholderColor3=C.GRAY,Font=Enum.Font.Gotham,TextSize=13,ClearTextOnFocus=false,ZIndex=209},inputRow2)
    New("UICorner",{CornerRadius=UDim.new(0,6)},amountBox)
    New("UIStroke",{Color=C.NEON_AQ,Thickness=1,Transparency=0.6},amountBox)
    amountBox.FocusLost:Connect(function()
        local val=tonumber(amountBox.Text)
        if val and val>=1 then dupConfig.plantAmount=math.floor(val) else amountBox.Text=tostring(dupConfig.plantAmount) end
    end)
end

MakeDivider(scDup,"СТАТУС",11)
do
    local statusFr=New("Frame",{Size=UDim2.new(1,0,0,36),BackgroundColor3=Color3.fromRGB(8,20,14),BorderSizePixel=0,ZIndex=207,LayoutOrder=12},scDup)
    New("UICorner",{CornerRadius=UDim.new(0,10)},statusFr)
    New("UIStroke",{Color=C.NEON_AQ,Thickness=1,Transparency=0.7},statusFr)
    dupStatusLbl=New("TextLabel",{Size=UDim2.new(1,-16,1,0),Position=UDim2.new(0,8,0,0),BackgroundTransparency=1,Text="⛔ Дюп выключен",TextColor3=Color3.fromRGB(150,150,150),Font=Enum.Font.GothamBold,TextSize=12,TextXAlignment=Enum.TextXAlignment.Center,ZIndex=208},statusFr)
end

MakeDivider(scDup,"УПРАВЛЕНИЕ",13)
MakeToggle(scDup,"🌱  ДЮПЕР САЖЕНЦЕВ  (вкл/выкл)",C.NEON_AQ,14,function(on)
    dupEnabled=on
    if on then setDupStatus("🔄 Запускаю дюп...",C.NEON_AQ); runDupLoop()
    else dupEnabled=false; setDupStatus("⛔ Дюп выключен",Color3.fromRGB(150,150,150)) end
end)

MakeBtn(scDup,"🌿  Дюпнуть 1 раз вручную",C.NEON_G,15,function()
    local sapling=findSapling()
    if not sapling or not sapling.PrimaryPart then setDupStatus("❌ Саженец не найден рядом!",Color3.fromRGB(255,80,80));return end
    local root=Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
    if not root then setDupStatus("❌ Нет персонажа!",Color3.fromRGB(255,80,80));return end
    local RS=game:GetService("ReplicatedStorage")
    local tempStorage=RS:FindFirstChild("TempStorage")
    if tempStorage then sapling.Parent=tempStorage end
    setDupStatus("🌱 Ручной дюп x"..dupConfig.plantAmount,C.NEON_AQ)
    task.spawn(function()
        for i=1,dupConfig.plantAmount do
            local pos=Vector3.new(root.Position.X,root.Position.Y-3,root.Position.Z)
            pcall(function()
                local remote=RS:FindFirstChild("RemoteEvents")
                if remote then
                    local plantRemote=remote:FindFirstChild("RequestPlantItem")
                    if plantRemote then plantRemote:InvokeServer(sapling,pos) end
                end
            end)
            task.wait(dupConfig.plantDelay)
        end
        setDupStatus("✅ Ручной дюп завершён!",C.NEON_G)
    end)
end)

MakeBtn(scDup,"🔍  Найти ближайший саженец",C.NEON_Y,16,function()
    local sapling=findSapling()
    if sapling and sapling.PrimaryPart then
        local hrp=getHRP()
        local dist=hrp and math.floor((hrp.Position-sapling.PrimaryPart.Position).Magnitude) or 0
        setDupStatus("✅ Найдено: "..sapling.Name.."  ("..dist.." studs)",C.NEON_G)
        if hrp then hrp.CFrame=CFrame.new(sapling.PrimaryPart.Position+Vector3.new(0,3,0)) end
    else
        setDupStatus("❌ Саженец не найден в Items!",Color3.fromRGB(255,80,80))
    end
end)

do
    local noteFr=New("Frame",{Size=UDim2.new(1,0,0,46),BackgroundTransparency=1,ZIndex=207,LayoutOrder=17},scDup)
    New("TextLabel",{
        Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,
        Text="💡 Кнопка «Найти» также телепортирует\nтебя к саженцу автоматически.",
        TextColor3=C.GRAY,Font=Enum.Font.Gotham,TextSize=10,
        TextXAlignment=Enum.TextXAlignment.Center,ZIndex=208,TextWrapped=true,
    },noteFr)
end

-- ══════════════════════════════════════════════════════════════════════
--  👥  TEAM TAB
-- ══════════════════════════════════════════════════════════════════════
local teamTpEnabled     = false
local teamHealEnabled   = false
local teamAutoSave      = false
local teamHealItem      = "Bandage"
local teamTargetName    = "morselxdda Body"
local teamStatusLbl     = nil
local teamStatusLbl2    = nil
local teamStatusLbl3    = nil

local function findAnyBody()
    local chars = Workspace:FindFirstChild("Characters")
    if not chars then
        for _, v in ipairs(Workspace:GetChildren()) do
            if v.Name:find("Body") and v:IsA("Model") then return v end
        end
        return nil
    end
    for _, v in ipairs(chars:GetChildren()) do
        if v.Name:find("Body") then return v end
    end
    return nil
end

local function doTeamHeal(body)
    local RS = ReplicatedStorage
    pcall(function()
        local inv = Player:FindFirstChild("Inventory") or Player:FindFirstChild("Backpack")
        local item = inv and inv:FindFirstChild(teamHealItem)
        RS.RemoteEvents.EquipItemHandle:FireServer("FireAllClients", item)
    end)
    task.wait(0.3)
    pcall(function()
        if body and body.Parent then
            RS.RemoteEvents.RequestRevivePlayer:FireServer(body)
        end
    end)
    task.wait(0.3)
    pcall(function()
        local itemNil = nil
        pcall(function()
            for _, v in pairs(getnilinstances()) do
                if v.ClassName == "Model" and v.Name == teamHealItem then
                    itemNil = v; break
                end
            end
        end)
        if itemNil then
            RS.RemoteEvents.UnequipItemHandle:FireServer("FireAllClients", itemNil)
        end
    end)
end

local function setTeamStatus(lbl, txt, color)
    if lbl then lbl.Text = txt; lbl.TextColor3 = color or C.NEON_TM end
end

local teamTpConn = nil

local function startTeamTpLoop()
    if teamTpConn then teamTpConn:Disconnect(); teamTpConn = nil end
    teamTpConn = RunService.Heartbeat:Connect(function()
        if not teamTpEnabled then return end
        local chars = Workspace:FindFirstChild("Characters")
        local body = chars and chars:FindFirstChild(teamTargetName)
        if not body then body = Workspace:FindFirstChild(teamTargetName) end
        if body then
            pcall(function()
                ReplicatedStorage.RemoteEvents.RequestStartDraggingItem:FireServer(body)
            end)
            local root = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
            if root then
                for _, part in ipairs(body:GetDescendants()) do
                    if part:IsA("BasePart") then
                        pcall(function() part.CFrame = root.CFrame end)
                    end
                end
            end
        end
    end)
end

local function stopTeamTpLoop()
    teamTpEnabled = false
    if teamTpConn then teamTpConn:Disconnect(); teamTpConn = nil end
end

local teamHealTask = nil

local function startTeamHealLoop()
    teamHealTask = task.spawn(function()
        while teamHealEnabled do
            local chars = Workspace:FindFirstChild("Characters")
            local body = chars and chars:FindFirstChild(teamTargetName) or Workspace:FindFirstChild(teamTargetName)
            doTeamHeal(body)
            task.wait(1)
        end
    end)
end

local function stopTeamHeal()
    teamHealEnabled = false
end

local teamAutoSaveTask = nil

local function startTeamAutoSave()
    teamAutoSaveTask = task.spawn(function()
        local lastBody = nil
        while teamAutoSave do
            task.wait(0.5)
            local body = findAnyBody()
            if body and body ~= lastBody then
                lastBody = body
                print("[99N] Нокнут:", body.Name)
                local root = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
                if not root then continue end
                setTeamStatus(teamStatusLbl3, "🚨 Тянем: "..body.Name, Color3.fromRGB(255,160,0))
                local tpEnd = tick() + 2
                while tick() < tpEnd do
                    task.wait(0.05)
                    pcall(function()
                        ReplicatedStorage.RemoteEvents.RequestStartDraggingItem:FireServer(body)
                    end)
                    for _, part in ipairs(body:GetDescendants()) do
                        if part:IsA("BasePart") then
                            pcall(function() part.CFrame = root.CFrame end)
                        end
                    end
                end
                doTeamHeal(body)
                setTeamStatus(teamStatusLbl3, "✅ Вылечен: "..body.Name, C.NEON_G)
                print("[99N] Вылечен:", body.Name)
                task.wait(2)
                setTeamStatus(teamStatusLbl3, "👁 Слежу за нокнутыми...", C.NEON_TM)
            end
            if not body then lastBody = nil end
        end
        setTeamStatus(teamStatusLbl3, "⛔ Авто Спас выключен", Color3.fromRGB(180,80,80))
    end)
end

MakeDivider(scTeam, "👥 ТП + ХИЛ ТИМЕЙТОВ", 1)
do
    local infoFr=New("Frame",{Size=UDim2.new(1,0,0,54),BackgroundColor3=Color3.fromRGB(0,20,30),BorderSizePixel=0,ZIndex=207,LayoutOrder=2},scTeam)
    New("UICorner",{CornerRadius=UDim.new(0,10)},infoFr)
    New("UIStroke",{Color=C.NEON_TM,Thickness=1.2,Transparency=0.5},infoFr)
    New("TextLabel",{
        Size=UDim2.new(1,-16,1,0),Position=UDim2.new(0,8,0,0),BackgroundTransparency=1,
        Text="ТП тела тимейта к себе + лечение.\nАвто Спас — сам находит нокнутого\nи тянет + лечит автоматически.",
        TextColor3=C.NEON_TM,Font=Enum.Font.Gotham,TextSize=10,
        TextXAlignment=Enum.TextXAlignment.Center,ZIndex=208,TextWrapped=true,
    },infoFr)
end

MakeDivider(scTeam,"ИМЯ ТЕЛА ТИМЕЙТА",3)
do
    local inputRow=New("Frame",{Size=UDim2.new(1,0,0,46),BackgroundColor3=C.PANEL2,BorderSizePixel=0,ZIndex=207,LayoutOrder=4},scTeam)
    New("UICorner",{CornerRadius=UDim.new(0,10)},inputRow)
    New("TextLabel",{
        Size=UDim2.new(1,0,0,20),Position=UDim2.new(0,12,0,2),BackgroundTransparency=1,
        Text="Имя объекта (напр: morselxdda Body):",
        TextColor3=C.NEON_TM,Font=Enum.Font.GothamBold,TextSize=11,
        TextXAlignment=Enum.TextXAlignment.Left,ZIndex=208,
    },inputRow)
    local nameBox=New("TextBox",{
        Size=UDim2.new(1,-24,0,22),Position=UDim2.new(0,12,0,22),
        BackgroundColor3=Color3.fromRGB(0,20,30),BorderSizePixel=0,
        Text="morselxdda Body",PlaceholderText="Имя Body тимейта",
        TextColor3=C.WHITE,PlaceholderColor3=C.GRAY,
        Font=Enum.Font.Gotham,TextSize=12,ClearTextOnFocus=false,ZIndex=209,
    },inputRow)
    New("UICorner",{CornerRadius=UDim.new(0,6)},nameBox)
    New("UIStroke",{Color=C.NEON_TM,Thickness=1,Transparency=0.6},nameBox)
    nameBox:GetPropertyChangedSignal("Text"):Connect(function()
        teamTargetName = nameBox.Text
    end)
end

MakeDivider(scTeam,"ПРЕДМЕТ ЛЕЧЕНИЯ",5)
do
    local healRow=New("Frame",{Size=UDim2.new(1,0,0,44),BackgroundColor3=C.PANEL2,BorderSizePixel=0,ZIndex=207,LayoutOrder=6},scTeam)
    New("UICorner",{CornerRadius=UDim.new(0,10)},healRow)
    New("TextLabel",{
        Size=UDim2.new(0.5,0,1,0),Position=UDim2.new(0,12,0,0),BackgroundTransparency=1,
        Text="Лечить чем:",TextColor3=C.NEON_TM,Font=Enum.Font.GothamBold,TextSize=13,
        TextXAlignment=Enum.TextXAlignment.Left,ZIndex=208,
    },healRow)
    local healItemBtn=New("TextButton",{
        Size=UDim2.new(0.45,-8,0,30),Position=UDim2.new(0.5,4,0.5,-15),
        BackgroundColor3=Color3.fromRGB(0,80,140),BorderSizePixel=0,
        Text="Bandage",TextColor3=C.WHITE,Font=Enum.Font.GothamBold,TextSize=13,
        AutoButtonColor=false,ZIndex=209,
    },healRow)
    New("UICorner",{CornerRadius=UDim.new(0,8)},healItemBtn)
    New("UIStroke",{Color=C.NEON_TM,Thickness=1,Transparency=0.4},healItemBtn)
    healItemBtn.Activated:Connect(function()
        if teamHealItem=="Bandage" then
            teamHealItem="MedKit"
            healItemBtn.Text="MedKit"
            Tw(healItemBtn,{BackgroundColor3=Color3.fromRGB(140,70,0)},0.15)
        else
            teamHealItem="Bandage"
            healItemBtn.Text="Bandage"
            Tw(healItemBtn,{BackgroundColor3=Color3.fromRGB(0,80,140)},0.15)
        end
    end)
end

MakeDivider(scTeam,"ТП ТЕЛА К СЕБЕ",7)
MakeToggle(scTeam,"👤  ТП тела тимейта к себе",C.NEON_TM,8,function(on)
    teamTpEnabled=on
    if on then
        startTeamTpLoop()
        setTeamStatus(teamStatusLbl,"🔄 ТП активно: "..teamTargetName,C.NEON_TM)
    else
        stopTeamTpLoop()
        setTeamStatus(teamStatusLbl,"⛔ ТП тимейта выключено",Color3.fromRGB(180,80,80))
    end
end)
do
    local sf=New("Frame",{Size=UDim2.new(1,0,0,34),BackgroundColor3=Color3.fromRGB(0,18,26),BorderSizePixel=0,ZIndex=207,LayoutOrder=9},scTeam)
    New("UICorner",{CornerRadius=UDim.new(0,10)},sf)
    New("UIStroke",{Color=C.NEON_TM,Thickness=1,Transparency=0.7},sf)
    teamStatusLbl=New("TextLabel",{
        Size=UDim2.new(1,-16,1,0),Position=UDim2.new(0,8,0,0),BackgroundTransparency=1,
        Text="⛔ ТП тимейта выключено",TextColor3=Color3.fromRGB(180,80,80),
        Font=Enum.Font.GothamBold,TextSize=11,TextXAlignment=Enum.TextXAlignment.Center,ZIndex=208,
    },sf)
end

MakeBtn(scTeam,"📍  ТП тела вручную (1 раз)",C.NEON_TM,10,function()
    local chars=Workspace:FindFirstChild("Characters")
    local body=chars and chars:FindFirstChild(teamTargetName) or Workspace:FindFirstChild(teamTargetName)
    if not body then
        setTeamStatus(teamStatusLbl,"❌ Не найдено: "..teamTargetName,Color3.fromRGB(255,80,80)); return
    end
    local root=Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    pcall(function() ReplicatedStorage.RemoteEvents.RequestStartDraggingItem:FireServer(body) end)
    for _,part in ipairs(body:GetDescendants()) do
        if part:IsA("BasePart") then pcall(function() part.CFrame=root.CFrame end) end
    end
    setTeamStatus(teamStatusLbl,"✅ ТП выполнено: "..teamTargetName,C.NEON_G)
    task.delay(2,function() if not teamTpEnabled then setTeamStatus(teamStatusLbl,"⛔ ТП тимейта выключено",Color3.fromRGB(180,80,80)) end end)
end)

MakeDivider(scTeam,"АВТО ХИЛ ТИМЕЙТА",11)
MakeToggle(scTeam,"💊  Авто Хил тимейта",C.NEON_G,12,function(on)
    teamHealEnabled=on
    if on then
        startTeamHealLoop()
        setTeamStatus(teamStatusLbl2,"💊 Хилю: "..teamTargetName.." ("..teamHealItem..")",C.NEON_G)
    else
        stopTeamHeal()
        setTeamStatus(teamStatusLbl2,"⛔ Авто хил выключен",Color3.fromRGB(180,80,80))
    end
end)
do
    local sf2=New("Frame",{Size=UDim2.new(1,0,0,34),BackgroundColor3=Color3.fromRGB(0,18,10),BorderSizePixel=0,ZIndex=207,LayoutOrder=13},scTeam)
    New("UICorner",{CornerRadius=UDim.new(0,10)},sf2)
    New("UIStroke",{Color=C.NEON_G,Thickness=1,Transparency=0.7},sf2)
    teamStatusLbl2=New("TextLabel",{
        Size=UDim2.new(1,-16,1,0),Position=UDim2.new(0,8,0,0),BackgroundTransparency=1,
        Text="⛔ Авто хил выключен",TextColor3=Color3.fromRGB(180,80,80),
        Font=Enum.Font.GothamBold,TextSize=11,TextXAlignment=Enum.TextXAlignment.Center,ZIndex=208,
    },sf2)
end

MakeBtn(scTeam,"💉  Хилнуть вручную (1 раз)",C.NEON_G,14,function()
    local chars=Workspace:FindFirstChild("Characters")
    local body=chars and chars:FindFirstChild(teamTargetName) or Workspace:FindFirstChild(teamTargetName)
    doTeamHeal(body)
    if body then setTeamStatus(teamStatusLbl2,"✅ Хил выполнен: "..teamTargetName,C.NEON_G)
    else setTeamStatus(teamStatusLbl2,"⚠️ Тело не найдено, хил всё равно отправлен",C.NEON_Y) end
    task.delay(2,function() if not teamHealEnabled then setTeamStatus(teamStatusLbl2,"⛔ Авто хил выключен",Color3.fromRGB(180,80,80)) end end)
end)

MakeDivider(scTeam,"АВТО СПАС (нокнутые)",15)
do
    local infoFr2=New("Frame",{Size=UDim2.new(1,0,0,40),BackgroundColor3=Color3.fromRGB(16,10,0),BorderSizePixel=0,ZIndex=207,LayoutOrder=16},scTeam)
    New("UICorner",{CornerRadius=UDim.new(0,10)},infoFr2)
    New("UIStroke",{Color=C.NEON_GD,Thickness=1,Transparency=0.6},infoFr2)
    New("TextLabel",{
        Size=UDim2.new(1,-16,1,0),Position=UDim2.new(0,8,0,0),BackgroundTransparency=1,
        Text="Авто найдёт любого нокнутого (Body) в workspace.Characters\nпритянет к тебе и поднимет автоматически.",
        TextColor3=C.NEON_GD,Font=Enum.Font.Gotham,TextSize=10,
        TextXAlignment=Enum.TextXAlignment.Center,ZIndex=208,TextWrapped=true,
    },infoFr2)
end
MakeToggle(scTeam,"🚨  Авто Спас тимейтов",C.NEON_GD,17,function(on)
    teamAutoSave=on
    if on then
        setTeamStatus(teamStatusLbl3,"👁 Слежу за нокнутыми...",C.NEON_TM)
        startTeamAutoSave()
    else
        teamAutoSave=false
        setTeamStatus(teamStatusLbl3,"⛔ Авто Спас выключен",Color3.fromRGB(180,80,80))
    end
end)
do
    local sf3=New("Frame",{Size=UDim2.new(1,0,0,34),BackgroundColor3=Color3.fromRGB(16,10,0),BorderSizePixel=0,ZIndex=207,LayoutOrder=18},scTeam)
    New("UICorner",{CornerRadius=UDim.new(0,10)},sf3)
    New("UIStroke",{Color=C.NEON_GD,Thickness=1,Transparency=0.7},sf3)
    teamStatusLbl3=New("TextLabel",{
        Size=UDim2.new(1,-16,1,0),Position=UDim2.new(0,8,0,0),BackgroundTransparency=1,
        Text="⛔ Авто Спас выключен",TextColor3=Color3.fromRGB(180,80,80),
        Font=Enum.Font.GothamBold,TextSize=11,TextXAlignment=Enum.TextXAlignment.Center,ZIndex=208,
    },sf3)
end

MakeBtn(scTeam,"🔍  Найти нокнутого сейчас",C.NEON_GD,19,function()
    local body=findAnyBody()
    if body then
        setTeamStatus(teamStatusLbl3,"✅ Найден: "..body.Name,C.NEON_G)
    else
        setTeamStatus(teamStatusLbl3,"❌ Нокнутых не найдено",Color3.fromRGB(255,80,80))
    end
    task.delay(2,function()
        if not teamAutoSave then setTeamStatus(teamStatusLbl3,"⛔ Авто Спас выключен",Color3.fromRGB(180,80,80)) end
    end)
end)

do
    local noteFr=New("Frame",{Size=UDim2.new(1,0,0,50),BackgroundTransparency=1,ZIndex=207,LayoutOrder=20},scTeam)
    New("TextLabel",{
        Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,
        Text="💡 Имя объекта — это имя Body в workspace.Characters\nнапр: «ник Body». Авто Спас ищет любого с Body в имени.",
        TextColor3=C.GRAY,Font=Enum.Font.Gotham,TextSize=10,
        TextXAlignment=Enum.TextXAlignment.Center,ZIndex=208,TextWrapped=true,
    },noteFr)
end

-- ══ SWITCH TAB ════════════════════════════════════════════════════════════════
SwitchTab=function(id)
    if id==ActiveTab then return end
    if TabScrolls[ActiveTab] then TabScrolls[ActiveTab].Visible=false end
    for _,t in ipairs(TABS) do if TabBtns[t.id] then TabBtns[t.id].TextColor3=C.GRAY end end
    ActiveTab=id
    if TabScrolls[id] then TabScrolls[id].Visible=true end
    for _,t in ipairs(TABS) do
        if t.id==id and TabBtns[t.id] then TabBtns[t.id].TextColor3=t.color end
    end
    UpdateTabLine()
end

-- ══ TOGGLE GUI ════════════════════════════════════════════════════════════════
local guiTweenOpen  = TweenInfo.new(0.3,  Enum.EasingStyle.Back,  Enum.EasingDirection.Out)
local guiTweenClose = TweenInfo.new(0.22, Enum.EasingStyle.Quart, Enum.EasingDirection.In)

ToggleGui=function()
    GuiOpen=not GuiOpen
    if GuiOpen then
        local vp=ScreenGui.AbsoluteSize
        WinFrame.Position=UDim2.new(0,math.floor((vp.X-WinW)/2),0,math.floor((vp.Y-WinH)/2))
        WinFrame.Size=UDim2.new(0,WinW*0.88,0,WinH*0.88)
        WinFrame.BackgroundTransparency=1
        WinFrame.Visible=true
        ContentHolder.Visible=not minimized
        TweenService:Create(WinFrame,guiTweenOpen,{
            Size=UDim2.new(0,WinW,0,minimized and HEADER_H or WinH),
            BackgroundTransparency=0,
        }):Play()
    else
        TweenService:Create(WinFrame,guiTweenClose,{
            Size=UDim2.new(0,WinW*0.88,0,(minimized and HEADER_H or WinH)*0.88),
            BackgroundTransparency=1,
        }):Play()
        task.delay(0.22,function()
            if not GuiOpen then WinFrame.Visible=false end
        end)
    end
end

-- ══ HOTKEY ══════════════════════════════════════════════════════════════════════════════════
UserInputService.InputBegan:Connect(function(inp,gp)
    if gp then return end
    if inp.KeyCode==Enum.KeyCode.RightShift then ToggleGui() end
end)

-- ══ REC DOT BLINK ═════════════════════════════════════════════════════════════════
local recAcc,recOn=0,true
RunService.Heartbeat:Connect(function(dt)
    recAcc=recAcc+dt
    if recAcc>=0.9 then
        recAcc=0;recOn=not recOn
        Tw(RecDot,{BackgroundTransparency=recOn and 0 or 0.85},0.3)
        Tw(TDot,  {BackgroundTransparency=recOn and 0 or 0.85},0.3)
    end
end)

-- ══ АВТО-ВОССТАНОВЛЕНИЕ НАСТРОЕК (RESTORE PREVIOUS STATE) ════════════
task.spawn(function()
    task.wait(1)
    for _, restoreFunc in ipairs(autoRestoreList) do
        pcall(restoreFunc)
    end
    print("[99Nights] Сохраненные настройки успешно восстановлены!")
end)

print("[99NightsHardMode|xdar4k v2.5 FIX] Loaded! RightShift = GUI")
print("  🔥 СЖОГ: теперь GetDescendants — Cultist + Crossbow + Brutal + Juggernaut")
print("  🛡️ GOD MODE: вкладка MAIN → тогл GOD MODE")
print("  💬 ЧАТ ТП: вкладка АВТОФАРМ → тогл Чат→ТП + поставь метку")
print("  🌱 ДЮП САЖЕНЦЕВ: вкладка ДЮПЕР → тогл ДЮПЕР САЖЕНЦЕВ")
print("  👥 ТП/ХИЛ ТИМЕЙТОВ: вкладка ТИМЕЙТЫ → все функции")
print("  💾 АВТО-СЕЙВ: активен, состояние тогло сохраняется в 99Nights_Config.json")
