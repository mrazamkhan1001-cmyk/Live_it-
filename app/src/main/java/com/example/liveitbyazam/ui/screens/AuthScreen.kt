package com.example.liveitbyazam.ui.screens

import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Email
import androidx.compose.material.icons.filled.Lock
import androidx.compose.material.icons.filled.Person
import androidx.compose.material.icons.filled.Visibility
import androidx.compose.material.icons.filled.VisibilityOff
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.text.input.PasswordVisualTransformation
import androidx.compose.ui.text.input.VisualTransformation
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.example.liveitbyazam.sharingan.SharinganPattern
import com.example.liveitbyazam.sharingan.SharinganView
import com.example.liveitbyazam.ui.theme.*

@Composable
fun AuthScreen(
    onAuthSuccess: (String) -> Unit
) {
    var isSignUp by remember { mutableStateOf(false) }
    var nameInput by remember { mutableStateOf("Azam") }
    var emailInput by remember { mutableStateOf("") }
    var passwordInput by remember { mutableStateOf("") }
    var isPasswordVisible by remember { mutableStateOf(false) }

    val calculatedUchihaName = remember(nameInput) {
        val trimmed = nameInput.trim()
        if (trimmed.lowercase().endsWith("uchiha")) {
            val words = trimmed.split(" ")
            val base = words.dropLast(1).joinToString(" ").ifEmpty { words.first() }
            "$base Uchiha"
        } else if (trimmed.isEmpty()) {
            "Shinobi Uchiha"
        } else {
            "$trimmed Uchiha"
        }
    }

    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(PrimaryBackground)
            .padding(24.dp)
    ) {
        Column(
            modifier = Modifier.fillMaxSize(),
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.SpaceBetween
        ) {
            // Header Sharingan & Logo
            Column(
                horizontalAlignment = Alignment.CenterHorizontally,
                modifier = Modifier.padding(top = 10.dp)
            ) {
                SharinganView(
                    pattern = SharinganPattern.THREE_TOMOE,
                    isPlaying = true,
                    sizeDp = 90.dp,
                    glowIntensity = 0.9f
                )

                Spacer(modifier = Modifier.height(10.dp))

                Text(
                    text = "LIVE IT",
                    color = TextPrimary,
                    fontSize = 32.sp,
                    fontWeight = FontWeight.Black,
                    letterSpacing = 3.sp
                )
                Text(
                    text = "BY AZAM",
                    color = BrightRed,
                    fontSize = 12.sp,
                    fontWeight = FontWeight.Bold,
                    letterSpacing = 2.sp
                )

                Spacer(modifier = Modifier.height(4.dp))

                Text(
                    text = "YOU ARE ALREADY UNDER\nMY GENJUTSU.",
                    color = TextSecondary,
                    fontSize = 10.sp,
                    letterSpacing = 1.2.sp,
                    fontWeight = FontWeight.Medium,
                    textAlign = androidx.compose.ui.text.style.TextAlign.Center
                )
            }

            // Input Form Card matching Mockup #5
            Column(
                modifier = Modifier.fillMaxWidth()
            ) {
                if (isSignUp) {
                    OutlinedTextField(
                        value = nameInput,
                        onValueChange = { nameInput = it },
                        placeholder = { Text("Display Name", color = TextSecondary, fontSize = 13.sp) },
                        leadingIcon = { Icon(imageVector = Icons.Default.Person, contentDescription = null, tint = TextSecondary) },
                        supportingText = {
                            Text(
                                text = "Identity: $calculatedUchihaName",
                                color = BrightRed,
                                fontSize = 11.sp,
                                fontWeight = FontWeight.Bold
                            )
                        },
                        colors = OutlinedTextFieldDefaults.colors(
                            focusedBorderColor = PrimaryRed,
                            unfocusedBorderColor = DividerColor,
                            focusedTextColor = TextPrimary,
                            unfocusedTextColor = TextPrimary,
                            focusedContainerColor = CardBackground,
                            unfocusedContainerColor = CardBackground
                        ),
                        shape = RoundedCornerShape(12.dp),
                        modifier = Modifier.fillMaxWidth()
                    )
                    Spacer(modifier = Modifier.height(8.dp))
                }

                // Email / Username Input
                OutlinedTextField(
                    value = emailInput,
                    onValueChange = { emailInput = it },
                    placeholder = { Text("Email or Username", color = TextSecondary, fontSize = 13.sp) },
                    leadingIcon = { Icon(imageVector = Icons.Default.Email, contentDescription = null, tint = TextSecondary) },
                    keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Email),
                    colors = OutlinedTextFieldDefaults.colors(
                        focusedBorderColor = PrimaryRed,
                        unfocusedBorderColor = DividerColor,
                        focusedTextColor = TextPrimary,
                        unfocusedTextColor = TextPrimary,
                        focusedContainerColor = CardBackground,
                        unfocusedContainerColor = CardBackground
                    ),
                    shape = RoundedCornerShape(12.dp),
                    modifier = Modifier.fillMaxWidth()
                )

                Spacer(modifier = Modifier.height(10.dp))

                // Password Input
                OutlinedTextField(
                    value = passwordInput,
                    onValueChange = { passwordInput = it },
                    placeholder = { Text("Password", color = TextSecondary, fontSize = 13.sp) },
                    leadingIcon = { Icon(imageVector = Icons.Default.Lock, contentDescription = null, tint = TextSecondary) },
                    trailingIcon = {
                        IconButton(onClick = { isPasswordVisible = !isPasswordVisible }) {
                            Icon(
                                imageVector = if (isPasswordVisible) Icons.Default.Visibility else Icons.Default.VisibilityOff,
                                contentDescription = null,
                                tint = TextSecondary
                            )
                        }
                    },
                    visualTransformation = if (isPasswordVisible) VisualTransformation.None else PasswordVisualTransformation(),
                    keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Password),
                    colors = OutlinedTextFieldDefaults.colors(
                        focusedBorderColor = PrimaryRed,
                        unfocusedBorderColor = DividerColor,
                        focusedTextColor = TextPrimary,
                        unfocusedTextColor = TextPrimary,
                        focusedContainerColor = CardBackground,
                        unfocusedContainerColor = CardBackground
                    ),
                    shape = RoundedCornerShape(12.dp),
                    modifier = Modifier.fillMaxWidth()
                )

                Row(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(top = 6.dp),
                    horizontalArrangement = Arrangement.End
                ) {
                    Text(
                        text = "Forgot Password?",
                        color = BrightRed,
                        fontSize = 11.sp,
                        modifier = Modifier.clickable { }
                    )
                }

                Spacer(modifier = Modifier.height(16.dp))

                // Login Pill Button
                Button(
                    onClick = { onAuthSuccess(calculatedUchihaName) },
                    colors = ButtonDefaults.buttonColors(containerColor = PrimaryRed),
                    shape = RoundedCornerShape(24.dp),
                    modifier = Modifier
                        .fillMaxWidth()
                        .height(48.dp)
                ) {
                    Text(
                        text = if (isSignUp) "Sign Up" else "Login",
                        color = TextPrimary,
                        fontSize = 14.sp,
                        fontWeight = FontWeight.Bold
                    )
                }

                Spacer(modifier = Modifier.height(16.dp))

                // OR Divider
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    HorizontalDivider(modifier = Modifier.weight(1f), color = DividerColor)
                    Text(
                        text = "  OR  ",
                        color = TextSecondary,
                        fontSize = 11.sp,
                        fontWeight = FontWeight.Bold
                    )
                    HorizontalDivider(modifier = Modifier.weight(1f), color = DividerColor)
                }

                Spacer(modifier = Modifier.height(16.dp))

                // Social Buttons matching Mockup #5
                OutlinedButton(
                    onClick = { onAuthSuccess(calculatedUchihaName) },
                    border = BorderStroke(1.dp, DividerColor),
                    shape = RoundedCornerShape(24.dp),
                    colors = ButtonDefaults.outlinedButtonColors(containerColor = CardBackground),
                    modifier = Modifier
                        .fillMaxWidth()
                        .height(44.dp)
                ) {
                    Text(text = "G  Continue with Google", color = TextPrimary, fontSize = 13.sp)
                }

                Spacer(modifier = Modifier.height(8.dp))

                OutlinedButton(
                    onClick = { onAuthSuccess(calculatedUchihaName) },
                    border = BorderStroke(1.dp, DividerColor),
                    shape = RoundedCornerShape(24.dp),
                    colors = ButtonDefaults.outlinedButtonColors(containerColor = CardBackground),
                    modifier = Modifier
                        .fillMaxWidth()
                        .height(44.dp)
                ) {
                    Text(text = "  Continue with Apple", color = TextPrimary, fontSize = 13.sp)
                }
            }

            // Bottom Sign Up Switch
            Row(
                modifier = Modifier.padding(bottom = 10.dp),
                verticalAlignment = Alignment.CenterVertically
            ) {
                Text(
                    text = if (isSignUp) "Already have an account?" else "Don't have an account?",
                    color = TextSecondary,
                    fontSize = 12.sp
                )
                Spacer(modifier = Modifier.width(6.dp))
                Text(
                    text = if (isSignUp) "Login" else "Sign Up",
                    color = BrightRed,
                    fontSize = 12.sp,
                    fontWeight = FontWeight.Bold,
                    modifier = Modifier.clickable { isSignUp = !isSignUp }
                )
            }
        }
    }
}
