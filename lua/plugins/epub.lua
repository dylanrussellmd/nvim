return {
  'CrystalDime/epub.nvim',
  opts = {
    auto_open = false, -- Enable automatic opening of EPUBs
    output_dir = vim.fn.stdpath 'cache' .. '/epub_reader', -- Default output directory (where epubs are unziped)
    data_dir = vim.fn.stdpath 'data' .. '/epub_reader', -- Persistent data directory
  },
  config = true,
}
