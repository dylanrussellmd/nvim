return {
  -- Python `uv` integration with Neovim
  'benomahony/uv.nvim',
  dependencies = 'nvim-telescope/telescope.nvim',
  ftplugin = 'python', -- `uv` is associated with Python files
  config = function()
    require('uv').setup()
    local map = vim.keymap.set

    local uv_ok, uv = pcall(require, 'uv')
    local ts_ok, ts = pcall(require, 'telescope.builtin')
    local actions_ok, actions = pcall(require, 'telescope.actions')
    local actions_state_ok, actions_state = pcall(require, 'telescope.actions.state')

    local function run_uv_pytest(cmd_suffix)
      if not uv_ok then
        print 'Error: uv.nvim plugin not found or failed to load.'
        return
      end
      local command = 'uv run pytest'
      if cmd_suffix then
        command = command .. ' ' .. cmd_suffix
      end
      uv.run_command(command)
    end

    map('n', '<leader>xt', function()
      run_uv_pytest()
      uv.run_command 'uv run pytest'
    end, {
      noremap = true,
      desc = 'UV pytest (all)',
    })

    map('n', '<leader>xtf', function()
      if not ts_ok then
        print 'Error: Telescope plugin not found or failed to load.'
        return
      end
      if not actions_ok then
        print 'Error: Telescope actions module not found or failed to load.'
      end
      if not actions_state_ok then
        print 'Error: Telescope actions.state module not found or failed to load.'
      end

      ts.find_files {
        prompt_title = 'Select Test File to Run',
        cwd = 'tests/',
        attach_mappings = function(prompt_bufnr, map_opts)
          actions.select_default:replace(function(current_prompt_bufnr)
            local entry = actions_state.get_selected_entry()
            actions.close(current_prompt_bufnr)
            local file_path = 'tests/' .. entry.value
            run_uv_pytest(file_path)
          end)
          return true
        end,
      }
    end, {
      noremap = true,
      desc = 'UV pytest (selected file)',
    })
  end,
}
