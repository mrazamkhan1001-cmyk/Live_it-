package com.example.liveitbyazam.ui.screens

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.ArrowBack
import androidx.compose.material.icons.filled.Favorite
import androidx.compose.material.icons.filled.PlayArrow
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.example.liveitbyazam.model.Song
import com.example.liveitbyazam.ui.components.SongItemRow
import com.example.liveitbyazam.ui.theme.*

@Composable
fun FavoritesScreen(
    allSongs: List<Song>,
    currentSong: Song?,
    isPlaying: Boolean,
    onSongSelect: (Song) -> Unit,
    onFavoriteToggle: (String) -> Unit,
    onBack: () -> Unit
) {
    val favoriteSongs = allSongs.filter { it.isFavorite }

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
                Text(text = "LIKED SONGS", color = TextPrimary, fontSize = 18.sp, fontWeight = FontWeight.Bold, letterSpacing = 1.sp)
            }
        }

        item {
            Column(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(horizontal = 20.dp),
                horizontalAlignment = Alignment.CenterHorizontally
            ) {
                Box(
                    modifier = Modifier
                        .size(120.dp)
                        .clip(RoundedCornerShape(20.dp))
                        .background(PrimaryRed),
                    contentAlignment = Alignment.Center
                ) {
                    Icon(
                        imageVector = Icons.Default.Favorite,
                        contentDescription = "Heart",
                        tint = TextPrimary,
                        modifier = Modifier.size(60.dp)
                    )
                }

                Spacer(modifier = Modifier.height(16.dp))

                Text(
                    text = "Favorites",
                    color = TextPrimary,
                    fontSize = 24.sp,
                    fontWeight = FontWeight.Black
                )

                Text(
                    text = "${favoriteSongs.size} tracks saved",
                    color = TextSecondary,
                    fontSize = 13.sp
                )

                Spacer(modifier = Modifier.height(16.dp))

                if (favoriteSongs.isNotEmpty()) {
                    Button(
                        onClick = { onSongSelect(favoriteSongs.first()) },
                        colors = ButtonDefaults.buttonColors(containerColor = PrimaryRed),
                        shape = RoundedCornerShape(24.dp),
                        modifier = Modifier.height(46.dp)
                    ) {
                        Icon(imageVector = Icons.Default.PlayArrow, contentDescription = "Play", tint = TextPrimary)
                        Spacer(modifier = Modifier.width(6.dp))
                        Text(text = "PLAY ALL FAVORITES", color = TextPrimary, fontWeight = FontWeight.Bold, fontSize = 13.sp)
                    }
                }

                Spacer(modifier = Modifier.height(20.dp))
            }
        }

        if (favoriteSongs.isEmpty()) {
            item {
                Box(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(top = 40.dp),
                    contentAlignment = Alignment.Center
                ) {
                    Text(text = "No favorite songs yet. Heart a track to add it!", color = TextSecondary, fontSize = 14.sp)
                }
            }
        } else {
            items(favoriteSongs) { song ->
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
}
