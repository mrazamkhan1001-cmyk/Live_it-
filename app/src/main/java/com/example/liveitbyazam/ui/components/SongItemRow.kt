package com.example.liveitbyazam.ui.components

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Favorite
import androidx.compose.material.icons.filled.FavoriteBorder
import androidx.compose.material.icons.filled.MoreVert
import androidx.compose.material.icons.filled.PlayArrow
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
fun SongItemRow(
    song: Song,
    isCurrentPlaying: Boolean = false,
    isPlaying: Boolean = false,
    onSongClick: (Song) -> Unit,
    onFavoriteToggle: (String) -> Unit,
    onMoreClick: ((Song) -> Unit)? = null,
    modifier: Modifier = Modifier
) {
    Row(
        modifier = modifier
            .fillMaxWidth()
            .clip(RoundedCornerShape(12.dp))
            .background(if (isCurrentPlaying) SurfaceElevated else CardBackground)
            .clickable { onSongClick(song) }
            .padding(horizontal = 12.dp, vertical = 10.dp),
        verticalAlignment = Alignment.CenterVertically
    ) {
        // Thumbnail with mini Sharingan preview
        Box(
            modifier = Modifier
                .size(48.dp)
                .clip(RoundedCornerShape(8.dp))
                .background(SecondaryBackground),
            contentAlignment = Alignment.Center
        ) {
            SharinganView(
                pattern = song.sharinganPattern,
                isPlaying = isCurrentPlaying && isPlaying,
                sizeDp = 44.dp,
                glowIntensity = 0.4f
            )
        }

        Spacer(modifier = Modifier.width(12.dp))

        // Title & Artist
        Column(
            modifier = Modifier.weight(1f)
        ) {
            Text(
                text = song.title,
                color = if (isCurrentPlaying) BrightRed else TextPrimary,
                fontSize = 15.sp,
                fontWeight = if (isCurrentPlaying) FontWeight.Bold else FontWeight.SemiBold,
                maxLines = 1,
                overflow = TextOverflow.Ellipsis
            )
            Spacer(modifier = Modifier.height(2.dp))
            Text(
                text = "${song.artist} • ${song.formattedDuration()}",
                color = TextSecondary,
                fontSize = 12.sp,
                maxLines = 1,
                overflow = TextOverflow.Ellipsis
            )
        }

        // Like Button
        IconButton(
            onClick = { onFavoriteToggle(song.id) },
            modifier = Modifier.size(36.dp)
        ) {
            Icon(
                imageVector = if (song.isFavorite) Icons.Default.Favorite else Icons.Default.FavoriteBorder,
                contentDescription = "Favorite",
                tint = if (song.isFavorite) BrightRed else TextMuted,
                modifier = Modifier.size(20.dp)
            )
        }

        // More Options Button
        if (onMoreClick != null) {
            IconButton(
                onClick = { onMoreClick(song) },
                modifier = Modifier.size(36.dp)
            ) {
                Icon(
                    imageVector = Icons.Default.MoreVert,
                    contentDescription = "Options",
                    tint = TextSecondary,
                    modifier = Modifier.size(20.dp)
                )
            }
        }
    }
}
