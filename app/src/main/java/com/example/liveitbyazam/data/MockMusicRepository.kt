package com.example.liveitbyazam.data

import com.example.liveitbyazam.model.Artist
import com.example.liveitbyazam.model.Playlist
import com.example.liveitbyazam.model.Song
import com.example.liveitbyazam.sharingan.SharinganPattern

object MockMusicRepository {

    val sampleSongs = listOf(
        Song(
            id = "s1",
            title = "Enemy",
            artist = "Imagine Dragons | JID",
            album = "Uchiha Vibes",
            durationMs = 196000,
            mediaUri = "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3",
            coverArtUrl = "https://images.unsplash.com/photo-1578632767115-351597cf2477?w=500",
            lyrics = """
                [00:05.00] Look out for yourself
                [00:10.00] I wake up to the sounds of the silence that allows
                [00:16.00] For my mind to run around with my ear up
                [00:22.00] To the ground I'm searching to behold the stories that are told
                [00:28.00] When my back is to the world that was smiling when I turned
                [00:35.00] Tell you you're the greatest, but once you turn they hate us
                [00:42.00] Oh, the misery! Everybody wants to be my enemy!
                [00:50.00] Spare the sympathy, everybody wants to be my enemy!
                [00:58.00] YOU ARE ALREADY UNDER MY GENJUTSU.
            """.trimIndent(),
            isFavorite = true,
            genre = "Uchiha Rock / Synth",
            sharinganPattern = SharinganPattern.THREE_TOMOE
        ),
        Song(
            id = "s2",
            title = "Heat Waves",
            artist = "Glass Animals",
            album = "Chill Phase",
            durationMs = 238000,
            mediaUri = "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3",
            coverArtUrl = "https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?w=500",
            lyrics = """
                [00:08.00] Last night all I think about is you.
                [00:15.00] Don't you cry, tonight inside the Genjutsu.
                [00:22.00] Road shimmer in the dark red heat.
                [00:30.00] I can't make you happier now.
                [00:38.00] Eternal Mangekyō awakened at last.
                [00:46.00] LIVE IT BY AZAM.
            """.trimIndent(),
            isFavorite = true,
            genre = "Chill Synth",
            sharinganPattern = SharinganPattern.SASUKE_MANGEKYOU
        ),
        Song(
            id = "s3",
            title = "Demons",
            artist = "Imagine Dragons",
            album = "Anime Hits",
            durationMs = 177000,
            mediaUri = "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-3.mp3",
            coverArtUrl = "https://images.unsplash.com/photo-1518709268805-4e9042af9f23?w=500",
            lyrics = """
                [00:06.00] When the days are cold and the cards all fold.
                [00:14.00] And the saints we see are all made of gold.
                [00:22.00] When your dreams all fail and the ones we hail.
                [00:31.00] Are the worst of all, and the blood's run stale.
                [00:40.00] No matter what we breed, we still are made of greed.
                [00:48.00] This is my kingdom come.
            """.trimIndent(),
            isFavorite = false,
            genre = "Uchiha Rock",
            sharinganPattern = SharinganPattern.ITACHI_MANGEKYOU
        ),
        Song(
            id = "s4",
            title = "My Ordinary Life",
            artist = "The Living Tombstone",
            album = "Uchiha Vibes",
            durationMs = 230000,
            mediaUri = "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-4.mp3",
            coverArtUrl = "https://images.unsplash.com/photo-1550684848-fac1c5b4e853?w=500",
            lyrics = """
                [00:04.00] They tell me that I'm special, I smile and shake my head.
                [00:10.00] I'll give them stories they can tell long after I am dead.
                [00:16.00] They think I'm crazy, but I'm just living in my mind.
                [00:23.00] Eye of the moon initiative active.
                [00:30.00] LIVE IT BY AZAM.
            """.trimIndent(),
            isFavorite = true,
            genre = "Electro Phonk",
            sharinganPattern = SharinganPattern.MADARA_MANGEKYOU
        ),
        Song(
            id = "s5",
            title = "Centuries",
            artist = "Fall Out Boy",
            album = "Anime Hits",
            durationMs = 228000,
            mediaUri = "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-5.mp3",
            coverArtUrl = "https://images.unsplash.com/photo-1534447677768-be436bb09401?w=500",
            lyrics = """
                [00:05.00] Some legends are told, some turn to dust or to gold.
                [00:12.00] But you will remember me for centuries.
                [00:20.00] Protect the honor of the Uchiha shadow.
                [00:28.00] YOU ARE ALREADY UNDER MY GENJUTSU.
            """.trimIndent(),
            isFavorite = false,
            genre = "Rock Anthem",
            sharinganPattern = SharinganPattern.ETERNAL_MANGEKYOU
        ),
        Song(
            id = "s6",
            title = "Without Me",
            artist = "Halsey",
            album = "Chill Phase",
            durationMs = 201000,
            mediaUri = "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-6.mp3",
            coverArtUrl = "https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?w=500",
            lyrics = """
                [00:06.00] Found you when your heart was broke.
                [00:15.00] Filled your cup until it overflowed.
                [00:24.00] Azam Uchiha presents the ultimate music realm.
                [00:32.00] Music hits different here.
            """.trimIndent(),
            isFavorite = true,
            genre = "Dark Pop",
            sharinganPattern = SharinganPattern.TWO_TOMOE
        )
    )

    val samplePlaylists = listOf(
        Playlist(
            id = "p1",
            name = "Uchiha Vibes",
            description = "32 songs • Dark crimson energy for intense focus.",
            songs = sampleSongs,
            coverArtUrl = "https://images.unsplash.com/photo-1578632767115-351597cf2477?w=500"
        ),
        Playlist(
            id = "p2",
            name = "Chill Phase",
            description = "28 songs • Late night midnight synth sessions.",
            songs = sampleSongs.drop(1),
            coverArtUrl = "https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?w=500"
        ),
        Playlist(
            id = "p3",
            name = "Anime Hits",
            description = "45 songs • Epic battle themes and high energy tracks.",
            songs = sampleSongs.drop(2),
            coverArtUrl = "https://images.unsplash.com/photo-1518709268805-4e9042af9f23?w=500"
        )
    )

    val sampleArtists = listOf(
        Artist("a1", "Azam Uchiha", "https://images.unsplash.com/photo-1578632767115-351597cf2477?w=500", 248, "Creator of LIVE IT BY AZAM music experience."),
        Artist("a2", "Imagine Dragons", "https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?w=500", 42, "Rock and Synthwave Band."),
        Artist("a3", "Glass Animals", "https://images.unsplash.com/photo-1518709268805-4e9042af9f23?w=500", 28, "Alternative Psychedelic Pop."),
        Artist("a4", "The Living Tombstone", "https://images.unsplash.com/photo-1550684848-fac1c5b4e853?w=500", 35, "Electronic Phonk Creator.")
    )
}
