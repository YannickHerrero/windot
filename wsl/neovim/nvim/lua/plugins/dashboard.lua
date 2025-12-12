return {
  'nvimdev/dashboard-nvim',
  event = 'VimEnter',
  config = function()
    require('dashboard').setup {
      theme = 'doom',
      config = {
        header = {
          '',
          '',
          '',
          '',
          '',
          '',
          'Welcome back Yannick',
          '',
          '',
          '',
        },
        center = {},
        footer = function()
          local stats = require('lazy').stats()
          local version = vim.version()
          return {
            '',
            '',
            '',
            '',
            '',
            'Neovim v' .. version.major .. '.' .. version.minor .. '.' .. version.patch .. ' | ' .. stats.loaded .. ' plugins',
          }
        end,
      },
    }
  end,
  dependencies = {},
}
