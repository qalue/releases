local Eclipse,Connections,GUISettings={},{},{Automation={AutoButtons=false,AutoObby=false,AutoCollect=false,AutoJuice=false}}
local Player,ReplicatedStorage,StarterGui,RunService=game.Players.LocalPlayer,game:GetService'ReplicatedStorage',game:GetService'StarterGui',game:GetService'RunService'
local C_R,C_C,F_TI,F_P,Stepped=coroutine.resume,coroutine.create,firetouchinterest,fireproximityprompt,RunService.Stepped
Eclipse.Loaded=false

local function GetTycoon()
    local tycoons=workspace.Tycoons:GetChildren()
    for i=1,#tycoons do 
        local tycoon=tycoons[i]
        if tycoon.Owner.Value==game.Players.LocalPlayer then
            return tycoon
        end
    end
    for i=1,#tycoons do 
        local tycoon=tycoons[i]
        if tycoon.Owner.Value==nil then
            if tycoon.Essentials.Entrance then
                F_TI(Player.Character:WaitForChild'HumanoidRootPart',tycoon.Essentials.Entrance,0)
                F_TI(Player.Character:WaitForChild'HumanoidRootPart',tycoon.Essentials.Entrance,1)
                return tycoon
            end
        end
    end
end

local playerTycoon=GetTycoon()
local obbyStartPart,obbyWinPart,juicerPrompt,dropsFolder,buttonsFolder=workspace.ObbyParts.RealObbyStartPart,workspace.ObbyParts.VictoryPart,playerTycoon.Essentials.JuiceMaker.StartJuiceMakerButton.PromptAttachment.StartPrompt,playerTycoon.Drops,playerTycoon.Buttons

function Eclipse:GetConnection(Connection,DisconnectConnection)
    for i=1,#Connections do 
        if Connections[i].Name==Connection then 
            if DisconnectConnection then 
                Connections[i].Function:Disconnect()
                return table.remove(Connections,i)
            end
            return Connections[i].Function
        end
    end
    return false
end

function Eclipse:SendNotification(title,text)
    StarterGui:SetCore("SendNotification",{Title=title; Text=text})
end

function Eclipse:AutomateButtons()
    if not Player.Character then
        Eclipse:SendNotification("Failure","No character found")
        return false
    end
    if not Player.Character:FindFirstChild'HumanoidRootPart' then
        Eclipse:SendNotification("Failure","No HumanoidRootPart found")
        return false
    end
    C_R(C_C(function()
        while GUISettings.Automation.AutoButtons do
            Stepped:Wait()
            local buttonsFolder=buttonsFolder:GetChildren()
            for i=1,#buttonsFolder do
                if buttonsFolder[i].ButtonLabel.CostLabel.Text~="FREE!" then
                    local buttonPrice=string.gsub(buttonsFolder[i].ButtonLabel.CostLabel.Text, ",", "")
                    if tonumber(buttonPrice)<=Player:WaitForChild'leaderstats'.Money.Value then
                        if not (#buttonsFolder>2 and buttonsFolder[i].Name=="AutoCollect") then
                            F_TI(Player.Character:WaitForChild'HumanoidRootPart',buttonsFolder[i],0)
                            F_TI(Player.Character:WaitForChild'HumanoidRootPart',buttonsFolder[i],1)
                        end
                    end
                else
                    F_TI(Player.Character:WaitForChild'HumanoidRootPart',buttonsFolder[i],0)
                    F_TI(Player.Character:WaitForChild'HumanoidRootPart',buttonsFolder[i],1)
                end
            end
            if not playerTycoon.Purchased:FindFirstChild("Golden Tree Statue") then

            end
        end
    end))
    return true
end

function Eclipse:AutomateCollection()
    C_R(C_C(function()
        while GUISettings.Automation.AutoCollect do
            Stepped:Wait()
            local dropsFolder=dropsFolder:GetChildren()
            for i=1,#dropsFolder do
                local drop=dropsFolder[i]
                ReplicatedStorage.CollectFruit:FireServer(drop)
            end
        end
    end))
    return true
end

function Eclipse:AutomateJuicer()
    C_R(C_C(function()
        while GUISettings.Automation.AutoJuice do
            task.wait(0.5)
            F_P(juicerPrompt)
        end
    end))
    return true
end

function Eclipse:LoopObby()
    if not Player.Character then
        Eclipse:SendNotification("Failure","No character found")
        return false
    end
    if not Player.Character:FindFirstChild'HumanoidRootPart' then
        Eclipse:SendNotification("Failure","No HumanoidRootPart found")
        return false
    end
    C_R(C_C(function()
        while GUISettings.Automation.AutoObby do
            Stepped:Wait()
            Connections[#Connections+1]={Name="AutoObby",Function=Player.CharacterAdded:Connect(function()
                Eclipse:GetConnection('AutoObby',true)
            end)}
            F_TI(Player.Character:WaitForChild'HumanoidRootPart',obbyStartPart,0)
            F_TI(Player.Character:WaitForChild'HumanoidRootPart',obbyStartPart,1)
            F_TI(Player.Character:WaitForChild'HumanoidRootPart',obbyWinPart,0)
            F_TI(Player.Character:WaitForChild'HumanoidRootPart',obbyWinPart,1)
            repeat Stepped:wait()until typeof(Eclipse:GetConnection'DupeInventory')~='RBXScriptConnection'
        end
    end))
    return true
end

local EclipseUI=loadstring(game:HttpGet('https://raw.githubusercontent.com/EclipseUtilities/Eclipse/main/UI%20Libraries/EclipseUILibrary.lua',true))()

EclipseUI:CreateWindow()
--// Automation UI
EclipseUI:CreateSection("Automation")
EclipseUI:CreateToggle("Auto Buy Buttons",function(state)
    GUISettings.Automation.AutoButtons=state
    if not Eclipse:AutomateButtons() then
        task.wait(.3)
        GUISettings.Automation.AutoButtons=false
    end
end)
EclipseUI:CreateToggle("Auto Collect",function(state)
    GUISettings.Automation.AutoCollect=state
    if not Eclipse:AutomateCollection() then
        task.wait(.3)
        GUISettings.Automation.AutoCollect=false
    end
end)
EclipseUI:CreateToggle("Auto Juicer (must be close)",function(state)
    GUISettings.Automation.AutoJuice=state
    if not Eclipse:AutomateJuicer() then
        task.wait(.3)
        GUISettings.Automation.AutoJuice=false
    end
end)
EclipseUI:CreateToggle("Auto Complete Obby",function(state)
    GUISettings.Automation.AutoObby=state
    if not Eclipse:LoopObby() then
        task.wait(.3)
        GUISettings.Automation.AutoObby=false
    end
end)

Connections[#Connections+1]={Name='DestroyedGUI',Function=game.CoreGui.ChildRemoved:Connect(function(Child)
    if tstring(Child)=='Ancestor'then
        Eclipse.Loaded=false
		for i=1,#Connections do 
			Connections[i].Function:Disconnect()
		end
    end
end)}

Eclipse.Loaded=true
Eclipse:SendNotification("Loaded Eclipse","Eclipse has now loaded.")