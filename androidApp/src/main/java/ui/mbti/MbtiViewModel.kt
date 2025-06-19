package ui.mbti

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.launch
import javax.inject.Inject

@HiltViewModel
class MbtiViewModel @Inject constructor(
    private val repository: MbtiRepository
) : ViewModel() {

    private val _uiState = MutableStateFlow<MbtiUiState>(MbtiUiState.Loading)
    val uiState: StateFlow<MbtiUiState> = _uiState

    fun fetchMbtiInfo(type: String) {
        viewModelScope.launch {
            _uiState.value = MbtiUiState.Loading
            try {
                val data = repository.getMbtiInfo(type)
                _uiState.value = MbtiUiState.Success(data)
            } catch (e: Exception) {
                _uiState.value = MbtiUiState.Error
            }
        }
    }
}

sealed interface MbtiUiState {
    object Loading : MbtiUiState
    data class Success(val data: MbtiInfo) : MbtiUiState
    object Error : MbtiUiState
}
