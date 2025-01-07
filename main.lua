local config = {
    api_url = 'https://redm.munafio.com/api/check-version',
    github_base_url = 'https://github.com/blnStudio',
}

local function CheckVersion()
    local currentVersion = GetResourceMetadata(RESOURCE_NAME, 'version')
    
    if not currentVersion then
        print('^3[' .. RESOURCE_NAME .. '] ^1❌ ^0No version specified in fxmanifest.lua')
        return
    end

    local payload = json.encode({
        script_name = RESOURCE_NAME,
        current_version = currentVersion
    })

    PerformHttpRequest(config.api_url, function(statusCode, responseText, headers)
        if statusCode ~= 200 then
            print('^3[' .. RESOURCE_NAME .. '] ^1❌ ^0Failed to check version. Status: ' .. statusCode)
            return
        end

        local response = json.decode(responseText)
        local githubRepoLink = config.github_base_url .. '/' .. RESOURCE_NAME
        
        if response.needs_update then
            print(
                '^3[' .. 
                RESOURCE_NAME .. 
                '] ^1❌ ' ..
                'Outdated (v' ..
                currentVersion .. 
                ') ^5- Update found: v' .. 
                response.latest_version .. 
                ' ^0(' .. 
                githubRepoLink .. 
                ')'
            )
        else
            print(
                '^3[' .. 
                RESOURCE_NAME .. 
                '] ^2✓ ' ..
                'Up to date (v' .. 
                currentVersion .. 
                ')'
            )
        end
    end, 'POST', payload, { ['Content-Type'] = 'application/json' })
end

CheckVersion()