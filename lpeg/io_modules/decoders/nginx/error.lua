-- This Source Code Form is subject to the terms of the Mozilla Public
-- License, v. 2.0. If a copy of the MPL was not distributed with this
-- file, You can obtain one at http://mozilla.org/MPL/2.0/.

--[[
# Nginx Error Log Decoder Module

## Decoder Configuration Table
- none

## Functions

### decode

Decode and inject the resulting message

*Arguments*
- data (string) - Nginx error log line
- default_headers (table, nil/none) - Heka message table containing the default
  header values to use, if not populated by the decoder. Default 'Fields' cannot
  be provided.

*Return*
- err (nil, string)
    - nil if the data was successfully parsed/decoded and injected
    - string error message if the decoding failed
    - throws an error on an invalid data type, inject_message failure etc.

--]]

-- Imports
local clf               = require "lpeg.common_log_format"
local inject_message    = inject_message

local grammar = clf.nginx_error_grammar

local M = {}
setfenv(1, M) -- Remove external access to contain everything in the module

local msg = { }

function decode(data, dh)
    local msg = grammar:match(data)
    if not msg then return "parse failed" end

    if dh then
       if not msg.Uuid then msg.Uuid = dh.Uuid end
       if not msg.Logger then msg.Logger = dh.Logger end
       if not msg.Hostname then msg.Hostname = dh.Hostname end
       -- Timestamp always overwritten
       if not msg.Type then msg.Type = dh.Type end
       -- Payload always overwritten
       if not msg.EnvVersion then msg.EnvVersion = dh.EnvVersion end
       -- Pid always overwritten
       -- Severity always overwritten
       end

    inject_message(msg)
end

return M
