package com.example.liveitbyazam.ui.components

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.example.liveitbyazam.model.Artist
import com.example.liveitbyazam.model.Playlist
import com.example.liveitbyazam.model.Song
import com.example.liveitbyazam.sharingan.SharinganPattern
import com.example.liveitbyazam.sharingan.SharinganView
import com.example.liveitbyazam.ui.theme.*

@Composable
fun QuickAccessCard(
    title: String,
    icon: ImageVector,
    onClick: () -> Unit,
    modifier: Modifier = Modifier
) {
    Row(
        modifier = modifier
            .clip(RoundedCornerShape(12.dp))
            .background(CardBackground)
            .border(1.dp, DividerColor, RoundedCornerShape(12.dp))
            .clickable { onClick() }
            .padding(horizontal = 14.dp, vertical = 12.dp),
        verticalAlignment = Alignment.CenterVertically
    ) {
        Icon(
            imageVector = icon,
            contentDescription = title,
            tint = BrightRed,
            modifier = Modifier.size(20.dp)
        )
        Spacer(modifier = Modifier.width(10.dp))
        Text(
            text = title,
            color = TextPrimary,
            fontSize = 13.sp,
            fontWeight = FontWeight.Bold,
            maxLines = 1
        )
    }
}

@Composable
fun AlbumCard(
    song: Song,
    onClick: () -> Unit,
    modifier: Modifier = Modifier
) {
    Column(
        modifier = modifier
            .width(140.dp)
            .clip(RoundedCornerShape(14.dp))
            .background(CardBackground)
            .clickable { onClick() }
            .padding(10.dp)
    ) {
        Box(
            modifier = Modifier
                .fillMaxWidth()
                .height(120.dp)
                .clip(RoundedCornerShape(10.dp))
                .background(
                    Brush.radialGradient(
                        colors = listOf(DarkRed, PrimaryBackground)
                    )
                ),
            contentAlignment = Alignment.Center
        ) {
            SharinganView(
                pattern = song.sharinganPattern,
                isPlaying = false,
                sizeDp = 90.dp,
                glowIntensity = 0.6f
            )
        }

        Spacer(modifier = Modifier.height(8.dp))

        Text(
            text = song.title,
            color = TextPrimary,
            fontSize = 13.sp,
            fontWeight = FontWeight.Bold,
            maxLines = 1,
            overflow = TextOverflow.Ellipsis
        )
        Text(
            text = song.artist,
            color = TextSecondary,
            fontSize = 11.sp,
            maxLines = 1,
            overflow = TextOverflow.Ellipsis
        )
    }
}

@Composable
fun PlaylistCard(
    playlist: Playlist,
    onClick: () -> Unit,
    modifier: Modifier = Modifier
) {
    Row(
        modifier = modifier
            .fillMaxWidth()
            .clip(RoundedCornerShape(12.dp))
            .background(CardBackground)
            .clickable { onClick() }
            .padding(12.dp),
        verticalAlignment = Alignment.CenterVertically
    ) {
        Box(
            modifier = Modifier
                .size(56.dp)
                .clip(RoundedCornerShape(10.dp))
                .background(DarkRed),
            contentAlignment = Alignment.Center
        ) {
            SharinganView(
                pattern = SharinganPattern.ITACHI_MANGEKYOU,
                isPlaying = false,
                sizeDp = 48.dp,
                glowIntensity = 0.5f
            )
        }

        Spacer(modifier = Modifier.width(14.dp))

        Column(modifier = Modifier.weight(1f)) {
            Text(
                text = playlist.name,
                color = TextPrimary,
                fontSize = 15.sp,
                fontWeight = FontWeight.Bold
            )
            Spacer(modifier = Modifier.height(2.dp))
            Text(
                text = "${playlist.songs.size} tracks • ${playlist.description}",
                color = TextSecondary,
                fontSize = 12.sp,
                maxLines = 1,
                overflow = TextOverflow.Ellipsis
            )
        }
    }
}

@Composable
fun ArtistCard(
    artist: Artist,
    onClick: () -> Unit,
    modifier: Modifier = Modifier
) {
    Column(
        modifier = modifier
            .width(120.dp)
            .clickable { onClick() },
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        Box(
            modifier = Modifier
                .size(90.dp)
                .clip(RoundedCornerShape(45.dp))
                .background(SurfaceElevated)
                .border(2.dp, PrimaryRed, RoundedCornerShape(45.dp)),
            contentAlignment = Alignment.Center
        ) {
            SharinganView(
                pattern = SharinganPattern.SASUKE_MANGEKYOU,
                isPlaying = false,
                sizeDp = 70.dp,
                glowIntensity = 0.7f
            )
        }
        Spacer(modifier = Modifier.height(6.dp))
        Text(
            text = artist.name,
            color = TextPrimary,
            fontSize = 13.sp,
            fontWeight = FontWeight.Bold,
            maxLines = 1,
            overflow = TextOverflow.Ellipsis
        )
        Text(
            text = "${artist.songCount} tracks",
            color = TextSecondary,
            fontSize = 11.sp
        )
    }
}
