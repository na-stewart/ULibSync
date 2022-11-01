require( 'mysqloo' )

local function parse_log_level(level)
    local levelStr = nil
    if level == 10 then
        levelStr = 'DEBUG'
    elseif level == 20 then
        levelStr = 'INFO'
    elseif level == 30 then
        levelStr = 'WARNING'
    elseif level == 40 then
        levelStr = 'ERROR'
    elseif level == 50 then
        levelStr = 'CRITICAL'
    else
        levelStr = 'NONE'
    end
    return levelStr
end

function ULibSync.log(msg, id, level, err)
    if not ULibSync.logs or level == 10 and not ULibSync.debug then return end
    local unformatted  = (level > 20) and '[ULibSync] (%s) %s: %s %s.\n' or '[ULibSync] (%s) %s: %s\n'
    ServerLog(string.format(unformatted, id,  parse_log_level(level), msg, err))
end

local function initMySQLOO()
    ULibSync.mysql = mysqloo.connect(ULibSync.ip, ULibSync.username, ULibSync.password, ULibSync.database, ULibSync.port)
    function ULibSync.mysql:onConnected()
        ULibSync.initBanSync()
        ULibSync.initUsersSync()
        ULibSync.initGroupsSync()
        ULibSync.log('Connection to database succeeded, please check workshop for updates.', ULibSync.ip, 20)
    end
    function ULibSync.mysql:onConnectionFailed(err)
        ULibSync.log('Connection to database failed.', ULibSync.ip, 50, err)
    end
    ULibSync.mysql:connect()
end

initMySQLOO()
