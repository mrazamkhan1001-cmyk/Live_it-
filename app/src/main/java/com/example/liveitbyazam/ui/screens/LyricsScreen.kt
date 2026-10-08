package com.example.liveitbyazam.ui.screens

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.itemsIndexed
import androidx.compose.foundation.lazy.rememberLazyListState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.Text
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.example.liveitbyazam.model.Song
import com.example.liveitbyazam.sharingan.SharinganView
import com.example.liveitbyazam.ui.theme.*

@Composable
fun LyricsScreen(
    song: Song?,
    playbackPositionMs: Long,
    onBack: () -> Unit
) {
    if (song == null) return

    val lyricsRaw = song.lyrics ?: """
        [00:05.00] Look out for yourself
        [00:10.00] I wake up to the sounds of the silence that allows
        [00:16.00] For my mind to run around with my ear up
        [00:22.00] To the ground I'm searching to behold the stories that are told
        [00:28.00] When my back is to the world that was smiling when I turned
        [00:35.00] Tell you you're the greatest, but once you turn they hate us
        [00:42.00] Oh, the misery! Everybody wants to be my enemy!
        [00:50.00] Spare the sympathy, everybody wants to be my enemy!
        [00:58.00] YOU ARE ALREADY UNDER MY GENJUTSU.
    """.trimIndent()

    val parsedLyrics = remember(lyricsRaw) {
        lyricsRaw.lines().mapNotNull { line ->
            val trimmed = line.trim()
            if (trimmed.isEmpty()) null
            else {
                val timestampRegex = Regex("\\[(\\d{2}):(\\d{2})\\.(\\d{2})\\]")
                val match = timestampRegex.find(trimmed)
                if (match != null) {
                    val min = match.groupValues[1].toLongOrNull() ?: 0L
                    val sec = match.groupValues[2].toLongOrNull() ?: 0L
                    val ms = (min * 60 + sec) * 1000L
                    val text = trimmed.replace(timestampRegex, "").trim()
                    LyricLine(ms, text)
                } else {
                    LyricLine(0L, trimmed)
                }
            }
        }
    }

    val activeIndex = remember(playbackPositionMs, parsedLyrics) {
        val idx = parsedLyrics.indexOfLast { it.timestampMs <= playbackPositionMs }
        if (idx < 0) 0 else idx
    }

    val listState = rememberLazyListState()

    LaunchedEffect(activeIndex) {
        if (parsedLyrics.isNotEmpty() && activeIndex in parsedLyrics.indices) {
            listState.animateScrollToItem(activeIndex)
        }
    }

    val totalMs = song.durationMs.coerceAtLeast(1L)
    val progressRatio = (playbackPositionMs.toFloat() / totalMs.toFloat()).coerceIn(0f, 1f)

    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(PrimaryBackground)
    ) {
        // Top Bar Header matching Mockup #10
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
                text = "Lyrics",
                color = TextPrimary,
                fontSize = 18.sp,
                fontWeight = FontWeight.Bold
            )
        }

        // Song Metadata Card Header matching Mockup #10
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = 20.dp, vertical = 8.dp)
                .clip(RoundedCornerShape(12.dp))
                .background(CardBackground)
                .padding(12.dp),
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
                    isPlaying = true,
                    sizeDp = 38.dp,
                    glowIntensity = 0.5f
                )
            }
            Spacer(modifier = Modifier.width(12.dp))
            Column {
                Text(
                    text = song.title,
                    color = TextPrimary,
                    fontSize = 15.sp,
                    fontWeight = FontWeight.Bold
                )
                Text(
                    text = song.artist,
                    color = TextSecondary,
                    fontSize = 12.sp
                )
            }
        }

        Spacer(modifier = Modifier.height(16.dp))

        // Lyrics Lines List matching Mockup #10
        LazyColumn(
            state = listState,
            contentPadding = PaddingValues(horizontal = 24.dp, vertical = 16.dp),
            verticalArrangement = Arrangement.spacedBy(16.dp),
            modifier = Modifier.weight(1f)
        ) {
            itemsIndexed(parsedLyrics) { index, line ->
                val isActive = index == activeIndex

                Text(
                    text = line.text,
                    color = if (isActive) BrightRed else TextPrimary.copy(alpha = 0.45f),
                    fontSize = if (isActive) 19.sp else 16.sp,
                    fontWeight = if (isActive) FontWeight.Black else FontWeight.Medium,
                    lineHeight = if (isActive) 26.sp else 22.sp
                )
            }
        }

        // Bottom Progress Indicator Bar matching Mockup #10
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = 20.dp, vertical = 12.dp)
        ) {
            Box(
                modifier = Modifier
                    .fillMaxWidth()
                    .height(3.dp)
                    .background(SurfaceElevated)
            ) {
                Box(
                    modifier = Modifier
                        .fillMaxHeight()
                        .fillMaxWidth(progressRatio)
                        .background(BrightRed)
                )
            }
            Spacer(modifier = Modifier.height(6.dp))
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween
            ) {
                val elapsedSec = (playbackPositionMs / 1000) % 60
                val elapsedMin = (playbackPositionMs / (1000 * 60)) % 60
                Text(
                    text = String.format("%d:%02d", elapsedMin, elapsedSec),
                    color = TextSecondary,
                    fontSize = 11.sp
                )
                Text(
                    text = song.formattedDuration(),
                    color = TextSecondary,
                    fontSize = 11.sp
                )
            }
        }
    }
}

private data class LyricLine(
    val timestampMs: Long,
    val text: String
)
