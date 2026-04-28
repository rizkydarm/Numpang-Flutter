---
name: mapbox-geocoding-api
description: Use this skill when implementing geocoding by mapbox api
---
# Mapbox Geocoding API – Agent Skill

## Overview
This skill enables an AI agent to convert location descriptions (addresses, place names, coordinates) into structured geographic data using Mapbox Geocoding API v6. It supports forward geocoding (text → coordinates), reverse geocoding (coordinates → address), structured input, and batch processing. Use it whenever a user asks to find a place, resolve an address, or look up a location.

---

## Base Information
- **Base URL**: `https://api.mapbox.com/search/geocode/v6`
- **Authentication**: Pass `access_token` as query parameter (Mapbox secret token).
- **Rate limit**: 1000 requests/min (adjustable; 429 if exceeded).
- **Billing**: Per request. Each keystroke in autocomplete mode counts as a separate request.
- **Response format**: GeoJSON FeatureCollection (default). Alternative `format=v5` available.

---

## Endpoints & Parameters

### 1. Forward Geocoding (Text)
`GET /forward?q={search_text}`

**Required**
- `q`: URL‑encoded search text (max 256 chars, ≤20 words). Must not contain `;`.

**Optional**
- `permanent` (boolean) – `true` to store results (requires billing setup).
- `autocomplete` (boolean) – `true` (default) returns partial matches. For exact match, set `false`.
- `country` – ISO 3166‑1 alpha‑2 code(s), comma separated. Hard filter.
- `types` – one or more feature types: `country, region, postcode, district, place, locality, neighborhood, street, address`. Comma separated.
- `limit` – max results (1‑10, default 5).
- `bbox` – `minLon,minLat,maxLon,maxLat`.
- `proximity` – `longitude,latitude` or `ip` for bias.
- `language` – IETF tag(s), e.g. `en`, `de`. First takes priority.
- `worldview` – `us` (default), `cn`, `ru`, etc.
- `entrances` (boolean, beta) – include building entrance points.

### 2. Forward Geocoding (Structured Input)
`GET /forward?address_number={number}&street={name}&...`

No `q` parameter. Instead, provide individual components:
- `address_number`, `street`, `address_line1` (combined number+street)
- `block`, `place`, `locality`, `neighborhood`, `region`, `postcode`, `country` (ISO code or full name; ISO filters, name influences)

All other optional parameters identical to text search. Set `autocomplete=false` for best results.

### 3. Reverse Geocoding
`GET /reverse?longitude={lon}&latitude={lat}`

**Required**
- `longitude`, `latitude` (decimal degrees)

**Optional**
- `permanent`, `country`, `language`, `limit` (1–5, default 1; if >1, must specify exactly one `types`), `types`, `worldview`

### 4. Batch Geocoding
`POST /batch` (JSON body)

Array of up to 1000 query objects. Each object can be forward, structured, or reverse. Optional `permanent` in query string. Each sub‑query billed separately.

---

## Address Formatting Rules (Critical)
When constructing `q` or structured inputs, follow these rules exactly:

1. **Encode**: Always URL‑encode the search string. Example: `123 Main St` → `123%20Main%20St`. No raw semicolon.
2. **Single building number**: `123 Main St`, never `123-127 Main St`.
3. **US address format** (recommended): `{house number} {street} {city} {state} {zip}`  
   Example: `123 Main St Boston MA 02111`
4. **Non‑US**: Use local convention or the more‑granular‑to‑less order: `{house number} {street} {postcode} {city} {state}`. Example (UK): `123 Main St Swindon SN2 2DQ`.
5. **Country**: Use the `country` parameter (ISO code) instead of including the country name in `q`.  
   ✅ `?q=123%20Main%20St%20Boston%20MA&country=US`  
   ❌ `?q=123%20Main%20St%20Boston%20MA%20United%20States`
6. **Zip codes**: US 5‑digit (`02919`) or 9‑digit (`02919-3232`) both work.
7. **Secondary address**: If searching for unit/suite, append `#456` or `Suite 7` to the street address. Ensure `types` includes `secondary_address` (enabled by default unless explicitly filtered out).

---

## Interpreting the Response
Responses contain a `features` array (GeoJSON). Each feature includes:
- `geometry.coordinates` – `[lon, lat]`
- `properties.feature_type` – type of result (address, street, place, etc.)
- `properties.name` – main name
- `properties.place_formatted` – formatted region string
- `properties.full_address` – combined name + place_formatted
- `properties.context` – hierarchy of parent features (address, street, postcode, place, region, country, etc.) each with `mapbox_id` and `name`
- `properties.coordinates.accuracy` – `rooftop`, `parcel`, `point`, `interpolated`, `approximate`, `intersection`
- `properties.match_code` (for forward address queries) – how well each component matched (`matched`, `unmatched`, `inferred`, `plausible`) and overall confidence (`exact`, `high`, `medium`, `low`)

For reverse geocoding, features are ordered from most specific (address) to least specific (country). Use `context` to extract clean components.

---

## Special Features
### Intersection Search
Use connectors `and`, `&`, `x`, or `e` between two street names. Example: `Market%20Street%20and%20Fremont%20Street`. Returns feature with `feature_type: street` and `accuracy: intersection`.

### Smart Address Match (v6)
When using structured input, the `match_code` object helps validate input quality. Use `confidence` to decide whether to accept the result. For example, only keep results with confidence `exact` or `high` if you need strict matching.

### Japan Geocoding
Set `language=ja` and `country=jp`. Responses include `block`, `neighborhood` (chome), etc. A `reading` object gives Kana and Latin transliterations.

### Worldviews
Affects disputed territories. Default is `us`. Other values: `cn`, `ru`, `in`, `jp`, etc. Combine carefully with `country` filter; they may conflict.

---

## Error Handling
- **401** – Missing/invalid token.
- **403** – Account issue or URL‑restricted token.
- **404** – Wrong endpoint or missing search text.
- **422** – Validation error (check `bbox`, `types`, `language`, `proximity`, length limits). Message includes details.
- **429** – Rate limit. Retry after a delay.

Common mistakes:
- Unencoded spaces or special characters in `q`.
- Including country in `q` instead of `country` parameter.
- Using a range of building numbers.
- Exceeding 256 characters or 20 words.

---

## Examples for Agent Execution

**Simple forward geocode**
```
GET /forward?q=1600%20Pennsylvania%20Ave%20NW&country=US&limit=1
```

**Structured input (best for known components)**
```
GET /forward?address_number=1600&street=Pennsylvania%20Ave%20NW&postcode=20500&place=Washington&region=DC&country=us&autocomplete=false
```

**Reverse geocode**
```
GET /reverse?longitude=-77.03655&latitude=38.89768&types=address
```

**Batch**
```json
POST /batch
[
  {"q": "1600 Pennsylvania Ave NW", "country": "us", "limit": 1},
  {"longitude": -73.986, "latitude": 40.748, "types": "address"}
]
```

**Intersection**
```
GET /forward?q=Market%20Street%20and%20Fremont%20Street&proximity=-122.4,37.79
```

---

## Caching & Storage
- **Temporary** (default): Do not cache responses. Use for ephemeral lookups.
- **Permanent**: Set `permanent=true`. Results may be stored indefinitely. Requires valid billing.

---

When in doubt, prefer structured input with explicit component typing for highest accuracy and match confidence. Always set `autocomplete=false` for complete queries, and use the `country` parameter for filtering.
