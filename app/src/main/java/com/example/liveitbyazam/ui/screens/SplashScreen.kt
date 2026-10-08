package com.example.liveitbyazam.ui.screens

import androidx.compose.animation.core.*
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.material3.Text
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.alpha
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.example.liveitbyazam.sharingan.SharinganPattern
import com.example.liveitbyazam.sharingan.SharinganView
import com.example.liveitbyazam.ui.theme.*
import kotlinx.coroutines.delay

@Composable
fun SplashScreen(
    onSplashFinished: () -> Unit
) {
    var animStage by remember { mutableIntStateOf(0) }

    val logoAlpha by animateFloatAsState(
        targetValue = if (animStage >= 1) 1f else 0f,
        animationSpec = tween(1000, easing = FastOutSlowInEasing),
        label = "logo_alpha"
    )

    val sloganAlpha by animateFloatAsState(
        targetValue = if (animStage >= 2) 1f else 0f,
        animationSpec = tween(1000, easing = FastOutSlowInEasing),
        label = "slogan_alpha"
    )

    LaunchedEffect(Unit) {
        delay(600)
        animStage = 1
        delay(800)
        animStage = 2
        delay(1600)
        onSplashFinished()
    }

    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(PrimaryBackground),
        contentAlignment = Alignment.Center
    ) {
        Column(
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.Center,
            modifier = Modifier.padding(24.dp)
        ) {
            // Sharingan Eye Centerpiece
            SharinganView(
                pattern = SharinganPattern.ETERNAL_MANGEKYOU,
                isPlaying = true,
                sizeDp = 180.dp,
                glowIntensity = 1.2f,
                rotationSpeedMultiplier = 1.5f
            )

            Spacer(modifier = Modifier.height(32.dp))

            // Branding LIVE IT BY AZAM
            Column(
                horizontalAlignment = Alignment.CenterHorizontally,
                modifier = Modifier.alpha(logoAlpha)
            ) {
                Text(
                    text = "LIVE IT",
                    color = TextPrimary,
                    fontSize = 38.sp,
                    fontWeight = FontWeight.Black,
                    letterSpacing = 4.sp
                )
                Text(
                    text = "BY AZAM",
                    color = BrightRed,
                    fontSize = 16.sp,
                    fontWeight = FontWeight.Bold,
                    letterSpacing = 3.sp
                )
            }

            Spacer(modifier = Modifier.height(24.dp))

            // Official Slogan
            Text(
                text = "YOU ARE ALREADY UNDER MY GENJUTSU.",
                color = TextSecondary,
                fontSize = 12.sp,
                fontWeight = FontWeight.Medium,
                letterSpacing = 1.5.sp,
                modifier = Modifier.alpha(sloganAlpha)
            )
        }
    }
}
