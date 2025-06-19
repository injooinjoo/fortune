package com.example.dream

import kotlinx.coroutines.flow.Flow

data class DreamResult(
    val id: String,
    val description: String
)

interface DreamRepository {
    fun search(query: String): Flow<List<DreamResult>>
}
