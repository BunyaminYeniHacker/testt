-- WARP ADMIN (all-in-one: core + 4 packs). One file, one loadstring.

do
print("[WarpAdmin] starting")
pcall(function()
game:GetService("StarterGui"):SetCore("SendNotification", { Title = "Warp Admin", Text = "Starting...", Duration = 2 })
end)

local ok, err = pcall(function()
local Players = game:GetService("Players")
local RS = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Light = game:GetService("Lighting")
local TS = game:GetService("TweenService")
local lp = Players.LocalPlayer
if _G.CAUnload then pcall(_G.CAUnload) end
if _G.WarpUnload then pcall(_G.WarpUnload) end

local alive, conns, flags, hooks = true, {}, {}, {}
local vals = { flyspeed = 60, speed = 80, jump = 100 }
local g0 = workspace.Gravity
local fov0 = workspace.CurrentCamera.FieldOfView
local w0, j0, bv, fb, controls

local function bind(s, f) conns[#conns + 1] = s:Connect(f) end
local function hum() local c = lp.Character; return c and c:FindFirstChildOfClass("Humanoid") end
local function root() local c = lp.Character; return c and c:FindFirstChild("HumanoidRootPart") end
local function setFlag(k, on)
on = on and true or false
if (flags[k] or false) == on then return end
flags[k] = on
if hooks[k] then hooks[k](on) end
end
local function find(q)
if not q then return nil end
q = q:lower()
for _, p in ipairs(Players:GetPlayers()) do
if p ~= lp and (p.Name:lower():find(q, 1, true) or p.DisplayName:lower():find(q, 1, true)) then return p end
end
return nil
end

task.spawn(function()
local ok1, m = pcall(function()
return require(lp:WaitForChild("PlayerScripts"):WaitForChild("PlayerModule", 10))
end)
if ok1 and m then pcall(function() controls = m:GetControls() end) end
end)

hooks.fly = function(on)
if on then return end
if bv then bv:Destroy(); bv = nil end
local h = hum()
if h then h.PlatformStand = false end
end
hooks.speed = function(on)
local h = hum()
if not h then return end
if on then w0 = h.WalkSpeed else h.WalkSpeed = w0 or 16 end
end
hooks.jump = function(on)
local h = hum()
if not h then return end
if on then j0 = h.JumpPower else h.JumpPower = j0 or 50 end
end
hooks.fullbright = function(on)
if on then
fb = { Light.Ambient, Light.Brightness, Light.ClockTime, Light.FogEnd, Light.GlobalShadows }
elseif fb then
Light.Ambient, Light.Brightness, Light.ClockTime, Light.FogEnd, Light.GlobalShadows = fb[1], fb[2], fb[3], fb[4], fb[5]
end
end
hooks.esp = function(on)
if on then return end
for _, p in ipairs(Players:GetPlayers()) do
local c = p.Character
local hl = c and c:FindFirstChild("CAESP")
if hl then hl:Destroy() end
end
end

bind(RS.RenderStepped, function()
local cam, h, r = workspace.CurrentCamera, hum(), root()
if h then
if flags.speed then h.WalkSpeed = vals.speed end
if flags.jump then h.UseJumpPower = true; h.JumpPower = vals.jump end
end
if flags.fly and h and r then
if not bv or bv.Parent ~= r then
if bv then bv:Destroy() end
bv = Instance.new("BodyVelocity")
bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
bv.Parent = r
end
local d
local ok2, mv = pcall(function() return controls and controls:GetMoveVector() end)
if ok2 and mv then
d = cam.CFrame.RightVector * mv.X - cam.CFrame.LookVector * mv.Z
else
d = h.MoveDirection
end
if UIS:IsKeyDown(Enum.KeyCode.Space) then d = d + Vector3.new(0, 1, 0) end
if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then d = d - Vector3.new(0, 1, 0) end
bv.Velocity = d * vals.flyspeed
h.PlatformStand = true
end
if flags.fullbright then
Light.Ambient = Color3.new(1, 1, 1)
Light.Brightness = 2
Light.ClockTime = 14
Light.FogEnd = 1e5
Light.GlobalShadows = false
end
end)
bind(RS.Stepped, function()
if flags.noclip and lp.Character then
for _, d in ipairs(lp.Character:GetDescendants()) do
if d:IsA("BasePart") then d.CanCollide = false end
end
end
end)
bind(UIS.JumpRequest, function()
local h = hum()
if flags.infjump and h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
end)
task.spawn(function()
while alive do
if flags.esp then
for _, p in ipairs(Players:GetPlayers()) do
local c = p ~= lp and p.Character
if c and not c:FindFirstChild("CAESP") then
local hl = Instance.new("Highlight")
hl.Name = "CAESP"
hl.FillTransparency = 0.8
hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
hl.Parent = c
end
end
end
task.wait(0.5)
end
end)

local BG = Color3.fromRGB(10, 10, 10)
local W = Color3.new(1, 1, 1)
local MUTED = Color3.fromRGB(125, 125, 125)
local ERR = Color3.fromRGB(205, 105, 105)

local function mk(class, props, parent)
local i = Instance.new(class)
for k, v in pairs(props) do i[k] = v end
i.Parent = parent
return i
end
local function rnd(i, r) mk("UICorner", { CornerRadius = UDim.new(0, r) }, i) end
local function stroke(i, t)
return mk("UIStroke", { Color = W, Transparency = t, Thickness = 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }, i)
end
local function tw(o, t, p, s)
pcall(function()
TS:Create(o, TweenInfo.new(t, s or Enum.EasingStyle.Quint, Enum.EasingDirection.Out), p):Play()
end)
end

local gui = mk("ScreenGui", { Name = "WarpAdmin", ResetOnSpawn = false, IgnoreGuiInset = true, DisplayOrder = 1000 }, nil)
local pok, par = pcall(function() return (gethui and gethui()) or game:GetService("CoreGui") end)
if not (pok and par and pcall(function() gui.Parent = par end) and gui.Parent) then
gui.Parent = lp:WaitForChild("PlayerGui")
end

local snd = mk("Sound", { SoundId = "rbxasset://sounds/clickfast.wav", Volume = 0.35 }, gui)
local sfxOn = true
local function sfx(speed)
if sfxOn then pcall(function() snd.PlaybackSpeed = speed; snd.TimePosition = 0; snd:Play() end) end
end

local vp = workspace.CurrentCamera.ViewportSize
local BW = math.min(320, vp.X - 24)
local MAXL = math.clamp(vp.Y - 200, 90, 260)
local ROW = 34
local lastTap, fillAt = 0, 0

local holder = mk("Frame", { BackgroundTransparency = 1, Size = UDim2.fromOffset(0, 0), Position = UDim2.new(0.5, 0, 0, 6) }, gui)
local circle = mk("TextButton", {
AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromOffset(0, 20), Size = UDim2.fromOffset(0, 0),
BackgroundColor3 = BG, Text = "W", TextColor3 = W, Font = Enum.Font.GothamBold, TextSize = 16, AutoButtonColor = false,
}, holder)
rnd(circle, 30)
local cs = stroke(circle, 0.75)

local bar = mk("CanvasGroup", {
Visible = false, GroupTransparency = 1, BackgroundTransparency = 1, AnchorPoint = Vector2.new(0.5, 0),
Position = UDim2.new(0, 0, 0, 52), Size = UDim2.fromOffset(BW, 0), AutomaticSize = Enum.AutomaticSize.Y,
}, holder)
mk("UIListLayout", { Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder }, bar)
local card = mk("Frame", { LayoutOrder = 1, Size = UDim2.new(1, 0, 0, 42), BackgroundColor3 = BG }, bar)
rnd(card, 12)
local ks = stroke(card, 0.85)
local input = mk("TextBox", {
BackgroundTransparency = 1, Position = UDim2.fromOffset(14, 0), Size = UDim2.new(1, -60, 1, 0), Text = "",
PlaceholderText = "Enter command", PlaceholderColor3 = MUTED, TextColor3 = W, Font = Enum.Font.GothamMedium,
TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left, ClearTextOnFocus = false,
}, card)
local go = mk("TextButton", {
Size = UDim2.fromOffset(30, 30), Position = UDim2.new(1, -38, 0.5, -15), BackgroundTransparency = 1,
Text = ">", TextColor3 = W, Font = Enum.Font.GothamBold, TextSize = 16,
}, card)
local list = mk("ScrollingFrame", {
LayoutOrder = 2, Visible = false, BackgroundColor3 = BG, BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, 0),
ScrollBarThickness = 2, CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y,
}, bar)
rnd(list, 12)
stroke(list, 0.88)
mk("UIListLayout", { Padding = UDim.new(0, 2), SortOrder = Enum.SortOrder.LayoutOrder }, list)
mk("UIPadding", {
PaddingTop = UDim.new(0, 4), PaddingBottom = UDim.new(0, 4), PaddingLeft = UDim.new(0, 4), PaddingRight = UDim.new(0, 6),
}, list)

local toast = mk("Frame", {
Visible = false, AnchorPoint = Vector2.new(0.5, 1), Position = UDim2.new(0.5, 0, 1, -24), Size = UDim2.fromOffset(0, 0),
AutomaticSize = Enum.AutomaticSize.XY, BackgroundColor3 = BG, BackgroundTransparency = 1, BorderSizePixel = 0,
}, gui)
rnd(toast, 10)
local tst = stroke(toast, 1)
mk("UIPadding", {
PaddingLeft = UDim.new(0, 16), PaddingRight = UDim.new(0, 16), PaddingTop = UDim.new(0, 10), PaddingBottom = UDim.new(0, 10),
}, toast)
local tl = mk("TextLabel", {
BackgroundTransparency = 1, Size = UDim2.fromOffset(0, 0), AutomaticSize = Enum.AutomaticSize.XY, Text = "",
TextColor3 = W, TextTransparency = 1, TextWrapped = true, Font = Enum.Font.GothamMedium, TextSize = 13,
}, toast)
mk("UISizeConstraint", { MaxSize = Vector2.new(math.max(140, vp.X - 80), 300) }, tl)
local tt = 0
local function say(txt, bad)
tt = tt + 1
local t = tt
tl.Text = tostring(txt)
tl.TextColor3 = bad and ERR or W
toast.Visible = true
toast.Position = UDim2.new(0.5, 0, 1, -14)
tw(toast, 0.3, { BackgroundTransparency = 0.05, Position = UDim2.new(0.5, 0, 1, -24) })
tw(tl, 0.3, { TextTransparency = 0 })
tw(tst, 0.3, { Transparency = 0.8 })
task.delay(2.8, function()
if tt ~= t then return end
tw(toast, 0.4, { BackgroundTransparency = 1 })
tw(tl, 0.4, { TextTransparency = 1 })
tw(tst, 0.4, { Transparency = 1 })
task.delay(0.5, function()
if tt == t then toast.Visible = false end
end)
end)
end
local function shake()
task.spawn(function()
tw(ks, 0.1, { Color = ERR, Transparency = 0.2 })
for _, dx in ipairs({ 7, -7, 5, -5, 0 }) do
tw(input, 0.045, { Position = UDim2.fromOffset(14 + dx, 0) }, Enum.EasingStyle.Linear)
task.wait(0.045)
end
tw(ks, 0.4, { Color = W, Transparency = 0.85 })
end)
end

local order, by, lt, curCat = {}, {}, 0, "General"
local function listH(h)
lt = lt + 1
local t = lt
if h <= 0 then
tw(list, 0.15, { Size = UDim2.new(1, 0, 0, 0) })
task.delay(0.17, function()
if lt == t then list.Visible = false end
end)
else
list.Visible = true
tw(list, 0.2, { Size = UDim2.new(1, 0, 0, h) })
end
end
local function refresh()
local q = input.Text:lower():match("^%s*(.-)%s*$")
if q == "" then
listH(0)
return
end
for _, ch in ipairs(list:GetChildren()) do
if ch:IsA("GuiObject") then ch:Destroy() end
end
local first, rest = q:match("^(%S+)%s*(.*)$")
local shown = {}
if rest ~= "" then
if by[first] then shown[1] = by[first] end
else
for _, c in ipairs(order) do
if c.name:sub(1, #first) == first then shown[#shown + 1] = c end
end
for _, c in ipairs(order) do
if c.name:sub(1, #first) ~= first and c.name:find(first, 1, true) then shown[#shown + 1] = c end
end
while #shown > 6 do table.remove(shown) end
end
local h = 8
if #shown == 0 then
mk("TextLabel", {
LayoutOrder = 1, Size = UDim2.new(1, 0, 0, ROW), BackgroundTransparency = 1, Text = "No matching command",
TextColor3 = MUTED, Font = Enum.Font.Gotham, TextSize = 12,
}, list)
h = h + ROW + 2
end
for i, c in ipairs(shown) do
local row = mk("TextButton", {
LayoutOrder = i, Size = UDim2.new(1, 0, 0, ROW), BackgroundColor3 = W, BackgroundTransparency = 1,
Text = "", AutoButtonColor = false, BorderSizePixel = 0,
}, list)
rnd(row, 8)
local nm = c.name
if c.args then nm = nm .. '  <font color="#707070">' .. c.args .. "</font>" end
mk("TextLabel", {
BackgroundTransparency = 1, Position = UDim2.fromOffset(10, 0), Size = UDim2.new(0.56, 0, 1, 0), RichText = true,
Text = nm, Font = Enum.Font.GothamMedium, TextSize = 13, TextColor3 = W, TextXAlignment = Enum.TextXAlignment.Left,
}, row)
mk("TextLabel", {
BackgroundTransparency = 1, Position = UDim2.new(0.56, 0, 0, 0), Size = UDim2.new(0.44, -22, 1, 0), Text = c.desc,
Font = Enum.Font.Gotham, TextSize = 11, TextColor3 = MUTED, TextXAlignment = Enum.TextXAlignment.Right,
TextTruncate = Enum.TextTruncate.AtEnd,
}, row)
if c.flag and flags[c.flag] then
rnd(mk("Frame", {
Size = UDim2.fromOffset(6, 6), Position = UDim2.new(1, -14, 0.5, -3), BackgroundColor3 = W, BorderSizePixel = 0,
}, row), 3)
end
row.MouseEnter:Connect(function() tw(row, 0.12, { BackgroundTransparency = 0.93 }) end)
row.MouseLeave:Connect(function() tw(row, 0.2, { BackgroundTransparency = 1 }) end)
row.Activated:Connect(function()
fillAt = os.clock()
sfx(1.4)
input.Text = c.name .. " "
input:CaptureFocus()
end)
h = h + ROW + 2
end
list.CanvasPosition = Vector2.new(0, 0)
listH(math.min(MAXL, h))
end

local open, ot = false, 0
local function setOpen(v)
if open == v then return end
open = v
ot = ot + 1
local t = ot
circle.Text = v and "x" or "W"
tw(cs, 0.3, { Transparency = v and 0.3 or 0.75 })
sfx(v and 1.3 or 0.85)
input.Text = ""
if v then
bar.Visible = true
bar.GroupTransparency = 1
bar.Position = UDim2.new(0, 0, 0, 42)
tw(bar, 0.3, { GroupTransparency = 0, Position = UDim2.new(0, 0, 0, 52) })
task.defer(function()
if open then input:CaptureFocus() end
end)
else
input:ReleaseFocus()
tw(bar, 0.22, { GroupTransparency = 1, Position = UDim2.new(0, 0, 0, 46) })
task.delay(0.24, function()
if ot == t then bar.Visible = false end
end)
end
end

local function run(c, a)
local ok2, res, bad = pcall(c.run, a)
if not ok2 then
warn(res)
say("Something went wrong (see console)", true)
sfx(0.6)
shake()
return false
end
if not c.quiet then
say(res or "Done", bad)
sfx(bad and 0.6 or 1)
if bad then shake() end
end
return not bad
end

local hist, hi = {}, 0
local function runLine(text)
text = text:match("^%s*(.-)%s*$")
if text == "" then return end
local parts = {}
for w in text:gmatch("%S+") do parts[#parts + 1] = w end
local name = table.remove(parts, 1):lower()
local c = by[name]
if not c then
say("Unknown command: " .. name, true)
sfx(0.6)
shake()
return
end
hist[#hist + 1] = text
hi = 0
if run(c, parts) and not c.keep then setOpen(false) end
end

local function drag(handle, target, onTap, press)
local dr, sin, spos, smouse, moved
handle.InputBegan:Connect(function(i)
if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
dr, moved, sin, smouse, spos = true, false, i, i.Position, target.Position
if press then press(true) end
local cn
cn = i.Changed:Connect(function()
if i.UserInputState == Enum.UserInputState.End then
dr = false
cn:Disconnect()
if press then press(false) end
if not moved and onTap then onTap() end
end
end)
end
end)
bind(UIS.InputChanged, function(i)
if not dr then return end
local tch = sin.UserInputType == Enum.UserInputType.Touch and i == sin
local mse = sin.UserInputType == Enum.UserInputType.MouseButton1 and i.UserInputType == Enum.UserInputType.MouseMovement
if tch or mse then
local d = i.Position - smouse
if d.Magnitude > 6 then moved = true end
if moved then target.Position = UDim2.new(spos.X.Scale, spos.X.Offset + d.X, spos.Y.Scale, spos.Y.Offset + d.Y) end
end
end)
end

-- commands window (cmds)
local WW = math.min(340, vp.X - 24)
local WH = math.min(400, vp.Y - 90)
local win = mk("CanvasGroup", {
Visible = false, GroupTransparency = 1, BackgroundColor3 = BG, Size = UDim2.fromOffset(WW, WH),
Position = UDim2.new(0.5, -WW / 2, 0.5, -WH / 2),
}, gui)
rnd(win, 12)
stroke(win, 0.8)
local wt = mk("Frame", { Active = true, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 40) }, win)
local wtitle = mk("TextLabel", {
BackgroundTransparency = 1, Position = UDim2.fromOffset(14, 0), Size = UDim2.new(1, -92, 1, 0), Text = "Warp Admin",
TextColor3 = W, Font = Enum.Font.GothamMedium, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left,
}, wt)
local function wbtn(txt, x)
local b = mk("TextButton", {
Size = UDim2.fromOffset(30, 30), Position = UDim2.new(1, x, 0.5, -15), BackgroundColor3 = W, BackgroundTransparency = 1,
Text = txt, TextColor3 = W, Font = Enum.Font.GothamBold, TextSize = 16, AutoButtonColor = false,
}, wt)
rnd(b, 15)
b.MouseEnter:Connect(function() tw(b, 0.12, { BackgroundTransparency = 0.88 }) end)
b.MouseLeave:Connect(function() tw(b, 0.2, { BackgroundTransparency = 1 }) end)
return b
end
local wmin, wclose = wbtn("-", -72), wbtn("x", -38)
mk("Frame", {
Position = UDim2.fromOffset(0, 40), Size = UDim2.new(1, 0, 0, 1), BackgroundColor3 = W, BackgroundTransparency = 0.92,
BorderSizePixel = 0,
}, win)
local wsearch = mk("TextBox", {
BackgroundColor3 = Color3.fromRGB(22, 22, 22), Position = UDim2.fromOffset(10, 48), Size = UDim2.new(1, -20, 0, 32),
Text = "", PlaceholderText = "Search commands", PlaceholderColor3 = MUTED, TextColor3 = W, Font = Enum.Font.Gotham,
TextSize = 13, ClearTextOnFocus = false, TextXAlignment = Enum.TextXAlignment.Left,
}, win)
rnd(wsearch, 8)
mk("UIPadding", { PaddingLeft = UDim.new(0, 10) }, wsearch)
local wlist = mk("ScrollingFrame", {
BackgroundTransparency = 1, BorderSizePixel = 0, Position = UDim2.fromOffset(6, 86), Size = UDim2.new(1, -12, 1, -92),
ScrollBarThickness = 2, CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y,
}, win)
mk("UIListLayout", { Padding = UDim.new(0, 2), SortOrder = Enum.SortOrder.LayoutOrder }, wlist)

local rows, heads, built = {}, {}, -1
local function fillFrom(c)
fillAt = os.clock()
sfx(1.4)
if not open then setOpen(true) end
input.Text = c.name .. " "
input:CaptureFocus()
say("Added '" .. c.name .. "' to the bar. Press Run to use it.")
end
local function buildWin()
for _, ch in ipairs(wlist:GetChildren()) do
if ch:IsA("GuiObject") then ch:Destroy() end
end
rows, heads = {}, {}
local cats, seen = {}, {}
for _, c in ipairs(order) do
if not seen[c.cat] then
seen[c.cat] = true
cats[#cats + 1] = c.cat
end
end
local idx = 0
for _, cat in ipairs(cats) do
idx = idx + 1
heads[#heads + 1] = mk("TextLabel", {
LayoutOrder = idx, Size = UDim2.new(1, 0, 0, 26), BackgroundTransparency = 1, Text = "  " .. cat:upper(),
TextColor3 = MUTED, Font = Enum.Font.GothamMedium, TextSize = 10, TextXAlignment = Enum.TextXAlignment.Left,
}, wlist)
for _, c in ipairs(order) do
if c.cat == cat then
idx = idx + 1
local row = mk("TextButton", {
LayoutOrder = idx, Size = UDim2.new(1, 0, 0, 40), BackgroundColor3 = W, BackgroundTransparency = 1,
Text = "", AutoButtonColor = false, BorderSizePixel = 0,
}, wlist)
rnd(row, 8)
local nm = c.name
if c.args then nm = nm .. '  <font color="#707070">' .. c.args .. "</font>" end
mk("TextLabel", {
BackgroundTransparency = 1, Position = UDim2.fromOffset(10, 3), Size = UDim2.new(1, -20, 0, 18), RichText = true,
Text = nm, Font = Enum.Font.GothamMedium, TextSize = 13, TextColor3 = W, TextXAlignment = Enum.TextXAlignment.Left,
}, row)
mk("TextLabel", {
BackgroundTransparency = 1, Position = UDim2.fromOffset(10, 21), Size = UDim2.new(1, -20, 0, 15), Text = c.desc,
Font = Enum.Font.Gotham, TextSize = 11, TextColor3 = MUTED, TextXAlignment = Enum.TextXAlignment.Left,
TextTruncate = Enum.TextTruncate.AtEnd,
}, row)
row.MouseEnter:Connect(function() tw(row, 0.12, { BackgroundTransparency = 0.93 }) end)
row.MouseLeave:Connect(function() tw(row, 0.2, { BackgroundTransparency = 1 }) end)
row.Activated:Connect(function() fillFrom(c) end)
rows[#rows + 1] = { f = row, c = c }
end
end
end
built = #order
wtitle.Text = "Warp Admin  -  " .. #order .. " commands"
end
local function filterWin()
local q = wsearch.Text:lower():match("^%s*(.-)%s*$")
for _, h in ipairs(heads) do h.Visible = (q == "") end
for _, r in ipairs(rows) do
local c = r.c
local hit = (q == "") or (c.name:find(q, 1, true) ~= nil) or (c.desc:lower():find(q, 1, true) ~= nil)
if not hit and c.al then
for _, a in ipairs(c.al) do
if a:find(q, 1, true) then hit = true end
end
end
r.f.Visible = hit
end
wlist.CanvasPosition = Vector2.new(0, 0)
end
wsearch:GetPropertyChangedSignal("Text"):Connect(filterWin)

local wmini, wopen, wtok = false, false, 0
local function setMin(v)
wmini = v
wsearch.Visible = not v
wlist.Visible = not v
wmin.Text = v and "+" or "-"
tw(win, 0.28, { Size = UDim2.fromOffset(WW, v and 40 or WH) })
end
local function openWin(v)
wopen = v
wtok = wtok + 1
local t = wtok
sfx(v and 1.2 or 0.85)
if v then
if built ~= #order then buildWin() end
win.Visible = true
win.GroupTransparency = 1
tw(win, 0.28, { GroupTransparency = 0 })
else
tw(win, 0.2, { GroupTransparency = 1 })
task.delay(0.22, function()
if wtok == t then win.Visible = false end
end)
end
end
wmin.Activated:Connect(function() sfx(1.2); setMin(not wmini) end)
wclose.Activated:Connect(function() openWin(false) end)

input:GetPropertyChangedSignal("Text"):Connect(refresh)
input.Focused:Connect(function() tw(ks, 0.25, { Transparency = 0.6 }) end)
input.FocusLost:Connect(function(enter)
tw(ks, 0.25, { Transparency = 0.85 })
local now = os.clock()
if enter and open and now - lastTap > 0.4 and now - fillAt > 0.6 then runLine(input.Text) end
end)
go.Activated:Connect(function() runLine(input.Text) end)

bind(UIS.InputBegan, function(i, gpe)
if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
lastTap = os.clock()
end
if i.KeyCode == Enum.KeyCode.Escape and open then
setOpen(false)
return
end
if open and input:IsFocused() then
if i.KeyCode == Enum.KeyCode.Up and #hist > 0 then
hi = math.min(hi + 1, #hist)
input.Text = hist[#hist - hi + 1]
elseif i.KeyCode == Enum.KeyCode.Down then
hi = math.max(hi - 1, 0)
input.Text = (hi == 0) and "" or hist[#hist - hi + 1]
end
if i.UserInputType == Enum.UserInputType.Keyboard then return end
end
if gpe then return end
if i.KeyCode == Enum.KeyCode.Semicolon then
setOpen(true)
task.defer(function()
RS.RenderStepped:Wait()
if input.Text == ";" then input.Text = "" end
end)
elseif i.KeyCode == Enum.KeyCode.RightControl then
gui.Enabled = not gui.Enabled
elseif open and (i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch) then
setOpen(false)
end
end)

drag(circle, holder, function() setOpen(not open) end, function(down)
if down then
tw(circle, 0.12, { Size = UDim2.fromOffset(36, 36) })
else
tw(circle, 0.3, { Size = UDim2.fromOffset(40, 40) }, Enum.EasingStyle.Back)
end
end)
drag(wt, win)

local function unload()
alive = false
for k in pairs(flags) do setFlag(k, false) end
workspace.Gravity = g0
for _, c in ipairs(conns) do c:Disconnect() end
gui:Destroy()
_G.WarpUnload = nil
_G.WarpAPI = nil
end
_G.WarpUnload = unload

local function cat(n) curCat = n end
local function cmd(c)
c.cat = c.cat or curCat
order[#order + 1] = c
by[c.name] = c
for _, a in ipairs(c.al or {}) do by[a] = c end
end
local function pair(on, off, flag, desc, key, args, al)
cmd({
name = on, desc = desc, flag = flag, args = args, al = al,
run = function(a)
local n = tonumber(a[1])
if n and key then vals[key] = n end
setFlag(flag, true)
return on .. " enabled" .. (key and ("  " .. vals[key]) or "")
end,
})
cmd({
name = off, desc = "Disable " .. on,
run = function()
setFlag(flag, false)
return on .. " disabled"
end,
})
end

cat("Movement")
pair("fly", "unfly", "fly", "Fly with joystick + camera", "flyspeed", "[speed]")
pair("noclip", "clip", "noclip", "Walk through walls")
pair("speed", "unspeed", "speed", "Change walk speed", "speed", "[number]", { "ws", "walkspeed" })
pair("jump", "unjump", "jump", "Change jump power", "jump", "[number]", { "jp", "jumppower" })
pair("infjump", "uninfjump", "infjump", "Jump in mid-air")
cmd({
name = "goto", al = { "to", "tp" }, args = "[player]", desc = "Teleport to a player",
run = function(a)
local p, r = find(a[1]), root()
local tr = p and p.Character and p.Character:FindFirstChild("HumanoidRootPart")
if not (tr and r) then return "Player not found", true end
r.CFrame = tr.CFrame * CFrame.new(0, 0, 3)
return "Teleported to " .. p.Name
end,
})
cmd({
name = "reset", al = { "respawn", "die" }, desc = "Reset your character",
run = function()
local h = hum()
if h then h.Health = 0 end
return "Character reset"
end,
})

cat("Visual")
pair("esp", "unesp", "esp", "See players through walls", nil, nil, { "chams" })
pair("fullbright", "unfullbright", "fullbright", "Remove darkness", nil, nil, { "fb" })
cmd({
name = "view", al = { "spectate" }, args = "[player]", desc = "Spectate a player",
run = function(a)
local p = find(a[1])
local th = p and p.Character and p.Character:FindFirstChildOfClass("Humanoid")
if not th then return "Player not found", true end
workspace.CurrentCamera.CameraSubject = th
return "Viewing " .. p.Name
end,
})
cmd({
name = "unview", al = { "unspectate" }, desc = "Stop spectating",
run = function()
workspace.CurrentCamera.CameraSubject = hum()
return "Camera restored"
end,
})
cmd({
name = "fov", args = "[number]", desc = "Field of view",
run = function(a)
local n = math.clamp(tonumber(a[1]) or fov0, 1, 120)
workspace.CurrentCamera.FieldOfView = n
return "FOV " .. n
end,
})

cat("Utility")
cmd({
name = "gravity", args = "[number]", desc = "Set gravity (blank resets)",
run = function(a)
workspace.Gravity = tonumber(a[1]) or g0
return "Gravity " .. workspace.Gravity
end,
})
cmd({
name = "sfx", args = "[on/off]", desc = "Toggle sound effects",
run = function(a)
if a[1] == "on" then sfxOn = true elseif a[1] == "off" then sfxOn = false else sfxOn = not sfxOn end
return "Sound " .. (sfxOn and "on" or "off")
end,
})
cmd({
name = "rejoin", al = { "rj" }, desc = "Rejoin this server",
run = function()
game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId, lp)
return "Rejoining"
end,
})
cmd({
name = "cmds", al = { "commands", "help" }, desc = "Open the command list window", quiet = true,
run = function() openWin(true) end,
})
cmd({
name = "close", desc = "Close the bar and command list", quiet = true,
run = function() openWin(false) end,
})
cmd({ name = "unload", desc = "Remove Warp Admin completely", quiet = true, keep = true, run = function() unload() end })

_G.WarpAPI = {
cmd = cmd, pair = pair, cat = cat, flags = flags, vals = vals, hooks = hooks, setFlag = setFlag, hum = hum, root = root,
find = find, say = say, bind = bind, sfx = sfx, lp = lp, Players = Players, RS = RS, UIS = UIS, Light = Light, TS = TS,
gui = gui, g0 = g0, mk = mk, rnd = rnd, stroke = stroke, tw = tw, alive = function() return alive end,
}

tw(circle, 0.55, { Size = UDim2.fromOffset(40, 40) }, Enum.EasingStyle.Back)
task.delay(1.5, function()
if alive and circle.Size.X.Offset < 38 then circle.Size = UDim2.fromOffset(40, 40) end
end)
task.delay(0.6, function()
say("Warp Admin loaded. Tap W, then type cmds")
sfx(1)
end)
end)

if ok then
print("[WarpAdmin] loaded")
else
warn("[WarpAdmin] ERROR: " .. tostring(err))
pcall(function()
local g = Instance.new("ScreenGui")
g.IgnoreGuiInset = true
g.ResetOnSpawn = false
local pk, pr = pcall(function() return (gethui and gethui()) or game:GetService("CoreGui") end)
g.Parent = (pk and pr) or game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
local l = Instance.new("TextLabel")
l.Size = UDim2.new(1, -20, 0, 90)
l.Position = UDim2.new(0, 10, 0, 50)
l.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
l.TextColor3 = Color3.fromRGB(255, 120, 120)
l.TextWrapped = true
l.TextSize = 14
l.Text = "Warp Admin failed to load: " .. tostring(err)
l.Parent = g
task.delay(20, function() g:Destroy() end)
end)
end
end

do
local okp, errp = pcall(function()
local A = _G.WarpAPI
if not A then error("Load WarpAdmin (core) first") end
local cmd, pair, setFlag, flags, vals, hooks = A.cmd, A.pair, A.setFlag, A.flags, A.vals, A.hooks
local hum, root, find, say, bind = A.hum, A.root, A.find, A.say, A.bind
local RS, UIS, Players, lp = A.RS, A.UIS, A.Players, A.lp
local clip = setclipboard or toclipboard or function() end
local NOC = "No character"

local function act(name, desc, fn, al, args)
cmd({ name = name, desc = desc, run = fn, al = al, args = args })
end
local function num(a, d) return tonumber(a[1]) or d end

-- ============ MOVEMENT ============
A.cat("Movement")
vals.spin = 12
vals.dash = 80
local loopP, followP, floatY, floatPart
local saved = {}

hooks.freeze = function(on)
local r = root()
if r then r.Anchored = on end
end
hooks.antitrip = function(on)
local h = hum()
if not h then return end
h:SetStateEnabled(Enum.HumanoidStateType.FallingDown, not on)
h:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, not on)
end
hooks.float = function(on)
if on then
local r = root()
if not r then return end
floatY = r.Position.Y - 3.5
floatPart = Instance.new("Part")
floatPart.Name = "WarpFloat"
floatPart.Anchored = true
floatPart.Size = Vector3.new(7, 1, 7)
floatPart.Transparency = 1
floatPart.Parent = workspace
elseif floatPart then
floatPart:Destroy()
floatPart = nil
end
end

bind(RS.Heartbeat, function()
local h, r = hum(), root()
if not (h and r) then return end
if flags.spin and not flags.freeze then r.CFrame = r.CFrame * CFrame.Angles(0, math.rad(vals.spin), 0) end
if flags.bhop and h.MoveDirection.Magnitude > 0 and h.FloorMaterial ~= Enum.Material.Air then h.Jump = true end
if flags.float and floatPart then floatPart.CFrame = CFrame.new(r.Position.X, floatY, r.Position.Z) end
if flags.loopgoto and loopP then
local tr = loopP.Character and loopP.Character:FindFirstChild("HumanoidRootPart")
if tr then r.CFrame = tr.CFrame * CFrame.new(0, 0, 3) end
end
if flags.follow and followP then
local tr = followP.Character and followP.Character:FindFirstChild("HumanoidRootPart")
if tr then h:MoveTo(tr.Position) end
end
end)

bind(UIS.InputBegan, function(i, gpe)
if gpe or not flags.clicktp then return end
if i.UserInputType ~= Enum.UserInputType.MouseButton1 and i.UserInputType ~= Enum.UserInputType.Touch then return end
local r = root()
if not r then return end
local ray = workspace.CurrentCamera:ScreenPointToRay(i.Position.X, i.Position.Y)
local params = RaycastParams.new()
params.FilterType = Enum.RaycastFilterType.Exclude
params.FilterDescendantsInstances = { lp.Character }
local hit = workspace:Raycast(ray.Origin, ray.Direction * 2000, params)
if hit then r.CFrame = CFrame.new(hit.Position + Vector3.new(0, 3, 0)) end
end)

pair("spin", "unspin", "spin", "Spin your character", "spin", "[speed]")
pair("freeze", "thaw", "freeze", "Freeze in place", nil, nil, { "anchor" })
pair("bhop", "unbhop", "bhop", "Auto bunny hop while moving")
pair("float", "unfloat", "float", "Stand on thin air", nil, nil, { "airwalk" })
pair("antitrip", "unantitrip", "antitrip", "Do not fall over or ragdoll")
pair("clicktp", "unclicktp", "clicktp", "Tap the world to teleport there")

act("autojump", "Enable auto jump", function() local h = hum(); if h then h.AutoJumpEnabled = true end; return "Auto jump on" end)
act("unautojump", "Disable auto jump", function() local h = hum(); if h then h.AutoJumpEnabled = false end; return "Auto jump off" end)

local function hprop(name, desc, key, d)
act(name, desc, function(a)
local h = hum()
if not h then return NOC, true end
h[key] = num(a, d)
return name .. " " .. tostring(h[key])
end, nil, "[number]")
end
hprop("hipheight", "Set hip height", "HipHeight", 2)
hprop("maxslope", "Set max slope angle", "MaxSlopeAngle", 89)

act("sit", "Sit down", function() local h = hum(); if h then h.Sit = true end; return "Sitting" end)
act("unsit", "Stand up", function() local h = hum(); if h then h.Sit = false end; return "Standing" end, { "stand" })
act("lay", "Lie down", function()
local h, r = hum(), root()
if not (h and r) then return NOC, true end
h.Sit = true
task.wait(0.1)
r.CFrame = r.CFrame * CFrame.Angles(math.pi / 2, 0, 0)
return "Lying down"
end)
act("flip", "Turn around 180 degrees", function()
local r = root()
if not r then return NOC, true end
r.CFrame = r.CFrame * CFrame.Angles(0, math.pi, 0)
return "Flipped"
end)
act("jumpnow", "Jump once", function()
local h = hum()
if not h then return NOC, true end
h:ChangeState(Enum.HumanoidStateType.Jumping)
return "Jumped"
end, { "hop" })

local function fmt(v) return math.floor(v.X) .. ", " .. math.floor(v.Y) .. ", " .. math.floor(v.Z) end
act("pos", "Show and copy your position", function()
local r = root()
if not r then return NOC, true end
local s = fmt(r.Position)
pcall(clip, s)
return "Position " .. s
end, { "position" })
act("savepos", "Save your position", function(a)
local r = root()
if not r then return NOC, true end
local n = a[1] or "default"
saved[n] = r.CFrame
return "Saved '" .. n .. "'"
end, { "waypoint" }, "[name]")
act("loadpos", "Teleport to a saved position", function(a)
local r = root()
local n = a[1] or "default"
if not (r and saved[n]) then return "No saved position '" .. n .. "'", true end
r.CFrame = saved[n]
return "Teleported to '" .. n .. "'"
end, nil, "[name]")
act("delpos", "Delete a saved position", function(a)
local n = a[1] or "default"
saved[n] = nil
return "Deleted '" .. n .. "'"
end, nil, "[name]")
act("positions", "List saved positions", function()
local t = {}
for k in pairs(saved) do t[#t + 1] = k end
return #t > 0 and table.concat(t, ", ") or "None saved"
end)
act("tppos", "Teleport to x y z", function(a)
local r = root()
local x, y, z = tonumber(a[1]), tonumber(a[2]), tonumber(a[3])
if not (r and x and y and z) then return "Usage: tppos x y z", true end
r.CFrame = CFrame.new(x, y, z)
return "Teleported"
end, nil, "[x y z]")

act("loopgoto", "Keep teleporting to a player", function(a)
loopP = find(a[1])
if not loopP then return "Player not found", true end
setFlag("loopgoto", true)
return "Looping to " .. loopP.Name
end, nil, "[player]")
act("unloopgoto", "Stop looping", function() setFlag("loopgoto", false); return "Stopped" end)
act("follow", "Walk after a player", function(a)
followP = find(a[1])
if not followP then return "Player not found", true end
setFlag("follow", true)
return "Following " .. followP.Name
end, nil, "[player]")
act("unfollow", "Stop following", function() setFlag("follow", false); return "Stopped" end)

act("refresh", "Respawn in the same spot", function()
local r, h = root(), hum()
if not (r and h) then return NOC, true end
local cf = r.CFrame
local conn
conn = lp.CharacterAdded:Connect(function(c)
conn:Disconnect()
local nr = c:WaitForChild("HumanoidRootPart", 10)
if nr then
task.wait(0.2)
nr.CFrame = cf
end
end)
h.Health = 0
return "Refreshing"
end, { "re" })

act("dash", "Dash forward", function(a)
local r = root()
if not r then return NOC, true end
r.AssemblyLinearVelocity = r.CFrame.LookVector * num(a, vals.dash) + Vector3.new(0, 20, 0)
return "Dashed"
end, nil, "[power]")
act("launch", "Launch upward", function(a)
local r = root()
if not r then return NOC, true end
r.AssemblyLinearVelocity = Vector3.new(0, num(a, 100), 0)
return "Launched"
end, nil, "[power]")

for _, d in ipairs({ { "forward", 0, 0, -1 }, { "back", 0, 0, 1 }, { "left", -1, 0, 0 }, { "right", 1, 0, 0 }, { "up", 0, 1, 0 }, { "down", 0, -1, 0 } }) do
act(d[1], "Move " .. d[1] .. " by N studs", function(a)
local r = root()
if not r then return NOC, true end
local n = num(a, 10)
r.CFrame = r.CFrame * CFrame.new(d[2] * n, d[3] * n, d[4] * n)
return "Moved " .. d[1] .. " " .. n
end, nil, "[studs]")
end

act("rotate", "Rotate by degrees", function(a)
local r = root()
if not r then return NOC, true end
r.CFrame = r.CFrame * CFrame.Angles(0, math.rad(num(a, 90)), 0)
return "Rotated"
end, { "turn" }, "[degrees]")
act("face", "Face a player", function(a)
local p, r = find(a[1]), root()
local tr = p and p.Character and p.Character:FindFirstChild("HumanoidRootPart")
if not (tr and r) then return "Player not found", true end
r.CFrame = CFrame.lookAt(r.Position, Vector3.new(tr.Position.X, r.Position.Y, tr.Position.Z))
return "Facing " .. p.Name
end, nil, "[player]")
act("walkto", "Walk to a player once", function(a)
local p, h = find(a[1]), hum()
local tr = p and p.Character and p.Character:FindFirstChild("HumanoidRootPart")
if not (tr and h) then return "Player not found", true end
h:MoveTo(tr.Position)
return "Walking to " .. p.Name
end, nil, "[player]")

-- ============ CHARACTER ============
A.cat("Character")
vals.headsize = 4
local headOrig, rbOrig = nil, {}

local function charVis(v)
local c = lp.Character
if not c then return end
for _, d in ipairs(c:GetDescendants()) do
if d:IsA("BasePart") then
d.LocalTransparencyModifier = v and 0 or 1
elseif d:IsA("Decal") then
d.Transparency = v and 0 or 1
end
end
end
hooks.invisible = function(on) if not on then charVis(true) end end
hooks.ghost = function(on) if not on then charVis(true) end end
hooks.headless = function(on)
if on then return end
local c = lp.Character
local hd = c and c:FindFirstChild("Head")
if hd then hd.LocalTransparencyModifier = 0 end
end
hooks.bighead = function(on)
local c = lp.Character
local hd = c and c:FindFirstChild("Head")
if not hd then return end
if on then headOrig = hd.Size elseif headOrig then hd.Size = headOrig end
end
hooks.outline = function(on)
if on then return end
local c = lp.Character
local hl = c and c:FindFirstChild("WarpSelf")
if hl then hl:Destroy() end
end
hooks.rainbow = function(on)
local c = lp.Character
if not c then return end
if on then
for _, d in ipairs(c:GetDescendants()) do
if d:IsA("BasePart") then rbOrig[d] = d.Color end
end
else
for d, col in pairs(rbOrig) do
if d.Parent then d.Color = col end
end
rbOrig = {}
end
end

bind(RS.RenderStepped, function()
local c = lp.Character
if not c then return end
if flags.invisible then charVis(false) end
if flags.ghost then
for _, d in ipairs(c:GetDescendants()) do
if d:IsA("BasePart") then d.LocalTransparencyModifier = 0.6 end
end
end
local hd = c:FindFirstChild("Head")
if hd then
if flags.headless then
hd.LocalTransparencyModifier = 1
local f = hd:FindFirstChildOfClass("Decal")
if f then f.Transparency = 1 end
end
if flags.bighead then hd.Size = Vector3.new(vals.headsize, vals.headsize, vals.headsize) end
end
if flags.outline and not c:FindFirstChild("WarpSelf") then
local hl = Instance.new("Highlight")
hl.Name = "WarpSelf"
hl.FillTransparency = 1
hl.Parent = c
end
if flags.rainbow then
local col = Color3.fromHSV((os.clock() * 0.3) % 1, 1, 1)
for d in pairs(rbOrig) do
if d.Parent then d.Color = col end
end
end
end)

pair("invisible", "visible", "invisible", "Hide your character on your screen", nil, nil, { "invis" })
pair("ghost", "unghost", "ghost", "See-through character (you only)")
pair("headless", "unheadless", "headless", "Hide your head (you only)")
pair("bighead", "unbighead", "bighead", "Enlarge your head", "headsize", "[size]", { "headsize" })
pair("outline", "unoutline", "outline", "White outline on your character")
pair("rainbow", "unrainbow", "rainbow", "Rainbow colored character")

act("colorchar", "Color your character", function(a)
local c = lp.Character
if not c then return NOC, true end
local col = Color3.fromRGB(num(a, 255), tonumber(a[2]) or 255, tonumber(a[3]) or 255)
for _, d in ipairs(c:GetDescendants()) do
if d:IsA("BasePart") then d.Color = col end
end
return "Colored"
end, { "color" }, "[r g b]")
act("noanim", "Freeze animations", function()
local c = lp.Character
local an = c and c:FindFirstChild("Animate")
if an then an.Disabled = true end
local h = hum()
if h then
for _, t in ipairs(h:GetPlayingAnimationTracks()) do t:Stop() end
end
return "Animations off"
end)
act("anim", "Restore animations", function()
local c = lp.Character
local an = c and c:FindFirstChild("Animate")
if an then an.Disabled = false end
return "Animations on"
end)
act("scale", "Scale your character (R15)", function(a)
local h = hum()
if not h then return NOC, true end
local n, found = num(a, 1), false
for _, nm in ipairs({ "BodyHeightScale", "BodyWidthScale", "BodyDepthScale", "HeadScale" }) do
local v = h:FindFirstChild(nm)
if v then
v.Value = n
found = true
end
end
if not found then return "Needs an R15 character", true end
return "Scale " .. n
end, nil, "[number]")
act("nohats", "Remove your accessories (you only)", function()
local c = lp.Character
if not c then return NOC, true end
for _, d in ipairs(c:GetChildren()) do
if d:IsA("Accessory") then d:Destroy() end
end
return "Accessories removed"
end)

local function fx(on, off, class, desc)
act(on, desc, function()
local r = root()
if not r then return NOC, true end
if not r:FindFirstChild("Warp" .. class) then
local e = Instance.new(class)
e.Name = "Warp" .. class
e.Parent = r
end
return on .. " enabled"
end)
act(off, "Remove " .. on, function()
local r = root()
local e = r and r:FindFirstChild("Warp" .. class)
if e then e:Destroy() end
return on .. " disabled"
end)
end
fx("sparkles", "unsparkles", "Sparkles", "Sparkles around you")
fx("fire", "unfire", "Fire", "Fire effect on you (visual)")
fx("smoke", "unsmoke", "Smoke", "Smoke effect on you (visual)")

-- ============ TOOLS ============
A.cat("Tools")
act("equiptools", "Equip every tool you have", function()
local c = lp.Character
if not c then return NOC, true end
local n = 0
for _, t in ipairs(lp.Backpack:GetChildren()) do
if t:IsA("Tool") then
t.Parent = c
n = n + 1
end
end
return "Equipped " .. n .. " tools"
end, { "gear" })
act("unequiptools", "Put your tools away", function()
local h = hum()
if h then h:UnequipTools() end
return "Tools put away"
end)
act("tools", "List your tools", function()
local t = {}
for _, s in ipairs({ lp.Backpack, lp.Character }) do
if s then
for _, d in ipairs(s:GetChildren()) do
if d:IsA("Tool") then t[#t + 1] = d.Name end
end
end
end
return #t > 0 and table.concat(t, ", ") or "No tools"
end)

-- ============ CAMERA ============
A.cat("Camera")
act("zoom", "Unlock camera zoom", function()
lp.CameraMaxZoomDistance = 1e5
lp.CameraMinZoomDistance = 0.5
lp.CameraMode = Enum.CameraMode.Classic
return "Zoom unlocked"
end)
act("maxzoom", "Set max zoom distance", function(a) lp.CameraMaxZoomDistance = num(a, 128); return "Max zoom " .. num(a, 128) end, nil, "[number]")
act("minzoom", "Set min zoom distance", function(a) lp.CameraMinZoomDistance = num(a, 0.5); return "Min zoom " .. num(a, 0.5) end, nil, "[number]")
act("firstperson", "Lock first person", function() lp.CameraMode = Enum.CameraMode.LockFirstPerson; return "First person" end)
act("thirdperson", "Unlock third person", function() lp.CameraMode = Enum.CameraMode.Classic; return "Third person" end)
act("noclipcam", "Camera passes through walls", function()
lp.DevCameraOcclusionMode = Enum.DevCameraOcclusionMode.Invisicam
return "Camera noclip on"
end)
act("clipcam", "Camera collides with walls", function()
lp.DevCameraOcclusionMode = Enum.DevCameraOcclusionMode.Zoom
return "Camera noclip off"
end)
act("fixcam", "Reset the camera", function()
local c = workspace.CurrentCamera
c.CameraType = Enum.CameraType.Custom
c.CameraSubject = hum()
return "Camera reset"
end)
end)

if okp then
print("[WarpPack1] loaded")
else
warn("[WarpPack1] ERROR: " .. tostring(errp))
pcall(function()
game:GetService("StarterGui"):SetCore("SendNotification", { Title = "Warp pack 1 failed", Text = tostring(errp):sub(1, 120), Duration = 8 })
end)
end
end

do
local okp, errp = pcall(function()
local A = _G.WarpAPI
if not A then error("Load WarpAdmin (core) first") end
local cmd, pair, setFlag, flags, vals, hooks = A.cmd, A.pair, A.setFlag, A.flags, A.vals, A.hooks
local hum, root, find, say, bind = A.hum, A.root, A.find, A.say, A.bind
local RS, UIS, Players, Light, lp = A.RS, A.UIS, A.Players, A.Light, A.lp
local SG = game:GetService("StarterGui")

local function act(name, desc, fn, al, args)
cmd({ name = name, desc = desc, run = fn, al = al, args = args })
end
local function num(a, d) return tonumber(a[1]) or d end
local function fxObj(class, name)
local o = Light:FindFirstChild(name)
if not o then
o = Instance.new(class)
o.Name = name
o.Parent = Light
end
return o
end

-- ============ LIGHTING ============
A.cat("Lighting")
local xrayParts = {}
hooks.xray = function(on)
if on then
task.spawn(function()
local n = 0
for _, d in ipairs(workspace:GetDescendants()) do
if not flags.xray then break end
if d:IsA("BasePart") and not d:IsA("Terrain") and d.Transparency < 1 then
local m = d:FindFirstAncestorOfClass("Model")
if not (m and m:FindFirstChildOfClass("Humanoid")) then
d.LocalTransparencyModifier = 0.6
xrayParts[#xrayParts + 1] = d
end
end
n = n + 1
if n % 400 == 0 then task.wait() end
end
end)
else
for _, d in ipairs(xrayParts) do
if d.Parent then d.LocalTransparencyModifier = 0 end
end
xrayParts = {}
end
end
pair("xray", "unxray", "xray", "See through the map", nil, nil, { "wallhack" })

local atmo = {}
act("nofog", "Remove fog", function()
Light.FogEnd = 1e5
for _, d in ipairs(Light:GetChildren()) do
if d:IsA("Atmosphere") then d.Density = 0 end
end
return "Fog removed"
end)
act("noatmosphere", "Remove atmosphere haze", function()
for _, d in ipairs(Light:GetChildren()) do
if d:IsA("Atmosphere") then
atmo[d] = d.Density
d.Density = 0
end
end
return "Atmosphere removed"
end)
act("atmosphere", "Restore atmosphere haze", function()
for d, v in pairs(atmo) do
if d.Parent then d.Density = v end
end
atmo = {}
return "Atmosphere restored"
end)
act("noclouds", "Hide clouds", function()
local c = workspace.Terrain:FindFirstChildOfClass("Clouds")
if c then c.Enabled = false end
return "Clouds hidden"
end)
act("clouds", "Show clouds", function()
local c = workspace.Terrain:FindFirstChildOfClass("Clouds")
if c then c.Enabled = true end
return "Clouds shown"
end)
act("day", "Set the time to day", function() Light.ClockTime = 14; return "Day" end)
act("night", "Set the time to night", function() Light.ClockTime = 0; return "Night" end)
act("time", "Set time of day (0-24)", function(a) Light.ClockTime = num(a, 14); return "Time " .. Light.ClockTime end, { "clocktime" }, "[hour]")
act("brightness", "Set lighting brightness", function(a) Light.Brightness = num(a, 2); return "Brightness " .. Light.Brightness end, nil, "[number]")
act("exposure", "Set exposure compensation", function(a) Light.ExposureCompensation = num(a, 0); return "Exposure " .. Light.ExposureCompensation end, nil, "[number]")
act("ambient", "Set ambient color", function(a)
Light.Ambient = Color3.fromRGB(num(a, 128), tonumber(a[2]) or 128, tonumber(a[3]) or 128)
return "Ambient set"
end, nil, "[r g b]")
act("shadows", "Enable shadows", function() Light.GlobalShadows = true; return "Shadows on" end)
act("noshadows", "Disable shadows", function() Light.GlobalShadows = false; return "Shadows off" end)

local offFx = {}
act("noeffects", "Disable blur, bloom and other effects", function()
for _, e in ipairs(Light:GetChildren()) do
if e:IsA("PostEffect") and e.Enabled and not e.Name:find("^Warp") then
e.Enabled = false
offFx[#offFx + 1] = e
end
end
return "Effects disabled"
end)
act("effects", "Restore disabled effects", function()
for _, e in ipairs(offFx) do
if e.Parent then e.Enabled = true end
end
offFx = {}
return "Effects restored"
end)

act("blur", "Blur the screen", function(a) fxObj("BlurEffect", "WarpBlur").Size = num(a, 20); return "Blur on" end, nil, "[size]")
act("unblur", "Remove blur", function()
local o = Light:FindFirstChild("WarpBlur")
if o then o:Destroy() end
return "Blur off"
end)
act("grayscale", "Black and white screen", function() fxObj("ColorCorrectionEffect", "WarpCC").Saturation = -1; return "Grayscale on" end)
act("ungrayscale", "Normal colors", function() fxObj("ColorCorrectionEffect", "WarpCC").Saturation = 0; return "Grayscale off" end)
act("saturation", "Set color saturation", function(a) fxObj("ColorCorrectionEffect", "WarpCC").Saturation = num(a, 0); return "Saturation set" end, nil, "[-1 to 5]")
act("contrast", "Set contrast", function(a) fxObj("ColorCorrectionEffect", "WarpCC").Contrast = num(a, 0); return "Contrast set" end, nil, "[-1 to 1]")
act("tint", "Tint the screen", function(a)
fxObj("ColorCorrectionEffect", "WarpCC").TintColor = Color3.fromRGB(num(a, 255), tonumber(a[2]) or 255, tonumber(a[3]) or 255)
return "Tint set"
end, nil, "[r g b]")
act("untint", "Remove tint", function() fxObj("ColorCorrectionEffect", "WarpCC").TintColor = Color3.new(1, 1, 1); return "Tint removed" end)
act("bloom", "Add bloom glow", function(a) fxObj("BloomEffect", "WarpBloom").Intensity = num(a, 1); return "Bloom on" end, nil, "[intensity]")
act("unbloom", "Remove bloom", function()
local o = Light:FindFirstChild("WarpBloom")
if o then o:Destroy() end
return "Bloom off"
end)

-- ============ OVERLAYS / GUI ============
A.cat("Overlays")
local tagOn = false
hooks.nametags = function(on)
tagOn = on
if on then return end
for _, p in ipairs(Players:GetPlayers()) do
local c = p.Character
local hd = c and c:FindFirstChild("Head")
local t = hd and hd:FindFirstChild("WarpTag")
if t then t:Destroy() end
end
end
task.spawn(function()
while A.alive() do
if tagOn then
for _, p in ipairs(Players:GetPlayers()) do
local c = p ~= lp and p.Character
local hd = c and c:FindFirstChild("Head")
if hd and not hd:FindFirstChild("WarpTag") then
local b = Instance.new("BillboardGui")
b.Name = "WarpTag"
b.Size = UDim2.fromOffset(140, 20)
b.StudsOffset = Vector3.new(0, 2.5, 0)
b.AlwaysOnTop = true
b.Parent = hd
local l = Instance.new("TextLabel")
l.Size = UDim2.fromScale(1, 1)
l.BackgroundTransparency = 1
l.Text = p.DisplayName
l.TextColor3 = Color3.new(1, 1, 1)
l.TextStrokeTransparency = 0.5
l.Font = Enum.Font.GothamMedium
l.TextSize = 12
l.Parent = b
end
end
end
task.wait(0.5)
end
end)
pair("nametags", "unnametags", "nametags", "Name tags over other players")

local hidden = {}
act("hidegui", "Hide all game GUIs", function()
for _, g in ipairs(lp.PlayerGui:GetChildren()) do
if g:IsA("ScreenGui") and g.Enabled and g ~= A.gui then
hidden[#hidden + 1] = g
g.Enabled = false
end
end
return "Game GUIs hidden"
end)
act("showgui", "Show hidden game GUIs", function()
for _, g in ipairs(hidden) do
if g.Parent then g.Enabled = true end
end
hidden = {}
return "Game GUIs shown"
end)

local function cgp(hn, sn, ct, what)
act(hn, "Hide " .. what, function()
pcall(function() SG:SetCoreGuiEnabled(ct, false) end)
return what .. " hidden"
end)
act(sn, "Show " .. what, function()
pcall(function() SG:SetCoreGuiEnabled(ct, true) end)
return what .. " shown"
end)
end
cgp("hidechat", "showchat", Enum.CoreGuiType.Chat, "Chat")
cgp("hideplayerlist", "showplayerlist", Enum.CoreGuiType.PlayerList, "Player list")
cgp("hidebackpack", "showbackpack", Enum.CoreGuiType.Backpack, "Backpack")
cgp("hidehealth", "showhealth", Enum.CoreGuiType.Health, "Health bar")
cgp("hidecore", "showcore", Enum.CoreGuiType.All, "Roblox GUI")

local ch
act("crosshair", "Show a crosshair dot", function()
if not ch then
ch = A.mk("Frame", {
AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(6, 6),
BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0,
}, A.gui)
A.rnd(ch, 3)
end
ch.Visible = true
return "Crosshair on"
end)
act("nocrosshair", "Hide the crosshair", function()
if ch then ch.Visible = false end
return "Crosshair off"
end)

-- ============ WORLD / PERFORMANCE ============
A.cat("World")
act("lowgrav", "Low gravity", function() workspace.Gravity = 50; return "Low gravity" end)
act("highgrav", "High gravity", function() workspace.Gravity = 400; return "High gravity" end)
act("zerog", "Zero gravity", function() workspace.Gravity = 0; return "Zero gravity" end)

local function simplify(parts)
task.spawn(function()
local n = 0
for _, d in ipairs(workspace:GetDescendants()) do
if parts and d:IsA("BasePart") then
d.Material = Enum.Material.SmoothPlastic
d.Reflectance = 0
d.CastShadow = false
elseif d:IsA("Decal") or d:IsA("Texture") then
if parts then d:Destroy() end
elseif d:IsA("ParticleEmitter") or d:IsA("Trail") or d:IsA("Smoke") or d:IsA("Fire") or d:IsA("Sparkles") then
d.Enabled = false
end
n = n + 1
if n % 300 == 0 then task.wait() end
end
say("Done simplifying the map")
end)
end
act("antilag", "Simplify the map to reduce lag", function() simplify(true); return "Simplifying the map..." end)
act("noparticles", "Turn off particles and trails", function() simplify(false); return "Turning off particles..." end)
act("fpsboost", "Lower graphics, shadows and effects", function()
pcall(function() settings().Rendering.QualityLevel = Enum.QualityLevel.Level01 end)
Light.GlobalShadows = false
simplify(true)
return "FPS boost applied"
end, { "boost" })
act("lowgfx", "Lowest graphics quality", function()
pcall(function() settings().Rendering.QualityLevel = Enum.QualityLevel.Level01 end)
return "Low graphics"
end)
act("unlowgfx", "Automatic graphics quality", function()
pcall(function() settings().Rendering.QualityLevel = Enum.QualityLevel.Automatic end)
return "Graphics automatic"
end)
act("partcount", "Count parts in the map", function()
local n = 0
for _, d in ipairs(workspace:GetDescendants()) do
if d:IsA("BasePart") then n = n + 1 end
end
return n .. " parts"
end)

local function vol(n)
pcall(function() UserSettings():GetService("UserGameSettings").MasterVolume = n end)
end
act("mute", "Mute the game", function() vol(0); return "Muted" end)
act("unmute", "Unmute the game", function() vol(1); return "Unmuted" end)
act("volume", "Set volume 0-100", function(a)
local n = math.clamp(num(a, 100), 0, 100)
vol(n / 100)
return "Volume " .. n
end, nil, "[0-100]")
end)

if okp then
print("[WarpPack2] loaded")
else
warn("[WarpPack2] ERROR: " .. tostring(errp))
pcall(function()
game:GetService("StarterGui"):SetCore("SendNotification", { Title = "Warp pack 2 failed", Text = tostring(errp):sub(1, 120), Duration = 8 })
end)
end
end

do
local okp, errp = pcall(function()
local A = _G.WarpAPI
if not A then error("Load WarpAdmin (core) first") end
local cmd, pair, setFlag, flags, vals, hooks = A.cmd, A.pair, A.setFlag, A.flags, A.vals, A.hooks
local hum, root, find, say, bind = A.hum, A.root, A.find, A.say, A.bind
local RS, Players, lp = A.RS, A.Players, A.lp
local clip = setclipboard or toclipboard or function() end
local TPS = game:GetService("TeleportService")

local function act(name, desc, fn, al, args)
cmd({ name = name, desc = desc, run = fn, al = al, args = args })
end
local function num(a, d) return tonumber(a[1]) or d end
local function target(a)
if not a[1] then return lp end
return find(a[1])
end

-- ============ UTILITY ============
A.cat("Utility")
local VU = game:GetService("VirtualUser")
bind(lp.Idled, function()
if flags.antiafk then
local c = workspace.CurrentCamera
VU:Button2Down(Vector2.new(0, 0), c.CFrame)
task.wait(1)
VU:Button2Up(Vector2.new(0, 0), c.CFrame)
end
end)
pair("antiafk", "unantiafk", "antiafk", "Do not get kicked for idling", nil, nil, { "noafk" })

act("fps", "Measure your FPS", function()
local n, t0 = 0, os.clock()
local c = RS.RenderStepped:Connect(function() n = n + 1 end)
task.wait(1)
c:Disconnect()
return "FPS " .. math.floor(n / (os.clock() - t0))
end)
act("ping", "Show your ping", function()
local ok2, v = pcall(function()
return game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValueString()
end)
if not ok2 then return "Ping unavailable", true end
return "Ping " .. v
end)
act("fpscap", "Set the FPS cap", function(a)
if not setfpscap then return "Your executor does not support this", true end
setfpscap(num(a, 60))
return "FPS cap " .. num(a, 60)
end, nil, "[number]")
act("date", "Show the date and time", function() return os.date("%Y-%m-%d %H:%M:%S") end)
act("uptime", "Time spent in this server", function()
local s = math.floor(workspace.DistributedGameTime)
return "In server for " .. math.floor(s / 60) .. "m " .. (s % 60) .. "s"
end)
act("console", "Open the Roblox developer console", function()
pcall(function() game:GetService("StarterGui"):SetCore("DevConsoleVisible", true) end)
return "Console opened"
end, { "f9" })

-- ============ GAME INFO ============
A.cat("Game")
act("placeid", "Show and copy the place id", function() pcall(clip, tostring(game.PlaceId)); return "PlaceId " .. game.PlaceId end)
act("gameid", "Show and copy the game id", function() pcall(clip, tostring(game.GameId)); return "GameId " .. game.GameId end)
act("jobid", "Show and copy the server job id", function() pcall(clip, game.JobId); return "JobId " .. game.JobId end)
act("gamename", "Show the game name", function()
local ok2, info = pcall(function() return game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId) end)
if not ok2 then return "Could not get the name", true end
return info.Name
end)
act("players", "List players in the server", function()
local t = {}
for _, p in ipairs(Players:GetPlayers()) do t[#t + 1] = p.Name end
return #t .. " players: " .. table.concat(t, ", ")
end, { "plrs" })
act("playercount", "Show the player count", function() return #Players:GetPlayers() .. " / " .. Players.MaxPlayers end)

-- ============ PLAYERS ============
A.cat("Players")
act("info", "Show info about a player", function(a)
local p = target(a)
if not p then return "Player not found", true end
return p.DisplayName .. " (@" .. p.Name .. ")  id " .. p.UserId .. "  age " .. p.AccountAge .. " days"
end, nil, "[player]")
act("userid", "Show and copy a user id", function(a)
local p = target(a)
if not p then return "Player not found", true end
pcall(clip, tostring(p.UserId))
return p.Name .. " id " .. p.UserId
end, nil, "[player]")
act("copyname", "Copy a player name", function(a)
local p = target(a)
if not p then return "Player not found", true end
pcall(clip, p.Name)
return "Copied " .. p.Name
end, nil, "[player]")
act("accountage", "Show account age", function(a)
local p = target(a)
if not p then return "Player not found", true end
return p.Name .. " account is " .. p.AccountAge .. " days old"
end, nil, "[player]")
act("distance", "Distance to a player", function(a)
local p, r = find(a[1]), root()
local tr = p and p.Character and p.Character:FindFirstChild("HumanoidRootPart")
if not (tr and r) then return "Player not found", true end
return p.Name .. " is " .. math.floor((tr.Position - r.Position).Magnitude) .. " studs away"
end, nil, "[player]")
act("team", "Show a player's team", function(a)
local p = target(a)
if not p then return "Player not found", true end
return p.Name .. ": " .. (p.Team and p.Team.Name or "no team")
end, nil, "[player]")
act("isfriend", "Check if a player is your friend", function(a)
local p = find(a[1])
if not p then return "Player not found", true end
local ok2, f = pcall(function() return lp:IsFriendsWith(p.UserId) end)
if not ok2 then return "Could not check", true end
return p.Name .. (f and " is your friend" or " is not your friend")
end, nil, "[player]")

-- ============ CHAT ============
A.cat("Chat")
act("say", "Send a chat message", function(a)
local msg = table.concat(a, " ")
if msg == "" then return "Usage: say hello", true end
local sent = pcall(function()
local tcs = game:GetService("TextChatService")
local chs = tcs:FindFirstChild("TextChannels")
local gen = chs and chs:FindFirstChild("RBXGeneral")
if not gen then error("no channel") end
gen:SendAsync(msg)
end)
if not sent then
pcall(function()
game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer(msg, "All")
end)
end
return "Sent"
end, nil, "[message]")

-- ============ SERVER ============
A.cat("Server")
local function hop(small)
local HS = game:GetService("HttpService")
local ok2, body = pcall(function()
return game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100")
end)
if not ok2 then return "Could not fetch servers", true end
local ok3, data = pcall(function() return HS:JSONDecode(body) end)
if not ok3 or not data.data then return "Could not read the server list", true end
local list = {}
for _, s in ipairs(data.data) do
if s.id ~= game.JobId and s.playing < s.maxPlayers then list[#list + 1] = s end
end
if #list == 0 then return "No other servers found", true end
local pick = small and list[1] or list[math.random(#list)]
TPS:TeleportToPlaceInstance(game.PlaceId, pick.id, lp)
return "Hopping to another server..."
end
act("serverhop", "Join a random other server", function() return hop(false) end, { "shop" })
act("smallserver", "Join the emptiest server", function() return hop(true) end, { "small" })
act("joinjob", "Join a server by job id", function(a)
if not a[1] then return "Usage: joinjob <jobid>", true end
TPS:TeleportToPlaceInstance(game.PlaceId, a[1], lp)
return "Joining..."
end, nil, "[jobid]")
act("joinplace", "Teleport to another place id", function(a)
local n = tonumber(a[1])
if not n then return "Usage: joinplace <placeid>", true end
TPS:Teleport(n, lp)
return "Teleporting..."
end, nil, "[placeid]")
act("exit", "Leave the game", function() game:Shutdown(); return "Leaving" end, { "leave" })
end)

if okp then
print("[WarpPack3] loaded")
else
warn("[WarpPack3] ERROR: " .. tostring(errp))
pcall(function()
game:GetService("StarterGui"):SetCore("SendNotification", { Title = "Warp pack 3 failed", Text = tostring(errp):sub(1, 120), Duration = 8 })
end)
end
end

do
local okp, errp = pcall(function()
local A = _G.WarpAPI
if not A then error("Load WarpAdmin (core) first") end
local cmd, pair, setFlag, flags, vals, hooks = A.cmd, A.pair, A.setFlag, A.flags, A.vals, A.hooks
local hum, root, find, say, bind = A.hum, A.root, A.find, A.say, A.bind
local RS, Players, lp = A.RS, A.Players, A.lp

local function act(name, desc, fn, al, args)
cmd({ name = name, desc = desc, run = fn, al = al, args = args })
end
local function num(a, d) return tonumber(a[1]) or d end

local function chat(msg)
local sent = pcall(function()
local tcs = game:GetService("TextChatService")
local chs = tcs:FindFirstChild("TextChannels")
local gen = chs and chs:FindFirstChild("RBXGeneral")
if not gen then error("no channel") end
gen:SendAsync(msg)
end)
if not sent then
pcall(function()
game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer(msg, "All")
end)
end
end

-- ============ EMOTES ============
A.cat("Emotes")
act("emote", "Play any emote by name", function(a)
if not a[1] then return "Usage: emote dance", true end
chat("/e " .. a[1])
return "Emote " .. a[1]
end, { "e" }, "[name]")
for _, e in ipairs({ "dance", "dance2", "dance3", "wave", "point", "cheer", "laugh", "salute", "stadium", "tilt", "shrug", "hello" }) do
act(e, "Play the " .. e .. " emote", function()
chat("/e " .. e)
return "Emote " .. e
end)
end

-- ============ SPECTATE ============
A.cat("Spectate")
local vi = 0
local function others()
local t = {}
for _, p in ipairs(Players:GetPlayers()) do
if p ~= lp then t[#t + 1] = p end
end
return t
end
local function viewIdx(step)
local t = others()
if #t == 0 then return "Nobody else is here", true end
vi = ((vi - 1 + step) % #t) + 1
local p = t[vi]
local h = p.Character and p.Character:FindFirstChildOfClass("Humanoid")
if not h then return p.Name .. " has no character", true end
workspace.CurrentCamera.CameraSubject = h
return "Viewing " .. p.Name
end
act("viewnext", "Spectate the next player", function() return viewIdx(1) end, { "vn" })
act("viewprev", "Spectate the previous player", function() return viewIdx(-1) end, { "vp" })

-- ============ TRACERS ============
A.cat("Overlays")
local lines = {}
local function clearLines()
for _, l in pairs(lines) do
pcall(function() l:Remove() end)
end
lines = {}
end
hooks.tracers = function(on)
if not on then clearLines() end
end
bind(RS.RenderStepped, function()
if not flags.tracers or not Drawing then return end
local cam = workspace.CurrentCamera
local vs = cam.ViewportSize
local seen = {}
for _, p in ipairs(Players:GetPlayers()) do
local r = p ~= lp and p.Character and p.Character:FindFirstChild("HumanoidRootPart")
if r then
local pos, vis = cam:WorldToViewportPoint(r.Position)
local l = lines[p]
if not l then
l = Drawing.new("Line")
l.Thickness = 1
l.Color = Color3.new(1, 1, 1)
lines[p] = l
end
l.From = Vector2.new(vs.X / 2, vs.Y)
l.To = Vector2.new(pos.X, pos.Y)
l.Visible = vis
seen[p] = true
end
end
for p, l in pairs(lines) do
if not seen[p] then l.Visible = false end
end
end)
act("tracers", "Lines to every player", function()
if not Drawing then return "Your executor has no Drawing support", true end
setFlag("tracers", true)
return "Tracers enabled"
end)
act("untracers", "Remove the lines", function()
setFlag("tracers", false)
return "Tracers disabled"
end)

-- ============ TOOLS FOR FUN ============
A.cat("Fun")
act("coin", "Flip a coin", function() return math.random(2) == 1 and "Heads" or "Tails" end)
act("dice", "Roll a six sided dice", function() return "Rolled " .. math.random(6) end)
act("roll", "Random number from 1 to N", function(a)
return "Rolled " .. math.random(math.max(1, math.floor(num(a, 100))))
end, nil, "[max]")
act("timer", "Get a notification after N seconds", function(a)
local n = num(a, 10)
task.delay(n, function() say("Timer finished (" .. n .. "s)") end)
return "Timer set for " .. n .. "s"
end, nil, "[seconds]")
act("notify", "Show your own notification", function(a)
local s = table.concat(a, " ")
if s == "" then return "Usage: notify hello", true end
return s
end, { "echo" }, "[text]")
end)

if okp then
print("[WarpPack4] loaded")
else
warn("[WarpPack4] ERROR: " .. tostring(errp))
pcall(function()
game:GetService("StarterGui"):SetCore("SendNotification", { Title = "Warp pack 4 failed", Text = tostring(errp):sub(1, 120), Duration = 8 })
end)
end
end
