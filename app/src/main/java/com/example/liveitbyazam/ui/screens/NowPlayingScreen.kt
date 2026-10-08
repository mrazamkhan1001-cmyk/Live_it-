package com.example.liveitbyazam.ui.screens

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.KeyboardArrowLeft
import androidx.compose.material.icons.automirrored.filled.QueueMusic
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.example.liveitbyazam.R
import com.example.liveitbyazam.model.Song
import com.example.liveitbyazam.player.NavDestination
import com.example.liveitbyazam.sharingan.SharinganPattern
import com.example.liveitbyazam.sharingan.SharinganVideoView
import com.example.liveitbyazam.sharingan.SharinganView
import com.example.liveitbyazam.ui.theme.*

@Composable
fun NowPlayingScreen(
    song: Song?,
    isPlaying: Boolean,
    playbackPositionMs: Long,
    isShuffle: Boolean,
    isRepeat: Boolean,
    beatPulse: Float,
    onPlayPauseToggle: () -> Unit,
    onPrevious: () -> Unit,
    onNext: () -> Unit,
    onSeekTo: (Long) -> Unit,
    onToggleFavorite: (String) -> Unit,
    onToggleShuffle: () -> Unit,
    onToggleRepeat: () -> Unit,
    onPatternChange: (SharinganPattern) -> Unit,
    onNavigate: (NavDestination) -> Unit,
    onBack: () -> Unit
) {
    if (song == null) return

    val totalMs = song.durationMs.coerceAtLeast(1L)
    var isDraggingSlider by remember { mutableStateOf(false) }
    var sliderPosition by remember { mutableFloatStateOf(0f) }
    var useVectorCanvas by remember { mutableStateOf(true) }

    val currentSliderVal = if (isDraggingSlider) sliderPosition else (playbackPositionMs.toFloat() / totalMs.toFloat())

    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(PrimaryBackground)
            .statusBarsPadding()
            .padding(horizontal = 24.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.SpaceBetween
    ) {
        // 1. Top Bar Header matching Mockup #8
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(top = 8.dp),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment = Alignment.CenterVertically
        ) {
            IconButton(onClick = onBack) {
                Icon(
                    imageVector = Icons.AutoMirrored.Filled.KeyboardArrowLeft,
                    contentDescription = "Collapse Player",
                    tint = TextPrimary,
                    modifier = Modifier.size(28.dp)
                )
            }

            Column(horizontalAlignment = Alignment.CenterHorizontally) {
                Text(
                    text = "PLAYING FROM",
                    color = TextSecondary,
                    fontSize = 10.sp,
                    letterSpacing = 1.2.sp,
                    fontWeight = FontWeight.Bold
                )
                Text(
                    text = song.album,
                    color = TextPrimary,
                    fontSize = 13.sp,
                    fontWeight = FontWeight.Bold,
                    maxLines = 1,
                    overflow = TextOverflow.Ellipsis
                )
            }

            IconButton(onClick = { onNavigate(NavDestination.PLAYER_DETAILS) }) {
                Box(
                    modifier = Modifier
                        .size(24.dp)
                        .border(1.dp, BrightRed, CircleShape),
                    contentAlignment = Alignment.Center
                ) {
                    Text(text = "A", color = BrightRed, fontSize = 11.sp, fontWeight = FontWeight.Bold)
                }
            }
        }

        // 2. Central Signature Cinematic Sharingan Video Display (Dominant Centerpiece)
        Box(
            modifier = Modifier.padding(vertical = 12.dp),
            contentAlignment = Alignment.Center
        ) {
            SharinganVideoView(
                videoResId = R.raw.sharingan,
                isPlaying = isPlaying,
                sizeDp = 280.dp,
                beatPulse = beatPulse,
                glowIntensity = 1.4f
            )
        }

        // 3. Track Title, Artist & Favorite Heart matching Mockup #8
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment = Alignment.CenterVertically
        ) {
            Column(modifier = Modifier.weight(1f)) {
                Text(
                    text = song.title,
                    color = TextPrimary,
                    fontSize = 22.sp,
                    fontWeight = FontWeight.Black,
                    maxLines = 1,
                    overflow = TextOverflow.Ellipsis
                )
                Spacer(modifier = Modifier.height(2.dp))
                Text(
                    text = song.artist,
                    color = TextSecondary,
                    fontSize = 14.sp,
                    maxLines = 1,
                    overflow = TextOverflow.Ellipsis
                )
            }

            IconButton(
                onClick = { onToggleFavorite(song.id) },
                modifier = Modifier.size(44.dp)
            ) {
                Icon(
                    imageVector = if (song.isFavorite) Icons.Default.Favorite else Icons.Default.FavoriteBorder,
                    contentDescription = "Favorite",
                    tint = if (song.isFavorite) BrightRed else TextSecondary,
                    modifier = Modifier.size(24.dp)
                )
            }
        }

        // 4. Red Track Slider & Elapsed / Duration Times
        Column(modifier = Modifier.fillMaxWidth()) {
            Slider(
                value = currentSliderVal.coerceIn(0f, 1f),
                onValueChange = {
                    isDraggingSlider = true
                    sliderPosition = it
                },
                onValueChangeFinished = {
                    isDraggingSlider = false
                    onSeekTo((sliderPosition * totalMs).toLong())
                },
                colors = SliderDefaults.colors(
                    thumbColor = BrightRed,
                    activeTrackColor = PrimaryRed,
                    inactiveTrackColor = SurfaceElevated
                ),
                modifier = Modifier.fillMaxWidth()
            )

            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween
            ) {
                val elapsedMs = (currentSliderVal * totalMs).toLong()
                val elapsedSec = (elapsedMs / 1000) % 60
                val elapsedMin = (elapsedMs / (1000 * 60)) % 60
                val formattedElapsed = String.format("%d:%02d", elapsedMin, elapsedSec)

                Text(
                    text = formattedElapsed,
                    color = TextSecondary,
                    fontSize = 12.sp
                )
                Text(
                    text = song.formattedDuration(),
                    color = TextSecondary,
                    fontSize = 12.sp
                )
            }
        }

        // 5. Playback Controls Row matching Mockup #8
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.SpaceEvenly,
            verticalAlignment = Alignment.CenterVertically
        ) {
            IconButton(onClick = onToggleShuffle) {
                Icon(
                    imageVector = Icons.Default.Shuffle,
                    contentDescription = "Shuffle",
                    tint = if (isShuffle) BrightRed else TextMuted,
                    modifier = Modifier.size(22.dp)
                )
            }

            IconButton(onClick = onPrevious) {
                Icon(
                    imageVector = Icons.Default.SkipPrevious,
                    contentDescription = "Previous",
                    tint = TextPrimary,
                    modifier = Modifier.size(32.dp)
                )
            }

            // Central Main Red Circle Play/Pause Button with Outer Glow Ring
            Box(
                modifier = Modifier
                    .size(64.dp)
                    .clip(CircleShape)
                    .background(PrimaryRed)
                    .border(2.dp, BrightRed, CircleShape)
                    .clickable { onPlayPauseToggle() },
                contentAlignment = Alignment.Center
            ) {
                Icon(
                    imageVector = if (isPlaying) Icons.Default.Pause else Icons.Default.PlayArrow,
                    contentDescription = "Play/Pause",
                    tint = TextPrimary,
                    modifier = Modifier.size(34.dp)
                )
            }

            IconButton(onClick = onNext) {
                Icon(
                    imageVector = Icons.Default.SkipNext,
                    contentDescription = "Next",
                    tint = TextPrimary,
                    modifier = Modifier.size(32.dp)
                )
            }

            IconButton(onClick = onToggleRepeat) {
                Icon(
                    imageVector = Icons.Default.Repeat,
                    contentDescription = "Repeat",
                    tint = if (isRepeat) BrightRed else TextMuted,
                    modifier = Modifier.size(22.dp)
                )
            }
        }

        // 6. Bottom Shortcuts Bar matching Mockup #8 (Equalizer, Lyrics, Queue, Sound Settings)
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(bottom = 16.dp),
            horizontalArrangement = Arrangement.SpaceEvenly,
            verticalAlignment = Alignment.CenterVertically
        ) {
            IconButton(onClick = { onNavigate(NavDestination.EQUALIZER) }) {
                Icon(imageVector = Icons.Default.Equalizer, contentDescription = "Equalizer", tint = TextSecondary, modifier = Modifier.size(20.dp))
            }
            IconButton(onClick = { onNavigate(NavDestination.LYRICS) }) {
                Icon(imageVector = Icons.Default.Subtitles, contentDescription = "Lyrics", tint = TextSecondary, modifier = Modifier.size(20.dp))
            }
            IconButton(onClick = { onNavigate(NavDestination.QUEUE) }) {
                Icon(imageVector = Icons.AutoMirrored.Filled.QueueMusic, contentDescription = "Queue", tint = TextSecondary, modifier = Modifier.size(20.dp))
            }
            IconButton(onClick = { onNavigate(NavDestination.SETTINGS) }) {
                Icon(imageVector = Icons.Default.Settings, contentDescription = "Settings", tint = TextSecondary, modifier = Modifier.size(20.dp))
            }
        }
    }
}
