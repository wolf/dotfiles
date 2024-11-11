vim.cmd('source ~/.config/vim/vimrc')

if vim.fn.has('nvim') == 1 then
    local status, hop = pcall(require, 'hop')
    if status then
        hop.setup {}
    else
        print("hop.nvim is not available")
    end
end
