package com.example.physiognomy.data

import android.content.Context
import android.net.Uri
import com.example.physiognomy.data.remote.PhysiognomyApiService
import okhttp3.MediaType.Companion.toMediaTypeOrNull
import okhttp3.MultipartBody
import okhttp3.RequestBody

/**
 * Repository that uploads an image for physiognomy analysis using [PhysiognomyApiService].
 */
class PhysiognomyRepository(
    private val context: Context,
    private val api: PhysiognomyApiService
) {

    /**
     * Converts the given [Uri] to [MultipartBody.Part] and sends it to the API.
     */
    suspend fun analyzeSelectedImage(imageUri: Uri) = api.analyzeFace(toMultipart(imageUri))

    private fun toMultipart(uri: Uri): MultipartBody.Part {
        val stream = context.contentResolver.openInputStream(uri)
            ?: throw IllegalArgumentException("Unable to open URI: $uri")
        val bytes = stream.readBytes()
        val requestBody = RequestBody.create("image/*".toMediaTypeOrNull(), bytes)
        return MultipartBody.Part.createFormData("file", "image.jpg", requestBody)
    }
}
