package com.example.liveitbyazam.ui.screens

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material.icons.automirrored.filled.VolumeUp
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.example.liveitbyazam.model.AppSettings
import com.example.liveitbyazam.sharingan.SharinganPattern
import com.example.liveitbyazam.sharingan.SharinganView
import com.example.liveitbyazam.ui.theme.*

@Composable
fun SettingsScreen(
    appSettings: AppSettings,
    onSettingsUpdate: (AppSettings) -> Unit,
    onBack: () -> Unit
) {
    var notificationsEnabled by remember { mutableStateOf(true) }

    LazyColumn(
        modifier = Modifier
            .fillMaxSize()
            .background(PrimaryBackground),
        contentPadding = PaddingValues(start = 20.dp, end = 20.dp, bottom = 120.dp),
        verticalArrangement = Arrangement.spacedBy(10.dp)
    ) {
        item {
            // Top Header Bar matching Mockup #13
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(vertical = 16.dp),
                verticalAlignment = Alignment.CenterVertically
            ) {
                IconButton(onClick = onBack) {
                    Icon(imageVector = Icons.AutoMirrored.Filled.ArrowBack, contentDescription = "Back", tint = TextPrimary)
                }
                Spacer(modifier = Modifier.width(12.dp))
                Text(text = "Settings", color = TextPrimary, fontSize = 20.sp, fontWeight = FontWeight.Bold)
            }
        }

        item {
            SettingsIconValueRow(
                icon = Icons.Default.Visibility,
                title = "Theme",
                value = "Red Uchiha (Default)"
            )
        }

        item {
            SettingsIconValueRow(
                icon = Icons.Default.MusicNote,
                title = "Playback",
                value = ""
            )
        }

        item {
            SettingsIconValueRow(
                icon = Icons.AutoMirrored.Filled.VolumeUp,
                title = "Audio Quality",
                value = "High"
            )
        }

        item {
            SettingsIconValueRow(
                icon = Icons.Default.Download,
                title = "Downloads",
                value = ""
            )
        }

        item {
            SettingsIconValueRow(
                icon = Icons.Default.MotionPhotosAuto,
                title = "Custom Animation",
                value = "Sharingan (Default)"
            )
        }

        item {
            // Notifications Toggle Row matching Mockup #13
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .clip(RoundedCornerShape(12.dp))
                    .background(CardBackground)
                    .padding(horizontal = 16.dp, vertical = 14.dp),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Row(verticalAlignment = Alignment.CenterVertically) {
                    Icon(imageVector = Icons.Default.Notifications, contentDescription = null, tint = TextSecondary, modifier = Modifier.size(20.dp))
                    Spacer(modifier = Modifier.width(14.dp))
                    Text(text = "Notifications", color = TextPrimary, fontSize = 14.sp, fontWeight = FontWeight.SemiBold)
                }
                Switch(
                    checked = notificationsEnabled,
                    onCheckedChange = { notificationsEnabled = it },
                    colors = SwitchDefaults.colors(
                        checkedThumbColor = TextPrimary,
                        checkedTrackColor = PrimaryRed,
                        uncheckedThumbColor = TextMuted,
                        uncheckedTrackColor = SurfaceElevated
                    )
                )
            }
        }

        item {
            SettingsIconValueRow(
                icon = Icons.Default.SdCard,
                title = "Data & Storage",
                value = ""
            )
        }

        item {
            SettingsIconValueRow(
                icon = Icons.Default.Language,
                title = "Language",
                value = ""
            )
        }

        item {
            SettingsIconValueRow(
                icon = Icons.Default.Info,
                title = "About",
                value = ""
            )
        }
    }
}

@Composable
private fun SettingsIconValueRow(
    icon: ImageVector,
    title: String,
    value: String
) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .clip(RoundedCornerShape(12.dp))
            .background(CardBackground)
            .padding(horizontal = 16.dp, vertical = 14.dp),
        horizontalArrangement = Arrangement.SpaceBetween,
        verticalAlignment = Alignment.CenterVertically
    ) {
        Row(verticalAlignment = Alignment.CenterVertically) {
            Icon(imageVector = icon, contentDescription = title, tint = TextSecondary, modifier = Modifier.size(20.dp))
            Spacer(modifier = Modifier.width(14.dp))
            Column {
                Text(text = title, color = TextPrimary, fontSize = 14.sp, fontWeight = FontWeight.SemiBold)
                if (value.isNotEmpty()) {
                    Text(text = value, color = TextSecondary, fontSize = 11.sp)
                }
            }
        }
        Icon(imageVector = Icons.Default.ChevronRight, contentDescription = null, tint = TextMuted, modifier = Modifier.size(18.dp))
    }
}
