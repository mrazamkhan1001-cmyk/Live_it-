package com.example.liveitbyazam.sharingan

import androidx.compose.animation.core.*
import androidx.compose.foundation.Canvas
import androidx.compose.foundation.clickable
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.size
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.geometry.Rect
import androidx.compose.ui.geometry.Size
import androidx.compose.ui.graphics.*
import androidx.compose.ui.graphics.drawscope.DrawScope
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.graphics.drawscope.rotate
import androidx.compose.ui.graphics.drawscope.scale
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import com.example.liveitbyazam.ui.theme.RedGlow
import com.example.liveitbyazam.ui.theme.SharinganBlack
import com.example.liveitbyazam.ui.theme.SharinganBrightRed
import com.example.liveitbyazam.ui.theme.SharinganRed
import kotlin.math.*
import kotlin.random.Random

/**
 * High-performance, vector-rendered Sharingan animation system.
 * Supports continuous rotation, smooth pattern morphing, red chakra aura, and beat reactivity.
 */
@Composable
fun SharinganView(
    modifier: Modifier = Modifier,
    pattern: SharinganPattern = SharinganPattern.THREE_TOMOE,
    isPlaying: Boolean = true,
    sizeDp: Dp = 260.dp,
    beatPulse: Float = 0f, // 0.0f to 1.0f beat reactivity scale
    glowIntensity: Float = 1.0f,
    rotationSpeedMultiplier: Float = 1.0f,
    onClick: (() -> Unit)? = null
) {
    // Rotation animation
    val infiniteTransition = rememberInfiniteTransition(label = "sharingan_infinite")

    // Rotation angle
    val currentRotation by infiniteTransition.animateFloat(
        initialValue = 0f,
        targetValue = 360f,
        animationSpec = infiniteRepeatable(
            animation = tween(
                durationMillis = (6000 / rotationSpeedMultiplier).toInt().coerceAtLeast(1000),
                easing = LinearEasing
            ),
            repeatMode = RepeatMode.Restart
        ),
        label = "rotation"
    )

    // Smooth speed scaling based on play/pause state
    val targetSpeedFactor = if (isPlaying) 1.0f else 0.05f
    val animatedSpeedFactor by animateFloatAsState(
        targetValue = targetSpeedFactor,
        animationSpec = tween(durationMillis = 800, easing = FastOutSlowInEasing),
        label = "speed_factor"
    )

    // Pattern change morph transition
    var previousPattern by remember { mutableStateOf(pattern) }
    var currentPatternState by remember { mutableStateOf(pattern) }
    var morphProgress by remember { mutableFloatStateOf(1f) }

    LaunchedEffect(pattern) {
        if (pattern != currentPatternState) {
            previousPattern = currentPatternState
            currentPatternState = pattern
            morphProgress = 0f
        }
    }

    LaunchedEffect(morphProgress) {
        if (morphProgress < 1f) {
            val step = 0.05f
            kotlinx.coroutines.delay(16)
            morphProgress = (morphProgress + step).coerceAtMost(1f)
        }
    }

    // Chakra particle simulation data
    val particleCount = 14
    val particles = remember {
        List(particleCount) {
            ParticleData(
                angle = Random.nextFloat() * 360f,
                radiusRatio = 0.55f + Random.nextFloat() * 0.45f,
                speed = 0.5f + Random.nextFloat() * 1.5f,
                size = 2f + Random.nextFloat() * 4f,
                alpha = 0.3f + Random.nextFloat() * 0.7f
            )
        }
    }

    val particleRotation by infiniteTransition.animateFloat(
        initialValue = 0f,
        targetValue = 360f,
        animationSpec = infiniteRepeatable(
            animation = tween(4000, easing = LinearEasing),
            repeatMode = RepeatMode.Restart
        ),
        label = "particles"
    )

    Box(
        modifier = modifier
            .size(sizeDp)
            .then(
                if (onClick != null) {
                    Modifier.clickable(
                        interactionSource = remember { MutableInteractionSource() },
                        indication = null,
                        onClick = onClick
                    )
                } else Modifier
            ),
        contentAlignment = Alignment.Center
    ) {
        Canvas(modifier = Modifier.fillMaxSize()) {
            val center = Offset(size.width / 2f, size.height / 2f)
            val radius = min(size.width, size.height) / 2f * 0.88f

            // 1. Draw Red Atmospheric Chakra Aura / Energy Glow behind eye
            val extraGlowPulse = beatPulse * 0.20f * glowIntensity
            val auraRadius = radius * (1.28f + extraGlowPulse)
            drawCircle(
                brush = Brush.radialGradient(
                    colors = listOf(
                        SharinganBrightRed.copy(alpha = 0.65f * glowIntensity),
                        RedGlow.copy(alpha = 0.35f * glowIntensity),
                        Color(0xFF800000).copy(alpha = 0.15f * glowIntensity),
                        Color.Transparent
                    ),
                    center = center,
                    radius = auraRadius
                ),
                radius = auraRadius,
                center = center
            )

            // 2. Draw Orbiting Chakra Energy Particles
            particles.forEach { p ->
                val pAngle = (p.angle + particleRotation * p.speed) * (PI / 180f)
                val pDist = radius * p.radiusRatio * (1f + beatPulse * 0.1f)
                val px = center.x + cos(pAngle).toFloat() * pDist
                val py = center.y + sin(pAngle).toFloat() * pDist
                drawCircle(
                    color = SharinganBrightRed.copy(alpha = p.alpha * glowIntensity),
                    radius = p.size,
                    center = Offset(px, py)
                )
            }

            // Apply beat pulse scaling
            val currentPulseScale = 1.0f + (beatPulse * 0.06f)
            scale(currentPulseScale, center) {
                // Apply rotation
                val effectiveRotation = currentRotation * animatedSpeedFactor
                rotate(effectiveRotation, center) {

                    // 3. Draw Outer Black Ring Frame
                    drawCircle(
                        color = SharinganBlack,
                        radius = radius,
                        center = center
                    )

                    // Outer Rim Thin Highlight
                    drawCircle(
                        color = SharinganBrightRed.copy(alpha = 0.7f),
                        radius = radius,
                        center = center,
                        style = Stroke(width = radius * 0.025f)
                    )

                    // 4. Draw Crimson Red Iris Gradient
                    val irisRadius = radius * 0.94f
                    drawCircle(
                        brush = Brush.radialGradient(
                            colors = listOf(
                                SharinganBrightRed,
                                SharinganRed,
                                Color(0xFF900000),
                                SharinganBlack
                            ),
                            center = center,
                            radius = irisRadius
                        ),
                        radius = irisRadius,
                        center = center
                    )

                    // Inner Tomoe Ring Track
                    val tomoeTrackRadius = irisRadius * 0.58f
                    drawCircle(
                        color = SharinganBlack.copy(alpha = 0.85f),
                        radius = tomoeTrackRadius,
                        center = center,
                        style = Stroke(width = irisRadius * 0.02f)
                    )

                    // 5. Draw Eye Pattern (with morphing blending if transitioning)
                    if (morphProgress < 1f) {
                        // Blend previous & new pattern
                        drawSharinganPattern(
                            pattern = previousPattern,
                            center = center,
                            radius = irisRadius,
                            alpha = 1f - morphProgress
                        )
                        drawSharinganPattern(
                            pattern = currentPatternState,
                            center = center,
                            radius = irisRadius,
                            alpha = morphProgress
                        )
                    } else {
                        drawSharinganPattern(
                            pattern = currentPatternState,
                            center = center,
                            radius = irisRadius,
                            alpha = 1f
                        )
                    }

                    // 6. Center Black Pupil
                    val pupilRadius = irisRadius * 0.22f
                    drawCircle(
                        color = SharinganBlack,
                        radius = pupilRadius,
                        center = center
                    )

                    // Pupil Inner Red Core Dot
                    drawCircle(
                        color = SharinganBrightRed,
                        radius = pupilRadius * 0.25f,
                        center = center
                    )
                }
            }
        }
    }
}

private fun DrawScope.drawSharinganPattern(
    pattern: SharinganPattern,
    center: Offset,
    radius: Float,
    alpha: Float
) {
    val blackPaint = SharinganBlack.copy(alpha = alpha)

    when (pattern) {
        SharinganPattern.ONE_TOMOE -> {
            drawTomoeCluster(center, radius, count = 1, alpha = alpha)
        }
        SharinganPattern.TWO_TOMOE -> {
            drawTomoeCluster(center, radius, count = 2, alpha = alpha)
        }
        SharinganPattern.THREE_TOMOE -> {
            drawTomoeCluster(center, radius, count = 3, alpha = alpha)
        }
        SharinganPattern.ITACHI_MANGEKYOU -> {
            // Itachi: 3 curved pinwheel blades
            val path = Path()
            val bladeCount = 3
            for (i in 0 until bladeCount) {
                val angleDeg = i * (360f / bladeCount) - 90f
                rotate(angleDeg, center) {
                    path.reset()
                    val startR = radius * 0.20f
                    val endR = radius * 0.88f
                    path.moveTo(center.x, center.y - startR)
                    
                    path.cubicTo(
                        center.x + radius * 0.45f, center.y - radius * 0.35f,
                        center.x + radius * 0.35f, center.y - endR,
                        center.x, center.y - endR
                    )
                    path.cubicTo(
                        center.x - radius * 0.15f, center.y - radius * 0.55f,
                        center.x - radius * 0.10f, center.y - startR,
                        center.x, center.y - startR
                    )
                    drawPath(path, color = blackPaint)
                }
            }
        }
        SharinganPattern.SASUKE_MANGEKYOU -> {
            // Sasuke: 6-pointed star / 3 intersecting elongated black ovals
            val ovalWidth = radius * 0.42f
            val ovalHeight = radius * 1.70f
            for (i in 0 until 3) {
                val angleDeg = i * 60f
                rotate(angleDeg, center) {
                    val rect = Rect(
                        center.x - ovalWidth / 2f,
                        center.y - ovalHeight / 2f,
                        center.x + ovalWidth / 2f,
                        center.y + ovalHeight / 2f
                    )
                    drawOval(
                        color = blackPaint,
                        topLeft = rect.topLeft,
                        size = rect.size,
                        style = Stroke(width = radius * 0.09f)
                    )
                }
            }
        }
        SharinganPattern.MADARA_MANGEKYOU -> {
            // Madara: 3 outer connected black circles/blades around pupil
            val ringDistance = radius * 0.46f
            val ringRadius = radius * 0.28f
            val bladeCount = 3
            for (i in 0 until bladeCount) {
                val angleDeg = i * (360f / bladeCount) - 90f
                val rad = angleDeg * (PI / 180f)
                val cx = center.x + cos(rad).toFloat() * ringDistance
                val cy = center.y + sin(rad).toFloat() * ringDistance

                drawCircle(
                    color = blackPaint,
                    radius = ringRadius,
                    center = Offset(cx, cy)
                )

                // Outer connector ring
                drawCircle(
                    color = blackPaint,
                    radius = radius * 0.52f,
                    center = center,
                    style = Stroke(width = radius * 0.06f)
                )
            }
        }
        SharinganPattern.ETERNAL_MANGEKYOU -> {
            // Eternal Mangekyou: Combined Sasuke star + Itachi pinwheel blades
            drawSharinganPattern(SharinganPattern.SASUKE_MANGEKYOU, center, radius, alpha * 0.85f)
            drawSharinganPattern(SharinganPattern.ITACHI_MANGEKYOU, center, radius, alpha * 0.90f)
        }
    }
}

private fun DrawScope.drawTomoeCluster(
    center: Offset,
    radius: Float,
    count: Int,
    alpha: Float
) {
    val distance = radius * 0.58f
    val tomoeSize = radius * 0.16f

    for (i in 0 until count) {
        val angleDeg = i * (360f / count) - 90f
        val rad = angleDeg * (PI / 180f)
        val tx = center.x + cos(rad).toFloat() * distance
        val ty = center.y + sin(rad).toFloat() * distance

        rotate(angleDeg + 110f, Offset(tx, ty)) {
            // Draw Tomoe Head (Circle)
            drawCircle(
                color = SharinganBlack.copy(alpha = alpha),
                radius = tomoeSize,
                center = Offset(tx, ty)
            )

            // Draw Tomoe Tail (Curved comma tail)
            val tailPath = Path().apply {
                moveTo(tx - tomoeSize * 0.8f, ty)
                cubicTo(
                    tx - tomoeSize * 1.4f, ty + tomoeSize * 0.6f,
                    tx - tomoeSize * 1.8f, ty + tomoeSize * 1.6f,
                    tx - tomoeSize * 0.5f, ty + tomoeSize * 2.1f
                )
                cubicTo(
                    tx - tomoeSize * 0.2f, ty + tomoeSize * 1.4f,
                    tx, ty + tomoeSize * 0.8f,
                    tx + tomoeSize * 0.8f, ty
                )
                close()
            }
            drawPath(tailPath, color = SharinganBlack.copy(alpha = alpha))
        }
    }
}

private data class ParticleData(
    val angle: Float,
    val radiusRatio: Float,
    val speed: Float,
    val size: Float,
    val alpha: Float
)
