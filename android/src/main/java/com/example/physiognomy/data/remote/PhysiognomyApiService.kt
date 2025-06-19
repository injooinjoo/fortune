package com.example.physiognomy.data.remote

import okhttp3.MultipartBody
import okhttp3.ResponseBody
import retrofit2.Response
import retrofit2.http.Multipart
import retrofit2.http.POST
import retrofit2.http.Part

/**
 * Retrofit interface for physiognomy analysis.
 */
interface PhysiognomyApiService {
    /**
     * Uploads an image to the `analyze` endpoint for face analysis.
     */
    @Multipart
    @POST("analyze")
    suspend fun analyzeFace(
        @Part image: MultipartBody.Part
    ): Response<ResponseBody>
}
