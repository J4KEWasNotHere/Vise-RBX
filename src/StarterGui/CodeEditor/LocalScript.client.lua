local Packages = script.Parent.Packages
local Components = script.Parent.Components
local Checkbox = require(Components.Checkbox)
local MainButton = require(Components.MainButton)
local ScrollFrame = require(Components.ScrollFrame)
local Label = require(Components.Label)
local LabelImage = require(Components.LabelImage)
local Paragraph = require(Components.Paragraph)
local TextInput = require(Components.TextInput)
local VerticalExpandingList = require(Components.VerticalExpandingList)
local VerticalCollapsibleSection = require(Components.VerticalCollapsibleSection)
local Seperator = require(Components.Seperator)
local Loading = require(Components.Loading)
local Fusion = require(Packages.Fusion)

local New = Fusion.New
local Value = Fusion.Value
local Children = Fusion.Children
local OnChange = Fusion.OnChange
local OnEvent = Fusion.OnEvent
local Observer = Fusion.Observer
local Computed = Fusion.Computed
local unwrap = Fusion.unwrap
local Ref = Fusion.Ref

local function stringToTable(str: string)
	local tbl = {}
	for line in string.gmatch(str, "[^\r\n]+") do
		table.insert(tbl, line)
	end
	return tbl
end

local function makeCard(contents, y: NumberRange?)
	return New("Frame")({
		Size = UDim2.new(1, 0, 0, 0),
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
end

local ScreenGui = script.Parent
local Frame = script.Parent.Frame

local source = Value({})
source:set(stringToTable([[@include shader_type canvas_item; -- canvas_item / spatial (3d)

-- defining globa variables (editable)
@export float:var hint_range(0.0, 1.0, 0.1) = 1.0; -- floats must have decimals

-- defining static variables
local world_uv: Vector2;
const test: string = "test";

-- number is available but in double form

float:lerp(a: float, b: float, float: float) {
	return a + (b - a) * c;
}

nil:vertex() {
	-- Called for every vertex the material is visible on.
	
	world_uv = (MODEL_MATRIX * vec4(VERTEX.xy, 0.0, 1.0)).xy / 128.0;
}

(nil):fragment() {
	-- Called for every pixel the material is visible on.
	center: Vector2 = Vector2.new(0, 0);
	vec: Vector2 = UV - center;
	
	dist: number = math.sqrt(math.pow(vec.X, 2) + math.pow(vec.Y, 2));
	
	COLOR = texture(TEXTURE, UV);
}]]))

local coloredText = Value({})

local textBoxRefs = {}

local UserInputService = game:GetService("UserInputService")

local KEYWORDS = {
	["local"] = true, ["const"] = true, ["return"] = true, ["if"] = true,
	["then"] = true, ["else"] = true, ["elseif"] = true, ["end"] = true,
	["function"] = true, ["for"] = true, ["while"] = true, ["do"] = true,
	["in"] = true, ["break"] = true, ["continue"] = true, ["repeat"] = true,
	["until"] = true, ["and"] = true, ["or"] = true, ["not"] = true,
	["true"] = true, ["false"] = true, ["self"] = true,
}

local TYPES = {
	["float"] = true, ["number"] = true, ["string"] = true, ["bool"] = true,
	["boolean"] = true, ["int"] = true, ["nil"] = true,
	["Vector2"] = true, ["Vector3"] = true, ["Vector4"] = true,
	["vec2"] = true, ["vec3"] = true, ["vec4"] = true,
	["mat3"] = true, ["mat4"] = true, ["sampler2D"] = true, ["void"] = true,
}

local BUILTINS = {
	["shader_type"] = true, ["canvas_item"] = true, ["spatial"] = true,
	["hint_range"] = true, ["MODEL_MATRIX"] = true, ["VIEW_MATRIX"] = true,
	["PROJECTION_MATRIX"] = true, ["VERTEX"] = true, ["UV"] = true,
	["NORMAL"] = true, ["TEXTURE"] = true, ["COLOR"] = true,
	["TIME"] = true, ["FRAGCOORD"] = true, ["math"] = true,
}

local COLORS = {
	keyword = "C586C0",
	type = "4EC9B0",
	builtin = "DCDCAA",
	comment = "6A9955",
	string = "CE9178",
	number = "B5CEA8",
	decorator = "D16969",
	func = "DCDCAA",
	default = "D4D4D4",
}

local function escapeRich(s: string): string
	s = s:gsub("&", "&amp;")
	s = s:gsub("<", "&lt;")
	s = s:gsub(">", "&gt;")
	s = s:gsub('"', "&quot;")
	return s
end

local function wrap(text: string, color: string): string
	if text == "" then return "" end
	return string.format('<font color="#%s">%s</font>', color, escapeRich(text))
end

local function highlightLine(line: string): string
	local result = {}
	local pos, len = 1, #line

	while pos <= len do
		local c = line:sub(pos, pos)

		if c == " " or c == "\t" then
			local startPos = pos
			while pos <= len and (line:sub(pos, pos) == " " or line:sub(pos, pos) == "\t") do
				pos += 1
			end
			table.insert(result, escapeRich(line:sub(startPos, pos - 1)))

		elseif line:sub(pos, pos + 1) == "--" then
			table.insert(result, wrap(line:sub(pos), COLORS.comment))
			pos = len + 1

		elseif c == '"' or c == "'" then
			local quote = c
			local startPos = pos
			pos += 1
			while pos <= len and line:sub(pos, pos) ~= quote do
				if line:sub(pos, pos) == "\\" then pos += 1 end
				pos += 1
			end
			pos = math.min(pos, len) + 1
			table.insert(result, wrap(line:sub(startPos, pos - 1), COLORS.string))

		elseif c == "@" then
			local startPos = pos
			pos += 1
			while pos <= len and line:sub(pos, pos):match("[%a_]") do pos += 1 end
			table.insert(result, wrap(line:sub(startPos, pos - 1), COLORS.decorator))

		elseif c:match("%d") then
			local startPos = pos
			while pos <= len and line:sub(pos, pos):match("[%d%.]") do pos += 1 end
			table.insert(result, wrap(line:sub(startPos, pos - 1), COLORS.number))

		elseif c:match("[%a_]") then
			local startPos = pos
			while pos <= len and line:sub(pos, pos):match("[%w_]") do pos += 1 end
			local word = line:sub(startPos, pos - 1)

			local peek = pos
			while peek <= len and line:sub(peek, peek) == " " do peek += 1 end
			local isCall = line:sub(peek, peek) == "("

			if KEYWORDS[word] then
				table.insert(result, wrap(word, COLORS.keyword))
			elseif TYPES[word] then
				table.insert(result, wrap(word, COLORS.type))
			elseif BUILTINS[word] then
				table.insert(result, wrap(word, COLORS.builtin))
			elseif isCall then
				table.insert(result, wrap(word, COLORS.func))
			else
				table.insert(result, wrap(word, COLORS.default))
			end

		else
			table.insert(result, escapeRich(c))
			pos += 1
		end
	end

	return table.concat(result) 
end

local function tokenizeLine(line: string)
	local tokens = {}
	local pos, len = 1, #line

	local function push(text, color, startCol)
		table.insert(tokens, { text = text, color = color, startCol = startCol, endCol = startCol + #text - 1 })
	end

	while pos <= len do
		local c = line:sub(pos, pos)

		if c == " " or c == "\t" then
			local startPos = pos
			while pos <= len and (line:sub(pos, pos) == " " or line:sub(pos, pos) == "\t") do
				pos += 1
			end
			push(line:sub(startPos, pos - 1), nil, startPos)

		elseif line:sub(pos, pos + 1) == "--" then
			push(line:sub(pos), "comment", pos)
			pos = len + 1

		elseif c == '"' or c == "'" then
			local quote = c
			local startPos = pos
			pos += 1
			while pos <= len and line:sub(pos, pos) ~= quote do
				if line:sub(pos, pos) == "\\" then pos += 1 end
				pos += 1
			end
			pos = math.min(pos, len) + 1
			push(line:sub(startPos, pos - 1), "string", startPos)

		elseif c == "@" then
			local startPos = pos
			pos += 1
			while pos <= len and line:sub(pos, pos):match("[%a_]") do pos += 1 end
			push(line:sub(startPos, pos - 1), "decorator", startPos)

		elseif c:match("%d") then
			local startPos = pos
			while pos <= len and line:sub(pos, pos):match("[%d%.]") do pos += 1 end
			push(line:sub(startPos, pos - 1), "number", startPos)

		elseif c:match("[%a_]") then
			local startPos = pos
			while pos <= len and line:sub(pos, pos):match("[%w_]") do pos += 1 end
			local word = line:sub(startPos, pos - 1)

			local peek = pos
			while peek <= len and line:sub(peek, peek) == " " do peek += 1 end
			local isCall = line:sub(peek, peek) == "("

			local color
			if KEYWORDS[word] then color = "keyword"
			elseif TYPES[word] then color = "type"
			elseif BUILTINS[word] then color = "builtin"
			elseif isCall then color = "func"
			else color = "default" end

			push(word, color, startPos)

		else
			push(c, "default", pos)
			pos += 1
		end
	end

	return tokens
end

local BRACKET_PAIRS = { ["("] = ")", ["["] = "]", ["{"] = "}" }
local CLOSING_TO_OPENING = { [")"] = "(", ["]"] = "[", ["}"] = "{" }

local errorsByLine = Value({}) -- [lineIndex] = { {col=, len=, message=}, ... }

local function recomputeErrors()
	local lines = unwrap(source)
	local errors = {}
	local stack = {} -- { char=, line=, col= }

	local function addError(lineIndex, col, len, message)
		if not errors[lineIndex] then errors[lineIndex] = {} end
		table.insert(errors[lineIndex], { col = col, len = len, message = message })
	end

	for lineIndex, line in ipairs(lines) do
		local pos, len = 1, #line
		while pos <= len do
			local c = line:sub(pos, pos)

			if line:sub(pos, pos + 1) == "--" then
				break -- rest of line is a comment; nothing after this matters

			elseif c == '"' or c == "'" then
				local quote = c
				local startCol = pos
				pos += 1
				local closed = false
				while pos <= len do
					local cc = line:sub(pos, pos)
					if cc == "\\" then
						pos += 2
					elseif cc == quote then
						closed = true
						pos += 1
						break
					else
						pos += 1
					end
				end
				if not closed then
					addError(lineIndex, startCol, len - startCol + 1, "Unterminated string")
				end

			elseif BRACKET_PAIRS[c] then
				table.insert(stack, { char = c, line = lineIndex, col = pos })
				pos += 1

			elseif CLOSING_TO_OPENING[c] then
				local top = stack[#stack]
				if top and top.char == CLOSING_TO_OPENING[c] then
					table.remove(stack)
				else
					addError(lineIndex, pos, 1, `Unmatched '{c}'`)
				end
				pos += 1

			else
				pos += 1
			end
		end
	end

	-- anything left on the stack never got closed
	for _, unclosed in ipairs(stack) do
		addError(unclosed.line, unclosed.col, 1, `Unclosed '{unclosed.char}'`)
	end

	errorsByLine:set(errors)
end

COLORS.error = "F44747" -- vscode-style error red

local function rangesOverlap(aStart, aEnd, bStart, bEnd)
	return aStart <= bEnd and bStart <= aEnd
end

local function renderLine(line: string, lineErrors)
	local tokens = tokenizeLine(line)
	local parts = {}

	for _, token in ipairs(tokens) do
		if token.text == "" then continue end

		local isError = false
		if lineErrors then
			for _, err in ipairs(lineErrors) do
				if rangesOverlap(token.startCol, token.endCol, err.col, err.col + err.len - 1) then
					isError = true
					break
				end
			end
		end

		if isError then
			table.insert(parts, string.format('<font color="#%s"><u>%s</u></font>', COLORS.error, escapeRich(token.text)))
		elseif token.color and COLORS[token.color] then
			table.insert(parts, wrap(token.text, COLORS[token.color]))
		else
			table.insert(parts, escapeRich(token.text))
		end
	end

	return table.concat(parts)
end

local function getFocusedIndex(): number?
	local focusedBox = UserInputService:GetFocusedTextBox()
	if not focusedBox then
		return nil
	end
	for i, ref in pairs(textBoxRefs) do
		if unwrap(ref) == focusedBox then
			return i
		end
	end
	return nil
end

local function createLine(index: number, sourceText: string)
	local textBoxRef = Value(nil)
	textBoxRefs[index] = textBoxRef

	local lineTextValue = Value(sourceText)
	local highlighted = Computed(function()
		local errs = unwrap(errorsByLine)
		return renderLine(unwrap(lineTextValue), errs[index])
	end)

	local cursorPos = -1
	local isFocused = Value(false)
	
	local textBox: TextBox; textBox = New("TextBox")({
		[Ref] = textBoxRef,
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		ClearTextOnFocus = false,
		RichText = false,
		TextColor3 = Color3.new(1, 1, 1),
		TextTransparency = Computed(function()
			return unwrap(isFocused) == true and 0.75 or 1
		end),
		ZIndex = 2,

		Text = sourceText,
		Font = Enum.Font.Code,
		TextSize = 15,
		AutomaticSize = Enum.AutomaticSize.X,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Center,

		[OnEvent("Changed")] = function(prop: string)
			if prop == "Text" then
				local currentLines = unwrap(source)
				currentLines[index] = textBox.Text
				lineTextValue:set(textBox.Text)
				recomputeErrors()
			elseif prop == "CursorPosition" and textBox:IsFocused() then
				cursorPos = textBox.CursorPosition
			end
			isFocused:set(textBox:IsFocused())
		end,
		
		[OnEvent("FocusLost")] = function(enterPressed: boolean, input: InputObject)
			isFocused:set(false)
			if not enterPressed then return end
			
			if cursorPos == -1 then
				cursorPos = #textBox.Text + 1
			end

			local fullText = textBox.Text
			local beforeText = string.sub(fullText, 1, cursorPos - 1)
			local afterText = string.sub(fullText, cursorPos)
			
			local currentLines = unwrap(source)
			local newLines = table.clone(currentLines)
			newLines[index] = beforeText
			table.insert(newLines, index + 1, afterText)
			source:set(newLines)
			
			task.defer(function()
				local nextBox = unwrap(textBoxRefs[index + 1])
				if nextBox then
					nextBox:CaptureFocus()
					nextBox.CursorPosition = 1
				end
			end)
		end
	})
	
	local highlightLabel = New("TextLabel")({
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		RichText = true,
		Interactable = false,
		Active = false,
		Text = highlighted,
		Font = Enum.Font.Code,
		TextSize = 15,
		TextColor3 = Color3.fromRGB(212, 212, 212),
		AutomaticSize = Enum.AutomaticSize.X,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Center,
	})
	
	local lineFrame = New("Frame")({
		Size = UDim2.new(1, 0, 0, 22),
		AutomaticSize = Enum.AutomaticSize.X,
		BackgroundTransparency = 1,
		LayoutOrder = index,

		[Children] = {
			New("UIListLayout")({
				FillDirection = Enum.FillDirection.Horizontal,
				SortOrder = Enum.SortOrder.LayoutOrder,
				VerticalAlignment = Enum.VerticalAlignment.Center,
			}),

			New("Frame")({
				Size = UDim2.fromOffset(40, 22),
				BackgroundTransparency = 1,
				LayoutOrder = 1,
				[Children] = {
					New("TextLabel")({
						Size = UDim2.fromScale(1, 1),
						BackgroundTransparency = 1,
						RichText = true,
						Text = Computed(function()
							return unwrap(isFocused) and `<b>{tostring(index)}</b>` or tostring(index)
						end),
						TextXAlignment = Enum.TextXAlignment.Right,
						Font = Enum.Font.Code,
						TextSize = 15,
						TextColor3 = Computed(function()
							local errs = unwrap(errorsByLine)
							if errs[index] then
								return Color3.fromRGB(244, 71, 71)
							end
							return Color3.fromRGB(130, 130, 130)
						end),
					}),
				},
			}),

			New("Frame")({
				Size = UDim2.fromOffset(18, 22),
				BackgroundTransparency = 1,
				LayoutOrder = 2,
				[Children] = {
					New("TextLabel")({
						Size = UDim2.fromScale(1, 1),
						BackgroundTransparency = 1,
						Text = "",
						Font = Enum.Font.Code,
						TextSize = 14,
						TextColor3 = Color3.fromRGB(170, 170, 170),
						TextXAlignment = Enum.TextXAlignment.Center,
					}),
				},
			}),

			New("Frame")({
				Size = UDim2.new(1, -58, 1, 0),
				AutomaticSize = Enum.AutomaticSize.X,
				BackgroundTransparency = 1,
				LayoutOrder = 3,
				[Children] = { textBox, highlightLabel },
			}),
		},
	})
	
	return lineFrame
end

local lineComponents = Computed(function()
	table.clear(textBoxRefs)
	local components = {}
	for i, line in ipairs(unwrap(source)) do
		table.insert(components, createLine(i, line))
	end
	return components
end)

local WhiteBg = "rbxasset://textures/ui/InGameMenu/WhiteSquare.png"
recomputeErrors()
local BaseFrame = New("ScrollingFrame")({
	Parent = ScreenGui,

	Size = Frame.Size,
	Position = Frame.Position,
	AnchorPoint = Frame.AnchorPoint,
	BackgroundColor3 = Frame.BackgroundColor3,
	AutomaticSize = Frame.AutomaticSize,
	BackgroundTransparency = Frame.BackgroundTransparency,
	ClipsDescendants = true,

	CanvasSize = UDim2.new(0, 0, 0, 0),
	AutomaticCanvasSize = Enum.AutomaticSize.XY,
	
	TopImage = WhiteBg,
	MidImage = WhiteBg,
	BottomImage = WhiteBg,
	
	ScrollBarThickness = 12,
	ScrollBarImageTransparency = 0.75,
	ScrollBarImageColor3 = Color3.fromRGB(255, 255, 255),
	
	ScrollingDirection = Enum.ScrollingDirection.XY,
	VerticalScrollBarInset = Enum.ScrollBarInset.Always,
	HorizontalScrollBarInset = Enum.ScrollBarInset.Always,
	

	[Children] = {
		New("UIPadding")({
			PaddingTop = UDim.new(0, 10),
			PaddingLeft = UDim.new(0, 10),
			PaddingBottom = UDim.new(0, 10),
			PaddingRight = UDim.new(0, 10),
		}),

		New("UIListLayout")({
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = UDim.new(0, 0),
		}),

		lineComponents,
	},
})

UserInputService.InputBegan:Connect(function(input: InputObject, gameProcessedEvent: boolean)
	if input.UserInputType ~= Enum.UserInputType.Keyboard then
		return
	end

	local index: number? = getFocusedIndex()
	if not index then
		return
	end

	local textBox: TextBox = unwrap(textBoxRefs[index])
	if not textBox then
		return
	end

	if input.KeyCode == Enum.KeyCode.Up then
		local cursorPos = textBox.CursorPosition
		if cursorPos == -1 then
			cursorPos = #textBox.Text + 1
		end

		local prevRef = textBoxRefs[index - 1]
		local prevBox = prevRef and unwrap(prevRef)
		if prevBox then
			prevBox:CaptureFocus()
			prevBox.CursorPosition = math.min(cursorPos, #prevBox.Text + 1)
		end
	elseif input.KeyCode == Enum.KeyCode.Down then
		local cursorPos = textBox.CursorPosition
		if cursorPos == -1 then
			cursorPos = #textBox.Text + 1
		end

		local nextRef = textBoxRefs[index + 1]
		local nextBox = nextRef and unwrap(nextRef)
		if nextBox then
			nextBox:CaptureFocus()
			nextBox.CursorPosition = math.min(cursorPos, #nextBox.Text + 1)
		end
	elseif input.KeyCode == Enum.KeyCode.Backspace then
		local cursorPos = textBox.CursorPosition
		if cursorPos == -1 then
			cursorPos = #textBox.Text + 1
		end

		if cursorPos ~= 1 then
			return
		elseif index <= 1 then
			return 
		end

		local currentLines = unwrap(source)
		local prevText = currentLines[index - 1]
		local currentText = textBox.Text
		local mergedCursorPos = #prevText + 1

		local newLines = table.clone(currentLines)
		newLines[index - 1] = prevText .. currentText
		table.remove(newLines, index)
		source:set(newLines)

		task.defer(function()
			local prevBox = unwrap(textBoxRefs[index - 1])
			if prevBox then
				prevBox:CaptureFocus()
				prevBox.CursorPosition = mergedCursorPos
			end
		end)
	end
end)

Frame:Destroy()