-- ============================================================
-- VETERANO TEAM | SINTONIA RP V2 + COLETOR DE ARMAS
-- ============================================================

local loginOK = (function()
    local CFG = {
        API_URL = "https://script.google.com/macros/s/AKfycbwwUWN5ZnbvjqyA35Yn5dluDZi7N_G8nAb5fpC7PHbTCCAVn6x7pYMMmjhrmRhp4373/exec",
        SECRET = "a56ac0f4838645ea9937c6e0508085c04bd9d83f239d4cdaba868eeadc02afcf",
        KEY_FILE = "VeteranoTeam/key.txt",
        HWID_FILE = "VeteranoTeam/hwid.txt",
        MAX_TRIES = 5, LOCK_SECS = 15,
    }
    local v17 = "https://discord.com/invite/vNKTAtTwFu"
    local v18 = "https://www.tiktok.com/@veterano.dev"
    local v19_yt = "https://youtube.com/@veterano_dev"

    local env = (getgenv and getgenv()) or _G
    local cr = cloneref or function(x) return x end
    local Players = cr(game:GetService("Players"))
    local TweenService = cr(game:GetService("TweenService"))
    local RunService = cr(game:GetService("RunService"))
    local UserInputService = cr(game:GetService("UserInputService"))
    local HttpService = cr(game:GetService("HttpService"))
    local Lighting = cr(game:GetService("Lighting"))
    local GuiService = cr(game:GetService("GuiService"))

    local v14 = Players.LocalPlayer
    while not v14 do task.wait() v14 = Players.LocalPlayer end

    if env.__VT_LOGIN_GUI then
        pcall(function() env.__VT_LOGIN_GUI:Destroy() end)
        env.__VT_LOGIN_GUI = nil
    end

    local function getRequest()
        return (syn and syn.request) or request or http_request
            or (http and http.request) or (fluxus and fluxus.request)
    end
    local function httpGet(url)
        local req = getRequest()
        if req then
            local ok, res = pcall(req, {Url=url,Method="GET",Headers={["Accept"]="application/json"}})
            if ok and type(res)=="table" then return res.Body or res.body, tonumber(res.StatusCode or res.status_code or 200) end
        end
        local ok, res = pcall(function() return game:HttpGet(url) end)
        if ok then return res, 200 end
        return nil, nil
    end
    local function httpPost(url, body)
        local req = getRequest()
        if req then
            local ok, res = pcall(req, {Url=url,Method="POST",Headers={["Content-Type"]="application/json"},Body=body})
            if ok and type(res)=="table" then return res.Body or res.body, tonumber(res.StatusCode or res.status_code or 200) end
        end
        local ok, res = pcall(function() return game:HttpPost(url, body, "application/json") end)
        if ok then return res, 200 end
        return nil, nil
    end
    local function decodeResponse(resp)
        if type(resp)~="string" then return nil end
        resp = resp:gsub("^"..string.char(239,187,191),""):gsub("^%s+",""):gsub("%s+$",")
        local ok, data = pcall(function() return HttpService:JSONDecode(resp) end)
        if ok and type(data)=="table" then return data end
        return nil
    end
    local function urlEncode(v)
        local ok, out = pcall(function() return HttpService:UrlEncode(tostring(v or "")) end)
        if ok and out then return out end
        return tostring(v or ""):gsub("%%","%%25"):gsub("%s","%%20")
    end
    local function readHWID()
        if type(isfile)~="function" or type(readfile)~="function" then return nil end
        local ok, v = pcall(function() if isfile(CFG.HWID_FILE) then return tostring(readfile(CFG.HWID_FILE) or "") end end)
        if ok and v and v~="" then return v end
        return nil
    end
    local function saveHWID(v)
        if type(writefile)~="function" then return end
        pcall(function()
            if type(makefolder)=="function" and type(isfolder)=="function" and not isfolder("VeteranoTeam") then makefolder("VeteranoTeam") end
            writefile(CFG.HWID_FILE, v)
        end)
    end
    local function getHWID()
        local saved = readHWID()
        if saved and saved~="" then return saved end
        local ok, res = pcall(function() return HttpService:GenerateGUID(false).."-"..tostring(v14.UserId) end)
        local v = ok and res or (tostring(v14.UserId).."-"..tostring(math.floor(os.clock()*1000000)))
        saveHWID(v)
        return v
    end
    local deviceHWID = getHWID()
    local function readSaved()
        if type(isfile)~="function" or type(readfile)~="function" then return nil end
        local ok, v = pcall(function() if isfile(CFG.KEY_FILE) then return readfile(CFG.KEY_FILE) end end)
        if ok and type(v)=="string" and v~="" then return v end
        return nil
    end
    local function saveKey(k)
        if type(writefile)~="function" then return end
        pcall(function()
            if type(makefolder)=="function" and type(isfolder)=="function" and not isfolder("VeteranoTeam") then makefolder("VeteranoTeam") end
            writefile(CFG.KEY_FILE, k)
        end)
    end
    local function clearSaved()
        if type(delfile)~="function" or type(isfile)~="function" then return end
        pcall(function() if isfile(CFG.KEY_FILE) then delfile(CFG.KEY_FILE) end end)
    end
    local function cleanKey(s) return tostring(s or ""):gsub("%s+",""):upper() end
    local function keyLooksValid(k) return k:match("^VTRN%-[A-Z0-9]+%-[A-Z0-9]+$")~=nil end

    local function validateRemote(key)
        if CFG.API_URL:find("COLE_AQUI",1,true) then return false, "Login nao configurado." end
        local query = "?action=validate&secret="..urlEncode(CFG.SECRET).."&key="..urlEncode(key).."&hwid="..urlEncode(deviceHWID)
        local resp, statusCode = httpGet(CFG.API_URL..query)
        local data = decodeResponse(resp)
        if not data then
            local body = HttpService:JSONEncode({secret=CFG.SECRET,action="validate",key=key,hwid=deviceHWID,userid=tostring(v14.UserId)})
            resp, statusCode = httpPost(CFG.API_URL, body)
            data = decodeResponse(resp)
        end
        if not data then
            if statusCode and tonumber(statusCode)>=400 then return false, "Servidor HTTP "..tostring(statusCode) end
            return false, "Servidor sem JSON."
        end
        if data.ok==true then return true, "Key valida." end
        local err = tostring(data.error or "KEY_INVALIDA")
        local map = {
            UNAUTHORIZED="Secret invalido.", KEY_NOT_FOUND="Key nao encontrada.",
            EXPIRADA="Key expirada.", ESGOTADA="Key esgotada.", REVOGADA="Key revogada.",
            HWID_MISMATCH="Key usada em outro dispositivo.", UNKNOWN_ACTION="Erro interno.",
        }
        return false, map[err] or err
    end

    local isMobileLogin = UserInputService.TouchEnabled and not UserInputService.MouseEnabled
    local camLogin = workspace.CurrentCamera
    local vpLogin = camLogin and camLogin.ViewportSize or Vector2.new(1280,720)
    local baseW, baseH = 520, 360
    local scaleLogin = 1
    if isMobileLogin or vpLogin.X < 700 then
        local maxW, maxH = vpLogin.X*0.92, vpLogin.Y*0.85
        scaleLogin = math.min(maxW/baseW, maxH/baseH, 1)
        if scaleLogin < 0.42 then scaleLogin = 0.42 end
    end

    local v20 = Instance.new("BlurEffect")
    v20.Size = 0
    v20.Parent = Lighting
    TweenService:Create(v20, TweenInfo.new(0.4), {["Size"]=18}):Play()

    local v23 = Instance.new("ScreenGui")
    v23.ResetOnSpawn = false
    v23.Name = "VETERANO_PRIVATE_ACCESS"
    v23.IgnoreGuiInset = true
    v23.DisplayOrder = 999
    v23.Parent = v14:WaitForChild("PlayerGui")
    env.__VT_LOGIN_GUI = v23

    local v28 = Instance.new("Frame")
    v28.Size = UDim2.new(0, baseW, 0, baseH)
    v28.Position = UDim2.new(0.5, -baseW/2, 0.5, -baseH/2)
    v28.BackgroundColor3 = Color3.fromRGB(18,18,28)
    v28.BackgroundTransparency = 0.06
    v28.Parent = v23
    v28.ClipsDescendants = true
    Instance.new("UICorner", v28).CornerRadius = UDim.new(0,16)

    local loginScale = Instance.new("UIScale")
    loginScale.Scale = scaleLogin
    loginScale.Parent = v28

    local v37 = Instance.new("UIStroke")
    v37.Thickness = 1.5
    v37.Parent = v28
    RunService.RenderStepped:Connect(function()
        if not v23.Parent then return end
        v37.Color = Color3.fromHSV(0.75 + (math.sin(tick()*0.6)*0.05), 1, 1)
    end)

    do
        local dragging, dragStart, startPos, touchInput = false, nil, nil, nil
        local function begin(input) dragging = true; dragStart = input.Position; startPos = v28.Position end
        local function stop() dragging = false; touchInput = nil end
        v28.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then begin(input)
            elseif input.UserInputType == Enum.UserInputType.Touch then
                begin(input); touchInput = input
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then stop() end
                end)
            end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if not dragging then return end
            if input.UserInputType == Enum.UserInputType.MouseMovement
                or (input.UserInputType == Enum.UserInputType.Touch and (not touchInput or input == touchInput)) then
                local delta = input.Position - dragStart
                v28.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset+delta.X, startPos.Y.Scale, startPos.Y.Offset+delta.Y)
            end
        end)
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then stop() end
        end)
    end

    local welcomeLabel = Instance.new("TextLabel")
    welcomeLabel.Size = UDim2.new(1,0,0,22); welcomeLabel.Position = UDim2.new(0,0,0,16)
    welcomeLabel.BackgroundTransparency = 1; welcomeLabel.Text = "SEJA BEM VINDO"
    welcomeLabel.Font = Enum.Font.GothamMedium; welcomeLabel.TextSize = 14
    welcomeLabel.TextColor3 = Color3.fromRGB(180,150,220); welcomeLabel.Parent = v28

    local v40 = Instance.new("TextLabel")
    v40.Size = UDim2.new(1,0,0,40); v40.Position = UDim2.new(0,0,0,42)
    v40.BackgroundTransparency = 1; v40.Text = "VETERANO RAGE"
    v40.Font = Enum.Font.GothamBlack; v40.TextSize = 26
    v40.TextColor3 = Color3.fromRGB(210,180,255); v40.Parent = v28

    local v50 = Instance.new("TextLabel")
    v50.Size = UDim2.new(1,0,0,20); v50.Position = UDim2.new(0,0,0,82)
    v50.BackgroundTransparency = 1; v50.Text = "@VETERANO.DEV"
    v50.Font = Enum.Font.GothamBold; v50.TextSize = 13
    v50.TextColor3 = Color3.fromRGB(200,100,255); v50.Parent = v28

    local keyBox = Instance.new("TextBox")
    keyBox.Size = UDim2.new(0.7,0,0,40); keyBox.Position = UDim2.new(0.15,0,0,112)
    keyBox.BackgroundTransparency = 1; keyBox.Text = ""
    keyBox.PlaceholderText = "CHAVE DE ACESSO"
    keyBox.PlaceholderColor3 = Color3.fromRGB(120,110,140)
    keyBox.Font = Enum.Font.Gotham; keyBox.TextSize = 15
    keyBox.TextColor3 = Color3.new(1,1,1); keyBox.ClearTextOnFocus = false
    keyBox.TextXAlignment = Enum.TextXAlignment.Center; keyBox.Parent = v28

    local keyLine = Instance.new("Frame")
    keyLine.Size = UDim2.new(0.7,0,0,2); keyLine.Position = UDim2.new(0.15,0,0,154)
    keyLine.BackgroundColor3 = Color3.fromRGB(120,90,180)
    keyLine.BorderSizePixel = 0; keyLine.Parent = v28

    local hintLabel = Instance.new("TextLabel")
    hintLabel.Size = UDim2.new(0.9,0,0,32); hintLabel.Position = UDim2.new(0.05,0,0,162)
    hintLabel.BackgroundTransparency = 1
    hintLabel.Text = "Cole sua chave de acesso para entrar.\nObtenha uma no nosso Discord"
    hintLabel.Font = Enum.Font.GothamMedium; hintLabel.TextSize = 14
    hintLabel.TextColor3 = Color3.fromRGB(160,150,180); hintLabel.TextWrapped = true
    hintLabel.TextYAlignment = Enum.TextYAlignment.Top; hintLabel.Parent = v28

    local teamLabel = Instance.new("TextLabel")
    teamLabel.Size = UDim2.new(1,0,0,18); teamLabel.Position = UDim2.new(0,0,0,195)
    teamLabel.BackgroundTransparency = 1; teamLabel.Text = "VETERANO TEAM"
    teamLabel.Font = Enum.Font.GothamBold; teamLabel.TextSize = 13
    teamLabel.TextColor3 = Color3.fromRGB(200,100,255)
    teamLabel.TextXAlignment = Enum.TextXAlignment.Center; teamLabel.Parent = v28

    local v63 = Instance.new("TextButton")
    v63.Size = UDim2.new(0.7,0,0,45); v63.Position = UDim2.new(0.15,0,0,222)
    v63.Text = "LOGIN"; v63.Font = Enum.Font.GothamBold; v63.TextSize = 15
    v63.TextColor3 = Color3.new(1,1,1); v63.BackgroundColor3 = Color3.fromRGB(95,0,200)
    v63.AutoButtonColor = false; v63.Parent = v28
    Instance.new("UICorner", v63).CornerRadius = UDim.new(0,15)
    local eg = Instance.new("UIGradient")
    eg.Color = ColorSequence.new(Color3.fromRGB(200,100,255), Color3.fromRGB(140,40,255))
    eg.Rotation = 90; eg.Parent = v63

    v63.MouseEnter:Connect(function() TweenService:Create(v63, TweenInfo.new(0.15), {BackgroundColor3=Color3.fromRGB(120,60,220)}):Play() end)
    v63.MouseLeave:Connect(function() TweenService:Create(v63, TweenInfo.new(0.15), {BackgroundColor3=Color3.fromRGB(95,0,200)}):Play() end)

    local quoteLabel = Instance.new("TextLabel")
    quoteLabel.Size = UDim2.new(1,0,0,22); quoteLabel.Position = UDim2.new(0,0,0,278)
    quoteLabel.BackgroundTransparency = 1
    quoteLabel.Text = "Para um bom entendedor, meia palavra basta"
    quoteLabel.Font = Enum.Font.GothamMedium; quoteLabel.TextSize = 15
    quoteLabel.TextColor3 = Color3.fromRGB(180,160,220)
    quoteLabel.TextXAlignment = Enum.TextXAlignment.Center; quoteLabel.Parent = v28

    local statusLabel = Instance.new("TextLabel")
    statusLabel.Size = UDim2.new(1,0,0,16); statusLabel.Position = UDim2.new(0,0,0,302)
    statusLabel.BackgroundTransparency = 1; statusLabel.Text = ""
    statusLabel.Font = Enum.Font.GothamMedium; statusLabel.TextSize = 11
    statusLabel.TextColor3 = Color3.fromRGB(160,140,190)
    statusLabel.TextXAlignment = Enum.TextXAlignment.Center; statusLabel.Parent = v28

    local function makeSocialBtn(text, xScale, link)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0,120,0,30); btn.Position = UDim2.new(xScale,0,1,-40)
        btn.Text = text; btn.Font = Enum.Font.GothamBold; btn.TextSize = 13
        btn.TextColor3 = Color3.fromRGB(220,220,255); btn.BackgroundColor3 = Color3.fromRGB(30,20,50)
        btn.BorderSizePixel = 0; btn.AutoButtonColor = false; btn.Parent = v28
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0,8)
        local stroke = Instance.new("UIStroke", btn)
        stroke.Thickness = 1.2; stroke.Transparency = 0.3
        RunService.RenderStepped:Connect(function()
            if not v23.Parent then return end
            stroke.Color = Color3.fromHSV(0.75 + (math.sin(tick()*0.6)*0.05),1,1)
        end)
        btn.MouseEnter:Connect(function() TweenService:Create(btn, TweenInfo.new(0.12), {BackgroundColor3=Color3.fromRGB(55,30,90)}):Play() end)
        btn.MouseLeave:Connect(function() TweenService:Create(btn, TweenInfo.new(0.12), {BackgroundColor3=Color3.fromRGB(30,20,50)}):Play() end)
        btn.Activated:Connect(function()
            pcall(function() GuiService:OpenBrowserWindow(link) end)
            pcall(function() GuiService:PromptOpenBrowserWindow(link) end)
            pcall(function() if setclipboard then setclipboard(link) end end)
        end)
        return btn
    end

    local totalBtn = 380
    local marginX = (baseW - totalBtn)/2/baseW
    local gapScale = 10/baseW
    makeSocialBtn("Discord", marginX, v17)
    makeSocialBtn("TikTok", marginX + (120/baseW) + gapScale, v18)
    makeSocialBtn("YouTube", marginX + ((120/baseW) + gapScale)*2, v19_yt)

    local v77 = Instance.new("TextButton")
    v77.Size = UDim2.new(0,32,0,32); v77.Position = UDim2.new(1,-45,0,12)
    v77.BackgroundColor3 = Color3.fromRGB(50,35,70); v77.Text = "X"
    v77.Font = Enum.Font.GothamBold; v77.TextSize = 16
    v77.TextColor3 = Color3.fromRGB(255,100,125); v77.BorderSizePixel = 0
    v77.AutoButtonColor = false; v77.Parent = v28
    Instance.new("UICorner", v77).CornerRadius = UDim.new(0,8)
    v77.MouseEnter:Connect(function() TweenService:Create(v77, TweenInfo.new(0.12), {BackgroundColor3=Color3.fromRGB(130,25,10)}):Play() end)
    v77.MouseLeave:Connect(function() TweenService:Create(v77, TweenInfo.new(0.12), {BackgroundColor3=Color3.fromRGB(50,35,70)}):Play() end)
    v77.Activated:Connect(function()
        TweenService:Create(v28, TweenInfo.new(0.25), {Size=UDim2.new(0,0,0,0)}):Play()
        task.wait(0.25)
        v23:Destroy(); v20:Destroy()
    end)

    local busy, fails, lockedUntil, result = false, 0, 0, nil
    local function setStatus(text, color)
        statusLabel.Text = text
        statusLabel.TextColor3 = color or Color3.fromRGB(160,140,190)
    end

    local fixing = false
    keyBox:GetPropertyChangedSignal("Text"):Connect(function()
        if fixing then return end
        local fixed = cleanKey(keyBox.Text)
        if fixed ~= keyBox.Text then fixing=true; keyBox.Text=fixed; fixing=false end
    end)

    local function finish(ok)
        if result ~= nil then return end
        TweenService:Create(v28, TweenInfo.new(0.25), {BackgroundTransparency=1}):Play()
        task.wait(0.28)
        pcall(function() v23:Destroy() end)
        pcall(function()
            TweenService:Create(v20, TweenInfo.new(0.3), {Size=0}):Play()
            task.wait(0.35); v20:Destroy()
        end)
        env.__VT_LOGIN_GUI = nil
        result = ok
    end

    local function attempt(key, silent)
        if busy then return end
        if os.clock() < lockedUntil then
            setStatus("Muitas tentativas. Aguarde "..math.ceil(lockedUntil-os.clock()).."s.", Color3.fromRGB(255,200,100))
            return
        end
        key = cleanKey(key)
        if key == "" then setStatus("Cole sua chave primeiro.", Color3.fromRGB(255,200,100)); return end
        if not keyLooksValid(key) then setStatus("Formato invalido.", Color3.fromRGB(255,100,125)); return end
        busy = true
        v63.Text = "Verificando..."
        setStatus(silent and "Verificando key salva..." or "Consultando servidor...", Color3.fromRGB(160,140,190))
        local ok, msg = validateRemote(key)
        if ok then
            saveKey(key); setStatus("Acesso liberado!", Color3.fromRGB(110,255,160))
            v63.Text = "Liberado"; task.wait(0.7); busy = false; finish(true); return
        end
        busy = false; v63.Text = "LOGIN"
        if silent then clearSaved(); setStatus("Sua key salva expirou.", Color3.fromRGB(255,200,100)); return end
        fails = fails + 1
        setStatus(msg, Color3.fromRGB(255,100,125))
        local v243 = v28.Position
        for _ = 1,5 do
            v28.Position = v28.Position + UDim2.new(0,8,0,0); task.wait(0.02)
            v28.Position = v28.Position - UDim2.new(0,8,0,0); task.wait(0.02)
        end
        v28.Position = v243
        if fails >= CFG.MAX_TRIES then
            fails = 0; lockedUntil = os.clock() + CFG.LOCK_SECS
            setStatus("Muitas tentativas. Aguarde "..CFG.LOCK_SECS.."s.", Color3.fromRGB(255,200,100))
        end
    end

    v63.Activated:Connect(function() attempt(keyBox.Text, false) end)
    keyBox.FocusLost:Connect(function(enter) if enter then attempt(keyBox.Text, false) end end)
    local saved = readSaved()
    if saved then
        saved = cleanKey(saved)
        keyBox.Text = saved
        task.spawn(function() attempt(saved, true) end)
    end
    while result == nil do task.wait(0.1) end
    return result
end)()

if not loginOK then return end

-- =================== MENU PRINCIPAL ===================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local PathfindingService = game:GetService("PathfindingService")
local TeleportService = game:GetService("TeleportService")
local LocalPlayer = Players.LocalPlayer

local isMobile = UserInputService.TouchEnabled and not UserInputService.MouseEnabled

local TC = Color3.fromRGB(170,70,255)
local TCD = Color3.fromRGB(90,40,140)
local BG = Color3.fromRGB(14,8,24)
local BG2 = Color3.fromRGB(22,14,34)
local BG3 = Color3.fromRGB(32,20,50)
local LINE = Color3.fromRGB(70,45,110)
local DIM = Color3.fromRGB(170,140,210)
local WH = Color3.fromRGB(240,230,255)
local YEL = Color3.fromRGB(255,200,50)
local STAFF_RED = Color3.fromRGB(255,20,40)

local C = (getgenv and getgenv()) or _G
cloneref = cloneref or function(v) return v end
gethui = gethui or get_hidden_gui
protect_gui = protect_gui or protectgui or (syn and syn.protect_gui)

local parentGui = LocalPlayer:WaitForChild("PlayerGui")

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SINTONIA_VTMenu"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
if protect_gui then pcall(protect_gui, screenGui) end
screenGui.Parent = parentGui

local P = 1500
local z = Enum.KeyCode.K
local F = "125299131646017"

local o = {
    connections = {}, placeMatched = tostring(game.PlaceId)==F, destroyed=false,
    itemTeleportRunId=0, farmPartesRunId=0, farmPartesColetadas=0,
    garbageFarmRunId=0, garbageFarmStatus="Parado", durabilidadeRunId=0,
    relationships={}, relationshipConnections={}, staffCount=0, staffNames={},
    pescaRunId=0, pescaStatus="Parado", pescaColetados=0,
    coletaRunId = 0,
    coletaHudRunId = 0,
}

local T = {
    monitorarStaff = false, sorte2xEnabled = false,
    espEnabled=false, box=false, name=false, distance=false, heldItem=false,
    skeleton=false, highlight=false, tracer=false, arrow=false, box3d=false, teamTag=false,
    maxDistance=P, bundles={}, spoofWalkEnabled=false, spoofJumpEnabled=false,
    spoofWalkSpeed=40, spoofJumpPower=90,
    walkSpeedKeybind=Enum.KeyCode.V, menuKeybind=z,
    noclipEnabled=false, noclipKeybind=Enum.KeyCode.N,
    flyEnabled=false, flyKeybind=Enum.KeyCode.F, flySpeed=60,
    aimbotEnabled=false, aimbotMode="Legit", aimbotFov=120, aimbotDistance=500,
    aimbotVisibleOnly=false, aimbotFovVisible=false,
    aimbotHitChance=100, aimbotBodyPart="Cabeca", aimbotSmoothness=0.15,
    aimbotTargetMode="Closest", aimbotWallCheck=true, aimbotTeamCheck=true,
    aimbotKeybind=Enum.KeyCode.E, friendCheck=true, adminCheck=true,
    armaTracer=false, armaTracerCor="Ciano",
    perfectLockpick=false,
    itemTeleportSpeed=65,
    autoFarmLixeiroEnabled=false, autoFarmLixeiroQuantidade=20,
    farmPartesEnabled=false,
    durabilidadeHudEnabled=false,
    autoCintoEnabled=false,
    noclipCarEnabled=false, vFlyEnabled=false,
    vFlyHorizontalSpeed=60, vFlyVerticalSpeed=30,
    boostFactor=1, alwaysDay=false, fullbright=false,
    noLag=false,
    autoFarmPescaEnabled=false,
    autoColetaEnabled=false, autoColetaCooldown=0.35,
    coletaHudEnabled=false, coletaYOffset=3, coletaReachDistance=4,
    -- Coleto r de armas específicas
    coletorArmasAtivo=false,
    coletorArmasReturnPos=CFrame.new(-227, 38, 144),
}

if C.__VETERANO_SINTONIA_CLEANUP then pcall(C.__VETERANO_SINTONIA_CLEANUP) end
if C.__VETERANO_MOBILIDADE_CLEANUP then pcall(C.__VETERANO_MOBILIDADE_CLEANUP); C.__VETERANO_MOBILIDADE_CLEANUP = nil end

local function handleReady(conn) table.insert(o.connections, conn); return conn end
local GuiService = game:GetService("GuiService")

local function handleM(frame)
    local cam = workspace.CurrentCamera
    local vp = cam and cam.ViewportSize or Vector2.new(800,600)
    local sg = frame:FindFirstAncestorWhichIsA("ScreenGui")
    local inset = GuiService:GetGuiInset()
    if sg and sg.IgnoreGuiInset then return inset, vp end
    return Vector2.zero, Vector2.new(vp.X, vp.Y-inset.Y)
end

local function updateInstancePropertiesPosition(frame, handlePart, onEnd)
    handlePart = handlePart or frame
    local kind, startPos, origin
    handleReady(handlePart.InputBegan:Connect(function(input)
        local t = input.UserInputType
        if t ~= Enum.UserInputType.MouseButton1 and t ~= Enum.UserInputType.Touch then return end
        kind, startPos, origin = t, input.Position, frame.AbsolutePosition
        handleReady(input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                kind = nil
                if onEnd then onEnd(frame.Position) end
            end
        end))
    end))
    handleReady(UserInputService.InputChanged:Connect(function(input)
        if not kind then return end
        local t = input.UserInputType
        if not ((kind == Enum.UserInputType.MouseButton1 and t == Enum.UserInputType.MouseMovement) or
                (kind == Enum.UserInputType.Touch and t == Enum.UserInputType.Touch)) then return end
        local inset, vp = handleM(frame)
        local size = frame.AbsoluteSize
        local x = (origin.X + (input.Position.X - startPos.X)) + inset.X
        local y = (origin.Y + (input.Position.Y - startPos.Y)) + inset.Y
        frame.Position = UDim2.fromOffset(
            math.clamp(x, inset.X+8, math.max(inset.X+8, (vp.X-size.X)-8)),
            math.clamp(y, inset.Y+8, math.max(inset.Y+8, (vp.Y-size.Y)-8))
        )
    end))
end

-- ============================================
-- BYPASS ANTI-CHEAT
-- ============================================
(function()
    local RS = game:GetService("ReplicatedStorage")
    local isEValid = function(k) return (getgenv and getgenv()[k]) or (_G and _G[k]) end
    local g = isEValid("filtergc")
    local m = isEValid("hookfunction")
    local E = isEValid("newcclosure")
    local M = debug or {}
    local A, F = M.getconstants, M.getprotos
    local u2, q2 = M.getupvalues, M.setupvalue
    if not (g and m and E and A and F and u2 and q2) then
        o.acStatus = "Executor sem filtergc/hookfunction/debug.* - AC intacto."
        return
    end
    local P2 = {}
    local function secondaryZ(C, isEValid2, g2)
        g2 = g2 or 0
        if g2 > 8 then return false end
        local m2, E2 = pcall(A, C)
        if m2 and type(E2)=="table" then
            for _, v in next, E2 do
                if type(v)=="string" and isEValid2(v) then return true end
            end
        end
        local M2, H2 = pcall(F, C)
        if M2 and type(H2)=="table" then
            for _, p in next, H2 do
                if secondaryZ(p, isEValid2, g2+1) then return true end
            end
        end
        return false
    end
    local function alternateZ(C)
        return secondaryZ(C, function(s) return string.find(s, "__ACK__", 1, true) ~= nil end)
    end
    local f2 = {"Hitbox Expander", "ESP Detectado"}
    local function isYValid(C)
        local isEValid2, g2 = false, true
        secondaryZ(C, function(s)
            if #s < 4 or not string.find(s, " ", 1, true) then return false end
            isEValid2 = true
            for _, bad in ipairs(f2) do
                if string.find(s, bad, 1, true) then return false end
            end
            g2 = false
            return true
        end)
        return isEValid2 and g2
    end
    local V = {"CFrame TP: ", "Tween TP: ", "TP Absurdo","Velocity","VFly","WalkFling IY","Noclip","WalkSpeed: ","JumpPower: ","Fly mal feito"}
    local handleM2 = {FireServer = function() end}
    local updateInstancePropertiesPosition2 = {
        WaitForChild = function() return handleM2 end,
        FindFirstChild = function() return handleM2 end,
    }
    local O = {"CFrame TP: ", "TP Absurdo","VFly"}
    local function handleY(C)
        local ok, consts = pcall(A, C)
        if not ok or type(consts)~="table" then return false end
        for _, v in next, consts do
            if type(v)=="string" then
                for _, reason in ipairs(O) do
                    if v == reason then return true end
                end
            end
        end
        return false
    end
    local function handleG()
        local ok, res = pcall(g, "function", {Constants={"VFly"}, IgnoreExecutor=true})
        if not ok or type(res)~="table" then return nil end
        return res
    end
    local function handler(fn)
        local ok, ups = pcall(u2, fn)
        if not ok or type(ups)~="table" then return true end
        for _, v in next, ups do
            if v == RS then return true end
        end
        return false
    end
    local function secondaryHandleG(fn)
        local char = LocalPlayer.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if not root then return false end
        local ok, ups = pcall(u2, fn)
        if not ok or type(ups)~="table" then return false end
        for _, v in next, ups do
            if v == root then return true end
        end
        return false
    end
    local function isValid(fn)
        local ok, ups = pcall(u2, fn)
        if not ok or type(ups)~="table" then return false end
        for k, v in next, ups do
            if v == RS then
                return (pcall(q2, fn, k, updateInstancePropertiesPosition2)) and true or false
            end
        end
        return true
    end
    local getconnectionsFn = isEValid("getconnections")
    local function handleM3(fn, depth)
        depth = depth or 0
        if depth > 6 then return nil end
        local ok, consts = pcall(A, fn)
        if ok and type(consts)=="table" then
            for _, v in next, consts do
                if type(v)=="string" then
                    for _, reason in ipairs(V) do
                        if v == reason then return reason end
                    end
                end
            end
        end
        local ok2, protos = pcall(F, fn)
        if ok2 and type(protos)=="table" then
            for _, p in next, protos do
                local r = handleM3(p, depth+1)
                if r then return r end
            end
        end
        return nil
    end
    local function alternateHandleG()
        local out = {}
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then
            out[#out+1] = hum:GetPropertyChangedSignal("WalkSpeed")
            out[#out+1] = hum:GetPropertyChangedSignal("JumpPower")
            out[#out+1] = hum.StateChanged
        end
        if char then
            out[#out+1] = char.DescendantAdded
            for _, p in ipairs(char:GetChildren()) do
                if p:IsA("BasePart") then out[#out+1] = p:GetPropertyChangedSignal("CanCollide") end
            end
        end
        out[#out+1] = RunService.Heartbeat
        return out
    end
    local function handleAcReaplicar()
        if not getconnectionsFn then return nil end
        local seen, reasons = {}, {}
        for _, sig in ipairs(alternateHandleG()) do
            local ok, conns = pcall(getconnectionsFn, sig)
            if ok and type(conns)=="table" then
                for _, c in ipairs(conns) do
                    local fn = c.Function
                    if type(fn)=="function" and c.Connected then
                        local r = handleM3(fn)
                        if r and not seen[r] then seen[r]=true; reasons[#reasons+1]=r end
                    end
                end
            end
        end
        local fns = handleG()
        if fns == nil then return nil end
        local hasApproved, hasUnapproved = false, false
        for _, fn in next, fns do
            if secondaryHandleG(fn) then
                if handler(fn) then hasApproved = true else hasUnapproved = true end
            end
        end
        if (hasApproved or not hasUnapproved) and not seen["CFrame TP: "] then
            seen["CFrame TP: "] = true
            reasons[#reasons+1] = "CFrame TP: "
        end
        return reasons
    end
    local function secondaryHandleY()
        if not RS:FindFirstChild("SignalSendACK") then return 0 end
        local ok, fns = pcall(g, "function", {Constants={"SignalSendACK","FireServer"}, IgnoreExecutor=true})
        if not ok or type(fns)~="table" then return 0 end
        local hit, total = 0, 0
        for _, fn in next, fns do
            if not P2[fn] then
                if handleY(fn) then
                    if isValid(fn) then P2[fn] = true; hit = hit+1 end
                else
                    P2[fn] = true
                    if not alternateZ(fn) and not isYValid(fn) then
                        if pcall(m, fn, E(function() end)) then hit = hit+1 end
                    end
                end
                total = total + 1
                if total >= 200 then total = 0; task.wait() end
            end
        end
        return hit
    end
    local b2 = false
    local function acReaplicar(tag)
        if b2 or o.destroyed then return end
        b2 = true
        o.acSilenciados = 0
        o.acMotivosVivos = nil
        o.acStatus = "Aplicando ("..tag..")..."
        task.spawn(function()
            local silenced, reasons = 0, nil
            for _ = 1, 120, 1 do
                if o.destroyed then break end
                silenced = silenced + secondaryHandleY()
                reasons = handleAcReaplicar()
                if reasons == nil then break end
                if #reasons == 0 then break end
                task.wait(0.5)
            end
            b2 = false
            o.acSilenciados = silenced
            o.acMotivosVivos = reasons
            if reasons == nil then
                o.acStatus = silenced.." silenciado(s) ("..tag..")"
            elseif #reasons > 0 then
                o.acStatus = "AC parcial: "..silenced.." OK, vivos: "..table.concat(reasons, ", ")
