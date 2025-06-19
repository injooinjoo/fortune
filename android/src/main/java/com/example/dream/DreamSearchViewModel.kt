package com.example.dream

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.*
import kotlinx.coroutines.launch
import javax.inject.Inject

@HiltViewModel
class DreamSearchViewModel @Inject constructor(
    private val dreamRepository: DreamRepository
) : ViewModel() {

    val searchText = MutableStateFlow("")

    private val _searchResults = MutableStateFlow<List<DreamResult>>(emptyList())
    val searchResults: StateFlow<List<DreamResult>> = _searchResults.asStateFlow()

    init {
        viewModelScope.launch {
            snapshotFlow { searchText.value }
                .debounce(500)
                .distinctUntilChanged()
                .flatMapLatest { query ->
                    if (query.isBlank()) {
                        flowOf(emptyList())
                    } else {
                        dreamRepository.search(query)
                    }
                }
                .collect { results ->
                    _searchResults.value = results
                }
        }
    }
}
