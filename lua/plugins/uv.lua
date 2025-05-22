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

    -- run_uv_pytest is the function all mappings will call eventually to run pytest
    local function run_uv_pytest(cmd_suffix)
      if not uv_ok then
        print 'Error: uv.nvim plugin not found or failed to load.'
        return
      end
      local command = 'uv run pytest -s'
      if cmd_suffix then
        command = command .. ' ' .. cmd_suffix
      end
      uv.run_command(command)
    end

    -- Run pytest on all files in /tests directory.
    map('n', '<leader>xta', function()
      run_uv_pytest()
    end, {
      noremap = true,
      desc = 'UV pytest (all)',
    })

    -- Run pytest on currently selected buffer.
    map('n', '<leader>xtc', function()
      local current_file_path = vim.fn.expand '%:p' -- Get full path of the current buffer
      if current_file_path == '' then
        print 'Error: No file open in the current buffer.'
        return
      end

      -- Check if the file is actually a test file
      if not string.match(current_file_path, 'tests/') then
        print('Error: Current file ' .. current_file_path .. ' is not in a tests directory.')
        return
      end

      run_uv_pytest(current_file_path)
    end, {
      noremap = true,
      desc = 'UV pytest (current file)',
    })

    -- Run pytest on a selected file
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
        prompt_title = 'Select Test File',
        cwd = 'tests/',
        layout_strategy = 'horizontal',
        layout_config = {
          width = 0.5, -- 50% of editor width
          height = 0.4, -- 40% of editor height
          prompt_position = 'top',
          preview_cutoff = 120, -- If preview width is less than this, it will be hidden
          preview_width = 0.6, -- Percentage of the Telescope window for the preview
        },
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
