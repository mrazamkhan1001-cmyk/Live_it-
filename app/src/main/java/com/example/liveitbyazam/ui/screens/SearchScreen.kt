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
import androidx.compose.material.icons.filled.CallMade
import androidx.compose.material.icons.filled.Clear
import androidx.compose.material.icons.filled.Search
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
fun SearchScreen(
    searchQuery: String,
    selectedCategory: String,
    allSongs: List<Song>,
    currentSong: Song?,
    isPlaying: Boolean,
    onQueryChange: (String) -> Unit,
    onCategorySelect: (String) -> Unit,
    onSongSelect: (Song) -> Unit,
    onFavoriteToggle: (String) -> Unit
) {
    val categories = listOf("All", "Songs", "Artists", "Albums", "Playlists")
    val trendingSearches = listOf(
        "Uchiha Vibes",
        "Anime Songs",
        "Chill Beats",
        "Sad Songs",
        "JID",
        "Naruto OST",
        "Lofi",
        "Imagine Dragons"
    )

    val filteredSongs = allSongs.filter { song ->
        if (searchQuery.isBlank()) true
        else song.title.contains(searchQuery, ignoreCase = true) ||
                song.artist.contains(searchQuery, ignoreCase = true) ||
                song.album.contains(searchQuery, ignoreCase = true)
    }

    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(PrimaryBackground)
    ) {
        // Search Input Box
        Spacer(modifier = Modifier.height(16.dp))

        OutlinedTextField(
            value = searchQuery,
            onValueChange = onQueryChange,
            placeholder = { Text("Search songs, artists, albums...", color = TextSecondary, fontSize = 14.sp) },
            leadingIcon = {
                Icon(
                    imageVector = Icons.Default.Search,
                    contentDescription = "Search",
                    tint = TextSecondary
                )
            },
            trailingIcon = {
                if (searchQuery.isNotEmpty()) {
                    IconButton(onClick = { onQueryChange("") }) {
                        Icon(
                            imageVector = Icons.Default.Clear,
                            contentDescription = "Clear",
                            tint = TextSecondary
                        )
                    }
                }
            },
            colors = OutlinedTextFieldDefaults.colors(
                focusedBorderColor = PrimaryRed,
                unfocusedBorderColor = DividerColor,
                focusedTextColor = TextPrimary,
                unfocusedTextColor = TextPrimary,
                focusedContainerColor = CardBackground,
                unfocusedContainerColor = CardBackground
            ),
            shape = RoundedCornerShape(14.dp),
            singleLine = true,
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = 20.dp)
        )

        Spacer(modifier = Modifier.height(14.dp))

        // Category Filter Chips
        LazyRow(
            contentPadding = PaddingValues(horizontal = 20.dp),
            horizontalArrangement = Arrangement.spacedBy(8.dp)
        ) {
            items(categories) { category ->
                val isSelected = selectedCategory == category
                Box(
                    modifier = Modifier
                        .clip(RoundedCornerShape(20.dp))
                        .background(if (isSelected) PrimaryRed else CardBackground)
                        .border(
                            width = 1.dp,
                            color = if (isSelected) BrightRed else DividerColor,
                            shape = RoundedCornerShape(20.dp)
                        )
                        .clickable { onCategorySelect(category) }
                        .padding(horizontal = 16.dp, vertical = 8.dp)
                ) {
                    Text(
                        text = category,
                        color = if (isSelected) TextPrimary else TextSecondary,
                        fontSize = 13.sp,
                        fontWeight = if (isSelected) FontWeight.Bold else FontWeight.Medium
                    )
                }
            }
        }

        Spacer(modifier = Modifier.height(16.dp))

        // If search query is empty, show Trending Searches list matching Mockup #7
        if (searchQuery.isEmpty()) {
            LazyColumn(
                contentPadding = PaddingValues(start = 20.dp, end = 20.dp, bottom = 120.dp),
                verticalArrangement = Arrangement.spacedBy(12.dp)
            ) {
                item {
                    Text(
                        text = "Trending Searches",
                        color = TextPrimary,
                        fontSize = 16.sp,
                        fontWeight = FontWeight.Bold,
                        modifier = Modifier.padding(vertical = 4.dp)
                    )
                }

                items(trendingSearches) { term ->
                    Row(
                        modifier = Modifier
                            .fillMaxWidth()
                            .clickable { onQueryChange(term) }
                            .padding(vertical = 8.dp),
                        horizontalArrangement = Arrangement.SpaceBetween,
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        Row(verticalAlignment = Alignment.CenterVertically) {
                            Icon(
                                imageVector = Icons.Default.Search,
                                contentDescription = null,
                                tint = TextSecondary,
                                modifier = Modifier.size(18.dp)
                            )
                            Spacer(modifier = Modifier.width(14.dp))
                            Text(
                                text = term,
                                color = TextPrimary,
                                fontSize = 14.sp,
                                fontWeight = FontWeight.Medium
                            )
                        }
                        Icon(
                            imageVector = Icons.Default.CallMade,
                            contentDescription = null,
                            tint = TextMuted,
                            modifier = Modifier.size(16.dp)
                        )
                    }
                }
            }
        } else {
            // Search Results List
            if (filteredSongs.isEmpty()) {
                Box(
                    modifier = Modifier
                        .fillMaxWidth()
                        .weight(1f),
                    contentAlignment = Alignment.Center
                ) {
                    Column(horizontalAlignment = Alignment.CenterHorizontally) {
                        Text(
                            text = "No results found",
                            color = TextPrimary,
                            fontSize = 16.sp,
                            fontWeight = FontWeight.Bold
                        )
                        Spacer(modifier = Modifier.height(4.dp))
                        Text(
                            text = "Try searching for another Uchiha track or artist",
                            color = TextSecondary,
                            fontSize = 12.sp
                        )
                    }
                }
            } else {
                LazyColumn(
                    contentPadding = PaddingValues(start = 20.dp, end = 20.dp, bottom = 120.dp),
                    verticalArrangement = Arrangement.spacedBy(8.dp)
                ) {
                    item {
                        Text(
                            text = "TOP RESULTS",
                            color = TextSecondary,
                            fontSize = 12.sp,
                            fontWeight = FontWeight.Bold,
                            letterSpacing = 1.sp,
                            modifier = Modifier.padding(vertical = 4.dp)
                        )
                    }

                    items(filteredSongs) { song ->
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
