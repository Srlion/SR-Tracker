-- some locals
local SR = SR_Tracker
local config = SR.Config
local colors = config.Colors
local languages = config.Languages
--

-- localizations
local ScrW	= ScrW
local ScrH	= ScrH

local ipairs	= ipairs
local os_time	= os.time
local os_date	= os.date
local tonumber 	= tonumber

local math_max 		= math.max
local math_floor	= math.floor

local simpleText = draw.SimpleText
local roundedBox = draw.RoundedBox

local SetFont 		= surface.SetFont
local GetTextSize	= surface.GetTextSize

local GetBySteamID = player.GetBySteamID
local table_concat = table.concat
--

local function S(v)
	return ScrH() * (v / 900)
end

local function FormatDate(time)
	return os_date("%d/%m/%Y", time)
end

surface.CreateFont("SR_Tracker.Texts", {font = "Lato", antialias = true, size = S(16), weight = 700})

local function div(number, number2) -- Thanks to this guide https://stackoverflow.com/a/21323783
	return math_floor(number / number2), math_floor(number % number2)
end

local function formatTime(number)
	local tmptable = {}

	if (tonumber(number) > 0) then
        local weeks, days, hours, minutes

		weeks, number = div(number, 604800)
		if (weeks > 0) then
			tmptable[#tmptable+1] = weeks .. "w"
		end

		days, number = div(number, 86400)
		if (days > 0) then
			tmptable[#tmptable+1] = days .. "d"
		end

		hours, number = div(number, 3600)
		if (hours > 0) then
			tmptable[#tmptable+1] = hours .. "h"
		end

		minutes, number = div(number, 60)
		if (minutes > 0) then
			tmptable[#tmptable+1] = minutes .. "m"
		end

		if (number > 0) then
			tmptable[#tmptable+1] = number .. "s"
		end
	else
		tmptable[#tmptable+1] = number .. "s"
	end

	return table_concat(tmptable, " ")
end

do
	local positions = {}

	positions["Top"] = function(w, h)
		return (ScrW() / 2) - (w / 2), 5
	end

	positions["TopRight"] = function(w, h)
		return ScrW() - w - 5, 5
	end

	positions["TopLeft"] = function(w, h)
		return 5, 5
	end

	positions["Bottom"] = function(w, h)
		return (ScrW() / 2) - (w / 2), ScrH() - h - 5
	end

	positions["BottomRight"] = function(w, h)
		return ScrW() - w - 5, ScrH() - h - 5
	end

	positions["BottomLeft"] = function(w, h)
		return 5, ScrH() - h - 5
	end

	local ply

	local fTime, sTime
	local getPos = positions[config.HUDPosition] || "TopRight"

	local w, h, x, y
	local fW, fH, sW, sH

	local fTimeTxt = languages.FullTime
	local sTimeTxt = languages.SessionTime

	local bgColor = colors.HUDBackground
	local txtColor = colors.HUDTexts

	local font = "SR_Tracker.Texts"

	hook.Add("HUDPaint", "SR_Tracker.HUD", function()
		ply = LocalPlayer()

		fTime = fTimeTxt:format(formatTime(ply:GetFullTime()))
		sTime = sTimeTxt:format(formatTime(ply:GetSessionTime()))

		SetFont(font)

		fW, fH = GetTextSize(fTime)
		sW, sH = GetTextSize(sTime)

		w, h = math_max(fW, sW) + 15, fH + sH + 10
		x, y = getPos(w, h)

		roundedBox(3, x, y, w, h, bgColor)

		simpleText(fTime, font, x + w * 0.5, y + 5, txtColor, 1, 2)
		simpleText(sTime, font, x + w * 0.5, y + fH + 5, txtColor, 1, 2)
	end)
end

local frame
local function OpenMenu(results, pages)
	if (IsValid(frame)) then frame:Remove() end

	frame = vgui.Create("DFrame")
	frame:SetTitle(FormatDate(os_time()))
	frame:SetSize(S(520), S(550))
	frame:Center()
	frame:MakePopup()

	frame.cachedPages = {}
	frame.cachedSearches = {}

	frame.currentPage = 1
	frame.cachedPages[1] = results

	local searchBox = frame:Add("DTextEntry")
	searchBox:Dock(TOP)
	searchBox:SetPlaceholderText(languages.Search)
	searchBox:SetUpdateOnType(true)

	searchBox.OnEnter = function(s)
		local steamid = s:GetText()

		local cached = frame.cachedSearches[steamid]
		if (cached) then
			frame.loadTimes(cached)
		else
			frame.searchingSteamid = steamid

			net.Start("SR_Tracker.Search")
				net.WriteString(steamid)
			net.SendToServer()
		end

		frame.searched = true
	end

	searchBox.OnValueChange = function(s, value)
		if (value == "" && frame.searched) then
			frame.searched = false
			frame.loadTimes(frame.cachedPages[frame.currentPage])
		end
	end

	local timesList = frame:Add("DListView")
	timesList:Dock(FILL)
	timesList:DockMargin(0, 3, 0, 4)
	timesList:SetMultiSelect(false)

	timesList.OnRowRightClick = function(s, id, line)
		local steamid = line:GetColumnText(1)

		local Menu = DermaMenu()

		Menu:AddOption(languages.Reset, function()
			net.Start("SR_Tracker.ResetTime")
				net.WriteString(steamid)
			net.SendToServer()

			line:SetColumnText(2, "0s")
		end)

		Menu:AddOption(languages.CopySteamID, function()
			SetClipboardText(line:GetColumnText(1))
		end)

		Menu:AddOption(languages.CopySteamID64, function()
			SetClipboardText(util.SteamIDTo64(line:GetColumnText(1)))
		end)

		Menu:Open()
	end

	timesList:AddColumn(languages.SteamID)
	timesList:AddColumn(languages.PlayTime)
	timesList:AddColumn(languages.FirstJoin)
	timesList:AddColumn(languages.LastJoin)
	timesList:AddColumn(languages.Online)

	frame.loadTimes = function(data)
		timesList:Clear()

		for k, v in ipairs(data) do
			local steamid = v.steamid
			local line = timesList:AddLine(steamid, formatTime(v.time), FormatDate(v.firstjoin), FormatDate(v.lastjoin), GetBySteamID(steamid) && languages.Yes || languages.No)

			for _, column in ipairs(line.Columns) do
				column:SetContentAlignment(5)
			end
		end
	end

	frame.loadTimes(results)

	local bottomPanel = frame:Add("DPanel")
	bottomPanel:Dock(BOTTOM)
	bottomPanel:SetTall(S(22))
	bottomPanel:SetPaintBackground(false)

	local lastPage = bottomPanel:Add("DButton")
	lastPage:Dock(LEFT)
	lastPage:SetWide(S(30))
	lastPage:SetText("<")
	lastPage:SetTooltip(languages.LastPage)

	lastPage.DoClick = function(s, w, h)
		local page = frame.currentPage - 1
		if (page > 0) then
			frame.currentPage = page
			frame.loadTimes(frame.cachedPages[page])
		end
	end

	local currentPagePanel = bottomPanel:Add("DPanel")
	currentPagePanel:Dock(FILL)
	currentPagePanel:DockMargin(4, 0, 4, 0)

	local currentSkin = currentPagePanel:GetSkin()
	local textCol = currentSkin.Colours.Button.Normal

	currentPagePanel.Paint = function(s, w, h)
		currentSkin:PaintPanel(s, w, h)
		simpleText(languages.CurrPage:format(frame.currentPage, pages), "DermaDefault", w / 2, h / 2, textCol, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end

	local nextPage = bottomPanel:Add("DButton")
	nextPage:Dock(RIGHT)
	nextPage:SetWide(S(30))
	nextPage:SetText(">")
	nextPage:SetTooltip(languages.NextPage)

	nextPage.DoClick = function(s, w, h)
		if (frame.changingPage) then return end

		local page = frame.currentPage + 1
		if (page > pages) then return end

		local cachedpage = frame.cachedPages[page]
		if (cachedpage) then
			frame.currentPage = page
			frame.loadTimes(cachedpage)
		else
			net.Start("SR_Tracker.ChangePage")
				net.WriteUInt(page, 32)
			net.SendToServer()

			frame.changingPage = true
		end
	end
end

net.Receive("SR_Tracker.SendTimeOnJoin", function()
	local time = net.ReadUInt(32)
	local ostime = net.ReadUInt(32)

	hook.Add("HUDPaint", "SR_Tracker.SetCurrentTime", function()
		SR.SetPlyVar(LocalPlayer(), "Time", time)
		SR.SetPlyVar(LocalPlayer(), "JoinTime", ostime)

		hook.Remove("HUDPaint", "SR_Tracker.SetCurrentTime")
	end)
end)

net.Receive("SR_Tracker.ResetTime", function()
	SR.SetPlyVar(LocalPlayer(), "Time", 0)
	SR.SetPlyVar(LocalPlayer(), "JoinTime", os_time())
end)

net.Receive("SR_Tracker.SendTimes", function()
	local len = net.ReadUInt(32)
	local pages = net.ReadUInt(32)
	local results = SR.Decode(net.ReadData(len))

	OpenMenu(results, pages)
end)

net.Receive("SR_Tracker.ChangePage", function()
	if (!IsValid(frame)) then return end

	local results = SR.Decode(net.ReadData(net.ReadUInt(32)))

	frame.loadTimes(results)

	frame.changingPage = false
	frame.currentPage = frame.currentPage + 1
	frame.cachedPages[frame.currentPage] = results
end)

net.Receive("SR_Tracker.Search", function()
	if (!IsValid(frame)) then return end

	local results = SR.Decode(net.ReadData(net.ReadUInt(32)))

	frame.loadTimes(results)
	frame.cachedSearches[frame.searchingSteamid] = results
end)
