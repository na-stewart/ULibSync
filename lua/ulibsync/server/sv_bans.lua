local function createULibSyncBanDataTable()
    local q = ULibSync.mysql:query('CREATE TABLE IF NOT EXISTS `ulib_bans` (' ..
    '`id` INT AUTO_INCREMENT PRIMARY KEY,' ..
    '`steamid` VARCHAR(18) UNIQUE NOT NULL,' ..
    '`reason` TINYTEXT,' ..
    '`unban` VARCHAR(12) NOT NULL,' ..
    '`manual_unban` BOOLEAN NOT NULL DEFAULT FALSE,' ..
    '`username` VARCHAR(32),' ..
    '`host` VARCHAR(60) NOT NULL,' ..
    '`admin` VARCHAR(52),' ..
    '`date_created` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),' ..
    '`date_updated` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6)' ..
    ');')
    function q:onError(err)
        ULibSync.log('Table creation failed.', 'bans', 50, err)
    end
    q:start()
end

local function addULibSyncPlayerBanHooks()
    hook.Add('ULibPlayerBanned', 'ULibSyncPlayerBanned', ULibSync.syncULibPlayerBan)
    hook.Add('ULibPlayerUnBanned', 'ULibSyncPlayerUnBanned', ULibSync.syncULibPlayerUnban)
end

local function removeULibSyncPlayerBanHooks()
    hook.Remove('ULibPlayerBanned', 'ULibSyncPlayerBanned')    
    hook.Remove('ULibPlayerUnBanned', 'ULibSyncPlayerUnBanned')        
end

function ULibSync.initBanSync()
    createULibSyncBanDataTable()
    addULibSyncPlayerBanHooks()
end

function ULibSync.syncULibPlayerBans()
    for steamid, banData in pairs(ULib.bans) do
        ULibSync.syncULibPlayerBan(steamid, banData, replace)
    end
end

function ULibSync.syncULibPlayerBan(steamid, banData, replace)
    local q = ULibSync.mysql:prepare('REPLACE INTO ulib_bans (`steamid`, `reason`, `unban`, `username`, `host`, `admin`) VALUES (?, ?, ?, ?, ?, ?)')
    q:setString(1, steamid)
    q:setString(3, tostring(banData.unban))
    q:setString(5, GetHostName())
    if banData.reason then q:setString(2, banData.reason) end
    if banData.admin then q:setString(6, banData.admin) end
    if banData.name  then q:setString(4, banData.name) end
    function q:onSuccess(data)
        ULibSync.log('Ban has been synced successfully', steamid, 20)
    end
    function q:onError(err)
        ULibSync.log('Ban has not been synced.', steamid, 40, err)
    end
    q:start()
end

function ULibSync.syncULibPlayerUnban(steamid)
    local q = ULibSync.mysql:prepare('UPDATE ulib_bans SET manual_unban = ? WHERE steamid = ?')
    q:setBoolean(1, true)
    q:setString(2, steamid)
    function q:onSuccess(data)
        ULibSync.log('UnBan has been synced successfully.', steamid, 20)
    end
    function q:onError(err)
        ULibSync.log('UnBan has not been synced.', steamid, 40, err)
    end
    q:start()
end

local function timeRemaining(seconds)
    secondsToNumber = tonumber(seconds)
    return (secondsToNumber > 0) and (secondsToNumber - os.time()) / 60 or 0
end

local function syncULibSyncPlayerBanDataLocally(steamid, uLibSyncPlayerBanData)
    local uLibSyncTimeRemaining = timeRemaining(uLibSyncPlayerBanData.unban)  
    if uLibSyncPlayerBanData['manual_unban'] == 1 then
        if ULib.bans[steamid] then
            ULib.unban(steamid)
            ULibSync.log('UnBan has been synced locally.', steamid, 20)       
        end  
    elseif uLibSyncTimeRemaining > 0 or uLibSyncPlayerBanData.unban == '0' then
        if not ULib.bans[steamid] or ULib.bans[steamid].reason != uLibSyncPlayerBanData.reason or uLibSyncTimeRemaining != timeRemaining(ULib.bans[steamid].unban) then
            ULib.addBan(steamid, uLibSyncTimeRemaining, uLibSyncPlayerBanData.reason, uLibSyncPlayerBanData.username)
            ULibSync.log('Ban has been synced locally.', steamid, 20)     
        end
    end
end

function ULibSync.syncULibSyncPlayerBanData(steamID64)
    local steamid = util.SteamIDFrom64(steamID64)
    local q = ULibSync.mysql:prepare('SELECT steamid, reason, unban, manual_unban, username FROM ulib_bans WHERE steamid = ?')
    q:setString(1, steamid)
    function q:onSuccess(data)   
        local uLibSyncPlayerBanData = data[1]
        if uLibSyncPlayerBanData then 
            removeULibSyncPlayerBanHooks()    
            syncULibSyncPlayerBanDataLocally(steamid, uLibSyncPlayerBanData)
            addULibSyncPlayerBanHooks()       
        end
    end
    function q:onError(err)
        ULibSync.log('Ban has not been synced locally.', steamid, 20, err)
    end
    q:start()
    q:wait(true)
end
hook.Add('CheckPassword', 'ULibSyncPlayerBanCheck', ULibSync.syncULibSyncPlayerBanData)
