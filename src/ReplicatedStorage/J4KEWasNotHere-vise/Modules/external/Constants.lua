--!strict

local Constants = {}

-- Services
local HttpService = game:GetService("HttpService")

-- Context
local Widget = require("../../Components/PluginComponents/Widget")

local Checkbox = require("../../Components/StudioComponents/Checkbox")
local MainButton = require("../../Components/StudioComponents/MainButton")
local ScrollFrame = require("../../Components/StudioComponents/ScrollFrame")
local Label = require("../../Components/StudioComponents/Label")
local LabelImage = require("../../Components/StudioComponents/LabelImage")
local Paragraph = require("../../Components/StudioComponents/Paragraph")
local TextInput = require("../../Components/StudioComponents/TextInput")
local VerticalExpandingList = require("../../Components/StudioComponents/VerticalExpandingList")
local VerticalCollapsibleSection =
	require("../../Components/StudioComponents/VerticalCollapsibleSection")
local Seperator = require("../../Components/StudioComponents/Seperator")
local Loading = require("../../Components/StudioComponents/Loading")
local ClassIcon = require("../../Components/StudioComponents/ClassIcon")
local IconButton = require("../../Components/StudioComponents/IconButton")
local LimitedTextInput = require("../../Components/StudioComponents/LimitedTextInput")
local ProgressBar = require("../../Components/StudioComponents/ProgressBar")
local Slider = require("../../Components/StudioComponents/Slider")

local Fusion = require("../../Packages/Fusion")
local New = Fusion.New
local Value = Fusion.Value
local Children = Fusion.Children
local OnChange = Fusion.OnChange
local OnEvent = Fusion.OnEvent
local Observer = Fusion.Observer
local Computed = Fusion.Computed
local unwrap = require("../../Components/StudioComponents/Util/unwrap")

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

		AddWidget = function(props)
			local id = props.Id or HttpService:GenerateGUID()
			local widgetsEnabled = props.Enabled or Value(false)

			return Widget({
				Id = id,
				Name = props.Name or id,
				InitialDockTo = props.InitialDockTo or Enum.InitialDockState.Left,
				InitialEnabled = props.InitialEnabled or false,
				ForceInitialEnabled = props.ForceInitialEnabled or false,
				FloatingSize = props.FloatingSize or Vector2.new(280, 280),
				MinimumSize = props.FloatingSize or Vector2.new(280, 240),
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
					[Children] = props.Children or {},
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
		ClassIcon = ClassIcon,
		Slider = Slider,
		ProgressBar = ProgressBar,
		LimitedTextInput = LimitedTextInput,
		IconButton = IconButton,
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
		Constants = Constants,
	},
}

Constants.Version = "0.1.0"
Constants.VersionTip = "-alpha"

Constants._context = ctx

return Constants
