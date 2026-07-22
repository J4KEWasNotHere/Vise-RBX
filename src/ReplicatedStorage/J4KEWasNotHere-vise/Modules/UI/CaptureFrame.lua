--[[
	Capture Frame
	A movable and scalable frame for selecting capture area
]]

local CaptureFrame = {}
CaptureFrame.__index = CaptureFrame

function CaptureFrame.new(parent)
	local self = setmetatable({}, CaptureFrame)
	self.parent = parent
	self.isDragging = false
	self.isResizing = false
	self.dragStart = nil
	self.resizeStart = nil

	self:createUI()
	return self
end

function CaptureFrame:createUI()
	-- Main frame
	self.frame = Instance.new("Frame")
	self.frame.Name = "CaptureFrame"
	self.frame.Size = UDim2.new(0, 400, 0, 300)
	self.frame.Position = UDim2.new(0.5, -200, 0.5, -150)
	self.frame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	self.frame.BorderColor3 = Color3.fromRGB(100, 200, 255)
	self.frame.BorderSizePixel = 2
	self.frame.Parent = self.parent

	-- Title bar
	self.titleBar = Instance.new("Frame")
	self.titleBar.Name = "TitleBar"
	self.titleBar.Size = UDim2.new(1, 0, 0, 30)
	self.titleBar.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	self.titleBar.BorderSizePixel = 0
	self.titleBar.Parent = self.frame

	-- Title text
	local titleText = Instance.new("TextLabel")
	titleText.Size = UDim2.new(1, -60, 1, 0)
	titleText.BackgroundTransparency = 1
	titleText.TextColor3 = Color3.fromRGB(255, 255, 255)
	titleText.TextSize = 14
	titleText.Text = "Capture Area"
	titleText.Parent = self.titleBar

	-- Size input section
	local sizeContainer = Instance.new("Frame")
	sizeContainer.Name = "SizeContainer"
	sizeContainer.Size = UDim2.new(1, 0, 0, 50)
	sizeContainer.Position = UDim2.new(0, 0, 0, 30)
	sizeContainer.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
	sizeContainer.BorderSizePixel = 0
	sizeContainer.Parent = self.frame

	-- Width label
	local widthLabel = Instance.new("TextLabel")
	widthLabel.Size = UDim2.new(0, 40, 0, 20)
	widthLabel.Position = UDim2.new(0, 5, 0, 5)
	widthLabel.BackgroundTransparency = 1
	widthLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
	widthLabel.TextSize = 12
	widthLabel.Text = "W:"
	widthLabel.Parent = sizeContainer

	-- Width input
	self.widthInput = Instance.new("TextBox")
	self.widthInput.Size = UDim2.new(0, 60, 0, 20)
	self.widthInput.Position = UDim2.new(0, 45, 0, 5)
	self.widthInput.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	self.widthInput.TextColor3 = Color3.fromRGB(255, 255, 255)
	self.widthInput.TextSize = 12
	self.widthInput.Text = "400"
	self.widthInput.Parent = sizeContainer

	-- Height label
	local heightLabel = Instance.new("TextLabel")
	heightLabel.Size = UDim2.new(0, 40, 0, 20)
	heightLabel.Position = UDim2.new(0, 5, 0, 25)
	heightLabel.BackgroundTransparency = 1
	heightLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
	heightLabel.TextSize = 12
	heightLabel.Text = "H:"
	heightLabel.Parent = sizeContainer

	-- Height input
	self.heightInput = Instance.new("TextBox")
	self.heightInput.Size = UDim2.new(0, 60, 0, 20)
	self.heightInput.Position = UDim2.new(0, 45, 0, 25)
	self.heightInput.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	self.heightInput.TextColor3 = Color3.fromRGB(255, 255, 255)
	self.heightInput.TextSize = 12
	self.heightInput.Text = "300"
	self.heightInput.Parent = sizeContainer

	-- Update frame size when inputs change
	self.widthInput.FocusLost:Connect(function()
		local w = tonumber(self.widthInput.Text) or 400
		self.frame.Size = UDim2.new(0, w, self.frame.Size.Y.Scale, self.frame.Size.Y.Offset)
	end)

	self.heightInput.FocusLost:Connect(function()
		local h = tonumber(self.heightInput.Text) or 300
		self.frame.Size = UDim2.new(self.frame.Size.X.Scale, self.frame.Size.X.Offset, 0, h)
	end)

	-- Capture button
	local captureBtn = Instance.new("TextButton")
	captureBtn.Size = UDim2.new(0, 80, 0, 25)
	captureBtn.Position = UDim2.new(0, 120, 0, 10)
	captureBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
	captureBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	captureBtn.TextSize = 12
	captureBtn.Text = "Capture"
	captureBtn.Parent = sizeContainer

	-- Resize handle
	local resizeHandle = Instance.new("Frame")
	resizeHandle.Name = "ResizeHandle"
	resizeHandle.Size = UDim2.new(0, 15, 0, 15)
	resizeHandle.Position = UDim2.new(1, -15, 1, -15)
	resizeHandle.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
	resizeHandle.Parent = self.frame
	resizeHandle.Cursor = "ResizeSeNWSE"

	self:setupInput()
	return captureBtn
end

function CaptureFrame:setupInput()
	-- Make title bar draggable
	self.titleBar.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then
			return
		end
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			self.isDragging = true
			self.dragStart = input.Position
			self.frameStart = self.frame.Position
		end
	end)

	game:GetService("UserInputService").InputChanged:Connect(function(input)
		if not self.isDragging then
			return
		end
		local delta = input.Position - self.dragStart
		self.frame.Position = self.frameStart + UDim2.new(0, delta.X, 0, delta.Y)
	end)

	game:GetService("UserInputService").InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			self.isDragging = false
		end
	end)
end

function CaptureFrame:getSize()
	return {
		width = tonumber(self.widthInput.Text) or 400,
		height = tonumber(self.heightInput.Text) or 300,
	}
end

function CaptureFrame:destroy()
	if self.frame then
		self.frame:Destroy()
	end
end

return CaptureFrame
