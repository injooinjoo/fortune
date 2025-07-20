import ActivityKit
import WidgetKit
import SwiftUI

@available(iOS 16.2, *)
struct FortuneActivityWidget: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: FortuneActivityAttributes.self) { context in
            // Lock Screen View
            FortuneActivityView(context: context)
                .padding()
                .background(Color("ActivityBackground"))
                .activityBackgroundTint(Color("ActivityBackground"))
                .activitySystemActionForegroundColor(.white)
            
        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded View
                DynamicIslandExpandedRegion(.leading) {
                    FortuneActivityLeadingView(context: context)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    FortuneActivityTrailingView(context: context)
                }
                DynamicIslandExpandedRegion(.center) {
                    FortuneActivityCenterView(context: context)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    FortuneActivityBottomView(context: context)
                }
            } compactLeading: {
                // Compact Leading
                Image(systemName: "sparkles")
                    .font(.caption2)
                    .foregroundColor(.white)
            } compactTrailing: {
                // Compact Trailing
                Text("\(context.state.fortuneScore)")
                    .font(.caption2.monospacedDigit())
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            } minimal: {
                // Minimal View
                Image(systemName: "sparkles")
                    .font(.caption2)
                    .foregroundColor(.white)
            }
            .widgetURL(URL(string: "fortune://activity"))
            .keylineTint(.white)
        }
    }
}

// MARK: - Lock Screen View
@available(iOS 16.2, *)
struct FortuneActivityView: View {
    let context: ActivityViewContext<FortuneActivityAttributes>
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: iconForActivityType(context.state.activityType))
                        .font(.subheadline)
                    Text(titleForActivityType(context.state.activityType))
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }
                
                Spacer()
                
                Text(context.state.lastUpdated, style: .relative)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // Content based on activity type
            switch context.state.activityType {
            case .dailyFortune:
                DailyFortuneActivityContent(state: context.state)
            case .compatibility:
                CompatibilityActivityContent(state: context.state)
            case .fortuneReading:
                FortuneReadingActivityContent(state: context.state)
            }
        }
        .foregroundColor(.white)
    }
    
    func iconForActivityType(_ type: FortuneActivityAttributes.ContentState.ActivityType) -> String {
        switch type {
        case .dailyFortune: return "sparkles"
        case .compatibility: return "heart.circle.fill"
        case .fortuneReading: return "book.circle.fill"
        }
    }
    
    func titleForActivityType(_ type: FortuneActivityAttributes.ContentState.ActivityType) -> String {
        switch type {
        case .dailyFortune: return "오늘의 운세"
        case .compatibility: return "궁합 분석"
        case .fortuneReading: return "운세 읽기"
        }
    }
}

// MARK: - Dynamic Island Views
@available(iOS 16.2, *)
struct FortuneActivityLeadingView: View {
    let context: ActivityViewContext<FortuneActivityAttributes>
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Image(systemName: "sparkles")
                .font(.caption)
            Text("\(context.state.fortuneScore)")
                .font(.caption2.monospacedDigit())
                .fontWeight(.bold)
        }
        .foregroundColor(.white)
    }
}

@available(iOS 16.2, *)
struct FortuneActivityTrailingView: View {
    let context: ActivityViewContext<FortuneActivityAttributes>
    
    var body: some View {
        VStack(alignment: .trailing, spacing: 4) {
            HStack(spacing: 2) {
                Image(systemName: "paintpalette")
                    .font(.caption2)
                Text(context.state.luckyColor)
                    .font(.caption2)
            }
            HStack(spacing: 2) {
                Image(systemName: "number")
                    .font(.caption2)
                Text("\(context.state.luckyNumber)")
                    .font(.caption2)
            }
        }
        .foregroundColor(.white.opacity(0.8))
    }
}

@available(iOS 16.2, *)
struct FortuneActivityCenterView: View {
    let context: ActivityViewContext<FortuneActivityAttributes>
    
    var body: some View {
        Text(context.state.message)
            .font(.caption)
            .fontWeight(.medium)
            .foregroundColor(.white)
            .lineLimit(2)
            .multilineTextAlignment(.center)
    }
}

@available(iOS 16.2, *)
struct FortuneActivityBottomView: View {
    let context: ActivityViewContext<FortuneActivityAttributes>
    
    var body: some View {
        HStack {
            if let partnerName = context.state.partnerName,
               let compatibilityScore = context.state.compatibilityScore {
                Label("\(partnerName): \(compatibilityScore)%", systemImage: "heart.fill")
                    .font(.caption)
                    .foregroundColor(.pink)
            }
            
            Spacer()
            
            Text("탭하여 자세히 보기")
                .font(.caption2)
                .foregroundColor(.white.opacity(0.6))
        }
    }
}

// MARK: - Activity Content Views
@available(iOS 16.2, *)
struct DailyFortuneActivityContent: View {
    let state: FortuneActivityAttributes.ContentState
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Score
            HStack(spacing: 16) {
                Text("\(state.fortuneScore)")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                + Text("/100")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.white.opacity(0.7))
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 4) {
                        Image(systemName: "paintpalette.fill")
                            .font(.caption)
                        Text(state.luckyColor)
                            .font(.caption)
                    }
                    HStack(spacing: 4) {
                        Image(systemName: "number.circle.fill")
                            .font(.caption)
                        Text("숫자 \(state.luckyNumber)")
                            .font(.caption)
                    }
                }
                .foregroundColor(.white.opacity(0.8))
            }
            
            // Message
            Text(state.message)
                .font(.footnote)
                .foregroundColor(.white.opacity(0.9))
                .lineLimit(2)
        }
    }
}

@available(iOS 16.2, *)
struct CompatibilityActivityContent: View {
    let state: FortuneActivityAttributes.ContentState
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let partnerName = state.partnerName,
               let score = state.compatibilityScore {
                HStack(spacing: 12) {
                    // Score Circle
                    ZStack {
                        Circle()
                            .stroke(Color.white.opacity(0.2), lineWidth: 4)
                            .frame(width: 50, height: 50)
                        
                        Circle()
                            .trim(from: 0, to: CGFloat(score) / 100)
                            .stroke(
                                LinearGradient(
                                    colors: [Color.pink, Color.red],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                style: StrokeStyle(lineWidth: 4, lineCap: .round)
                            )
                            .rotationEffect(.degrees(-90))
                            .frame(width: 50, height: 50)
                        
                        Text("\(score)%")
                            .font(.caption2.monospacedDigit())
                            .fontWeight(.bold)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(partnerName)님과의 궁합")
                            .font(.footnote)
                            .fontWeight(.semibold)
                        
                        if let status = state.compatibilityStatus {
                            Text(status)
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.8))
                        }
                    }
                }
            }
            
            Text(state.message)
                .font(.caption)
                .foregroundColor(.white.opacity(0.9))
                .lineLimit(2)
        }
    }
}

@available(iOS 16.2, *)
struct FortuneReadingActivityContent: View {
    let state: FortuneActivityAttributes.ContentState
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("운세 읽기 중...")
                .font(.footnote)
                .fontWeight(.semibold)
            
            Text(state.message)
                .font(.caption)
                .foregroundColor(.white.opacity(0.9))
                .lineLimit(3)
            
            // Progress indicator
            ProgressView()
                .progressViewStyle(LinearProgressViewStyle())
                .tint(.white)
                .scaleEffect(x: 1, y: 0.5, anchor: .center)
        }
    }
}

// MARK: - Compatibility Activity Widget
@available(iOS 16.2, *)
struct CompatibilityActivityWidget: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: CompatibilityActivityAttributes.self) { context in
            // Lock Screen View
            CompatibilityActivityView(context: context)
                .padding()
                .background(Color("ActivityBackground"))
            
        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded View
                DynamicIslandExpandedRegion(.center) {
                    CompatibilityExpandedView(context: context)
                }
            } compactLeading: {
                Image(systemName: "heart.fill")
                    .font(.caption2)
                    .foregroundColor(.pink)
            } compactTrailing: {
                if context.state.isComplete {
                    Text("\(context.state.compatibilityScore ?? 0)%")
                        .font(.caption2.monospacedDigit())
                        .fontWeight(.bold)
                        .foregroundColor(.pink)
                } else {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .tint(.pink)
                        .scaleEffect(0.7)
                }
            } minimal: {
                Image(systemName: "heart.fill")
                    .font(.caption2)
                    .foregroundColor(.pink)
            }
            .widgetURL(URL(string: "fortune://compatibility"))
            .keylineTint(.pink)
        }
    }
}

@available(iOS 16.2, *)
struct CompatibilityActivityView: View {
    let context: ActivityViewContext<CompatibilityActivityAttributes>
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text("\(context.attributes.userName) ❤️ \(context.attributes.partnerName)")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                if context.state.isComplete {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                } else {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .tint(.white)
                        .scaleEffect(0.8)
                }
            }
            
            // Progress Bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.white.opacity(0.2))
                        .frame(height: 8)
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(
                            LinearGradient(
                                colors: [Color.pink, Color.red],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * context.state.progress, height: 8)
                }
            }
            .frame(height: 8)
            
            Text(context.state.status)
                .font(.footnote)
                .foregroundColor(.white.opacity(0.9))
            
            if let message = context.state.message {
                Text(message)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
                    .lineLimit(2)
            }
        }
        .foregroundColor(.white)
    }
}

@available(iOS 16.2, *)
struct CompatibilityExpandedView: View {
    let context: ActivityViewContext<CompatibilityActivityAttributes>
    
    var body: some View {
        VStack(spacing: 8) {
            if context.state.isComplete,
               let score = context.state.compatibilityScore {
                Text("\(score)%")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(.pink)
                
                Text("궁합 분석 완료!")
                    .font(.caption)
                    .foregroundColor(.white)
            } else {
                Text("분석 중...")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text("\(Int(context.state.progress * 100))%")
                    .font(.caption.monospacedDigit())
                    .foregroundColor(.white.opacity(0.7))
            }
            
            if let message = context.state.message {
                Text(message)
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
        }
    }
}