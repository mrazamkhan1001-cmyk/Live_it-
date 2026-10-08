package com.example.liveitbyazam.ui.screens

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.LazyRow
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Download
import androidx.compose.material.icons.filled.Favorite
import androidx.compose.material.icons.filled.Person
import androidx.compose.material.icons.filled.QueueMusic
import androidx.compose.material.icons.filled.Search
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.example.liveitbyazam.model.Artist
import com.example.liveitbyazam.model.Song
import com.example.liveitbyazam.player.NavDestination
import com.example.liveitbyazam.sharingan.SharinganPattern
import com.example.liveitbyazam.sharingan.SharinganView
import com.example.liveitbyazam.ui.components.AlbumCard
import com.example.liveitbyazam.ui.components.ArtistCard
import com.example.liveitbyazam.ui.components.QuickAccessCard
import com.example.liveitbyazam.ui.components.SongItemRow
import com.example.liveitbyazam.ui.theme.*

@Composable
fun HomeScreen(
    uchihaName: String,
    allSongs: List<Song>,
    artists: List<Artist>,
    currentSong: Song?,
    isPlaying: Boolean,
    onSongSelect: (Song) -> Unit,
    onFavoriteToggle: (String) -> Unit,
    onNavigate: (NavDestination) -> Unit
) {
    LazyColumn(
        modifier = Modifier
            .fillMaxSize()
            .background(PrimaryBackground),
        contentPadding = PaddingValues(bottom = 120.dp)
    ) {
        // 1. Header Greeting & Avatar matching Mockup #6
        item {
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(horizontal = 20.dp, vertical = 16.dp),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Column {
                    Text(
                        text = "Good Evening,",
                        color = TextSecondary,
                        fontSize = 13.sp
                    )
                    Spacer(modifier = Modifier.height(2.dp))
                    Text(
                        text = uchihaName,
                        color = TextPrimary,
                        fontSize = 22.sp,
                        fontWeight = FontWeight.Black,
                        letterSpacing = 0.5.sp
                    )
                }

                // Profile Avatar with Red Ring Accent
                Box(
                    modifier = Modifier
                        .size(44.dp)
                        .clip(CircleShape)
                        .background(CardBackground)
                        .border(1.5.dp, PrimaryRed, CircleShape)
                        .clickable { onNavigate(NavDestination.PROFILE) },
                    contentAlignment = Alignment.Center
                ) {
                    SharinganView(
                        pattern = SharinganPattern.ETERNAL_MANGEKYOU,
                        isPlaying = isPlaying,
                        sizeDp = 38.dp,
                        glowIntensity = 0.4f
                    )
                }
            }
        }

        // 2. Search Quick Bar
        item {
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(horizontal = 20.dp)
                    .clip(RoundedCornerShape(14.dp))
                    .background(CardBackground)
                    .border(1.dp, DividerColor, RoundedCornerShape(14.dp))
                    .clickable { onNavigate(NavDestination.SEARCH) }
                    .padding(horizontal = 16.dp, vertical = 12.dp),
                verticalAlignment = Alignment.CenterVertically
            ) {
                Icon(
                    imageVector = Icons.Default.Search,
                    contentDescription = "Search",
                    tint = TextSecondary,
                    modifier = Modifier.size(18.dp)
                )
                Spacer(modifier = Modifier.width(12.dp))
                Text(
                    text = "What are we listening to?",
                    color = TextSecondary,
                    fontSize = 13.sp
                )
            }

            Spacer(modifier = Modifier.height(20.dp))
        }

        // 3. Quick Access Cards Grid (Favorites, Playlists, Artists, Downloads)
        item {
            Column(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(horizontal = 20.dp)
            ) {
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.spacedBy(10.dp)
                ) {
                    QuickAccessCard(
                        title = "Favorites",
                        icon = Icons.Default.Favorite,
                        onClick = { onNavigate(NavDestination.FAVORITES) },
                        modifier = Modifier.weight(1f)
                    )
                    QuickAccessCard(
                        title = "Playlists",
                        icon = Icons.Default.QueueMusic,
                        onClick = { onNavigate(NavDestination.LIBRARY) },
                        modifier = Modifier.weight(1f)
                    )
                }
                Spacer(modifier = Modifier.height(10.dp))
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.spacedBy(10.dp)
                ) {
                    QuickAccessCard(
                        title = "Artists",
                        icon = Icons.Default.Person,
                        onClick = { onNavigate(NavDestination.LIBRARY) },
                        modifier = Modifier.weight(1f)
                    )
                    QuickAccessCard(
                        title = "Downloads",
                        icon = Icons.Default.Download,
                        onClick = { onNavigate(NavDestination.LIBRARY) },
                        modifier = Modifier.weight(1f)
                    )
                }
            }

            Spacer(modifier = Modifier.height(24.dp))
        }

        // 4. Recently Played Section (With "See All" link)
        item {
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(horizontal = 20.dp),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Text(
                    text = "Recently Played",
                    color = TextPrimary,
                    fontSize = 17.sp,
                    fontWeight = FontWeight.Bold
                )
                Text(
                    text = "See All",
                    color = BrightRed,
                    fontSize = 12.sp,
                    fontWeight = FontWeight.Bold,
                    modifier = Modifier.clickable { onNavigate(NavDestination.LIBRARY) }
                )
            }

            Spacer(modifier = Modifier.height(12.dp))

            LazyRow(
                contentPadding = PaddingValues(horizontal = 20.dp),
                horizontalArrangement = Arrangement.spacedBy(14.dp)
            ) {
                items(allSongs) { song ->
                    AlbumCard(
                        song = song,
                        onClick = { onSongSelect(song) }
                    )
                }
            }

            Spacer(modifier = Modifier.height(28.dp))
        }

        // 5. For You Section
        item {
            Text(
                text = "For You",
                color = TextPrimary,
                fontSize = 17.sp,
                fontWeight = FontWeight.Bold,
                modifier = Modifier.padding(horizontal = 20.dp)
            )
            Spacer(modifier = Modifier.height(12.dp))
        }

        items(allSongs.take(4)) { song ->
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
