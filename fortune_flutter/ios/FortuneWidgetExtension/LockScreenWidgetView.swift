import SwiftUI
import WidgetKit

@available(iOS 16.0, *)
struct LockScreenWidgetView: View {
    var entry: FortuneEntry
    @Environment(\.widgetFamily) var family
    
    var body: some View {
        switch family {
        case .accessoryCircular:
            AccessoryCircularView(entry: entry)
        case .accessoryRectangular:
            AccessoryRectangularView(entry: entry)
        case .accessoryInline:
            AccessoryInlineView(entry: entry)
        default:
            AccessoryCircularView(entry: entry)
        }
    }
}

// MARK: - Circular Widget
@available(iOS 16.0, *)
struct AccessoryCircularView: View {
    let entry: FortuneEntry
    
    var body: some View {
        ZStack {
            AccessoryWidgetBackground()
            
            VStack(spacing: 2) {
                Image(systemName: "sparkles")
                    .font(.caption2)
                
                Text("\(entry.fortuneScore)")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                
                Text("운세")
                    .font(.system(size: 10))
                    .fontWeight(.medium)
            }
        }
        .widgetURL(URL(string: "fortune://daily"))
    }
}

// MARK: - Rectangular Widget
@available(iOS 16.0, *)
struct AccessoryRectangularView: View {
    let entry: FortuneEntry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack(spacing: 4) {
                Image(systemName: "sparkles")
                    .font(.caption2)
                Text("오늘의 운세")
                    .font(.caption2)
                    .fontWeight(.semibold)
                Spacer()
                Text("\(entry.fortuneScore)/100")
                    .font(.caption2.monospacedDigit())
                    .fontWeight(.bold)
            }
            
            Divider()
                .opacity(0.5)
            
            Text(entry.fortuneMessage)
                .font(.system(size: 11))
                .lineLimit(2)
                .multilineTextAlignment(.leading)
            
            Spacer(minLength: 0)
            
            HStack(spacing: 8) {
                HStack(spacing: 2) {
                    Image(systemName: "paintpalette")
                        .font(.system(size: 9))
                    Text(entry.luckyColor)
                        .font(.system(size: 10))
                }
                
                HStack(spacing: 2) {
                    Image(systemName: "number")
                        .font(.system(size: 9))
                    Text("\(entry.luckyNumber)")
                        .font(.system(size: 10))
                }
            }
        }
        .widgetURL(URL(string: "fortune://daily"))
    }
}

// MARK: - Inline Widget
@available(iOS 16.0, *)
struct AccessoryInlineView: View {
    let entry: FortuneEntry
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "sparkles")
            Text("운세 \(entry.fortuneScore)점")
            Text("·")
            Text("행운의 숫자 \(entry.luckyNumber)")
        }
        .widgetURL(URL(string: "fortune://daily"))
    }
}

// MARK: - Preview
@available(iOS 16.0, *)
struct LockScreenWidgetView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            LockScreenWidgetView(entry: .placeholder)
                .previewContext(WidgetPreviewContext(family: .accessoryCircular))
                .previewDisplayName("Circular")
            
            LockScreenWidgetView(entry: .placeholder)
                .previewContext(WidgetPreviewContext(family: .accessoryRectangular))
                .previewDisplayName("Rectangular")
            
            LockScreenWidgetView(entry: .placeholder)
                .previewContext(WidgetPreviewContext(family: .accessoryInline))
                .previewDisplayName("Inline")
        }
    }
}