local unwrap = require("../../Components/StudioComponents/Util/unwrap")
local Constants = require("../external/Constants")
local Types = require("../external/Types")

local CaptureWidget = {}
CaptureWidget.__index = CaptureWidget

-- Services
local RunService = game.RunService
local UserInputService: UserInputService = game.UserInputService
local CoreGui: CoreGui = game.CoreGui

-- Variables
local ctx: Types.ctx = Constants._context
local Value = ctx.fusion.Value

-- Internal API
CaptureWidget.CaptureSize = Value(Vector2.new(256, 256))

-- Plugin

function CaptureWidget:Bind(_, toolbarButton, pluginRoot, pluginInstance)
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

	local Widget = ctx.studio.Widget
	local AddWidget = ctx.studio.AddWidget

	local Trove = ctx.modules.Trove.new()

	-- Variables
	local mousePos = UserInputService:GetMouseLocation()
	local isDragging = false
	local mousePosStart = nil
	local dragStartSize = Vector2.new(256, 256)
	local offsetFunc = nil

	-- States
	local widgetsEnabled = Value(false)
	local captureSize = CaptureWidget.CaptureSize
	local targetCaptureSize = Value(captureSize:get())
	dragStartSize = captureSize:get()

	-- Constants
	local CAPTURE_PAD_X, CAPTURE_PAD_Y = 10, 10

	-- Capture Screen

	local Camera = workspace.CurrentCamera or workspace.Camera

	local function viewportChanged()
		local viewport = Camera.ViewportSize
		local target = targetCaptureSize:get()

		local rawsize = Vector2.new(
			math.min(target.X, viewport.X - CAPTURE_PAD_X),
			math.min(target.Y, viewport.Y - CAPTURE_PAD_Y)
		)

		captureSize:set(rawsize)
	end

	local function updateDrag()
		if isDragging and offsetFunc and mousePosStart then
			local currentPos = UserInputService:GetMouseLocation()
			offsetFunc(2 * (currentPos - mousePosStart))
		end
	end

	local function inputEnded(input: InputObject)
		if input.UserInputType == Enum.UserInputType.MouseButton1 and isDragging then
			isDragging = false
			mousePosStart = nil
			offsetFunc = nil
		end
	end

	local function BackgroundSpacer(props)
		local Filler = props.NoFill and {}
			or New("UIFlexItem")({
				FlexMode = Enum.UIFlexMode.Fill,
			})

		return New("Frame")({
			BackgroundColor3 = props.Color or Color3.new(0, 0, 0),
			BackgroundTransparency = props.Transparency or 0.8,
			LayoutOrder = props.Order,
			Position = props.Position,
			Size = props.Size or UDim2.fromScale(1, 1),
			AnchorPoint = props.AnchorPoint,

			[Children] = { Filler },
		})
	end

	local function DraggableIcon(props)
		return New("ImageButton")({
			Image = props.Image,

			Position = props.Position,
			AnchorPoint = props.AnchorPoint,

			Active = true,
			Selectable = true,

			BackgroundTransparency = 1,
			Size = props.Size,
			ImageTransparency = props.Transparency,
			ImageRectOffset = props.RectOffset,
			ImageRectSize = props.RectSize,

			[OnEvent("InputBegan")] = function(input: InputObject)
				if isDragging then
					return
				end
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					mousePosStart = UserInputService:GetMouseLocation()
					dragStartSize = captureSize:get()
					offsetFunc = props.OnDrag
					isDragging = true
				end
			end,
		})
	end

	-- Connections
	Trove:Connect(Camera:GetPropertyChangedSignal("ViewportSize"), viewportChanged)
	Trove:Connect(RunService.RenderStepped, updateDrag)
	Trove:Connect(UserInputService.InputEnded, inputEnded)

	-- External
	local MainGui = New("ScreenGui")({
		DisplayOrder = 200,
		Enabled = widgetsEnabled,

		ClipToDeviceSafeArea = false,
		SafeAreaCompatibility = Enum.SafeAreaCompatibility.None,
		ScreenInsets = Enum.ScreenInsets.None,
		IgnoreGuiInset = true,
		ResetOnSpawn = false,

		Name = "vise_capture_gui",

		[Children] = {
			New("UIListLayout")({
				FillDirection = Enum.FillDirection.Vertical,
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				VerticalAlignment = Enum.VerticalAlignment.Center,
			}),

			BackgroundSpacer({
				Order = 0,
			}),

			-- Window
			New("Frame")({
				Size = Computed(function()
					local rawsize = captureSize:get()
					return UDim2.fromOffset(rawsize.X, rawsize.Y)
				end),
				BackgroundTransparency = 1,
				LayoutOrder = 1,

				[Children] = {
					BackgroundSpacer({
						NoFill = true,
						AnchorPoint = Vector2.new(1, 0),

						Size = UDim2.new(0, 1000, 1, 0),
					}),

					BackgroundSpacer({
						NoFill = true,
						Position = UDim2.fromScale(1, 0),

						Size = UDim2.new(0, 1000, 1, 0),
					}),

					New("UIStroke")({
						Color = Color3.new(0, 0, 0),
						Thickness = 2,
						Transparency = 0.8,
					}),

					New("TextLabel")({
						Text = Computed(function()
							local rawsize = captureSize:get()
							return `{rawsize.X} x {rawsize.Y}`
						end),

						AutomaticSize = Enum.AutomaticSize.X,
						AnchorPoint = Vector2.new(0.5, 1),
						Size = UDim2.new(0, 0, 0, 18),
						Position = UDim2.new(0.5, 0, 0, -6),

						TextTransparency = 0.3,
						TextColor3 = Color3.new(1, 1, 1),
						FontFace = Font.fromName(
							"Roboto",
							Enum.FontWeight.Bold,
							Enum.FontStyle.Normal
						),

						BackgroundTransparency = 1,
						TextSize = 18,
						TextScaled = false,
					}),

					DraggableIcon({
						Image = "rbxassetid://16898614020",
						RectOffset = Vector2.new(0, 257),
						RectSize = Vector2.new(256, 256),
						Transparency = 0,

						Position = UDim2.fromScale(1, 1),
						Size = UDim2.fromOffset(32, 32),
						AnchorPoint = Vector2.new(0, 0),

						OnDrag = function(offset: Vector2)
							local nextSize = dragStartSize + offset
							local viewport = Camera.ViewportSize
							local maxSize = Vector2.new(
								math.max(16, viewport.X - CAPTURE_PAD_X),
								math.max(16, viewport.Y - CAPTURE_PAD_Y)
							)

							nextSize = Vector2.new(
								math.floor(math.clamp(nextSize.X, 16, maxSize.X)),
								math.floor(math.clamp(nextSize.Y, 16, maxSize.Y))
							)

							targetCaptureSize:set(nextSize)
							captureSize:set(nextSize)
						end,
					}),
				},
			}),

			BackgroundSpacer({
				Order = 2,
			}),
		},
	})

	MainGui.Parent = CoreGui
	viewportChanged()

	local Collapsible = function(props)
		return makeCard({
			Padding = 0,

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
	end

	-- Widget
	AddWidget({
		Name = `Capture | {Constants.NameId}`,

		Enabled = widgetsEnabled,
		InitialDockTo = Enum.InitialDockState.Float,
		FloatingSize = Vector2.new(280, 360),
		ScrollingEnabled = true,

		Children = { -- do not replace with [Children]
			Collapsible({
				Text = "Camera Configurations",
				Collapsed = true,
				Children = { -- do not replace with [Children]
					--
				},
			}),
		},
	})

	toolbarButton.Click:Connect(function()
		widgetsEnabled:set(not widgetsEnabled:get())
	end)

	return function()
		widgetsEnabled:set(false)
		Trove:Destroy()
		cleanup(MainGui)
	end
end

return CaptureWidget
