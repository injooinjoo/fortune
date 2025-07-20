# Watch Companion Apps Implementation Guide

## Overview

This guide provides comprehensive instructions for implementing Apple Watch and Wear OS companion apps for the Fortune Flutter application, focusing on fortune-telling features optimized for wearable devices.

## Table of Contents

1. [Apple Watch Implementation](#apple-watch-implementation)
2. [Wear OS Implementation](#wear-os-implementation)
3. [Shared Architecture](#shared-architecture)
4. [Communication Protocols](#communication-protocols)
5. [UI/UX Guidelines](#uiux-guidelines)
6. [Performance Optimization](#performance-optimization)
7. [Testing Strategies](#testing-strategies)

## Apple Watch Implementation

### 1. Project Setup

#### Create Watch App Target

1. In Xcode, select File → New → Target
2. Choose watchOS → App
3. Name: "Fortune Watch"
4. Configure:
   - Organization Identifier: com.fortune
   - Bundle Identifier: com.fortune.watchapp
   - Include Complication: ✓

#### Project Structure

```
FortuneWatch/
├── FortuneWatchApp.swift
├── ContentView.swift
├── Models/
│   ├── Fortune.swift
│   ├── UserProfile.swift
│   └── WatchConnectivity.swift
├── Views/
│   ├── FortuneDetailView.swift
│   ├── LuckyNumbersView.swift
│   ├── ElementsView.swift
│   └── CompatibilityView.swift
├── Services/
│   ├── FortuneService.swift
│   ├── ConnectivityService.swift
│   └── ComplicationController.swift
└── Resources/
    └── Assets.xcassets
```

### 2. Core Implementation

#### Main App Structure

```swift
import SwiftUI

@main
struct FortuneWatchApp: App {
    @StateObject private var connectivityService = ConnectivityService()
    @StateObject private var fortuneService = FortuneService()
    
    var body: some Scene {
        WindowGroup {
            NavigationView {
                ContentView()
                    .environmentObject(connectivityService)
                    .environmentObject(fortuneService)
            }
        }
    }
}
```

#### Main View Implementation

```swift
import SwiftUI

struct ContentView: View {
    @EnvironmentObject var fortuneService: FortuneService
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Daily Fortune Tab
            FortuneView()
                .tag(0)
            
            // Lucky Numbers Tab
            LuckyNumbersView()
                .tag(1)
            
            // Elements Tab
            ElementsView()
                .tag(2)
            
            // Compatibility Tab
            CompatibilityView()
                .tag(3)
        }
        .tabViewStyle(PageTabViewStyle())
        .onAppear {
            fortuneService.refreshFortune()
        }
    }
}

struct FortuneView: View {
    @EnvironmentObject var fortuneService: FortuneService
    @State private var isRefreshing = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                // Fortune Score
                FortuneScoreView(score: fortuneService.currentFortune?.score ?? 0)
                    .frame(height: 120)
                
                // Fortune Message
                if let message = fortuneService.currentFortune?.message {
                    Text(message)
                        .font(.system(size: 14))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                
                // Quick Actions
                HStack(spacing: 16) {
                    ActionButton(
                        icon: "arrow.clockwise",
                        title: "Refresh"
                    ) {
                        refreshFortune()
                    }
                    
                    ActionButton(
                        icon: "square.and.arrow.up",
                        title: "Share"
                    ) {
                        shareFortune()
                    }
                }
                .padding(.top)
            }
            .padding(.vertical)
        }
        .navigationTitle("Fortune")
    }
    
    private func refreshFortune() {
        guard !isRefreshing else { return }
        
        isRefreshing = true
        WKInterfaceDevice.current().play(.click)
        
        Task {
            await fortuneService.refreshFortune()
            isRefreshing = false
        }
    }
    
    private func shareFortune() {
        // Implementation for sharing
    }
}

struct FortuneScoreView: View {
    let score: Int
    @State private var animatedScore = 0
    
    var body: some View {
        ZStack {
            // Background Circle
            Circle()
                .stroke(
                    LinearGradient(
                        colors: [scoreColor.opacity(0.3), scoreColor.opacity(0.1)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 10
                )
            
            // Progress Circle
            Circle()
                .trim(from: 0, to: CGFloat(animatedScore) / 100)
                .stroke(
                    LinearGradient(
                        colors: [scoreColor, scoreColor.opacity(0.7)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    style: StrokeStyle(lineWidth: 10, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 1.5), value: animatedScore)
            
            // Score Text
            VStack {
                Text("\(animatedScore)")
                    .font(.system(size: 40, weight: .bold, design: .rounded))
                    .foregroundColor(scoreColor)
                
                Text("Today's Score")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }
        }
        .onAppear {
            withAnimation {
                animatedScore = score
            }
        }
    }
    
    var scoreColor: Color {
        if score >= 80 { return .green }
        if score >= 60 { return .yellow }
        if score >= 40 { return .orange }
        return .red
    }
}
```

### 3. Watch Connectivity

#### Connectivity Service

```swift
import WatchConnectivity

class ConnectivityService: NSObject, ObservableObject {
    @Published var isReachable = false
    @Published var receivedFortune: Fortune?
    
    private let session: WCSession
    
    override init() {
        self.session = WCSession.default
        super.init()
        
        if WCSession.isSupported() {
            session.delegate = self
            session.activate()
        }
    }
    
    func requestFortune() {
        guard session.isReachable else { return }
        
        session.sendMessage(
            ["request": "fortune"],
            replyHandler: { [weak self] response in
                if let fortuneData = response["fortune"] as? Data,
                   let fortune = try? JSONDecoder().decode(Fortune.self, from: fortuneData) {
                    DispatchQueue.main.async {
                        self?.receivedFortune = fortune
                    }
                }
            },
            errorHandler: { error in
                print("Error requesting fortune: \(error)")
            }
        )
    }
    
    func sendHeartRate(_ heartRate: Double) {
        guard session.isReachable else { return }
        
        session.sendMessage(
            ["heartRate": heartRate],
            replyHandler: nil,
            errorHandler: nil
        )
    }
}

extension ConnectivityService: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        DispatchQueue.main.async {
            self.isReachable = session.isReachable
        }
    }
    
    func sessionReachabilityDidChange(_ session: WCSession) {
        DispatchQueue.main.async {
            self.isReachable = session.isReachable
        }
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        if let fortuneData = message["fortune"] as? Data,
           let fortune = try? JSONDecoder().decode(Fortune.self, from: fortuneData) {
            DispatchQueue.main.async {
                self.receivedFortune = fortune
            }
        }
    }
    
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        // Handle background updates
        if let fortuneData = applicationContext["latestFortune"] as? Data,
           let fortune = try? JSONDecoder().decode(Fortune.self, from: fortuneData) {
            DispatchQueue.main.async {
                self.receivedFortune = fortune
                // Update complications
                ComplicationController.shared.updateComplications(with: fortune)
            }
        }
    }
}
```

### 4. Complications

#### Complication Data Source

```swift
import ClockKit

class ComplicationController: NSObject, CLKComplicationDataSource {
    static let shared = ComplicationController()
    
    // MARK: - Complication Configuration
    
    func getComplicationDescriptors(handler: @escaping ([CLKComplicationDescriptor]) -> Void) {
        let descriptors = [
            CLKComplicationDescriptor(
                identifier: "FortuneScore",
                displayName: "Fortune Score",
                supportedFamilies: [
                    .circularSmall,
                    .modularSmall,
                    .utilitarianSmall,
                    .graphicCircular,
                    .graphicBezel,
                    .graphicCorner,
                    .graphicRectangular
                ]
            ),
            CLKComplicationDescriptor(
                identifier: "LuckyNumbers",
                displayName: "Lucky Numbers",
                supportedFamilies: [
                    .modularLarge,
                    .graphicRectangular,
                    .graphicExtraLarge
                ]
            )
        ]
        
        handler(descriptors)
    }
    
    // MARK: - Timeline Population
    
    func getCurrentTimelineEntry(
        for complication: CLKComplication,
        withHandler handler: @escaping (CLKComplicationTimelineEntry?) -> Void
    ) {
        let fortune = FortuneService.shared.currentFortune ?? Fortune.placeholder()
        let template = makeTemplate(for: complication, fortune: fortune)
        let entry = CLKComplicationTimelineEntry(date: Date(), complicationTemplate: template)
        handler(entry)
    }
    
    func getTimelineEntries(
        for complication: CLKComplication,
        after date: Date,
        limit: Int,
        withHandler handler: @escaping ([CLKComplicationTimelineEntry]?) -> Void
    ) {
        // Provide timeline entries for the next 24 hours
        var entries: [CLKComplicationTimelineEntry] = []
        let fortune = FortuneService.shared.currentFortune ?? Fortune.placeholder()
        
        for hour in 1...24 {
            guard entries.count < limit else { break }
            
            let entryDate = date.addingTimeInterval(TimeInterval(hour * 3600))
            let template = makeTemplate(for: complication, fortune: fortune)
            let entry = CLKComplicationTimelineEntry(date: entryDate, complicationTemplate: template)
            entries.append(entry)
        }
        
        handler(entries)
    }
    
    // MARK: - Template Creation
    
    private func makeTemplate(for complication: CLKComplication, fortune: Fortune) -> CLKComplicationTemplate {
        switch complication.family {
        case .circularSmall:
            return createCircularSmallTemplate(fortune: fortune)
        case .modularSmall:
            return createModularSmallTemplate(fortune: fortune)
        case .graphicCircular:
            return createGraphicCircularTemplate(fortune: fortune)
        case .graphicRectangular:
            return createGraphicRectangularTemplate(fortune: fortune)
        case .graphicCorner:
            return createGraphicCornerTemplate(fortune: fortune)
        case .graphicBezel:
            return createGraphicBezelTemplate(fortune: fortune)
        default:
            return createModularSmallTemplate(fortune: fortune)
        }
    }
    
    private func createGraphicCircularTemplate(fortune: Fortune) -> CLKComplicationTemplate {
        let gaugeProvider = CLKSimpleGaugeProvider(
            style: .fill,
            gaugeColor: fortune.scoreColor,
            fillFraction: Float(fortune.score) / 100
        )
        
        return CLKComplicationTemplateGraphicCircularClosedGaugeText(
            gaugeProvider: gaugeProvider,
            centerTextProvider: CLKTextProvider(format: "\(fortune.score)")
        )
    }
    
    private func createGraphicRectangularTemplate(fortune: Fortune) -> CLKComplicationTemplate {
        let headerText = CLKTextProvider(format: "Fortune \(fortune.score)/100")
        let body1Text = CLKTextProvider(format: fortune.shortMessage)
        let body2Text = CLKTextProvider(format: "Lucky: \(fortune.luckyNumbers.prefix(3).map(String.init).joined(separator: ", "))")
        
        return CLKComplicationTemplateGraphicRectangularStandardBody(
            headerTextProvider: headerText,
            body1TextProvider: body1Text,
            body2TextProvider: body2Text
        )
    }
    
    // MARK: - Update Complications
    
    func updateComplications(with fortune: Fortune) {
        let server = CLKComplicationServer.sharedInstance()
        
        for complication in server.activeComplications ?? [] {
            server.reloadTimeline(for: complication)
        }
    }
}
```

### 5. Health Integration

```swift
import HealthKit

class HealthIntegration {
    private let healthStore = HKHealthStore()
    
    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        guard HKHealthStore.isHealthDataAvailable() else {
            completion(false)
            return
        }
        
        let readTypes: Set<HKObjectType> = [
            HKQuantityType.quantityType(forIdentifier: .heartRate)!,
            HKQuantityType.quantityType(forIdentifier: .heartRateVariabilitySDNN)!,
            HKQuantityType.quantityType(forIdentifier: .restingHeartRate)!,
            HKCategoryType.categoryType(forIdentifier: .mindfulSession)!
        ]
        
        healthStore.requestAuthorization(toShare: nil, read: readTypes) { success, error in
            completion(success)
        }
    }
    
    func getCurrentHeartRate(completion: @escaping (Double?) -> Void) {
        let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate)!
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        
        let query = HKSampleQuery(
            sampleType: heartRateType,
            predicate: nil,
            limit: 1,
            sortDescriptors: [sortDescriptor]
        ) { _, samples, error in
            guard let sample = samples?.first as? HKQuantitySample else {
                completion(nil)
                return
            }
            
            let heartRate = sample.quantity.doubleValue(for: HKUnit(from: "count/min"))
            completion(heartRate)
        }
        
        healthStore.execute(query)
    }
    
    func getStressLevel(completion: @escaping (StressLevel) -> Void) {
        // Analyze HRV data to determine stress level
        let hrvType = HKQuantityType.quantityType(forIdentifier: .heartRateVariabilitySDNN)!
        
        // Query last 5 minutes of HRV data
        let predicate = HKQuery.predicateForSamples(
            withStart: Date().addingTimeInterval(-300),
            end: Date(),
            options: .strictStartDate
        )
        
        let query = HKStatisticsQuery(
            quantityType: hrvType,
            quantitySamplePredicate: predicate,
            options: .discreteAverage
        ) { _, statistics, error in
            guard let average = statistics?.averageQuantity() else {
                completion(.unknown)
                return
            }
            
            let hrvValue = average.doubleValue(for: HKUnit.secondUnit(with: .milli))
            
            // Determine stress level based on HRV
            let stressLevel: StressLevel
            if hrvValue > 50 {
                stressLevel = .low
            } else if hrvValue > 30 {
                stressLevel = .moderate
            } else {
                stressLevel = .high
            }
            
            completion(stressLevel)
        }
        
        healthStore.execute(query)
    }
}

enum StressLevel {
    case low, moderate, high, unknown
    
    var fortuneModifier: Double {
        switch self {
        case .low: return 1.1
        case .moderate: return 1.0
        case .high: return 0.9
        case .unknown: return 1.0
        }
    }
}
```

## Wear OS Implementation

### 1. Project Setup

#### Create Wear OS Module

In Android Studio:
1. File → New → New Module
2. Select "Wear OS Module"
3. Configure:
   - Module name: wear
   - Package name: com.fortune.wear
   - Minimum SDK: API 30 (Wear OS 3.0)

#### Module Structure

```
wear/
├── src/main/
│   ├── java/com/fortune/wear/
│   │   ├── MainActivity.kt
│   │   ├── presentation/
│   │   │   ├── FortuneViewModel.kt
│   │   │   ├── screens/
│   │   │   │   ├── FortuneScreen.kt
│   │   │   │   ├── LuckyNumbersScreen.kt
│   │   │   │   └── ElementsScreen.kt
│   │   │   └── components/
│   │   │       ├── FortuneCard.kt
│   │   │       └── CircularProgress.kt
│   │   ├── services/
│   │   │   ├── DataLayerService.kt
│   │   │   └── ComplicationService.kt
│   │   ├── tiles/
│   │   │   └── FortuneTileService.kt
│   │   └── health/
│   │       └── HealthService.kt
│   └── res/
└── build.gradle.kts
```

### 2. Main Activity Implementation

```kotlin
package com.fortune.wear

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.runtime.Composable
import androidx.wear.compose.navigation.SwipeDismissableNavHost
import androidx.wear.compose.navigation.composable
import androidx.wear.compose.navigation.rememberSwipeDismissableNavController
import com.fortune.wear.presentation.screens.*
import com.fortune.wear.presentation.theme.FortuneWearTheme
import dagger.hilt.android.AndroidEntryPoint

@AndroidEntryPoint
class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        setContent {
            FortuneWearApp()
        }
    }
}

@Composable
fun FortuneWearApp() {
    FortuneWearTheme {
        val navController = rememberSwipeDismissableNavController()
        
        SwipeDismissableNavHost(
            navController = navController,
            startDestination = Screen.Fortune.route
        ) {
            composable(Screen.Fortune.route) {
                FortuneScreen(
                    onNavigateToLuckyNumbers = {
                        navController.navigate(Screen.LuckyNumbers.route)
                    },
                    onNavigateToElements = {
                        navController.navigate(Screen.Elements.route)
                    }
                )
            }
            
            composable(Screen.LuckyNumbers.route) {
                LuckyNumbersScreen()
            }
            
            composable(Screen.Elements.route) {
                ElementsScreen()
            }
        }
    }
}

sealed class Screen(val route: String) {
    object Fortune : Screen("fortune")
    object LuckyNumbers : Screen("lucky_numbers")
    object Elements : Screen("elements")
}
```

### 3. Fortune Screen Implementation

```kotlin
package com.fortune.wear.presentation.screens

import androidx.compose.foundation.layout.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.hilt.navigation.compose.hiltViewModel
import androidx.wear.compose.material.*
import com.fortune.wear.presentation.FortuneViewModel
import com.fortune.wear.presentation.components.FortuneScoreIndicator

@Composable
fun FortuneScreen(
    onNavigateToLuckyNumbers: () -> Unit,
    onNavigateToElements: () -> Unit,
    viewModel: FortuneViewModel = hiltViewModel()
) {
    val uiState by viewModel.uiState.collectAsState()
    val listState = rememberScalingLazyListState()
    
    Scaffold(
        timeText = {
            TimeText()
        },
        vignette = {
            Vignette(vignettePosition = VignettePosition.TopAndBottom)
        },
        positionIndicator = {
            PositionIndicator(scalingLazyListState = listState)
        }
    ) {
        ScalingLazyColumn(
            modifier = Modifier.fillMaxSize(),
            state = listState,
            contentPadding = PaddingValues(
                top = 24.dp,
                bottom = 40.dp
            ),
            verticalArrangement = Arrangement.spacedBy(8.dp),
            autoCentering = AutoCenteringParams(itemIndex = 0)
        ) {
            // Fortune Score Card
            item {
                Card(
                    onClick = { viewModel.refreshFortune() },
                    modifier = Modifier.fillMaxWidth()
                ) {
                    Column(
                        modifier = Modifier.padding(16.dp),
                        horizontalAlignment = Alignment.CenterHorizontally
                    ) {
                        FortuneScoreIndicator(
                            score = uiState.fortune?.score ?: 0,
                            size = 100.dp
                        )
                        
                        Spacer(modifier = Modifier.height(8.dp))
                        
                        Text(
                            text = "Today's Fortune",
                            style = MaterialTheme.typography.caption1
                        )
                    }
                }
            }
            
            // Fortune Message
            if (uiState.fortune?.message != null) {
                item {
                    Text(
                        text = uiState.fortune.message,
                        style = MaterialTheme.typography.body2,
                        textAlign = TextAlign.Center,
                        modifier = Modifier.padding(horizontal = 16.dp)
                    )
                }
            }
            
            // Lucky Numbers Chip
            item {
                Chip(
                    onClick = onNavigateToLuckyNumbers,
                    label = {
                        Text("Lucky Numbers")
                    },
                    secondaryLabel = {
                        uiState.fortune?.luckyNumbers?.take(3)?.let { numbers ->
                            Text(numbers.joinToString(", "))
                        }
                    },
                    icon = {
                        Icon(
                            imageVector = Icons.Rounded.Numbers,
                            contentDescription = null
                        )
                    },
                    colors = ChipDefaults.primaryChipColors(),
                    modifier = Modifier.fillMaxWidth()
                )
            }
            
            // Elements Chip
            item {
                Chip(
                    onClick = onNavigateToElements,
                    label = {
                        Text("Five Elements")
                    },
                    secondaryLabel = {
                        uiState.fortune?.element?.let { element ->
                            Text("Current: $element")
                        }
                    },
                    icon = {
                        Icon(
                            imageVector = Icons.Rounded.Spa,
                            contentDescription = null
                        )
                    },
                    colors = ChipDefaults.secondaryChipColors(),
                    modifier = Modifier.fillMaxWidth()
                )
            }
            
            // Refresh Button
            item {
                Button(
                    onClick = { viewModel.refreshFortune() },
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(top = 8.dp),
                    enabled = !uiState.isLoading
                ) {
                    if (uiState.isLoading) {
                        CircularProgressIndicator(
                            modifier = Modifier.size(16.dp),
                            strokeWidth = 2.dp
                        )
                    } else {
                        Icon(
                            imageVector = Icons.Rounded.Refresh,
                            contentDescription = "Refresh"
                        )
                    }
                }
            }
        }
    }
}
```

### 4. Data Layer Service

```kotlin
package com.fortune.wear.services

import android.content.Intent
import com.google.android.gms.wearable.*
import kotlinx.coroutines.*
import kotlinx.serialization.decodeFromString
import kotlinx.serialization.encodeToString
import kotlinx.serialization.json.Json
import javax.inject.Inject

class DataLayerService : WearableListenerService() {
    
    @Inject lateinit var fortuneRepository: FortuneRepository
    
    private val scope = CoroutineScope(Dispatchers.IO + SupervisorJob())
    
    override fun onDataChanged(dataEvents: DataEventBuffer) {
        dataEvents.forEach { event ->
            when (event.type) {
                DataEvent.TYPE_CHANGED -> {
                    event.dataItem.uri.path?.let { path ->
                        when (path) {
                            FORTUNE_PATH -> handleFortuneUpdate(event.dataItem)
                            USER_PROFILE_PATH -> handleUserProfileUpdate(event.dataItem)
                        }
                    }
                }
            }
        }
    }
    
    override fun onMessageReceived(messageEvent: MessageEvent) {
        when (messageEvent.path) {
            REQUEST_FORTUNE_PATH -> {
                sendCurrentFortune(messageEvent.sourceNodeId)
            }
            HEART_RATE_UPDATE_PATH -> {
                val heartRate = String(messageEvent.data).toDoubleOrNull()
                heartRate?.let { updateFortuneWithHeartRate(it) }
            }
        }
    }
    
    private fun handleFortuneUpdate(dataItem: DataItem) {
        val dataMap = DataMapItem.fromDataItem(dataItem).dataMap
        val fortuneJson = dataMap.getString(FORTUNE_KEY)
        
        fortuneJson?.let { json ->
            try {
                val fortune = Json.decodeFromString<Fortune>(json)
                scope.launch {
                    fortuneRepository.updateFortune(fortune)
                    updateComplications()
                    updateTiles()
                }
            } catch (e: Exception) {
                e.printStackTrace()
            }
        }
    }
    
    private fun sendCurrentFortune(nodeId: String) {
        scope.launch {
            val fortune = fortuneRepository.getCurrentFortune()
            fortune?.let {
                val fortuneJson = Json.encodeToString(it)
                
                Wearable.getMessageClient(this@DataLayerService)
                    .sendMessage(
                        nodeId,
                        FORTUNE_RESPONSE_PATH,
                        fortuneJson.toByteArray()
                    )
            }
        }
    }
    
    private fun updateFortuneWithHeartRate(heartRate: Double) {
        scope.launch {
            // Adjust fortune based on heart rate
            // Higher heart rate might indicate stress, affecting fortune
            val stressModifier = when {
                heartRate > 100 -> 0.9
                heartRate > 80 -> 1.0
                else -> 1.1
            }
            
            fortuneRepository.applyStressModifier(stressModifier)
        }
    }
    
    private fun updateComplications() {
        val intent = Intent(this, ComplicationService::class.java).apply {
            action = ComplicationService.ACTION_UPDATE_COMPLICATIONS
        }
        startService(intent)
    }
    
    private fun updateTiles() {
        TileService.getUpdater(this)
            .requestUpdate(FortuneTileService::class.java)
    }
    
    override fun onDestroy() {
        super.onDestroy()
        scope.cancel()
    }
    
    companion object {
        private const val FORTUNE_PATH = "/fortune"
        private const val USER_PROFILE_PATH = "/user_profile"
        private const val REQUEST_FORTUNE_PATH = "/request_fortune"
        private const val FORTUNE_RESPONSE_PATH = "/fortune_response"
        private const val HEART_RATE_UPDATE_PATH = "/heart_rate"
        private const val FORTUNE_KEY = "fortune_data"
    }
}
```

### 5. Tile Service Implementation

```kotlin
package com.fortune.wear.tiles

import androidx.wear.protolayout.*
import androidx.wear.protolayout.LayoutElementBuilders.*
import androidx.wear.protolayout.DimensionBuilders.*
import androidx.wear.protolayout.ColorBuilders.*
import androidx.wear.protolayout.ActionBuilders.*
import androidx.wear.protolayout.ModifiersBuilders.*
import androidx.wear.tiles.*
import com.google.common.util.concurrent.ListenableFuture
import kotlinx.coroutines.guava.future
import javax.inject.Inject

class FortuneTileService : TileService() {
    
    @Inject lateinit var fortuneRepository: FortuneRepository
    
    override fun onTileRequest(requestParams: RequestBuilders.TileRequest): ListenableFuture<Tile> {
        return serviceScope.future {
            val fortune = fortuneRepository.getCurrentFortune()
            
            Tile.Builder()
                .setResourcesVersion(RESOURCES_VERSION)
                .setTileTimeline(
                    Timeline.fromLayoutElement(
                        createTileLayout(fortune)
                    )
                )
                .build()
        }
    }
    
    override fun onTileResourcesRequest(
        requestParams: RequestBuilders.ResourcesRequest
    ): ListenableFuture<ResourceBuilders.Resources> {
        return serviceScope.future {
            ResourceBuilders.Resources.Builder()
                .setVersion(RESOURCES_VERSION)
                .addIdToImageMapping(
                    IMAGE_ID_FORTUNE,
                    ImageResource.Builder()
                        .setInlineResource(
                            InlineImageResource.Builder()
                                .setData(loadFortuneIcon())
                                .setWidthPx(48)
                                .setHeightPx(48)
                                .setFormat(ResourceBuilders.IMAGE_FORMAT_ARGB_8888)
                                .build()
                        )
                        .build()
                )
                .build()
        }
    }
    
    private fun createTileLayout(fortune: Fortune?): LayoutElement {
        return Box.Builder()
            .setWidth(expand())
            .setHeight(expand())
            .setModifiers(
                Modifiers.Builder()
                    .setBackground(
                        Background.Builder()
                            .setColor(argb(0xFF1A1A1A.toInt()))
                            .setCorner(
                                Corner.Builder()
                                    .setRadius(dp(16f))
                                    .build()
                            )
                            .build()
                    )
                    .setPadding(
                        Padding.Builder()
                            .setAll(dp(16f))
                            .build()
                    )
                    .setClickable(
                        Clickable.Builder()
                            .setId("open_app")
                            .setOnClick(
                                LoadAction.Builder()
                                    .build()
                            )
                            .build()
                    )
                    .build()
            )
            .addContent(
                Column.Builder()
                    .addContent(
                        // Icon and Title Row
                        Row.Builder()
                            .setWidth(expand())
                            .addContent(
                                Image.Builder()
                                    .setResourceId(IMAGE_ID_FORTUNE)
                                    .setWidth(dp(24f))
                                    .setHeight(dp(24f))
                                    .build()
                            )
                            .addContent(
                                Spacer.Builder()
                                    .setWidth(dp(8f))
                                    .build()
                            )
                            .addContent(
                                Text.Builder()
                                    .setText("Fortune")
                                    .setFontStyle(
                                        FontStyle.Builder()
                                            .setSize(sp(16f))
                                            .setWeight(FONT_WEIGHT_BOLD)
                                            .build()
                                    )
                                    .build()
                            )
                            .build()
                    )
                    .addContent(
                        Spacer.Builder()
                            .setHeight(dp(12f))
                            .build()
                    )
                    .addContent(
                        // Fortune Score
                        fortune?.let {
                            Row.Builder()
                                .setWidth(expand())
                                .setVerticalAlignment(VERTICAL_ALIGN_CENTER)
                                .addContent(
                                    Text.Builder()
                                        .setText("${it.score}")
                                        .setFontStyle(
                                            FontStyle.Builder()
                                                .setSize(sp(32f))
                                                .setWeight(FONT_WEIGHT_BOLD)
                                                .setColor(
                                                    argb(getScoreColor(it.score))
                                                )
                                                .build()
                                        )
                                        .build()
                                )
                                .addContent(
                                    Text.Builder()
                                        .setText("/100")
                                        .setFontStyle(
                                            FontStyle.Builder()
                                                .setSize(sp(16f))
                                                .setColor(argb(0xFF888888.toInt()))
                                                .build()
                                        )
                                        .setModifiers(
                                            Modifiers.Builder()
                                                .setPadding(
                                                    Padding.Builder()
                                                        .setStart(dp(4f))
                                                        .build()
                                                )
                                                .build()
                                        )
                                        .build()
                                )
                                .build()
                        } ?: Text.Builder()
                            .setText("Tap to refresh")
                            .setFontStyle(
                                FontStyle.Builder()
                                    .setSize(sp(14f))
                                    .setColor(argb(0xFF888888.toInt()))
                                    .build()
                            )
                            .build()
                    )
                    .addContent(
                        Spacer.Builder()
                            .setHeight(dp(8f))
                            .build()
                    )
                    .addContent(
                        // Lucky Numbers
                        fortune?.luckyNumbers?.let { numbers ->
                            Row.Builder()
                                .setWidth(expand())
                                .apply {
                                    numbers.take(3).forEach { number ->
                                        addContent(
                                            Box.Builder()
                                                .setWidth(dp(32f))
                                                .setHeight(dp(32f))
                                                .setModifiers(
                                                    Modifiers.Builder()
                                                        .setBackground(
                                                            Background.Builder()
                                                                .setColor(argb(0xFF2C2C2C.toInt()))
                                                                .setCorner(
                                                                    Corner.Builder()
                                                                        .setRadius(dp(16f))
                                                                        .build()
                                                                )
                                                                .build()
                                                        )
                                                        .setPadding(
                                                            Padding.Builder()
                                                                .setRtlAware(false)
                                                                .setEnd(dp(4f))
                                                                .build()
                                                        )
                                                        .build()
                                                )
                                                .addContent(
                                                    Text.Builder()
                                                        .setText("$number")
                                                        .setFontStyle(
                                                            FontStyle.Builder()
                                                                .setSize(sp(14f))
                                                                .build()
                                                        )
                                                        .setModifiers(
                                                            Modifiers.Builder()
                                                                .setPadding(
                                                                    Padding.Builder()
                                                                        .setAll(dp(8f))
                                                                        .build()
                                                                )
                                                                .build()
                                                        )
                                                        .build()
                                                )
                                                .build()
                                        )
                                    }
                                }
                                .build()
                        } ?: Box.Builder().build()
                    )
                    .build()
            )
            .build()
    }
    
    private fun getScoreColor(score: Int): Int {
        return when {
            score >= 80 -> 0xFF4CAF50.toInt() // Green
            score >= 60 -> 0xFFFFC107.toInt() // Amber
            score >= 40 -> 0xFFFF9800.toInt() // Orange
            else -> 0xFFF44336.toInt() // Red
        }
    }
    
    companion object {
        private const val RESOURCES_VERSION = "1.0"
        private const val IMAGE_ID_FORTUNE = "fortune_icon"
    }
}
```

## Shared Architecture

### 1. Communication Protocol

```kotlin
// Shared constants for both platforms
object WearCommunication {
    // Message paths
    const val PATH_FORTUNE_UPDATE = "/fortune/update"
    const val PATH_REQUEST_FORTUNE = "/fortune/request"
    const val PATH_HEART_RATE = "/health/heart_rate"
    const val PATH_STRESS_LEVEL = "/health/stress"
    
    // Data keys
    const val KEY_FORTUNE_DATA = "fortune_data"
    const val KEY_USER_PROFILE = "user_profile"
    const val KEY_TIMESTAMP = "timestamp"
    
    // Update intervals
    const val MIN_UPDATE_INTERVAL_MS = 30 * 60 * 1000L // 30 minutes
    const val COMPLICATION_UPDATE_INTERVAL_MS = 60 * 60 * 1000L // 1 hour
}
```

### 2. Data Models

```kotlin
// Shared data models
@Serializable
data class WearFortune(
    val score: Int,
    val message: String,
    val shortMessage: String,
    val luckyNumbers: List<Int>,
    val element: String,
    val luckyColor: String,
    val timestamp: Long
)

@Serializable
data class WearUserProfile(
    val id: String,
    val name: String,
    val birthDate: String,
    val zodiacSign: String,
    val element: String
)

@Serializable
data class HealthData(
    val heartRate: Double?,
    val stressLevel: String?,
    val steps: Int?,
    val timestamp: Long
)
```

## Communication Protocols

### 1. Flutter to Watch Communication

```dart
// Flutter side implementation
class WatchConnectivityService {
  static const _iosChannel = MethodChannel('com.fortune.ios/watch');
  static const _androidChannel = MethodChannel('com.fortune.android/wear');
  
  // Send fortune update to watch
  static Future<void> updateWatchFortune(Fortune fortune) async {
    final watchData = {
      'score': fortune.score,
      'message': fortune.message,
      'shortMessage': fortune.message.substring(0, min(50, fortune.message.length)),
      'luckyNumbers': fortune.luckyNumbers,
      'element': fortune.element,
      'luckyColor': fortune.luckyColor,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };
    
    if (Platform.isIOS) {
      await _iosChannel.invokeMethod('updateWatch', watchData);
    } else if (Platform.isAndroid) {
      await _androidChannel.invokeMethod('updateWear', watchData);
    }
  }
  
  // Check watch connectivity
  static Future<bool> isWatchConnected() async {
    try {
      if (Platform.isIOS) {
        return await _iosChannel.invokeMethod('isWatchConnected');
      } else if (Platform.isAndroid) {
        return await _androidChannel.invokeMethod('isWearConnected');
      }
      return false;
    } catch (e) {
      return false;
    }
  }
  
  // Receive health data from watch
  static Stream<HealthData> get healthDataStream {
    if (Platform.isIOS) {
      return _iosChannel.receiveBroadcastStream('healthData')
          .map((data) => HealthData.fromJson(data));
    } else if (Platform.isAndroid) {
      return _androidChannel.receiveBroadcastStream('healthData')
          .map((data) => HealthData.fromJson(data));
    }
    return Stream.empty();
  }
}
```

### 2. Watch to Phone Communication

iOS Implementation:
```swift
// Watch side
func sendHealthData() {
    let healthData: [String: Any] = [
        "heartRate": currentHeartRate,
        "stressLevel": stressLevel.rawValue,
        "steps": todaySteps,
        "timestamp": Date().timeIntervalSince1970
    ]
    
    session.sendMessage(
        ["healthData": healthData],
        replyHandler: nil,
        errorHandler: nil
    )
}
```

Android Implementation:
```kotlin
// Wear side
fun sendHealthData() {
    val healthData = mapOf(
        "heartRate" to currentHeartRate,
        "stressLevel" to stressLevel.name,
        "steps" to todaySteps,
        "timestamp" to System.currentTimeMillis()
    )
    
    val dataMap = PutDataMapRequest.create(PATH_HEALTH_DATA).apply {
        dataMap.putString(KEY_HEALTH_DATA, Json.encodeToString(healthData))
    }
    
    Wearable.getDataClient(context)
        .putDataItem(dataMap.asPutDataRequest())
}
```

## UI/UX Guidelines

### 1. Watch-Specific Design Principles

- **Glanceable Information**: Show key fortune data within 5 seconds
- **Minimal Interaction**: Maximum 2-3 taps to access any feature
- **High Contrast**: Ensure readability in all lighting conditions
- **Circular UI**: Optimize for round watch faces
- **Quick Actions**: Prominent refresh and share buttons

### 2. Screen Layouts

```
Main Screen:
┌─────────────┐
│   88/100    │ <- Large fortune score
│   Today     │ <- Date indicator
│ ─────────── │
│ Lucky: 7,14 │ <- Key info
│ [Refresh]   │ <- Primary action
└─────────────┘

Detail Screen:
┌─────────────┐
│ < Back      │
│ ─────────── │
│ Message...  │ <- Scrollable
│ ─────────── │
│ Element: 🔥 │
│ Color: 🟡   │
└─────────────┘
```

### 3. Complication Designs

```
Small Circular:
╭──╮
│88│
╰──╯

Large Rectangular:
┌─────────────┐
│Fortune   88 │
│Lucky: 7, 14 │
└─────────────┘
```

## Performance Optimization

### 1. Battery Management

```kotlin
class WearBatteryManager {
    companion object {
        fun getUpdateStrategy(context: Context): UpdateStrategy {
            val batteryManager = context.getSystemService(Context.BATTERY_SERVICE) as BatteryManager
            val batteryLevel = batteryManager.getIntProperty(BatteryManager.BATTERY_PROPERTY_CAPACITY)
            
            return when {
                batteryLevel < 15 -> UpdateStrategy.CRITICAL
                batteryLevel < 30 -> UpdateStrategy.CONSERVATIVE
                else -> UpdateStrategy.NORMAL
            }
        }
    }
    
    enum class UpdateStrategy {
        CRITICAL,     // Update once per day
        CONSERVATIVE, // Update every 6 hours
        NORMAL       // Update every hour
    }
}
```

### 2. Memory Optimization

```swift
// iOS Watch memory management
class WatchMemoryManager {
    static let shared = WatchMemoryManager()
    private var fortuneCache: [String: Fortune] = [:]
    private let maxCacheSize = 5
    
    func cacheFortune(_ fortune: Fortune) {
        let key = fortune.dateKey
        
        // Remove oldest if cache is full
        if fortuneCache.count >= maxCacheSize {
            let oldestKey = fortuneCache.keys.sorted().first
            oldestKey.map { fortuneCache.removeValue(forKey: $0) }
        }
        
        fortuneCache[key] = fortune
    }
    
    func getCachedFortune(for date: Date) -> Fortune? {
        return fortuneCache[date.dateKey]
    }
}
```

### 3. Network Optimization

```kotlin
// Wear OS network optimization
class WearNetworkManager {
    suspend fun syncWithPhone(): Boolean {
        // Check if phone is connected
        val nodes = Wearable.getNodeClient(context)
            .connectedNodes
            .await()
        
        if (nodes.isEmpty()) {
            // Use cached data
            return false
        }
        
        // Sync only essential data
        val request = DataSyncRequest(
            includeFullMessage = false,
            includeHistory = false,
            compressData = true
        )
        
        return performSync(request)
    }
}
```

## Testing Strategies

### 1. Unit Testing

```kotlin
// Watch app unit tests
class FortuneViewModelTest {
    @Test
    fun `fortune score updates correctly`() {
        val viewModel = FortuneViewModel()
        val testFortune = Fortune(score = 88)
        
        viewModel.updateFortune(testFortune)
        
        assertEquals(88, viewModel.uiState.value.fortune?.score)
    }
    
    @Test
    fun `health data affects fortune calculation`() {
        val viewModel = FortuneViewModel()
        val healthData = HealthData(heartRate = 120.0, stressLevel = "high")
        
        viewModel.applyHealthData(healthData)
        
        assertTrue(viewModel.uiState.value.fortune?.score ?: 0 < 100)
    }
}
```

### 2. Integration Testing

```swift
// Watch connectivity testing
class WatchConnectivityTests: XCTestCase {
    func testFortuneSync() async {
        let expectation = expectation(description: "Fortune synced")
        let connectivityService = ConnectivityService()
        
        connectivityService.requestFortune()
        
        wait(for: [expectation], timeout: 5.0)
        
        XCTAssertNotNil(connectivityService.receivedFortune)
    }
}
```

### 3. Device Testing Checklist

- [ ] Test on different watch models
- [ ] Verify complications on all watch faces
- [ ] Test battery consumption over 24 hours
- [ ] Verify offline functionality
- [ ] Test health sensor integration
- [ ] Verify notification handling
- [ ] Test companion app communication
- [ ] Verify performance on low battery

## Best Practices

### 1. Code Organization

```
watch-shared/
├── models/          # Shared data models
├── protocols/       # Communication protocols
├── utilities/       # Shared utilities
└── constants/       # Shared constants
```

### 2. Error Handling

```kotlin
sealed class WatchError : Exception() {
    object NoPhoneConnection : WatchError()
    object SyncTimeout : WatchError()
    object InvalidData : WatchError()
    object HealthPermissionDenied : WatchError()
}

fun handleWatchError(error: WatchError) {
    when (error) {
        is WatchError.NoPhoneConnection -> showOfflineUI()
        is WatchError.SyncTimeout -> retryWithBackoff()
        is WatchError.InvalidData -> requestFullSync()
        is WatchError.HealthPermissionDenied -> showPermissionRequest()
    }
}
```

### 3. Accessibility

```swift
// Ensure watch apps are accessible
extension FortuneScoreView {
    var accessibilityLabel: String {
        "Fortune score \(score) out of 100"
    }
    
    var accessibilityHint: String {
        "Tap to refresh your fortune"
    }
}
```

## Conclusion

This comprehensive guide provides the foundation for implementing robust watch companion apps for the Fortune Flutter application. Key considerations:

1. **Performance**: Optimize for battery life and quick interactions
2. **Design**: Follow platform-specific guidelines
3. **Communication**: Implement reliable sync mechanisms
4. **Features**: Focus on glanceable, relevant information
5. **Testing**: Thorough testing on actual devices

Regular updates and user feedback will help refine the watch experience over time.