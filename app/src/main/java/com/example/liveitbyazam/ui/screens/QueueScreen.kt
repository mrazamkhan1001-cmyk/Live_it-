package com.example.liveitbyazam.ui.screens

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.itemsIndexed
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material.icons.filled.DragHandle
import androidx.compose.material3.*
import androidx.compose.runtime.*
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
fun QueueScreen(
    currentSong: Song?,
    queue: List<Song>,
    queueIndex: Int,
    isPlaying: Boolean,
    onSongSelect: (Song) -> Unit,
    onBack: () -> Unit
) {
    var selectedQueueTab by remember { mutableIntStateOf(1) } // 0: Now Playing, 1: Up Next

    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(PrimaryBackground)
    ) {
        // Top Header matching Mockup #11
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = 16.dp, vertical = 14.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            IconButton(onClick = onBack) {
                Icon(
                    imageVector = Icons.AutoMirrored.Filled.ArrowBack,
                    contentDescription = "Back",
                    tint = TextPrimary
                )
            }
            Spacer(modifier = Modifier.width(8.dp))
            Text(
                text = "Queue",
                color = TextPrimary,
                fontSize = 18.sp,
                fontWeight = FontWeight.Bold
            )
        }

        // Pill Tabs (Now Playing | Up Next) matching Mockup #11
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = 20.dp, vertical = 8.dp),
            horizontalArrangement = Arrangement.spacedBy(10.dp)
        ) {
            Box(
                modifier = Modifier
                    .weight(1f)
                    .clip(RoundedCornerShape(20.dp))
                    .background(if (selectedQueueTab == 0) PrimaryRed else CardBackground)
                    .clickable { selectedQueueTab = 0 }
                    .padding(vertical = 8.dp),
                contentAlignment = Alignment.Center
            ) {
                Text(
                    text = "Now Playing",
                    color = if (selectedQueueTab == 0) TextPrimary else TextSecondary,
                    fontSize = 13.sp,
                    fontWeight = FontWeight.Bold
                )
            }
            Box(
                modifier = Modifier
                    .weight(1f)
                    .clip(RoundedCornerShape(20.dp))
                    .background(if (selectedQueueTab == 1) PrimaryRed else CardBackground)
                    .clickable { selectedQueueTab = 1 }
                    .padding(vertical = 8.dp),
                contentAlignment = Alignment.Center
            ) {
                Text(
                    text = "Up Next",
                    color = if (selectedQueueTab == 1) TextPrimary else TextSecondary,
                    fontSize = 13.sp,
                    fontWeight = FontWeight.Bold
                )
            }
        }

        Spacer(modifier = Modifier.height(10.dp))

        LazyColumn(
            contentPadding = PaddingValues(start = 20.dp, end = 20.dp, bottom = 120.dp),
            verticalArrangement = Arrangement.spacedBy(8.dp)
        ) {
            if (selectedQueueTab == 0 && currentSong != null) {
                item {
                    QueueItemRow(
                        song = currentSong,
                        isNowPlaying = true,
                        isPlaying = isPlaying,
                        onSongClick = { }
                    )
                }
            } else {
                itemsIndexed(queue) { index, song ->
                    QueueItemRow(
                        song = song,
                        isNowPlaying = song.id == currentSong?.id,
                        isPlaying = song.id == currentSong?.id && isPlaying,
                        onSongClick = { onSongSelect(song) }
                    )
                }
            }
        }
    }
}

@Composable
private fun QueueItemRow(
    song: Song,
    isNowPlaying: Boolean,
    isPlaying: Boolean,
    onSongClick: () -> Unit
) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .clip(RoundedCornerShape(12.dp))
            .background(if (isNowPlaying) SurfaceElevated else CardBackground)
            .clickable { onSongClick() }
            .padding(horizontal = 12.dp, vertical = 10.dp),
        verticalAlignment = Alignment.CenterVertically
    ) {
        Box(
            modifier = Modifier
                .size(44.dp)
                .clip(RoundedCornerShape(8.dp))
                .background(SecondaryBackground),
            contentAlignment = Alignment.Center
        ) {
            SharinganView(
                pattern = song.sharinganPattern,
                isPlaying = isNowPlaying && isPlaying,
                sizeDp = 38.dp,
                glowIntensity = 0.5f
            )
        }

        Spacer(modifier = Modifier.width(12.dp))

        Column(modifier = Modifier.weight(1f)) {
            Text(
                text = song.title,
                color = if (isNowPlaying) BrightRed else TextPrimary,
                fontSize = 14.sp,
                fontWeight = if (isNowPlaying) FontWeight.Bold else FontWeight.Medium,
                maxLines = 1,
                overflow = TextOverflow.Ellipsis
            )
            Spacer(modifier = Modifier.height(2.dp))
            Text(
                text = song.artist,
                color = TextSecondary,
                fontSize = 12.sp,
                maxLines = 1,
                overflow = TextOverflow.Ellipsis
            )
        }

        Icon(
            imageVector = Icons.Default.DragHandle,
            contentDescription = "Reorder",
            tint = TextSecondary,
            modifier = Modifier.size(20.dp)
        )
    }
}
