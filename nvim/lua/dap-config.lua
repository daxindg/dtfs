local dap = require("dap")
require("dapui").setup()

dap.set_log_level("TRACE")

dap.adapters.go = function(callback, _)
   local stdout = vim.loop.new_pipe(false)
   local handle
   local pid_or_err
   local port = 38697
   local opts = {
     stdio = {nil, stdout},
     args = {"dap", "-l", "127.0.0.1:" .. port},
     detached = true
   }
   handle, pid_or_err = vim.loop.spawn("dlv", opts, function(code)
     stdout:close()
     handle:close()
     if code ~= 0 then
       print('dlv exited with code', code)
     end
   end)
   assert(handle, 'Error running dlv: ' .. tostring(pid_or_err))
   stdout:read_start(function(err, chunk)
     assert(not err, err)
     if chunk then
       vim.schedule(function()
         require('dap.repl').append(chunk)
       end)
     end
   end)
   -- Wait for delve to start
   vim.defer_fn(
     function()
       callback({type = "server", host = "127.0.0.1", port = port})
     end,
     100)
 end

dap.adapters.codelldb = {
  type = "server",
  port = "${port}",
  executable = {
    command = "/usr/bin/codelldb",
    args = {"--port", "${port}"},
  },
  terminal = 'integrated',
  sourceLanguages = { 'rust' },
  stopOnEntry = true
}

dap.configurations.rust = {
  {
    name = "Rust: Launch",
    type = "codelldb",
    request = "launch",
    program = function()
      vim.fn.jobstart('cargo build') 
      return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/target/debug/', 'file')
    end,
    cwd = '${workspaceFolder}',
    stopOnEntry = true,
    showDisassembly = false,
  }
}

 -- https://github.com/go-delve/delve/blob/master/Documentation/usage/dlv_dap.md
 dap.configurations.go = {
  {
    type = "go",
    name = "Debug",
    request = "launch",
    program = "${workspaceFolder}"
  },
  {
    type = "go",
    name = "Attach",
    mode = "local",
    request = "attach",
    processId = require('dap.utils').pick_process,
  },
  {
    type = "go",
    name = "Debug test", -- configuration for debugging test files
    request = "launch",
    mode = "test",
    program = "${file}"
  },
  -- works with go.mod packages and sub packages
  {
    type = "go",
    name = "Debug test (go.mod)",
    request = "launch",
    mode = "test",
    program = "./${relativeFileDirname}"
  }
}

vim.cmd([[
nnoremap <silent> <F5> :lua require'dap'.continue()<CR>
nnoremap <silent> <F10> :lua require'dap'.step_over()<CR>
nnoremap <silent> <F11> :lua require'dap'.step_into()<CR>
nnoremap <silent> <F12> :lua require'dap'.step_out()<CR>
nnoremap <silent> <leader>db :lua require'dap'.toggle_breakpoint()<CR>
nnoremap <silent> <leader>dB :lua require'dap'.set_breakpoint(vim.fn.input('Breakpoint condition: '))<CR>
nnoremap <silent> <leader>lp :lua require'dap'.set_breakpoint(nil, nil, vim.fn.input('Log point message: '))<CR>
nnoremap <silent> <leader>dr :lua require'dap'.repl.open()<CR>
nnoremap <silent> <leader>dl :lua require'dap'.run_last()<CR>
nnoremap <silent> <leader>du :lua require("dapui").toggle()<CR>
]])

