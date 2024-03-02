# Police Vehicle Modification System for QBCore/QBX

This resource enables a comprehensive vehicle modification system for FiveM servers running the QBCore framework, specifically tailored for emergency vehicles. Players with the 'police' job can automatically enhance their vehicle's performance mods to level 4 upon accessing the modification menu and further customize their vehicles with skins and extras.

## Requirements

- [QBCore Framework](https://github.com/qbcore-framework)
- [OX MySQL](https://github.com/overextended/oxmysql) for database operations
- [OX Lib](https://github.com/overextended/ox_lib) for UI components

## Features

- Automatic performance modifications to level 4 for emergency vehicles
- Dynamic menu generation for selecting vehicle skins and toggling extras
- Persistence of vehicle modifications using QBCore's database structure
- Seamless integration with QBCore's job system for role-restricted access

## Installation

1. **Clone or Download**: Clone this repository or download it as a ZIP file and extract it into your server's `resources` directory.
   
   ```bash
   git clone https://github.com/yourgithubusername/police-vehicle-modification-system.git

## Configuration

### Configure the Resource
Place the extracted folder into your `resources/[qb]` directory. Ensure you rename the folder to `police-vehicle-modification-system` if it is not already named as such.

### Database Setup
Extend your `owned_vehicles` table in QBCore's database with additional columns for vehicle modifications (e.g., `vehicle_color`, `vehicle_livery`, `custom_mod`). Use the provided SQL statements to make these adjustments.

```sql
ALTER TABLE `owned_vehicles`
ADD COLUMN `vehicle_color` VARCHAR(255) NULL AFTER `plate`,
ADD COLUMN `vehicle_livery` INT(11) NULL AFTER `vehicle_color`,
ADD COLUMN `custom_mod` TEXT NULL AFTER `vehicle_livery`;
```
### Resource Registration
Add the following line to your `server.cfg` file to ensure the resource is started with your server: 

# ensure vehicle-mod-menu

## Usage

Players with the 'police' job can use the `/modvehicle` command while inside an emergency vehicle to access the modification menu. Performance modifications are applied automatically, and further customizations can be made through the menu.

## Support

For issues, suggestions, or contributions, please use GitHub issues and pull requests. Community support is available through the QBCore and OX libraries' official Discord channels.





