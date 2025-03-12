local M = {}

function M.setup(config)
    config = config or {}
    for key, value in pairs(config) do
        local plugin = require('myplugins.' .. key)
        if plugin and plugin.setup then
            plugin.setup(value)
        else
            vim.notify(
                'Plugin ' .. key .. ' not found or does not have a setup function',
                vim.log.levels.WARN
            )
        end
    end
end

return M
