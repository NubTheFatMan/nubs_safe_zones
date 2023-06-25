local NSZComboBox = {}
function NSZComboBox:Init() 
    self.color = Color(0, 0, 0, 100)

    self:SetFont("nsz_between")
    self:SetTextColor(Color(255, 255, 255))

    function self.DropButton:Paint(w, h)
        if isfunction(self.RenderCondition) then 
            if not self:RenderCondition() then return end 
        end
    
        local par = self:GetParent()
        local col = par:GetTextColor()
        surface.SetDrawColor(col.r, col.g, col.b)
        draw.NoTexture()
    
        if par:IsMenuOpen() then
            surface.DrawPoly({
                {x = w/2, y = 4},
                {x = w - 4, y = h - 4},
                {x = 4, y = h - 4}
            })
        else
            surface.DrawPoly({
                {x = 4, y = 4},
                {x = w - 4, y = 4},
                {x = w/2, y = h - 4}
            })
        end
    end
end

function NSZComboBox:SetColor(col)
    if IsColor(col) then
        self.color = col
    end
end
function NSZComboBox:GetColor() return self.color end

function NSZComboBox:Paint(w, h)
    if isfunction(self.RenderCondition) then 
        if not self:RenderCondition() then return end 
    end

    draw.RoundedBox(0, 0, 0, w, h, self.color)
end

vgui.Register("NSZComboBox", NSZComboBox, "DComboBox")