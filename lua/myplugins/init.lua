local M = {}

function M.setup(config)
    config = config or {}
    for key, value in pairs(config) do
        local ok, plugin = pcall(require, 'myplugins.' .. key)
        if ok and plugin and type(plugin.setup) == 'function' then
            local setup_ok, err = pcall(plugin.setup, value)
            if not setup_ok then
                vim.notify('Error setting up plugin ' .. key .. ': ' .. tostring(err), vim.log.levels.ERROR)
            end
        else
            vim.notify('Plugin ' .. key .. ' not found or does not have a setup function', vim.log.levels.WARN)
            vim.notify('Error: ' .. tostring(plugin), vim.log.levels.WARN)
        end
    end
end

return M
