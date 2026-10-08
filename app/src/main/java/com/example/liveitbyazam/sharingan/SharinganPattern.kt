package com.example.liveitbyazam.sharingan

enum class SharinganPattern(
    val title: String,
    val description: String,
    val tomoeCount: Int
) {
    ONE_TOMOE("1-Tomoe Sharingan", "Initial perception awakening", 1),
    TWO_TOMOE("2-Tomoe Sharingan", "Enhanced chakra tracking", 2),
    THREE_TOMOE("3-Tomoe Sharingan", "Complete Uchiha perception", 3),
    ITACHI_MANGEKYOU("Itachi Mangekyō", "Curved pinwheel of Tsukuyomi", 3),
    SASUKE_MANGEKYOU("Sasuke Mangekyō", "Hexagram star of Amaterasu", 6),
    MADARA_MANGEKYOU("Madara Mangekyō", "Triple interconnected ring blades", 3),
    ETERNAL_MANGEKYOU("Eternal Mangekyō", "Infinite Uchiha visual force", 6);

    fun next(): SharinganPattern {
        val entries = entries
        return entries[(ordinal + 1) % entries.size]
    }
}
