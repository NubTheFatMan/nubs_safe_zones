AddCSLuaFile()

-- Setup of the weapon
SWEP.PrintName = "Nub's Zone Creator"
SWEP.Author	   = "Nub"
SWEP.Purpose   = "Create different types of zones for your players."

SWEP.Slot    = 0
SWEP.SlotPos = 4

SWEP.Spawnable = true
SWEP.AdminOnly = false

SWEP.ViewModel    = Model("models/weapons/c_toolgun.mdl")
SWEP.WorldModel   = "models/weapons/w_toolgun.mdl"
SWEP.ViewModelFOV = 54

SWEP.Primary.ClipSize    = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic   = false
SWEP.Primary.Ammo        = "none"

SWEP.Secondary.ClipSize    = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic   = false
SWEP.Secondary.Ammo        = "none"

SWEP.DrawAmmo = false
SWEP.UseHands = true

function SWEP:Initialize()
	if SERVER then
		-- Make sure the zones are updated
		nsz:SendZones(self.Owner)
	else
		-- For some reason, this runs on all clients, but we only want it to run
		-- on whoever got the zone creator
		if LocalPlayer() ~= self.Owner then return end

		LocalPlayer():ChatPrint("NSZ Controls: Left click to set a point.")
		LocalPlayer():ChatPrint("NSZ Controls: Right click to open the zone type selector.")
		LocalPlayer():ChatPrint("NSZ Controls: Press R to reset the zone you are placing.")
		LocalPlayer():ChatPrint("NSZ Controls: Hold left alt to place the second point where you're aiming.")

		if not istable(nsz.currentZone) then
			nsz.currentZone = {type = "", points = {}}
		end
		if not istable(nsz.currentZone.points) then
			nsz.currentZone.points = {}
		end
		nsz.currentZone.type = ""
	end

	self:SetHoldType("pistol")
end

SWEP.nextPrimary = 0
function SWEP:PrimaryAttack()
	if CurTime() < self.nextPrimary then return end
	self.nextPrimary = CurTime() + 0.5

	if CLIENT then
		if LocalPlayer() ~= self.Owner then return end

		-- Make sure the zone information is correct
		if not istable(nsz.currentZone) then
			nsz.currentZone = {type = "", points = {}}
		end
		if not isstring(nsz.currentZone.type) then
			nsz.currentZone.type = ""
		end
		if not istable(nsz.currentZone.points) then
			nsz.currentZone.points = {}
		end

		-- Make sure they have the valid variables selected
		if not istable(nsz.zonetypes[nsz.currentZone.type]) then
			LocalPlayer():ChatPrint("NSZ Error: Invalid zone type selected. Right click to open the selector")
			return
		end
		if not isstring(nsz.zonetypes[nsz.currentZone.type].type) then -- This should never happen unless you mess with the zonetype table
			LocalPlayer():ChatPrint("NSZ Internal Error: The zone you are trying to edit isn't set up properly.")
			return
		end

		local dist = 100000000
		if isvector(nsz.currentZone.points[1]) and not input.IsKeyDown(KEY_LALT) then
			dist = 100
		end

		local tr = self.Owner:GetEyeTrace()
		tr.start = self.Owner:GetShootPos()
		tr.endpos = tr.start + self.Owner:GetAimVector() * dist
		tr.filter = self.Owner
		local trace = util.TraceLine(tr)

		if isvector(trace.HitPos) then
			table.insert(nsz.currentZone.points, trace.HitPos)

			if #nsz.currentZone.points == 2 then
				LocalPlayer():ChatPrint("NSZ: Creating zone..")
				net.Start("nsz_upload")
					net.WriteTable(nsz.currentZone)
				net.SendToServer()
				nsz.currentZone.points = {}
			else
				LocalPlayer():ChatPrint("NSZ: Point 1 set, please click elsewhere for the second point!")
			end
		else -- This should never happen, as a trace will always return the endpos if it didn't hit anything
			LocalPlayer():ChatPrint("NSZ Error: Invalid point (unable to locate where you're aiming)!")
		end
	end
end

SWEP.nextReload = 0
function SWEP:Reload()
	if CurTime() < self.nextReload then return end
	self.nextReload = CurTime() + 0.5

	if CLIENT then
		if LocalPlayer() ~= self.Owner then return end

		nsz.currentZone.points = {}
		chat.AddText("NSZ: Current zone reset!")
	end
end

SWEP.nextSecondary = 0
function SWEP:SecondaryAttack()
	if CurTime() < self.nextSecondary then return end
	self.nextSecondary = CurTime() + 1

	if CLIENT then
		if LocalPlayer() ~= self.Owner then return end

		local panel = vgui.Create("DFrame")
		panel:SetSize(ScrW()/5, 60)
		panel:Center()
		panel:SetTitle("Zone Type Selector")
		panel:SetSizable(false)
		panel:SetDraggable(false)
		panel:MakePopup()

		local dropdown = vgui.Create("DComboBox", panel)
		dropdown:SetPos(4, panel:GetTall() - 32)
		dropdown:SetSize(panel:GetWide() - 8, 28)
		dropdown:SetValue("Select a zone type...")
		for id, zone in pairs(nsz.zonetypes) do
			dropdown:AddChoice(zone.title .. " (" .. zone.type .. ")", zone.type)
		end
		function dropdown:OnSelect(index, value, data)
			nsz.currentZone.type = data
			LocalPlayer():ChatPrint("NSZ: Zone placement type set to " .. value .. ".")
			panel:Remove()
		end
	end
end
