package com.example.liveitbyazam.data

import android.content.ContentUris
import android.content.Context
import android.provider.MediaStore
import com.example.liveitbyazam.model.Song
import com.example.liveitbyazam.sharingan.SharinganPattern

object LocalMusicScanner {

    fun scanLocalAudioFiles(context: Context): List<Song> {
        val songList = mutableListOf<Song>()
        val projection = arrayOf(
            MediaStore.Audio.Media._ID,
            MediaStore.Audio.Media.TITLE,
            MediaStore.Audio.Media.ARTIST,
            MediaStore.Audio.Media.ALBUM,
            MediaStore.Audio.Media.DURATION,
            MediaStore.Audio.Media.ALBUM_ID
        )

        val selection = "${MediaStore.Audio.Media.IS_MUSIC} != 0"
        val sortOrder = "${MediaStore.Audio.Media.TITLE} ASC"

        try {
            context.contentResolver.query(
                MediaStore.Audio.Media.EXTERNAL_CONTENT_URI,
                projection,
                selection,
                null,
                sortOrder
            )?.use { cursor ->
                val idColumn = cursor.getColumnIndexOrThrow(MediaStore.Audio.Media._ID)
                val titleColumn = cursor.getColumnIndexOrThrow(MediaStore.Audio.Media.TITLE)
                val artistColumn = cursor.getColumnIndexOrThrow(MediaStore.Audio.Media.ARTIST)
                val albumColumn = cursor.getColumnIndexOrThrow(MediaStore.Audio.Media.ALBUM)
                val durationColumn = cursor.getColumnIndexOrThrow(MediaStore.Audio.Media.DURATION)
                val albumIdColumn = cursor.getColumnIndexOrThrow(MediaStore.Audio.Media.ALBUM_ID)

                var index = 0
                val patterns = SharinganPattern.entries

                while (cursor.moveToNext()) {
                    val id = cursor.getLong(idColumn)
                    val title = cursor.getString(titleColumn) ?: "Unknown Track"
                    val artist = cursor.getString(artistColumn) ?: "Unknown Artist"
                    val album = cursor.getString(albumColumn) ?: "Unknown Album"
                    val duration = cursor.getLong(durationColumn)
                    val albumId = cursor.getLong(albumIdColumn)

                    val contentUri = ContentUris.withAppendedId(
                        MediaStore.Audio.Media.EXTERNAL_CONTENT_URI,
                        id
                    ).toString()

                    val albumArtUri = ContentUris.withAppendedId(
                        android.net.Uri.parse("content://media/external/audio/albumart"),
                        albumId
                    ).toString()

                    val pattern = patterns[index % patterns.size]

                    songList.add(
                        Song(
                            id = "local_$id",
                            title = title,
                            artist = if (artist.contains("<unknown>", ignoreCase = true)) "Unknown Artist" else artist,
                            album = album,
                            durationMs = if (duration > 0) duration else 180000L,
                            mediaUri = contentUri,
                            coverArtUrl = albumArtUri,
                            genre = "Local Audio",
                            sharinganPattern = pattern,
                            isDownloaded = true
                        )
                    )
                    index++
                }
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }

        return songList
    }
}
