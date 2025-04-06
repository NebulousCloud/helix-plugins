
util.AddNetworkString("ixCAPlayerSay")

net.Receive("ixCAPlayerSay", function(_, client)
	if (!client:IsCombine()) then return end
	
	local message = net.ReadString()
	hook.Run("PlayerSay", client, message)
end)

