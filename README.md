# qb-airtag

# 🏷️ QB-Airtag - Vehicle & Player Tracker

A realistic tracking system for QBCore FiveM servers. Place airtags on players/objects to track their real time location for 30 minutes. Made for qbCore but should work with ESX as well.

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
- 🚫 **Anti exploit** - Can't activate the **same** airtag twice

## 📋 Requirements

- [QBCore Framework](https://github.com/qbcore-framework/qb-core)
- [qb-inventory](https://github.com/qbcore-framework/qb-inventory) or compatible inventory system
- [swt_notifications](https://github.com/Switty6/swt_notifications) 

## 🔧 Installation

1. **Download** the latest release or clone this repository:
```bash
git clone https://github.com/rcnrqvet/qb-airtag.git
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
   - [airtag.png](https://github.com/user-attachments/assets/bdd4d753-ca6f-4c64-b570-57ac83cdc19b)
   - [airtag_dead.png](https://github.com/user-attachments/assets/655011ac-00b9-44c8-99c3-c2dcad3fed74)
")

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

> - <img width="107" height="104" alt="image" src="https://github.com/user-attachments/assets/8e81d00b-5e16-40c4-97d4-d796e2e060c9" />

> - <img width="318" height="38" alt="image" src="https://github.com/user-attachments/assets/213166d1-8096-4677-9773-8413fef0e10c" />
> - <img width="1016" height="525" alt="image" src="https://github.com/user-attachments/assets/55c18a3f-1ba0-4f7b-a3d7-5986cb5efbf4" />

> - <img width="277" height="53" alt="image" src="https://github.com/user-attachments/assets/80572055-35f7-423e-b13f-78bb308408a8" />
> - <img width="293" height="55" alt="image" src="https://github.com/user-attachments/assets/5c32ded0-4785-4064-bfdf-5e98cc3e6d68" />





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
- **Best Use Case**: Works perfectly for tracking players or vehicles with airtag in their inventory. Will still track if dropped and picked up etc.

## 🐛 Bug Reports & Suggestions

Found a bug or have a feature request? Please open an [issue](https://github.com/rcnrqvet/qb-airtag/issues) !

## 📝 Changelog

### Version 1.0.5 (Current)
- ✅ Real time tracking system
- ✅ Dynamic blip names with countdown
- ✅ Auto expiration to dead airtag
- ✅ Owner only tracking
- ✅ Performance optimized for less spam (30s checks)

## 💰 Support

This script is **completely free** and always will be!

If you find it useful:
- ⭐ **Star this repository**
- 🐛 **Report bugs** and suggest features

Contact me on Discord for any help: **rcnrqvet#0000**

## 📜 License

This project is licensed under the MIT License, see the [LICENSE](LICENSE) file for details.

## 🙏 Credits

- **Author**: rcnrqvet
- **Framework**: [QBCore](https://github.com/qbcore-framework)
- **Inspired by**: Real life Apple AirTag


**Made with ❤️ for the FiveM community**

*If you use this script, a star ⭐ on GitHub would be greatly appreciated!*
