import SwiftUI

// MARK: - Fortune Score Gauge

/// Circular gauge displaying fortune score with animation
struct FortuneScoreGauge: View {
    let score: Int
    let grade: String
    var showGrade: Bool = true
    var size: CGFloat = 120

    @State private var animatedScore: Double = 0

    var body: some View {
        ZStack {
            // Background circle
            Circle()
                .stroke(
                    Color.gray.opacity(0.2),
                    lineWidth: 12
                )

            // Progress circle
            Circle()
                .trim(from: 0, to: animatedScore / 100)
                .stroke(
                    FortuneColors.scoreGradient(for: score),
                    style: StrokeStyle(
                        lineWidth: 12,
                        lineCap: .round
                    )
                )
                .rotationEffect(.degrees(-90))
                .animation(.spring(response: 1.0, dampingFraction: 0.8), value: animatedScore)

            // Center content
            VStack(spacing: 2) {
                Text("\(Int(animatedScore))")
                    .font(FortuneTypography.scoreHero)
                    .foregroundStyle(FortuneColors.scoreColor(for: score))
                    .contentTransition(.numericText())

                if showGrade && !grade.isEmpty {
                    Text(grade)
                        .font(FortuneTypography.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .frame(width: size, height: size)
        .onAppear {
            withAnimation(.easeOut(duration: 1.0)) {
                animatedScore = Double(score)
            }
        }
        .onChange(of: score) { _, newValue in
            withAnimation(.easeOut(duration: 0.5)) {
                animatedScore = Double(newValue)
            }
        }
    }
}

// MARK: - Grade Badge

/// Badge showing fortune grade with emoji
struct GradeBadge: View {
    let grade: String

    var body: some View {
        HStack(spacing: 4) {
            Text(gradeEmoji)
                .font(FortuneTypography.emojiSmall)
            Text(grade)
                .font(FortuneTypography.captionBold)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(
            Capsule()
                .fill(FortuneColors.gradeColor(for: grade).opacity(0.2))
        )
        .overlay(
            Capsule()
                .stroke(FortuneColors.gradeColor(for: grade), lineWidth: 1)
        )
    }

    private var gradeEmoji: String {
        switch grade {
        case "대길": return "🌟"
        case "길": return "✨"
        case "평": return "⭐"
        case "흉": return "🌥️"
        case "대흉": return "🌧️"
        default: return "✨"
        }
    }
}

// MARK: - Biorhythm Gauge

/// Small circular gauge for biorhythm display
struct BiorhythmGauge: View {
    enum BioType: String {
        case physical = "신체"
        case emotional = "감정"
        case intellectual = "지성"

        var icon: String {
            switch self {
            case .physical: return "figure.run"
            case .emotional: return "heart.fill"
            case .intellectual: return "brain"
            }
        }
    }

    let type: BioType
    let score: Int
    let color: Color

    @State private var animatedScore: Double = 0

    var body: some View {
        VStack(spacing: 4) {
            ZStack {
                Circle()
                    .stroke(color.opacity(0.2), lineWidth: 6)

                Circle()
                    .trim(from: 0, to: animatedScore / 100)
                    .stroke(
                        color,
                        style: StrokeStyle(lineWidth: 6, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .animation(.spring(response: 0.8, dampingFraction: 0.8), value: animatedScore)

                Image(systemName: type.icon)
                    .font(.system(size: 14))
                    .foregroundStyle(color)
            }
            .frame(width: 44, height: 44)

            Text("\(Int(animatedScore))")
                .font(FortuneTypography.scoreSmall)
                .foregroundStyle(color)

            Text(type.rawValue)
                .font(FortuneTypography.caption)
                .foregroundStyle(.secondary)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.8)) {
                animatedScore = Double(score)
            }
        }
        .onChange(of: score) { _, newValue in
            withAnimation(.easeOut(duration: 0.5)) {
                animatedScore = Double(newValue)
            }
        }
    }
}

// MARK: - Loading View

struct FortuneLoadingView: View {
    var body: some View {
        VStack(spacing: 12) {
            ProgressView()
                .progressViewStyle(.circular)
            Text("불러오는 중...")
                .font(FortuneTypography.caption)
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: - Empty State View

struct FortuneEmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    var action: (() -> Void)?

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 36))
                .foregroundStyle(.secondary)

            Text(title)
                .font(FortuneTypography.title2)
                .multilineTextAlignment(.center)

            Text(message)
                .font(FortuneTypography.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            if let action = action {
                Button(action: action) {
                    Text("새로고침")
                        .font(FortuneTypography.captionBold)
                }
                .buttonStyle(.borderedProminent)
                .tint(FortuneColors.primary)
            }
        }
        .padding()
    }
}

// MARK: - Preview

#Preview {
    ScrollView {
        VStack(spacing: 20) {
            FortuneScoreGauge(score: 85, grade: "대길")

            GradeBadge(grade: "대길")

            HStack {
                BiorhythmGauge(type: .physical, score: 75, color: FortuneColors.bioPhysical)
                BiorhythmGauge(type: .emotional, score: 60, color: FortuneColors.bioEmotional)
                BiorhythmGauge(type: .intellectual, score: 90, color: FortuneColors.bioIntellectual)
            }

            FortuneEmptyStateView(
                icon: "iphone.slash",
                title: "데이터 없음",
                message: "iPhone 앱에서 운세를 조회해주세요"
            )
        }
    }
}
