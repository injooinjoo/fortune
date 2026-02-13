import SwiftUI

// MARK: - Compatibility View

/// Compatibility result view with score circle and summary
struct CompatibilityView: View {
    @StateObject private var viewModel: CompatibilityViewModel

    init(viewModel: CompatibilityViewModel? = nil) {
        _viewModel = StateObject(wrappedValue: viewModel ?? Container.shared.makeCompatibilityViewModel())
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                if viewModel.isLoading {
                    FortuneLoadingView()
                } else if !viewModel.hasData {
                    emptyStateView
                } else {
                    contentView
                }
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 12)
        }
        .navigationTitle("궁합")
        .refreshable {
            await viewModel.refresh()
        }
    }

    // MARK: - Content View

    private var contentView: some View {
        VStack(spacing: 16) {
            // Partner name
            HStack(spacing: 6) {
                Image(systemName: "person.2.fill")
                    .foregroundStyle(FortuneColors.primary)

                Text("나 & \(viewModel.partnerName)")
                    .font(FortuneTypography.title2)
            }

            // Score with emoji
            VStack(spacing: 4) {
                Text(viewModel.scoreEmoji)
                    .font(FortuneTypography.emojiLarge)

                Text("\(viewModel.score)%")
                    .font(FortuneTypography.scoreHero)
                    .foregroundStyle(viewModel.scoreColor)
            }

            // Score gauge
            CompatibilityGauge(score: viewModel.score)

            Divider()
                .padding(.horizontal)

            // Summary
            if !viewModel.summary.isEmpty {
                Text(viewModel.summary)
                    .font(FortuneTypography.callout)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(4)
                    .padding(.horizontal, 4)
            }

            // Strengths & Challenges
            if !viewModel.strengths.isEmpty || !viewModel.challenges.isEmpty {
                strengthsChallengesView
            }
        }
    }

    // MARK: - Strengths & Challenges

    private var strengthsChallengesView: some View {
        VStack(spacing: 12) {
            // Strengths
            if !viewModel.strengths.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                        Text("강점")
                            .font(FortuneTypography.captionBold)
                    }

                    ForEach(viewModel.strengths.prefix(2), id: \.self) { strength in
                        Text("• \(strength)")
                            .font(FortuneTypography.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }

            // Challenges
            if !viewModel.challenges.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundStyle(.orange)
                        Text("주의점")
                            .font(FortuneTypography.captionBold)
                    }

                    ForEach(viewModel.challenges.prefix(2), id: \.self) { challenge in
                        Text("• \(challenge)")
                            .font(FortuneTypography.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(.horizontal, 8)
    }

    // MARK: - Empty State

    private var emptyStateView: some View {
        FortuneEmptyStateView(
            icon: "heart.slash",
            title: "궁합 결과 없음",
            message: "iPhone 앱에서\n궁합을 확인해주세요"
        ) {
            Task {
                await viewModel.refresh()
            }
        }
    }
}

// MARK: - Compatibility Gauge

struct CompatibilityGauge: View {
    let score: Int

    @State private var animatedScore: Double = 0

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Background
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.gray.opacity(0.2))

                // Fill
                RoundedRectangle(cornerRadius: 4)
                    .fill(FortuneColors.scoreGradient(for: score))
                    .frame(width: geometry.size.width * (animatedScore / 100))
                    .animation(.spring(response: 0.8, dampingFraction: 0.8), value: animatedScore)
            }
        }
        .frame(height: 8)
        .padding(.horizontal, 20)
        .onAppear {
            withAnimation(.easeOut(duration: 0.8)) {
                animatedScore = Double(score)
            }
        }
    }
}

// MARK: - Preview

#Preview {
    CompatibilityView()
}
