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
	local device_connected = Variable(device.connected or false)
	local device_paired = Variable(device.paired or false)
	local device_battery = Variable(device.battery_percentage or 0)

	-- Set up property watching with error handling
	if device then
		pcall(function()
			device:connect("notify::connected", function()
				device_connected:set(device.connected or false)
			end)
			device:connect("notify::paired", function()
				device_paired:set(device.paired or false)
			end)
			device:connect("notify::battery-percentage", function()
				device_battery:set(device.battery_percentage or 0)
			end)
		end)
	end

	-- Create derived variable for pair button
	local pair_button_widget = Variable.derive({ device_paired }, function(paired)
		if not device then
			return Widget.Box({})
		end
		if not paired then
			return Widget.Button({
				class_name = "action-button pair-button",
				label = "Pair",
				on_clicked = function()
					pcall(function()
						device:pair()
					end)
				end,
			})
		end
		return Widget.Box({})
	end)

	-- Create derived variable for class name
	local class_name_var = Variable.derive({ device_connected, device_paired }, function(connected, paired)
		if not device then
			return "device-item"
		end
		local classes = "device-item"
		if connected then
			classes = classes .. " connected"
		elseif paired then
			classes = classes .. " paired"
		end
		return classes
	end)

	return Widget.Button({
		class_name = bind(class_name_var),
		hexpand = true,
		on_clicked = function()
			-- Don't handle connection in the main button click
		end,
		child = Widget.Box({
			orientation = "HORIZONTAL",
			spacing = 10,
			hexpand = true,
			Widget.Box({
				class_name = "device-info",
				orientation = "HORIZONTAL",
				spacing = 10,
				hexpand = true,
				Widget.Icon({
					class_name = "device-icon",
					icon = bind(device, "icon"):as(function(icon)
						return icon or "bluetooth-symbolic"
					end),
				}),
				Widget.Box({
					orientation = "VERTICAL",
					spacing = 2,
					hexpand = true,
					Widget.Label({
						class_name = "device-name",
						label = bind(device, "alias"):as(function(alias)
							return alias or device.name or "Unknown Device"
						end),
						xalign = 0,
						hexpand = true,
						ellipsize = "END",
					}),
					Widget.Label({
						class_name = "device-address",
						label = bind(device, "address"):as(function(addr)
							return addr or "Unknown Address"
						end),
						xalign = 0,
					}),
				}),
			}),
			Widget.Box({
				class_name = "device-actions",
				orientation = "HORIZONTAL",
				spacing = 4,
				-- Battery level if available
				bind(device_battery):as(function(battery)
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
				Widget.Button({
					class_name = bind(device_connected):as(function(connected)
						return connected and "action-button disconnect-button" or "action-button connect-button"
					end),
					label = bind(device_connected):as(function(connected)
						return connected and "Disconnect" or "Connect"
					end),
					on_clicked = function()
						if device_connected:get() then
							pcall(function()
								device:disconnect()
							end)
						else
							pcall(function()
								device:connect()
							end)
						end
					end,
				}),
				-- Add pair button for unpaired devices
				bind(pair_button_widget),
			}),
		}),
		setup = function(self)
			self:hook(self, "destroy", function()
				pcall(function()
					device_connected:drop()
				end)
				pcall(function()
					device_paired:drop()
				end)
				pcall(function()
					device_battery:drop()
				end)
				pcall(function()
					pair_button_widget:drop()
				end)
				pcall(function()
					class_name_var:drop()
				end)
			end)
		end,
	})
end

local function create_device_list(devices, show_all)
	local widgets = {}

	if not devices or #devices == 0 then
		return {
			Widget.Label({
				class_name = "no-devices",
				label = "No devices found",
				xalign = 0.5,
			}),
		}
	end

	for _, device in ipairs(devices) do
		if device and (show_all or device.paired) then
			table.insert(widgets, BluetoothDevice(device))
		end
	end

	if #widgets == 0 then
		return {
			Widget.Label({
				class_name = "no-devices",
				label = show_all and "No devices discovered" or "No paired devices",
				xalign = 0.5,
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

	-- State variables
	cleanup_refs.bluetooth_enabled = Variable(false)
	cleanup_refs.bluetooth_connected = Variable(false)
	cleanup_refs.bluetooth_discovering = Variable(false)
	cleanup_refs.paired_devices = Variable({})
	cleanup_refs.discovered_devices = Variable({})
	cleanup_refs.show_discovery = Variable(false)
	cleanup_refs.show_paired = Variable(false)
	cleanup_refs.is_scanning = Variable(false)
	cleanup_refs.scan_ready = Variable(false)

	local function start_scan()
		if not Bluetooth or not cleanup_refs.bluetooth_enabled:get() then
			return
		end

		cleanup_refs.is_scanning:set(true)
		cleanup_refs.scan_ready:set(false)
		cleanup_refs.discovered_devices:set({})

		Debug.info("BluetoothControl", "Starting Bluetooth device discovery")

		pcall(function()
			Bluetooth:start_discovery()
		end)

		-- Set a timeout to stop scanning after 10 seconds
		cleanup_refs.scan_timer = GLib.timeout_add(GLib.PRIORITY_DEFAULT, 10000, function()
			if not is_destroyed then
				pcall(function()
					Bluetooth:stop_discovery()
				end)
				cleanup_refs.is_scanning:set(false)
				cleanup_refs.scan_ready:set(true)
				cleanup_refs.scan_timer = nil
			end
			return false
		end)
	end

	-- Update bluetooth state
	local function update_bluetooth_state()
		if not Bluetooth or is_destroyed then
			return
		end

		local powered = false
		local connected = false
		local discovering = false

		-- Try multiple ways to get the powered state
		pcall(function()
			if Bluetooth.is_powered ~= nil then
				powered = Bluetooth.is_powered
			elseif Bluetooth.powered ~= nil then
				powered = Bluetooth.powered
			end
		end)

		pcall(function()
			if Bluetooth.is_connected ~= nil then
				connected = Bluetooth.is_connected
			elseif Bluetooth.connected ~= nil then
				connected = Bluetooth.connected
			end
		end)

		pcall(function()
			if Bluetooth.discovering ~= nil then
				discovering = Bluetooth.discovering
			end
		end)

		-- Fallback: check bluetoothctl for power status if API doesn't work
		if not powered then
			pcall(function()
				local output = astal.exec("bluetoothctl show | grep 'Powered' | awk '{print $2}'")
				if output and output:match("yes") then
					powered = true
				end
			end)
		end

		Debug.info("BluetoothControl", "State update - Powered: %s, Connected: %s, Discovering: %s",
			tostring(powered), tostring(connected), tostring(discovering))

		cleanup_refs.bluetooth_enabled:set(powered)
		cleanup_refs.bluetooth_connected:set(connected)
		cleanup_refs.bluetooth_discovering:set(discovering)

		-- If Bluetooth is off, hide discovery section and clear discovery state
		if not powered then
			cleanup_refs.show_discovery:set(false)
			cleanup_refs.bluetooth_discovering:set(false)
		end

		-- Update device lists
		local devices = {}
		pcall(function()
			devices = Bluetooth.devices or {}
		end)

		local paired = {}
		local discovered = {}

		for _, device in ipairs(devices) do
			if device.paired then
				table.insert(paired, device)
			else
				table.insert(discovered, device)
			end
		end

		cleanup_refs.paired_devices:set(paired)
		cleanup_refs.discovered_devices:set(discovered)
	end

	-- Initial state update
	update_bluetooth_state()

	-- Set up property watching
	if Bluetooth then
		pcall(function()
			Bluetooth:connect("notify::is-powered", update_bluetooth_state)
			Bluetooth:connect("notify::is-connected", update_bluetooth_state)
			Bluetooth:connect("notify::discovering", update_bluetooth_state)
			Bluetooth:connect("device-added", update_bluetooth_state)
			Bluetooth:connect("device-removed", update_bluetooth_state)
		end)
	end

	-- Periodic updates to catch any missed signals
	cleanup_refs.update_timer = GLib.timeout_add(GLib.PRIORITY_DEFAULT, 2000, function()
		if not is_destroyed then
			update_bluetooth_state()
			return true
		end
		return false
	end)

	local function BluetoothToggle()
		-- Create derived variables for toggle button
		local toggle_class_var = Variable.derive({ cleanup_refs.bluetooth_enabled }, function(enabled)
			if is_destroyed or not cleanup_refs then
				return "toggle-button"
			end
			return enabled and "toggle-button enabled" or "toggle-button"
		end)
		local toggle_label_var = Variable.derive({ cleanup_refs.bluetooth_enabled }, function(enabled)
			if is_destroyed or not cleanup_refs then
				return "Off"
			end
			return enabled and "On" or "Off"
		end)

		-- Store these variables for cleanup
		cleanup_refs.toggle_class_var = toggle_class_var
		cleanup_refs.toggle_label_var = toggle_label_var

		return Widget.Box({
			class_name = "bluetooth-toggle",
			orientation = "HORIZONTAL",
			spacing = 10,
			hexpand = true,
			Widget.Icon({
				class_name = "bluetooth-icon",
				icon = bind(cleanup_refs.bluetooth_enabled):as(function(enabled)
					return enabled and "bluetooth-active-symbolic" or "bluetooth-disabled-symbolic"
				end),
			}),
			Widget.Label({
				label = "Bluetooth",
				xalign = 0,
				hexpand = true,
			}),
			Widget.Button({
				class_name = bind(toggle_class_var),
				on_clicked = function()
					if Bluetooth then
						local current_state = cleanup_refs.bluetooth_enabled:get()
						local new_state = not current_state

						Debug.info("BluetoothControl", "Toggling Bluetooth from %s to %s", tostring(current_state), tostring(new_state))

						local success = false

						-- Try the AstalBluetooth API first
						pcall(function()
							if Bluetooth.set_powered then
								Bluetooth:set_powered(new_state)
								success = true
							elseif Bluetooth.powered ~= nil then
								Bluetooth.powered = new_state
								success = true
							elseif Bluetooth.is_powered ~= nil then
								-- Try direct property assignment
								Bluetooth.is_powered = new_state
								success = true
							end
						end)

						-- If API failed, try bluetoothctl command
						if not success then
							Debug.warn("BluetoothControl", "API failed, trying bluetoothctl command")
							local cmd = new_state and "bluetoothctl power on" or "bluetoothctl power off"
							Process.exec_async(cmd)
						end

						-- If turning off, hide discovery section
						if not new_state then
							cleanup_refs.show_discovery:set(false)
							cleanup_refs.bluetooth_discovering:set(false)
						end

						-- Force update after a short delay
						GLib.timeout_add(GLib.PRIORITY_DEFAULT, 1000, function()
							if not is_destroyed then
								update_bluetooth_state()
							end
							return false
						end)
					end
				end,
				child = Widget.Label({
					label = bind(toggle_label_var),
				}),
			}),
		})
	end

	local function ConnectedDevicesList()
		-- Create a derived variable for the paired devices list
		local paired_devices_list = Variable.derive(
			{ cleanup_refs.bluetooth_enabled, cleanup_refs.paired_devices },
			function(enabled, devices)
				if is_destroyed or not cleanup_refs then
					return {}
				end

				if not enabled then
					return {
						Widget.Label({
							label = "Bluetooth is disabled",
							xalign = 0.5,
						}),
					}
				end

				if not devices or #devices == 0 then
					return {
						Widget.Label({
							label = "No paired devices",
							xalign = 0.5,
						}),
					}
				end

				local buttons = {}
				for _, device in ipairs(devices) do
					if device and device.paired then
						table.insert(buttons, BluetoothDevice(device))
					end
				end

				if #buttons == 0 then
					return {
						Widget.Label({
							label = "No paired devices",
							xalign = 0.5,
						}),
					}
				end

				return buttons
			end
		)

		-- Store for cleanup
		cleanup_refs.paired_devices_list = paired_devices_list

		return Widget.Box({
			class_name = "device-controls",
			orientation = "VERTICAL",
			spacing = 5,
			hexpand = true,
			visible = bind(cleanup_refs.bluetooth_enabled),
			Widget.Box({
				class_name = "devices-container",
				orientation = "VERTICAL",
				spacing = 8,
				hexpand = true,
				Widget.Button({
					class_name = "device-selector",
					hexpand = true,
					child = Widget.Box({
						orientation = "HORIZONTAL",
						spacing = 10,
						hexpand = true,
						Widget.Icon({
							icon = Variable.derive({ cleanup_refs.bluetooth_connected }, function(connected)
								return connected and "bluetooth-active-symbolic" or "bluetooth-symbolic"
							end)(),
						}),
						Widget.Box({
							hexpand = true,
							Widget.Label({
								label = Variable.derive({ cleanup_refs.bluetooth_connected, cleanup_refs.paired_devices }, function(connected, devices)
									if connected then
										return "Connected Devices"
									else
										local count = devices and #devices or 0
										return count > 0 and string.format("Paired Devices (%d)", count) or "Paired Devices"
									end
								end)(),
								xalign = 0,
								hexpand = true,
							}),
						}),
						Widget.Icon({
							icon = "pan-down-symbolic",
							class_name = Variable.derive({ cleanup_refs.show_paired }, function(shown)
								return shown and "expanded" or ""
							end)(),
						}),
					}),
					on_clicked = function()
						cleanup_refs.show_paired:set(not cleanup_refs.show_paired:get())
					end,
				}),
				Widget.Revealer({
					transition_duration = 200,
					transition_type = "SLIDE_DOWN",
					reveal_child = bind(cleanup_refs.show_paired),
					hexpand = true,
					child = Widget.Box({
						class_name = "devices-list-container",
						orientation = "VERTICAL",
						hexpand = true,
						Widget.Scrollable({
							vscrollbar_policy = "AUTOMATIC",
							hscrollbar_policy = "NEVER",
							class_name = "device-list",
							hexpand = true,
							child = Widget.Box({
								orientation = "VERTICAL",
								spacing = 4,
								hexpand = true,
								bind(paired_devices_list),
							}),
						}),
					}),
				}),
			}),
		})
	end

	local function AvailableDevicesSection()
		local function start_scan()
			if not Bluetooth or not cleanup_refs.bluetooth_enabled:get() then
				return
			end

			cleanup_refs.is_scanning:set(true)
			cleanup_refs.scan_ready:set(false)
			cleanup_refs.discovered_devices:set({})

			Debug.info("BluetoothControl", "Starting Bluetooth device discovery")

			pcall(function()
				Bluetooth:start_discovery()
			end)

			-- Set a timeout to stop scanning after 10 seconds
			cleanup_refs.scan_timer = GLib.timeout_add(GLib.PRIORITY_DEFAULT, 10000, function()
				if not is_destroyed then
					pcall(function()
						Bluetooth:stop_discovery()
					end)
					cleanup_refs.is_scanning:set(false)
					cleanup_refs.scan_ready:set(true)
					cleanup_refs.scan_timer = nil
				end
				return false
			end)
		end

		-- Create a derived variable for the device list similar to WiFi networks
		local devices_list = Variable.derive(
			{ cleanup_refs.bluetooth_enabled, cleanup_refs.scan_ready, cleanup_refs.discovered_devices, cleanup_refs.is_scanning },
			function(enabled, ready, devices, scanning)
				if is_destroyed or not cleanup_refs then
					return {}
				end

				if not enabled then
					return {
						Widget.Label({
							label = "Bluetooth is disabled",
							xalign = 0.5,
						}),
					}
				end

				if scanning and not ready then
					return {
						Widget.Label({
							label = "Scanning for devices...",
							xalign = 0.5,
						}),
					}
				end

				if not devices or #devices == 0 then
					local message = ready and "No devices discovered" or "Click to scan for devices"
					return {
						Widget.Label({
							label = message,
							xalign = 0.5,
						}),
					}
				end

				local buttons = {}
				for _, device in ipairs(devices) do
					if device and not device.paired then  -- Only show unpaired devices
						table.insert(buttons, BluetoothDevice(device))
					end
				end

				if #buttons == 0 then
					return {
						Widget.Label({
							label = "No new devices found",
							xalign = 0.5,
						}),
					}
				end

				return buttons
			end
		)

		-- Store for cleanup
		cleanup_refs.devices_list = devices_list

		return Widget.Box({
			class_name = "device-controls",
			orientation = "VERTICAL",
			spacing = 10,
			hexpand = true,
			visible = bind(cleanup_refs.bluetooth_enabled),
			Widget.Box({
				class_name = "devices-container",
				orientation = "VERTICAL",
				spacing = 8,
				hexpand = true,
				Widget.Button({
					class_name = "device-selector",
					hexpand = true,
					child = Widget.Box({
						orientation = "HORIZONTAL",
						spacing = 10,
						hexpand = true,
						Widget.Icon({
							icon = "bluetooth-symbolic",
						}),
						Widget.Box({
							hexpand = true,
							Widget.Label({
								label = Variable.derive({ cleanup_refs.is_scanning }, function(scanning)
									return scanning and "Scanning..." or "Available Devices"
								end)(),
								xalign = 0,
								hexpand = true,
							}),
						}),
						Widget.Icon({
							icon = "pan-down-symbolic",
							class_name = Variable.derive({ cleanup_refs.show_discovery }, function(shown)
								return shown and "expanded" or ""
							end)(),
						}),
					}),
					on_clicked = function()
						local new_state = not cleanup_refs.show_discovery:get()
						cleanup_refs.show_discovery:set(new_state)
						if new_state then
							start_scan()
						else
							-- Stop scanning when collapsing
							if cleanup_refs.scan_timer then
								GLib.source_remove(cleanup_refs.scan_timer)
								cleanup_refs.scan_timer = nil
							end
							pcall(function()
								Bluetooth:stop_discovery()
							end)
							cleanup_refs.is_scanning:set(false)
							cleanup_refs.scan_ready:set(false)
							cleanup_refs.discovered_devices:set({})
						end
					end,
				}),
				Widget.Revealer({
					transition_duration = 200,
					transition_type = "SLIDE_DOWN",
					reveal_child = bind(cleanup_refs.show_discovery),
					hexpand = true,
					child = Widget.Box({
						class_name = "devices-list-container",
						orientation = "VERTICAL",
						hexpand = true,
						Widget.Scrollable({
							vscrollbar_policy = "AUTOMATIC",
							hscrollbar_policy = "NEVER",
							class_name = "device-list",
							hexpand = true,
							child = Widget.Box({
								orientation = "VERTICAL",
								spacing = 5,
								hexpand = true,
								bind(devices_list),
							}),
						}),
					}),
				}),
			}),
		})
	end

	local function Settings()
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

				if cleanup_refs then
					if cleanup_refs.update_timer then
						GLib.source_remove(cleanup_refs.update_timer)
						cleanup_refs.update_timer = nil
					end

					if cleanup_refs.scan_timer then
						GLib.source_remove(cleanup_refs.scan_timer)
						cleanup_refs.scan_timer = nil
					end

					-- Drop all variables properly
					for key, ref in pairs(cleanup_refs) do
						if type(ref) == "table" and ref.drop then
							pcall(function()
								ref:drop()
							end)
						end
						cleanup_refs[key] = nil
					end

					cleanup_refs = nil
				end

				collectgarbage("collect")
			end)
		end,
		child = Widget.Box({
			orientation = "VERTICAL",
			spacing = 15,
			css = "padding: 15px;",
			hexpand = true,
			Widget.Box({
				class_name = "bluetooth-controls-container",
				orientation = "VERTICAL",
				spacing = 10,
				hexpand = true,
				BluetoothToggle(),
			}),
			ConnectedDevicesList(),
			AvailableDevicesSection(),
			Settings(),
		}),
	})

	return window
end

return BluetoothControlWindow
