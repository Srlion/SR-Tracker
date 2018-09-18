-- some locals
local SR = SR_Tracker
local config = SR.Config
local menupermissions = config.MenuPermissions
--

-- localizations
local os_time = os.time

local pon_encode = SR.pon.encode
local pon_decode = SR.pon.decode

local compress 		= util.Compress
local decompress	= util.Decompress
--

function SR.SetPlyVar(ply, key, value, value2)
	ply.SR_Tracker = ply.SR_Tracker || {}
	ply.SR_Tracker[key] = value
end

function SR.GetPlayerVar(ply, key, key2)
	return ply.SR_Tracker[key]
end

function SR.Encode(data)
	return compress(pon_encode(data))
end

function SR.Decode(data)
	return pon_decode(decompress(data))
end

function SR.HasMenuPermissions(ply)
	return menupermissions[ply:GetUserGroup()] || menupermissions[ply:SteamID()] || menupermissions[ply:SteamID64()]
end

local PLAYER = FindMetaTable("Player")

function PLAYER:GetFullTime()
	return SR.GetPlayerVar(self, "Time") + (os_time() - SR.GetPlayerVar(self, "JoinTime"))
end

function PLAYER:GetSessionTime()
	return os_time() - SR.GetPlayerVar(self, "JoinTime")
end