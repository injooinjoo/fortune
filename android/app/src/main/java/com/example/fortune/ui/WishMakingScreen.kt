package com.example.fortune.ui

import androidx.compose.animation.core.LinearEasing
import androidx.compose.animation.core.RepeatMode
import androidx.compose.animation.core.animateFloat
import androidx.compose.animation.core.infiniteRepeatable
import androidx.compose.animation.core.rememberInfiniteTransition
import androidx.compose.animation.core.tween
import androidx.compose.foundation.Canvas
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.text.BasicTextField
import androidx.compose.material3.Button
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.drawscope.drawCircle
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import kotlinx.coroutines.launch
import androidx.room.*

/**
 * Screen for writing a wish. Provides a calming twinkling star background and a
 * text field styled like an old scroll. When the "소원 담기" button is clicked a
 * small particle burst originates from the button and the wish is saved using
 * Room.
 */
@Composable
fun WishMakingScreen(database: WishDatabase) {
    val scope = rememberCoroutineScope()
    var wishText by remember { mutableStateOf("") }
    var showParticles by remember { mutableStateOf(false) }

    Box(modifier = Modifier.fillMaxSize()) {
        // Animated starry background
        StarBackground()

        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(32.dp),
            verticalArrangement = Arrangement.Center,
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            BasicTextField(
                value = wishText,
                onValueChange = { wishText = it },
                textStyle = TextStyle(
                    fontFamily = FontFamily.Cursive,
                    fontSize = 20.sp,
                    color = Color.Black
                ),
                modifier = Modifier
                    .background(Color(0xFFFFF8E1)) // parchment color
                    .padding(16.dp)
                    .fillMaxWidth()
                    .height(150.dp)
            )

            Spacer(modifier = Modifier.height(24.dp))

            Button(onClick = {
                if (wishText.isNotBlank()) {
                    scope.launch {
                        database.wishDao().insertWish(WishEntity(text = wishText))
                        showParticles = true
                    }
                }
            }) {
                Text(text = "소원 담기")
            }
        }

        if (showParticles) {
            ParticleBurst(onFinished = { showParticles = false })
        }
    }
}

@Composable
private fun StarBackground() {
    val transition = rememberInfiniteTransition(label = "stars")
    val alpha by transition.animateFloat(
        initialValue = 0.3f,
        targetValue = 1f,
        animationSpec = infiniteRepeatable(
            animation = tween(2000, easing = LinearEasing),
            repeatMode = RepeatMode.Reverse
        ), label = "alpha"
    )

    Canvas(modifier = Modifier.fillMaxSize().background(Color.Black)) {
        val starCount = 50
        repeat(starCount) { i ->
            val x = (size.width * (i.toFloat() / starCount))
            val y = (size.height * ((starCount - i).toFloat() / starCount))
            drawCircle(Color.White.copy(alpha = alpha), radius = 2f, center = androidx.compose.ui.geometry.Offset(x, y))
        }
    }
}

@Composable
private fun ParticleBurst(onFinished: () -> Unit) {
    val scope = rememberCoroutineScope()
    var particles by remember { mutableStateOf(List(20) { Particle() }) }

    Canvas(modifier = Modifier.fillMaxSize()) {
        particles.forEach { particle ->
            drawCircle(
                color = Color.Yellow,
                radius = particle.radius,
                center = particle.position
            )
        }
    }

    LaunchedEffect(Unit) {
        scope.launch {
            repeat(30) { step ->
                particles = particles.map { it.next(step) }
                kotlinx.coroutines.delay(16)
            }
            onFinished()
        }
    }
}

private data class Particle(
    val position: androidx.compose.ui.geometry.Offset = androidx.compose.ui.geometry.Offset.Zero,
    val radius: Float = 4f
) {
    fun next(step: Int): Particle {
        val newPosition = position.copy(
            x = position.x + (0..4).random() - 2,
            y = position.y - step * 0.5f
        )
        return copy(position = newPosition, radius = radius * 0.95f)
    }
}

@Entity(tableName = "wishes")
data class WishEntity(
    @PrimaryKey(autoGenerate = true) val id: Int = 0,
    val text: String
)

@Dao
interface WishDao {
    @Insert
    suspend fun insertWish(wish: WishEntity)
}

@Database(entities = [WishEntity::class], version = 1)
abstract class WishDatabase : RoomDatabase() {
    abstract fun wishDao(): WishDao
}
