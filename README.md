# pb-vehiclekeys | for QBCore or QBXCore | with ox_lib | can be converted to ESX easily

## Config
```
Config.UnloadEvent = 'QBCore:Client:OnPlayerUnload' -> Event trigged on player unload (default qb-core and qbx-core)

Config.LoadEvent = 'QBCore:Client:OnPlayerLoaded' -> Event trigged on player load (default qb-core and qbx-core)
```
## Exports

```
GiveKeys(plate, id) -> Give keys to vehicle of the plate to the player with the id (if id is nil then add to yourself)

HaveKeys(plate) -> Check if client have the key for vehicle with the plate

RemoveAllKeys -> Clean all client keys

GetAllCSNKeys -> Give back all keys that player character had in past

GetVehicleKeysNearby -> Get keys from nearby vehicle

Lockpicking -> Do animation of lockpick and GetVehicleKeysNearby
```

### Requirements

- [baseevents](https://github.com/xaviablaza/fivem-playground/tree/master/cfx-server-data/resources/%5Bsystem%5D/baseevents)

* [ox_lib](https://github.com/overextended/ox_lib)
