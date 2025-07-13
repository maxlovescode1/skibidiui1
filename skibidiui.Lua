local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local screenGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))

-- GUI Setup
local mainFrame = Instance.new("Frame", screenGui)
mainFrame.Size = UDim2.new(0, 420, 0, 120)
mainFrame.Position = UDim2.new(0.5, -210, 0.5, -60)
mainFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true

local titleLabel = Instance.new("TextLabel", mainFrame)
titleLabel.Size = UDim2.new(1, 0, 0, 30)
titleLabel.Text = "skibidiui"
titleLabel.BackgroundTransparency = 1
titleLabel.TextColor3 = Color3.new(1, 1, 1)
titleLabel.Font = Enum.Font.SourceSansBold
titleLabel.TextSize = 28

local closeButton = Instance.new("TextButton", mainFrame)
closeButton.Size = UDim2.new(0, 30, 0, 30)
closeButton.Position = UDim2.new(0, 0, 0, 0)
closeButton.Text = "X"
closeButton.BackgroundColor3 = Color3.new(0.4, 0.4, 0.4)
closeButton.TextColor3 = Color3.new(1, 1, 1)
closeButton.Font = Enum.Font.SourceSansBold
closeButton.TextSize = 24

local flyButton = Instance.new("TextButton", mainFrame)
flyButton.Size = UDim2.new(0, 200, 0, 50)
flyButton.Position = UDim2.new(0, 10, 0, 40)
flyButton.Text = "Toggle Fly"
flyButton.BackgroundColor3 = Color3.new(0.2, 0.6, 0.8)
flyButton.TextColor3 = Color3.new(1, 1, 1)
flyButton.Font = Enum.Font.SourceSans
flyButton.TextSize = 24

local killButton = Instance.new("TextButton", mainFrame)
killButton.Size = UDim2.new(0, 200, 0, 50)
killButton.Position = UDim2.new(0, 210, 0, 40)
killButton.Text = "Self Destruct"
killButton.BackgroundColor3 = Color3.new(0.8, 0.2, 0.2)
killButton.TextColor3 = Color3.new(1, 1, 1)
killButton.Font = Enum.Font.SourceSans
killButton.TextSize = 24

local toggleButton = Instance.new("TextButton", screenGui)
toggleButton.Size = UDim2.new(0, 120, 0, 30)
toggleButton.Position = UDim2.new(0, 10, 0.5, -15) -- Left side
toggleButton.Text = "skibidi gui>"
toggleButton.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
toggleButton.TextColor3 = Color3.new(1, 1, 1)
toggleButton.Font = Enum.Font.SourceSans
toggleButton.TextSize = 20
toggleButton.Visible = false -- Hidden until X is clicked

-- Dragging logic
local dragging, dragInput, dragStart, startPos

titleLabel.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)

titleLabel.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input == dragInput then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X,
                                       startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- Flight logic
local flying = false
local flightGyro, flightVelocity
local flightConnection

local function toggleFlight()
    character = player.Character or player.CharacterAdded:Wait()
    local root = character:WaitForChild("HumanoidRootPart")

    flying = not flying
    if flying then
        flightGyro = Instance.new("BodyGyro", root)
        flightGyro.P = 10000
        flightGyro.MaxTorque = Vector3.new(400000, 400000, 400000)
        flightGyro.D = 10

        flightVelocity = Instance.new("BodyVelocity", root)
        flightVelocity.MaxForce = Vector3.new(400000, 400000, 400000)
        flightVelocity.Velocity = Vector3.zero

        flightConnection = RunService.RenderStepped:Connect(function()
            flightGyro.CFrame = workspace.CurrentCamera.CFrame
            local moveVector = Vector3.zero

            if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                moveVector = moveVector + workspace.CurrentCamera.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                moveVector = moveVector - workspace.CurrentCamera.CFrame.LookVector
            end

            flightVelocity.Velocity = moveVector.Magnitude > 0 and moveVector.Unit * 60 or Vector3.zero
        end)
    else
        if flightGyro then flightGyro:Destroy() end
        if flightVelocity then flightVelocity:Destroy() end
        if flightConnection then flightConnection:Disconnect() end
    end
end

flyButton.MouseButton1Click:Connect(toggleFlight)

killButton.MouseButton1Click:Connect(function()
    local hum = character:FindFirstChildOfClass("Humanoid")
    if hum then hum.Health = 0 end
end)

closeButton.MouseButton1Click:Connect(function()
    mainFrame.Visible = false
    toggleButton.Visible = true -- Show toggle after closing GUI
end)

toggleButton.MouseButton1Click:Connect(function()
    mainFrame.Visible = true
    toggleButton.Visible = false -- Hide toggle when reopening GUI
end)
