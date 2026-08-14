local Constants = require("../external/Constants")
local Types = require("../external/Types")

local DesignerWidget = {}
DesignerWidget.__index = DesignerWidget

-- Services
local RunService = game.RunService
local UserInputService: UserInputService = game.UserInputService
local CoreGui: CoreGui = game.CoreGui

-- Variables
local ctx: Types.ctx = Constants._context
local Value = ctx.fusion.Value

-- Internal API

-- Plugin

function DesignerWidget:Bind(_, toolbarButton, pluginRoot, pluginInstance)
	-- Setup
	local Hydrate = ctx.fusion.Hydrate
	local Computed = ctx.fusion.Computed
	local unwrap = ctx.fusion.unwrap

	local Children = ctx.fusion.Children
	local OnChange = ctx.fusion.OnChange
	local OnEvent = ctx.fusion.OnEvent
	local Observer = ctx.fusion.Observer
	local Cleanup = ctx.fusion.Cleanup
	local cleanup = ctx.fusion.cleanup
	local New = ctx.fusion.New

	local Label = ctx.components.Label
	local MainButton = ctx.components.MainButton
	local TextInput = ctx.components.TextInput
	local Checkbox = ctx.components.Checkbox
	local Seperator = ctx.components.Seperator
	local Loading = ctx.components.Loading
	local VerticalCollapsibleSection = ctx.components.VerticalCollapsibleSection
	local ScrollFrame = ctx.components.ScrollFrame

	local makeCard = ctx.ui.makeCard
	local makeSectionHeader = ctx.ui.makeSectionHeader
	local makeCollapsible = ctx.ui.makeCollapsible

	local Widget = ctx.studio.Widget
	local AddWidget = ctx.studio.AddWidget

	local Trove = ctx.modules.Trove.new()

	-- Variables

	-- States
	local widgetsEnabled = Value(false)

	-- Components

	-- Connections

	-- Widget
	AddWidget({
		Name = `Designer | {Constants.NameId}`,

		Enabled = widgetsEnabled,
		InitialDockTo = Enum.InitialDockState.Float,
		FloatingSize = Vector2.new(280, 360),
		ScrollingEnabled = true,

		Children = { -- do not replace with [Children]
		},
	})

	toolbarButton.Click:Connect(function()
		widgetsEnabled:set(not widgetsEnabled:get())
	end)

	return function()
		widgetsEnabled:set(false)
		Trove:Destroy()
	end
end

return DesignerWidget
