package com.example.repository

import javax.inject.Inject
import javax.inject.Singleton

@Singleton
class MbtiRepositoryImpl @Inject constructor() : MbtiRepository {
    override fun getMbtiType(): String {
        // Placeholder implementation
        return "ISTJ"
    }
}
