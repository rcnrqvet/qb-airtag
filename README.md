# qb-airtag

# 🏷️ QB-Airtag - Vehicle & Player Tracker

A realistic tracking system for QBCore FiveM servers. Place airtags on players to track their real-time location for 30 minutes.

![Version](https://img.shields.io/badge/version-1.0.5-blue.svg)
![QBCore](https://img.shields.io/badge/framework-QBCore-green.svg)
![License](https://img.shields.io/badge/license-MIT-orange.svg)

## ✨ Features

- 🎯 **Real time GPS tracking** - Live blip updates every 5 seconds
- ⏱️ **30 minute battery life** - Automatically expires and converts to dead airtag
- 🗺️ **Dynamic blip names** - Shows remaining time on the map
- 🔒 **Owner-only tracking** - Only the person who activated it can see the blip
- 🎨 **Clean UI notifications** - Uses swt_notifications for alerts
- 📍 **Multiple tracking** - Track players carrying the airtag in their inventory
- 🔋 **Dead airtag system** - Expired trackers become unusable items
- 🚫 **Anti exploit** - Can't activate the same airtag twice

## 📋 Requirements

- [QBCore Framework](https://github.com/qbcore-framework/qb-core)
- [qb-inventory](https://github.com/qbcore-framework/qb-inventory) or compatible inventory system
- [swt_notifications](https://github.com/Switty6/swt_notifications) (optional - can replace with QBCore notifications)

## 🔧 Installation

1. **Download** the latest release or clone this repository:
```bash
git clone https://github.com/yourusername/qb-airtag.git
```

2. **Add items** to `qb-core/shared/items.lua`:
```lua
['airtag'] = {
    name = 'airtag',
    label = 'Airtag',
    weight = 250,
    type = 'item',
    image = 'airtag.png',
    unique = true,
    useable = true,
    shouldClose = true,
    description = 'A small tracking device. Activate to track movement for 30 minutes.'
},
['deadairtag'] = {
    name = 'deadairtag',
    label = 'Dead Airtag',
    weight = 250,
    type = 'item',
    image = 'airtag_dead.png',
    unique = true,
    useable = false,
    shouldClose = true,
    description = 'A dead airtag. No longer functional.'
},
```

3. **Add images** to your inventory images folder:
   - `airtag.png`
   - `airtag_dead.png`

4. **Add to server.cfg**:
```
ensure qb-airtag
```

5. **Restart your server**

## 🎮 Usage

### For Players:
1. Obtain an airtag item (through shops, crafting, or admin)
2. Use the airtag from your inventory
3. The airtag is now activated and tracking begins
4. A blip appears on your map showing the airtag's location
5. After 30 minutes, it automatically becomes a "Dead Airtag"

### For Admins:
```lua
-- Give player an airtag
/give [player_id] airtag 1
```

## 📸 Screenshots

> Add your screenshots here showing:
> - Airtag item in inventory
> - Active tracking blip on map
> - Notification messages

## ⚙️ Configuration

The script has minimal configuration. To adjust settings, edit `server/main.lua`:

```lua
expire = os.time() + 1800 -- Change 1800 to desired seconds (default: 30 minutes)
```

And `client/main.lua`: to change the time for blip & blip name time 
```lua
Wait(5000) -- Location update interval (default: 5 seconds)
Wait(30000) -- Blip name update interval (default: 30 seconds)
```

## 🔍 How It Works

1. **Activation**: Player uses airtag item → Creates unique tracker ID → Starts 30-min timer
2. **Tracking**: Client checks every 5 seconds → Requests location from server → Updates blip position
3. **Location Detection**: All clients check their inventory → Report if they have the airtag → Owner sees updated position
4. **Expiration**: After 30 minutes → Converts to dead airtag → Removes blip → Sends notification

## ⚠️ Known Limitations

- **Vehicle Tracking**: Limited ability to track airtags in vehicle trunks/gloveboxes (FiveM security restriction)
- **Dropped Items**: Difficult to track dropped airtags in remote areas without nearby players
- **Best Use Case**: Works perfectly for tracking players with airtag in their inventory

## 🐛 Bug Reports & Suggestions

Found a bug or have a feature request? Please open an [issue](https://github.com/rcnrqvet/qb-airtag/issues) !

## 🤝 Contributing

## 📝 Changelog

### Version 1.0.5 (Current)
- ✅ Real time tracking system
- ✅ Dynamic blip names with countdown
- ✅ Auto expiration to dead airtag
- ✅ Owner only tracking
- ✅ Performance optimized for less spam (30s periodic checks)

## 💰 Support

This script is **completely free** and always will be!

If you find it useful:
- ⭐ **Star this repository**
- 🐛 **Report bugs** and suggest features

Contact me on Discord for any help: **rcnrqvet#0000**

## 📜 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Credits

- **Author**: rcnrqvet
- **Framework**: [QBCore](https://github.com/qbcore-framework)
- **Inspired by**: Real life Apple AirTag


**Made with ❤️ for the FiveM community**

*If you use this script, a star ⭐ on GitHub would be greatly appreciated!*
