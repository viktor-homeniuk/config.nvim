-- DAP plugin to debug code.
return {
  { "nvim-neotest/nvim-nio" },

  {
    'mfussenegger/nvim-dap',
    dependencies = {
      -- Installs the debug adapters
      'williamboman/mason.nvim',
      'jay-babu/mason-nvim-dap.nvim',

      -- Creates a beautiful debugger UI
      { 'rcarriga/nvim-dap-ui', dependencies = { "mfussenegger/nvim-dap" }, },

      -- Golang
      'leoluz/nvim-dap-go',

      -- JS/TS/Node/React
      {
        "microsoft/vscode-js-debug",
        -- After install, build it and rename the dist directory to out
        build = "npm install --legacy-peer-deps --no-save && npx gulp vsDebugServerBundle && rm -rf out && mv dist out",
        version = "1.*",
      },
      {
        "mxsdev/nvim-dap-vscode-js",
        config = function()
          ---@diagnostic disable-next-line: missing-fields
          require("dap-vscode-js").setup({
            -- Path of node executable. Defaults to $NODE_PATH, and then "node"
            -- node_path = "node",

            -- Path to vscode-js-debug installation.
            debugger_path = vim.fn.resolve(vim.fn.stdpath("data") .. "/lazy/vscode-js-debug"),

            -- Command to use to launch the debug server. Takes precedence over "node_path" and "debugger_path"
            -- debugger_cmd = { "js-debug-adapter" },

            -- which adapters to register in nvim-dap
            adapters = {
              "chrome",
              "pwa-node",
              "pwa-chrome",
              "pwa-msedge",
              "pwa-extensionHost",
              "node-terminal",
            },

            -- Path for file logging
            -- log_file_path = "(stdpath cache)/dap_vscode_js.log",

            -- Logging level for output to file. Set to false to disable logging.
            -- log_file_level = false,

            -- Logging level for output to console. Set to false to disable console output.
            -- log_console_level = vim.log.levels.ERROR,
          })
        end,
      },
    },
    config = function()
      local dap = require 'dap'

      -- require('mason-nvim-dap').setup {
      --   -- Makes a best effort to setup the various debuggers with
      --   -- reasonable debug configurations
      --   automatic_setup = true,
      --
      --   -- You can provide additional configuration to the handlers,
      --   -- see mason-nvim-dap README for more information
      --   handlers = {},
      --
      --   -- You'll need to check that you have the required things installed
      --   -- online, please don't ask me how to install them :)
      --   ensure_installed = {
      --     -- Update this to ensure that you have the debuggers for the langs you want
      --     'delve',
      --   },
      -- }
      --
      --

      -- local Config = require("lazyvim.config")
      -- vim.api.nvim_set_hl(0, "DapStoppedLine", { default = true, link = "Visual" })
      --
      -- for name, sign in pairs(Config.icons.dap) do
      --   sign = type(sign) == "table" and sign or { sign }
      --   vim.fn.sign_define(
      --     "Dap" .. name,
      --     { text = sign[1], texthl = sign[2] or "DiagnosticInfo", linehl = sign[3], numhl = sign[3] }
      --   )
      -- end

      local js_based_languages = {
        "typescript",
        "javascript",
        "typescriptreact",
        "javascriptreact",
      }
      for _, language in ipairs(js_based_languages) do
        dap.configurations[language] = {
          -- Debug single nodejs files
          {
            type = "pwa-node",
            request = "launch",
            name = "Launch file",
            program = "${file}",
            cwd = vim.fn.getcwd(),
            sourceMaps = true,
          },
          -- Debug nodejs processes (make sure to add --inspect when you run the process)
          {
            type = "pwa-node",
            request = "attach",
            name = "Attach",
            processId = require("dap.utils").pick_process,
            cwd = vim.fn.getcwd(),
            sourceMaps = true,
          },
          -- Debug web applications (client side)
          {
            type = "pwa-chrome",
            request = "launch",
            name = "Launch & Debug Chrome",
            url = function()
              local co = coroutine.running()
              return coroutine.create(function()
                vim.ui.input({
                  prompt = "Enter URL: ",
                  default = "http://localhost:3000",
                }, function(url)
                  if url == nil or url == "" then
                    return
                  else
                    coroutine.resume(co, url)
                  end
                end)
              end)
            end,
            webRoot = vim.fn.getcwd(),
            protocol = "inspector",
            sourceMaps = true,
            userDataDir = false,
          },
        }
      end

      -- Basic debugging keymaps, feel free to change to your liking!
      -- vim.keymap.set('n', '<leader>db', dap.continue, { desc = 'Debug: Start/Continue' })
      -- vim.keymap.set('n', '<C-i>', dap.step_into, { desc = 'Debug: Step Into' })
      -- vim.keymap.set('n', '<C-O>', dap.step_over, { desc = 'Debug: Step Over' })
      -- vim.keymap.set('n', '<C-o>', dap.step_out, { desc = 'Debug: Step Out' })
      -- vim.keymap.set('n', '<leader>b', dap.toggle_breakpoint, { desc = 'Debug: Toggle Breakpoint' })
      -- vim.keymap.set('n', '<leader>B', function()
      --   dap.set_breakpoint(vim.fn.input 'Breakpoint condition: ')
      --   vim.keymap.set('n', '<C-st>', dap.stop, { desc = 'Stop debugging' })
      --   vim.keymap.set('n', '<C-q>', dap.close, { desc = 'Quit debugging' })
      -- end, { desc = 'Debug: Set Breakpoint' })

      -- Dap UI setup
      local dapui = require 'dapui'
      dapui.setup({
        controls = {
          element = "repl",
          enabled = true,
          icons = {
            disconnect = "",
            pause = "",
            play = "",
            run_last = "",
            step_back = "",
            step_into = "",
            step_out = "",
            step_over = "",
            terminate = ""
          }
        },
        element_mappings = {},
        expand_lines = true,
        floating = {
          border = "single",
          mappings = {
            close = { "q", "<Esc>" }
          }
        },
        force_buffers = true,
        icons = {
          collapsed = "",
          current_frame = "*",
          expanded = ""
        },
        layouts = { {
          elements = { {
            id = "scopes",
            size = 0.25
          }, {
            id = "breakpoints",
            size = 0.25
          }, {
            id = "stacks",
            size = 0.25
          }, {
            id = "watches",
            size = 0.25
          } },
          position = "left",
          size = 40
        }, {
          elements = { {
            id = "repl",
            size = 0.5
          }, {
            id = "console",
            size = 0.5
          } },
          position = "bottom",
          size = 10
        } },
        mappings = {
          edit = "e",
          expand = { "<CR>", "<2-LeftMouse>" },
          open = "o",
          remove = "d",
          repl = "r",
          toggle = "t"
        },
        render = {
          indent = 1,
          max_value_lines = 100
        }
      })

      -- Toggle to see last session result. Without this, you can't see session output in case of unhandled exception.
      vim.keymap.set('n', '<F7>', dapui.toggle, { desc = 'Debug: See last session result.' })

      dap.listeners.after.event_initialized['dapui_config'] = dapui.open
      dap.listeners.before.event_terminated['dapui_config'] = dapui.close
      dap.listeners.before.event_exited['dapui_config'] = dapui.close

      -- Install golang specific config
      require('dap-go').setup()
    end,
  },

  -- {
  --   "mfussenegger/nvim-dap",
  --   dependencies = {
  --     "rcarriga/nvim-dap-ui",
  --     "mxsdev/nvim-dap-vscode-js",
  --     -- build debugger from source
  --     {
  --       "microsoft/vscode-js-debug",
  --       version = "1.x",
  --       build = "npm i && npm run compile vsDebugServerBundle && mv dist out"
  --     }
  --   },
  --   keys = {
  --     -- normal mode is default
  --     { "<leader>b",  function() require 'dap'.toggle_breakpoint() end },
  --     { "<leader>db", function() require 'dap'.continue() end },
  --     { "<C-o",       function() require 'dap'.step_over() end },
  --     { "<C-i>",      function() require 'dap'.step_into() end },
  --     { "<C-O>",      function() require 'dap'.step_out() end },
  --   },
  --   config = function()
  --     require("dap-vscode-js").setup({
  --       -- Path of node executable. Defaults to $NODE_PATH, and then "node"
  --       --
  --       node_path = "node",
  --
  --       -- Path to vscode-js-debug installation.
  --       debugger_path = vim.fn.resolve(vim.fn.stdpath("data") .. "/lazy/vscode-js-debug"),
  --
  --       -- Path for file logging
  --       log_file_path = "(stdpath cache)/dap_vscode_js.log",
  --
  --       -- Logging level for output to file. Set to false to disable logging.
  --       log_file_level = false,
  --
  --       -- Logging level for output to console. Set to false to disable console output.
  --       log_console_level = vim.log.levels.ERROR,
  --       -- Command to use to launch the debug server. Takes precedence over "node_path" and "debugger_path"
  --       debugger_cmd = { "js-debug-adapter" },
  --       adapters = { 'chrome', 'pwa-node', 'pwa-chrome', 'pwa-msedge', 'node-terminal', 'pwa-extensionHost' },
  --     })
  --
  --     for _, language in ipairs({ "typescript", "typescriptreact", "javascript", "javascriptreact", }) do
  --       require("dap").configurations[language] = {
  --         -- attach to a node process that has been started with
  --         -- `--inspect` for longrunning tasks or `--inspect-brk` for short tasks
  --         -- npm script -> `node --inspect-brk ./node_modules/.bin/vite dev`
  --         {
  --           -- use nvim-dap-vscode-js's pwa-node debug adapter
  --           type = "pwa-node",
  --           -- attach to an already running node process with --inspect flag
  --           -- default port: 9222
  --           request = "attach",
  --           -- allows us to pick the process using a picker
  --           processId = require 'dap.utils'.pick_process,
  --           -- name of the debug action you have to select for this config
  --           name = "Attach debugger to existing `node --inspect` process",
  --           -- for compiled languages like TypeScript or Svelte.js
  --           sourceMaps = true,
  --           -- resolve source maps in nested locations while ignoring node_modules
  --           resolveSourceMapLocations = {
  --             "${workspaceFolder}/**",
  --             "!**/node_modules/**" },
  --           -- path to src in vite based projects (and most other projects as well)
  --           cwd = "${workspaceFolder}/src",
  --           -- we don't want to debug code inside node_modules, so skip it!
  --           skipFiles = { "${workspaceFolder}/node_modules/**/*.js" },
  --         },
  --         {
  --           type = "pwa-chrome",
  --           name = "Launch Chrome to debug client",
  --           request = "launch",
  --           url = "http://localhost:3333",
  --           sourceMaps = true,
  --           protocol = "inspector",
  --           port = 3333,
  --           webRoot = "${workspaceFolder}/src",
  --           -- skip files from vite's hmr
  --           skipFiles = { "**/node_modules/**/*", "**/@vite/*", "**/src/client/*", "**/src/*" },
  --         },
  --         -- only if language is javascript, offer this debug action
  --         language == "javascript" and {
  --           -- use nvim-dap-vscode-js's pwa-node debug adapter
  --           type = "pwa-node",
  --           -- launch a new process to attach the debugger to
  --           request = "launch",
  --           -- name of the debug action you have to select for this config
  --           name = "Launch file in new node process",
  --           -- launch current file
  --           program = "${file}",
  --           cwd = "${workspaceFolder}",
  --         } or nil,
  --       }
  --     end
  --
  --     require("dapui").setup()
  --     local dap, dapui = require("dap"), require("dapui")
  --     dap.listeners.after.event_initialized["dapui_config"] = function()
  --       dapui.open({ reset = true })
  --     end
  --     dap.listeners.before.event_terminated["dapui_config"] = dapui.close
  --     dap.listeners.before.event_exited["dapui_config"] = dapui.close
  --   end
  -- }
}
