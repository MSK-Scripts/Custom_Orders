# msk_vehicleregistration
Simple Vehicleregistration Script

## Description
* Register your own vehicle at the Registration Office (Zulassungsstelle)
* You can implement the exports to lookup if the vehicle is registered or not
* Database changes are made automatically *(new column in owned_vehicles: registration)*

## Exports
You can use this exports **clientside** and **serverside**
```lua
local isRegistered = exports.msk_vehicleregistration:getRegistration(plate)
exports.msk_vehicleregistration:addRegistration(plate)
exports.msk_vehicleregistration:removeRegistration(plate)
```

**clientside ONLY**
```lua
exports.msk_vehicleregistration:changePlate(vehicle, oldPlate, newPlate)
```

## Requirements
* ESX 1.2 or higher
* oxmysql
* msk_core