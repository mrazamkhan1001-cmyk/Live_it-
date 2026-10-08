package com.example.liveitbyazam.ui.screens

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.ArrowBack
import androidx.compose.material.icons.filled.PlayArrow
import androidx.compose.material.icons.filled.Shuffle
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.example.liveitbyazam.model.Playlist
import com.example.liveitbyazam.model.Song
import com.example.liveitbyazam.sharingan.SharinganPattern
import com.example.liveitbyazam.sharingan.SharinganView
import com.example.liveitbyazam.ui.components.SongItemRow
import com.example.liveitbyazam.ui.theme.*

@Composable
fun PlaylistDetailScreen(
    playlist: Playlist?,
    currentSong: Song?,
    isPlaying: Boolean,
    onSongSelect: (Song) -> Unit,
    onPlayAll: (List<Song>) -> Unit,
    onFavoriteToggle: (String) -> Unit,
    onBack: () -> Unit
) {
    if (playlist == null) return

    LazyColumn(
        modifier = Modifier
            .fillMaxSize()
            .background(PrimaryBackground),
        contentPadding = PaddingValues(bottom = 120.dp)
    ) {
        item {
            // Header Bar
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(horizontal = 16.dp, vertical = 16.dp),
                verticalAlignment = Alignment.CenterVertically
            ) {
                IconButton(onClick = onBack) {
                    Icon(imageVector = Icons.Default.ArrowBack, contentDescription = "Back", tint = TextPrimary)
                }
                Spacer(modifier = Modifier.width(12.dp))
                Text(text = "PLAYLIST", color = BrightRed, fontSize = 12.sp, fontWeight = FontWeight.Bold, letterSpacing = 1.5.sp)
            }
        }

        item {
            // Cover Art & Info
            Column(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(horizontal = 20.dp),
                horizontalAlignment = Alignment.CenterHorizontally
            ) {
                Box(
                    modifier = Modifier
                        .size(160.dp)
                        .clip(RoundedCornerShape(16.dp))
                        .background(CardBackground),
                    contentAlignment = Alignment.Center
                ) {
                    SharinganView(
                        pattern = SharinganPattern.ITACHI_MANGEKYOU,
                        isPlaying = isPlaying,
                        sizeDp = 130.dp,
                        glowIntensity = 0.8f
                    )
                }

                Spacer(modifier = Modifier.height(16.dp))

                Text(
                    text = playlist.name,
                    color = TextPrimary,
                    fontSize = 22.sp,
                    fontWeight = FontWeight.Black
                )

                Spacer(modifier = Modifier.height(4.dp))

                Text(
                    text = playlist.description.ifEmpty { "Curated Uchiha selection" },
                    color = TextSecondary,
                    fontSize = 13.sp
                )

                Spacer(modifier = Modifier.height(16.dp))

                // Action Buttons (Play All & Shuffle)
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.Center,
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Button(
                        onClick = { onPlayAll(playlist.songs) },
                        colors = ButtonDefaults.buttonColors(containerColor = PrimaryRed),
                        shape = RoundedCornerShape(24.dp),
                        modifier = Modifier.height(46.dp)
                    ) {
                        Icon(imageVector = Icons.Default.PlayArrow, contentDescription = "Play", tint = TextPrimary)
                        Spacer(modifier = Modifier.width(6.dp))
                        Text(text = "PLAY ALL", color = TextPrimary, fontWeight = FontWeight.Bold, fontSize = 13.sp)
                    }

                    Spacer(modifier = Modifier.width(12.dp))

                    IconButton(
                        onClick = { onPlayAll(playlist.songs.shuffled()) },
                        modifier = Modifier
                            .size(46.dp)
                            .clip(CircleShape)
                            .background(CardBackground)
                    ) {
                        Icon(imageVector = Icons.Default.Shuffle, contentDescription = "Shuffle", tint = BrightRed)
                    }
                }

                Spacer(modifier = Modifier.height(24.dp))
            }
        }

        // Song Items
        items(playlist.songs) { song ->
            Box(modifier = Modifier.padding(horizontal = 20.dp, vertical = 4.dp)) {
                SongItemRow(
                    song = song,
                    isCurrentPlaying = currentSong?.id == song.id,
                    isPlaying = isPlaying,
                    onSongClick = onSongSelect,
                    onFavoriteToggle = onFavoriteToggle
                )
            }
        }
    }
}
