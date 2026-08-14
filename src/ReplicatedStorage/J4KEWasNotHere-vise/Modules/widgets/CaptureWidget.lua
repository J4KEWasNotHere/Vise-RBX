local Project = require("../Project")
local Renderer = require("../Renderer")
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
	local themeProvider = ctx.util.themeProvider

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
	local LimitedTextInput = ctx.components.LimitedTextInput
	local Paragraph = ctx.components.Paragraph
	local VerticalCollapsibleSection = ctx.components.VerticalCollapsibleSection
	local ScrollFrame = ctx.components.ScrollFrame
	local PlainCheckbox = ctx.components.PlainCheckbox
	local makeCard = ctx.ui.makeCard
	local makeSectionHeader = ctx.ui.makeSectionHeader
	local makeCollapsible = ctx.ui.makeCollapsible

	local Widget = ctx.studio.Widget
	local AddWidget = ctx.studio.AddWidget

	local Trove = ctx.modules.Trove.new()

	-- Variables
	local mousePos = UserInputService:GetMouseLocation()
	local isDragging = false
	local mousePosStart = nil
	local dragStartSize = Vector2.new(256, 256)
	local offsetFunc = nil

	Project = Project.new()

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

	local function HorizontalSection(props)
		return makeCard({
			Padding = 3,
			PaddingLeft = 8,
			Size = UDim2.new(1, 0, 0, props.Height or 28),
			NoLayout = true,
			--DontConstrain = true,
			YScaling = NumberRange.new(28, 9999),
			UseBorder = true,
			Transparency = 0,
			CornerRadius = 2,
			Color = themeProvider:GetColor(Enum.StudioStyleGuideColor.MainBackground),
			Children = {
				New("UIListLayout")({
					FillDirection = Enum.FillDirection.Horizontal,
					Padding = UDim.new(0, 4),
					SortOrder = Enum.SortOrder.LayoutOrder,
					HorizontalAlignment = Enum.HorizontalAlignment.Center,
					VerticalAlignment = Enum.VerticalAlignment.Center,
				}),

				props.Children,
			},
		})
	end

	local function PropertySection(props)
		return HorizontalSection({
			Height = props.Height,
			Scaled = props.Scaled,

			Children = {
				Label({
					Text = props.Title or "Title",
					FontFace = props.FontFace
						or Font.fromName("SourceSans", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
					TextXAlignment = Enum.TextXAlignment.Left,
					TextTruncate = Enum.TextTruncate.SplitWord,
					NoScaling = true,
					Size = UDim2.fromScale(0.5, 1),
				}),

				Seperator({ IsVertical = true, Thickness = 1 }),

				props.Children,
			},
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
			makeCollapsible({
				Text = "Camera Configurations",
				Collapsed = true,
				Children = { -- do not replace with [Children]
					Checkbox({
						Text = "Render Skybox",
						Enabled = true,
						Value = false,
						OnChange = function(value) end,
					}),

					Seperator({}),

					PropertySection({
						Title = "Property Title",

						Children = {
							TextInput({
								PlaceholderText = "Placeholder Text",
								Text = "",

								Size = UDim2.fromScale(1, 1),
								[OnChange("Text")] = function(newText)
									print("Text:", newText)
								end,

								[Children] = {
									New("UIFlexItem")({
										FlexMode = Enum.UIFlexMode.Fill,
									}),
								},
							}),
						},
					}),

					PropertySection({
						Title = "Property Title",

						Children = {
							PlainCheckbox({

								[Children] = {
									New("UIFlexItem")({
										FlexMode = Enum.UIFlexMode.Fill,
									}),
								},
							}),
						},
					}),

					MainButton({
						Text = "Capture",
						Activated = function()
							print("[Vise] Capturing image...")

							local selectedShaders = {
								{
									id = "grayscale",
									path = script.Parent.Parent.files.shaders.Grayscale,
								},
							}

							local position = Camera and Camera.CFrame and Camera.CFrame.Position
								or Vector3.zero
							local captureFuture = Renderer.captureImage(captureSize:get(), position)

							local success, imageData = pcall(function()
								return captureFuture:expect()
							end)

							if success and imageData and not imageData.error then
								local imageId = Project:createImage(imageData)

								-- Attach shaders to the image we just created
								for _, shaderEntry in ipairs(selectedShaders) do
									if shaderEntry.module then
										-- Already-required module
										Project:addShader(shaderEntry.id, shaderEntry.module)
									elseif shaderEntry.path then
										-- Path to require at load time
										Project:addShaderFromPath(shaderEntry.id, shaderEntry.path)
									end
								end

								Project:applyCurrentImageToWorkspace()
								print("[Vise] Capture complete!", imageId)
								return
							end

							warn(
								"[Vise] Capture failed:",
								success and imageData and imageData.error or "unknown error"
							)
							local fallbackId = Project:createImage({
								size = captureSize:get(),
								position = position,
								timestamp = os.time(),
								source = "fallback",
							})
							Project:applyCurrentImageToWorkspace()
							print("[Vise] Capture fallback applied!", fallbackId)
						end,
					}),
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
