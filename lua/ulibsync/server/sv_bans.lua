local function createULibSyncBanDataTable()
    local q = ULibSync.mysql:query('CREATE TABLE IF NOT EXISTS `ulib_bans` (' ..
    '`id` INT AUTO_INCREMENT PRIMARY KEY,' ..
    '`steamid` VARCHAR(19) UNIQUE NOT NULL,' ..
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
    ULibSync.log('Initializing sync.', 'bans', 10)
    createULibSyncBanDataTable()
    addULibSyncPlayerBanHooks()
    if ULibSync.syncPlayerBanDataOnJoin then
        hook.Add('CheckPassword', 'ULibSyncPlayerBanCheck', ULibSync.syncULibSyncPlayerBanData)
    end
end

function ULibSync.syncULibBans()
    local host, rows = GetHostName(), {}
    for steamid, banData in pairs(ULib.bans) do
        rows[#rows + 1] = string.format('(%s,%s,%s,%s,%s,%s)',
            ULibSync.escape(steamid),
            ULibSync.escape(banData.reason),
            ULibSync.escape(tostring(banData.unban)),
            ULibSync.escape(banData.name),
            ULibSync.escape(host),
            ULibSync.escape(banData.admin))
    end
    ULibSync.log(string.format('Attemping to sync %d bans.', #rows), 'bans', 10)
    ULibSync.batchReplace('ulib_bans', '`steamid`, `reason`, `unban`, `username`, `host`, `admin`', rows, 'bans', 'Bans')
end

function ULibSync.syncULibPlayerBan(steamid, banData)
    ULibSync.log('Attemping to sync player ban.', steamid, 10)
    local q = ULibSync.mysql:prepare('REPLACE INTO ulib_bans (`steamid`, `reason`, `unban`, `username`, `host`, `admin`) VALUES (?, ?, ?, ?, ?, ?)')
    q:setString(1, steamid)
    q:setString(3, tostring(banData.unban))
    q:setString(5, GetHostName())
    if banData.reason then q:setString(2, banData.reason) end
    if banData.admin then q:setString(6, banData.admin) end
    if banData.name then q:setString(4, banData.name) end
    function q:onSuccess(data)
        ULibSync.log('Ban has been synced successfully.', steamid, 20)
    end
    function q:onError(err)
        ULibSync.log('Ban has not been synced.', steamid, 40, err)
    end
    q:start()
end

function ULibSync.syncULibPlayerUnban(steamid)
    ULibSync.log('Attemping to sync player unban.', steamid, 10)
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

local function syncULibSyncPlayerBanDataLocally(steamid, uLibSyncPlayerBanData)
    local unbanAt = tonumber(uLibSyncPlayerBanData.unban) or 0
    local uLibSyncTimeRemaining = (unbanAt > 0) and (unbanAt - os.time()) / 60 or 0
    local uLibBan = ULib.bans[steamid]
    if uLibSyncPlayerBanData['manual_unban'] == 1 then
        if uLibBan then
            ULib.unban(steamid)
            ULibSync.log('Unban has been synced locally.', steamid, 20)
        end
    elseif uLibSyncTimeRemaining > 0 or unbanAt == 0 then
        if not uLibBan or uLibBan.reason ~= uLibSyncPlayerBanData.reason or (tonumber(uLibBan.unban) or 0) ~= unbanAt then
            ULib.addBan(steamid, uLibSyncTimeRemaining, uLibSyncPlayerBanData.reason, uLibSyncPlayerBanData.username)
            ULibSync.log('Ban has been synced locally.', steamid, 20)
        end
    end
end

function ULibSync.syncULibSyncBanData()
    ULibSync.log('Attemping to sync locally.', 'bans', 10)
    local q = ULibSync.mysql:query('SELECT steamid, reason, unban, manual_unban, username FROM ulib_bans')
    function q:onSuccess(data)
        removeULibSyncPlayerBanHooks()
        for index = 1, #data do
            local uLibSyncPlayerBanData = data[index]
            syncULibSyncPlayerBanDataLocally(uLibSyncPlayerBanData.steamid, uLibSyncPlayerBanData)
        end
        addULibSyncPlayerBanHooks()
    end
    function q:onError(err)
        ULibSync.log('Local syncing failed.', 'bans', 40, err)
    end
    q:start()
end

function ULibSync.syncULibSyncPlayerBanData(steamID64)
    local steamid = util.SteamIDFrom64(steamID64)
    ULibSync.log('Attemping to sync ban data locally.', steamid, 10)
    local q = ULibSync.mysql:prepare('SELECT reason, unban, manual_unban, username FROM ulib_bans WHERE steamid = ?')
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
        ULibSync.log('Ban has not been synced locally.', steamid, 40, err)
    end
    q:start()
end
