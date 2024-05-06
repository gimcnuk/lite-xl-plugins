-- mod-version:3

local core = require "core"
local config = require "core.config"
local common = require "core.common"
local style = require "core.style"
local StatusView = require "core.statusview"
local DocView = require "core.docview"
local CommandView = require "core.commandview"

config.plugins.selectcount = common.merge({
	enabled = true,
	nlcnt = true,
	-- The config specification used by the settings gui
	config_spec = {
		name = "Select Count",
		{
			label = "Enabled",
			description = "Counts selected text and print number of lines and characters.",
			path = "enabled",
			type = "toggle",
			default = true,
			on_apply = function(enabled)
				core.add_thread(function()
					if enabled then
						core.status_view:get_item("doc:selectcount"):show()
					else
						core.status_view:get_item("doc:selectcount"):hide()
					end
				end)
			end
		},
		{
			label = "Count newlines",
			description = "Count newline symbols [\\r, \\n] as a character",
			path = "nlcnt",
			type = "toggle",
			default = true
		}
	}
}, config.plugins.selectcount)

local function selectcount()
	if core.status_view:get_item("doc:selectcount") then return end

	core.status_view:add_item({
		predicate = function() return core.active_view:is(DocView) and not core.active_view:is(CommandView) end,
		name = "doc:selectcount",
		alignment = StatusView.Item.LEFT,
		get_item = function()
			local line, sym = 0, 0
			local line1, col1, line2, col2 = core.active_view.doc:get_selection()
			
			if line1 ~= line2 or col1 ~= col2 then 
				line = math.abs(line1 - line2) + 1
				local text = core.active_view.doc:get_text(line1, col1, line2, col2)
				if not config.plugins.selectcount.nlcnt then text = text:gsub("[\n\r]", "") end
				-- multi-byte or single-byte encoding or 0 (unknown error)
				sym = string.ulen(text) or string.len(text) or 0
				-- some dirty
				if core.active_view.doc.crlf and config.plugins.selectcount.nlcnt then sym = sym + line - 1 end
			end

			return {
				style.text,
				style.font,
				"Sel: " .. line .. " / " .. sym
			}
		end,
		tooltip = "lines / symbols in selection",
	})

end

local SelectCount = selectcount()

return SelectCount
