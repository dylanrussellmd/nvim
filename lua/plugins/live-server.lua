return {
  -- Live reload local development server inside neovim
  'barrett-ruth/live-server.nvim',
  build = 'npm install -g live-server',
  cmd = { 'LiveServerStart', 'LiveServerStop' },
  config = true,
}
