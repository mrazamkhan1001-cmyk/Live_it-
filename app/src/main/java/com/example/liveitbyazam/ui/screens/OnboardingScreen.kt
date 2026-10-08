package com.example.liveitbyazam.ui.screens

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowForward
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.Text
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.example.liveitbyazam.sharingan.SharinganPattern
import com.example.liveitbyazam.sharingan.SharinganView
import com.example.liveitbyazam.ui.theme.*

@Composable
fun OnboardingScreen(
    onFinishOnboarding: () -> Unit
) {
    var currentPage by remember { mutableIntStateOf(0) }

    val pages = listOf(
        OnboardingPageData(
            headline = "MUSIC\nHITS DIFFERENT\nHERE.",
            description = "Step into a world where music meets emotion.",
            pattern = SharinganPattern.ONE_TOMOE
        ),
        OnboardingPageData(
            headline = "SAME SOULS\nDIFFERENT BEATS.",
            description = "Every listener is an Uchiha.",
            pattern = SharinganPattern.ITACHI_MANGEKYOU
        ),
        OnboardingPageData(
            headline = "LIVE IT\nBY AZAM",
            description = "YOU ARE ALREADY UNDER MY GENJUTSU.",
            pattern = SharinganPattern.ETERNAL_MANGEKYOU
        )
    )

    val page = pages[currentPage]

    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(PrimaryBackground)
            .padding(24.dp)
    ) {
        // Top Header with Skip button
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(top = 16.dp),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment = Alignment.CenterVertically
        ) {
            Text(
                text = "LIVE IT",
                color = TextPrimary,
                fontSize = 18.sp,
                fontWeight = FontWeight.Black,
                letterSpacing = 2.sp
            )
            Text(
                text = "Skip",
                color = TextSecondary,
                fontSize = 13.sp,
                modifier = Modifier.clickable { onFinishOnboarding() }
            )
        }

        // Center Sharingan Eye Visual & Headlines
        Column(
            horizontalAlignment = Alignment.Start,
            verticalArrangement = Arrangement.Center,
            modifier = Modifier
                .fillMaxSize()
                .padding(bottom = 60.dp)
        ) {
            Box(
                modifier = Modifier.fillMaxWidth(),
                contentAlignment = Alignment.Center
            ) {
                SharinganView(
                    pattern = page.pattern,
                    isPlaying = true,
                    sizeDp = 250.dp,
                    glowIntensity = 1.2f
                )
            }

            Spacer(modifier = Modifier.height(40.dp))

            Text(
                text = page.headline,
                color = TextPrimary,
                fontSize = 28.sp,
                fontWeight = FontWeight.Black,
                lineHeight = 34.sp,
                letterSpacing = 1.sp
            )

            Spacer(modifier = Modifier.height(12.dp))

            Text(
                text = page.description,
                color = if (currentPage == 2) BrightRed else TextSecondary,
                fontSize = 14.sp,
                fontWeight = if (currentPage == 2) FontWeight.Bold else FontWeight.Normal,
                lineHeight = 20.sp
            )
        }

        // Bottom Navigation Bar with Dots & Red Circular Arrow Button
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .align(Alignment.BottomCenter)
                .padding(bottom = 20.dp),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment = Alignment.CenterVertically
        ) {
            // Dots Indicator
            Row(verticalAlignment = Alignment.CenterVertically) {
                pages.indices.forEach { index ->
                    Box(
                        modifier = Modifier
                            .padding(end = 6.dp)
                            .size(if (index == currentPage) 8.dp else 6.dp)
                            .clip(CircleShape)
                            .background(if (index == currentPage) BrightRed else SurfaceElevated)
                    )
                }
            }

            // Red Circular Action Button with Arrow matching mock-up
            Box(
                modifier = Modifier
                    .size(54.dp)
                    .clip(CircleShape)
                    .background(PrimaryRed)
                    .clickable {
                        if (currentPage < pages.size - 1) {
                            currentPage++
                        } else {
                            onFinishOnboarding()
                        }
                    },
                contentAlignment = Alignment.Center
            ) {
                Icon(
                    imageVector = Icons.AutoMirrored.Filled.ArrowForward,
                    contentDescription = "Next",
                    tint = TextPrimary,
                    modifier = Modifier.size(24.dp)
                )
            }
        }
    }
}

private data class OnboardingPageData(
    val headline: String,
    val description: String,
    val pattern: SharinganPattern
)
