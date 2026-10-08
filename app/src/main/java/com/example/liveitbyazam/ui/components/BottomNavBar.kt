package com.example.liveitbyazam.ui.components

import androidx.compose.animation.animateColorAsState
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Home
import androidx.compose.material.icons.filled.LibraryMusic
import androidx.compose.material.icons.filled.Person
import androidx.compose.material.icons.filled.Search
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.example.liveitbyazam.player.NavDestination
import com.example.liveitbyazam.ui.theme.*

@Composable
fun BottomNavBar(
    currentDestination: NavDestination,
    onNavigate: (NavDestination) -> Unit,
    modifier: Modifier = Modifier
) {
    val items = listOf(
        NavItem("HOME", NavDestination.HOME, Icons.Default.Home),
        NavItem("SEARCH", NavDestination.SEARCH, Icons.Default.Search),
        NavItem("LIBRARY", NavDestination.LIBRARY, Icons.Default.LibraryMusic),
        NavItem("PROFILE", NavDestination.PROFILE, Icons.Default.Person)
    )

    Box(
        modifier = modifier
            .fillMaxWidth()
            .background(SecondaryBackground)
            .padding(vertical = 8.dp, horizontal = 12.dp)
    ) {
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.SpaceAround,
            verticalAlignment = Alignment.CenterVertically
        ) {
            items.forEach { item ->
                val isSelected = currentDestination == item.destination
                val iconColor by animateColorAsState(
                    targetValue = if (isSelected) PrimaryRed else TextSecondary,
                    label = "nav_icon_color"
                )
                val textColor by animateColorAsState(
                    targetValue = if (isSelected) TextPrimary else TextMuted,
                    label = "nav_text_color"
                )

                Column(
                    horizontalAlignment = Alignment.CenterHorizontally,
                    verticalArrangement = Arrangement.Center,
                    modifier = Modifier
                        .clip(RoundedCornerShape(12.dp))
                        .clickable { onNavigate(item.destination) }
                        .padding(horizontal = 16.dp, vertical = 6.dp)
                ) {
                    Icon(
                        imageVector = item.icon,
                        contentDescription = item.label,
                        tint = iconColor,
                        modifier = Modifier.size(24.dp)
                    )
                    Spacer(modifier = Modifier.height(4.dp))
                    Text(
                        text = item.label,
                        color = textColor,
                        fontSize = 10.sp,
                        fontWeight = if (isSelected) FontWeight.Bold else FontWeight.Medium,
                        letterSpacing = 1.sp
                    )

                    if (isSelected) {
                        Spacer(modifier = Modifier.height(3.dp))
                        Box(
                            modifier = Modifier
                                .width(14.dp)
                                .height(2.dp)
                                .background(BrightRed, RoundedCornerShape(1.dp))
                        )
                    }
                }
            }
        }
    }
}

private data class NavItem(
    val label: String,
    val destination: NavDestination,
    val icon: ImageVector
)
