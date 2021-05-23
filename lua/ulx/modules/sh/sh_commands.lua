function ulx.syncBans(calling_ply)
    ULibSync.syncULibPlayerBanData()
end
local syncBans = ulx.command("ULibSync", "ulx syncbans", ulx.syncBans, "!syncbans")
syncBans:defaultAccess(ULib.ACCESS_ADMIN)
syncBans:help("Syncs all local ban data to the ULibSync database.")


function ulx.syncUsers(calling_ply)
    ULibSync.syncULibUsers()
end
local syncBans = ulx.command("ULibSync", "ulx syncusers", ulx.syncUsers, "!syncusers")
syncBans:defaultAccess(ULib.ACCESS_ADMIN)
syncBans:help("Syncs all local users to the ULibSync database.")
