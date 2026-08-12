--[[
	Vise - Icon Creator
	github.com/J4KEWasNotHere/Vise
	GPL-3.0 License
]]

-- Services

local HttpService = game:GetService("HttpService")

-- Setup

local pluginRoot = script.Parent
local toolbar = plugin:CreateToolbar("Vise")

-- Modules
local Modules = pluginRoot.Modules

-- Create toolbar buttons
local captureButton = toolbar:CreateButton("Capture", "Capture screenshot of the viewport.", "")
captureButton.ClickableWhenViewportHidden = false

local iconMakerButton = toolbar:CreateButton("Designer", "Edit your existing screenshots.", "")
iconMakerButton.ClickableWhenViewportHidden = true

local shaderEditButton = toolbar:CreateButton("Shaders", "Create a shader for vise.", "")
shaderEditButton.ClickableWhenViewportHidden = true

-- Wigets
local Widgets = Modules.widgets
local CaptureWidget = require(Widgets.CaptureWidget)

-- Context
local Components = pluginRoot.Components
local Packages = pluginRoot.Packages

local PluginComponents = Components:FindFirstChild("PluginComponents")
local Widget = require(PluginComponents.Widget)

local StudioComponents = Components:FindFirstChild("StudioComponents")
local Checkbox = require(StudioComponents.Checkbox)
local MainButton = require(StudioComponents.MainButton)
local ScrollFrame = require(StudioComponents.ScrollFrame)
local Label = require(StudioComponents.Label)
local LabelImage = require(StudioComponents.LabelImage)
local Paragraph = require(StudioComponents.Paragraph)
local TextInput = require(StudioComponents.TextInput)
local VerticalExpandingList = require(StudioComponents.VerticalExpandingList)
local VerticalCollapsibleSection = require(StudioComponents.VerticalCollapsibleSection)
local Seperator = require(StudioComponents.Seperator)
local Loading = require(StudioComponents.Loading)

local Fusion = require(Packages.Fusion)
local New = Fusion.New
local Value = Fusion.Value
local Children = Fusion.Children
local OnChange = Fusion.OnChange
local OnEvent = Fusion.OnEvent
local Observer = Fusion.Observer
local Computed = Fusion.Computed
local unwrap = require(StudioComponents.Util.unwrap)

local ctx = {
	fusion = {
		New = New,
		Value = Value,
		Children = Children,
		OnChange = OnChange,
		OnEvent = OnEvent,
		Observer = Observer,
		Computed = Computed,
		unwrap = unwrap,
	},

	studio = {
		Widget = Widget,

		AddWidget = function(props, children)
			local id = props.Id or HttpService:GenerateGUID()
			local widgetsEnabled = props.Enabled or Value(false)

			return Widget({
				Id = id,
				Name = props.Name or id,
				InitialDockTo = props.InitialDockTo or Enum.InitialDockState.Left,
				InitialEnabled = props.InitialEnabled or false,
				ForceInitialEnabled = props.ForceInitialEnabled or false,
				FloatingSize = props.FloatingSize or Vector2.new(280, 280),
				MinimumSize = props.MinimumSize or Vector2.new(280, 240),
				Enabled = widgetsEnabled,
				[OnChange("Enabled")] = function(isEnabled)
					widgetsEnabled:set(isEnabled)
				end,
				[Children] = ScrollFrame({
					ZIndex = 1,
					Size = UDim2.fromScale(1, 1),
					CanvasScaleConstraint = Enum.ScrollingDirection.X,
					UILayout = New("UIListLayout")({
						SortOrder = Enum.SortOrder.LayoutOrder,
						Padding = UDim.new(0, 8),
					}),
					UIPadding = New("UIPadding")({
						PaddingLeft = UDim.new(0, 6),
						PaddingRight = UDim.new(0, 6),

						PaddingBottom = UDim.new(0, 6),
						PaddingTop = UDim.new(0, 6),
					}),
					[Children] = children,
				}),
			})
		end,
	},

	components = {
		Checkbox = Checkbox,
		MainButton = MainButton,
		ScrollFrame = ScrollFrame,
		Label = Label,
		LabelImage = LabelImage,
		Paragraph = Paragraph,
		TextInput = TextInput,
		VerticalExpandingList = VerticalExpandingList,
		VerticalCollapsibleSection = VerticalCollapsibleSection,
		Seperator = Seperator,
		Loading = Loading,
	},

	ui = {
		makeCard = function(contents, y: NumberRange?)
			return New("Frame")({
				Size = UDim2.fromScale(1, 0),
				AutomaticSize = Enum.AutomaticSize.Y,
				BackgroundTransparency = 0.7,
				BackgroundColor3 = Color3.fromRGB(0, 0, 0),
				BorderSizePixel = 0,
				[Children] = {
					New("UICorner")({ CornerRadius = UDim.new(0, 8) }),
					New("UIPadding")({
						PaddingLeft = UDim.new(0, 10),
						PaddingRight = UDim.new(0, 10),
						PaddingTop = UDim.new(0, 10),
						PaddingBottom = UDim.new(0, 10),
					}),
					New("UIListLayout")({
						SortOrder = Enum.SortOrder.LayoutOrder,
						Padding = UDim.new(0, 8),
					}),
					New("UISizeConstraint")({
						MaxSize = Vector2.new(9999, y and y.Max or 9999),
						MinSize = Vector2.new(0, y and y.Min or 0),
					}),
					table.unpack(contents),
				},
			})
		end,

		makeSectionHeader = function(text)
			return Label({
				Text = text,
				TextColor3 = Color3.fromRGB(220, 220, 220),
				TextSize = 14,
			})
		end,

		ScrollFrame = function(contents, size: UDim2?)
			return New("ScrollingFrame")({
				Size = size or UDim2.fromScale(1, 1),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				ScrollBarThickness = 6,
				ScrollBarImageColor3 = Color3.fromRGB(180, 180, 180),
				ScrollingDirection = Enum.ScrollingDirection.Y,
				AutomaticCanvasSize = Enum.AutomaticSize.Y,
				CanvasSize = UDim2.fromScale(0, 0),
				[Children] = {
					New("UIListLayout")({
						SortOrder = Enum.SortOrder.LayoutOrder,
						Padding = UDim.new(0, 8),
					}),
					New("UIPadding")({
						PaddingLeft = UDim.new(0, 4),
						PaddingRight = UDim.new(0, 10),
						PaddingTop = UDim.new(0, 4),
						PaddingBottom = UDim.new(0, 4),
					}),
					table.unpack(contents),
				},
			})
		end,
	},
	modules = {
		Constants = require("./Modules/external/Constants"),
	},
}

-- Initialize

CaptureWidget:Bind(ctx, captureButton, pluginRoot, plugin)

-- function Editor:performCapture()
-- 	print("[Vise] Capturing image...")
-- 	-- In a real plugin, this would capture the viewport
-- 	-- For now, create a dummy capture
-- 	local imageData = {
-- 		size = self.captureFrame:getSize(),
-- 		timestamp = os.time(),
-- 	}
-- 	self.project:createImage(imageData)
-- 	print("[Vise] Capture complete!")
-- end
