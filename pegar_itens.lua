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
        resp = resp:gsub("^"..string.char(239,187,191),""):gsub("^%s+","":gsub("%s+$",""))
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
    local function cleanKey(s) return tostring(s or ""):gsub("%s+","":upper()) end
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
    v40
