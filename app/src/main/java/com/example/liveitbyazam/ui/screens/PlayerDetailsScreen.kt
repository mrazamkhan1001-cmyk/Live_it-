package com.example.liveitbyazam.ui.screens

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.example.liveitbyazam.model.Song
import com.example.liveitbyazam.player.NavDestination
import com.example.liveitbyazam.sharingan.SharinganView
import com.example.liveitbyazam.ui.theme.*

@Composable
fun PlayerDetailsScreen(
    song: Song?,
    isPlaying: Boolean,
    onFavoriteToggle: (String) -> Unit,
    onNavigate: (NavDestination) -> Unit,
    onBack: () -> Unit
) {
    if (song == null) return

    LazyColumn(
        modifier = Modifier
            .fillMaxSize()
            .background(PrimaryBackground),
        contentPadding = PaddingValues(start = 20.dp, end = 20.dp, bottom = 120.dp)
    ) {
        item {
            // Header Bar
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(vertical = 16.dp),
                verticalAlignment = Alignment.CenterVertically
            ) {
                IconButton(onClick = onBack) {
                    Icon(imageVector = Icons.Default.ArrowBack, contentDescription = "Back", tint = TextPrimary)
                }
                Spacer(modifier = Modifier.width(12.dp))
                Text(text = "TRACK DETAILS", color = TextPrimary, fontSize = 18.sp, fontWeight = FontWeight.Bold, letterSpacing = 1.sp)
            }
        }

        item {
            Column(
                modifier = Modifier.fillMaxWidth(),
                horizontalAlignment = Alignment.CenterHorizontally
            ) {
                SharinganView(
                    pattern = song.sharinganPattern,
                    isPlaying = isPlaying,
                    sizeDp = 220.dp,
                    glowIntensity = 1.0f
                )

                Spacer(modifier = Modifier.height(20.dp))

                Text(text = song.title, color = TextPrimary, fontSize = 22.sp, fontWeight = FontWeight.Black)
                Spacer(modifier = Modifier.height(4.dp))
                Text(text = song.artist, color = BrightRed, fontSize = 15.sp, fontWeight = FontWeight.Bold)
                Text(text = "Album: ${song.album}", color = TextSecondary, fontSize = 13.sp)

                Spacer(modifier = Modifier.height(28.dp))
            }
        }

        item {
            Column(verticalArrangement = Arrangement.spacedBy(10.dp)) {
                DetailActionRow(
                    title = "Open Lyrics",
                    icon = Icons.Default.Subtitles,
                    onClick = { onNavigate(NavDestination.LYRICS) }
                )
                DetailActionRow(
                    title = "Open Equalizer",
                    icon = Icons.Default.Equalizer,
                    onClick = { onNavigate(NavDestination.EQUALIZER) }
                )
                DetailActionRow(
                    title = "Up Next Queue",
                    icon = Icons.Default.QueueMusic,
                    onClick = { onNavigate(NavDestination.QUEUE) }
                )
                DetailActionRow(
                    title = if (song.isFavorite) "Remove from Favorites" else "Add to Favorites",
                    icon = Icons.Default.Favorite,
                    onClick = { onFavoriteToggle(song.id) }
                )
                DetailActionRow(
                    title = "Share Track",
                    icon = Icons.Default.Share,
                    onClick = { }
                )
                DetailActionRow(
                    title = "Add to Playlist",
                    icon = Icons.Default.PlaylistAdd,
                    onClick = { onNavigate(NavDestination.LIBRARY) }
                )
            }
        }
    }
}

@Composable
private fun DetailActionRow(
    title: String,
    icon: androidx.compose.ui.graphics.vector.ImageVector,
    onClick: () -> Unit
) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .clip(RoundedCornerShape(12.dp))
            .background(CardBackground)
            .clickable { onClick() }
            .padding(16.dp),
        verticalAlignment = Alignment.CenterVertically
    ) {
        Icon(imageVector = icon, contentDescription = title, tint = BrightRed, modifier = Modifier.size(22.dp))
        Spacer(modifier = Modifier.width(16.dp))
        Text(text = title, color = TextPrimary, fontSize = 15.sp, fontWeight = FontWeight.SemiBold)
    }
}
