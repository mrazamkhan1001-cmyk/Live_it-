package com.example.liveitbyazam.model

import com.example.liveitbyazam.sharingan.SharinganPattern

data class Song(
    val id: String,
    val title: String,
    val artist: String,
    val album: String,
    val durationMs: Long,
    val mediaUri: String,
    val coverArtUrl: String? = null,
    val lyrics: String? = null,
    val isFavorite: Boolean = false,
    val genre: String = "Anime / Dark Synth",
    val sharinganPattern: SharinganPattern = SharinganPattern.THREE_TOMOE,
    val isDownloaded: Boolean = true
) {
    fun formattedDuration(): String {
        val seconds = (durationMs / 1000) % 60
        val minutes = (durationMs / (1000 * 60)) % 60
        return String.format("%d:%02d", minutes, seconds)
    }
}

data class Playlist(
    val id: String,
    val name: String,
    val description: String = "",
    val songs: List<Song> = emptyList(),
    val coverArtUrl: String? = null
)

data class Artist(
    val id: String,
    val name: String,
    val imageUrl: String? = null,
    val songCount: Int = 0,
    val bio: String = ""
)

data class UserProfile(
    val rawName: String = "Azam",
    val email: String = "azam@liveit.uchiha",
    val playlistsCount: Int = 12,
    val favoriteSongsCount: Int = 48,
    val listeningMinutes: Int = 1420,
    val profilePicUrl: String? = null
) {
    // Universal Uchiha Identity System
    val uchihaDisplayName: String
        get() {
            val trimmed = rawName.trim()
            if (trimmed.lowercase().endsWith("uchiha")) {
                val words = trimmed.split(" ")
                val base = words.dropLast(1).joinToString(" ").ifEmpty { words.first() }
                return "$base Uchiha"
            }
            return "$trimmed Uchiha"
        }
}

data class EqualizerSettings(
    val preset: String = "Normal",
    val band60Hz: Float = 0f,   // -10dB to +10dB
    val band230Hz: Float = 0f,
    val band910Hz: Float = 0f,
    val band3k6Hz: Float = 0f,
    val band14kHz: Float = 0f
)

data class AppSettings(
    val isRedTheme: Boolean = true,
    val animationIntensity: Float = 1.0f,
    val sharinganSpeed: Float = 1.0f,
    val glowIntensity: Float = 1.0f,
    val musicReactiveMode: Boolean = true,
    val audioQuality: String = "High (320kbps)",
    val gaplessPlayback: Boolean = true,
    val crossfadeSeconds: Int = 3,
    val wifiOnlyDownloads: Boolean = true
)
