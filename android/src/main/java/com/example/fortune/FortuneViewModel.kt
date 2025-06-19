package com.example.fortune

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableSharedFlow
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.SharedFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asSharedFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import javax.inject.Inject

@HiltViewModel
class FortuneViewModel @Inject constructor(
    private val repository: FortuneRepository
) : ViewModel() {

    private val _uiState = MutableStateFlow<FortuneUiState>(FortuneUiState.Loading)
    val uiState: StateFlow<FortuneUiState> = _uiState.asStateFlow()

    private val _toastMessage = MutableSharedFlow<String>()
    val toastMessage: SharedFlow<String> = _toastMessage.asSharedFlow()

    fun generateFortune(birthDate: String) {
        viewModelScope.launch {
            _uiState.value = FortuneUiState.Loading
            try {
                val result = repository.getFortune(birthDate)
                _uiState.value = FortuneUiState.Success(result)
            } catch (e: Exception) {
                _uiState.value = FortuneUiState.Error(e)
                _toastMessage.emit("Error: ${'$'}{e.message}")
            }
        }
    }
}

sealed interface FortuneUiState {
    object Loading : FortuneUiState
    data class Success(val fortune: String) : FortuneUiState
    data class Error(val exception: Throwable) : FortuneUiState
}
