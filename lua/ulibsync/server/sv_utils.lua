if not pcall(require, 'mysqloo') then
    ErrorNoHalt('[ULibSync] MySQLOO is not installed, ULibSync will not run.\n')
    return
end

local LOG_LEVELS = {
    [10] = 'DEBUG',
    [20] = 'INFO',
    [30] = 'WARNING',
    [40] = 'ERROR',
    [50] = 'CRITICAL'
}

function ULibSync.log(msg, id, level, err)
    if not ULibSync.logs then return end
    if level == 10 and not ULibSync.debug then return end
    local levelStr = LOG_LEVELS[level] or 'NONE'
    if level > 20 then
        ServerLog(string.format('[ULibSync] (%s) %s: %s %s.\n', id, levelStr, msg, err or ''))
    else
        ServerLog(string.format('[ULibSync] (%s) %s: %s\n', id, levelStr, msg))
    end
end

function ULibSync.escape(value)
    if value == nil then return 'NULL' end
    return '\'' .. ULibSync.mysql:escape(tostring(value)) .. '\''
end

local BATCH_SIZE = 500
function ULibSync.batchReplace(tableName, columns, rows, id, label)
    local total = #rows
    if total == 0 then return end
    local prefix = string.format('REPLACE INTO `%s` (%s) VALUES ', tableName, columns)
    for i = 1, total, BATCH_SIZE do
        local q = ULibSync.mysql:query(prefix .. table.concat(rows, ',', i, math.min(i + BATCH_SIZE - 1, total)))
        function q:onSuccess(data)
            ULibSync.log(label .. ' have been synced successfully.', id, 20)
        end
        function q:onError(err)
            ULibSync.log(label .. ' have not been synced.', id, 40, err)
        end
        q:start()
    end
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
    ULibSync.mysql:setAutoReconnect(true)
    ULibSync.mysql:connect()
end

initMySQLOO()
