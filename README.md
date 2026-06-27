<div align="center">
  <img src="icon.png" width="128" height="128" alt="WAVE App Icon" />
  <h1>WAVE</h1>
  <p>A fast, cross-platform music streaming app built with Flutter.</p>
  <p><strong>Latest release:</strong> <a href="https://github.com/killamfkr/WAVE/releases/latest">v1.1.1</a></p>
</div>

---

## Overview

WAVE is a modern music client for streaming, library management, and personalized listening. It resolves Deezer metadata and plays audio via a high-quality pipeline, with offline downloads, synced lyrics, visual themes, and cloud backup for your library.

## Features

- **High Quality Streaming**: Fast track loading with direct streaming, proactive URL refresh, and resilient playback recovery.
- **Personal DJ**: Spotify-style personalized mixes built from your likes, recent plays, and similar tracks — with mood controls (Mixed, Chill, Hype, Discover) and spoken on-screen DJ commentary.
- **Autoplay Similar**: When a playlist or album ends, WAVE keeps going with similar music. Toggle AUTO from Now Playing or Settings → Playback.
- **Repeat Modes**: Off, repeat all, or repeat one.
- **Audio Focus**: Pauses automatically when another app takes audio focus or headphones are unplugged.
- **Cloud Sync**: Sign in with email/password (Supabase, shared with PlayTorrio/Stories) to sync playlists, liked songs, equalizer settings, and library data across devices.
- **Local Profile**: Set a display name and avatar in Settings; syncs to the cloud when signed in.
- **Android Auto**: Browse and play your library from Android Auto.
- **Visual Themes**: Aurora, Brutalist, Minimal Mono, Neon Grid, Obsidian, and Vapor — each with distinct layout and motion.
- **Synced Lyrics**: In-app synced lyrics from multiple provider backends.
- **Queue Management**: Full control over upcoming, current, and historical tracks, including drag-to-reorder.
- **Downloads**: Save tracks locally for offline playback.
- **Playlists & Library**: Create, import, and export playlists. Follow artists and track recently played music.
- **Recommendation Engine**: Discover tracks and artists based on your library, likes, and playback history (Last.fm + Deezer).
- **Crossfade & Equalizer**: Gapless playback with customizable crossfade; 5-band EQ synced to the cloud.

## Screenshots

<div align="center">
  <h3>Homescreen</h3>
  <img src="homescreenshot.png" width="600" alt="Homescreen" />
  
  <h3>Now Playing</h3>
  <img src="playingscreenshot.png" width="600" alt="Now Playing Screen" />
  
  <h3>Settings</h3>
  <img src="settingsscreenshot.png" width="600" alt="Settings Screen" />
</div>

## Recent Updates

| Version | Highlights |
|---------|------------|
| **1.1.1** | Personal DJ voice — spoken commentary with music ducking |
| **1.1.0** | Personal DJ — personalized mixes, mood controls, and liner commentary |
| **1.0.9** | Pause when another app takes audio focus |
| **1.0.8** | Playback stability — fixes CD-skip stutter during long sessions |
| **1.0.7** | Autoplay similar when queue ends + AUTO toggle |
| **1.0.6** | Cloud sync for liked songs and equalizer settings |
| **1.0.5** | Playback recovery, repeat-all/one fixes, stream URL refresh |
| **1.0.4** | Cloud login works out of the box (built-in Supabase defaults) |
| **1.0.3** | Local profile, cloud sync, Android Auto, update source → `killamfkr/WAVE` |

[View all releases](https://github.com/killamfkr/WAVE/releases)

## Technical Stack

- **Framework**: Flutter (Dart)
- **Audio Engine**: MediaKit (libmpv) + audio_service
- **State Management**: Riverpod
- **Local Storage**: Hive
- **Cloud Sync**: Supabase
- **Metadata**: Deezer API, Last.fm

## Downloads

Android APKs are attached to each [GitHub Release](https://github.com/killamfkr/WAVE/releases):

- **Most phones** → `WAVE-arm64-v8a-release.apk`
- **Older 32-bit devices** → `WAVE-armeabi-v7a-release.apk`
- **Emulators / x86 tablets** → `WAVE-x86_64-release.apk`
