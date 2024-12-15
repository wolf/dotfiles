vim.cmd('source ~/.config/vim/vimrc')

if vim.fn.has('nvim') == 1 then
    local status, hop = pcall(require, 'hop')
    if status then
        hop.setup {}
    else
        print("hop.nvim is not available")
    end

    require'lspconfig'.pyright.setup{}
    require'lspconfig'.rust_analyzer.setup{
        settings = {
            ["rust-analyzer"] = {
                checkOnSave = "clippy"
            }
        }
    }
    require'nvim-treesitter.configs'.setup {
      ensure_installed = { "python", "rust" }, -- Ensure Python parser is installed
      highlight = {
        enable = true,                -- Enable Treesitter highlighting
      },
    }
end
