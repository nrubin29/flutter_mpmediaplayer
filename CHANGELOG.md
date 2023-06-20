## 0.3.0

* Added `albumArtist` field to `Song` and `PlayedSong`.
* Updated to Flutter 3.10
* **BREAKING**: Removed unnamed constructors from model classes. These were never used in internal code and should never
  have been used in external code.

## 0.2.0

**BREAKING**: `getRecentTracks()` is now a paged request.

## 0.1.2

Fixed `PlayedSong` missing `playbackDuration` and `artwork`.

## 0.1.1

Updated image sizes.

## 0.1.0

Added methods for searching and getting detailed entities.

## 0.0.2

* Added `authorizationStatus` getter.

## 0.0.1

* Initial release with support for fetching recent tracks.
