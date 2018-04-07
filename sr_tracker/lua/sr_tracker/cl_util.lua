--
	local sr = SR_Tracker
	local config = sr.Config
--

--
	local math_floor = math.floor
	local math_Clamp = math.Clamp
	local table_insert = table.insert
	local table_concat = table.concat
	local tonumber = tonumber
--

function sr.EnableDragging(panel)
	local parent = panel:GetParent()

	if (parent:GetClassName() == "CGModBase") then
		parent = panel
	end

	function panel:Think()
		if (parent.y < 5) then
			parent:SetPos(parent.x, 5)
		end

		if (parent.x < 5) then
			parent:SetPos(5, parent.y)
		end

		if (parent.y > ScrH() - parent:GetTall() - 5) then
			parent:SetPos(parent.x, ScrH() - parent:GetTall() - 5)
		end

		if (parent.x > ScrW() - parent:GetWide() - 5) then
			parent:SetPos(ScrW() - parent:GetWide() - 5, parent.y)
		end

		if (self.Dragging) then
			local mousex = math_Clamp(gui.MouseX(), 1, ScrW() - 1)
			local mousey = math_Clamp(gui.MouseY(), 1, ScrH() - 1)

			local x = mousex - self.Dragging[1]
			local y = mousey - self.Dragging[2]

			parent:SetPos(x, y)
		end

		if (self.Hovered) then
			self:SetCursor("sizeall")
		end
	end

	function panel:OnMousePressed()
		self.Dragging = {gui.MouseX() - parent.x, gui.MouseY() - parent.y}

		self:MouseCapture(true)
	end

	function panel:OnMouseReleased()
		self.Dragging = nil
		self:MouseCapture(false)
	end
end

-- Thanks to this guide https://stackoverflow.com/a/21323783
local function div(number, number2)
	return math_floor(number / number2), math_floor(number % number2)
end

function sr.FormatTime(number)
	local tmptable = {}

	if (tonumber(number) > 0) then
		local weeks, number = div(number, 604800)
		if (weeks > 0) then
			table_insert(tmptable, weeks .. "w")
		end

		local days, number = div(number, 86400)
		if (days > 0) then
			table_insert(tmptable, days .. "d")
		end

		local hours, number = div(number, 3600)
		if (hours > 0) then
			table_insert(tmptable, hours .. "h")
		end

		local minutes, number = div(number, 60)
		if (minutes > 0) then
			table_insert(tmptable, minutes .. "m")
		end

		if (number > 0) then
			table_insert(tmptable, number .. "s")
		end
	else
		table_insert(tmptable, number .. "s")
	end

	return table_concat(tmptable, " ")
end