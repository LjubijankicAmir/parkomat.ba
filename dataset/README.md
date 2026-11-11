# Parking data

Each city has a folder of hand-written YAML. A build script joins it with [OpenStreetMap](https://www.openstreetmap.org) and writes the file the app bundles, `assets/data/<city>.json`.

```
dataset/sarajevo/
├── city.yaml     # Name, operator, map area, default camera, holidays
├── zones.yaml    # Paid zones: SMS number, prices, paid hours, streets
├── places.yaml   # Garages and lots with prices and hours OSM doesn't have
└── REPORT.md     # Written by the build: what's unresolved or unverified
```

## Updating the data

1. Edit the YAML. Every value needs a source in `sources`. Leave `verifiedAt` as `null` until someone has checked the value on the street, then set it to that day's date.
2. Rebuild:

   ```bash
   dart run tool/build_dataset.dart sarajevo
   ```

3. Read `REPORT.md` and commit the YAML, `REPORT.md` and `assets/data/sarajevo.json` together.

The build stops and lists every problem if the YAML breaks a rule, such as an SMS number that isn't 7 digits or a lot without a `near` anchor.

## How zones are drawn

A zone lists its stretches as they appear in the operator's official list.

- **Streets** are drawn over the OpenStreetMap ways with the same name. Use `osmName` when OpenStreetMap spells a street differently.
- **Part of a long street** needs a `near` point and radius, so that only the ways around it are drawn. A street longer than 800 m without one isn't drawn, because the paid part is unknown. The report lists it.
- **Lots** (ramp-controlled) are matched to the closest OpenStreetMap parking area around `near`.

Every other public `amenity=parking` in the city's area is added from OpenStreetMap as it is. Private ones are left out.

## License

This data is made available under the [Open Database License](https://opendatacommons.org/licenses/odbl/1-0/). It contains information from OpenStreetMap, © OpenStreetMap contributors.
