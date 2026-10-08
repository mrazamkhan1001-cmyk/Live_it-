package com.example.liveitbyazam.ui.screens

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.example.liveitbyazam.model.UserProfile
import com.example.liveitbyazam.player.NavDestination
import com.example.liveitbyazam.sharingan.SharinganPattern
import com.example.liveitbyazam.sharingan.SharinganView
import com.example.liveitbyazam.ui.theme.*

@Composable
fun ProfileScreen(
    userProfile: UserProfile,
    onUpdateName: (String) -> Unit,
    onNavigate: (NavDestination) -> Unit
) {
    var showEditDialog by remember { mutableStateOf(false) }
    var nameInput by remember { mutableStateOf(userProfile.rawName) }

    if (showEditDialog) {
        AlertDialog(
            onDismissRequest = { showEditDialog = false },
            title = { Text("Edit Uchiha Identity", color = TextPrimary, fontWeight = FontWeight.Bold) },
            text = {
                Column {
                    Text("Enter your display name:", color = TextSecondary, fontSize = 13.sp)
                    Spacer(modifier = Modifier.height(8.dp))
                    OutlinedTextField(
                        value = nameInput,
                        onValueChange = { nameInput = it },
                        singleLine = true,
                        colors = OutlinedTextFieldDefaults.colors(
                            focusedBorderColor = PrimaryRed,
                            unfocusedBorderColor = DividerColor,
                            focusedTextColor = TextPrimary,
                            unfocusedTextColor = TextPrimary
                        )
                    )
                }
            },
            confirmButton = {
                TextButton(onClick = {
                    onUpdateName(nameInput)
                    showEditDialog = false
                }) {
                    Text("Save Identity", color = BrightRed, fontWeight = FontWeight.Bold)
                }
            },
            dismissButton = {
                TextButton(onClick = { showEditDialog = false }) {
                    Text("Cancel", color = TextSecondary)
                }
            },
            containerColor = CardBackground
        )
    }

    LazyColumn(
        modifier = Modifier
            .fillMaxSize()
            .background(PrimaryBackground),
        contentPadding = PaddingValues(bottom = 120.dp)
    ) {
        // Top Banner Artwork Header matching Mockup #14
        item {
            Box(
                modifier = Modifier
                    .fillMaxWidth()
                    .height(180.dp)
                    .background(
                        Brush.verticalGradient(
                            colors = listOf(DarkRed, PrimaryBackground)
                        )
                    ),
                contentAlignment = Alignment.Center
            ) {
                SharinganView(
                    pattern = SharinganPattern.ETERNAL_MANGEKYOU,
                    isPlaying = true,
                    sizeDp = 140.dp,
                    glowIntensity = 0.8f
                )
            }
        }

        // Avatar, Name, Handle, Edit Button matching Mockup #14
        item {
            Column(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(horizontal = 20.dp),
                horizontalAlignment = Alignment.CenterHorizontally
            ) {
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.Center,
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Box(
                        modifier = Modifier
                            .size(80.dp)
                            .clip(CircleShape)
                            .background(CardBackground)
                            .border(2.dp, PrimaryRed, CircleShape),
                        contentAlignment = Alignment.Center
                    ) {
                        SharinganView(
                            pattern = SharinganPattern.THREE_TOMOE,
                            isPlaying = true,
                            sizeDp = 70.dp,
                            glowIntensity = 0.6f
                        )
                    }
                }

                Spacer(modifier = Modifier.height(10.dp))

                Row(verticalAlignment = Alignment.CenterVertically) {
                    Text(
                        text = userProfile.uchihaDisplayName,
                        color = TextPrimary,
                        fontSize = 22.sp,
                        fontWeight = FontWeight.Black
                    )
                    Spacer(modifier = Modifier.width(10.dp))
                    Box(
                        modifier = Modifier
                            .clip(RoundedCornerShape(12.dp))
                            .background(CardBackground)
                            .border(1.dp, DividerColor, RoundedCornerShape(12.dp))
                            .clickable { showEditDialog = true }
                            .padding(horizontal = 10.dp, vertical = 4.dp)
                    ) {
                        Text(text = "Edit", color = TextSecondary, fontSize = 11.sp, fontWeight = FontWeight.Bold)
                    }
                }

                Text(
                    text = "@${userProfile.rawName.lowercase()}uchiha",
                    color = TextSecondary,
                    fontSize = 12.sp
                )

                Spacer(modifier = Modifier.height(20.dp))

                // Stats Counters matching Mockup #14 (32 Playlists, 248 Songs, 12K Minutes)
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.SpaceEvenly
                ) {
                    ProfileStatItem(number = "32", label = "Playlists")
                    ProfileStatItem(number = "248", label = "Songs")
                    ProfileStatItem(number = "12K", label = "Minutes")
                }

                Spacer(modifier = Modifier.height(16.dp))

                // Centered Official Slogan matching Mockup #14
                Text(
                    text = "\"YOU ARE ALREADY UNDER\nMY GENJUTSU.\"",
                    color = BrightRed,
                    fontSize = 11.sp,
                    fontWeight = FontWeight.Bold,
                    letterSpacing = 1.2.sp,
                    textAlign = androidx.compose.ui.text.style.TextAlign.Center
                )

                Spacer(modifier = Modifier.height(24.dp))
            }
        }

        // Section Rows with Icons matching Mockup #14
        item {
            Column(
                modifier = Modifier.padding(horizontal = 20.dp),
                verticalArrangement = Arrangement.spacedBy(10.dp)
            ) {
                ProfileSectionRow(
                    title = "Liked Songs",
                    subtitle = "128 songs",
                    icon = Icons.Default.Favorite,
                    onClick = { onNavigate(NavDestination.FAVORITES) }
                )
                ProfileSectionRow(
                    title = "My Playlists",
                    subtitle = "12 playlists",
                    icon = Icons.Default.QueueMusic,
                    onClick = { onNavigate(NavDestination.LIBRARY) }
                )
                ProfileSectionRow(
                    title = "Downloads",
                    subtitle = "45 songs",
                    icon = Icons.Default.Download,
                    onClick = { onNavigate(NavDestination.LIBRARY) }
                )
                ProfileSectionRow(
                    title = "Recently Played",
                    subtitle = "",
                    icon = Icons.Default.History,
                    onClick = { onNavigate(NavDestination.LIBRARY) }
                )
                ProfileSectionRow(
                    title = "Artists",
                    subtitle = "",
                    icon = Icons.Default.Person,
                    onClick = { onNavigate(NavDestination.LIBRARY) }
                )
            }
        }
    }
}

@Composable
private fun ProfileStatItem(
    number: String,
    label: String
) {
    Column(horizontalAlignment = Alignment.CenterHorizontally) {
        Text(text = number, color = TextPrimary, fontSize = 18.sp, fontWeight = FontWeight.Black)
        Text(text = label, color = TextSecondary, fontSize = 11.sp)
    }
}

@Composable
private fun ProfileSectionRow(
    title: String,
    subtitle: String,
    icon: ImageVector,
    onClick: () -> Unit
) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .clip(RoundedCornerShape(12.dp))
            .background(CardBackground)
            .clickable { onClick() }
            .padding(14.dp),
        horizontalArrangement = Arrangement.SpaceBetween,
        verticalAlignment = Alignment.CenterVertically
    ) {
        Row(verticalAlignment = Alignment.CenterVertically) {
            Icon(imageVector = icon, contentDescription = title, tint = BrightRed, modifier = Modifier.size(20.dp))
            Spacer(modifier = Modifier.width(14.dp))
            Column {
                Text(text = title, color = TextPrimary, fontSize = 14.sp, fontWeight = FontWeight.Bold)
                if (subtitle.isNotEmpty()) {
                    Text(text = subtitle, color = TextSecondary, fontSize = 11.sp)
                }
            }
        }
        Icon(imageVector = Icons.Default.ChevronRight, contentDescription = null, tint = TextMuted, modifier = Modifier.size(18.dp))
    }
}
