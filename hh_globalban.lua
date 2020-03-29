
PLUGIN.name = "HHub Global Ban"
PLUGIN.author = "Half-Life 2 Roleplay Hub"
PLUGIN.description = "A plugin which automatically bans malicious individuals based on a Global Ban list."
PLUGIN.version = "v1"

if (SERVER) then
	function PLUGIN:CheckVersion()
		MsgC(Color(231, 148, 60), "[HGB] The HHub Global Ban plugin has been initialized.\n")
		MsgC(Color(231, 148, 60), "[HGB] Local Version: "..self.version.."\n")
		MsgC(Color(231, 148, 60), "[HGB] Fetching for updates...\n")
		http.Fetch("https://dl.dropboxusercontent.com/s/i9khzmgp3hl136z/hgb_version_control_nut.txt", function(body)
			local info = string.Explode("\n", body)
			local versions = {}
			for k,v in pairs(info) do
				local version_info = string.Explode(": ", v)
				versions[version_info[1]] = version_info[2]
			end

			if (versions["nutHHubGlobalBan"]) then
				if (versions["nutHHubGlobalBan"] == self.version) then
					MsgC(Color(46, 204, 113), "[HGB] The HHub Global Ban plugin is up to date!\n")
				else
					MsgC(Color(231, 76, 60), "[HGB] The HHub Global Ban plugin is out of date! Please install the latest version at your earliest convenience.\n")
					MsgC(Color(231, 76, 60), "[HGB] Local version: "..self.version.."\n")
					MsgC(Color(231, 76, 60), "[HGB] Newest version: "..versions["nutHHubGlobalBan"].."\n")
				end
			else
				MsgC(Color(231, 76, 60), "[HGB] Failed to fetch local version information!\n")
			end
		end, function()
			MsgC(Color(231, 76, 60), "[HGB] Failed to connect with Version Tracker!\n")
		end)
	end

	local Initialized = false -- Ensure the plugin is initialized.
	function PLUGIN:Think()
		if (!Initialized) then
			self:CheckVersion()
			Initialized = true
		end
    end
    
    -- Called when a player initially spawns.
    function PLUGIN:PlayerInitialSpawn(player)
        local plyname = player:Name()
        local plyid = player:SteamID64()
        local plyip = player:IPAddress()
        local banlist

        http.Fetch("https://dl.dropboxusercontent.com/s/j08c341boqj5x8w/hgb_ban_list.txt", function(body)
			banlist = body
			MsgC(Color(231, 148, 60), "[HGB] Comparing SteamID64 '"..plyid.."' with HHub Global Ban list...\n")
			if (string.find(banlist, plyid, nil, true)) then
				if (serverguard) then
					serverguard:BanPlayer(nil, plyid, 0, "Autobanned by HHubGlobalBan.")
					-- No need to add it to the chatbox since SG does it on it's own anyway.
				elseif (ULib) then
					ULib.ban(plyid, 0, "Autobanned by HHubGlobalBan.")
					-- No need to add it to the chatbox since ULX does it on it's own anyway.
				else
					player:Ban(0, true)
					RunConsoleCommand("addip", 0, plyip) -- Ban their IP too just to be sure.
					MsgC(Color(231, 76, 60), "[HGB] "..plyname.." was automatically banned for being in the HHub Global Ban list.\n")
				end
            else
                MsgC(Color(46, 204, 113), "[HGB] "..plyname.." is not in the Global Ban list.\n")
            end
        end)
    end
end
