-- local
local types = require(script.Parent.types)

type styleStyleGuideColor = Enum.StudioStyleGuideColor | types.StateObject<Enum.StudioStyleGuideColor>
type styleGuideModifier = Enum.StudioStyleGuideModifier | types.StateObject<Enum.StudioStyleGuideModifier>
type computedOrValue = types.Computed<Color3> | types.Value<Color3>

local hasStudio, Studio = pcall(function()
	return settings().Studio
end)

Studio = if hasStudio then Studio else nil

local Plugin = script:FindFirstAncestorOfClass("ScreenGui")
local Fusion = require(Plugin:FindFirstChild("Fusion", true))

local unwrap = require(script.Parent.unwrap)

local Computed = Fusion.Computed
local Value = Fusion.Value

local currentTheme = {}

local RuntimeColors = { -- DarkMode
	[Enum.StudioStyleGuideColor.MainBackground] = Color3.fromRGB(25, 26, 31),
	[Enum.StudioStyleGuideColor.Titlebar] = Color3.fromRGB(32, 34, 39),
	[Enum.StudioStyleGuideColor.Dropdown] = Color3.fromRGB(25, 26, 31),
	[Enum.StudioStyleGuideColor.Tooltip] = Color3.fromRGB(32, 34, 39),
	[Enum.StudioStyleGuideColor.Notification] = Color3.fromRGB(25, 26, 31),
	[Enum.StudioStyleGuideColor.ScrollBar] = Color3.fromRGB(53, 55, 65),
	[Enum.StudioStyleGuideColor.ScrollBarBackground] = Color3.fromRGB(39, 41, 48),
	[Enum.StudioStyleGuideColor.TabBar] = Color3.fromRGB(25, 26, 31),
	[Enum.StudioStyleGuideColor.Tab] = Color3.fromRGB(32, 34, 39),
	[Enum.StudioStyleGuideColor.FilterButtonDefault] = Color3.fromRGB(25, 26, 31),
	[Enum.StudioStyleGuideColor.FilterButtonHover] = Color3.fromRGB(32, 34, 39),
	[Enum.StudioStyleGuideColor.FilterButtonChecked] = Color3.fromRGB(46, 46, 56),
	[Enum.StudioStyleGuideColor.FilterButtonAccent] = Color3.fromRGB(32, 34, 39),
	[Enum.StudioStyleGuideColor.FilterButtonBorder] = Color3.fromRGB(25, 26, 31),
	[Enum.StudioStyleGuideColor.FilterButtonBorderAlt] = Color3.fromRGB(46, 46, 56),
	[Enum.StudioStyleGuideColor.RibbonTab] = Color3.fromRGB(32, 34, 39),
	[Enum.StudioStyleGuideColor.RibbonTabTopBar] = Color3.fromRGB(82, 139, 255),
	[Enum.StudioStyleGuideColor.Button] = Color3.fromRGB(53, 55, 65),
	[Enum.StudioStyleGuideColor.MainButton] = Color3.fromRGB(51, 95, 255),
	[Enum.StudioStyleGuideColor.RibbonButton] = Color3.fromRGB(25, 26, 31),
	[Enum.StudioStyleGuideColor.ViewPortBackground] = Color3.fromRGB(32, 34, 39),
	[Enum.StudioStyleGuideColor.InputFieldBackground] = Color3.fromRGB(40, 41, 49),
	[Enum.StudioStyleGuideColor.Item] = Color3.fromRGB(25, 26, 31),
	[Enum.StudioStyleGuideColor.TableItem] = Color3.fromRGB(39, 41, 48),
	[Enum.StudioStyleGuideColor.CategoryItem] = Color3.fromRGB(32, 34, 39),
	[Enum.StudioStyleGuideColor.GameSettingsTableItem] = Color3.fromRGB(39, 41, 48),
	[Enum.StudioStyleGuideColor.GameSettingsTooltip] = Color3.fromRGB(32, 34, 39),
	[Enum.StudioStyleGuideColor.EmulatorBar] = Color3.fromRGB(25, 26, 31),
	[Enum.StudioStyleGuideColor.EmulatorDropDown] = Color3.fromRGB(25, 26, 31),
	[Enum.StudioStyleGuideColor.ColorPickerFrame] = Color3.fromRGB(25, 26, 31),
	[Enum.StudioStyleGuideColor.CurrentMarker] = Color3.fromRGB(53, 55, 65),
	[Enum.StudioStyleGuideColor.Border] = Color3.fromRGB(32, 34, 39),
	[Enum.StudioStyleGuideColor.DropShadow] = Color3.fromRGB(0, 0, 0),
	[Enum.StudioStyleGuideColor.Shadow] = Color3.fromRGB(53, 55, 65),
	[Enum.StudioStyleGuideColor.Light] = Color3.fromRGB(53, 55, 65),
	[Enum.StudioStyleGuideColor.Dark] = Color3.fromRGB(32, 34, 39),
	[Enum.StudioStyleGuideColor.Mid] = Color3.fromRGB(32, 34, 39),
	[Enum.StudioStyleGuideColor.MainText] = Color3.fromRGB(188, 190, 200),
	[Enum.StudioStyleGuideColor.SubText] = Color3.fromRGB(188, 190, 200),
	[Enum.StudioStyleGuideColor.TitlebarText] = Color3.fromRGB(188, 190, 200),
	[Enum.StudioStyleGuideColor.BrightText] = Color3.fromRGB(230, 231, 234),
	[Enum.StudioStyleGuideColor.DimmedText] = Color3.fromRGB(106, 111, 129),
	[Enum.StudioStyleGuideColor.LinkText] = Color3.fromRGB(82, 139, 255),
	[Enum.StudioStyleGuideColor.WarningText] = Color3.fromRGB(245, 118, 48),
	[Enum.StudioStyleGuideColor.ErrorText] = Color3.fromRGB(231, 87, 80),
	[Enum.StudioStyleGuideColor.InfoText] = Color3.fromRGB(143, 180, 255),
	[Enum.StudioStyleGuideColor.SensitiveText] = Color3.fromRGB(223, 106, 247),
	[Enum.StudioStyleGuideColor.ScriptSideWidget] = Color3.fromRGB(32, 34, 39),
	[Enum.StudioStyleGuideColor.ScriptBackground] = Color3.fromRGB(40, 42, 54),
	[Enum.StudioStyleGuideColor.ScriptText] = Color3.fromRGB(248, 248, 242),
	[Enum.StudioStyleGuideColor.ScriptSelectionText] = Color3.fromRGB(68, 71, 90),
	[Enum.StudioStyleGuideColor.ScriptSelectionBackground] = Color3.fromRGB(168, 171, 190),
	[Enum.StudioStyleGuideColor.ScriptFindSelectionBackground] = Color3.fromRGB(68, 71, 90),
	[Enum.StudioStyleGuideColor.ScriptMatchingWordSelectionBackground] = Color3.fromRGB(68, 71, 90),
	[Enum.StudioStyleGuideColor.ScriptOperator] = Color3.fromRGB(255, 184, 108),
	[Enum.StudioStyleGuideColor.ScriptNumber] = Color3.fromRGB(189, 147, 249),
	[Enum.StudioStyleGuideColor.ScriptString] = Color3.fromRGB(241, 250, 140),
	[Enum.StudioStyleGuideColor.ScriptComment] = Color3.fromRGB(98, 114, 164),
	[Enum.StudioStyleGuideColor.ScriptKeyword] = Color3.fromRGB(255, 121, 198),
	[Enum.StudioStyleGuideColor.ScriptBuiltInFunction] = Color3.fromRGB(80, 250, 123),
	[Enum.StudioStyleGuideColor.ScriptWarning] = Color3.fromRGB(255, 184, 108),
	[Enum.StudioStyleGuideColor.ScriptError] = Color3.fromRGB(255, 85, 85),
	[Enum.StudioStyleGuideColor.ScriptInformation] = Color3.fromRGB(73, 77, 90),
	[Enum.StudioStyleGuideColor.ScriptHint] = Color3.fromRGB(51, 95, 255),
	[Enum.StudioStyleGuideColor.ScriptWhitespace] = Color3.fromRGB(60, 62, 74),
	[Enum.StudioStyleGuideColor.ScriptRuler] = Color3.fromRGB(68, 71, 90),
	[Enum.StudioStyleGuideColor.DocViewCodeBackground] = Color3.fromRGB(53, 55, 65),
	[Enum.StudioStyleGuideColor.DebuggerCurrentLine] = Color3.fromRGB(68, 71, 90),
	[Enum.StudioStyleGuideColor.DebuggerErrorLine] = Color3.fromRGB(255, 32, 32),
	[Enum.StudioStyleGuideColor.DiffFilePathText] = Color3.fromRGB(188, 190, 200),
	[Enum.StudioStyleGuideColor.DiffTextHunkInfo] = Color3.fromRGB(188, 190, 200),
	[Enum.StudioStyleGuideColor.DiffTextNoChange] = Color3.fromRGB(188, 190, 200),
	[Enum.StudioStyleGuideColor.DiffTextAddition] = Color3.fromRGB(188, 190, 200),
	[Enum.StudioStyleGuideColor.DiffTextDeletion] = Color3.fromRGB(188, 190, 200),
	[Enum.StudioStyleGuideColor.DiffTextSeparatorBackground] = Color3.fromRGB(53, 55, 65),
	[Enum.StudioStyleGuideColor.DiffTextNoChangeBackground] = Color3.fromRGB(25, 26, 31),
	[Enum.StudioStyleGuideColor.DiffTextAdditionBackground] = Color3.fromRGB(53, 55, 65),
	[Enum.StudioStyleGuideColor.DiffTextDeletionBackground] = Color3.fromRGB(87, 30, 0),
	[Enum.StudioStyleGuideColor.DiffLineNum] = Color3.fromRGB(188, 190, 200),
	[Enum.StudioStyleGuideColor.DiffLineNumSeparatorBackground] = Color3.fromRGB(73, 77, 90),
	[Enum.StudioStyleGuideColor.DiffLineNumNoChangeBackground] = Color3.fromRGB(32, 34, 39),
	[Enum.StudioStyleGuideColor.DiffLineNumAdditionBackground] = Color3.fromRGB(53, 55, 65),
	[Enum.StudioStyleGuideColor.DiffLineNumDeletionBackground] = Color3.fromRGB(87, 30, 0),
	[Enum.StudioStyleGuideColor.DiffFilePathBackground] = Color3.fromRGB(32, 34, 39),
	[Enum.StudioStyleGuideColor.DiffFilePathBorder] = Color3.fromRGB(32, 34, 39),
	[Enum.StudioStyleGuideColor.ChatIncomingBgColor] = Color3.fromRGB(230, 231, 234),
	[Enum.StudioStyleGuideColor.ChatIncomingTextColor] = Color3.fromRGB(53, 55, 65),
	[Enum.StudioStyleGuideColor.ChatOutgoingBgColor] = Color3.fromRGB(53, 55, 65),
	[Enum.StudioStyleGuideColor.ChatOutgoingTextColor] = Color3.fromRGB(188, 190, 200),
	[Enum.StudioStyleGuideColor.ChatModeratedMessageColor] = Color3.fromRGB(231, 87, 80),
	[Enum.StudioStyleGuideColor.Separator] = Color3.fromRGB(32, 34, 39),
	[Enum.StudioStyleGuideColor.ButtonBorder] = Color3.fromRGB(53, 53, 53),
	[Enum.StudioStyleGuideColor.ButtonText] = Color3.fromRGB(188, 190, 200),
	[Enum.StudioStyleGuideColor.InputFieldBorder] = Color3.fromRGB(40, 41, 49),
	[Enum.StudioStyleGuideColor.CheckedFieldBackground] = Color3.fromRGB(40, 41, 49),
	[Enum.StudioStyleGuideColor.CheckedFieldBorder] = Color3.fromRGB(40, 41, 49),
	[Enum.StudioStyleGuideColor.CheckedFieldIndicator] = Color3.fromRGB(82, 139, 255),
	[Enum.StudioStyleGuideColor.HeaderSection] = Color3.fromRGB(32, 34, 39),
	[Enum.StudioStyleGuideColor.Midlight] = Color3.fromRGB(32, 34, 39),
	[Enum.StudioStyleGuideColor.StatusBar] = Color3.fromRGB(25, 26, 31),
	[Enum.StudioStyleGuideColor.DialogButton] = Color3.fromRGB(53, 55, 65),
	[Enum.StudioStyleGuideColor.DialogButtonText] = Color3.fromRGB(188, 190, 200),
	[Enum.StudioStyleGuideColor.DialogButtonBorder] = Color3.fromRGB(53, 55, 65),
	[Enum.StudioStyleGuideColor.DialogMainButton] = Color3.fromRGB(51, 95, 255),
	[Enum.StudioStyleGuideColor.DialogMainButtonText] = Color3.fromRGB(255, 255, 255),
	[Enum.StudioStyleGuideColor.InfoBarWarningBackground] = Color3.fromRGB(250, 228, 170),
	[Enum.StudioStyleGuideColor.InfoBarWarningText] = Color3.fromRGB(0, 0, 0),
	[Enum.StudioStyleGuideColor.ScriptEditorCurrentLine] = Color3.fromRGB(68, 71, 90),
	[Enum.StudioStyleGuideColor.ScriptMethod] = Color3.fromRGB(80, 250, 123),
	[Enum.StudioStyleGuideColor.ScriptProperty] = Color3.fromRGB(139, 233, 253),
	[Enum.StudioStyleGuideColor.ScriptNil] = Color3.fromRGB(255, 184, 108),
	[Enum.StudioStyleGuideColor.ScriptBool] = Color3.fromRGB(255, 184, 108),
	[Enum.StudioStyleGuideColor.ScriptFunction] = Color3.fromRGB(80, 250, 123),
	[Enum.StudioStyleGuideColor.ScriptLocal] = Color3.fromRGB(255, 121, 198),
	[Enum.StudioStyleGuideColor.ScriptSelf] = Color3.fromRGB(255, 184, 108),
	[Enum.StudioStyleGuideColor.ScriptLuauKeyword] = Color3.fromRGB(255, 121, 198),
	[Enum.StudioStyleGuideColor.ScriptFunctionName] = Color3.fromRGB(80, 250, 123),
	[Enum.StudioStyleGuideColor.ScriptTodo] = Color3.fromRGB(255, 184, 108),
	[Enum.StudioStyleGuideColor.ScriptBracket] = Color3.fromRGB(248, 248, 242),
	[Enum.StudioStyleGuideColor.AttributeCog] = Color3.fromRGB(188, 190, 200),
	[Enum.StudioStyleGuideColor.AICOOverlayText] = Color3.fromRGB(255, 255, 255),
	[Enum.StudioStyleGuideColor.AICOOverlayButtonBackground] = Color3.fromRGB(53, 55, 65),
	[Enum.StudioStyleGuideColor.AICOOverlayButtonBackgroundHover] = Color3.fromRGB(53, 55, 65),
	[Enum.StudioStyleGuideColor.AICOOverlayButtonBackgroundPressed] = Color3.fromRGB(53, 55, 65),
	[Enum.StudioStyleGuideColor.OnboardingCover] = Color3.fromRGB(51, 95, 255),
	[Enum.StudioStyleGuideColor.OnboardingHighlight] = Color3.fromRGB(82, 139, 255),
	[Enum.StudioStyleGuideColor.OnboardingShadow] = Color3.fromRGB(0, 0, 0),
	[Enum.StudioStyleGuideColor.BreakpointMarker] = Color3.fromRGB(231, 87, 80),
	[Enum.StudioStyleGuideColor.DiffLineNumHover] = Color3.fromRGB(255, 255, 255),
	[Enum.StudioStyleGuideColor.DiffLineNumSeparatorBackgroundHover] = Color3.fromRGB(82, 139, 255),
}

local function getThemeColor(color, modifier)
	if Studio then
		return Studio.Theme:GetColor(
			color,
			modifier or Enum.StudioStyleGuideModifier.Default
		)
	end

	return RuntimeColors[color] or Color3.new(1, 1, 1)
end

local themeProvider = {
	Theme = Value("Dark"),
	Fonts = {
		Default = Enum.Font.SourceSans,
		SemiBold = Enum.Font.SourceSansSemibold,
		Bold = Enum.Font.SourceSansBold,
		Black = Enum.Font.GothamBlack,
		Mono = Enum.Font.Code,
	},
	IsDark = Value(true),
}

function themeProvider:GetColor(studioStyleGuideColor: styleStyleGuideColor, studioStyleGuideModifier: styleGuideModifier?): computedOrValue
	local hasState =
		(unwrap(studioStyleGuideModifier, false) ~= studioStyleGuideModifier)
		or (unwrap(studioStyleGuideColor, false) ~= studioStyleGuideColor)

	local function isCorrectType(value, enumType)
		local unwrapped = unwrap(value, false)
		local isState = unwrapped ~= value and unwrapped ~= nil
		assert(
			(value == nil or isState)
				or (typeof(value) == "EnumItem" and value.EnumType == enumType),
			"Incorrect type"
		)
	end

	isCorrectType(studioStyleGuideColor, Enum.StudioStyleGuideColor)
	isCorrectType(studioStyleGuideModifier, Enum.StudioStyleGuideModifier)

	local unwrappedColor = unwrap(studioStyleGuideColor, false)
	local unwrappedModifier = unwrap(studioStyleGuideModifier, false)

	currentTheme[unwrappedColor] = currentTheme[unwrappedColor] or {}

	local themeValue = (function()
		local modifier = unwrappedModifier or Enum.StudioStyleGuideModifier.Default

		local existing = currentTheme[unwrappedColor][modifier]
		if existing then
			return existing
		end

		local value = Value(getThemeColor(unwrappedColor, modifier))
		currentTheme[unwrappedColor][modifier] = value

		return value
	end)()

	if not hasState then
		return themeValue
	end

	return Computed(function()
		local currentColor = unwrap(studioStyleGuideColor)
		local currentModifier = unwrap(studioStyleGuideModifier)
		return self:GetColor(currentColor, currentModifier):get()
	end)
end

function themeProvider:GetFont(fontName: (string | types.StateObject<string>)?): types.Computed<Enum.Font>
	return Computed(function()
		local givenFontName = unwrap(fontName)
		local fontToGet = self.Fonts.Default

		if givenFontName and self.Fonts[givenFontName] then
			fontToGet = self.Fonts[givenFontName]
		end

		return unwrap(fontToGet)
	end)
end

local function updateTheme()
	for color, modifiers in pairs(currentTheme) do
		for modifier, valueState in pairs(modifiers) do
			valueState:set(getThemeColor(color, modifier))
		end
	end

	if Studio then
		themeProvider.Theme:set(Studio.Theme.Name)

		local _, _, v =
			Studio.Theme:GetColor(Enum.StudioStyleGuideColor.MainBackground):ToHSV()

		themeProvider.IsDark:set(v <= 0.6)
	else
		themeProvider.Theme:set("Dark")
		themeProvider.IsDark:set(true)
	end
end

if Studio then
	local connection = Studio.ThemeChanged:Connect(updateTheme)

	updateTheme()

	if Plugin and Plugin.Unloading then
		Plugin.Unloading:Connect(function()
			connection:Disconnect()
		end)
	end
else
	updateTheme()
end

return themeProvider