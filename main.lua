local config = {
    api_url = 'https://redm.munafio.com/api/check-version',
    github_base_url = 'https://github.com/blnStudio',
}

local function CheckVersion()
    local currentVersion = GetResourceMetadata(RESOURCE_NAME, 'version')
    
    if not currentVersion then
        print('^1[VERSION CHECKER]^0 No version specified in fxmanifest.lua for ' .. RESOURCE_NAME)
        return
    end

    local payload = json.encode({
        script_name = RESOURCE_NAME,
        current_version = currentVersion
    })

    PerformHttpRequest(config.api_url, function(statusCode, responseText, headers)
        if statusCode ~= 200 then
            print(string.format(
                '^1[VERSION CHECKER]^0 Failed to check version for %s. Status: %s',
                RESOURCE_NAME,
                statusCode
            ))
            return
        end

        local response = json.decode(responseText)
        
        if response.needs_update then
            print(string.format(
                '^3[VERSION CHECKER]^0 Update available for %s: %s -> %s',
                RESOURCE_NAME,
                currentVersion,
                response.latest_version
            ))
            print('^3[VERSION CHECKER]^0 Please update from: ' .. config.github_base_url .. '/' .. RESOURCE_NAME)
        else
            print(string.format(
                '^2[VERSION CHECKER]^0 %s is up to date (v%s)',
                RESOURCE_NAME,
                currentVersion
            ))
        end
    end, 'POST', payload, { ['Content-Type'] = 'application/json' })
end


CheckVersion()