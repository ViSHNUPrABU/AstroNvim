return {
  "rebelot/heirline.nvim",
  event = "BufEnter",
  opts = function()
    local status = require "astronvim.utils.status"
    return {
      opts = {
        disable_winbar_cb = function(args)
          return not require("astronvim.utils.buffer").is_valid(args.buf)
            or status.condition.buffer_matches({
              buftype = { "terminal", "prompt", "nofile", "help", "quickfix" },
              filetype = { "NvimTree", "neo%-tree", "dashboard", "Outline", "aerial" },
            }, args.buf)
        end,
      },
      statusline = {
        -- default highlight for the entire statusline
        hl = { fg = "fg", bg = "bg" },
        -- each element following is a component in astronvim.utils.status module
        -- NvChad Statusline Styles
        status.component.mode {
          mode_text = { icon = { kind = "VimIcon", padding = { right = 1, left = 1 } } },
          padding = { right = 1 },
          surround = {
            separator = "nvchad_left",
            color = function() return { main = status.hl.mode_bg() } end,
          },
        },
        status.component.file_info {
          file_icon = { padding = { left = 0 } },
          filename = false,
          filetype = {},
          padding = { right = 1 },
          surround = { separator = "nvchad_left", condition = false },
        },
        status.component.git_branch { surround = { separator = "none" } },
        status.component.git_diff { padding = { left = 1 }, surround = { separator = "none" } },
        status.component.fill(),
        status.component.lsp { lsp_client_names = false, surround = { separator = "none", color = "bg" } },
        status.component.fill(),
        status.component.cmd_info(),
        status.component.diagnostics { surround = { separator = "nvchad_right" } },
        status.component.lsp { lsp_progress = false, surround = { separator = "nvchad_right" } },
        {
          status.component.builder {
            { provider = require("astronvim.utils").get_icon "FolderClosed" },
            padding = { right = 1 },
            hl = { fg = "bg" },
            surround = { separator = "nvchad_right", color = "buffer_picker_fg" },
          },
          status.component.file_info {
            filename = { fname = function(nr) return vim.fn.getcwd(nr) end, padding = { left = 1 } },
            file_icon = false,
            file_modified = false,
            file_read_only = false,
            surround = { separator = "none", condition = false },
          },
        },
        {
          status.component.builder {
            { provider = require("astronvim.utils").get_icon "ScrollText" },
            padding = { right = 1 },
            hl = { fg = "bg" },
            surround = { separator = "nvchad_right", color = { main = "treesitter_fg" } },
          },
          status.component.nav {
            percentage = { padding = { left = 1, right = 1 }, },
            ruler = { padding = { left = 1 }, },
            scrollbar = false,
            surround = { separator = "none" },
          },
        },
      },
      -- AstroNvim Statusline Styles
      -- statusline = { -- statusline
      --   hl = { fg = "fg", bg = "bg" },
      --   -- status.component.mode(),
      --   status.component.mode({
      --     mode_text = {
      --       padding = {
      --         left = 1, right = 1,
      --       },
      --     },
      --     surround = {
      --       separator = "left",
      --       color = function() return { main = status.hl.mode_bg(), } end,
      --     },
      --   }),
      --   status.component.git_branch(),
      --   status.component.file_info { filetype = {}, filename = false, file_modified = false },
      --   status.component.git_diff(),
      --   status.component.diagnostics(),
      --   status.component.fill(),
      --   status.component.cmd_info(),
      --   status.component.fill(),
      --   status.component.lsp(),
      --   status.component.treesitter(),
      --   status.component.nav(),
      --   -- status.component.mode { surround = { separator = "right" } },
      -- },
      winbar = { -- winbar
        init = function(self) self.bufnr = vim.api.nvim_get_current_buf() end,
        fallthrough = false,
        {
          condition = function() return not status.condition.is_active() end,
          status.component.separated_path(),
          status.component.file_info {
            file_icon = { hl = status.hl.file_icon "winbar", padding = { left = 0 } },
            file_modified = false,
            file_read_only = false,
            hl = status.hl.get_attributes("winbarnc", true),
            surround = false,
            update = "BufEnter",
          },
        },
        status.component.breadcrumbs { hl = status.hl.get_attributes("winbar", true) },
      },
      tabline = { -- bufferline
        { -- file tree padding
          condition = function(self)
            self.winid = vim.api.nvim_tabpage_list_wins(0)[1]
            return status.condition.buffer_matches({
              filetype = {
                "NvimTree",
                "OverseerList",
                "aerial",
                "dap%-repl",
                "dapui_.",
                "edgy",
                "neo%-tree",
                "undotree",
              },
            }, vim.api.nvim_win_get_buf(self.winid))
          end,
          provider = function(self) return string.rep(" ", vim.api.nvim_win_get_width(self.winid) + 1) end,
          hl = { bg = "tabline_bg" },
        },
        status.heirline.make_buflist(status.component.tabline_file_info()), -- component for each buffer tab
        status.component.fill { hl = { bg = "tabline_bg" } }, -- fill the rest of the tabline with background color
        { -- tab list
          condition = function() return #vim.api.nvim_list_tabpages() >= 2 end, -- only show tabs if there are more than one
          status.heirline.make_tablist { -- component for each tab
            provider = status.provider.tabnr(),
            hl = function(self) return status.hl.get_attributes(status.heirline.tab_type(self, "tab"), true) end,
          },
          { -- close button for current tab
            provider = status.provider.close_button { kind = "TabClose", padding = { left = 1, right = 1 } },
            hl = status.hl.get_attributes("tab_close", true),
            on_click = {
              callback = function() require("astronvim.utils.buffer").close_tab() end,
              name = "heirline_tabline_close_tab_callback",
            },
          },
        },
      },
      statuscolumn = vim.fn.has "nvim-0.9" == 1 and {
        init = function(self) self.bufnr = vim.api.nvim_get_current_buf() end,
        status.component.foldcolumn(),
        status.component.fill(),
        status.component.numbercolumn(),
        status.component.signcolumn(),
      } or nil,
    }
  end,
  config = require "plugins.configs.heirline",
}
