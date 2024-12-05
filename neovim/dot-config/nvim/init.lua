vim.cmd('source ~/.config/vim/vimrc')

if vim.fn.has('nvim') == 1 then
    local status, hop = pcall(require, 'hop')
    if status then
        hop.setup {}
    else
        print("hop.nvim is not available")
    end

    require'lspconfig'.pyright.setup{}
    require'nvim-treesitter.configs'.setup {
      ensure_installed = { "python" }, -- Ensure Python parser is installed
      highlight = {
        enable = true,                -- Enable Treesitter highlighting
      },
    }
end
