nsz.gui = nsz.gui or {}
nsz.gui.tabs = nsz.gui.tabs or {}

local blurMaterial = Material("pp/blurscreen")
nsz.blurFunction = function(x, y, w, h, strength)
    surface.SetDrawColor(0, 0, 0)
    surface.SetMaterial(blurMaterial)

    for i = 1, 5 do 
        blurMaterial:SetFloat("$blur", (i / 5) * strength)
        blurMaterial:Recompute()

        render.UpdateScreenEffectTexture()

        render.SetScissorRect(x, y, x + w, y + h, true)
        surface.DrawTexturedRect(0, 0, ScrW(), ScrH())
        render.SetScissorRect(0, 0, 0, 0, false)
    end
end

local box = function(x, y, w, h, a)
    draw.RoundedBox(0, x, y, w, h, Color(0, 0, 0, a or 100))
end

function nsz.gui.IsOpen() 
    if IsValid(nsz.gui.panel) and nsz.gui.panel.Remove then return true end
    return false
end

function nsz.gui.Open() 
    if nsz.gui.IsOpen() then nsz.gui.panel:Remove() end 

    nsz.gui.panel = vgui.Create("DFrame")
    -- nsz.gui.panel:SetTitle("#nsz.menu.title." .. nsz.clientSettings.language)
    nsz.gui.panel:SetTitle(nsz.language.GetPhrase("menu.title"))
    nsz.gui.panel:SetSize(ScrW()/2, ScrH()/2)
    nsz.gui.panel:SetDraggable(false)
    nsz.gui.panel:SetSizable(false)
    nsz.gui.panel:ShowCloseButton(false)
    nsz.gui.panel:Center()
    nsz.gui.panel:MakePopup()
    nsz.gui.panel:DockPadding(4, 28, 4, 4)
    function nsz.gui.panel:Paint(w, h)
        box(0, 0,  w, h)
        box(0, 0,  w, 22)
        box(0, 22, w, 2, 150)
    end

    -- I find it more intuitive/user friendly to make escape close the menu
    function nsz.gui.panel:OnKeyCodeReleased(keyCode)
        if keyCode == KEY_ESCAPE then 
            self:Remove()
            if gui.IsGameUIVisible() then 
                gui.HideGameUI()
            end
        end
    end

    local close = vgui.Create("NSZButton", nsz.gui.panel)
    close:SetText(nsz.language.GetPhrase("menu.close"))
    close:SetFont("nsz_normal")
    close:SizeToContentsX()
    close:SetTall(20)
    close:SetX(nsz.gui.panel:GetWide() - close:GetWide() - 4)
    function close:DoClick()
        nsz.gui.panel:OnKeyCodeReleased(KEY_ESCAPE)
    end

    local credits = vgui.Create("NSZButton", nsz.gui.panel)
    credits:SetText(nsz.language.GetPhrase("menu.credits"))
    credits:SetFont("nsz_normal")
    credits:SizeToContentsX()
    credits:SetTall(20)
    credits:SetX(close:GetX() - credits:GetWide() - 8)
    credits:SetColor(Color(62, 62, 62))

    nsz.gui.panel.tabMenu = vgui.Create("NSZTabMenu", nsz.gui.panel)
    nsz.gui.panel.tabMenu:Dock(FILL)

    for i, tab in ipairs(nsz.gui.tabs) do
        local title
        if isstring(tab.title) then 
            title = tab.title
        else 
            title = nsz.language.GetPhrase("tab." .. tab.identifier)
        end

        nsz.gui.panel.tabMenu:AddTab(title, tab.CreateContent, i == 1)
    end

    local creditsTab = NULL
    function credits:DoClick()
        if not IsValid(creditsTab) then
            creditsTab = nsz.gui.panel.tabMenu:AddTab(
                self:GetText(), 
                function(parent)
                    local devs = {"nub", "slime"}
                    for i, dev in ipairs(devs) do 
                        local container = vgui.Create("DPanel", parent)
                        container:Dock(TOP)
                        container:DockMargin(0, 0, 0, 8)
                        function container:Paint(w, h)
                            draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 100))
                        end
                        container:DockPadding(4, 4, 4, 4)

                        local height = 4
                        local title = vgui.Create("DLabel", container)
                        title:Dock(TOP)
                        title:SetFont("nsz_large")
                        title:SetText(nsz.language.GetPhrase("dev." .. dev .. ".name"))
                        title:SetTextColor(Color(255, 255, 255))
                        title:SizeToContents()
                        height = height + title:GetTall() + 4

                        local contributions = vgui.Create("NSZLabel", container)
                        contributions:Dock(TOP)
                        contributions:DockMargin(0, 4, 0, 0)
                        contributions:SetText(nsz.language.GetPhrase("dev." .. dev .. ".contributions"))
                        height = height + contributions:GetTall()

                        local buttonsContainer = vgui.Create("DPanel", container)
                        buttonsContainer:Dock(TOP)
                        buttonsContainer:DockMargin(0, 4, 0, 0)
                        buttonsContainer:SetTall(28)
                        function buttonsContainer:Paint() end
                        height = height + buttonsContainer:GetTall() + 2

                        local steam = vgui.Create("NSZButton", buttonsContainer)
                        steam:Dock(LEFT)
                        steam:SetText(nsz.language.GetPhrase("dev.buttontext.steam"))
                        steam:SetColor(Color(25, 31, 71))
                        steam:SizeToContents()
                        function steam:DoClick() gui.OpenURL(nsz.language.GetPhrase("dev." .. dev .. ".link.steam")) end

                        local github = vgui.Create("NSZButton", buttonsContainer)
                        github:SetText(nsz.language.GetPhrase("dev.buttontext.github"))
                        github:SetColor(Color(36, 41, 47))
                        github:SizeToContents()
                        github:Dock(LEFT)
                        github:DockMargin(4, 0, 0, 0)
                        function github:DoClick() gui.OpenURL(nsz.language.GetPhrase("dev." .. dev .. ".link.github")) end

                        if i == 1 then 
                            -- Secret hehe
                            if not isbool(nsz.clientSettings.secrethehe) then nsz.clientSettings.secrethehe = nsz.defaultClientSettings.secrethehe end

                            local unlockForbiddenLanguage = vgui.Create("DImageButton", buttonsContainer)
                            if nsz.clientSettings.secrethehe then 
                                unlockForbiddenLanguage:SetImage("icon16/lock_open.png")
                            else 
                                unlockForbiddenLanguage:SetImage("icon16/lock.png")
                            end
                            unlockForbiddenLanguage:SetSize(20, 20)
                            unlockForbiddenLanguage:Dock(RIGHT)
                            unlockForbiddenLanguage:DockMargin(0, 4, 0, 4)
                            unlockForbiddenLanguage:SetToolTip(nsz.language.GetPhrase("dev.secret"))

                            function unlockForbiddenLanguage:DoClick()
                                nsz.clientSettings.secrethehe = not nsz.clientSettings.secrethehe
                                if nsz.clientSettings.secrethehe then 
                                    unlockForbiddenLanguage:SetImage("icon16/lock_open.png")
                                    if not table.HasValue(nsz.language.Languages, "Forbidden") then table.insert(nsz.language.Languages, "Forbidden") end
                                else 
                                    unlockForbiddenLanguage:SetImage("icon16/lock.png")
                                    table.RemoveByValue(nsz.language.Languages, "Forbidden")
                                end
                            end
                        end

                        container:SetTall(height)
                    end
                end, 
                true
            ) 
        else 
            creditsTab:DoClick(true)
        end
    end
end

hook.Add("HUDPaint", "NSZDrawBlurs", function() 
    if IsValid(nsz.gui.panel) then 
        local x, y = nsz.gui.panel:GetPos()
        local w, h = nsz.gui.panel:GetSize()
        nsz.blurFunction(x, y, w, h, 3)
    elseif IsValid(nsz.gui.offsetEditor) then 
        local x, y = nsz.gui.offsetEditor:GetPos()
        local w, h = nsz.gui.offsetEditor:GetSize()
        nsz.blurFunction(x, y, w, h, 3)
        
        local xControls, yControls = nsz.gui.offsetEditorControls:GetPos()
        local wControls, hControls = nsz.gui.offsetEditorControls:GetSize()
        nsz.blurFunction(xControls, yControls, wControls, hControls, 3)
    end
end)

function nsz.gui.AddTab(options)
    local tab = table.Copy(options)
    -- if not isstring(tab.title) then tab.title = "#nsz.menu.unnamed." .. nsz.clientSettings.language end
    if not isnumber(tab.sort) then tab.sort = 0 end
    -- if not isbool(tab.forcedPrivilege) then tab.forcedPrivilege = false end
    
    if not isstring(tab.identifier) then tab.identifier = "null" end

    for i, existingTab in ipairs(nsz.gui.tabs) do 
        if existingTab.identifier == tab.identifier then 
            table.remove(nsz.gui.tabs, i)
            break
        end
    end

    table.insert(nsz.gui.tabs, tab)
    table.sort(nsz.gui.tabs, function(a, b) return a.sort < b.sort end)
    return tab
end

function nsz.gui.Close()
    if nsz.gui.IsOpen() then 
        nsz.gui.panel:Remove()
    end
end