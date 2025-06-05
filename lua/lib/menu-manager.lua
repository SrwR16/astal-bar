local astal = require("astal")
local Variable = astal.Variable
local Widget = require("astal.gtk3.widget")
local Debug = require("lua.lib.debug")

local MenuManager = {}

-- Global menu state tracking
local active_menu = Variable(nil)
local menu_windows = {}
local overlay_window = nil

-- Register a menu window with the manager
function MenuManager.register(name, window, toggle_function)
	menu_windows[name] = {
		window = window,
		toggle = toggle_function,
		visible = Variable(false)
	}

	Debug.debug("MenuManager", "Registered menu: " .. name)
end

-- Unregister a menu window
function MenuManager.unregister(name)
	if menu_windows[name] then
		menu_windows[name].visible:drop()
		menu_windows[name] = nil
		Debug.debug("MenuManager", "Unregistered menu: " .. name)
	end
end

-- Close all menus
function MenuManager.close_all()
	for name, menu in pairs(menu_windows) do
		if menu.visible:get() then
			menu.window:hide()
			menu.visible:set(false)
			Debug.debug("MenuManager", "Closed menu: " .. name)
		end
	end
	active_menu:set(nil)
	MenuManager.hide_overlay()
end

-- Open a specific menu and close others
function MenuManager.open(name)
	-- Close all other menus first
	for menu_name, menu in pairs(menu_windows) do
		if menu_name ~= name and menu.visible:get() then
			menu.window:hide()
			menu.visible:set(false)
			Debug.debug("MenuManager", "Closed menu: " .. menu_name)
		end
	end

	-- Open the requested menu
	if menu_windows[name] then
		menu_windows[name].window:show_all()
		menu_windows[name].visible:set(true)
		active_menu:set(name)
		MenuManager.show_overlay()
		Debug.debug("MenuManager", "Opened menu: " .. name)
	end
end

-- Toggle a menu (close if open, open if closed)
function MenuManager.toggle(name)
	if menu_windows[name] then
		if menu_windows[name].visible:get() then
			MenuManager.close_all()
		else
			MenuManager.open(name)
		end
	end
end

-- Check if any menu is open
function MenuManager.is_any_open()
	return active_menu:get() ~= nil
end

-- Get the currently active menu
function MenuManager.get_active()
	return active_menu:get()
end

-- Create an invisible overlay to detect clicks outside menus
function MenuManager.create_overlay(monitor)
	if overlay_window then
		return overlay_window
	end

	local Anchor = astal.require("Astal").WindowAnchor

	overlay_window = Widget.Window({
		class_name = "MenuOverlay",
		gdkmonitor = monitor,
		anchor = Anchor.TOP + Anchor.BOTTOM + Anchor.LEFT + Anchor.RIGHT,
		visible = false,
		child = Widget.EventBox({
			hexpand = true,
			vexpand = true,
			above_child = false,
			on_button_press_event = function()
				Debug.debug("MenuManager", "Overlay clicked - closing all menus")
				MenuManager.close_all()
				return true
			end,
		}),
	})

	Debug.debug("MenuManager", "Created overlay window")
	return overlay_window
end

-- Show the overlay
function MenuManager.show_overlay()
	if overlay_window then
		overlay_window:show_all()
		Debug.debug("MenuManager", "Showed overlay")
	end
end

-- Hide the overlay
function MenuManager.hide_overlay()
	if overlay_window then
		overlay_window:hide()
		Debug.debug("MenuManager", "Hid overlay")
	end
end

-- Cleanup function
function MenuManager.cleanup()
	for name, menu in pairs(menu_windows) do
		menu.visible:drop()
	end
	menu_windows = {}
	active_menu:drop()
	if overlay_window then
		overlay_window:destroy()
		overlay_window = nil
	end
	Debug.debug("MenuManager", "Cleaned up menu manager")
end

-- Initialize overlay for a specific monitor
function MenuManager.init_overlay(monitor)
	MenuManager.create_overlay(monitor)
	Debug.debug("MenuManager", "Initialized overlay for monitor")
end

return MenuManager
