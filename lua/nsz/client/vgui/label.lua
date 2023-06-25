-- This label element is like a regular DLabel, except with line wrapping based on a set width

function nsz.makeTextFit(font, text, maximumWidth)
    if not isstring(font) then error("Bad argument #1: Expected a string, got " .. type(font)) end
    if not isstring(text) then error("Bad argument #2: Expected a string, got " .. type(text)) end
    if not isnumber(maximumWidth) then error("Bad argument #3: Expected a number, got " .. type(maximumWidth)) end

    surface.SetFont(font)
    local width, height = surface.GetTextSize(text)

    if width <= maximumWidth then 
        return {text}, height
    end
    

    local linesOfText = {}
    local totalHeight = 0

    local lastLineBreakPointer = 1
    local pointer = 0
    local textLength = #text

    -- spaces take priority over line break characters. Also line breakers are preserved while spaces are thrown out if used to insert a line break
    local lastSpaceIndex = 0 
    local lastLineBreakIndex = 0
    local lineBreakLetters = {"-", "/"}

    -- Preventing the game from crashing from being caught in a never ending while loop
    local iteration = 0
    local maxIterations = 512

    while pointer < textLength and iteration < maxIterations do 
        iteration = iteration + 1
        pointer = pointer + 1
        local thisLetter = text[pointer]

        local width, height = surface.GetTextSize(string.sub(text, lastLineBreakPointer, pointer))
        if thisLetter == "\n" then 
            table.insert(linesOfText, string.sub(text, lastLineBreakPointer, pointer))
            
            lastLineBreakPointer = pointer
            totalHeight = totalHeight + height

            lastSpaceIndex = 0
            lastLineBreakIndex = 0
        elseif thisLetter == " " then 
            lastSpaceIndex = pointer
        elseif table.HasValue(lineBreakLetters, thisLetter) then 
            lastLineBreakIndex = pointer
        end

        if width > maximumWidth then 
            local skip = true
            if lastSpaceIndex > 0 then 
                pointer = lastSpaceIndex
                lastSpaceIndex = 0
            elseif lastLineBreakIndex > 0 then 
                pointer = lastLineBreakIndex
                lastLineBreakIndex = 0
                skip = false
            else 
                pointer = pointer - 1
            end

            table.insert(linesOfText, string.Trim(string.sub(text, lastLineBreakPointer, pointer)))
            
            lastLineBreakPointer = pointer
            totalHeight = totalHeight + height

            if not skip then pointer = pointer - 1 end
        end
    end

    local remainingText = string.Trim(string.sub(text, lastLineBreakPointer))
    if remainingText ~= "" then 
        table.insert(linesOfText, remainingText)
        totalHeight = totalHeight + height
    end

    return linesOfText, totalHeight
end

local NSZLabel = {}
function NSZLabel:Init()
    self.text = "Label"
    self.font = "nsz_between"
    self.textColor = Color(255, 255, 255)
    self.autoResize = true

    self.autoHeight = 0

    self.cache = {width = nil, text = nil, font = nil} -- A cache of stuff to monitor every frame. If any of these changes, the render variable below is refreshed and the autoHeight is recalculated
    self.lines = {} -- Each line of text that fits in the width
end

function NSZLabel:SetText(txt)
    if not isstring(txt) then return end
    self.text = txt
end
function NSZLabel:GetText() return self.text end

function NSZLabel:SetFont(font)
    if not isstring(font) then return end
    self.font = font
end
function NSZLabel:GetFont() return self.font end

function NSZLabel:SetTextColor(col)
    if not IsColor(col) then return end
    self.textColor = col
end
function NSZLabel:GetTextColor() return self.textColor end

function NSZLabel:SetAutoResize(resize)
    if not isbool(resize) then return end
    self.autoResize = resize
end
function NSZLabel:GetAutoResize() return self.autoResize end

function NSZLabel:SizeToContentsX() end
function NSZLabel:SizeToContentsY()
    local lines, height = nsz.makeTextFit(self:GetFont(), self:GetText(), self:GetWide())
    self.lines = lines
    self:SetTall(height)
end
function NSZLabel:SizeToContents()
    self:SizeToContentsY()
end

function NSZLabel:Paint(w, h)
    local textDif  = (self:GetText() ~= self.cache.text )
    local fontDif  = (self:GetFont() ~= self.cache.font )
    local widthDif = (             w ~= self.cache.width)

    -- Monitor properties that affect how the text is displayed
    if textDif or fontDif or widthDif then 
        self.cache.text  = self:GetText()
        self.cache.font  = self:GetFont()
        self.cache.width = w 

        local lines, height = nsz.makeTextFit(self:GetFont(), self:GetText(), w)
        self.lines = lines
        self.autoHeight = height

        if self:GetAutoResize() then self:SetTall(height) end
    end

    local lineHeight = h / #self.lines 
    for i, line in ipairs(self.lines) do 
        draw.SimpleText(line, self:GetFont(), 0, (i - 1) * lineHeight, self:GetTextColor())
    end
end

vgui.Register("NSZLabel", NSZLabel, "DPanel")