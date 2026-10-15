local SU="https://raw.githubusercontent.com/PulseZax/Slate/refs/heads/main/.lua"
local P=game:GetService("Players")local L=P.LocalPlayer local G=L:WaitForChild("PlayerGui")local R=game:GetService("RunService")local U=game:GetService("UserInputService")local C=workspace.CurrentCamera local V=Vector3.new local K=Color3.fromRGB local N=Instance.new
local SENHA="SouzaDev"
local S=loadstring(game:HttpGet(SU),"@Slate")()pcall(function()S.Cleanup()end)pcall(function()S:PreloadIcons({"lucide"})end)
local KW=S:CreateWindow({Name="SD MODS PVP",Subtitle="Autenticação",Icon="lock",Logo=true,Size=UDim2.fromOffset(400,220),ToggleKey=Enum.KeyCode.LeftControl})
pcall(function()S.Theme.Preset("Ash")end)pcall(function()S:SetFontFamily("JosefinSans")end)pcall(function()KW:SetBackdrop("aurora")end)
pcall(function()
local cc=KW.root:FindFirstChildOfClass("UICorner")if cc then cc.CornerRadius=UDim.new(0,6)end
local ss=KW.root:FindFirstChildOfClass("UIStroke")if ss then ss.Thickness=0 end
KW.root.Active=false
for _,dd in ipairs(KW.root:GetDescendants())do if dd:IsA("GuiObject")then dd.Active=false dd.Draggable=false end end
end)
local KT=KW:CreateTab({Name="Login",Icon="lock"})local KS=KT:CreateSection({Name="Digite a senha"})
local senhaOK=false
KS:Input({Name="Senha",Placeholder="Digite a senha...",Default="",Callback=function(v)
if v==SENHA then
senhaOK=true
S:Notify({Title="SD MODS PVP",Description="Key correta! Aproveite o script de combate",Icon="circle-check",Tone="Success",Duration=15})
task.wait(0.3)
S:Notify({Title="Aviso do Desenvolvedor",Description="Use essas funções moderadamente, tome cuidado com algumas funções",Icon="triangle-alert",Tone="Warning",Duration=15})
task.wait(0.4)
S:Notify({Title="Desenvolvedor",Description="SouzaDev01",Icon="user",Tone="Info",Duration=15})
task.wait(0.5)
KW:Destroy()
elseif v~=""then
S:Notify({Title="SD MODS PVP",Description="Senha incorreta!",Icon="circle-alert",Tone="Danger",Duration=3})
end
end})
S:Notify({Title="SD MODS PVP",Description="Digite a senha para continuar",Icon="lock",Tone="Info",Duration=5})
while not senhaOK do task.wait(0.1)end
task.wait(0.5)

-- ============================================
-- CONFIGURAÇÕES DO COLETOR DE ARMAS
-- ============================================
local RETURN_POSITION = CFrame.new(-227, 38, 144)
local SPEED_LIMIT = 16 -- Velocidade máxima segura
local SPOOF_WALKSPEED = 22 -- Velocidade para spoofar

-- Lista de armas permitidas
local ARMAS_PERMITIDAS = {
    -- 📂 Facil
    "AK47", "FAL", "Fuzil", "Glock", "Oitão", "Submetralhadora", "USPs", "Uzi",
    -- 📂 Media
    "Barret", "FuzilHollow", "FuzilPhantom", "FuzilTrovão", "G3", "PtDragon", "PtNeon", "PtNK",
    -- 📂 Limited
    "ArmaPDSecreta", "FuzilNinja", "FuzilPascoa", "Natalina", "PtNinja", "PtPascoa"
}

-- ============================================
-- ANTI-CHEAT BYPASS SYSTEM
-- ============================================
local AntiCheat = {
    active = false,
    blocked = false,
    lastCheck = 0,
    
    handleAcReaplicar = function()
        local reasons = {}
        if AntiCheat.active then
            if getgenv().AC_SILENCED == nil then
                getgenv().AC_SILENCED = true
                table.insert(reasons, "CFrame TP")
                table.insert(reasons, "VFly")
                table.insert(reasons, "Velocity")
            end
        end
        return reasons
    end,
    
    isUpdateInstancePropertiesEValid = function()
        local timeSinceCheck = os.clock() - AntiCheat.lastCheck
        AntiCheat.lastCheck = os.clock()
        return not AntiCheat.blocked
    end,
    
    acReaplicar = function(reason)
        if reason == "respawn" then
            task.wait(0.5)
            AntiCheat.active = true
            AntiCheat.blocked = false
            print("[Anti-Cheat] Reaplicado após respawn")
        end
    end,
    
    init = function()
        local reasons = AntiCheat.handleAcReaplicar()
        if #reasons == 0 then
            getgenv().AC_SILENCED = true
        end
        
        player.CharacterAdded:Connect(function()
            AntiCheat.acReaplicar("respawn")
        end)
        
        task.spawn(function()
            while task.wait(5) do
                local unblocked = AntiCheat.isUpdateInstancePropertiesEValid()
                if not unblocked then
                    AntiCheat.blocked = true
                    print("[Anti-Cheat] Detectado! Reduzindo velocidade...")
                else
                    AntiCheat.blocked = false
                end
            end
        end)
        
        print("[Anti-Cheat] Sistema inicializado")
    end
}

-- ============================================
-- MOVIMENTAÇÃO SEGURA
-- ============================================
local Movement = {
    moveTo = function(targetPos)
        local character = L.Character
        if not character then return false end
        
        local root = character:FindFirstChild("HumanoidRootPart")
        if not root then return false end
        
        local unblocked = AntiCheat.isUpdateInstancePropertiesEValid()
        local speed = unblocked and SPOOF_WALKSPEED or SPEED_LIMIT
        
        local direction = (targetPos - root.Position)
        local distance = direction.Magnitude
        direction = direction.Unit
        
        local step = math.min(speed, distance)
        root.CFrame = root.CFrame + (direction * step)
        root.AssemblyLinearVelocity = Vector3.zero
        
        return true
    end,
    
    teleportTo = function(targetCFrame)
        local character = L.Character
        if not character then return false end
        
        local root = character:FindFirstChild("HumanoidRootPart")
        if not root then return false end
        
        local unblocked = AntiCheat.isUpdateInstancePropertiesEValid()
        
        if unblocked then
            root.CFrame = targetCFrame
            root.AssemblyLinearVelocity = Vector3.zero
            root.AssemblyAngularVelocity = Vector3.zero
            return true
        else
            local current = root.CFrame
            local steps = 10
            for i = 1, steps do
                local alpha = i / steps
                root.CFrame = current:Lerp(targetCFrame, alpha)
                task.wait(0.05)
            end
            return true
        end
    end
}

-- ============================================
-- SISTEMA DE COLETA DE ARMAS
-- ============================================
local WeaponCollector = {
    status = "Pronto para coletar armas!",
    coletando = false,
    
    armaPermitida = function(nome)
        for _, arma in ipairs(ARMAS_PERMITIDAS) do
            if nome == arma then
                return true
            end
        end
        return false
    end,
    
    encontrarArmas = function()
        local armasEncontradas = {}
        
        local pastas = {"FarmPartesDeArma", "Armas", "ArmasDropadas", "DropadosInv", "Drops", "ItensDropados"}
        
        for _, pastaNome in ipairs(pastas) do
            local pasta = workspace:FindFirstChild(pastaNome)
            if pasta then
                for _, item in ipairs(pasta:GetChildren()) do
                    if WeaponCollector.armaPermitida(item.Name) then
                        table.insert(armasEncontradas, item)
                    end
                end
            end
        end
        
        for _, item in ipairs(workspace:GetDescendants()) do
            if item:IsA("Tool") and WeaponCollector.armaPermitida(item.Name) then
                local isOwned = false
                if L.Character and item:IsDescendantOf(L.Character) then
                    isOwned = true
                end
                local backpack = L:FindFirstChild("Backpack")
                if backpack and item:IsDescendantOf(backpack) then
                    isOwned = true
                end
                if not isOwned then
                    table.insert(armasEncontradas, item)
                end
            end
        end
        
        return armasEncontradas
    end,
    
    teleportarParaArma = function(arma)
        local character = L.Character
        if not character then return false end
        
        local root = character:FindFirstChild("HumanoidRootPart")
        if not root then return false end
        
        local parte = arma
        if arma:IsA("Model") then
            parte = arma.PrimaryPart or arma:FindFirstChildWhichIsA("BasePart")
        end
        
        if not parte then return false end
        
        return Movement.teleportTo(CFrame.new(parte.Position + Vector3.new(0, 3, 0)))
    end,
    
    pegarArma = function(arma)
        local prompt = arma:FindFirstChildOfClass("ProximityPrompt")
        if prompt then
            fireproximityprompt(prompt)
            return true
        end
        
        if arma:IsA("Tool") then
            local character = L.Character
            if character then
                local humanoid = character:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    arma.Parent = L.Backpack
                    return true
                end
            end
        end
        
        return false
    end,
    
    voltarParaPosicao = function()
        task.wait(1)
        local character = L.Character
        if character then
            local root = character:FindFirstChild("HumanoidRootPart")
            if root then
                Movement.teleportTo(RETURN_POSITION)
                print("Voltou para posição!")
                return true
            end
        end
        return false
    end,
    
    coletarArmas = function()
        if WeaponCollector.coletando then
            WeaponCollector.status = "Já está coletando!"
            return
        end
        
        WeaponCollector.coletando = true
        WeaponCollector.status = "Procurando armas permitidas..."
        
        local armas = WeaponCollector.encontrarArmas()
        local coletadas = 0
        
        if #armas == 0 then
            WeaponCollector.status = "Nenhuma arma permitida encontrada no mapa."
            print("Nenhuma arma permitida encontrada!")
            WeaponCollector.coletando = false
            return
        end
        
        WeaponCollector.status = "Encontradas " .. #armas .. " armas!\nColetando..."
        
        for _, arma in ipairs(armas) do
            if WeaponCollector.teleportarParaArma(arma) then
                if WeaponCollector.pegarArma(arma) then
                    coletadas = coletadas + 1
                    WeaponCollector.status = "Coletada: " .. arma.Name .. "\nTotal: " .. coletadas
                    print("Coletada: " .. arma.Name)
                    task.wait(0.5)
                end
            end
        end
        
        WeaponCollector.status = "Coletadas " .. coletadas .. " armas!\nVoltando para posição..."
        WeaponCollector.voltarParaPosicao()
        WeaponCollector.status = "Coleta finalizada!\nArmas coletadas: " .. coletadas
        print("Coleta finalizada! Armas coletadas: " .. coletadas)
        WeaponCollector.coletando = false
    end,
    
    testarColeta = function(nomeArma)
        if WeaponCollector.coletando then return end
        
        WeaponCollector.coletando = true
        for _, item in ipairs(workspace:GetDescendants()) do
            if item:IsA("Tool") and item.Name == nomeArma then
                WeaponCollector.status = nomeArma .. " encontrada! Coletando..."
                WeaponCollector.teleportarParaArma(item)
                task.wait(0.5)
                WeaponCollector.pegarArma(item)
                WeaponCollector.voltarParaPosicao()
                WeaponCollector.status = nomeArma .. " coletada e voltou!"
                WeaponCollector.coletando = false
                return true
            end
        end
        WeaponCollector.status = nomeArma .. " não encontrada no mapa!"
        WeaponCollector.coletando = false
        return false
    end,
    
    mostrarLista = function()
        local lista = "Armas Permitidas:\n\n📂 Facil:\n"
        for _, arma in ipairs({"AK47", "FAL", "Fuzil", "Glock", "Oitão", "Submetralhadora", "USPs", "Uzi"}) do
            lista = lista .. "• " .. arma .. "\n"
        end
        lista = lista .. "\n📂 Media:\n"
        for _, arma in ipairs({"Barret", "FuzilHollow", "FuzilPhantom", "FuzilTrovão", "G3", "PtDragon", "PtNeon", "PtNK"}) do
            lista = lista .. "• " .. arma .. "\n"
        end
        lista = lista .. "\n📂 Limited:\n"
        for _, arma in ipairs({"ArmaPDSecreta", "FuzilNinja", "FuzilPascoa", "Natalina", "PtNinja", "PtPascoa"}) do
            lista = lista .. "• " .. arma .. "\n"
        end
        return lista
    end
}

-- ============================================
-- VARIÁVEIS DO COMBATE (do script original)
-- ============================================
local a,b,c=false,"Head","Sempre Ativo"local d,e,f,g=false,false,"Head",4 local h,i=500,300 local j="Inimigos"local k,l,m,n,o,p,q=false,false,false,false,false,false,false
local EE,FF,GG={},{},{}local HH={}

-- ============================================
-- GUI PRINCIPAL (Slate UI)
-- ============================================
local W=S:CreateWindow({Name="KS Fluxo PVP + Coletor",Subtitle="Combate & Coleta",Icon="zap",Logo=true,Size=UDim2.fromOffset(450,420),ToggleKey=Enum.KeyCode.LeftControl})
pcall(function()S.Theme.Preset("Ash")end)pcall(function()S:SetFontFamily("JosefinSans")end)pcall(function()W:SetBackdrop("aurora")end)
pcall(function()local cc=W.root:FindFirstChildOfClass("UICorner")if cc then cc.CornerRadius=UDim.new(0,6)end local ss=W.root:FindFirstChildOfClass("UIStroke")if ss then ss.Thickness=0 end W.root.Active=false for _,dd in ipairs(W.root:GetDescendants())do if dd:IsA("GuiObject")then dd.Active=false dd.Draggable=false end end end)
task.delay(0.6,function()
pcall(function()
for _,gg in ipairs(G:GetChildren())do
if gg:IsA("ScreenGui")and gg.Name~="KSFOV"then
for _,dd in ipairs(gg:GetDescendants())do
if dd:IsA("GuiButton")or dd:IsA("Frame")then dd.Draggable=false end
end
end
end
end)
end)
local lN=0
local function NTF(msg)
local nn=tick()
if nn-lN<0.25 then return end
lN=nn
pcall(function()
S:Notify({Title="SD MODS PVP",Description=msg,Icon="circle-check",Tone="Success",Duration=3})
end)
end
local IG=N("ImageLabel")IG.Name="BG"IG.Parent=W.root IG.BackgroundTransparency=1 IG.BorderSizePixel=0 IG.Size=UDim2.new(1,0,1,0)IG.Position=UDim2.new(0,0,0,0)IG.ZIndex=0 IG.ImageTransparency=0.35 IG.ScaleType=Enum.ScaleType.Crop IG.Visible=false
pcall(function()local cc=N("UICorner")cc.CornerRadius=UDim.new(0,6)cc.Parent=IG end)pcall(function()for _,dd in ipairs(W.root:GetChildren())do if dd~=IG and dd:IsA("GuiObject")then dd.ZIndex=(dd.ZIndex or 1)+1 end end end)
task.wait(0.1)pcall(function()for _,dd in ipairs(W.root:GetDescendants())do if dd:IsA("GuiObject")then HH[dd]={Bg=dd.BackgroundColor3,BgT=dd.BackgroundTransparency,Tx=(dd:IsA("TextLabel")or dd:IsA("TextButton"))and dd.TextColor3 or nil,Im=(dd:IsA("ImageLabel")or dd:IsA("ImageButton"))and dd.ImageColor3 or nil}end end end)
local function AC(x)pcall(function()if x=="Normal"then for oo,dd in pairs(HH)do if oo and oo.Parent then if dd.Bg then oo.BackgroundColor3=dd.Bg end if dd.BgT then oo.BackgroundTransparency=dd.BgT end if dd.Tx and(oo:IsA("TextLabel")or oo:IsA("TextButton"))then oo.TextColor3=dd.Tx end if dd.Im and(oo:IsA("ImageLabel")or oo:IsA("ImageButton"))then oo.ImageColor3=dd.Im end end end return end local mc,tc if x=="Preto"then mc=K(20,20,20)tc=K(255,255,255)elseif x=="Azul"then mc=K(20,60,120)tc=K(255,255,255)elseif x=="Vermelho"then mc=K(120,20,20)tc=K(255,255,255)elseif x=="Branco"then mc=K(230,230,230)tc=K(20,20,20)elseif x=="Rosa"then mc=K(200,80,150)tc=K(255,255,255)end for oo,dd in pairs(HH)do if oo and oo.Parent then if(oo:IsA("Frame")or oo:IsA("TextButton")or oo:IsA("ImageButton"))and oo.BackgroundTransparency<0.9 then oo.BackgroundColor3=mc end if oo:IsA("TextLabel")or oo:IsA("TextButton")then oo.TextColor3=tc end end end if W.root.BackgroundColor3 then W.root.BackgroundColor3=mc end end)end

-- ============================================
-- TABS E SEÇÕES
-- ============================================
local TC=W:CreateTab({Name="Combate",Icon="crosshair"})
local TV=W:CreateTab({Name="Visuals",Icon="eye"})
local TCO=W:CreateTab({Name="Coletor",Icon="package"})
local TA=W:CreateTab({Name="Ajustes",Icon="settings"})

-- ============================================
-- TAB COMBATE
-- ============================================
local A1=TC:CreateSection({Name="Aimbot"})
A1:Toggle({Name="Aimbot",Default=false,Callback=function(v)a=v NTF("A função Aimbot foi "..(v and "ativada" or "desativada").." com sucesso")end})
A1:Dropdown({Name="Parte Mira",Options={"Head","Chest"},Default="Head",Callback=function(v)b=v NTF("A função Parte Mira foi alterada para "..v)end})
A1:Dropdown({Name="Modo",Options={"Sempre Ativo","Botao Direito"},Default="Sempre Ativo",Callback=function(v)c=v NTF("A função Modo foi alterada para "..v)end})
A1:Toggle({Name="Previsao",Default=false,Callback=function(v)d=v NTF("A função Previsao foi "..(v and "ativada" or "desativada").." com sucesso")end})
A1:Slider({Name="FOV",Min=100,Max=700,Default=300,Callback=function(v)i=v end})
A1:Slider({Name="Distancia",Min=50,Max=1500,Default=500,Callback=function(v)h=v end})

local A2=TC:CreateSection({Name="Hitbox"})
A2:Toggle({Name="Expandir Hitbox",Default=false,Callback=function(v)e=v NTF("A função Expandir Hitbox foi "..(v and "ativada" or "desativada").." com sucesso")end})
A2:Dropdown({Name="Parte",Options={"Head","Chest"},Default="Head",Callback=function(v)f=v NTF("A função Parte foi alterada para "..v)end})
A2:Slider({Name="Tamanho",Min=2,Max=30,Default=4,Callback=function(v)g=v end})

-- ============================================
-- TAB VISUAIS
-- ============================================
local A3=TV:CreateSection({Name="ESP"})
A3:Dropdown({Name="Alvo",Options={"Inimigos","Amigos","Ambos"},Default="Inimigos",Callback=function(v)j=v NTF("A função Alvo foi alterada para "..v)end})
A3:Toggle({Name="Cabeca Rosa",Default=false,Callback=function(v)k=v NTF("A função Cabeca Rosa foi "..(v and "ativada" or "desativada").." com sucesso")end})
A3:Toggle({Name="Esqueleto Rosa",Default=false,Callback=function(v)l=v NTF("A função Esqueleto Rosa foi "..(v and "ativada" or "desativada").." com sucesso")end})
A3:Toggle({Name="Box V/R",Default=false,Callback=function(v)m=v NTF("A função Box V/R foi "..(v and "ativada" or "desativada").." com sucesso")end})
A3:Toggle({Name="Linha V/R",Default=false,Callback=function(v)n=v NTF("A função Linha V/R foi "..(v and "ativada" or "desativada").." com sucesso")end})
A3:Toggle({Name="Nome RGB",Default=false,Callback=function(v)o=v NTF("A função Nome RGB foi "..(v and "ativada" or "desativada").." com sucesso")end})
A3:Toggle({Name="Vida RGB",Default=false,Callback=function(v)p=v NTF("A função Vida RGB foi "..(v and "ativada" or "desativada").." com sucesso")end})
A3:Toggle({Name="Arma RGB",Default=false,Callback=function(v)q=v NTF("A função Arma RGB foi "..(v and "ativada" or "desativada").." com sucesso")end})

-- ============================================
-- TAB COLETOR DE ARMAS
-- ============================================
local A4=TCO:CreateSection({Name="Coletor de Armas"})
A4:Toggle({Name="Status",Default=false,Callback=function(v)NTF("Sistema de coleta "..(v and "ativado" or "desativado"))end})
A4:Button({Name="Coletar Armas Permitidas",Callback=function()
    WeaponCollector.coletarArmas()
    NTF(WeaponCollector.status)
end})
A4:Button({Name="Ver Lista de Armas",Callback=function()
    local lista = WeaponCollector.mostrarLista()
    NTF("Lista de armas atualizada!")
    print(lista)
end})
A4:Button({Name="Voltar para Posição",Callback=function()
    WeaponCollector.voltarParaPosicao()
    NTF("Voltou para posição!")
end})
A4:Button({Name="Testar Coleta (AK47)",Callback=function()
    WeaponCollector.testarColeta("AK47")
    NTF(WeaponCollector.status)
end})

-- ============================================
-- TAB AJUSTES
-- ============================================
local A8=TA:CreateSection({Name="Fundo do Menu"})
A8:Dropdown({Name="Imagem",Options={"Nenhuma","6421296789","5252447892"},Default="Nenhuma",Callback=function(v)if v=="Nenhuma"then IG.Visible=false else IG.Image="rbxassetid://"..v IG.Visible=true end NTF("A função Imagem foi alterada para "..v)end})
A8:Slider({Name="Transparencia",Min=0,Max=100,Default=35,Callback=function(v)IG.ImageTransparency=v/100 end})

local A9=TA:CreateSection({Name="Cor da Interface"})
A9:Dropdown({Name="Cor",Options={"Normal","Preto","Azul","Vermelho","Branco","Rosa"},Default="Normal",Callback=function(v)AC(v)NTF("A função Cor foi alterada para "..v)end})

-- ============================================
-- SISTEMA DE FOV (do script original)
-- ============================================
local FG=N("ScreenGui")FG.Name="KSFOV"FG.ResetOnSpawn=false FG.Parent=G local FV=N("Frame")FV.AnchorPoint=Vector2.new(0.5,0.5)FV.BackgroundTransparency=1 FV.Position=UDim2.new(0.5,0,0.5,0)FV.Size=UDim2.new(0,i*2,0,i*2)FV.Visible=false FV.Parent=FG
local FC=N("UICorner")FC.CornerRadius=UDim.new(1,0)FC.Parent=FV local FS=N("UIStroke")FS.Color=K(0,170,255)FS.Thickness=1.5 FS.Parent=FV

-- ============================================
-- FUNÇÕES DE COMBATE (do script original)
-- ============================================
local BN3={{"Head","UpperTorso"},{"UpperTorso","LeftUpperArm"},{"LeftUpperArm","LeftLowerArm"},{"LeftLowerArm","LeftHand"},{"UpperTorso","RightUpperArm"},{"RightUpperArm","RightLowerArm"},{"RightLowerArm","RightHand"},{"UpperTorso","LeftUpperLeg"},{"LeftUpperLeg","LeftLowerLeg"},{"LeftLowerLeg","LeftFoot"},{"UpperTorso","RightUpperLeg"},{"RightUpperLeg","RightLowerLeg"},{"RightLowerLeg","RightFoot"}}
local function gC(c)return c:FindFirstChild("UpperTorso")or c:FindFirstChild("Torso")end
local function gP(c,s)if s=="Head"then return c:FindFirstChild("Head")end return gC(c)end
local function vis(c)local hd=c:FindFirstChild("Head")if not hd then return false end local oo=C.CFrame.Position local dd=hd.Position-oo local rp=RaycastParams.new()rp.FilterType=Enum.RaycastFilterType.Exclude rp.FilterDescendantsInstances={L.Character,C}rp.IgnoreWater=true local rr=workspace:Raycast(oo,dd,rp)if rr and rr.Instance then return rr.Instance:IsDescendantOf(c)end return false end
local function rgb()return Color3.fromHSV((tick()*0.5)%1,1,1)end
local function nD(t,p)local ok,oo=pcall(function()return Drawing.new(t)end)if not ok or not oo then return nil end for kk,vv in pairs(p or{})do oo[kk]=vv end return oo end
local function mC(c)local cc={hC=nD("Circle",{Radius=20,Thickness=2,Color=K(255,105,180),Filled=false,Transparency=1,Visible=false}),ln=nD("Line",{Thickness=2,Color=K(255,255,255),Transparency=1,Visible=false}),sk={}}for ii=1,#BN3 do cc.sk[ii]=nD("Line",{Thickness=1.5,Color=K(255,105,180),Transparency=1,Visible=false})end return cc end
local function dC(cc)if not cc then return end if cc.hC and cc.hC.Remove then cc.hC:Remove()end if cc.ln and cc.ln.Remove then cc.ln:Remove()end for _,ll in ipairs(cc.sk or{})do if ll and ll.Remove then ll:Remove()end end if cc.hl then cc.hl:Destroy()end if cc.nB then cc.nB:Destroy()end if cc.hB then cc.hB:Destroy()end if cc.wB then cc.wB:Destroy()end end
local function eB(cc,ky,c,oy)if cc[ky]and cc[ky].Parent then return cc[ky]end local bb=N("BillboardGui")bb.Name="K_"..ky bb.Size=UDim2.new(0,200,0,20)bb.StudsOffset=V(0,oy,0)bb.AlwaysOnTop=true bb.Adornee=c:FindFirstChild("Head")or c:FindFirstChild("HumanoidRootPart")bb.Parent=c local lbl=N("TextLabel")lbl.Name="InfoText"lbl.Size=UDim2.new(1,0,1,0)lbl.BackgroundTransparency=1 lbl.Font=Enum.Font.GothamBold lbl.TextSize=13 lbl.TextStrokeTransparency=0 lbl.TextColor3=K(255,255,255)lbl.Parent=bb cc[ky]=bb return bb end
local function rH(c)if not FF[c]then return end for n2,dd in pairs(FF[c])do local pt=c:FindFirstChild(n2)if pt and pt:IsA("BasePart")then pt.Size=dd.S pt.Transparency=dd.T pt.CanCollide=dd.C pt.Massless=dd.M pcall(function()pt.CustomPhysicalProperties=dd.CP end)end end FF[c]=nil GG[c]=nil end
local function gT()local cl,sd=nil,i local mp=Vector2.new(C.ViewportSize.X/2,C.ViewportSize.Y/2)local mc=L.Character if not mc then return nil end local mr=mc:FindFirstChild("HumanoidRootPart")if not mr then return nil end for _,pl in ipairs(P:GetPlayers())do if pl~=L and pl.Character then local rp=pl.Character:FindFirstChild("HumanoidRootPart")local hm=pl.Character:FindFirstChildOfClass("Humanoid")local ap=gP(pl.Character,b)if rp and hm and ap then local ok=true if hm.Health<=0 then ok=false end if pl.Team==L.Team and pl.Team~=nil then ok=false end if(rp.Position-mr.Position).Magnitude>h then ok=false end if ok then local sp,os=C:WorldToViewportPoint(ap.Position)if os then local dd=(Vector2.new(sp.X,sp.Y)-mp).Magnitude if dd<sd then sd=dd cl=pl end end end end end end return cl end

-- ============================================
-- LOOP PRINCIPAL (RenderStepped)
-- ============================================
R.RenderStepped:Connect(function()
local mc=L.Character local mr=mc and mc:FindFirstChild("HumanoidRootPart")
FV.Visible=a FV.Size=UDim2.new(0,i*2,0,i*2)
local ca=false if a then if c=="Sempre Ativo"then ca=true elseif c=="Botao Direito"and U:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)then ca=true end end
if ca and mc then local tg=gT()if tg and tg.Character then local ap=gP(tg.Character,b)local tr=tg.Character:FindFirstChild("HumanoidRootPart")if ap and tr then local tp=ap.Position if d then tp=tp+(tr.AssemblyLinearVelocity*0.14)end C.CFrame=CFrame.new(C.CFrame.Position,tp)end end end
local ac={}
for _,pl in ipairs(P:GetPlayers())do if pl~=L then local c=pl.Character if c then ac[c]=true local hm=c:FindFirstChildOfClass("Humanoid")local rp=c:FindFirstChild("HumanoidRootPart")local hd=c:FindFirstChild("Head")local ok=true if hm and hm.Health<=0 then ok=false end if pl.Team==L.Team and pl.Team~=nil then ok=false end if mr and rp and(rp.Position-mr.Position).Magnitude>h then ok=false end
if e and ok then local pt=gP(c,f)if pt and pt:IsA("BasePart")then if GG[c]and GG[c]~=pt.Name then local op=c:FindFirstChild(GG[c])if op and op:IsA("BasePart")and FF[c]and FF[c][op.Name]then local dd=FF[c][op.Name]op.Size=dd.S op.Transparency=dd.T op.CanCollide=dd.C op.Massless=dd.M pcall(function()op.CustomPhysicalProperties=dd.CP end)FF[c][op.Name]=nil end end GG[c]=pt.Name if not FF[c]then FF[c]={}end if not FF[c][pt.Name]then FF[c][pt.Name]={S=pt.Size,T=pt.Transparency,C=pt.CanCollide,M=pt.Massless,CP=pt.CustomPhysicalProperties}end pcall(function()pt.CustomPhysicalProperties=nil end)pt.Massless=true pt.CanCollide=false pt.Size=V(g,g,g)pt.Transparency=0.6 end else rH(c)end
local ax=k or l or q or m or n or o or p local sh=false
if ax and ok then local st=(pl.Team==L.Team)and(pl.Team~=nil)if j=="Inimigos"then sh=not st elseif j=="Amigos"then sh=st else sh=true end end
local cc=EE[c]
if not sh then if cc then if cc.hC then cc.hC.Visible=false end if cc.ln then cc.ln.Visible=false end for _,ll in ipairs(cc.sk or{})do ll.Visible=false end if cc.hl then cc.hl.Enabled=false end if cc.nB then cc.nB.Enabled=false end if cc.hB then cc.hB.Enabled=false end if cc.wB then cc.wB.Enabled=false end end
else if not cc then cc=mC(c)EE[c]=cc end local vs=vis(c)
if cc.hC and hd then local sp,os=C:WorldToViewportPoint(hd.Position)if os and k then local ds=(C.CFrame.Position-hd.Position).Magnitude cc.hC.Position=Vector2.new(sp.X,sp.Y)cc.hC.Radius=math.clamp(2000/ds,4,40)cc.hC.Color=K(255,105,180)cc.hC.Visible=true else cc.hC.Visible=false end end
if cc.sk and#cc.sk>0 then for ii,pr in ipairs(BN3)do local ll=cc.sk[ii]local p1,p2=c:FindFirstChild(pr[1]),c:FindFirstChild(pr[2])if ll then if l and p1 and p2 then local s1,o1=C:WorldToViewportPoint(p1.Position)local s2,o2=C:WorldToViewportPoint(p2.Position)if o1 and o2 then ll.From=Vector2.new(s1.X,s1.Y)ll.To=Vector2.new(s2.X,s2.Y)ll.Color=K(255,105,180)ll.Visible=true else ll.Visible=false end else ll.Visible=false end end end end
if cc.ln then if n and hd then local sp,os=C:WorldToViewportPoint(hd.Position)if os then cc.ln.From=Vector2.new(C.ViewportSize.X/2,C.ViewportSize.Y)cc.ln.To=Vector2.new(sp.X,sp.Y)cc.ln.Color=vs and K(0,255,0)or K(255,0,0)cc.ln.Visible=true else cc.ln.Visible=false end else cc.ln.Visible=false end end
if m then if not cc.hl then local hh=N("Highlight")hh.Name="KH"hh.Adornee=c hh.FillTransparency=0.7 hh.OutlineTransparency=0 hh.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop hh.Parent=c cc.hl=hh end cc.hl.Enabled=true local co=vs and K(0,255,0)or K(255,0,0)cc.hl.OutlineColor=co cc.hl.FillColor=co elseif cc.hl then cc.hl.Enabled=false end
if o then local bb=eB(cc,"nB",c,3.2)bb.Enabled=true local lbl=bb:FindFirstChild("InfoText")if lbl then lbl.Text=pl.Name lbl.TextColor3=rgb()end elseif cc.nB then cc.nB.Enabled=false end
if p and hm then local bb=eB(cc,"hB",c,2.6)bb.Enabled=true local lbl=bb:FindFirstChild("InfoText")if lbl then local hp=math.clamp(math.floor(hm.Health),0,math.floor(hm.MaxHealth))lbl.Text="Vida: "..hp.." / "..math.floor(hm.MaxHealth)lbl.TextColor3=rgb()end elseif cc.hB then cc.hB.Enabled=false end
if q then local tl=c:FindFirstChildOfClass("Tool")local bb=eB(cc,"wB",c,4.0)bb.Enabled=true local lbl=bb:FindFirstChild("InfoText")if lbl then if tl then lbl.Text=tl.Name lbl.TextColor3=rgb()else lbl.Text=""end end elseif cc.wB then cc.wB.Enabled=false end
end end end end
for c,cc in pairs(EE)do if not ac[c]or not c.Parent then dC(cc)EE[c]=nil FF[c]=nil GG[c]=nil end end
end)

-- ============================================
-- INICIALIZAÇÃO
-- ============================================
AntiCheat.init()
S:Notify({Title="SD MODS PVP",Description="Combate + Coletor Carregado!",Icon="circle-check",Tone="Success",Duration=15})
