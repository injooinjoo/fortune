import SwiftUI

struct DailySummaryView: View {
    @StateObject private var dataManager = WatchDataManager.shared

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                if dataManager.isDataValid {
                    // Score Circle
                    ZStack {
                        Circle()
                            .stroke(
                                dataManager.scoreColor(for: dataManager.overallScore).opacity(0.3),
                                lineWidth: 8
                            )
                            .frame(width: 80, height: 80)

                        Circle()
                            .trim(from: 0, to: CGFloat(dataManager.overallScore) / 100)
                            .stroke(
                                dataManager.scoreColor(for: dataManager.overallScore),
                                style: StrokeStyle(lineWidth: 8, lineCap: .round)
                            )
                            .frame(width: 80, height: 80)
                            .rotationEffect(.degrees(-90))

                        VStack(spacing: 2) {
                            Text(dataManager.gradeEmoji)
                                .font(.title2)
                            Text("\(dataManager.overallScore)")
                                .font(.system(size: 24, weight: .bold, design: .rounded))
                        }
                    }

                    // Grade
                    Text(dataManager.overallGrade)
                        .font(.headline)
                        .foregroundColor(.secondary)

                    Divider()

                    // Message
                    Text(dataManager.overallMessage)
                        .font(.footnote)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.primary)
                        .padding(.horizontal, 8)

                    // Last Updated
                    if !dataManager.lastUpdated.isEmpty {
                        Text("업데이트: \(dataManager.lastUpdated)")
                            .font(.caption2)
                            .foregroundColor(.gray)
                    }
                } else {
                    // No Data State
                    VStack(spacing: 16) {
                        Image(systemName: "iphone.and.arrow.forward")
                            .font(.largeTitle)
                            .foregroundColor(.gray)

                        Text("iPhone에서\n앱을 열어주세요")
                            .font(.footnote)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 40)
                }
            }
            .padding()
        }
        .navigationTitle("오늘의 운세")
    }
}

#Preview {
    DailySummaryView()
}
