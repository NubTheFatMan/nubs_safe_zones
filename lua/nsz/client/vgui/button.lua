local NSZButton = {}
function NSZButton:Init()
    self.text = "Button"
    self:SetFont("nsz_between")
    self:SetTextColor(Color(255, 255, 255))

    self.color = {}
    self.color.normal   = Color(  0, 150, 255)
    self.color.hovered  = nsz.ShiftColor(self.color.normal, 25)
    self.color.down     = nsz.ShiftColor(self.color.normal, 10)
    self.color.shadow   = nsz.ShiftColor(self.color.normal, -50)
    self.color.disabled = nsz.ShiftColor(self.color.normal, -15)

    self.padding = 4

    self.icon = nil

    self.buttonSounds = {
        {"nsz/clickdown.ogg", "nsz/clickup.ogg"}
    }
    self.selectedSound = 1

    -- The paint function doesn't let me change how the text is shown on the button, so I use a separate variable and override this
    self:SetText("")

    -- These functions are inside init to allow the SetText above to work without conflicts

    function self:SetText(text)
        if not isstring(text) then return end
        self.text = text
    end
    function self:GetText()
        return self.text
    end
end

function NSZButton:GetTextSize()
    surface.SetFont(self:GetFont())
    local w, h = surface.GetTextSize(self:GetText())

    if isstring(self.icon) then 
        local iconWidth = math.min(self:GetWide(), self:GetTall())
        w = w + iconWidth + 8
    end
    
    return w, h
end
function NSZButton:SizeToContents()
    local w, h = self:GetTextSize()
    self:SetSize(w + self.padding * 2, h + self.padding * 2)
end
function NSZButton:SizeToContentsX()
    local w, _ = self:GetTextSize()
    self:SetWide(w + self.padding * 2)
end
function NSZButton:SizeToContentsY()
    local _, h = self:GetTextSize()
    self:SetTall(h + self.padding * 2)
end

function NSZButton:SetColor(color)
    if not IsColor(color) then return end

    self.color.normal   = color
    self.color.hovered  = nsz.ShiftColor(self.color.normal, 25)
    self.color.down     = nsz.ShiftColor(self.color.normal, 10)
    self.color.shadow   = nsz.ShiftColor(self.color.normal, -50)
    self.color.disabled = nsz.ShiftColor(self.color.normal, -15)
end
function NSZButton:GetColor()
    return self.color.normal
end

function NSZButton:GetPressSounds()
    if isnumber(self.selectedSound) then
        return self.buttonSounds[self.selectedSound]
    end
end

function NSZButton:SetPressSounds(ind)
    if not isnumber(ind) then return end

    self.selectedSound = ind
end

function NSZButton:OnDepressed()
    local sounds = self:GetPressSounds()
    if istable(sounds) and isstring(sounds[1]) then
        surface.PlaySound(sounds[1])
    end
end
function NSZButton:OnReleased()
    local sounds = self:GetPressSounds()
    if istable(sounds) and isstring(sounds[2]) then
        surface.PlaySound(sounds[2])
    end
end

local icons = {}
function NSZButton:SetIcon(icon)
    if not isstring(icon) then return end 
    self.icon = icon 
end
function NSZButton:GetIcon() return self.icon end
function NSZButton:GetIconMaterial() return icons[self.icon] end

function NSZButton:Paint(w, h) 
    local offset = (self:IsEnabled() and (self:IsDown() and 2 or 0)) or 0

    local color = self:GetColor()
    local tc    = self:GetTextColor()

    if self:IsEnabled() then
        if self:IsDown() then
            color = self.color.down
        elseif self:IsHovered() then
            color = self.color.hovered
        end
    else 
        color = self.color.disabled
    end

    draw.RoundedBox(0, 0, offset, w, h, color)

    if self:IsEnabled() and not self:IsDown() then
        draw.RoundedBox(0, 0, h-2, w, 2, self.color.shadow)
    end

    -- Icon 
    local ico 
    if isstring(self.icon) then 
        if not icons[self.icon] then icons[self.icon] = Material(self.icon) end
        ico = icons[self.icon]
    end

    local textPos = 0
    local iconPos = 0
    local iconWid = math.min(w, h) - 8

    surface.SetFont(self:GetFont())
    local wid = surface.GetTextSize(self:GetText())

    if ico ~= nil then 
        if self:GetText() ~= "" then 
            textPos = w/2 + iconWid/2
            iconPos = textPos - wid/2 - iconWid - 4
        else 
            iconPos = w/2 - iconWid/2
        end

        if self.icon == "icon16/bin_closed.png" then 
            iconPos = iconPos - 2
            textPos = textPos - 2
        end

        surface.SetDrawColor(255, 255, 255)
        surface.SetMaterial(ico)
        surface.DrawTexturedRect(iconPos, h/2 - iconWid/2 + offset, iconWid, iconWid)
    else 
        textPos = w/2 
    end

    if self:GetText() ~= "" then 
        draw.Text({
            text = self:GetText(),
            font = self:GetFont(),
            color = tc,
            pos = {textPos, h/2 + offset},
            xalign = TEXT_ALIGN_CENTER,
            yalign = TEXT_ALIGN_CENTER
        })
    end
end

vgui.Register("NSZButton", NSZButton, "DButton")