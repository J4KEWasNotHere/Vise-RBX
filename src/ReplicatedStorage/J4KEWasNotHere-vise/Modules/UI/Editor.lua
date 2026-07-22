--[[
	Editor Module
	Main editing interface
]]

local CaptureFrame = require(script.Parent.CaptureFrame)
local Project = require(script.Parent.Parent.Project)
local Renderer = require(script.Parent.Parent.Renderer)

local Editor = {}
Editor.__index = Editor

function Editor.new(plugin, pluginRoot)
	local self = setmetatable({}, Editor)
	self.plugin = plugin
	self.pluginRoot = pluginRoot
	self.project = Project.new()
	self.captureFrame = nil
	self.widget = nil
	return self
end

function Editor:show()
	if not self.widget then
		self:createWidget()
	end
	self.widget:SetPrimary(true)
end

function Editor:createWidget()
	local dockWidgetInfo =
		DockWidgetPluginGuiInfo.new(Enum.InitialDockState.Float, false, false, 500, 400, 300, 200)

	self.widget = self.plugin:CreateDockWidgetPluginGui("ViseEditor", dockWidgetInfo)
	self.widget.Title = "Vise - Image Editor"
	self.widget.Name = "ViseEditor"

	-- Main container
	local mainFrame = Instance.new("Frame")
	mainFrame.Size = UDim2.new(1, 0, 1, 0)
	mainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	mainFrame.BorderSizePixel = 0
	mainFrame.Parent = self.widget

	-- Toolbar
	local toolbar = Instance.new("Frame")
	toolbar.Name = "Toolbar"
	toolbar.Size = UDim2.new(1, 0, 0, 40)
	toolbar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	toolbar.BorderSizePixel = 0
	toolbar.Parent = mainFrame

	-- Capture button
	local captureBtn = Instance.new("TextButton")
	captureBtn.Size = UDim2.new(0, 100, 0, 30)
	captureBtn.Position = UDim2.new(0, 5, 0, 5)
	captureBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
	captureBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	captureBtn.TextSize = 12
	captureBtn.Text = "New Capture"
	captureBtn.Parent = toolbar

	captureBtn.MouseButton1Click:Connect(function()
		self:openCaptureFrame()
	end)

	-- Main content area
	local contentArea = Instance.new("Frame")
	contentArea.Name = "ContentArea"
	contentArea.Size = UDim2.new(1, 0, 1, -40)
	contentArea.Position = UDim2.new(0, 0, 0, 40)
	contentArea.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	contentArea.BorderSizePixel = 0
	contentArea.Parent = mainFrame

	-- Image preview (placeholder)
	local preview = Instance.new("TextLabel")
	preview.Name = "Preview"
	preview.Size = UDim2.new(1, 0, 1, 0)
	preview.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	preview.TextColor3 = Color3.fromRGB(150, 150, 150)
	preview.TextSize = 14
	preview.Text = "No image captured yet"
	preview.Parent = contentArea

	self.widget = self.widget
end

function Editor:openCaptureFrame()
	-- Create a temporary GUI for capture frame
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "ViseCaptureGui"
	screenGui.ResetOnSpawn = false

	-- Find the plugin GUI service
	local pluginGui = self.plugin:CreateDockWidgetPluginGui(
		"ViseCaptureFrame",
		DockWidgetPluginGuiInfo.new(Enum.InitialDockState.Float, false, false, 500, 400, 300, 200)
	)
	pluginGui.Title = "Capture Area"

	self.captureFrame = CaptureFrame.new(pluginGui)

	-- Get the capture button from the frame and connect it
	local contentChildren = pluginGui:GetChildren()
	for _, child in ipairs(contentChildren) do
		if child:IsA("Frame") and child.Name == "CaptureFrame" then
			-- Find capture button
			for _, item in ipairs(child:GetDescendants()) do
				if item:IsA("TextButton") and item.Text == "Capture" then
					item.MouseButton1Click:Connect(function()
						self:performCapture()
						pluginGui:Destroy()
					end)
					break
				end
			end
			break
		end
	end
end

function Editor:performCapture()
	print("[Vise] Capturing image...")
	-- In a real plugin, this would capture the viewport
	-- For now, create a dummy capture
	local imageData = {
		size = self.captureFrame:getSize(),
		timestamp = os.time(),
	}
	self.project:createImage(imageData)
	print("[Vise] Capture complete!")
end

return Editor
