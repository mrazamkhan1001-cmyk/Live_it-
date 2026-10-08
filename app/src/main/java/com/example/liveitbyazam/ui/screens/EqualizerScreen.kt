package com.example.liveitbyazam.ui.screens

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyRow
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.TransformOrigin
import androidx.compose.ui.graphics.graphicsLayer
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.example.liveitbyazam.model.EqualizerSettings
import com.example.liveitbyazam.ui.theme.*

@Composable
fun EqualizerScreen(
    settings: EqualizerSettings,
    onPresetSelect: (String) -> Unit,
    onBandChange: (Int, Float) -> Unit,
    onBack: () -> Unit
) {
    val presets = listOf("Custom", "Rock", "Pop", "Hip Hop", "Bass Boost", "Vocal", "Normal")

    var isBassBoostEnabled by remember { mutableStateOf(true) }
    var isVirtualizerEnabled by remember { mutableStateOf(false) }
    var isLoudnessEnabled by remember { mutableStateOf(true) }

    val bands = listOf(
        Pair("60", settings.band60Hz),
        Pair("230", settings.band230Hz),
        Pair("910", settings.band910Hz),
        Pair("3.6K", settings.band3k6Hz),
        Pair("14K", settings.band14kHz)
    )

    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(PrimaryBackground)
            .padding(horizontal = 20.dp)
    ) {
        // Top Header
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(vertical = 16.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            IconButton(onClick = onBack) {
                Icon(
                    imageVector = Icons.AutoMirrored.Filled.ArrowBack,
                    contentDescription = "Back",
                    tint = TextPrimary
                )
            }
            Spacer(modifier = Modifier.width(12.dp))
            Text(
                text = "Equalizer",
                color = TextPrimary,
                fontSize = 20.sp,
                fontWeight = FontWeight.Bold
            )
        }

        Spacer(modifier = Modifier.height(8.dp))

        // Preset Chips Selector
        LazyRow(
            horizontalArrangement = Arrangement.spacedBy(8.dp)
        ) {
            items(presets) { preset ->
                val isSelected = settings.preset == preset
                Box(
                    modifier = Modifier
                        .clip(RoundedCornerShape(16.dp))
                        .background(if (isSelected) PrimaryRed else CardBackground)
                        .border(1.dp, if (isSelected) BrightRed else DividerColor, RoundedCornerShape(16.dp))
                        .clickable { onPresetSelect(preset) }
                        .padding(horizontal = 16.dp, vertical = 8.dp)
                ) {
                    Text(
                        text = preset,
                        color = if (isSelected) TextPrimary else TextSecondary,
                        fontSize = 13.sp,
                        fontWeight = if (isSelected) FontWeight.Bold else FontWeight.Medium
                    )
                }
            }
        }

        Spacer(modifier = Modifier.height(24.dp))

        // 5-Band Red Sliders Card
        Box(
            modifier = Modifier
                .fillMaxWidth()
                .clip(RoundedCornerShape(16.dp))
                .background(CardBackground)
                .border(1.dp, DividerColor, RoundedCornerShape(16.dp))
                .padding(20.dp)
        ) {
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .height(220.dp),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                bands.forEachIndexed { index, band ->
                    Column(
                        horizontalAlignment = Alignment.CenterHorizontally,
                        verticalArrangement = Arrangement.SpaceBetween,
                        modifier = Modifier
                            .weight(1f)
                            .fillMaxHeight()
                    ) {
                        // Vertical Red Slider
                        Box(
                            modifier = Modifier
                                .weight(1f)
                                .width(36.dp),
                            contentAlignment = Alignment.Center
                        ) {
                            Slider(
                                value = band.second,
                                onValueChange = { onBandChange(index, it) },
                                valueRange = -10f..10f,
                                colors = SliderDefaults.colors(
                                    thumbColor = BrightRed,
                                    activeTrackColor = PrimaryRed,
                                    inactiveTrackColor = SurfaceElevated
                                ),
                                modifier = Modifier
                                    .graphicsLayer {
                                        rotationZ = -90f
                                        transformOrigin = TransformOrigin(0.5f, 0.5f)
                                    }
                                    .width(170.dp)
                            )
                        }

                        Spacer(modifier = Modifier.height(8.dp))

                        Text(
                            text = band.first,
                            color = TextSecondary,
                            fontSize = 12.sp,
                            fontWeight = FontWeight.Medium
                        )
                    }
                }
            }
        }

        Spacer(modifier = Modifier.height(24.dp))

        // Extra Audio Effect Toggles matching mock-up (Bass Boost, Virtualizer, Loudness)
        EqualizerToggleRow(
            title = "Bass Boost",
            isChecked = isBassBoostEnabled,
            onCheckedChange = { isBassBoostEnabled = it }
        )
        Spacer(modifier = Modifier.height(10.dp))
        EqualizerToggleRow(
            title = "Virtualizer",
            isChecked = isVirtualizerEnabled,
            onCheckedChange = { isVirtualizerEnabled = it }
        )
        Spacer(modifier = Modifier.height(10.dp))
        EqualizerToggleRow(
            title = "Loudness",
            isChecked = isLoudnessEnabled,
            onCheckedChange = { isLoudnessEnabled = it }
        )
    }
}

@Composable
private fun EqualizerToggleRow(
    title: String,
    isChecked: Boolean,
    onCheckedChange: (Boolean) -> Unit
) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .clip(RoundedCornerShape(12.dp))
            .background(CardBackground)
            .padding(horizontal = 16.dp, vertical = 12.dp),
        horizontalArrangement = Arrangement.SpaceBetween,
        verticalAlignment = Alignment.CenterVertically
    ) {
        Text(text = title, color = TextPrimary, fontSize = 14.sp, fontWeight = FontWeight.SemiBold)
        Switch(
            checked = isChecked,
            onCheckedChange = onCheckedChange,
            colors = SwitchDefaults.colors(
                checkedThumbColor = TextPrimary,
                checkedTrackColor = PrimaryRed,
                uncheckedThumbColor = TextMuted,
                uncheckedTrackColor = SurfaceElevated
            )
        )
    }
}
