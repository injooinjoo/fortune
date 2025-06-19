package ui.dream

import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.ui.Alignment
import androidx.compose.foundation.lazy.items
import androidx.compose.material.Icon
import androidx.compose.material.MaterialTheme
import androidx.compose.material.Text
import androidx.compose.material.TextField
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Search
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.input.TextFieldValue
import androidx.compose.ui.unit.dp

/**
 * Simple search screen for dream interpretation keywords.
 */
@Composable
fun DreamSearchScreen(
    interpretations: List<DreamInterpretation>
) {
    var query by remember { mutableStateOf(TextFieldValue("")) }

    Column(modifier = Modifier.fillMaxSize().padding(16.dp)) {
        TextField(
            value = query,
            onValueChange = { query = it },
            leadingIcon = { Icon(Icons.Default.Search, contentDescription = null) },
            modifier = Modifier.fillMaxWidth(),
            textStyle = MaterialTheme.typography.body1
        )

        Spacer(modifier = Modifier.height(16.dp))

        val results = remember(query.text, interpretations) {
            interpretations.filter {
                it.keyword.contains(query.text, ignoreCase = true)
            }
        }

        if (results.isEmpty()) {
            Box(modifier = Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
                Text(text = "No results found")
            }
        } else {
            LazyColumn(modifier = Modifier.fillMaxSize()) {
                items(results) { item ->
                    Column(modifier = Modifier.fillMaxWidth().padding(vertical = 8.dp)) {
                        Text(text = item.keyword, style = MaterialTheme.typography.subtitle1)
                        Text(text = item.summary, style = MaterialTheme.typography.body2)
                    }
                }
            }
        }
    }
}

data class DreamInterpretation(val keyword: String, val summary: String)
