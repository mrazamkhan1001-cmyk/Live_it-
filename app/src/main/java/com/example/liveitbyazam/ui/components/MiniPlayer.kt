package com.example.liveitbyazam.ui.components

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Favorite
import androidx.compose.material.icons.filled.FavoriteBorder
import androidx.compose.material.icons.filled.Pause
import androidx.compose.material.icons.filled.PlayArrow
import androidx.compose.material.icons.filled.SkipNext
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.example.liveitbyazam.model.Song
import com.example.liveitbyazam.sharingan.SharinganView
import com.example.liveitbyazam.ui.theme.*

@Composable
fun MiniPlayer(
    song: Song?,
    isPlaying: Boolean,
    playbackPositionMs: Long,
    onPlayPauseToggle: () -> Unit,
    onNext: () -> Unit,
    onToggleFavorite: (String) -> Unit,
    onClickMiniPlayer: () -> Unit,
    modifier: Modifier = Modifier
) {
    if (song == null) return

    val totalMs = song.durationMs.coerceAtLeast(1L)
    val progressRatio = (playbackPositionMs.toFloat() / totalMs.toFloat()).coerceIn(0f, 1f)

    Column(
        modifier = modifier
            .fillMaxWidth()
            .padding(horizontal = 8.dp)
            .clip(RoundedCornerShape(14.dp))
            .background(CardBackground)
            .clickable { onClickMiniPlayer() }
    ) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = 10.dp, vertical = 8.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            // Sharingan Thumbnail / Icon
            SharinganView(
                pattern = song.sharinganPattern,
                isPlaying = isPlaying,
                sizeDp = 42.dp,
                glowIntensity = 0.5f
            )

            Spacer(modifier = Modifier.width(12.dp))

            // Song & Artist Info
            Column(
                modifier = Modifier.weight(1f)
            ) {
                Text(
                    text = song.title,
                    color = TextPrimary,
                    fontSize = 14.sp,
                    fontWeight = FontWeight.Bold,
                    maxLines = 1,
                    overflow = TextOverflow.Ellipsis
                )
                Text(
                    text = song.artist,
                    color = TextSecondary,
                    fontSize = 12.sp,
                    maxLines = 1,
                    overflow = TextOverflow.Ellipsis
                )
            }

            // Favorite Button
            IconButton(
                onClick = { onToggleFavorite(song.id) },
                modifier = Modifier.size(36.dp)
            ) {
                Icon(
                    imageVector = if (song.isFavorite) Icons.Default.Favorite else Icons.Default.FavoriteBorder,
                    contentDescription = "Favorite",
                    tint = if (song.isFavorite) BrightRed else TextSecondary,
                    modifier = Modifier.size(20.dp)
                )
            }

            // Play / Pause Button
            IconButton(
                onClick = onPlayPauseToggle,
                modifier = Modifier
                    .size(38.dp)
                    .clip(RoundedCornerShape(19.dp))
                    .background(PrimaryRed)
            ) {
                Icon(
                    imageVector = if (isPlaying) Icons.Default.Pause else Icons.Default.PlayArrow,
                    contentDescription = "Play Pause",
                    tint = TextPrimary,
                    modifier = Modifier.size(22.dp)
                )
            }

            Spacer(modifier = Modifier.width(4.dp))

            // Next Song Button
            IconButton(
                onClick = onNext,
                modifier = Modifier.size(36.dp)
            ) {
                Icon(
                    imageVector = Icons.Default.SkipNext,
                    contentDescription = "Next",
                    tint = TextPrimary,
                    modifier = Modifier.size(22.dp)
                )
            }
        }

        // Mini Progress Bar Indicator at bottom edge
        Box(
            modifier = Modifier
                .fillMaxWidth()
                .height(2.5.dp)
                .background(SurfaceElevated)
        ) {
            Box(
                modifier = Modifier
                    .fillMaxHeight()
                    .fillMaxWidth(progressRatio)
                    .background(BrightRed)
            )
        }
    }
}
