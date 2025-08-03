import SwiftUI
import WidgetKit

struct LoveFortuneWidgetView: View {
    var entry: LoveFortuneEntry
    @Environment(\.widgetFamily) var family
    
    var body: some View {
        switch family {
        case .systemMedium:
            MediumLoveFortuneView(entry: entry)
        case .systemLarge:
            LargeLoveFortuneView(entry: entry)
        default:
            MediumLoveFortuneView(entry: entry)
        }
    }
}

// MARK: - Medium Widget
struct MediumLoveFortuneView: View {
    let entry: LoveFortuneEntry
    
    var body: some View {
        ZStack {
            ContainerRelativeShape()
                .fill(LinearGradient(
                    gradient: Gradient(colors: [Color("LoveWidgetBackground1"), Color("LoveWidgetBackground2")]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
            
            HStack(spacing: 16) {
                // Left: Compatibility Score
                VStack(spacing: 8) {
                    HStack {
                        Image(systemName: "heart.circle.fill")
                            .font(.caption)
                        Text("연애운 궁합")
                            .font(.caption)
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.white.opacity(0.8))
                    
                    Spacer()
                    
                    // Circular Progress
                    ZStack {
                        Circle()
                            .stroke(Color.white.opacity(0.2), lineWidth: 8)
                            .frame(width: 80, height: 80)
                        
                        Circle()
                            .trim(from: 0, to: CGFloat(entry.compatibilityScore) / 100)
                            .stroke(
                                LinearGradient(
                                    colors: [Color.pink, Color.red],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                style: StrokeStyle(lineWidth: 8, lineCap: .round)
                            )
                            .rotationEffect(.degrees(-90))
                            .frame(width: 80, height: 80)
                        
                        Text("\(entry.compatibilityScore)%")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                }
                
                Divider()
                    .background(Color.white.opacity(0.3))
                
                // Right: Partner Info & Message
                VStack(alignment: .leading, spacing: 8) {
                    Text("\(entry.partnerName)님과의 궁합")
                        .font(.footnote)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text(entry.message)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.9))
                        .lineLimit(3)
                        .multilineTextAlignment(.leading)
                    
                    Spacer()
                    
                    HStack {
                        Spacer()
                        Text("자세히 보기 ›")
                            .font(.caption2)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                    }
                }
            }
            .padding()
        }
        .widgetURL(URL(string: "fortune://love?partner=\(entry.partnerName)"))
    }
}

// MARK: - Large Widget
struct LargeLoveFortuneView: View {
    let entry: LoveFortuneEntry
    
    var body: some View {
        ZStack {
            ContainerRelativeShape()
                .fill(LinearGradient(
                    gradient: Gradient(colors: [Color("LoveWidgetBackground1"), Color("LoveWidgetBackground2")]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
            
            VStack(alignment: .leading, spacing: 16) {
                // Header
                HStack {
                    HStack(spacing: 8) {
                        Image(systemName: "heart.circle.fill")
                            .font(.title3)
                        Text("연애운 궁합")
                            .font(.title3)
                            .fontWeight(.bold)
                    }
                    Spacer()
                    Text(entry.date, style: .time)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.6))
                }
                .foregroundColor(.white)
                
                // Main Content
                HStack(alignment: .top, spacing: 20) {
                    // Compatibility Score
                    VStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .stroke(Color.white.opacity(0.2), lineWidth: 10)
                                .frame(width: 100, height: 100)
                            
                            Circle()
                                .trim(from: 0, to: CGFloat(entry.compatibilityScore) / 100)
                                .stroke(
                                    LinearGradient(
                                        colors: [Color.pink, Color.red],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    style: StrokeStyle(lineWidth: 10, lineCap: .round)
                                )
                                .rotationEffect(.degrees(-90))
                                .frame(width: 100, height: 100)
                            
                            VStack(spacing: 0) {
                                Text("\(entry.compatibilityScore)")
                                    .font(.system(size: 32, weight: .bold, design: .rounded))
                                Text("%")
                                    .font(.system(size: 16, weight: .medium))
                            }
                            .foregroundColor(.white)
                        }
                        
                        Text(entry.partnerName)
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                    
                    // Messages
                    VStack(alignment: .leading, spacing: 12) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("오늘의 궁합 메시지")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.7))
                            
                            Text(entry.message)
                                .font(.callout)
                                .fontWeight(.medium)
                                .foregroundColor(.white)
                                .lineLimit(3)
                        }
                        
                        if let advice = entry.advice {
                            Divider()
                                .background(Color.white.opacity(0.3))
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("연애 조언")
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.7))
                                
                                Text(advice)
                                    .font(.footnote)
                                    .foregroundColor(.white.opacity(0.9))
                                    .lineLimit(4)
                            }
                        }
                    }
                }
                
                Spacer()
                
                // Compatibility Indicators
                HStack(spacing: 16) {
                    CompatibilityIndicator(
                        icon: "heart.fill",
                        label: "애정도",
                        value: getCompatibilityLevel(entry.compatibilityScore)
                    )
                    
                    CompatibilityIndicator(
                        icon: "bubble.left.and.bubble.right.fill",
                        label: "소통",
                        value: getCommunicationLevel(entry.compatibilityScore)
                    )
                    
                    CompatibilityIndicator(
                        icon: "sparkles",
                        label: "미래",
                        value: getFutureLevel(entry.compatibilityScore)
                    )
                }
                
                // Call to Action
                HStack {
                    Spacer()
                    Text("상세 궁합 보기 ›")
                        .font(.footnote)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            Capsule()
                                .fill(Color.white.opacity(0.2))
                        )
                }
            }
            .padding()
        }
        .widgetURL(URL(string: "fortune://love?partner=\(entry.partnerName)"))
    }
    
    func getCompatibilityLevel(_ score: Int) -> String {
        switch score {
        case 80...100: return "매우 높음"
        case 60..<80: return "높음"
        case 40..<60: return "보통"
        case 20..<40: return "낮음"
        default: return "매우 낮음"
        }
    }
    
    func getCommunicationLevel(_ score: Int) -> String {
        switch score {
        case 70...100: return "원활"
        case 50..<70: return "양호"
        case 30..<50: return "노력 필요"
        default: return "어려움"
        }
    }
    
    func getFutureLevel(_ score: Int) -> String {
        switch score {
        case 75...100: return "밝음"
        case 55..<75: return "희망적"
        case 35..<55: return "불확실"
        default: return "도전적"
        }
    }
}

// MARK: - Compatibility Indicator
struct CompatibilityIndicator: View {
    let icon: String
    let label: String
    let value: String
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.body)
                .foregroundColor(.white.opacity(0.8))
            
            Text(label)
                .font(.caption2)
                .foregroundColor(.white.opacity(0.6))
            
            Text(value)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.white.opacity(0.1))
        )
    }
}

// MARK: - Preview
struct LoveFortuneWidgetView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            LoveFortuneWidgetView(entry: .placeholder)
                .previewContext(WidgetPreviewContext(family: .systemMedium))
            
            LoveFortuneWidgetView(entry: .placeholder)
                .previewContext(WidgetPreviewContext(family: .systemLarge))
        }
    }
}