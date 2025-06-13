local astal = require("astal")
local Widget = require("astal.gtk3.widget")
local bind = astal.bind
local Variable = astal.Variable
local GLib = astal.require("GLib")
local Debug = require("lua.lib.debug")
local Process = astal.require("AstalIO").Process

-- Try to load AstalBluetooth, handle gracefully if not available
local Bluetooth = nil
local bluetooth_available = false

local success, bluetooth_module = pcall(astal.require, "AstalBluetooth")
if success then
	Bluetooth = bluetooth_module.get_default()
	bluetooth_available = Bluetooth ~= nil
	if bluetooth_available then
		Debug.info("BluetoothControl", "Bluetooth service initialized successfully")
	else
		Debug.warn("BluetoothControl", "AstalBluetooth module loaded but service unavailable")
	end
else
	Debug.warn("BluetoothControl", "AstalBluetooth module not available: %s", tostring(bluetooth_module))
end

local function BluetoothDevice(device)
	return Widget.Button({
		class_name = "bluetooth-device-item",
		hexpand = true,
		on_clicked = function()
			if device.connected then
				device:disconnect()
			else
				device:connect()
			end
		end,
		child = Widget.Box({
			orientation = "HORIZONTAL",
			spacing = 10,
			hexpand = true,
			Widget.Icon({
				icon = bind(device, "icon"):as(function(icon)
					return icon or "bluetooth-symbolic"
				end),
			}),
			Widget.Box({
				orientation = "VERTICAL",
				spacing = 2,
				hexpand = true,
				Widget.Label({
					label = bind(device, "alias"):as(function(alias)
						return alias or device.name or "Unknown Device"
					end),
					xalign = 0,
					hexpand = true,
					ellipsize = "END",
				}),
				Widget.Label({
					label = bind(device, "connected"):as(function(connected)
						return connected and "Connected" or "Disconnected"
					end),
					xalign = 0,
					css = "font-size: 12px; opacity: 0.7;",
				}),
			}),
			-- Battery level if available
			bind(device, "battery-percentage"):as(function(battery)
				if battery and battery > 0 then
					return Widget.Box({
						spacing = 5,
						Widget.Icon({
							icon = "battery-symbolic",
						}),
						Widget.Label({
							label = string.format("%d%%", battery),
						}),
					})
				end
				return Widget.Box({})
			end),
			Widget.Icon({
				icon = bind(device, "connected"):as(function(connected)
					return connected and "emblem-ok-symbolic" or "network-wireless-offline-symbolic"
				end),
			}),
		}),
	})
end

local function create_device_list(devices)
	local widgets = {}

	if not devices or #devices == 0 then
		return {
			Widget.Label({
				label = "No devices found",
				xalign = 0.5,
				css = "opacity: 0.7;",
			}),
		}
	end

	for _, device in ipairs(devices) do
		if device and device.paired then
			table.insert(widgets, BluetoothDevice(device))
		end
	end

	if #widgets == 0 then
		return {
			Widget.Label({
				label = "No paired devices",
				xalign = 0.5,
				css = "opacity: 0.7;",
			}),
		}
	end

	return widgets
end

local BluetoothControlWindow = {}

function BluetoothControlWindow.new(gdkmonitor)
	if not gdkmonitor then
		Debug.error("BluetoothControl", "No monitor available")
		return nil
	end

	if not bluetooth_available then
		Debug.error("BluetoothControl", "Bluetooth service not available")
		return nil
	end

	local Anchor = astal.require("Astal").WindowAnchor
	local window
	local is_destroyed = false
	local cleanup_refs = {}

	local function close_window()
		if window and not is_destroyed then
			window:hide()
		end
	end

	cleanup_refs.bluetooth_enabled = Variable(false)
	cleanup_refs.bluetooth_connected = Variable(false)

	-- Safe property access with error handling
	local function update_bluetooth_state()
		if Bluetooth then
			local powered = false
			local connected = false

			pcall(function()
				powered = Bluetooth.is_powered or false
			end)

			pcall(function()
				connected = Bluetooth.is_connected or false
			end)

			cleanup_refs.bluetooth_enabled:set(powered)
			cleanup_refs.bluetooth_connected:set(connected)
		end
	end

	-- Initial state update
	update_bluetooth_state()

	-- Try to set up property watching if possible
	if Bluetooth then
		pcall(function()
			Bluetooth:connect("notify::is-powered", update_bluetooth_state)
			Bluetooth:connect("notify::is-connected", update_bluetooth_state)
		end)
	end

	cleanup_refs.show_devices = Variable(false)

	local function QuickToggle()
		return Widget.Box({
			class_name = "bluetooth-quick-toggle",
			orientation = "HORIZONTAL",
			spacing = 10,
			hexpand = true,
			Widget.Button({
				class_name = Variable.derive({ cleanup_refs.bluetooth_enabled }, function(enabled)
					return enabled and "quick-toggle bluetooth active" or "quick-toggle bluetooth"
				end)(),
				hexpand = true,
				on_clicked = function()
					if Bluetooth and Bluetooth.toggle then
						Bluetooth:toggle()
					end
				end,
				child = Widget.Box({
					orientation = "VERTICAL",
					spacing = 5,
					hexpand = true,
					Widget.Icon({
						icon = "bluetooth-symbolic",
					}),
					Widget.Label({
						label = "Bluetooth",
						xalign = 0.5,
					}),
				}),
			}),
		})
	end

	local function DevicesList()
		return Widget.Box({
			class_name = "bluetooth-devices-section",
			orientation = "VERTICAL",
			spacing = 10,
			hexpand = true,
			Widget.Button({
				class_name = "device-selector",
				hexpand = true,
				child = Widget.Box({
					orientation = "HORIZONTAL",
					spacing = 10,
					hexpand = true,
					Widget.Icon({ icon = "bluetooth-symbolic" }),
					Widget.Box({
						hexpand = true,
						Widget.Label({
							label = "Paired Devices",
							xalign = 0,
							hexpand = true,
						}),
					}),
					Widget.Icon({
						icon = "pan-down-symbolic",
						class_name = Variable.derive({ cleanup_refs.show_devices }, function(shown)
							return shown and "expanded" or ""
						end)(),
					}),
				}),
				on_clicked = function()
					cleanup_refs.show_devices:set(not cleanup_refs.show_devices:get())
				end,
			}),
			Widget.Revealer({
				transition_duration = 200,
				transition_type = "SLIDE_DOWN",
				reveal_child = bind(cleanup_refs.show_devices),
				hexpand = true,
				child = Widget.Box({
					orientation = "VERTICAL",
					spacing = 5,
					class_name = "device-list",
					hexpand = true,
					setup = function(self)
						-- Initial device list
						local devices = {}
						if Bluetooth then
							pcall(function()
								devices = Bluetooth.devices or {}
							end)
						end

						local device_widgets = create_device_list(devices)
						for _, widget in ipairs(device_widgets) do
							self:add(widget)
						end
					end,
				}),
			}),
		})
	end

	local function Settings(close_window)
		return Widget.Box({
			class_name = "settings",
			hexpand = true,
			Widget.Button({
				label = "Bluetooth Settings",
				hexpand = true,
				on_clicked = function()
					close_window()
					Process.exec_async("env XDG_CURRENT_DESKTOP=GNOME gnome-control-center bluetooth")
				end,
			}),
		})
	end

	window = Widget.Window({
		class_name = "BluetoothControlWindow",
		gdkmonitor = gdkmonitor,
		anchor = Anchor.TOP + Anchor.RIGHT,
		width_request = 350,
		setup = function(self)
			self:hook(self, "destroy", function()
				if is_destroyed then
					return
				end
				is_destroyed = true

				for _, ref in pairs(cleanup_refs) do
					if type(ref) == "table" and ref.drop then
						ref:drop()
					end
				end

				cleanup_refs = nil
				collectgarbage("collect")
			end)
		end,
		child = Widget.Box({
			orientation = "VERTICAL",
			spacing = 15,
			css = "padding: 15px;",
			hexpand = true,
			Widget.Box({
				class_name = "bluetooth-status",
				orientation = "VERTICAL",
				spacing = 10,
				hexpand = true,
				QuickToggle(),
				Widget.Box({
					class_name = "status-info",
					orientation = "HORIZONTAL",
					spacing = 10,
					hexpand = true,
					Widget.Icon({
						icon = bind(cleanup_refs.bluetooth_enabled):as(function(powered)
							return powered and "bluetooth-active-symbolic" or "bluetooth-disabled-symbolic"
						end),
					}),
					Widget.Label({
						label = Variable.derive(
							{ bind(cleanup_refs.bluetooth_enabled), bind(cleanup_refs.bluetooth_connected) },
							function(powered, connected)
								if not powered then
									return "Bluetooth is off"
								elseif connected then
									return "Connected"
								else
									return "Not connected"
								end
							end
						)(),
						xalign = 0,
						hexpand = true,
					}),
				}),
			}),
			Widget.Box({
				visible = bind(cleanup_refs.bluetooth_enabled),
				child = DevicesList(),
			}),
			Settings(close_window),
		}),
	})

	return window
end

return BluetoothControlWindow
