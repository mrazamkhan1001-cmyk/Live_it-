package com.example.liveitbyazam

import android.Manifest
import android.content.pm.PackageManager
import android.os.Build
import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.BackHandler
import androidx.activity.compose.rememberLauncherForActivityResult
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.activity.result.contract.ActivityResultContracts
import androidx.activity.viewModels
import androidx.compose.animation.Crossfade
import androidx.compose.animation.core.tween
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.material3.SnackbarHostState
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.core.content.ContextCompat
import com.example.liveitbyazam.player.NavDestination
import com.example.liveitbyazam.player.PlayerManager
import com.example.liveitbyazam.ui.components.BottomNavBar
import com.example.liveitbyazam.ui.components.MiniPlayer
import com.example.liveitbyazam.ui.screens.*
import com.example.liveitbyazam.ui.theme.LiveItTheme
import com.example.liveitbyazam.ui.theme.PrimaryBackground

class MainActivity : ComponentActivity() {

    private val playerViewModel: PlayerManager by viewModels()

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()

        setContent {
            LiveItTheme {
                val context = LocalContext.current

                // Collect state from ViewModel
                val currentDestination by playerViewModel.currentDestination.collectAsState()
                val userProfile by playerViewModel.userProfile.collectAsState()
                val currentSong by playerViewModel.currentSong.collectAsState()
                val isPlaying by playerViewModel.isPlaying.collectAsState()
                val playbackPositionMs by playerViewModel.playbackPositionMs.collectAsState()
                val allSongs by playerViewModel.allSongs.collectAsState()
                val playlists by playerViewModel.playlists.collectAsState()
                val selectedPlaylist by playerViewModel.selectedPlaylist.collectAsState()
                val artists by playerViewModel.artists.collectAsState()
                val queue by playerViewModel.queue.collectAsState()
                val queueIndex by playerViewModel.queueIndex.collectAsState()
                val isShuffle by playerViewModel.isShuffle.collectAsState()
                val isRepeat by playerViewModel.isRepeat.collectAsState()
                val beatPulse by playerViewModel.beatPulse.collectAsState()
                val equalizerSettings by playerViewModel.equalizerSettings.collectAsState()
                val appSettings by playerViewModel.appSettings.collectAsState()
                val searchQuery by playerViewModel.searchQuery.collectAsState()
                val selectedSearchCategory by playerViewModel.selectedSearchCategory.collectAsState()

                // Permission Launcher for Local Media scanning
                val permissionLauncher = rememberLauncherForActivityResult(
                    contract = ActivityResultContracts.RequestPermission()
                ) { isGranted ->
                    if (isGranted) {
                        playerViewModel.scanLocalDeviceAudio(context)
                    }
                }

                LaunchedEffect(Unit) {
                    val permission = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                        Manifest.permission.READ_MEDIA_AUDIO
                    } else {
                        Manifest.permission.READ_EXTERNAL_STORAGE
                    }
                    if (ContextCompat.checkSelfPermission(context, permission) == PackageManager.PERMISSION_GRANTED) {
                        playerViewModel.scanLocalDeviceAudio(context)
                    } else {
                        permissionLauncher.launch(permission)
                    }
                }

                // Custom Back Handler
                BackHandler(enabled = currentDestination != NavDestination.HOME && currentDestination != NavDestination.SPLASH) {
                    playerViewModel.navigateBack()
                }

                val showBottomBarAndMiniPlayer = currentDestination in listOf(
                    NavDestination.HOME,
                    NavDestination.SEARCH,
                    NavDestination.LIBRARY,
                    NavDestination.PROFILE,
                    NavDestination.FAVORITES,
                    NavDestination.PLAYLIST_DETAIL
                )

                Box(
                    modifier = Modifier
                        .fillMaxSize()
                        .background(PrimaryBackground)
                ) {
                    // Main Screen Crossfade Navigation
                    Crossfade(
                        targetState = currentDestination,
                        animationSpec = tween(350),
                        label = "screen_navigation"
                    ) { destination ->
                        when (destination) {
                            NavDestination.SPLASH -> {
                                SplashScreen(
                                    onSplashFinished = {
                                        playerViewModel.navigateTo(NavDestination.ONBOARDING, addToHistory = false)
                                    }
                                )
                            }
                            NavDestination.ONBOARDING -> {
                                OnboardingScreen(
                                    onFinishOnboarding = {
                                        playerViewModel.navigateTo(NavDestination.AUTH, addToHistory = false)
                                    }
                                )
                            }
                            NavDestination.AUTH -> {
                                AuthScreen(
                                    onAuthSuccess = { uchihaName ->
                                        playerViewModel.updateUserName(uchihaName.replace(" Uchiha", ""))
                                        playerViewModel.navigateTo(NavDestination.HOME, addToHistory = false)
                                    }
                                )
                            }
                            NavDestination.HOME -> {
                                HomeScreen(
                                    uchihaName = userProfile.uchihaDisplayName,
                                    allSongs = allSongs,
                                    artists = artists,
                                    currentSong = currentSong,
                                    isPlaying = isPlaying,
                                    onSongSelect = { song -> playerViewModel.playSong(song) },
                                    onFavoriteToggle = { id -> playerViewModel.toggleFavorite(id) },
                                    onNavigate = { dest -> playerViewModel.navigateTo(dest) }
                                )
                            }
                            NavDestination.SEARCH -> {
                                SearchScreen(
                                    searchQuery = searchQuery,
                                    selectedCategory = selectedSearchCategory,
                                    allSongs = allSongs,
                                    currentSong = currentSong,
                                    isPlaying = isPlaying,
                                    onQueryChange = { q -> playerViewModel.updateSearchQuery(q) },
                                    onCategorySelect = { cat -> playerViewModel.setSearchCategory(cat) },
                                    onSongSelect = { song -> playerViewModel.playSong(song) },
                                    onFavoriteToggle = { id -> playerViewModel.toggleFavorite(id) }
                                )
                            }
                            NavDestination.LIBRARY -> {
                                LibraryScreen(
                                    playlists = playlists,
                                    artists = artists,
                                    allSongs = allSongs,
                                    currentSong = currentSong,
                                    isPlaying = isPlaying,
                                    onSongSelect = { song -> playerViewModel.playSong(song) },
                                    onFavoriteToggle = { id -> playerViewModel.toggleFavorite(id) },
                                    onOpenPlaylist = { playlist -> playerViewModel.openPlaylist(playlist) },
                                    onCreatePlaylistClick = { playerViewModel.createPlaylist("Custom Uchiha Mix") },
                                    onScanDeviceAudio = { playerViewModel.scanLocalDeviceAudio(context) },
                                    onNavigate = { dest -> playerViewModel.navigateTo(dest) }
                                )
                            }
                            NavDestination.PROFILE -> {
                                ProfileScreen(
                                    userProfile = userProfile,
                                    onUpdateName = { name -> playerViewModel.updateUserName(name) },
                                    onNavigate = { dest -> playerViewModel.navigateTo(dest) }
                                )
                            }
                            NavDestination.NOW_PLAYING -> {
                                NowPlayingScreen(
                                    song = currentSong,
                                    isPlaying = isPlaying,
                                    playbackPositionMs = playbackPositionMs,
                                    isShuffle = isShuffle,
                                    isRepeat = isRepeat,
                                    beatPulse = beatPulse,
                                    onPlayPauseToggle = { playerViewModel.togglePlayPause() },
                                    onPrevious = { playerViewModel.previousSong() },
                                    onNext = { playerViewModel.nextSong() },
                                    onSeekTo = { pos -> playerViewModel.seekTo(pos) },
                                    onToggleFavorite = { id -> playerViewModel.toggleFavorite(id) },
                                    onToggleShuffle = { playerViewModel.toggleShuffle() },
                                    onToggleRepeat = { playerViewModel.toggleRepeat() },
                                    onPatternChange = { pattern -> playerViewModel.updateSharinganPattern(pattern) },
                                    onNavigate = { dest -> playerViewModel.navigateTo(dest) },
                                    onBack = { playerViewModel.navigateBack() }
                                )
                            }
                            NavDestination.PLAYER_DETAILS -> {
                                PlayerDetailsScreen(
                                    song = currentSong,
                                    isPlaying = isPlaying,
                                    onFavoriteToggle = { id -> playerViewModel.toggleFavorite(id) },
                                    onNavigate = { dest -> playerViewModel.navigateTo(dest) },
                                    onBack = { playerViewModel.navigateBack() }
                                )
                            }
                            NavDestination.LYRICS -> {
                                LyricsScreen(
                                    song = currentSong,
                                    playbackPositionMs = playbackPositionMs,
                                    onBack = { playerViewModel.navigateBack() }
                                )
                            }
                            NavDestination.QUEUE -> {
                                QueueScreen(
                                    currentSong = currentSong,
                                    queue = queue,
                                    queueIndex = queueIndex,
                                    isPlaying = isPlaying,
                                    onSongSelect = { song -> playerViewModel.playSong(song) },
                                    onBack = { playerViewModel.navigateBack() }
                                )
                            }
                            NavDestination.EQUALIZER -> {
                                EqualizerScreen(
                                    settings = equalizerSettings,
                                    onPresetSelect = { preset -> playerViewModel.updateEqualizerPreset(preset) },
                                    onBandChange = { idx, valDb -> playerViewModel.updateEqualizerBand(idx, valDb) },
                                    onBack = { playerViewModel.navigateBack() }
                                )
                            }
                            NavDestination.SETTINGS -> {
                                SettingsScreen(
                                    appSettings = appSettings,
                                    onSettingsUpdate = { updated -> playerViewModel.updateAppSettings(updated) },
                                    onBack = { playerViewModel.navigateBack() }
                                )
                            }
                            NavDestination.FAVORITES -> {
                                FavoritesScreen(
                                    allSongs = allSongs,
                                    currentSong = currentSong,
                                    isPlaying = isPlaying,
                                    onSongSelect = { song -> playerViewModel.playSong(song) },
                                    onFavoriteToggle = { id -> playerViewModel.toggleFavorite(id) },
                                    onBack = { playerViewModel.navigateBack() }
                                )
                            }
                            NavDestination.PLAYLIST_DETAIL -> {
                                PlaylistDetailScreen(
                                    playlist = selectedPlaylist,
                                    currentSong = currentSong,
                                    isPlaying = isPlaying,
                                    onSongSelect = { song -> playerViewModel.playSong(song) },
                                    onPlayAll = { songs -> if (songs.isNotEmpty()) playerViewModel.playSong(songs.first(), songs) },
                                    onFavoriteToggle = { id -> playerViewModel.toggleFavorite(id) },
                                    onBack = { playerViewModel.navigateBack() }
                                )
                            }
                        }
                    }

                    // Persistent Mini Player & Bottom Navigation Bar Overlay
                    if (showBottomBarAndMiniPlayer) {
                        Column(
                            modifier = Modifier
                                .align(Alignment.BottomCenter)
                                .fillMaxWidth()
                        ) {
                            MiniPlayer(
                                song = currentSong,
                                isPlaying = isPlaying,
                                playbackPositionMs = playbackPositionMs,
                                onPlayPauseToggle = { playerViewModel.togglePlayPause() },
                                onNext = { playerViewModel.previousSong() },
                                onToggleFavorite = { id -> playerViewModel.toggleFavorite(id) },
                                onClickMiniPlayer = { playerViewModel.navigateTo(NavDestination.NOW_PLAYING) }
                            )

                            BottomNavBar(
                                currentDestination = currentDestination,
                                onNavigate = { dest -> playerViewModel.navigateTo(dest) }
                            )
                        }
                    }
                }
            }
        }
    }
}