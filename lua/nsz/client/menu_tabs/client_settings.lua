nsz.gui.AddTab({
    title = "Client Settings",
    sort = -1, -- This is intended to always be first
    CreateContent = function(parent)
        local enableHud = parent:Add("DCheckBoxLabel")
        enableHud:Dock(TOP)
        enableHud:DockMargin(0, 0, 0, 4)
        enableHud:SetText("Enable HUD")
        enableHud:SetFont("nsz_between")
        enableHud:SetTextColor(Color(255, 255, 255))
        enableHud:SetConVar("nsz_show_display")
        enableHud:SizeToContentsX()
        enableHud:SetTall(20)

        local previewAllZones = parent:Add("DCheckBoxLabel")
        previewAllZones:Dock(TOP)
        previewAllZones:DockMargin(0, 0, 0, 12)
        previewAllZones:SetText("Show All Zones (preview)")
        previewAllZones:SetTextColor(Color(255, 255, 255))
        previewAllZones:SetFont("nsz_between")
        previewAllZones:SizeToContentsX()
        previewAllZones:SetTall(20)
        previewAllZones:SetChecked(nsz.previewAllZones)
        function previewAllZones:OnChange(value)
            nsz.previewAllZones = value
        end

        local maxZonesText = parent:Add("DLabel")
        maxZonesText:SetText("## zones on HUD:")
        maxZonesText:SetFont("nsz_between")
        maxZonesText:SetTextColor(Color(0, 0, 0, 0))
        maxZonesText:SizeToContentsX()
        maxZonesText:SetWide(maxZonesText:GetWide() + 8)
        maxZonesText:SetTall(24)
        maxZonesText:SetPos(4, 60)
        function maxZonesText:Paint(w, h)
            draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 150))
            draw.Text({ -- Drawing text centered instead of aligned to left
                text = self:GetText(),
                pos = {w/2, h/2},
                xalign = TEXT_ALIGN_CENTER,
                yalign = TEXT_ALIGN_CENTER,
                font = "nsz_between",
                color = Color(255, 255, 255)
            })
        end

        local maxZonesShown = parent:Add("DTextEntry")
        maxZonesShown:Dock(TOP)
        maxZonesShown:DockMargin(maxZonesText:GetWide(), 0, 0, 4)
        maxZonesShown:SetPlaceholderText("# zones")
        maxZonesShown:SetTextColor(Color(255, 255, 255))
        maxZonesShown:SetFont("nsz_between")
        maxZonesShown:SetTall(24)
        maxZonesShown:SetNumeric(true)
        maxZonesShown:SetText(nsz.clientSettings.visibleZones)
        maxZonesShown:SetUpdateOnType(true)
        function maxZonesShown:Paint(w, h)
            draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 100))
            self:DrawTextEntryText(self:GetTextColor(), Color(0, 150, 255), Color(255, 255, 255))
            if string.Trim(self:GetText()) == "" then 
                draw.Text({
                    text = self:GetPlaceholderText(),
                    pos = {4, 4},
                    font = "nsz_between",
                    color = Color(230, 230, 230)
                })
            end
        end
        function maxZonesShown:OnChange()
            if self:GetInt() ~= nil then 
                nsz.clientSettings.visibleZones = self:GetInt()
            end
        end

        local dockPositionLabel = parent:Add("DLabel")
        dockPositionLabel:Dock(TOP)
        dockPositionLabel:DockMargin(0, 8, 0, 2)
        dockPositionLabel:SetText("Dock Position:")
        dockPositionLabel:SetFont("nsz_between")
        dockPositionLabel:SetTextColor(Color(255, 255, 255))

        local dockPositionContainer = parent:Add("DPanel")
        dockPositionContainer:Dock(TOP)
        dockPositionContainer:SetTall(nsz.gui.panel:GetWide() / 6)
        function dockPositionContainer:Paint(w, h)
            draw.RoundedBox(0, 0, 0, h * 16/9, h, Color(0, 0, 0, 100))
        end
        local dockWidth = (dockPositionContainer:GetTall() * 16/9) / 3
        local dockHeight = dockPositionContainer:GetTall() / 3

        local dockButtons -- will be initialized later, however the :Paint functions require this now
        local selectedDock = nsz.clientSettings.dockPosition

        local dockOffsetXEntry = dockPositionContainer:Add("DTextEntry")
        local dockOffsetYEntry = dockPositionContainer:Add("DTextEntry")

        local dockNorthwest = dockPositionContainer:Add("DButton")
        dockNorthwest:SetText("")
        dockNorthwest:SetSize(dockWidth, dockHeight)
        function dockNorthwest:Paint(w, h)
            draw.RoundedBox(0, 6, 6, w - 12, 3, Color(255, 255, 255))
            draw.RoundedBox(0, 6, 6, 3, h - 12, Color(255, 255, 255))
            
            if dockButtons[selectedDock] == self then 
                draw.RoundedBox(0, 0, 0, w, 2, Color(0, 150, 255))
                draw.RoundedBox(0, 0, 0, 2, h, Color(0, 150, 255))
                draw.RoundedBox(0, w-2, 0, 2, h, Color(0, 150, 255))
                draw.RoundedBox(0, 0, h-2, w, 2, Color(0, 150, 255))
            elseif self:IsHovered() then
                draw.RoundedBox(0, 0, 0, w, 1, Color(255, 255, 255))
                draw.RoundedBox(0, 0, 0, 1, h, Color(255, 255, 255))
                draw.RoundedBox(0, w-1, 0, 1, h, Color(255, 255, 255))
                draw.RoundedBox(0, 0, h-1, w, 1, Color(255, 255, 255))
            end
        end
        function dockNorthwest:DoClick() 
            selectedDock = table.KeyFromValue(dockButtons, self) 
            nsz.clientSettings.dockPosition = selectedDock
            nsz.clientSettings.dockOffset = {4, 4}
            dockOffsetXEntry:SetText(4) dockOffsetYEntry:SetText(4)
        end

        local dockNorth = dockPositionContainer:Add("DButton")
        dockNorth:SetText("")
        dockNorth:SetSize(dockWidth, dockHeight)
        dockNorth:SetPos(dockWidth, 0)
        function dockNorth:Paint(w, h)
            draw.RoundedBox(0, 6, 6, w - 12, 3, Color(255, 255, 255))
            --draw.RoundedBox(0, 6, 6, 3, h - 12, Color(255, 255, 255))
            
            if dockButtons[selectedDock] == self then 
                draw.RoundedBox(0, 0, 0, w, 2, Color(0, 150, 255))
                draw.RoundedBox(0, 0, 0, 2, h, Color(0, 150, 255))
                draw.RoundedBox(0, w-2, 0, 2, h, Color(0, 150, 255))
                draw.RoundedBox(0, 0, h-2, w, 2, Color(0, 150, 255))
            elseif self:IsHovered() then
                draw.RoundedBox(0, 0, 0, w, 1, Color(255, 255, 255))
                draw.RoundedBox(0, 0, 0, 1, h, Color(255, 255, 255))
                draw.RoundedBox(0, w-1, 0, 1, h, Color(255, 255, 255))
                draw.RoundedBox(0, 0, h-1, w, 1, Color(255, 255, 255))
            end
        end
        function dockNorth:DoClick() 
            selectedDock = table.KeyFromValue(dockButtons, self) 
            nsz.clientSettings.dockPosition = selectedDock 
            nsz.clientSettings.dockOffset = {0, 4}
            dockOffsetXEntry:SetText(0) dockOffsetYEntry:SetText(4)
        end

        local dockNortheast = dockPositionContainer:Add("DButton")
        dockNortheast:SetText("")
        dockNortheast:SetSize(dockWidth, dockHeight)
        dockNortheast:SetPos(dockWidth * 2, 0)
        function dockNortheast:Paint(w, h)
            draw.RoundedBox(0, 6, 6, w - 12, 3, Color(255, 255, 255))
            draw.RoundedBox(0, w - 9, 6, 3, h - 12, Color(255, 255, 255))
            
            if dockButtons[selectedDock] == self then 
                draw.RoundedBox(0, 0, 0, w, 2, Color(0, 150, 255))
                draw.RoundedBox(0, 0, 0, 2, h, Color(0, 150, 255))
                draw.RoundedBox(0, w-2, 0, 2, h, Color(0, 150, 255))
                draw.RoundedBox(0, 0, h-2, w, 2, Color(0, 150, 255))
            elseif self:IsHovered() then
                draw.RoundedBox(0, 0, 0, w, 1, Color(255, 255, 255))
                draw.RoundedBox(0, 0, 0, 1, h, Color(255, 255, 255))
                draw.RoundedBox(0, w-1, 0, 1, h, Color(255, 255, 255))
                draw.RoundedBox(0, 0, h-1, w, 1, Color(255, 255, 255))
            end
        end
        function dockNortheast:DoClick() 
            selectedDock = table.KeyFromValue(dockButtons, self) 
            nsz.clientSettings.dockPosition = selectedDock
            nsz.clientSettings.dockOffset = {-4, 4}
            dockOffsetXEntry:SetText(-4) dockOffsetYEntry:SetText(4)
        end

        local dockWest = dockPositionContainer:Add("DButton")
        dockWest:SetText("")
        dockWest:SetSize(dockWidth, dockHeight)
        dockWest:SetPos(0, dockHeight)
        function dockWest:Paint(w, h)
            --draw.RoundedBox(0, 6, 6, w - 12, 3, Color(255, 255, 255))
            draw.RoundedBox(0, 6, 6, 3, h - 12, Color(255, 255, 255))
            
            if dockButtons[selectedDock] == self then 
                draw.RoundedBox(0, 0, 0, w, 2, Color(0, 150, 255))
                draw.RoundedBox(0, 0, 0, 2, h, Color(0, 150, 255))
                draw.RoundedBox(0, w-2, 0, 2, h, Color(0, 150, 255))
                draw.RoundedBox(0, 0, h-2, w, 2, Color(0, 150, 255))
            elseif self:IsHovered() then
                draw.RoundedBox(0, 0, 0, w, 1, Color(255, 255, 255))
                draw.RoundedBox(0, 0, 0, 1, h, Color(255, 255, 255))
                draw.RoundedBox(0, w-1, 0, 1, h, Color(255, 255, 255))
                draw.RoundedBox(0, 0, h-1, w, 1, Color(255, 255, 255))
            end
        end
        function dockWest:DoClick() 
            selectedDock = table.KeyFromValue(dockButtons, self) 
            nsz.clientSettings.dockPosition = selectedDock
            nsz.clientSettings.dockOffset = {4, 0}
            dockOffsetXEntry:SetText(4) dockOffsetYEntry:SetText(0)
        end

        local dockCenter = dockPositionContainer:Add("DButton")
        dockCenter:SetText("")
        dockCenter:SetSize(dockWidth, dockHeight)
        dockCenter:SetPos(dockWidth, dockHeight)
        function dockCenter:Paint(w, h)
            draw.RoundedBox(0, w/2 - 2, h/2 - h/4, 3, h / 2, Color(255, 255, 255))
            draw.RoundedBox(0, w/2 - w/4, h/2 - 2, w/2, 3, Color(255, 255, 255))
            
            if dockButtons[selectedDock] == self then 
                draw.RoundedBox(0, 0, 0, w, 2, Color(0, 150, 255))
                draw.RoundedBox(0, 0, 0, 2, h, Color(0, 150, 255))
                draw.RoundedBox(0, w-2, 0, 2, h, Color(0, 150, 255))
                draw.RoundedBox(0, 0, h-2, w, 2, Color(0, 150, 255))
            elseif self:IsHovered() then
                draw.RoundedBox(0, 0, 0, w, 1, Color(255, 255, 255))
                draw.RoundedBox(0, 0, 0, 1, h, Color(255, 255, 255))
                draw.RoundedBox(0, w-1, 0, 1, h, Color(255, 255, 255))
                draw.RoundedBox(0, 0, h-1, w, 1, Color(255, 255, 255))
            end
        end
        function dockCenter:DoClick() 
            selectedDock = table.KeyFromValue(dockButtons, self) 
            nsz.clientSettings.dockPosition = selectedDock
            nsz.clientSettings.dockOffset = {0, 0}
            dockOffsetXEntry:SetText(0) dockOffsetYEntry:SetText(0)
        end

        local dockEast = dockPositionContainer:Add("DButton")
        dockEast:SetText("")
        dockEast:SetSize(dockWidth, dockHeight)
        dockEast:SetPos(dockWidth * 2, dockHeight)
        function dockEast:Paint(w, h)
            --draw.RoundedBox(0, 6, 6, w - 12, 3, Color(255, 255, 255))
            draw.RoundedBox(0, w - 9, 6, 3, h - 12, Color(255, 255, 255))
            
            if dockButtons[selectedDock] == self then 
                draw.RoundedBox(0, 0, 0, w, 2, Color(0, 150, 255))
                draw.RoundedBox(0, 0, 0, 2, h, Color(0, 150, 255))
                draw.RoundedBox(0, w-2, 0, 2, h, Color(0, 150, 255))
                draw.RoundedBox(0, 0, h-2, w, 2, Color(0, 150, 255))
            elseif self:IsHovered() then
                draw.RoundedBox(0, 0, 0, w, 1, Color(255, 255, 255))
                draw.RoundedBox(0, 0, 0, 1, h, Color(255, 255, 255))
                draw.RoundedBox(0, w-1, 0, 1, h, Color(255, 255, 255))
                draw.RoundedBox(0, 0, h-1, w, 1, Color(255, 255, 255))
            end
        end
        function dockEast:DoClick() 
            selectedDock = table.KeyFromValue(dockButtons, self) 
            nsz.clientSettings.dockPosition = selectedDock
            nsz.clientSettings.dockOffset = {-4, 0}
            dockOffsetXEntry:SetText(-4) dockOffsetYEntry:SetText(0)
        end

        local dockSouthwest = dockPositionContainer:Add("DButton")
        dockSouthwest:SetText("")
        dockSouthwest:SetSize(dockWidth, dockHeight)
        dockSouthwest:SetPos(0, dockHeight * 2)
        function dockSouthwest:Paint(w, h)
            draw.RoundedBox(0, 6, h - 9, w - 12, 3, Color(255, 255, 255))
            draw.RoundedBox(0, 6, 6, 3, h - 12, Color(255, 255, 255))
            
            if dockButtons[selectedDock] == self then 
                draw.RoundedBox(0, 0, 0, w, 2, Color(0, 150, 255))
                draw.RoundedBox(0, 0, 0, 2, h, Color(0, 150, 255))
                draw.RoundedBox(0, w-2, 0, 2, h, Color(0, 150, 255))
                draw.RoundedBox(0, 0, h-2, w, 2, Color(0, 150, 255))
            elseif self:IsHovered() then
                draw.RoundedBox(0, 0, 0, w, 1, Color(255, 255, 255))
                draw.RoundedBox(0, 0, 0, 1, h, Color(255, 255, 255))
                draw.RoundedBox(0, w-1, 0, 1, h, Color(255, 255, 255))
                draw.RoundedBox(0, 0, h-1, w, 1, Color(255, 255, 255))
            end
        end
        function dockSouthwest:DoClick() 
            selectedDock = table.KeyFromValue(dockButtons, self) 
            nsz.clientSettings.dockPosition = selectedDock
            nsz.clientSettings.dockOffset = {4, -4}
            dockOffsetXEntry:SetText(4) dockOffsetYEntry:SetText(-4)
        end

        local dockSouth = dockPositionContainer:Add("DButton")
        dockSouth:SetText("")
        dockSouth:SetSize(dockWidth, dockHeight)
        dockSouth:SetPos(dockWidth, dockHeight * 2)
        function dockSouth:Paint(w, h)
            draw.RoundedBox(0, 6, h - 9, w - 12, 3, Color(255, 255, 255))
            --draw.RoundedBox(0, 6, 6, 3, h - 12, Color(255, 255, 255))
            
            if dockButtons[selectedDock] == self then 
                draw.RoundedBox(0, 0, 0, w, 2, Color(0, 150, 255))
                draw.RoundedBox(0, 0, 0, 2, h, Color(0, 150, 255))
                draw.RoundedBox(0, w-2, 0, 2, h, Color(0, 150, 255))
                draw.RoundedBox(0, 0, h-2, w, 2, Color(0, 150, 255))
            elseif self:IsHovered() then
                draw.RoundedBox(0, 0, 0, w, 1, Color(255, 255, 255))
                draw.RoundedBox(0, 0, 0, 1, h, Color(255, 255, 255))
                draw.RoundedBox(0, w-1, 0, 1, h, Color(255, 255, 255))
                draw.RoundedBox(0, 0, h-1, w, 1, Color(255, 255, 255))
            end
        end
        function dockSouth:DoClick() 
            selectedDock = table.KeyFromValue(dockButtons, self) 
            nsz.clientSettings.dockPosition = selectedDock
            nsz.clientSettings.dockOffset = {0, -4}
            dockOffsetXEntry:SetText(0) dockOffsetYEntry:SetText(-4)
        end

        local dockSoutheast = dockPositionContainer:Add("DButton")
        dockSoutheast:SetText("")
        dockSoutheast:SetSize(dockWidth, dockHeight)
        dockSoutheast:SetPos(dockWidth * 2, dockHeight * 2)
        function dockSoutheast:Paint(w, h)
            draw.RoundedBox(0, 6, h - 9, w - 12, 3, Color(255, 255, 255))
            draw.RoundedBox(0, w - 9, 6, 3, h - 12, Color(255, 255, 255))
            
            if dockButtons[selectedDock] == self then 
                draw.RoundedBox(0, 0, 0, w, 2, Color(0, 150, 255))
                draw.RoundedBox(0, 0, 0, 2, h, Color(0, 150, 255))
                draw.RoundedBox(0, w-2, 0, 2, h, Color(0, 150, 255))
                draw.RoundedBox(0, 0, h-2, w, 2, Color(0, 150, 255))
            elseif self:IsHovered() then
                draw.RoundedBox(0, 0, 0, w, 1, Color(255, 255, 255))
                draw.RoundedBox(0, 0, 0, 1, h, Color(255, 255, 255))
                draw.RoundedBox(0, w-1, 0, 1, h, Color(255, 255, 255))
                draw.RoundedBox(0, 0, h-1, w, 1, Color(255, 255, 255))
            end
        end
        function dockSoutheast:DoClick() 
            selectedDock = table.KeyFromValue(dockButtons, self) 
            nsz.clientSettings.dockPosition = selectedDock
            nsz.clientSettings.dockOffset = {-4, -4}
            dockOffsetXEntry:SetText(-4) dockOffsetYEntry:SetText(-4)
        end

        dockButtons = {
            dockNorthwest, dockNorth,  dockNortheast,
            dockWest,      dockCenter, dockEast,
            dockSouthwest, dockSouth,  dockSoutheast
        }

        local dockOffsetLabel = dockPositionContainer:Add("DLabel")
        dockOffsetLabel:SetText("Dock Offset:")
        dockOffsetLabel:SetFont("nsz_between")
        dockOffsetLabel:SetTextColor(Color(255, 255, 255))
        dockOffsetLabel:SizeToContents()
        dockOffsetLabel:SetPos(dockWidth * 3 + 4, 4)
        
        local x, y = dockOffsetLabel:GetPos()
        local dockOffsetReset = dockPositionContainer:Add("NSZButton")
        dockOffsetReset:SetText("Reset Offset")
        dockOffsetReset:SetColor(Color(100, 100, 100))
        dockOffsetReset:SizeToContentsX()
        dockOffsetReset:SetSize(dockOffsetReset:GetWide() + 8, 24)
        dockOffsetReset:SetPos(x + dockOffsetLabel:GetWide() + 4, y - 2)
        y = y + dockOffsetReset:GetTall()

        -- Panel instead of label to ensure text is center
        local dockOffsetXLabel = dockPositionContainer:Add("DButton")
        dockOffsetXLabel:SetText("")
        dockOffsetXLabel:SetSize(24, 24)
        dockOffsetXLabel:SetPos(x, y)
        dockOffsetXLabel:SetCursor("sizewe")
        dockOffsetXLabel.downLastFrame = false
        function dockOffsetXLabel:Paint(w, h)
            draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 150))
            draw.Text({
                text = "X",
                font = "nsz_between",
                color = Color(255, 255, 255),
                pos = {w/2, h/2},
                xalign = TEXT_ALIGN_CENTER,
                yalign = TEXT_ALIGN_CENTER
            })

            if self:IsDown() then 
                if self.startX == nil then 
                    self.startX = gui.MouseX()
                    self.startInt = dockOffsetXEntry:GetInt() or 0
                end
                local x = math.Round((gui.MouseX() - self.startX) / 2)
                dockOffsetXEntry:SetText(self.startInt + x)
                dockOffsetXEntry:OnChange()
            elseif not self:IsDown() and self.downLastFrame then 
                self.startX = nil
            end
            self.downLastFrame = self:IsDown()
        end
        function dockOffsetXLabel:DoRightClick()
            local x = 0
            local dock = nsz.clientSettings.dockPosition
            if dock == 1 or dock == 4 or dock == 7 then x = 4
            elseif dock == 3 or dock == 6 or dock == 9 then x = -4 end

            dockOffsetXEntry:SetText(x)
            nsz.clientSettings.dockOffset[1] = x
        end

        dockOffsetXEntry:SetFont("nsz_between")
        dockOffsetXEntry:SetTextColor(Color(255, 255, 255))
        dockOffsetXEntry:SetNumeric(true)
        dockOffsetXEntry:SetSize(62, 24)
        dockOffsetXEntry:SetPos(x + 24, y)
        dockOffsetXEntry:SetText(nsz.clientSettings.dockOffset[1])
        dockOffsetXEntry:SetUpdateOnType(true)
        function dockOffsetXEntry:Paint(w, h)
            draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 100))
            self:DrawTextEntryText(self:GetTextColor(), Color(0, 150, 255), Color(255, 255, 255))
        end
        function dockOffsetXEntry:OnChange()
            if self:GetInt() ~= nil then 
                nsz.clientSettings.dockOffset[1] = self:GetInt()
            end
        end

        local dockOffsetYLabel = dockPositionContainer:Add("DButton")
        dockOffsetYLabel:SetText("")
        dockOffsetYLabel:SetSize(24, 24)
        dockOffsetYLabel:SetPos(x, y + 28)
        dockOffsetYLabel:SetCursor("sizewe")
        dockOffsetYLabel.downLastFrame = false
        function dockOffsetYLabel:Paint(w, h)
            draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 150))
            draw.Text({
                text = "Y",
                font = "nsz_between",
                color = Color(255, 255, 255),
                pos = {w/2, h/2},
                xalign = TEXT_ALIGN_CENTER,
                yalign = TEXT_ALIGN_CENTER
            })

            if self:IsDown() then 
                if self.startX == nil then 
                    self.startX = gui.MouseX()
                    self.startInt = dockOffsetYEntry:GetInt() or 0
                end
                local x = math.Round((gui.MouseX() - self.startX) / 2)
                dockOffsetYEntry:SetText(self.startInt + x)
                dockOffsetYEntry:OnChange()
            elseif not self:IsDown() and self.downLastFrame then 
                self.startX = nil
            end
            self.downLastFrame = self:IsDown()
        end
        function dockOffsetYLabel:DoRightClick()
            local y = 0
            local dock = nsz.clientSettings.dockPosition
            if dock >= 1 and dock <= 3 then y = 4
            elseif dock >= 7 and dock <= 9 then y = -4 end

            dockOffsetYEntry:SetText(y)
            nsz.clientSettings.dockOffset[2] = y
        end

        dockOffsetYEntry:SetFont("nsz_between")
        dockOffsetYEntry:SetTextColor(Color(255, 255, 255))
        dockOffsetYEntry:SetNumeric(true)
        dockOffsetYEntry:SetSize(62, 24)
        dockOffsetYEntry:SetPos(x + 24, y + 28)
        dockOffsetYEntry:SetText(nsz.clientSettings.dockOffset[2])
        dockOffsetYEntry:SetUpdateOnType(true)
        function dockOffsetYEntry:Paint(w, h)
            draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 100))
            self:DrawTextEntryText(self:GetTextColor(), Color(0, 150, 255), Color(255, 255, 255))
        end
        function dockOffsetYEntry:OnChange()
            if self:GetInt() ~= nil then 
                nsz.clientSettings.dockOffset[2] = self:GetInt()
            end
        end

        function dockOffsetReset:DoClick()
            local x, y = 0, 0

            local dock = nsz.clientSettings.dockPosition
            if dock == 1     then x, y =  4,  4
            elseif dock == 2 then x, y =  0,  4
            elseif dock == 3 then x, y = -4,  4
            elseif dock == 4 then x, y =  4,  0
            elseif dock == 5 then x, y =  0,  0
            elseif dock == 6 then x, y = -4,  0
            elseif dock == 7 then x, y =  4, -4
            elseif dock == 8 then x, y =  0, -4
            elseif dock == 9 then x, y = -4, -4 end

            dockOffsetXEntry:SetText(x)
            dockOffsetYEntry:SetText(y)
            nsz.clientSettings.dockOffset = {x, y}
        end

        local dockOffsetEditByDragAndDrop = dockPositionContainer:Add("NSZButton")
        dockOffsetEditByDragAndDrop:SetText("Edit by dragging and dropping")
        -- Docking ensures the width always goes to the end of the menu regardless of if the vbar is visible
        dockOffsetEditByDragAndDrop:Dock(TOP)
        dockOffsetEditByDragAndDrop:DockMargin(x, y + 48 + 8, 0, 0)
        dockOffsetEditByDragAndDrop:SetTall(24)
        dockOffsetEditByDragAndDrop:SetColor(Color(100, 100, 100))
        function dockOffsetEditByDragAndDrop:DoClick()
            nsz.gui.Close()

            nsz.gui.offsetEditor = vgui.Create("DFrame")
            nsz.gui.offsetEditorControls = vgui.Create("DPanel")
            local editorControls = nsz.gui.offsetEditorControls
            local editor = nsz.gui.offsetEditor
            editor:SetTitle("")
            editor:ShowCloseButton(false)
            editor:SetSizable(false)
            editor:SetDraggable(false)
            editor:NoClipping(true)
            editor:SetSize(ScrW() / 7.75, (nsz.clientSettings.visibleZones * 48) + ((nsz.clientSettings.visibleZones - 1) * 4))
            editor:MakePopup()
            editor.visibleZones = nsz.clientSettings.visibleZones
            editor.lastChangedZones = SysTime()
            editor.visibleZonesChangeDirection = -1
            editor.tempDockPosition = nsz.clientSettings.dockPosition
            local transparentGray = Color(0, 0, 0, 150)
            function editor:Paint(w, h)
                local now = SysTime()
                if now - self.lastChangedZones >= 1.33 then
                    self.lastChangedZones = now
                    
                    self.visibleZones = self.visibleZones + self.visibleZonesChangeDirection
                    if self.visibleZones == 0 or self.visibleZones == nsz.clientSettings.visibleZones + 1 then 
                        self.visibleZonesChangeDirection = self.visibleZonesChangeDirection * -1
                        self.visibleZones = self.visibleZones + self.visibleZonesChangeDirection * 2
                    end
                end

                local dock = self.tempDockPosition

                for i = 1, self.visibleZones do 
                    local y = (i - 1) * 48 + ((i - 1) * 4)
                    
                    local offsetY = 0
                    if dock > 3 and dock <= 6 then 
                        local totalHeight = self.visibleZones * 48 + (self.visibleZones - 1) * 4
                        offsetY = h/2 - totalHeight/2
                    elseif dock > 6 and dock <= 9 then
                        local totalHeight = self.visibleZones * 48 + (self.visibleZones - 1) * 4
                        offsetY = h - totalHeight
                    end

                    draw.RoundedBox(0, 0, y + offsetY, w, 48, transparentGray)
                end

                local x, y = 0, 0
                if dock == 2 then 
                    x = w/2
                elseif dock == 3 then 
                    x = w
                elseif dock == 4 then 
                    y = h/2
                elseif dock == 5 then 
                    x, y = w/2, h/2
                elseif dock == 6 then 
                    x, y = w, h/2
                elseif dock == 7 then 
                    y = h
                elseif dock == 8 then 
                    x, y = w/2, h
                elseif dock == 9 then 
                    x, y = w, h
                end

                surface.DrawCircle(x, y, 8, 62, 255, 62)
            end 
            function editor:OnKeyCodeReleased(keyCode)
                if keyCode == KEY_ESCAPE then 
                    self:Remove()
                    editorControls:Remove()
                    if gui.IsGameUIVisible() then 
                        gui.HideGameUI()
                    end
                    nsz.gui.Open()
                elseif keyCode == KEY_ENTER then 
                    local x, y = self:GetPos()
                    local dock = self.tempDockPosition
                    local baseDockX, baseDockY = 0, 0
                    if dock == 2 then 
                        x = x + self:GetWide()/2
                        baseDockX = ScrW() / 2
                    elseif dock == 3 then 
                        x = x + self:GetWide()
                        baseDockX = ScrW()
                    elseif dock == 4 then 
                        y = y + self:GetTall()/2
                        baseDockY = ScrH() / 2
                    elseif dock == 5 then 
                        x = x + self:GetWide()/2
                        y = y + self:GetTall()/2
                        baseDockX = ScrW() / 2
                        baseDockY = ScrH() / 2
                    elseif dock == 6 then 
                        x = x + self:GetWide()
                        y = y + self:GetTall()/2
                        baseDockX = ScrW()
                        baseDockY = ScrH() / 2
                    elseif dock == 7 then 
                        y = y + self:GetTall()
                        baseDockY = ScrH()
                    elseif dock == 8 then 
                        x = x + self:GetWide()/2
                        y = y + self:GetTall()
                        baseDockX = ScrW() / 2
                        baseDockY = ScrH()
                    elseif dock == 9 then 
                        x = x + self:GetWide()
                        y = y + self:GetTall()
                        baseDockX = ScrW()
                        baseDockY = ScrH()
                    end

                    x = math.Round(x - baseDockX)
                    y = math.Round(y - baseDockY)
                    nsz.clientSettings.dockOffset = {x, y}
                    nsz.clientSettings.dockPosition = self.tempDockPosition
                    
                    self:Remove()
                    editorControls:Remove()
                    nsz.gui.Open()
                end
            end

            local offset = nsz.clientSettings.dockOffset
            local dock = nsz.clientSettings.dockPosition
            local totalHeight = editor:GetTall()
            local w = editor:GetWide()
            local x = ((ScrW() - w) * ((dock - 1) % 3) / 2) + offset[1]
            local y = ((ScrH() - totalHeight) * math.floor((dock - 1) / 3) / 2) + offset[2]
            editor:SetPos(x, y)

            local dragHandlerXAxis = function(self)
                if input.IsKeyDown(KEY_LSHIFT) then return end
                if self.initialMouseX == nil then 
                    self.initialMouseX = gui.MouseX()
                    self.initialPosX   = editor:GetX()
                end
                editor:SetX(math.Clamp(self.initialPosX + gui.MouseX() - self.initialMouseX, 0, ScrW() - editor:GetWide()))
            end
            local dragHandlerYAxis = function(self)
                if input.IsKeyDown(KEY_LSHIFT) then return end
                if self.initialMouseY == nil then 
                    self.initialMouseY = gui.MouseY()
                    self.initialPosY   = editor:GetY()
                end
                editor:SetY(math.Clamp(self.initialPosY + gui.MouseY() - self.initialMouseY, 0, ScrH() - editor:GetTall()))
            end
            local dragHandlerDiagonal = function(self, inverted)
                if input.IsKeyDown(KEY_LSHIFT) then return end

                if self.initialMouseX == nil then 
                    self.initialMouseX = gui.MouseX()

                    self.initialPosX = editor:GetX()
                    self.initialPosY = editor:GetY()
                end

                local x, y = 0, 0
                if inverted then 
                    x, y = self.initialPosX + gui.MouseX() - self.initialMouseX, self.initialPosY - gui.MouseX() + self.initialMouseX
                else 
                    x, y = self.initialPosX + gui.MouseX() - self.initialMouseX, self.initialPosY + gui.MouseX() - self.initialMouseX
                end

                x = math.Clamp(x, 0, ScrW() - editor:GetWide())
                y = math.Clamp(y, 0, ScrH() - editor:GetTall())

                editor:SetPos(x, y)
            end

            local dragXAxisTop = editor:Add("DButton")
            dragXAxisTop:SetText("")
            dragXAxisTop:SetPos(28, 0)
            dragXAxisTop:SetSize(editor:GetWide() - (28 * 2), 28)
            dragXAxisTop:SetCursor("sizewe")
            dragXAxisTop:NoClipping(true)
            dragXAxisTop.downLastFrame = false
            function dragXAxisTop:Paint(w, h)
                draw.RoundedBox(0,   0,   0, w, 2, Color(255, 255, 255))
                draw.RoundedBox(0,   0,   0, 1, h, Color(255, 255, 255))
                draw.RoundedBox(0,   0, h-1, w, 1, Color(255, 255, 255))
                draw.RoundedBox(0, w-1,   0, 1, h, Color(255, 255, 255))

                if self:IsDown() then 
                    dragHandlerXAxis(self)
                elseif not self:IsDown() and self.downLastFrame then 
                    self.initialMouseX = nil
                end
                self.downLastFrame = self:IsDown()

                if self:IsHovered() and input.IsKeyDown(KEY_LSHIFT) then 
                    surface.DrawCircle(w/2, 0, 8, 0, 150, 255)
                    self:SetCursor("hand")
                else 
                    self:SetCursor("sizewe")
                end
            end
            function dragXAxisTop:DoClick()
                if input.IsKeyDown(KEY_LSHIFT) then 
                    editor.tempDockPosition = 2
                end
            end

            local dragXAxisBottom = editor:Add("DButton")
            dragXAxisBottom:SetText("")
            dragXAxisBottom:SetPos(28, editor:GetTall() - 28)
            dragXAxisBottom:SetSize(editor:GetWide() - (28 * 2), 28)
            dragXAxisBottom:SetCursor("sizewe")
            dragXAxisBottom:NoClipping(true)
            dragXAxisBottom.downLastFrame = false
            function dragXAxisBottom:Paint(w, h)
                draw.RoundedBox(0,   0,   0, w, 1, Color(255, 255, 255))
                draw.RoundedBox(0,   0,   0, 1, h, Color(255, 255, 255))
                draw.RoundedBox(0,   0, h-2, w, 2, Color(255, 255, 255))
                draw.RoundedBox(0, w-1,   0, 1, h, Color(255, 255, 255))

                if self:IsDown() then 
                    dragHandlerXAxis(self)
                elseif not self:IsDown() and self.downLastFrame then 
                    self.initialMouseX = nil
                end
                self.downLastFrame = self:IsDown()

                if self:IsHovered() and input.IsKeyDown(KEY_LSHIFT) then 
                    surface.DrawCircle(w/2, h, 8, 0, 150, 255)
                    self:SetCursor("hand")
                else 
                    self:SetCursor("sizewe")
                end
            end
            function dragXAxisBottom:DoClick()
                if input.IsKeyDown(KEY_LSHIFT) then 
                    editor.tempDockPosition = 8
                end
            end

            local dragYAxisLeft = editor:Add("DButton")
            dragYAxisLeft:SetText("")
            dragYAxisLeft:SetPos(0, 28)
            dragYAxisLeft:SetSize(28, editor:GetTall() - (28 * 2))
            dragYAxisLeft:SetCursor("sizens")
            dragYAxisLeft:NoClipping(true)
            dragYAxisLeft.downLastFrame = false
            function dragYAxisLeft:Paint(w, h)
                draw.RoundedBox(0,   0,   0, w, 1, Color(255, 255, 255))
                draw.RoundedBox(0,   0,   0, 2, h, Color(255, 255, 255))
                draw.RoundedBox(0,   0, h-1, w, 1, Color(255, 255, 255))
                draw.RoundedBox(0, w-1,   0, 1, h, Color(255, 255, 255))

                if self:IsDown() then 
                    dragHandlerYAxis(self)
                elseif not self:IsDown() and self.downLastFrame then 
                    self.initialMouseY = nil
                end
                self.downLastFrame = self:IsDown()
            
                if self:IsHovered() and input.IsKeyDown(KEY_LSHIFT) then 
                    surface.DrawCircle(0, h/2, 8, 0, 150, 255)
                    self:SetCursor("hand")
                else 
                    self:SetCursor("sizens")
                end
            end
            function dragYAxisLeft:DoClick()
                if input.IsKeyDown(KEY_LSHIFT) then 
                    editor.tempDockPosition = 4
                end
            end

            local dragYAxisRight = editor:Add("DButton")
            dragYAxisRight:SetText("")
            dragYAxisRight:SetPos(editor:GetWide() - 28, 28)
            dragYAxisRight:SetSize(28, editor:GetTall() - (28 * 2))
            dragYAxisRight:SetCursor("sizens")
            dragYAxisRight:NoClipping(true)
            dragYAxisRight.downLastFrame = false
            function dragYAxisRight:Paint(w, h)
                draw.RoundedBox(0,   0,   0, w, 1, Color(255, 255, 255))
                draw.RoundedBox(0,   0,   0, 1, h, Color(255, 255, 255))
                draw.RoundedBox(0,   0, h-1, w, 1, Color(255, 255, 255))
                draw.RoundedBox(0, w-2,   0, 2, h, Color(255, 255, 255))

                if self:IsDown() then 
                    dragHandlerYAxis(self)
                elseif not self:IsDown() and self.downLastFrame then 
                    self.initialMouseY = nil
                end
                self.downLastFrame = self:IsDown()
            
                if self:IsHovered() and input.IsKeyDown(KEY_LSHIFT) then 
                    surface.DrawCircle(w, h/2, 8, 0, 150, 255)
                    self:SetCursor("hand")
                else 
                    self:SetCursor("sizens")
                end
            end
            function dragYAxisRight:DoClick()
                if input.IsKeyDown(KEY_LSHIFT) then 
                    editor.tempDockPosition = 6
                end
            end

            local dragXYAxis = editor:Add("DButton")
            dragXYAxis:SetText("")
            dragXYAxis:SetPos(28, 28)
            dragXYAxis:SetSize(editor:GetWide() - (28 * 2), editor:GetTall() - (28 * 2))
            dragXYAxis:SetCursor("sizeall")
            dragXYAxis:NoClipping(true)
            dragXYAxis.downLastFrame = false
            function dragXYAxis:Paint(w, h)
                draw.RoundedBox(0,   0,   0, w, 1, Color(255, 255, 255))
                draw.RoundedBox(0,   0,   0, 1, h, Color(255, 255, 255))
                draw.RoundedBox(0,   0, h-1, w, 1, Color(255, 255, 255))
                draw.RoundedBox(0, w-1,   0, 1, h, Color(255, 255, 255))

                if self:IsDown() then 
                    dragHandlerXAxis(self)
                    dragHandlerYAxis(self)
                elseif not self:IsDown() and self.downLastFrame then 
                    self.initialMouseX = nil
                    self.initialMouseY = nil
                end
                self.downLastFrame = self:IsDown()
            
                if self:IsHovered() and input.IsKeyDown(KEY_LSHIFT) then 
                    surface.DrawCircle(w/2, h/2, 8, 0, 150, 255)
                    self:SetCursor("hand")
                else 
                    self:SetCursor("sizeall")
                end
            end
            function dragXYAxis:DoClick()
                if input.IsKeyDown(KEY_LSHIFT) then 
                    editor.tempDockPosition = 5
                end
            end

            -- Despite this insane length, I can autofill with just 4 keystrokes :GigaChad:
            local dragTopLeftToBottomRightLocatedTopLeft = editor:Add("DButton")
            dragTopLeftToBottomRightLocatedTopLeft:SetText("")
            dragTopLeftToBottomRightLocatedTopLeft:SetPos(0, 0)
            dragTopLeftToBottomRightLocatedTopLeft:SetSize(28, 28)
            dragTopLeftToBottomRightLocatedTopLeft:SetCursor("sizenwse")
            dragTopLeftToBottomRightLocatedTopLeft:NoClipping(true)
            dragTopLeftToBottomRightLocatedTopLeft.downLastFrame = false
            function dragTopLeftToBottomRightLocatedTopLeft:Paint(w, h)
                draw.RoundedBox(0,   0,   0, w, 2, Color(255, 255, 255))
                draw.RoundedBox(0,   0,   0, 2, h, Color(255, 255, 255))
                draw.RoundedBox(0,   0, h-1, w, 1, Color(255, 255, 255))
                draw.RoundedBox(0, w-1,   0, 1, h, Color(255, 255, 255))

                if self:IsDown() then 
                    dragHandlerDiagonal(self)
                elseif not self:IsDown() and self.downLastFrame then 
                    self.initialMouseX = nil
                end
                self.downLastFrame = self:IsDown()
            
                if self:IsHovered() and input.IsKeyDown(KEY_LSHIFT) then 
                    surface.DrawCircle(0, 0, 8, 0, 150, 255)
                    self:SetCursor("hand")
                else 
                    self:SetCursor("sizenwse")
                end
            end
            function dragTopLeftToBottomRightLocatedTopLeft:DoClick()
                if input.IsKeyDown(KEY_LSHIFT) then 
                    editor.tempDockPosition = 1
                end
            end

            local dragTopLeftToBottomRightLocatedBottomRight = editor:Add("DButton")
            dragTopLeftToBottomRightLocatedBottomRight:SetText("")
            dragTopLeftToBottomRightLocatedBottomRight:SetPos(editor:GetWide() - 28, editor:GetTall() - 28)
            dragTopLeftToBottomRightLocatedBottomRight:SetSize(28, 28)
            dragTopLeftToBottomRightLocatedBottomRight:SetCursor("sizenwse")
            dragTopLeftToBottomRightLocatedBottomRight:NoClipping(true)
            dragTopLeftToBottomRightLocatedBottomRight.downLastFrame = false
            function dragTopLeftToBottomRightLocatedBottomRight:Paint(w, h)
                draw.RoundedBox(0,   0,   0, w, 1, Color(255, 255, 255))
                draw.RoundedBox(0,   0,   0, 1, h, Color(255, 255, 255))
                draw.RoundedBox(0,   0, h-2, w, 2, Color(255, 255, 255))
                draw.RoundedBox(0, w-2,   0, 2, h, Color(255, 255, 255))

                if self:IsDown() then 
                    dragHandlerDiagonal(self)
                elseif not self:IsDown() and self.downLastFrame then 
                    self.initialMouseX = nil
                end
                self.downLastFrame = self:IsDown()
            
                if self:IsHovered() and input.IsKeyDown(KEY_LSHIFT) then 
                    surface.DrawCircle(w, h, 8, 0, 150, 255)
                    self:SetCursor("hand")
                else 
                    self:SetCursor("sizenwse")
                end
            end
            function dragTopLeftToBottomRightLocatedBottomRight:DoClick()
                if input.IsKeyDown(KEY_LSHIFT) then 
                    editor.tempDockPosition = 9
                end
            end

            local dragBottomLeftToTopRightLocatedBottomLeft = editor:Add("DButton")
            dragBottomLeftToTopRightLocatedBottomLeft:SetText("")
            dragBottomLeftToTopRightLocatedBottomLeft:SetPos(0, editor:GetTall() - 28)
            dragBottomLeftToTopRightLocatedBottomLeft:SetSize(28, 28)
            dragBottomLeftToTopRightLocatedBottomLeft:SetCursor("sizenesw")
            dragBottomLeftToTopRightLocatedBottomLeft:NoClipping(true)
            dragBottomLeftToTopRightLocatedBottomLeft.downLastFrame = false
            function dragBottomLeftToTopRightLocatedBottomLeft:Paint(w, h)
                draw.RoundedBox(0,   0,   0, w, 1, Color(255, 255, 255))
                draw.RoundedBox(0,   0,   0, 2, h, Color(255, 255, 255))
                draw.RoundedBox(0,   0, h-2, w, 2, Color(255, 255, 255))
                draw.RoundedBox(0, w-1,   0, 1, h, Color(255, 255, 255))

                if self:IsDown() then 
                    dragHandlerDiagonal(self, true)
                elseif not self:IsDown() and self.downLastFrame then 
                    self.initialMouseX = nil
                end
                self.downLastFrame = self:IsDown()
            
                if self:IsHovered() and input.IsKeyDown(KEY_LSHIFT) then 
                    surface.DrawCircle(0, h, 8, 0, 150, 255)
                    self:SetCursor("hand")
                else 
                    self:SetCursor("sizenesw")
                end
            end
            function dragBottomLeftToTopRightLocatedBottomLeft:DoClick()
                if input.IsKeyDown(KEY_LSHIFT) then 
                    editor.tempDockPosition = 7
                end
            end

            local dragBottomLeftToTopRightLocatedTopRight = editor:Add("DButton")
            dragBottomLeftToTopRightLocatedTopRight:SetText("")
            dragBottomLeftToTopRightLocatedTopRight:SetPos(editor:GetWide() - 28, 0)
            dragBottomLeftToTopRightLocatedTopRight:SetSize(28, 28)
            dragBottomLeftToTopRightLocatedTopRight:SetCursor("sizenesw")
            dragBottomLeftToTopRightLocatedTopRight:NoClipping(true)
            dragBottomLeftToTopRightLocatedTopRight.downLastFrame = false
            function dragBottomLeftToTopRightLocatedTopRight:Paint(w, h)
                draw.RoundedBox(0,   0,   0, w, 2, Color(255, 255, 255))
                draw.RoundedBox(0,   0,   0, 1, h, Color(255, 255, 255))
                draw.RoundedBox(0,   0, h-1, w, 1, Color(255, 255, 255))
                draw.RoundedBox(0, w-2,   0, 2, h, Color(255, 255, 255))

                if self:IsDown() then 
                    dragHandlerDiagonal(self, true)
                elseif not self:IsDown() and self.downLastFrame then 
                    self.initialMouseX = nil
                end
                self.downLastFrame = self:IsDown()
            
                if self:IsHovered() and input.IsKeyDown(KEY_LSHIFT) then 
                    surface.DrawCircle(w, 0, 8, 0, 150, 255)
                    self:SetCursor("hand")
                else 
                    self:SetCursor("sizenesw")
                end
            end
            function dragBottomLeftToTopRightLocatedTopRight:DoClick()
                if input.IsKeyDown(KEY_LSHIFT) then 
                    editor.tempDockPosition = 3
                end
            end

            editorControls:SetSize(editor:GetWide(), 48)
            function editorControls:Paint(w, h)
                local y = editor:GetY() + editor:GetTall() + 4
                if y + h + 4 >= ScrH() then
                    y = editor:GetY() - h - 4
                end
                self:SetPos(editor:GetX(), y)

                draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 150))
                draw.Text({
                    text = "Hold LShift + click to set dock pos",
                    font = "nsz_normal",
                    pos = {4, 36},
                    yalign = TEXT_ALIGN_CENTER,
                    color = Color(255, 255, 255)
                })
            end

            local cancel = editorControls:Add("NSZButton")
            cancel:SetText("Cancel")
            cancel:SetSize(math.Round(editorControls:GetWide() / 2) - 2, 24)
            cancel:SetColor(Color(100, 100, 100))
            function cancel:DoClick()
                editor:OnKeyCodeReleased(KEY_ESCAPE)
            end

            local accept = editorControls:Add("NSZButton")
            accept:SetText("Accept")
            accept:SetX(cancel:GetWide() + 4)
            accept:SetSize(editorControls:GetWide() - accept:GetX(), 24)
            function accept:DoClick()
                editor:OnKeyCodeReleased(KEY_ENTER)
            end
        end

        local colorEditorLabel = parent:Add("DLabel")
        colorEditorLabel:Dock(TOP)
        colorEditorLabel:DockMargin(0, 8, 0, 2)
        colorEditorLabel:SetText("Indicator Background:")
        colorEditorLabel:SetFont("nsz_between")
        colorEditorLabel:SetTextColor(Color(255, 255, 255))

        local colorEditor = parent:Add("DPanel")
        colorEditor:Dock(TOP)
        colorEditor:SetTall(24 * 4 + (3 * 4))
        function colorEditor:Paint(w, h)
            draw.RoundedBox(0, 0, 0, h * 4/3 + 8, h, Color(0, 0, 0, 100))
        end

        local colorMixer = colorEditor:Add("DColorMixer")
        colorMixer:SetSize(colorEditor:GetTall() * 16/9, colorEditor:GetTall())
        colorMixer:SetPalette(false)
        colorMixer:SetAlphaBar(false)
        colorMixer:SetWangs(false)
        colorMixer:SetColor(nsz.clientSettings.background.color)

        local mixerRInput = colorEditor:Add("DTextEntry")
        local mixerGInput = colorEditor:Add("DTextEntry")
        local mixerBInput = colorEditor:Add("DTextEntry")
        local mixerAInput = colorEditor:Add("DTextEntry")

        local mixerRLabel = colorEditor:Add("DButton")
        mixerRLabel:SetText("")
        mixerRLabel:SetSize(24, 24)
        mixerRLabel:SetPos(colorMixer:GetWide() + 4, 0)
        mixerRLabel:SetCursor("sizewe")
        function mixerRLabel:Paint(w, h) 
            draw.RoundedBox(0, 0, 0, w, h, Color(255, 62, 62, 100))
            draw.Text({
                text = "R",
                font = "nsz_between",
                pos = {w/2, h/2},
                color = Color(255, 255, 255),
                xalign = TEXT_ALIGN_CENTER,
                yalign = TEXT_ALIGN_CENTER
            })
            
            if not isbool(self.downLastFrame) then self.downLastFrame = false end
            if self:IsDown() then 
                if self.startX == nil then 
                    self.startX = gui.MouseX()
                    self.startInt = mixerRInput:GetInt() or 0
                end
                local x = math.Round((gui.MouseX() - self.startX) / 2.5)
                mixerRInput:SetText(math.Clamp(self.startInt + x, 0, 255))
                mixerRInput:OnChange()
            elseif not self:IsDown() and self.downLastFrame then 
                self.startX = nil
            end
            self.downLastFrame = self:IsDown()
        end
        function mixerRLabel:DoRightClick()
            mixerRInput:SetText(nsz.defaultClientSettings.background.color.r)
            mixerRInput:OnChange()
        end 
        
        mixerRInput:SetFont("nsz_between")
        mixerRInput:SetTextColor(Color(255, 255, 255))
        mixerRInput:SetNumeric(true)
        mixerRInput:SetSize(62, 24)
        mixerRInput:SetPos(colorMixer:GetWide() + 28, 0)
        mixerRInput:SetText(nsz.clientSettings.background.color.r)
        mixerRInput:SetUpdateOnType(true)
        function mixerRInput:Paint(w, h)
            draw.RoundedBox(0, 0, 0, w, h, Color(255, 62, 62, 50))
            self:DrawTextEntryText(self:GetTextColor(), Color(0, 150, 255), Color(255, 255, 255))
        end
        function mixerRInput:OnChange() 
            local color = colorMixer:GetColor()
            if self:GetInt() ~= nil then 
                colorMixer:SetColor(Color(self:GetInt(), color.g, color.b))
                nsz.clientSettings.background.color = Color(self:GetInt(), color.g, color.b, mixerAInput:GetInt() or 0)
            end
        end

        local mixerGLabel = colorEditor:Add("DButton")
        mixerGLabel:SetText("")
        mixerGLabel:SetCursor("sizewe")
        mixerGLabel:SetSize(24, 24)
        mixerGLabel:SetPos(colorMixer:GetWide() + 4, 28)
        function mixerGLabel:Paint(w, h) 
            draw.RoundedBox(0, 0, 0, w, h, Color(62, 255, 62, 70))
            draw.Text({
                text = "G",
                font = "nsz_between",
                pos = {w/2, h/2},
                color = Color(255, 255, 255),
                xalign = TEXT_ALIGN_CENTER,
                yalign = TEXT_ALIGN_CENTER
            })

            if not isbool(self.downLastFrame) then self.downLastFrame = false end
            if self:IsDown() then 
                if self.startX == nil then 
                    self.startX = gui.MouseX()
                    self.startInt = mixerGInput:GetInt() or 0
                end
                local x = math.Round((gui.MouseX() - self.startX) / 2.5)
                mixerGInput:SetText(math.Clamp(self.startInt + x, 0, 255))
                mixerGInput:OnChange()
            elseif not self:IsDown() and self.downLastFrame then 
                self.startX = nil
            end
            self.downLastFrame = self:IsDown()
        end
        function mixerGLabel:DoRightClick()
            mixerGInput:SetText(nsz.defaultClientSettings.background.color.g)
            mixerGInput:OnChange()
        end 
        
        mixerGInput:SetFont("nsz_between")
        mixerGInput:SetTextColor(Color(255, 255, 255))
        mixerGInput:SetNumeric(true)
        mixerGInput:SetSize(62, 24)
        mixerGInput:SetPos(colorMixer:GetWide() + 28, 28)
        mixerGInput:SetText(nsz.clientSettings.background.color.g)
        mixerGInput:SetUpdateOnType(true)
        function mixerGInput:Paint(w, h)
            draw.RoundedBox(0, 0, 0, w, h, Color(62, 255, 62, 35))
            self:DrawTextEntryText(self:GetTextColor(), Color(0, 150, 255), Color(255, 255, 255))
        end
        function mixerGInput:OnChange() 
            local color = colorMixer:GetColor()
            if self:GetInt() ~= nil then 
                colorMixer:SetColor(Color(color.r, self:GetInt(), color.b))
                nsz.clientSettings.background.color = Color(color.r, self:GetInt(), color.b, mixerAInput:GetInt() or 0)
            end
        end

        local mixerBLabel = colorEditor:Add("DButton")
        mixerBLabel:SetText("")
        mixerBLabel:SetCursor("sizewe")
        mixerBLabel:SetSize(24, 24)
        mixerBLabel:SetPos(colorMixer:GetWide() + 4, 56)
        function mixerBLabel:Paint(w, h) 
            draw.RoundedBox(0, 0, 0, w, h, Color(62, 62, 255, 110))
            draw.Text({
                text = "B",
                font = "nsz_between",
                pos = {w/2, h/2},
                color = Color(255, 255, 255),
                xalign = TEXT_ALIGN_CENTER,
                yalign = TEXT_ALIGN_CENTER
            })

            if not isbool(self.downLastFrame) then self.downLastFrame = false end
            if self:IsDown() then 
                if self.startX == nil then 
                    self.startX = gui.MouseX()
                    self.startInt = mixerBInput:GetInt() or 0
                end
                local x = math.Round((gui.MouseX() - self.startX) / 2.5)
                mixerBInput:SetText(math.Clamp(self.startInt + x, 0, 255))
                mixerBInput:OnChange()
            elseif not self:IsDown() and self.downLastFrame then 
                self.startX = nil
            end
            self.downLastFrame = self:IsDown()
        end
        function mixerBLabel:DoRightClick()
            mixerBInput:SetText(nsz.defaultClientSettings.background.color.b)
            mixerBInput:OnChange()
        end 
        
        mixerBInput:SetFont("nsz_between")
        mixerBInput:SetTextColor(Color(255, 255, 255))
        mixerBInput:SetNumeric(true)
        mixerBInput:SetSize(62, 24)
        mixerBInput:SetPos(colorMixer:GetWide() + 28, 56)
        mixerBInput:SetText(nsz.clientSettings.background.color.b)
        mixerBInput:SetUpdateOnType(true)
        function mixerBInput:Paint(w, h)
            draw.RoundedBox(0, 0, 0, w, h, Color(62, 62, 255, 55))
            self:DrawTextEntryText(self:GetTextColor(), Color(0, 150, 255), Color(255, 255, 255))
        end
        function mixerBInput:OnChange() 
            local color = colorMixer:GetColor()
            if self:GetInt() ~= nil then 
                colorMixer:SetColor(Color(color.r, color.g, self:GetInt()))
                nsz.clientSettings.background.color = Color(color.r, color.g, self:GetInt(), mixerAInput:GetInt() or 0)
            end
        end

        local mixerALabel = colorEditor:Add("DButton")
        mixerALabel:SetText("")
        mixerALabel:SetCursor("sizewe")
        mixerALabel:SetSize(24, 24)
        mixerALabel:SetPos(colorMixer:GetWide() + 4, 24 * 3 + 12)
        function mixerALabel:Paint(w, h) 
            draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 150))
            draw.Text({
                text = "A",
                font = "nsz_between",
                pos = {w/2, h/2},
                color = Color(255, 255, 255),
                xalign = TEXT_ALIGN_CENTER,
                yalign = TEXT_ALIGN_CENTER
            })

            if not isbool(self.downLastFrame) then self.downLastFrame = false end
            if self:IsDown() then 
                if self.startX == nil then 
                    self.startX = gui.MouseX()
                    self.startInt = mixerAInput:GetInt() or 0
                end
                local x = math.Round((gui.MouseX() - self.startX) / 2.5)
                mixerAInput:SetText(math.Clamp(self.startInt + x, 0, 255))
                mixerAInput:OnChange()
            elseif not self:IsDown() and self.downLastFrame then 
                self.startX = nil
            end
            self.downLastFrame = self:IsDown()
        end
        function mixerALabel:DoRightClick()
            mixerAInput:SetText(nsz.defaultClientSettings.background.color.a)
            mixerAInput:OnChange()
        end 
        
        mixerAInput:SetFont("nsz_between")
        mixerAInput:SetTextColor(Color(255, 255, 255))
        mixerAInput:SetNumeric(true)
        mixerAInput:SetSize(62, 24)
        mixerAInput:SetPos(colorMixer:GetWide() + 28, 24 * 3 + 12)
        mixerAInput:SetText(nsz.clientSettings.background.color.a)
        mixerAInput:SetUpdateOnType(true)
        function mixerAInput:Paint(w, h)
            draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 100))
            self:DrawTextEntryText(self:GetTextColor(), Color(0, 150, 255), Color(255, 255, 255))
        end
        function mixerAInput:OnChange() 
            local color = colorMixer:GetColor()
            if self:GetInt() ~= nil then 
                nsz.clientSettings.background.color.a = self:GetInt()
            end
        end

        function colorMixer:ValueChanged(newColor)
            local rCaret = mixerRInput:GetCaretPos()
            local gCaret = mixerGInput:GetCaretPos()
            local bCaret = mixerBInput:GetCaretPos()

            mixerRInput:SetText(newColor.r)
            mixerGInput:SetText(newColor.g)
            mixerBInput:SetText(newColor.b)

            mixerRInput:SetCaretPos(rCaret)
            mixerGInput:SetCaretPos(gCaret)
            mixerBInput:SetCaretPos(bCaret)

            nsz.clientSettings.background.color = self:GetColor()
            nsz.clientSettings.background.color.a = mixerAInput:GetInt() or 0
        end

        local blurX = colorMixer:GetWide() + mixerRInput:GetWide() + 36

        local blurBackground = colorEditor:Add("DCheckBoxLabel")
        blurBackground:SetText("Blur Background (if A < 255)")
        blurBackground:SetTextColor(Color(255, 255, 255))
        blurBackground:SetFont("nsz_between")
        blurBackground:SizeToContentsX()
        blurBackground:SetTall(24)
        blurBackground:SetPos(blurX, 0)
        blurBackground:SetChecked(nsz.clientSettings.background.blur)
        function blurBackground:OnChange(checked)
            nsz.clientSettings.background.blur = checked
        end

        local blurStrength = colorEditor:Add("DNumSlider")
        blurStrength:Dock(TOP)
        blurStrength:DockMargin(blurX, blurBackground:GetTall(), 4, 0)
        blurStrength:SetMin(0.5)
        blurStrength:SetMax(5)
        blurStrength:SetDecimals(1)
        blurStrength:SetText("Blur Strength")
        blurStrength:SetDefaultValue(2)
        blurStrength:SetValue(nsz.clientSettings.background.blurStrength)
        blurStrength.Label:SetFont("nsz_between")
        blurStrength.Label:SetTextColor(Color(255, 255, 255))
        blurStrength.TextArea:SetFont("nsz_between")
        blurStrength.TextArea:SetTextColor(Color(255, 255, 255))

        function blurStrength:OnValueChanged(strength)
            nsz.clientSettings.background.blurStrength = math.Clamp(math.Round(strength, 1), 1, 5)
        end

        local buttonContainer = parent:Add("DPanel")
        buttonContainer:Dock(TOP)
        buttonContainer:DockMargin(0, 8, 4, 0)
        function buttonContainer:Paint() end

        local resetSettings = buttonContainer:Add("NSZButton")
        resetSettings:SetColor(Color(100, 100, 100))
        resetSettings:SetText("Reset to Default")
        resetSettings:SetIcon("icon16/bin_closed.png")
        resetSettings:SizeToContentsX()
        resetSettings:SetSize(resetSettings:GetWide() + 8, 24)
        function resetSettings:DoClick() 
            nsz.clientSettings = table.Copy(nsz.defaultClientSettings)
            nsz.SaveClientSettings()
            nsz.gui.Close()
            nsz.gui.Open()
        end

        local saveSettings = buttonContainer:Add("NSZButton")
        saveSettings:SetColor(Color(0, 150, 255))
        saveSettings:SetText("Save Settings")
        saveSettings:SetIcon("icon16/disk.png")
        saveSettings:SizeToContentsX()
        saveSettings:SetSize(saveSettings:GetWide() + 8, 24)
        saveSettings:SetPos(resetSettings:GetWide() + 4, 0)
        function saveSettings:DoClick()
            nsz.SaveClientSettings()
            self:SetText("Saved!")
            self:SetColor(Color(62, 255, 62))
            self:SetTextColor(Color(0, 0, 0))
            self:SetEnabled(false)
            timer.Simple(1, function()
                self:SetText("Save Settings")
                self:SetColor(Color(0, 150, 255))
                self:SetTextColor(Color(255, 255, 255))
                self:SetEnabled(true)
            end)
        end
    end
})