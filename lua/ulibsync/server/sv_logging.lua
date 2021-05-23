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

function ULibSync.log(data, level)
    local formatted_log_msg = string.format('[ULibSync] %s: %s', parse_log_level(level), data)
    print(formatted_log_msg)
end