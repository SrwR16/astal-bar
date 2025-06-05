local astal = require("astal")
local Widget = require("astal.gtk3.widget")
local Variable = astal.Variable
local Debug = require("lua.lib.debug")

local PowerControl = {}

function PowerControl.new(monitor)
	local Anchor = astal.require("Astal").WindowAnchor
	local window = nil

	local function execute_command(command, description)
		return function()
			Debug.info("PowerControl", "Executing: " .. description)
			if window then
				window:hide()
			end
			astal.exec(command)
		end
	end

	local function create_power_button(icon, label, command, class)
		return Widget.Button({
			class_name = class or "power-option-button",
			on_clicked = execute_command(command, label),
			child = Widget.Box({
				orientation = "VERTICAL",
				spacing = 8,
				Widget.Icon({
					icon = icon,
					size = 32,
				}),
				Widget.Label({
					label = label,
					class_name = "power-option-label",
				}),
			}),
		})
	end

	window = Widget.Window({
		class_name = "PowerControl",
		gdkmonitor = monitor,
		anchor = Anchor.TOP + Anchor.RIGHT,
		margin_top = 50,
		margin_right = 20,
		visible = false,
		layer = "OVERLAY",
		keymode = "ON_DEMAND",
		setup = function(self)
			self:hook(self, "key-press-event", function(_, event)
				if event.keyval == 65307 then -- Escape key
					self:hide()
				end
				return false
			end)
		end,
		child = Widget.EventBox({
			on_button_press_event = function(_, event)
				if event.button == 1 then -- Left click outside
					window:hide()
				end
				return true
			end,
			child = Widget.Box({
				class_name = "power-control-container",
				orientation = "VERTICAL",
				spacing = 12,
				Widget.Box({
					class_name = "power-control-header",
					Widget.Label({
						label = "Power Options",
						class_name = "power-control-title",
					}),
				}),
				Widget.Box({
					class_name = "power-options-grid",
					orientation = "HORIZONTAL",
					spacing = 12,
					create_power_button(
						"system-shutdown-symbolic",
						"Shutdown",
						"systemctl poweroff",
						"power-shutdown-button"
					),
					create_power_button(
						"system-reboot-symbolic",
						"Reboot",
						"systemctl reboot",
						"power-reboot-button"
					),
					create_power_button(
						"system-suspend-symbolic",
						"Suspend",
						"systemctl suspend",
						"power-suspend-button"
					),
					create_power_button(
						"system-log-out-symbolic",
						"Logout",
						"loginctl terminate-user $USER",
						"power-logout-button"
					),
				}),
			}),
		}),
	})

	return window
end

return PowerControl
