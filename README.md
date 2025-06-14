<div align="center">

# 🚀 Astal Bar

<img src="https://img.shields.io/badge/Built%20with-Lua-2C2D72?style=for-the-badge&logo=lua&logoColor=white" alt="Lua">
<img src="https://img.shields.io/badge/Framework-Astal-FF6B6B?style=for-the-badge" alt="Astal">
<img src="https://img.shields.io/badge/Platform-Wayland-1E88E5?style=for-the-badge&logo=wayland&logoColor=white" alt="Wayland">
<img src="https://img.shields.io/badge/Theme-Catppuccin-F5C2E7?style=for-the-badge" alt="Catppuccin">
<img src="https://img.shields.io/badge/Fork-Enhanced-00D9FF?style=for-the-badge&logo=github&logoColor=white" alt="Enhanced Fork">

**A modern, feature-rich system bar for Wayland compositors**
_Built with [Astal](https://github.com/aylur/astal) and Lua_

_Enhanced fork with extensive improvements and new features_ ✨

### 🎖️ **Credits**

**Original by:** [linuxmobile](https://github.com/linuxmobile/astal-bar) • **Enhanced by:** [SrwR16](https://github.com/SrwR16)

### 🚀 **What Makes This Fork Special**

<div align="center">

```
🌟 ENHANCED FEATURES 🌟

┌─────────────────────────────────────────┐
│ ✨ NEW ADDITIONS ✨                     │
├─────────────────────────────────────────┤
│ 🎛️  Advanced Display Controls           │
│ 🔋 Battery Conservation Mode           │
│ 🌡️  System Vitals Monitoring          │
│ 🎨 Enhanced Styling System             │
│ 🔧 Improved State Management           │
│ 📊 Performance Optimizations           │
│ 🎭 Better Animations & Transitions     │
│ 🌈 Extended Catppuccin Integration     │
└─────────────────────────────────────────┘
```

</div>

---

### 🎬 **Preview & Demo**

<div align="center">

```
┌─────────────────────────────────────────────────────────────────────┐
│  🏠  🖥️  🌐 telegram 🎥 obs ✏️ zed  📊   │ ⚡ ♪ 🔗 📶 🔋 📅 👤 │
└─────────────────────────────────────────────────────────────────────┘
                          ↑ Dynamic Top Bar ↑

                 ┌─────────────────────────┐
                 │  📁  💻  🌐  💬  🎥  │  ← Smart Dock
                 └─────────────────────────┘
                        (Auto-hide)
```

**🎨 Features in Action:**

- 🌊 **Smooth Animations** - Fluid hover effects and transitions
- 🎭 **Adaptive UI** - Components appear/disappear based on context
- 🌈 **Color Harmony** - Catppuccin palette with perfect contrast
- ⚡ **Performance** - Lightweight with <50MB RAM usage

</div>

<details>
<summary><b>🖼️ Visual Components Showcase</b></summary>

### 🎨 **Interface Elements**

```ascii
╭──────────── Top Bar ────────────╮
│ 🖥️ Active Window  ◉◉◉ Workspaces │ 🔊🔗📶🔋 System │
╰─────────────────────────────────╯

╭──── Dock (Auto-hide) ────╮
│  📁 💻 🌐 💬 🎥 ✏️ 📊  │
│   ● ● ●     ● ●  (running)   │
╰──────────────────────────╯

╭─── Notification Popup ───╮
│  🔔 New Message         │
│  From: Telegram         │
│  "Hey, check this out!" │
│  [View] [Dismiss]       │
╰─────────────────────────╯

╭── Media Control Window ──╮
│  🎵 Now Playing          │
│  Album Art   Song Info   │
│  ⏮️ ⏯️ ⏭️    🔊────●─  │
│  ●────────────────● Time │
╰──────────────────────────╯
```

</details>

</div>

## ✨ Features

<table>
<tr>
<td width="50%">

### 🎛️ **Core Components**

```
🚀 Dynamic Top Bar
   ├─ Adaptive layout system
   ├─ Real-time system monitoring
   └─ Multi-monitor support

📱 Smart Dock
   ├─ Auto-hiding with hover detection
   ├─ Pinned & running applications
   └─ Smooth reveal animations

🔔 Notification Center
   ├─ Rich notification popups
   ├─ Action button support
   └─ Dismissal animations

📺 OSD Controls
   ├─ Volume slider overlay
   ├─ Media control display
   └─ Fade-in/out transitions
```

</td>
<td width="50%">

### 🖥️ **System Widgets**

```
🎵 Media Player
   ├─ MPRIS integration
   ├─ Album art display
   └─ Playback controls

🔊 Audio Manager
   ├─ Device switching
   ├─ Volume controls
   └─ Mute indicators

🔗 Bluetooth Hub
   ├─ Device pairing
   ├─ Battery levels
   └─ Connection status

📶 Network Center
   ├─ WiFi management
   ├─ Signal strength
   └─ Quick connect
```

</td>
</tr>
</table>

<details>
<summary><b>🎨 Advanced System Integration</b></summary>

### 🔋 **Power & Display**

- **Battery Monitor** - Health tracking, conservation mode, power profiles
- **Display Controls** - Brightness, night light, color temperature adjustment
- **Workspace Manager** - Multi-monitor workspace switching (Niri optimized)

### 💻 **System Monitoring**

- **System Information** - Hardware specs, system stats, and detailed vitals
- **Performance Vitals** - Real-time CPU, memory, disk, and temperature monitoring
- **Resource Usage** - Interactive graphs and percentage displays

</details>

### 🎨 **Visual Excellence**

<div align="center">

| Feature                  | Description                             | Status    |
| ------------------------ | --------------------------------------- | --------- |
| 🌈 **Catppuccin Theme**  | Beautiful, consistent color palette     | ✅ Active |
| ⚡ **Smooth Animations** | Fluid transitions and hover effects     | ✅ Active |
| 📱 **Responsive Design** | Adapts to screen sizes and orientations | ✅ Active |
| 🎭 **Dynamic Styling**   | Context-aware UI elements               | ✅ Active |
| 🌙 **Dark/Light Modes**  | System theme integration                | ✅ Active |

</div>

## 🛠️ Installation

<div align="center">

### 🚀 **Quick Start**

</div>

<table>
<tr>
<td width="50%">

#### 📋 **Prerequisites**

```bash
✅ NixOS or Nix package manager
✅ Wayland compositor (tested with Niri)
✅ Astal framework
```

#### ⚡ **One-Command Install**

```bash
# Clone and build in one go
git clone https://github.com/SrwR16/astal-bar.git && \
cd astal-bar && \
nix build && \
./result/bin/kaneru
```

</td>
<td width="50%">

#### 🔧 **Development Setup**

```bash
# Enter the development environment
nix develop

# Start with hot-reload
./dev.sh

# Or run directly for testing
lua init.lua
```

#### 🎯 **Custom Installation**

```bash
# Build specific components
nix build .#kaneru

# Install system-wide (NixOS)
# Add to your configuration.nix
```

</td>
</tr>
</table>

<div align="center">

> 💡 **Pro Tip**: Use `./dev.sh` for development - it includes hot-reload and automatic SCSS compilation!

</div>

## ⚙️ Configuration

<div align="center">

### 🎨 **Customize Everything**

</div>

<details>
<summary><b>📝 User Variables Configuration</b></summary>

Customize your setup by editing `user-variables.lua`:

```lua
return {
    -- 🚢 Dock Settings
    dock = {
        pinned_apps = {
            "nautilus",    -- 📁 File Manager
            "ghostty",     -- 💻 Terminal
            "zen",         -- 🌐 Browser
            "telegram",    -- 💬 Messaging
            "obs",         -- 🎥 Streaming
            "zed",         -- ✏️  Code Editor
            "resources",   -- 📊 System Monitor
        },
    },

    -- 🖥️ Monitor Configuration
    monitor = {
        mode = "specific",        -- "primary" | "all" | "specific"
        specific_monitor = 1,     -- Monitor index
    },

    -- 👤 Profile Settings
    profile = {
        picture = os.getenv("HOME") .. "/Pictures/profile.png",
    },

    -- 🎵 Media Preferences
    media = {
        preferred_players = {
            "zen",         -- Browser media
            "firefox",     -- Fallback browser
        },
    },

    -- 🌙 Display Preferences
    display = {
        night_light_temp_initial = 3500,  -- Color temperature
    },
}
```

</details>

<details>
<summary><b>🎨 Styling & Themes</b></summary>

The interface uses **SCSS** with modular architecture:

```
scss/
├── 🎨 style.scss              # Main stylesheet
├── 🎯 abstracts/
│   ├── _colors.scss           # Catppuccin color palette
│   ├── _functions.scss        # SCSS utilities
│   └── _mixins.scss          # Reusable style patterns
├── 🧩 components/
│   ├── _button.scss          # Button styling
│   └── _tooltip.scss         # Tooltip animations
├── 🖼️ widgets/
│   ├── workspaces.scss       # Workspace indicators
│   ├── vitals.scss          # System vitals
│   └── active-client.scss   # Window title display
└── 🪟 windows/
    ├── bar.scss             # Main top bar
    ├── dock.scss            # Application dock
    ├── audio-control.scss   # Audio management
    └── ... (more components)
```

### 🌈 **Color Customization**

Edit `scss/abstracts/_colors.scss` to use your preferred color scheme:

- 🌸 **Catppuccin Mocha** (default)
- 🌙 **Custom dark themes**
- ☀️ **Light mode variants**

</details>

<div align="center">

> 🎭 **Theme Switching**: Toggle between light/dark modes with the display control widget!

</div>

## 🖥️ System Integration

<div align="center">

### 🔗 **Seamless System Integration**

</div>

<table>
<tr>
<td width="33%">

#### 🪟 **Window Managers**

```
✅ Niri (Primary)
✅ Sway
✅ Hyprland
✅ River
⚠️  Other Wayland WMs
```

</td>
<td width="33%">

#### 🔊 **Audio Systems**

```
✅ Wireplumber
✅ PipeWire
✅ ALSA
✅ PulseAudio
🎵 MPRIS Support
```

</td>
<td width="33%">

#### 🌐 **System Services**

```
✅ BlueZ (Bluetooth)
✅ NetworkManager
✅ UPower (Battery)
✅ systemd-logind
🔔 Built-in Notifications
```

</td>
</tr>
</table>

<details>
<summary><b>📦 Dependencies (Auto-managed by Nix)</b></summary>

### 🧩 **Core Framework**

- **Astal** - Main framework with GTK3 bindings
- **Lua 5.2** - Scripting language with essential packages
- **GLib/GTK3** - UI toolkit and system integration

### 🛠️ **System Utilities**

- `brightnessctl` - Display brightness control
- `gammastep` - Color temperature adjustment
- `fastfetch` - System information display
- `dart-sass` - SCSS compilation
- `inotify-tools` - File system monitoring

### 📚 **Lua Packages**

- `luautf8` - UTF-8 string handling
- `cjson` - JSON parsing and generation

### 🎨 **Development Tools**

- Hot-reload development server
- SCSS watch compilation
- Debug logging system

</details>

<div align="center">

> 🚀 **Zero Configuration**: All dependencies are automatically managed through the Nix flake!

</div>

## 🔧 Development

<div align="center">

### 🏗️ **Architecture Overview**

</div>

<details>
<summary><b>📁 Project Structure</b></summary>

```
astal-bar/
├── 🚀 init.lua                    # Application entry point
├── ⚙️  user-variables.lua          # User configuration
├── 📁 lua/
│   ├── 📚 lib/                    # Core libraries
│   │   ├── state.lua             # Reactive state management
│   │   ├── utils.lua             # Helper functions
│   │   ├── debug.lua             # Logging system
│   │   ├── display.lua           # Display controls
│   │   ├── vitals.lua            # System monitoring
│   │   └── ... (more modules)
│   ├── 🧩 widgets/                # Reusable UI components
│   │   ├── Workspaces.lua        # Workspace switcher
│   │   ├── Vitals.lua            # System vitals display
│   │   ├── ActiveClient.lua      # Window title
│   │   └── Notification.lua      # Notification widget
│   └── 🪟 windows/                # Main window definitions
│       ├── Bar.lua               # Top system bar
│       ├── Dock.lua              # Application dock
│       ├── AudioControl.lua      # Audio management
│       ├── BluetoothControl.lua  # Bluetooth manager
│       └── ... (more windows)
├── 🎨 scss/                       # Styling and themes
│   ├── style.scss               # Main stylesheet
│   ├── abstracts/               # SCSS utilities
│   ├── components/              # UI component styles
│   ├── widgets/                 # Widget-specific styles
│   └── windows/                 # Window-specific styles
├── 🎭 icons/                      # Custom SVG icons
├── 📦 flake.nix                   # Nix build configuration
└── 🔧 dev.sh                      # Development script
```

</details>

<details>
<summary><b>🧠 Key System Libraries</b></summary>

### 🔄 **State Management**

- **`state.lua`** - Reactive state system with pub/sub pattern
- **Event-driven updates** - Eliminates unnecessary polling
- **Memory-efficient** - Automatic cleanup and garbage collection

### 🖥️ **System Integration**

- **`display.lua`** - Brightness, gamma, and color temperature
- **`vitals.lua`** - CPU, memory, disk, and temperature monitoring
- **`niri.lua`** - Window manager integration
- **`dbus.lua`** - D-Bus communication wrapper

### 🛠️ **Utilities**

- **`utils.lua`** - Debouncing, throttling, and helper functions
- **`debug.lua`** - Comprehensive logging with file output
- **`common.lua`** - Shared utilities and constants

</details>

<details>
<summary><b>➕ Adding New Features</b></summary>

### 🎯 **Step-by-Step Guide**

1. **🧩 Create Widget/Window**

   ```bash
   # For widgets (reusable components)
   touch lua/widgets/MyWidget.lua

   # For windows (standalone interfaces)
   touch lua/windows/MyWindow.lua
   ```

2. **🎨 Add Styling**

   ```bash
   # Widget styles
   touch scss/widgets/my-widget.scss

   # Window styles
   touch scss/windows/my-window.scss

   # Import in scss/style.scss
   @use "widgets/my-widget";
   ```

3. **🔗 Register Component**

   ```lua
   -- In init.lua or parent component
   local MyWidget = require("lua.widgets.MyWidget")

   -- Add to layout
   MyWidget(),
   ```

4. **⚙️ Update Configuration**
   ```lua
   -- In user-variables.lua (if needed)
   my_feature = {
       enabled = true,
       option = "value",
   }
   ```

### 🎨 **Code Style Guidelines**

- Use **descriptive variable names**
- Implement **proper error handling**
- Add **debug logging** for important operations
- Follow **existing patterns** for consistency
- Write **self-documenting code**

</details>

<div align="center">

> 💡 **Development Tip**: Use `./dev.sh` for hot-reload development with automatic SCSS compilation!

</div>

## 🐛 Known Issues

<div align="center">

### 🔍 **Current Status & Issues**

</div>

<table>
<tr>
<td width="50%">

#### ⚠️ **Active Issues**

```
🔴 Suspension Recovery Error
   ├─ Variable emit signal error
   ├─ Occurs on system resume
   └─ Priority: High

🟡 Memory Optimization
   ├─ Polling-based updates
   ├─ Component cleanup
   └─ Priority: Medium
```

</td>
<td width="50%">

#### 🔧 **In Progress**

```
🟢 Performance Improvements
   ├─ Event-driven updates
   ├─ State management refactor
   └─ Memory leak fixes

🟢 Niri Integration
   ├─ Enhanced dock functionality
   ├─ Window focusing
   └─ Workspace improvements
```

</td>
</tr>
</table>

<div align="center">

📋 **Full Details**: See [currently_issues.md](currently_issues.md) • 🗺️ **Roadmap**: [ROADMAP.md](ROADMAP.md)

</div>

## 🗺️ Roadmap

<div align="center">

### 🚀 **Future Vision**

</div>

<details>
<summary><b>🎯 Planned Features</b></summary>

<table>
<tr>
<td width="50%">

#### 🆕 **New Modules**

```
📅 Calendar & Clock
   ├─ Event management
   ├─ Notification center
   └─ Pomodoro timer

🐙 GitHub Integration
   ├─ Activity feed
   ├─ PR status tracking
   └─ Notification panel

⌨️  Keyboard Visualization
   ├─ Real-time keypress display
   ├─ Visual feedback
   └─ Customizable layouts
```

</td>
<td width="50%">

#### 🔧 **Enhancements**

```
🎛️ Configuration GUI
   ├─ Visual settings panel
   ├─ Theme customization
   └─ Real-time preview

🚢 Enhanced Dock
   ├─ Window focusing
   ├─ Improved animations
   └─ Better Niri integration

📊 System Vitals
   ├─ Advanced monitoring
   ├─ Historical graphs
   └─ Alert system
```

</td>
</tr>
</table>

</details>

<details>
<summary><b>⚡ Performance Roadmap</b></summary>

### 🎯 **Optimization Goals**

#### 📈 **Phase 1: Foundation**

- [x] **State Management** - Reactive state system
- [x] **Utility Functions** - Debouncing, throttling, cleanup
- [ ] **Profiling Tools** - Performance monitoring

#### 📈 **Phase 2: Core Optimization**

- [ ] **Memory Management** - Reduce resource usage and fix leaks
- [ ] **Event-Driven Updates** - Replace polling with reactive updates
- [ ] **Lazy Loading** - Load components on-demand
- [ ] **Component Lifecycle** - Proper cleanup and initialization

#### 📈 **Phase 3: Advanced Features**

- [ ] **Plugin Architecture** - Community extension support
- [ ] **Performance Testing** - Automated benchmarks
- [ ] **Documentation** - Complete API and developer guides

</details>

<div align="center">

> 📋 **Detailed Plan**: See [ROADMAP.md](ROADMAP.md) for the complete implementation roadmap

</div>

## 📝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Make your changes following the existing code style
4. Test thoroughly with `./dev.sh`
5. Commit your changes (`git commit -m 'Add amazing feature'`)
6. Push to the branch (`git push origin feature/amazing-feature`)
7. Open a Pull Request

### Development Guidelines

- Follow existing Lua code style and patterns
- Use the established state management system
- Ensure proper cleanup in component destructors
- Add appropriate error handling and logging
- Update documentation for new features

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- [Astal](https://github.com/aylur/astal) - The fantastic framework this project is built on
- [Catppuccin](https://github.com/catppuccin/catppuccin) - Beautiful color palette
- [Niri](https://github.com/YaLTeR/niri) - The excellent Wayland compositor
- The open-source community for inspiration and tools

## 📞 Support

- **Issues**: [GitHub Issues](https://github.com/SrwR16/astal-bar/issues)
- **Discussions**: [GitHub Discussions](https://github.com/SrwR16/astal-bar/discussions)
- **Wiki**: [Project Wiki](https://github.com/SrwR16/astal-bar/wiki)
- **Original Project**: [linuxmobile/astal-bar](https://github.com/linuxmobile/astal-bar)

---

⭐ **Star this project** if you find it useful!
