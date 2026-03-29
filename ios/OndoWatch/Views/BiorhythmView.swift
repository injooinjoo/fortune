import SwiftUI

struct BiorhythmView: View {
    @StateObject private var dataManager = WatchDataManager.shared

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                Text("바이오리듬")
                    .font(.headline)

                // Three Rhythm Bars
                VStack(spacing: 12) {
                    BiorhythmBar(
                        icon: "figure.walk",
                        label: "신체",
                        score: dataManager.bioPhysicalScore,
                        color: .orange
                    )

                    BiorhythmBar(
                        icon: "heart.fill",
                        label: "감성",
                        score: dataManager.bioEmotionalScore,
                        color: .pink
                    )

                    BiorhythmBar(
                        icon: "brain.head.profile",
                        label: "지성",
                        score: dataManager.bioIntellectualScore,
                        color: .blue
                    )
                }

                Divider()

                // Overall Score
                HStack {
                    Text("종합")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("\(dataManager.bioOverallScore)점")
                        .font(.footnote)
                        .fontWeight(.semibold)
                        .foregroundColor(dataManager.scoreColor(for: dataManager.bioOverallScore))
                }
                .padding(.horizontal, 4)

                // Status Message
                if !dataManager.bioStatusMessage.isEmpty {
                    Text(dataManager.bioStatusMessage)
                        .font(.caption2)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                        .lineLimit(3)
                }
            }
            .padding()
        }
    }
}

// MARK: - Biorhythm Bar Component

struct BiorhythmBar: View {
    let icon: String
    let label: String
    let score: Int
    let color: Color

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.footnote)
                .foregroundColor(color)
                .frame(width: 20)

            Text(label)
                .font(.caption)
                .frame(width: 30, alignment: .leading)

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(color.opacity(0.2))

                    RoundedRectangle(cornerRadius: 4)
                        .fill(color)
                        .frame(width: geometry.size.width * CGFloat(score) / 100)
                }
            }
            .frame(height: 12)

            Text("\(score)")
                .font(.caption)
                .fontWeight(.medium)
                .frame(width: 28, alignment: .trailing)
        }
    }
}

#Preview {
    BiorhythmView()
}
