package com.example.liveitbyazam.player

import android.content.Context
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.example.liveitbyazam.data.LocalMusicScanner
import com.example.liveitbyazam.data.MockMusicRepository
import com.example.liveitbyazam.model.*
import com.example.liveitbyazam.sharingan.SharinganPattern
import kotlinx.coroutines.Job
import kotlinx.coroutines.delay
import kotlinx.coroutines.flow.*
import kotlinx.coroutines.launch
import kotlin.math.sin
import kotlin.random.Random

enum class NavDestination {
    SPLASH,
    ONBOARDING,
    AUTH,
    HOME,
    SEARCH,
    LIBRARY,
    PROFILE,
    NOW_PLAYING,
    PLAYER_DETAILS,
    LYRICS,
    QUEUE,
    EQUALIZER,
    SETTINGS,
    FAVORITES,
    PLAYLIST_DETAIL
}

class PlayerManager : ViewModel() {

    // Navigation State
    private val _currentDestination = MutableStateFlow(NavDestination.SPLASH)
    val currentDestination: StateFlow<NavDestination> = _currentDestination.asStateFlow()

    // Selected Playlist for Detail View
    private val _selectedPlaylist = MutableStateFlow<Playlist?>(null)
    val selectedPlaylist: StateFlow<Playlist?> = _selectedPlaylist.asStateFlow()

    // Navigation History for Back Press
    private val navigationHistory = mutableListOf<NavDestination>()

    // Songs & Queue
    private val _allSongs = MutableStateFlow<List<Song>>(MockMusicRepository.sampleSongs)
    val allSongs: StateFlow<List<Song>> = _allSongs.asStateFlow()

    private val _playlists = MutableStateFlow<List<Playlist>>(MockMusicRepository.samplePlaylists)
    val playlists: StateFlow<List<Playlist>> = _playlists.asStateFlow()

    private val _artists = MutableStateFlow<List<Artist>>(MockMusicRepository.sampleArtists)
    val artists: StateFlow<List<Artist>> = _artists.asStateFlow()

    private val _currentSong = MutableStateFlow<Song?>(MockMusicRepository.sampleSongs.first())
    val currentSong: StateFlow<Song?> = _currentSong.asStateFlow()

    private val _queue = MutableStateFlow<List<Song>>(MockMusicRepository.sampleSongs)
    val queue: StateFlow<List<Song>> = _queue.asStateFlow()

    private val _queueIndex = MutableStateFlow(0)
    val queueIndex: StateFlow<Int> = _queueIndex.asStateFlow()

    // Playback State
    private val _isPlaying = MutableStateFlow(false)
    val isPlaying: StateFlow<Boolean> = _isPlaying.asStateFlow()

    private val _playbackPositionMs = MutableStateFlow(0L)
    val playbackPositionMs: StateFlow<Long> = _playbackPositionMs.asStateFlow()

    private val _isShuffle = MutableStateFlow(false)
    val isShuffle: StateFlow<Boolean> = _isShuffle.asStateFlow()

    private val _isRepeat = MutableStateFlow(false)
    val isRepeat: StateFlow<Boolean> = _isRepeat.asStateFlow()

    // Beat Reactivity scale (0.0 to 1.0)
    private val _beatPulse = MutableStateFlow(0f)
    val beatPulse: StateFlow<Float> = _beatPulse.asStateFlow()

    // User Identity
    private val _userProfile = MutableStateFlow(UserProfile(rawName = "Azam"))
    val userProfile: StateFlow<UserProfile> = _userProfile.asStateFlow()

    // Settings & Equalizer
    private val _equalizerSettings = MutableStateFlow(EqualizerSettings())
    val equalizerSettings: StateFlow<EqualizerSettings> = _equalizerSettings.asStateFlow()

    private val _appSettings = MutableStateFlow(AppSettings())
    val appSettings: StateFlow<AppSettings> = _appSettings.asStateFlow()

    // Search Query
    private val _searchQuery = MutableStateFlow("")
    val searchQuery: StateFlow<String> = _searchQuery.asStateFlow()

    private val _selectedSearchCategory = MutableStateFlow("All")
    val selectedSearchCategory: StateFlow<String> = _selectedSearchCategory.asStateFlow()

    // Playback Progress Ticker Job
    private var playbackJob: Job? = null
    private var beatJob: Job? = null

    init {
        startBeatSimulator()
    }

    fun navigateTo(destination: NavDestination, addToHistory: Boolean = true) {
        if (addToHistory && _currentDestination.value != destination) {
            navigationHistory.add(_currentDestination.value)
        }
        _currentDestination.value = destination
    }

    fun navigateBack(): Boolean {
        if (navigationHistory.isNotEmpty()) {
            val prev = navigationHistory.removeAt(navigationHistory.size - 1)
            _currentDestination.value = prev
            return true
        }
        if (_currentDestination.value != NavDestination.HOME) {
            _currentDestination.value = NavDestination.HOME
            return true
        }
        return false
    }

    fun updateUserName(name: String) {
        if (name.isBlank()) return
        _userProfile.value = _userProfile.value.copy(rawName = name.trim())
    }

    fun playSong(song: Song, newQueue: List<Song> = _allSongs.value) {
        _queue.value = newQueue
        val index = newQueue.indexOfFirst { it.id == song.id }.coerceAtLeast(0)
        _queueIndex.value = index
        _currentSong.value = song
        _playbackPositionMs.value = 0L
        _isPlaying.value = true
        startPlaybackTicker()
    }

    fun togglePlayPause() {
        _isPlaying.value = !_isPlaying.value
        if (_isPlaying.value) {
            startPlaybackTicker()
        } else {
            playbackJob?.cancel()
        }
    }

    fun nextSong() {
        if (_queue.value.isEmpty()) return
        var nextIdx = _queueIndex.value + 1
        if (nextIdx >= _queue.value.size) {
            nextIdx = 0
        }
        _queueIndex.value = nextIdx
        _currentSong.value = _queue.value[nextIdx]
        _playbackPositionMs.value = 0L
        _isPlaying.value = true
        startPlaybackTicker()
    }

    fun previousSong() {
        if (_queue.value.isEmpty()) return
        var prevIdx = _queueIndex.value - 1
        if (prevIdx < 0) {
            prevIdx = _queue.value.size - 1
        }
        _queueIndex.value = prevIdx
        _currentSong.value = _queue.value[prevIdx]
        _playbackPositionMs.value = 0L
        _isPlaying.value = true
        startPlaybackTicker()
    }

    fun seekTo(positionMs: Long) {
        _playbackPositionMs.value = positionMs
    }

    fun toggleFavorite(songId: String) {
        _allSongs.value = _allSongs.value.map { song ->
            if (song.id == songId) song.copy(isFavorite = !song.isFavorite) else song
        }
        _queue.value = _queue.value.map { song ->
            if (song.id == songId) song.copy(isFavorite = !song.isFavorite) else song
        }
        if (_currentSong.value?.id == songId) {
            _currentSong.value = _currentSong.value?.let { it.copy(isFavorite = !it.isFavorite) }
        }
    }

    fun toggleShuffle() {
        _isShuffle.value = !_isShuffle.value
    }

    fun toggleRepeat() {
        _isRepeat.value = !_isRepeat.value
    }

    fun updateSharinganPattern(pattern: SharinganPattern) {
        _currentSong.value = _currentSong.value?.copy(sharinganPattern = pattern)
    }

    fun updateSearchQuery(query: String) {
        _searchQuery.value = query
    }

    fun setSearchCategory(category: String) {
        _selectedSearchCategory.value = category
    }

    fun openPlaylist(playlist: Playlist) {
        _selectedPlaylist.value = playlist
        navigateTo(NavDestination.PLAYLIST_DETAIL)
    }

    fun createPlaylist(name: String, description: String = "") {
        val newPlaylist = Playlist(
            id = "user_p_${System.currentTimeMillis()}",
            name = name,
            description = description,
            songs = emptyList()
        )
        _playlists.value = _playlists.value + newPlaylist
    }

    fun addSongToPlaylist(playlistId: String, song: Song) {
        _playlists.value = _playlists.value.map { playlist ->
            if (playlist.id == playlistId) {
                if (playlist.songs.any { it.id == song.id }) playlist
                else playlist.copy(songs = playlist.songs + song)
            } else playlist
        }
    }

    fun updateEqualizerPreset(preset: String) {
        val newSettings = when (preset) {
            "Rock" -> EqualizerSettings(preset = preset, band60Hz = 4f, band230Hz = 2f, band910Hz = -1f, band3k6Hz = 3f, band14kHz = 5f)
            "Pop" -> EqualizerSettings(preset = preset, band60Hz = -1f, band230Hz = 2f, band910Hz = 4f, band3k6Hz = 2f, band14kHz = -1f)
            "Hip Hop" -> EqualizerSettings(preset = preset, band60Hz = 6f, band230Hz = 4f, band910Hz = 1f, band3k6Hz = 2f, band14kHz = 3f)
            "Bass Boost" -> EqualizerSettings(preset = preset, band60Hz = 8f, band230Hz = 6f, band910Hz = 1f, band3k6Hz = 0f, band14kHz = 0f)
            "Classical" -> EqualizerSettings(preset = preset, band60Hz = 3f, band230Hz = 2f, band910Hz = 0f, band3k6Hz = 2f, band14kHz = 4f)
            "Vocal" -> EqualizerSettings(preset = preset, band60Hz = -2f, band230Hz = 0f, band910Hz = 5f, band3k6Hz = 4f, band14kHz = 1f)
            else -> EqualizerSettings(preset = "Normal")
        }
        _equalizerSettings.value = newSettings
    }

    fun updateEqualizerBand(bandIndex: Int, value: Float) {
        val current = _equalizerSettings.value
        val updated = when (bandIndex) {
            0 -> current.copy(preset = "Custom", band60Hz = value)
            1 -> current.copy(preset = "Custom", band230Hz = value)
            2 -> current.copy(preset = "Custom", band910Hz = value)
            3 -> current.copy(preset = "Custom", band3k6Hz = value)
            4 -> current.copy(preset = "Custom", band14kHz = value)
            else -> current
        }
        _equalizerSettings.value = updated
    }

    fun updateAppSettings(settings: AppSettings) {
        _appSettings.value = settings
    }

    fun scanLocalDeviceAudio(context: Context) {
        viewModelScope.launch {
            val localSongs = LocalMusicScanner.scanLocalAudioFiles(context)
            if (localSongs.isNotEmpty()) {
                val combined = (_allSongs.value + localSongs).distinctBy { it.id }
                _allSongs.value = combined
            }
        }
    }

    private fun startPlaybackTicker() {
        playbackJob?.cancel()
        playbackJob = viewModelScope.launch {
            while (_isPlaying.value) {
                delay(1000)
                val current = _playbackPositionMs.value + 1000
                val total = _currentSong.value?.durationMs ?: 180000L
                if (current >= total) {
                    if (_isRepeat.value) {
                        _playbackPositionMs.value = 0L
                    } else {
                        nextSong()
                    }
                } else {
                    _playbackPositionMs.value = current
                }
            }
        }
    }

    private fun startBeatSimulator() {
        beatJob?.cancel()
        beatJob = viewModelScope.launch {
            var phase = 0f
            while (true) {
                delay(100)
                if (_isPlaying.value && _appSettings.value.musicReactiveMode) {
                    phase += 0.4f
                    val rawPulse = (sin(phase) + 1f) / 2f
                    val beatVal = if (Random.nextFloat() > 0.75f) rawPulse.coerceAtLeast(0.85f) else rawPulse * 0.4f
                    _beatPulse.value = beatVal
                } else {
                    _beatPulse.value = 0f
                }
            }
        }
    }
}
