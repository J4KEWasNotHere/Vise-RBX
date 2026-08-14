-- Services
local HttpService = game:GetService("HttpService")
local LocalizationService = game:GetService("LocalizationService")

-- Context
local Widget = require("../../Components/PluginComponents/Widget")
local BoxBorder = require("../../Components/StudioComponents/BoxBorder")

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
local PlainCheckbox = require("../../Components/StudioComponents/PlainCheckbox")
local ProgressBar = require("../../Components/StudioComponents/ProgressBar")
local Slider = require("../../Components/StudioComponents/Slider")
local PlainCheckbox = require("../../Components/StudioComponents/PlainCheckbox")

local Fusion = require("../../Packages/_Index/elttob_fusion@0.2.0/fusion") -- explict
local New = Fusion.New
local Value = Fusion.Value
local Children = Fusion.Children
local OnChange = Fusion.OnChange
local OnEvent = Fusion.OnEvent
local Observer = Fusion.Observer
local Computed = Fusion.Computed
local Hydrate = Fusion.Hydrate
local Cleanup = Fusion.Cleanup
local cleanup = Fusion.cleanup

local unwrap = require("../../Components/StudioComponents/Util/unwrap")
local themeProvider = require("../../Components/StudioComponents/Util/themeProvider")

local function makeCard(props)
	local y: NumberRange? = props.YScaling
	local padding = props.Padding or 10
	local layout = props.NoLayout and {}
		or New("UIListLayout")({
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = UDim.new(0, 8),
		})
	local size = props.Size
	local border = props.UseBorder
			and New("UIStroke")({
				Thickness = 1,
				Color = props.BorderColor
					or themeProvider:GetColor(Enum.StudioStyleGuideColor.Border),
				Transparency = props.Transparency,
			})
		or {}

	local sizeconstraint = props.DontConstrain and {}
		or New("UISizeConstraint")({
			MaxSize = Vector2.new(9999, y and y.Max or 9999),
			MinSize = Vector2.new(0, y and y.Min or 0),
		})

	local corner = props.CornerRadius or 2
	local color = props.Color or Color3.fromRGB(0, 0, 0)

	return New("Frame")({
		Size = size or UDim2.fromScale(1, 0),
		AutomaticSize = size and Enum.AutomaticSize.None or Enum.AutomaticSize.Y,
		BackgroundTransparency = props.Transparency or 0.7,
		BackgroundColor3 = color,
		BorderSizePixel = 0,
		[Children] = {
			border,
			New("UICorner")({ CornerRadius = UDim.new(0, corner) }),
			New("UIPadding")({
				PaddingLeft = UDim.new(0, props.PaddingLeft or props.XPadding or padding),
				PaddingRight = UDim.new(0, props.XPadding or padding),
				PaddingTop = UDim.new(0, props.YPadding or padding),
				PaddingBottom = UDim.new(0, props.YPadding or padding),
			}),
			layout,

			sizeconstraint,
			props.Children,
		},
	})
end

local ctx = {
	fusion = {
		Hydrate = Hydrate,

		New = New,
		Value = Value,
		Children = Children,
		OnChange = OnChange,
		OnEvent = OnEvent,
		Observer = Observer,
		Computed = Computed,
		Cleanup = Cleanup,
		cleanup = cleanup,
		unwrap = unwrap,
	},

	util = {
		themeProvider = themeProvider,
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
		PlainCheckbox = PlainCheckbox,
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
		makeCollapsible = function(props)
			return makeCard({
				UseBorder = true,
				Padding = 0,
				Transparency = 0,
				Color = themeProvider:GetColor(Enum.StudioStyleGuideColor.MainBackground),
				BorderColor = themeProvider:GetColor(Enum.StudioStyleGuideColor.Light),

				Children = VerticalCollapsibleSection({
					Text = props.Text,
					Collapsed = props.Collapsed,
					Enabled = props.Enabled,

					Padding = UDim.new(0, props.Padding or 4),

					[Children] = makeCard({
						Transparency = 1,
						Padding = props.Padding or 4,
						Children = props.Children,
					}),
				}),
			})
		end,

		makeCard = makeCard,

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
		Trove = require("../../Packages/Trove"),
	},
}

-- Define

local Constants = {
	-- public
	Version = "0.1.0",
	VersionTip = "-alpha",

	-- internal
	_context = ctx,
}

Constants.NameId = `Vise-{Constants.Version}{Constants.VersionTip}`

return Constants
