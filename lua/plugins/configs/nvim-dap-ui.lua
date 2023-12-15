return function(_, opts)
  local dap, dapui = require "dap", require "dapui"
  dap.configurations.java = {
    {
      type = 'java';
      request = 'attach';
      name = "Debug";
      hostName = "127.0.0.1";
      port = 8000;
    },
  }
  dap.listeners.after.event_initialized["dapui_config"] = function() dapui.open() end
  dap.listeners.before.event_terminated["dapui_config"] = function() dapui.close() end
  dap.listeners.before.event_exited["dapui_config"] = function() dapui.close() end
  dapui.setup(opts)
end
