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
    local unformatted  = (level > 20) and '[ULibSync] (%s) %s: %s %s\n' or '[ULibSync] (%s) %s: %s\n'
    ServerLog(string.format(unformatted, id,  parse_log_level(level), msg, err))
end
