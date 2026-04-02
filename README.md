# fetch_and_embed.sh

A simple bash script that automatically fetches synced lyrics for your music files and embeds them directly into the audio tags.

## Dependencies

- **syncedlyrics** — fetches lyrics from multiple providers ([github.com/moehmeni/syncedlyrics](https://github.com/moehmeni/syncedlyrics))
- **kid3-cli** — embeds lyrics into audio file tags

Install syncedlyrics with:
```bash
pip install syncedlyrics --break-system-packages
```

## How it works

1. Scans the folder it lives in (and all subfolders) for MP3 and FLAC files
2. Skips any song that already has a `.lrc` file next to it
3. Reads the song's `TITLE` and `ARTIST` tags to build a search query
4. Tries to fetch **synced lyrics** (LRC format with timestamps) first
5. If no synced lyrics are found, falls back to **plain unsynced lyrics**
6. Saves the lyrics as a `.lrc` file next to the audio file
7. Embeds the lyrics into the audio file's `LYRICS` tag using kid3-cli
8. Prints a summary of how many songs were embedded, skipped, or failed

## Usage

Drop `fetch_and_embed.sh` into any music folder and run:

```bash
chmod +x fetch_and_embed.sh
bash fetch_and_embed.sh
```

To save a log of the results:

```bash
bash fetch_and_embed.sh | tee lyrics_results.log
```

## Notes

- Songs with missing or incorrect `TITLE`/`ARTIST` tags will be skipped — fix tags with MusicBrainz Picard first for best results
- The `.lrc` sidecar files are kept alongside the audio files so players like Lollypop can read them directly for scrolling synced lyrics
- Supports MP3 and FLAC files
