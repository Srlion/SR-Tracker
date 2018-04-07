--
	local sr = SR_Tracker
	local config = sr.Config
	local colors = config.Colors
	local languages = config.Languages
	local materials = config.Materials
--

--
	local CurTime = CurTime
	local ipairs = ipairs
	local DrawText = draw.SimpleText
	local surface = surface
	local SetFont = surface.SetFont
	local GetTextSize = surface.GetTextSize
	local math_Clamp = math.Clamp
	local FormatTime = sr.FormatTime
	local GetBySteamID = player.GetBySteamID
--

--
	local function S(value)
		return value * math_Clamp(ScrH() / 1080, 0.7, 1)
	end

	local function FormatText(str, ...)
		return str:format(...)
	end

	local function FormatDate(time)
		return os.date("%d/%m/%Y", time)
	end
--

--
	surface.CreateFont("SR_Tracker.Texts", {font = "Lato", antialias = true, size = S(20), weight = 700})
	surface.CreateFont("SR_Tracker.Header", {font = "Lato", antialias = true, size = S(30), weight = 700})
	surface.CreateFont("SR_Tracker.TextBoxText", {font = "Lato", antialias = true, size = S(18), weight = 700})
	surface.CreateFont("SR_Tracker.ColumnHeader", {font = "Lato", antialias = true, size = S(18), weight = 700})
	surface.CreateFont("SR_Tracker.Line", {font = "Lato", antialias = true, size = S(16), weight = 700})
	surface.CreateFont("SR_Tracker.Buttons", {font = "Lato", antialias = true, size = S(18), weight = 700})
	surface.CreateFont("SR_Tracker.Pages", {font = "Lato", antialias = true, size = S(18), weight = 700})
--

local function DrawTimeHUD()
	local ply = LocalPlayer()

	local w, h = ScrW(), ScrH()
	local x, y = w - 205, 0

	local Panel = vgui.Create("DPanel")
	Panel:SetSize(S(220), S(60))
	Panel:SetPos(w - Panel:GetWide() - 5, 0)
	Panel:TDLib()
		:ClearPaint()
		:Background(colors.HUDBackground, 3)

	local color = colors.HUDTexts
	local font = "SR_Tracker.Texts"
	local fulltimetext = languages.FullTime
	local sessiontimetext = languages.SessionTime

	Panel:On("Paint", function(self, w, h) -- from tdlib
		local text1 = FormatText(fulltimetext, FormatTime(ply:GetFullTime()))
		local text2 = FormatText(sessiontimetext, FormatTime(ply:GetSessionTime()))

		SetFont(font)
		local tw, th = GetTextSize(text1)

		SetFont(font)
		local bw, bh = GetTextSize(text2)

		local x = w / 2
		local y1, y2 = h / 2 - bh / 2, h / 2 + th / 2

		DrawText(text1, font, x, y1, color, 1, 1)
		DrawText(text2, font, x, y2, color, 1, 1)
	end)

	sr.EnableDragging(Panel)
end

local function LoadLines(menu, results)
	menu = menu.list

	if (!menu || !istable(results)) then
		return
	end

	menu:Clear()

	local alphatime = 0
	for _, v in ipairs(results) do
		if (!v) then continue end

		local steamid = v.steamid
		local online = GetBySteamID(steamid) && languages.Yes || languages.No

		local line = menu:AddLine(steamid, FormatTime(v.time), FormatDate(v.lastjoin), FormatDate(v.firstjoin), online)
		line:SetAlpha(0)
		line:AlphaTo(255, 0.2, 0 + alphatime)
		line:TDLib()
			:ClearPaint()
			:FadeHover(colors.Background)

		local changed = true
		line:On("Paint", function(self, w, h)
			if (self:IsHovered()) then
				if (changed) then
					changed = false
					for _, v in ipairs(line.Columns) do
						v:SetColor(color_white)
					end
				end
			else
				if (!changed) then
					changed = true
					for _, v in ipairs(line.Columns) do
						v:SetColor(colors.Background)
					end
				end
			end
		end)

		for _, v in ipairs(line.Columns) do
			v:SetContentAlignment(5)
			v:SetFont("SR_Tracker.Line")
			v:SetColor(colors.Background)
		end

		alphatime = alphatime + 0.02
	end
end

local function OpenMenu(results, pages)
	if (sr.TrackerMenu) then
		sr.TrackerMenu:Remove()
	end

	local w, h = ScrW() / 2, ScrH() / 2
	local w2, h2 = S(950), S(950)
	local x, y = w - (w2 / 2), h - (h2 / 2)

	local menu = vgui.Create("EditablePanel")
	menu:SetSize(0, 0)
	menu:Center()
	menu:MakePopup()
	menu:TDLib()
		:ClearPaint()
		:Background(colors.Background, 3)

	menu:MoveTo(x, y, 0.4, 0, -1)
	menu:SizeTo(w2, h2, 0.4, 0, -1, function()
		local w2, h2 = S(640), S(640)
		local x, y = w - (w2 / 2), h - (h2 / 2)

		menu:SizeTo(w2, h2, 0.3, 0, -1, function()
			sr.HookCall("LoadedPanel")
		end)
		menu:MoveTo(x, y, 0.3, 0, -1)
	end)

	menu.CurrentPage = 1
	menu.CachedPages = {}
	menu.CachedPages[1] = results
	menu.CachedSearches = {}

	menu.Header = vgui.Create("DPanel", menu)
	menu.Header:Dock(TOP)
	menu.Header:SetTall(S(52))
	menu.Header:SetTooltip(languages.Drag)
	menu.Header:TDLib()
		:ClearPaint()
		:Background(colors.Header, 3, true, true, false, false)
		:Text(FormatText("SR Tracker (%s)", FormatDate(os.time())), "SR_Tracker.Header")

	sr.EnableDragging(menu.Header)

	menu.button = vgui.Create("DButton", menu.Header)
	menu.button:Dock(RIGHT)
	menu.button:DockMargin(0, 3, 3, 3)
	menu.button:SetWidth(S(32))
	menu.button:SetText("")
	menu.button:SetTooltip(languages.Close)
	menu.button:TDLib()
		:ClearPaint()
		:CircleExpandHover(colors.CloseButtonHover, 15)

	menu.button:On("Paint", function(_, w, h)
		surface.SetMaterial(materials.CloseButton)
		surface.SetDrawColor(color_white)
		surface.DrawTexturedRectRotated(w / 2, h / 2, S(20), S(20), 0)
	end)

	menu.button:On("DoClick", function()
		menu:MoveTo(x, y, 0.4, 0, -1)
		menu:SizeTo(w2, h2, 0.4, 0, -1, function()
			local w2, h2 = 0, 0
			local x, y = w - (w2 / 2), h - (h2 / 2)

			menu:SizeTo(w2, h2, 0.25, 0, -1, function()
				menu:Remove()
			end)

			menu:MoveTo(x, y, 0.25, 0, -1)
		end)
	end)

	menu.searchbox = vgui.Create("DTextEntry", menu)
	menu.searchbox:Dock(TOP)
	menu.searchbox:DockMargin(5, 5, 5, 0)
	menu.searchbox:SetPlaceholderText("Search...")
	menu.searchbox:SetFont("SR_Tracker.TextBoxText")
	menu.searchbox:SetUpdateOnType(true)
	menu.searchbox:TDLib()
		:Background(colors.SearchBarBackground, 2)
		:SetTransitionFunc(function(self) return self:IsEditing() end)
		:BarHover(nil, 1)

	menu.searchbox:On("Paint", function(self, w, h)
		self:DrawTextEntryText(color_white, colors.Background, color_white)
	end)

	menu.searchbox:On("OnEnter", function(self)
		local steamid = self:GetText()
		local cached = menu.CachedSearches[steamid]
		if (cached) then
			LoadLines(menu, cached)
		else
			net.Start("SR_Tracker.Search")
				net.WriteString(steamid)
			net.SendToServer()

			menu.searchingsteamid = steamid
		end
		menu.searched = true
	end)

	menu.searchbox:On("OnValueChange", function(self, value)
		if (value == "" && menu.searched) then
			menu.searched = false
			LoadLines(menu, menu.CachedPages[menu.CurrentPage])
		end
	end)

	menu.list = vgui.Create("DListView", menu)
	menu.list:Dock(FILL)
	menu.list:DockMargin(5, 5, 5, 0)
	menu.list:SetMultiSelect(false)
	menu.list:SetHeaderHeight(S(24))
	menu.list:SetDataHeight(S(22))
	menu.list:TDLib()
		:ClearPaint()
		:Background(colors.BackgroundList, 2)
		:Outline(colors.Background, 2)

	menu.list:On("Paint", function(self, w, h)
		draw.RoundedBox(0, 0, 0, w, self:GetHeaderHeight(), colors.Header)
	end)

	menu.list:On("OnRowRightClick", function(self, id, line)
		local steamid = line:GetColumnText(1)

		local Menu = DermaMenu()
		Menu:AddOption(languages.Reset, function()
			net.Start("SR_Tracker.ResetTime")
				net.WriteString(steamid)
			net.SendToServer()

			line:SetColumnText(2, "0.0s")
		end)

		Menu:Open()
	end)

	local bar = menu.list.VBar
	bar:SetHideButtons(true)
	bar:TDLib()
		:ClearPaint()
		:Background(colors.Background, 1)

	bar.btnGrip:TDLib()
		:ClearPaint()
		:Background(colors.Header, 1)

	function menu.list:PerformLayout()
		local YPos = 0
		local Wide = self:GetWide()

		if (IsValid(self.VBar)) then
			self.VBar:SetPos(self:GetWide() - S(12), self:GetHeaderHeight())
			self.VBar:SetSize(S(12), self:GetTall() - S(26))
			self.VBar:SetUp(self.VBar:GetTall(), self.pnlCanvas:GetTall())

			YPos = self.VBar:GetOffset()
		end

		self.pnlCanvas:SetPos(0, YPos + self:GetHeaderHeight())
		self.pnlCanvas:SetSize(Wide, self.pnlCanvas:GetTall())

		self:FixColumnsLayout()

		if (self:GetDirty(true)) then
			self:SetDirty(false)

			local y = self:DataLayout()

			self.pnlCanvas:SetTall(y)
			self:InvalidateLayout(true)
		end
	end

	sr.AddHook("LoadedPanel", "LoadData", function()
		menu.list:AddColumn(languages.steamid):SetWidth(S(135))
		menu.list:AddColumn(languages.PlayTime)
		menu.list:AddColumn(languages.LastJoin)
		menu.list:AddColumn(languages.FirstJoin)
		menu.list:AddColumn(languages.Online)

		for _, v in ipairs(menu.list.Columns) do
			v.Header:TDLib()
				:ClearPaint()
				:Background(colors.Header, 0)
				:Text(v.Header:GetText(), "SR_Tracker.ColumnHeader")
		end

		LoadLines(menu, results)
	end)

	menu.bottompanel = vgui.Create("DPanel", menu)
	menu.bottompanel:Dock(BOTTOM)
	menu.bottompanel:DockMargin(5, 5, 5, 5)
	menu.bottompanel:SetTall(S(24))
	menu.bottompanel:SetDrawBackground(false)

	menu.lastpage = vgui.Create("DButton", menu.bottompanel)
	menu.lastpage:Dock(LEFT)
	menu.lastpage:SetWide(S(30))
	menu.lastpage:SetTooltip("Go to last page")
	menu.lastpage:TDLib()
		:ClearPaint()
		:Background(colors.Header, 2)
		:CircleClick()
		:Text("<", "SR_Tracker.Buttons")

	menu.lastpage:On("DoClick", function(self, w, h)
		local page = menu.CurrentPage - 1
		if (page > 0) then
			menu.CurrentPage = page
			LoadLines(menu, menu.CachedPages[page])
		end
	end)

	menu.nextpage = vgui.Create("DButton", menu.bottompanel)
	menu.nextpage:Dock(RIGHT)
	menu.nextpage:SetWide(S(30))
	menu.nextpage:SetTooltip("Go to next page")
	menu.nextpage:TDLib()
		:ClearPaint()
		:Background(colors.Header, 2)
		:CircleClick()
		:Text(">", "SR_Tracker.Buttons")

	menu.nextpage:On("DoClick", function(self, w, h)
		local page = menu.CurrentPage + 1
		if (page <= pages) then
			local cachedpage = menu.CachedPages[page]
			if (cachedpage) then
				menu.CurrentPage = page
				LoadLines(menu, cachedpage)
			elseif (!menu.ChangingPage) then
				net.Start("SR_Tracker.ChangePage")
					net.WriteUInt(page, 32)
				net.SendToServer()

				menu.ChangingPage = true
			end
		end
	end)

	menu.pagepanel = vgui.Create("DPanel", menu.bottompanel)
	menu.pagepanel:Dock(FILL)
	menu.pagepanel:DockMargin(5, 0, 5, 0)
	menu.pagepanel:TDLib()
		:ClearPaint()
		:Background(colors.Header, 2)

	menu.pagepanel:On("Paint", function(self, w, h)
		draw.SimpleText(FormatText("Page: %d/%d", menu.CurrentPage, pages), "SR_Tracker.Pages", w / 2, h / 2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end)

	sr.TrackerMenu = menu
end

net.Receive("SR_Tracker.SendTime", function()
	local time = net.ReadFloat()

	hook.Add("HUDPaint", "SR_Tracker.DrawHUD", function()
		local ply = LocalPlayer()

		sr.CreatePlayerTable(ply)
		sr.SetPlayerVar(ply, "Time", time)
		sr.SetPlayerVar(ply, "JoinTime", CurTime())

		DrawTimeHUD()

		hook.Remove("HUDPaint", "SR_Tracker.DrawHUD")
	end)
end)

net.Receive("SR_Tracker.ResetTime", function()
	local ply = LocalPlayer()

	sr.SetPlayerVar(ply, "Time", 0)
	sr.SetPlayerVar(ply, "JoinTime", CurTime())
end)

net.Receive("SR_Tracker.SendTimes", function()
	local len = net.ReadUInt(32)
	local pages = net.ReadUInt(32)
	local results = sr.Decode(net.ReadData(len))
	
	OpenMenu(results, pages)
end)

net.Receive("SR_Tracker.ChangePage", function()
	local len = net.ReadUInt(32)
	local results = sr.Decode(net.ReadData(len))
	
	local menu = sr.TrackerMenu
	if (menu) then
		LoadLines(menu, results)

		menu.ChangingPage = false
		menu.CurrentPage = menu.CurrentPage + 1
		menu.CachedPages[menu.CurrentPage] = results
	end
end)

net.Receive("SR_Tracker.Search", function()
	local len = net.ReadUInt(32)
	local results = sr.Decode(net.ReadData(len))

	local menu = sr.TrackerMenu
	if (menu) then
		LoadLines(menu, results)

		menu.CachedSearches[menu.searchingsteamid] = results
	end
end)
