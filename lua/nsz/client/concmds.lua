-- Convars for the HUD
if not ConVarExists("nsz_show_zones") then
    CreateClientConVar("nsz_show_zones", 0, true, false, "Allows you to debug and lets you see zones no matter where you are located.", 0, 1)
end
if not ConVarExists("nsz_show_display") then
    CreateClientConVar("nsz_show_display", 1, true, false, "Should the HUD show which zones you are in?", 0, 1)
end

concommand.Add("nsz_delete", function(ply, cmd, args, argStr)
    -- I never trust the client. Just send to the server and let the server process the command :moyai:
    net.Start("nsz_delete")
        net.WriteString(argStr)
    net.SendToServer()
end)

concommand.Add("nsz_gui", function(ply, cmd, args, argStr)
    if gui.IsGameUIVisible() then 
        gui.HideGameUI()
    end
    nsz.gui.Open()
end)

-- This is when the server sends zones to the client
net.Receive("nsz_download", function()
    nsz.zones = net.ReadTable()
    nsz.zonetypes = net.ReadTable()
    nsz.zoneSettings = net.ReadTable()
end)

net.Receive("nsz_send_message", function()
    chat.AddText(nsz.language.GetPhrase(net.ReadString()))
end)