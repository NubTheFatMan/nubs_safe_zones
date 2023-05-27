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
    nsz.gui.panel:SetTitle("Safe Zones Interface")
    nsz.gui.panel:SetSize(ScrW()/2, ScrH()/2)
    nsz.gui.panel:SetDraggable(false)
    nsz.gui.panel:SetSizable(false)
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

    local tabMenu = vgui.Create("NSZTabMenu", nsz.gui.panel)
    tabMenu:Dock(FILL)

    for i, tab in ipairs(nsz.gui.tabs) do
        tabMenu:AddTab(tab.title, tab.CreateContent, i == 1)
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
    if not isstring(tab.title) then tab.title = "Unnamed" end
    if not isnumber(tab.sort) then tab.sort = 0 end
    if not isbool(tab.forcedPrivilege) then tab.forcedPrivilege = false end

    for i, existingTab in ipairs(nsz.gui.tabs) do 
        if existingTab.title == tab.title then 
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