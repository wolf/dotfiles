vim.cmd('source ~/.config/vim/vimrc')

if vim.fn.has('nvim') == 1 then
    vim.g.mapleader = " "

    local status, hop = pcall(require, 'hop')
    if status then
        hop.setup {}

        local HintDirection = require('hop.hint').HintDirection

        -- Generalized function for line hopping
        local function hop_line(direction)
            hop.hint_lines({
                direction = direction,
            })
        end

        -- Hop only to lines below the cursor
        _G.hop_line_down = function()
            hop_line(HintDirection.AFTER_CURSOR)
        end

        -- Hop only to lines above the cursor
        _G.hop_line_up = function()
            hop_line(HintDirection.BEFORE_CURSOR)
        end

        -- Hop only to the same column and below the cursor
        _G.hop_vertical_down = function()
            hop.hint_vertical({
                direction = HintDirection.AFTER_CURSOR,
            })
        end

        -- Hop only to the same column and above the cursor
        _G.hop_vertical_up = function()
            hop.hint_vertical({
                direction = HintDirection.BEFORE_CURSOR,
            })
        end

        -- Forward motion: land one character before the target
        _G.hop_char1_before = function()
            hop.hint_char1({
                direction = HintDirection.AFTER_CURSOR,
                callback = function()
                    vim.cmd('normal! h') -- Move one character left
                end,
            })
        end

        -- Backward motion: land one character before the target
        _G.hop_char1_before_backward = function()
            hop.hint_char1({
                direction = HintDirection.BEFORE_CURSOR,
                callback = function()
                    vim.cmd('normal! l') -- Move one character right
                end,
            })
        end

        -- Key-bindings for Hop that come as close as reasonable to EasyMotion

        -- Normal mode
        vim.api.nvim_set_keymap('n', '<leader><leader>w', "<cmd>HopWordAC<CR>", { noremap = true, silent = true })
        vim.api.nvim_set_keymap('n', '<leader><leader>l', "<cmd>HopLineAC<CR>", { noremap = true, silent = true })
        vim.api.nvim_set_keymap('n', '<leader><leader>f', "<cmd>HopChar1AC<CR>", { noremap = true, silent = true })
        vim.api.nvim_set_keymap('n', '<leader><leader>s', "<cmd>HopChar2AC<CR>", { noremap = true, silent = true })
        vim.api.nvim_set_keymap('n', '<leader><leader>j', "<cmd>lua hop_line_down()<CR>", { noremap = true, silent = true })
        vim.api.nvim_set_keymap('n', '<leader><leader>k', "<cmd>lua hop_line_up()<CR>", { noremap = true, silent = true })
        vim.api.nvim_set_keymap('n', '<leader><leader>J', "<cmd>lua hop_vertical_down()<CR>", { noremap = true, silent = true })
        vim.api.nvim_set_keymap('n', '<leader><leader>K', "<cmd>lua hop_vertical_up()<CR>", { noremap = true, silent = true })
        vim.api.nvim_set_keymap('n', '<leader><leader>t', "<cmd>lua hop_char1_before()<CR>", { noremap = true, silent = true })
        vim.api.nvim_set_keymap('n', '<leader><leader>T', "<cmd>lua hop_char1_before_backward()<CR>", { noremap = true, silent = true })
        
        -- Operator-pending mode
        vim.api.nvim_set_keymap('o', '<leader><leader>w', "<cmd>HopWordAC<CR>", { noremap = true, silent = true })
        vim.api.nvim_set_keymap('o', '<leader><leader>l', "<cmd>HopLineAC<CR>", { noremap = true, silent = true })
        vim.api.nvim_set_keymap('o', '<leader><leader>f', "<cmd>HopChar1AC<CR>", { noremap = true, silent = true })
        vim.api.nvim_set_keymap('o', '<leader><leader>s', "<cmd>HopChar2AC<CR>", { noremap = true, silent = true })
        vim.api.nvim_set_keymap('o', '<leader><leader>j', "<cmd>lua hop_line_down()<CR>", { noremap = true, silent = true })
        vim.api.nvim_set_keymap('o', '<leader><leader>k', "<cmd>lua hop_line_up()<CR>", { noremap = true, silent = true })
        vim.api.nvim_set_keymap('o', '<leader><leader>J', "<cmd>lua hop_vertical_down()<CR>", { noremap = true, silent = true })
        vim.api.nvim_set_keymap('o', '<leader><leader>K', "<cmd>lua hop_vertical_up()<CR>", { noremap = true, silent = true })
        vim.api.nvim_set_keymap('o', '<leader><leader>t', "<cmd>lua hop_char1_before()<CR>", { noremap = true, silent = true })
        vim.api.nvim_set_keymap('o', '<leader><leader>T', "<cmd>lua hop_char1_before_backward()<CR>", { noremap = true, silent = true })

        -- Visual mode
        vim.api.nvim_set_keymap('x', '<leader><leader>w', "<cmd>HopWordAC<CR>", { noremap = true, silent = true })
        vim.api.nvim_set_keymap('x', '<leader><leader>l', "<cmd>HopLineAC<CR>", { noremap = true, silent = true })
        vim.api.nvim_set_keymap('x', '<leader><leader>f', "<cmd>HopChar1AC<CR>", { noremap = true, silent = true })
        vim.api.nvim_set_keymap('x', '<leader><leader>s', "<cmd>HopChar2AC<CR>", { noremap = true, silent = true })
        vim.api.nvim_set_keymap('x', '<leader><leader>j', "<cmd>lua hop_line_down()<CR>", { noremap = true, silent = true })
        vim.api.nvim_set_keymap('x', '<leader><leader>k', "<cmd>lua hop_line_up()<CR>", { noremap = true, silent = true })
        vim.api.nvim_set_keymap('x', '<leader><leader>J', "<cmd>lua hop_vertical_down()<CR>", { noremap = true, silent = true })
        vim.api.nvim_set_keymap('x', '<leader><leader>K', "<cmd>lua hop_vertical_up()<CR>", { noremap = true, silent = true })
        vim.api.nvim_set_keymap('x', '<leader><leader>t', "<cmd>lua hop_char1_before()<CR>", { noremap = true, silent = true })
        vim.api.nvim_set_keymap('x', '<leader><leader>T', "<cmd>lua hop_char1_before_backward()<CR>", { noremap = true, silent = true })
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
