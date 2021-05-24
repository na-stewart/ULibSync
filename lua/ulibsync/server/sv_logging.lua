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

function ULibSync.log(data, id, level, err)
    logLevel = parse_log_level(level)
    if level < 30 then
        formatted_log_msg = string.format('[ULibSync] (%s) %s: %s', id, logLevel, data)
    else
        formatted_log_msg = string.format('[ULibSync] (%s) %s: %s %s', id, logLevel, data, err)
    end
    print(formatted_log_msg)
end