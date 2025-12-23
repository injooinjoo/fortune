import SwiftUI

struct TimeSlotFortuneView: View {
    @StateObject private var dataManager = WatchDataManager.shared

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                Text("시간대별 운세")
                    .font(.headline)

                ForEach(dataManager.timeSlots) { slot in
                    TimeSlotCard(slot: slot)
                }
            }
            .padding()
        }
    }
}

// MARK: - Time Slot Card Component

struct TimeSlotCard: View {
    let slot: TimeSlotData
    @StateObject private var dataManager = WatchDataManager.shared

    var body: some View {
        HStack(spacing: 10) {
            // Icon
            Image(systemName: slot.icon)
                .font(.title3)
                .foregroundColor(iconColor)
                .frame(width: 30)

            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(slot.name)
                        .font(.footnote)
                        .fontWeight(.medium)

                    if slot.isCurrent {
                        Text("현재")
                            .font(.system(size: 8))
                            .padding(.horizontal, 4)
                            .padding(.vertical, 2)
                            .background(Color.blue)
                            .cornerRadius(4)
                    }
                }

                if !slot.message.isEmpty {
                    Text(slot.message)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
            }

            Spacer()

            // Score
            Text("\(slot.score)")
                .font(.footnote)
                .fontWeight(.bold)
                .foregroundColor(dataManager.scoreColor(for: slot.score))
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 10)
        .background(slot.isCurrent ? Color.blue.opacity(0.1) : Color.gray.opacity(0.1))
        .cornerRadius(10)
    }

    private var iconColor: Color {
        switch slot.key {
        case "morning":
            return .orange
        case "afternoon":
            return .yellow
        case "evening":
            return .indigo
        default:
            return .gray
        }
    }
}

#Preview {
    TimeSlotFortuneView()
}
