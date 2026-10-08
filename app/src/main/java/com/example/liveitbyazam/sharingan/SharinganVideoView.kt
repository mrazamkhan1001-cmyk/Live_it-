package com.example.liveitbyazam.sharingan

import android.graphics.drawable.GradientDrawable
import android.net.Uri
import androidx.compose.animation.core.*
import androidx.compose.foundation.Canvas
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.scale
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import androidx.compose.ui.viewinterop.AndroidView
import androidx.media3.common.MediaItem
import androidx.media3.common.Player
import androidx.media3.exoplayer.ExoPlayer
import androidx.media3.ui.AspectRatioFrameLayout
import androidx.media3.ui.PlayerView
import com.example.liveitbyazam.R
import kotlin.math.PI
import kotlin.math.cos
import kotlin.math.min
import kotlin.math.sin
import kotlin.random.Random

// Master Color Palette for Unified Sharingan Glow
private val BrightRedHighlight = Color(0xFFD00010)
private val PrimaryGlowRed = Color(0xFFB0000A)
private val DeepCrimsonRed = Color(0xFF6D0005)
private val DarkBackground = Color(0xFF050505)

/**
 * Premium Cinematic Sharingan Video Player for LIVE IT BY AZAM.
 * Features 100% circular video masking without any artificial hard outer border rings.
 * The soft red energy glow originates naturally from the Sharingan eye itself,
 * blending smoothly into the #050505 dark background.
 */
@Composable
fun SharinganVideoView(
    modifier: Modifier = Modifier,
    videoResId: Int = R.raw.sharingan,
    isPlaying: Boolean = true,
    sizeDp: Dp = 280.dp,
    beatPulse: Float = 0f,
    glowIntensity: Float = 1.2f,
    onClick: (() -> Unit)? = null
) {
    val context = LocalContext.current

    // Initialize ExoPlayer instance efficiently, reusing across recompositions
    val exoPlayer = remember(context) {
        ExoPlayer.Builder(context).build().apply {
            repeatMode = Player.REPEAT_MODE_ALL
            volume = 0f // Mute video completely; audio comes strictly from music track
        }
    }

    // Extensible MediaItem loading (supports future sharingan_01.mp4, sharingan_02.mp4 etc.)
    LaunchedEffect(videoResId) {
        val videoUri = Uri.parse("android.resource://${context.packageName}/$videoResId")
        val mediaItem = MediaItem.fromUri(videoUri)
        exoPlayer.setMediaItem(mediaItem)
        exoPlayer.prepare()
        if (isPlaying) {
            exoPlayer.play()
        }
    }

    // Synchronize video play/pause with music playback state
    LaunchedEffect(isPlaying) {
        if (isPlaying) {
            exoPlayer.play()
        } else {
            exoPlayer.pause()
        }
    }

    DisposableEffect(Unit) {
        onDispose {
            exoPlayer.release()
        }
    }

    // Subtle Orbiting Red Chakra Energy Particle System
    val particleCount = 10
    val particles = remember {
        List(particleCount) {
            ChakraParticle(
                angle = Random.nextFloat() * 360f,
                radiusRatio = 0.52f + Random.nextFloat() * 0.40f,
                speed = 0.5f + Random.nextFloat() * 1.2f,
                size = 2.0f + Random.nextFloat() * 3.0f,
                alpha = 0.25f + Random.nextFloat() * 0.50f
            )
        }
    }

    val infiniteTransition = rememberInfiniteTransition(label = "chakra_particle_anim")
    val particleRotation by infiniteTransition.animateFloat(
        initialValue = 0f,
        targetValue = 360f,
        animationSpec = infiniteRepeatable(
            animation = tween(5000, easing = LinearEasing),
            repeatMode = RepeatMode.Restart
        ),
        label = "particle_rotation"
    )

    Box(
        modifier = modifier
            .size(sizeDp)
            .then(if (onClick != null) Modifier.clickable { onClick() } else Modifier),
        contentAlignment = Alignment.Center
    ) {
        // 1. Soft Atmospheric Red Glow emanating from the Sharingan (NO hard outer border)
        Canvas(modifier = Modifier.fillMaxSize()) {
            val center = Offset(size.width / 2f, size.height / 2f)
            val radius = min(size.width, size.height) / 2f * 0.86f

            // Multi-stage Soft Radial Gradient Glow blending into #050505
            val pulseRadius = radius * (1.35f + (beatPulse * 0.12f))
            drawCircle(
                brush = Brush.radialGradient(
                    colors = listOf(
                        BrightRedHighlight.copy(alpha = 0.38f * glowIntensity),
                        PrimaryGlowRed.copy(alpha = 0.22f * glowIntensity),
                        DeepCrimsonRed.copy(alpha = 0.10f * glowIntensity),
                        DarkBackground.copy(alpha = 0.0f)
                    ),
                    center = center,
                    radius = pulseRadius
                ),
                radius = pulseRadius,
                center = center
            )

            // Subtle Orbiting Energy Particles fading into aura
            particles.forEach { p ->
                val pAngle = (p.angle + particleRotation * p.speed) * (PI / 180f)
                val pDist = radius * p.radiusRatio * (1f + beatPulse * 0.06f)
                val px = center.x + cos(pAngle).toFloat() * pDist
                val py = center.y + sin(pAngle).toFloat() * pDist
                drawCircle(
                    color = BrightRedHighlight.copy(alpha = p.alpha * glowIntensity),
                    radius = p.size,
                    center = Offset(px, py)
                )
            }
        }

        // 2. Pure Circular Video Mask (NO hard border ring, seamless edge integration)
        Box(
            modifier = Modifier
                .size(sizeDp * 0.88f)
                .clip(CircleShape)
                .background(DarkBackground),
            contentAlignment = Alignment.Center
        ) {
            AndroidView(
                factory = { ctx ->
                    PlayerView(ctx).apply {
                        player = exoPlayer
                        useController = false
                        resizeMode = AspectRatioFrameLayout.RESIZE_MODE_ZOOM
                        setShutterBackgroundColor(android.graphics.Color.parseColor("#050505"))

                        // Native View Layer Oval Mask Clipping
                        val circleDrawable = GradientDrawable().apply {
                            shape = GradientDrawable.OVAL
                            setColor(android.graphics.Color.parseColor("#050505"))
                        }
                        background = circleDrawable
                        clipToOutline = true
                    }
                },
                modifier = Modifier
                    .fillMaxSize()
                    .scale(1.02f)
                    .clip(CircleShape)
            )
        }
    }
}

private data class ChakraParticle(
    val angle: Float,
    val radiusRatio: Float,
    val speed: Float,
    val size: Float,
    val alpha: Float
)
