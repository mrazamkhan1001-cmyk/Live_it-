package com.example.liveitbyazam.ui.screens

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.LazyRow
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Add
import androidx.compose.material.icons.filled.Favorite
import androidx.compose.material.icons.filled.Folder
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.example.liveitbyazam.model.Artist
import com.example.liveitbyazam.model.Playlist
import com.example.liveitbyazam.model.Song
import com.example.liveitbyazam.player.NavDestination
import com.example.liveitbyazam.ui.components.ArtistCard
import com.example.liveitbyazam.ui.components.PlaylistCard
import com.example.liveitbyazam.ui.components.SongItemRow
import com.example.liveitbyazam.ui.theme.*

@Composable
fun LibraryScreen(
    playlists: List<Playlist>,
    artists: List<Artist>,
    allSongs: List<Song>,
    currentSong: Song?,
    isPlaying: Boolean,
    onSongSelect: (Song) -> Unit,
    onFavoriteToggle: (String) -> Unit,
    onOpenPlaylist: (Playlist) -> Unit,
    onCreatePlaylistClick: () -> Unit,
    onScanDeviceAudio: () -> Unit,
    onNavigate: (NavDestination) -> Unit
) {
    var selectedTab by remember { mutableIntStateOf(0) }
    val tabs = listOf("Playlists", "Artists", "Albums", "Songs")

    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(PrimaryBackground)
    ) {
        // Top Title Bar + Actions
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = 20.dp, vertical = 16.dp),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment = Alignment.CenterVertically
        ) {
            Text(
                text = "YOUR LIBRARY",
                color = TextPrimary,
                fontSize = 22.sp,
                fontWeight = FontWeight.Black,
                letterSpacing = 1.5.sp
            )

            Row(verticalAlignment = Alignment.CenterVertically) {
                IconButton(onClick = onScanDeviceAudio) {
                    Icon(
                        imageVector = Icons.Default.Folder,
                        contentDescription = "Scan Device Audio",
                        tint = BrightRed
                    )
                }
                IconButton(onClick = onCreatePlaylistClick) {
                    Icon(
                        imageVector = Icons.Default.Add,
                        contentDescription = "Create Playlist",
                        tint = BrightRed
                    )
                }
            }
        }

        // Tabs Row
        LazyRow(
            contentPadding = PaddingValues(horizontal = 20.dp),
            horizontalArrangement = Arrangement.spacedBy(8.dp)
        ) {
            items(tabs.indices.toList()) { index ->
                val isSelected = selectedTab == index
                Box(
                    modifier = Modifier
                        .clip(RoundedCornerShape(16.dp))
                        .background(if (isSelected) PrimaryRed else CardBackground)
                        .border(1.dp, if (isSelected) BrightRed else DividerColor, RoundedCornerShape(16.dp))
                        .clickable { selectedTab = index }
                        .padding(horizontal = 16.dp, vertical = 8.dp)
                ) {
                    Text(
                        text = tabs[index],
                        color = if (isSelected) TextPrimary else TextSecondary,
                        fontSize = 13.sp,
                        fontWeight = if (isSelected) FontWeight.Bold else FontWeight.Medium
                    )
                }
            }
        }

        Spacer(modifier = Modifier.height(16.dp))

        // Tab Content
        LazyColumn(
            contentPadding = PaddingValues(start = 20.dp, end = 20.dp, bottom = 120.dp),
            verticalArrangement = Arrangement.spacedBy(10.dp)
        ) {
            when (selectedTab) {
                0 -> { // Playlists
                    item {
                        // Liked Songs Quick Header Card
                        Row(
                            modifier = Modifier
                                .fillMaxWidth()
                                .clip(RoundedCornerShape(12.dp))
                                .background(CardBackground)
                                .clickable { onNavigate(NavDestination.FAVORITES) }
                                .padding(14.dp),
                            verticalAlignment = Alignment.CenterVertically
                        ) {
                            Box(
                                modifier = Modifier
                                    .size(52.dp)
                                    .clip(RoundedCornerShape(10.dp))
                                    .background(PrimaryRed),
                                contentAlignment = Alignment.Center
                            ) {
                                Icon(
                                    imageVector = Icons.Default.Favorite,
                                    contentDescription = "Liked Songs",
                                    tint = TextPrimary,
                                    modifier = Modifier.size(26.dp)
                                )
                            }
                            Spacer(modifier = Modifier.width(14.dp))
                            Column {
                                Text(
                                    text = "Liked Songs",
                                    color = TextPrimary,
                                    fontSize = 16.sp,
                                    fontWeight = FontWeight.Bold
                                )
                                Text(
                                    text = "${allSongs.count { it.isFavorite }} tracks",
                                    color = TextSecondary,
                                    fontSize = 12.sp
                                )
                            }
                        }
                    }

                    items(playlists) { playlist ->
                        PlaylistCard(
                            playlist = playlist,
                            onClick = { onOpenPlaylist(playlist) }
                        )
                    }
                }
                1 -> { // Artists
                    items(artists) { artist ->
                        Row(
                            modifier = Modifier
                                .fillMaxWidth()
                                .clip(RoundedCornerShape(12.dp))
                                .background(CardBackground)
                                .padding(12.dp),
                            verticalAlignment = Alignment.CenterVertically
                        ) {
                            ArtistCard(artist = artist, onClick = { })
                            Spacer(modifier = Modifier.width(16.dp))
                            Column {
                                Text(text = artist.name, color = TextPrimary, fontSize = 15.sp, fontWeight = FontWeight.Bold)
                                Text(text = artist.bio, color = TextSecondary, fontSize = 12.sp)
                            }
                        }
                    }
                }
                2 -> { // Albums
                    items(allSongs.distinctBy { it.album }) { song ->
                        SongItemRow(
                            song = song,
                            isCurrentPlaying = currentSong?.id == song.id,
                            isPlaying = isPlaying,
                            onSongClick = onSongSelect,
                            onFavoriteToggle = onFavoriteToggle
                        )
                    }
                }
                3 -> { // All Songs
                    items(allSongs) { song ->
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
    }
}
