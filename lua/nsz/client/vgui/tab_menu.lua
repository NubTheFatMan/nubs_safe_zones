-- Creates a scroll panel with tabs on top or to the side that let you switch between different menus

-- I ripped this code from my own mod, Nadmin https://github.com/NubTheFatMan/nadmin/blob/master/lua/nadmin/client/core/vgui2.lua#L889-L1221
local NSZTabMenu = {}
function NSZTabMenu:Init()
    self.backgroundColor  = Color(  0,   0,   0, 150)
    self.baseTabColor     = Color(  0, 150, 255)
    self.baseTabTextColor = Color(255, 255, 255)

    self.verticalTabs = false

    self.tabs = {}

    self.selectedTab = NULL

    self.tabSizeW = 50
    self.tabSizeH = 28
    self.cacheWidth = 0
    self.sizeWidthAcrossPanel = false

    self.tabContainerTop = vgui.Create("DPanel", self)
    self.tabContainerTop:Dock(TOP)
    self.tabContainerTop:SetTall(self.tabSizeH)
    self.tabContainerTop:SetVisible(false)
    function self.tabContainerTop:Paint(w, h) end -- Shouldn't be drawn
    
    self.tabContainerLeft = vgui.Create("DScrollPanel", self)
    self.tabContainerLeft:GetVBar():SetWide(0)
    self.tabContainerLeft:Dock(LEFT)
    self.tabContainerLeft:SetWide(self.tabSizeW)
    function self.tabContainerLeft:Paint(w, h) end -- Shouldn't be drawn

    self.scrollPanel = vgui.Create("DScrollPanel", self)
    self.scrollPanel:Dock(FILL)
    function self.scrollPanel:Paint(w, h) end
    self.scrollPanel:GetCanvas():DockPadding(4, 4, 4, 4)
end

function NSZTabMenu:GetCanvas() return self.scrollPanel:GetCanvas() end
function NSZTabMenu:GetScrollPanel() return self.scrollPanel end

function NSZTabMenu:SetColor(col) 
    if IsColor(col) then 
        self.backgroundColor = col
    end
end
function NSZTabMenu:GetColor() return self.backgroundColor end

function NSZTabMenu:SetTabColor(col)
    if IsColor(col) then 
        self.baseTabColor = col
    end
end
function NSZTabMenu:GetTabColor() return self.baseTabColor end

function NSZTabMenu:SetTabTextColor(col)
    if IsColor(col) then 
        self.baseTabTextColor = col
    end
end
function NSZTabMenu:GetTabTextColor() return self.baseTabTextColor end

function NSZTabMenu:SetTabSize(w, h)
    if isnumber(w) then self:SetTabWidth(w) end
    if isnumber(h) then self:SetTabHeight(h) end
end
function NSZTabMenu:SetTabWidth(w)
    self.tabContainerLeft:SetWide(w)
    self.tabSizeW = w
end
function NSZTabMenu:SetTabHeight(h)
    self.tabContainerTop:SetTall(h)
    self.tabSizeH = h
end

function NSZTabMenu:UseVerticalTabs(vert)
    if isbool(vert) then 
        self.verticalTabs = vert 
        self:ValidateMenu()
    end
end

function NSZTabMenu:SetSizeWidthAcrossPanel(sizeW)
    if isbool(sizeW) then 
        self.sizeWidthAcrossPanel = sizeW
        self:ValidateMenu()
    end
end
function NSZTabMenu:GetSizeWidthAcrossPanel() return self.sizeWidthAcrossPanel end

-- Makes sure the tabs are where they should be, and the contents panel is sized correctly
function NSZTabMenu:ValidateMenu()
    if not self.verticalTabs then -- Tabs are on top
        if not self.tabContainerTop:IsVisible() then self.tabContainerTop:SetVisible(true) end 
        if self.tabContainerLeft:IsVisible() then self.tabContainerLeft:SetVisible(false) end

        -- Position and size tabs
        if self:GetSizeWidthAcrossPanel() then
            local numTabs = #self.tabs
            local tabSize = (self.tabContainerTop:GetWide() / numTabs) - 4
            for i, tab in ipairs(self.tabs) do 
                if tab:GetParent() ~= self.tabContainerTop then 
                    tab:Dock(NODOCK)
                    tab:SetParent(self.tabContainerTop) 
                end
    
                tab:SetSize(tabSize, self.tabSizeH)
                tab:SetPos(((i - 1) / numTabs) * self.tabContainerTop:GetWide(), 0)
            end
    
            -- The final tab might not be aligned with the right side of the menu, so we are just going to increase the width to make it seamless
            local x = self.tabs[numTabs]:GetPos()
            self.tabs[numTabs]:SetWide(self.tabContainerTop:GetWide() - x)
        else 
            local x = 0
            for i, tab in ipairs(self.tabs) do 
                if tab:GetParent() ~= self.tabContainerTop then 
                    tab:Dock(NODOCK)
                    tab:SetParent(self.tabContainerTop)
                end

                tab:SizeToContentsX()
                tab:SetSize(tab:GetWide() + 8, self.tabSizeH)
                tab:SetPos(x, 0)
                x = x + tab:GetWide() + 4
            end
        end
    else -- Tabs are on the left
        if self.tabContainerTop:IsVisible() then self.tabContainerTop:SetVisible(false) end 
        if not self.tabContainerLeft:IsVisible() then self.tabContainerLeft:SetVisible(true) end

        local w = self.tabSizeW
        if not self.scrollPanel:IsVisible() then 
            w = self:GetWide()
            self.tabSizeW = w
            self.tabContainerLeft:SetWide(w)
        end

        for i, tab in ipairs(self.tabs) do 
            if tab:GetParent() ~= self.tabContainerLeft then 
                tab:SetParent(self.tabContainerLeft)
                tab:Dock(TOP)
                tab:DockMargin(0, 0, 0, 4)
            end

            tab:SetSize(w, self.tabSizeH)
        end
    end
end

function NSZTabMenu:AddTab(text, contents, selected, data)
    local tab = vgui.Create("DButton", self)
    if isfunction(contents) then tab.OnSelect = contents end
    tab.parent = self
    tab.vertical = false
    tab:SetText("")
    tab.text = text
    tab:SetFont("nsz_between")
    if data ~= nil then tab.data = data end 

    function tab:DoClick(noClick)
        if not noClick then chat.PlaySound() end
        self.animStart = SysTime()
        self.parent.selectedTab = self

        self.parent.scrollPanel:Clear()

        if isfunction(self.OnSelect) then 
            self.OnSelect(self.parent.scrollPanel, self.data) 
        end
    end

    function tab:SetText(text)
        if isstring(text) then 
            self.text = text
        end
    end
    function tab:GetText() return self.text end

    function tab:GetTextSize()
        surface.SetFont(self:GetFont())
        return surface.GetTextSize(self:GetText())
    end
    function tab:SizeToContents()
        self:SetSize(self:GetTextSize())
    end
    function tab:SizeToContentsX()
        local w, _ = self:GetTextSize()
        self:SetWide(w)
    end
    function tab:SizeToContentsY()
        local _, h = self:GetTextSize()
        self:SetTall(h)
    end

    function tab:SetSelectedColor(col)
        if IsColor(col) then 
            self.selColor = col
        end
    end
    function tab:GetSelectedColor() return self.selColor or self.parent.baseTabColor end
    function tab:ResetSelectedColor() self.selColor = nil end 

    function tab:SetSelectedTextColor(col)
        if IsColor(col) then 
            self.selTextColor = col
        end
    end
    function tab:GetSelectedTextColor() return self.selTextColor or self.parent.baseTabTextColor end
    function tab:ResetSelectedTextColor() self.selTextColor = nil end 

    function tab:SetUnselectedColor(col, noText)
        if IsColor(col) then 
            self.unselColor = col
        end
    end
    function tab:GetUnselectedColor() return self.unselColor or self.parent.baseTabColor end
    function tab:ResetUnselectedColor() self.unselColor = nil end 

    function tab:SetUnselectedTextColor(col)
        if IsColor(col) then 
            self.unselTextColor = col
        end
    end
    function tab:GetUnselectedTextColor() return self.unselTextColor or self.parent.baseTabTextColor end
    function tab:ResetUnselectedTextColor() self.unselTextColor = nil end 

    function tab:Paint(w, h)
        local col = self.unselColor or self.parent.baseTabColor
        if IsColor(self.selColor) then col = self.selColor end 

        if self.parent.selectedTab == self then 
            local tc = self.parent.baseTabTextColor 
            if IsColor(self.selTextColor) then tc = self.selTextColor end
            self:SetTextColor(tc)

            if isnumber(self.animStart) then 
                local anim = (SysTime() - self.animStart) / 0.33

                draw.RoundedBox(0, 0, 0, w, h, nsz.ShiftColor(self.parent.backgroundColor, 35))
                if not self.parent.verticalTabs then 
                    draw.RoundedBox(0, 0, h - h * anim, w, h, col)
                else 
                    draw.RoundedBox(0, w - w * anim, 0, w, h, col)
                end

                if SysTime() - self.animStart >= 0.33 then 
                    self.animStart = nil
                end
            else 
                draw.RoundedBox(0, 0, 0, w, h, col)
            end

            self.active = true
        else
            self:SetTextColor(self.unselTextColor or self.parent.baseTabTextColor)
            if self:IsHovered() and not isnumber(self.animStart) then 
                self.animStart = SysTime() 
                self.animDown = nil
            elseif not self:IsHovered() and isnumber(self.animStart) then 
                self.animStart = nil
                self.animDown = SysTime()
            elseif self.active then 
                self.active = nil 
                self.unselect = SysTime()
            end

            draw.RoundedBox(0, 0, 0, w, h, self.unselColor or self.parent.backgroundColor)

            local hoverLine = 3
            local brightenedColor = nsz.ShiftColor(self.unselColor or self.parent.backgroundColor, 35)
            if isnumber(self.animStart) then 
                local anim = math.Clamp((SysTime() - self.animStart) / 0.33, 0, 1)

                if self:IsDown() then hoverLine = 1 end 

                if not self.parent.verticalTabs then 
                    draw.RoundedBox(0, 0, h - h * anim, w, h, brightenedColor)
                    draw.RoundedBox(0, 0, h - hoverLine, w, hoverLine, col)
                else 
                    draw.RoundedBox(0, w - w * anim, 0, w, h, brightenedColor)
                    draw.RoundedBox(0, w - hoverLine, 0, hoverLine, h, col)
                end
            elseif isnumber(self.animDown) then 
                local anim = (SysTime() - self.animDown) / 0.66

                if not self.parent.verticalTabs then 
                    draw.RoundedBox(0, 0, h * anim, w, h, brightenedColor)
                    draw.RoundedBox(0, 0, h - hoverLine, w, hoverLine, col)
                else 
                    draw.RoundedBox(0, w * anim, 0, w, h, brightenedColor)
                    draw.RoundedBox(0, w - hoverLine, 0, hoverLine, h, col)
                end

                if SysTime() - self.animDown >= 0.66 then 
                    self.animDown = nil
                end
            elseif isnumber(self.unselect) then 
                local anim = (SysTime() - self.unselect) / 0.33

                if not self.parent.verticalTabs then 
                    draw.RoundedBox(0, 0, h * anim, w, h, col)
                else 
                    draw.RoundedBox(0, w * anim, 0, w, h, col)
                end

                if SysTime() - self.unselect >= 0.33 then 
                    self.unselect = nil
                end
            end
        end

        local textData = {
            text = self:GetText(),
            font = self:GetFont(),
            pos = {w/2, h/2},
            xalign = TEXT_ALIGN_CENTER,
            yalign = TEXT_ALIGN_CENTER
        }
        
        if self.parent.selectedTab == self then 
            textData.color = self:GetSelectedTextColor()
        else 
            textData.color = self:GetUnselectedTextColor()
        end

        draw.Text(textData)
    end

    table.insert(self.tabs, tab)
    
    self:ValidateMenu()
    
    -- For some reason, the scroll panel isn't sized correctly even after init, but a timer fixes it :shrug:
    if selected then timer.Simple(0.03, function() tab:DoClick(true) end) end
    return tab
end

function NSZTabMenu:RemoveTab(indexOrText)
    local tab = self:GetTab(indexOrText)
    if IsValid(tab) then 
        if isnumber(indexOrText) then 
            table.remove(self.tabs, indexOrText)
        else 
            for i, t in ipairs(self.tabs) do 
                if t == tab then 
                    table.remove(self.tabs, i)
                    break
                end
            end
        end
        tab:Remove()
    end
end

function NSZTabMenu:GetTab(indexOrText)
    if isnumber(indexOrText) then 
        if IsValid(self.tabs[indexOrText]) then 
            return self.tabs[indexOrText] 
        end
    elseif isstring(indexOrText) then 
        for i, t in ipairs(self.tabs) do 
            if t:GetText() == indexOrText then 
                return t
            end
        end
    end 
    return NULL
end

function NSZTabMenu:Paint(w, h)
    local x, y = 0, 0
    if self.verticalTabs then 
        x = self.tabSizeW
    else 
        y = self.tabSizeH
    end

    draw.RoundedBox(0, x, y, w, h, self.backgroundColor)

    -- Validate top tab container
    if self.cacheWidth ~= w and not self.verticalTabs then 
        self.tabContainerTop:SetWide(w) 
        self.cacheWidth = w
        self:ValidateMenu()
    end
end

vgui.Register("NSZTabMenu", NSZTabMenu, "DPanel")