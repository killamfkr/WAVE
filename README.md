<div align="center">
  <img src="icon.png" width="128" height="128" alt="WAVE App Icon" />
  <h1>WAVE</h1>
  <p>A fast and high performance music streaming application built using Flutter.</p>
</div>

---

## Overview

WAVE is a modern, responsive music client designed for seamless streaming and local library management. It offers high quality audio playback, crossfade transitions, offline caching, and customizable visual themes.

## Features

- **High Quality Streaming**: Fast track loading and streaming using a proxy compatible audio pipeline.
- **Visual Themes**: Multiple visual modes including Aurora, Brutalist, Minimal, Neon, Obsidian, and Vapor.
- **Synced Lyrics**: In app synced lyrics display retrieved from multiple provider backends.
- **Queue Management**: Full control over upcoming, current, and historical queue tracks, including reordering via drag handles.
- **Downloads**: Download and store tracks locally to play them offline.
- **Playlists & Library**: Create, import, and export playlists locally or from the clipboard. Follow artists and track your recently played songs.
- **Recommendation Engine**: Discover new tracks and artists based on your library and playback history.
- **Crossfade**: Gapless playback with customizable crossfade transitions between tracks.

## Screenshots

<div align="center">
  <h3>Homescreen</h3>
  <img src="homescreenshot.png" width="600" alt="Homescreen" />
  
  <h3>Now Playing</h3>
  <img src="playingscreenshot.png" width="600" alt="Now Playing Screen" />
  
  <h3>Settings</h3>
  <img src="settingsscreenshot.png" width="600" alt="Settings Screen" />
</div>

## Technical Stack

- **Framework**: Flutter (Dart)
- **Audio Engine**: MediaKit
- **State Management**: Riverpod
- **Local Storage**: Hive
