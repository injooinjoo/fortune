import SwiftUI

// MARK: - Tarot View

/// Tarot single card view with flip animation
struct TarotView: View {
    @StateObject private var viewModel: TarotViewModel

    init(viewModel: TarotViewModel? = nil) {
        _viewModel = StateObject(wrappedValue: viewModel ?? Container.shared.makeTarotViewModel())
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                if viewModel.isLoading {
                    FortuneLoadingView()
                } else if !viewModel.hasCard {
                    emptyStateView
                } else {
                    contentView
                }
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 12)
        }
        .navigationTitle("타로 한 장")
        .refreshable {
            await viewModel.refresh()
        }
    }

    // MARK: - Content View

    private var contentView: some View {
        VStack(spacing: 16) {
            // Card with flip animation
            TarotCardView(
                cardName: viewModel.cardName,
                isReversed: viewModel.isReversed,
                isFlipped: viewModel.isFlipped
            )
            .onTapGesture {
                viewModel.flipCard()
            }

            // Card status
            if viewModel.isFlipped {
                // Card name
                Text(viewModel.cardName)
                    .font(FortuneTypography.title)
                    .transition(.opacity)

                // Reversed indicator
                Text(viewModel.cardStatusText)
                    .font(FortuneTypography.caption)
                    .foregroundStyle(viewModel.isReversed ? .orange : .green)
                    .transition(.opacity)

                Divider()
                    .padding(.horizontal)

                // Interpretation
                if !viewModel.interpretation.isEmpty {
                    Text(viewModel.interpretation)
                        .font(FortuneTypography.callout)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .lineLimit(4)
                        .padding(.horizontal, 4)
                        .transition(.opacity)
                }

                // Advice
                if !viewModel.advice.isEmpty {
                    VStack(spacing: 4) {
                        Text("조언")
                            .font(FortuneTypography.captionBold)
                            .foregroundStyle(.secondary)

                        Text(viewModel.advice)
                            .font(FortuneTypography.caption)
                            .multilineTextAlignment(.center)
                            .lineLimit(3)
                    }
                    .padding(.horizontal, 4)
                    .transition(.opacity)
                }
            } else {
                Text("탭하여 카드 뒤집기")
                    .font(FortuneTypography.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: viewModel.isFlipped)
    }

    // MARK: - Empty State

    private var emptyStateView: some View {
        FortuneEmptyStateView(
            icon: "rectangle.portrait.on.rectangle.portrait.angled.fill",
            title: "타로 카드 없음",
            message: "iPhone 앱에서\n타로를 뽑아주세요"
        ) {
            Task {
                await viewModel.refresh()
            }
        }
    }
}

// MARK: - Tarot Card View

struct TarotCardView: View {
    let cardName: String
    let isReversed: Bool
    let isFlipped: Bool

    var body: some View {
        ZStack {
            // Card back
            RoundedRectangle(cornerRadius: 12)
                .fill(
                    LinearGradient(
                        colors: [FortuneColors.primary, FortuneColors.secondary],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                )
                .overlay(
                    Image(systemName: "sparkles")
                        .font(.system(size: 30))
                        .foregroundStyle(.white.opacity(0.5))
                )
                .opacity(isFlipped ? 0 : 1)
                .rotation3DEffect(
                    .degrees(isFlipped ? -90 : 0),
                    axis: (x: 0, y: 1, z: 0)
                )

            // Card front
            RoundedRectangle(cornerRadius: 12)
                .fill(FortuneColors.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(FortuneColors.primary.opacity(0.5), lineWidth: 1)
                )
                .overlay(
                    VStack(spacing: 8) {
                        Image(systemName: "sparkle")
                            .font(.system(size: 24))
                            .foregroundStyle(FortuneColors.primary)
                            .rotationEffect(.degrees(isReversed ? 180 : 0))

                        Text(cardName)
                            .font(FortuneTypography.caption)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
                            .rotationEffect(.degrees(isReversed ? 180 : 0))
                    }
                    .padding(8)
                )
                .opacity(isFlipped ? 1 : 0)
                .rotation3DEffect(
                    .degrees(isFlipped ? 0 : 90),
                    axis: (x: 0, y: 1, z: 0)
                )
        }
        .frame(width: 100, height: 140)
        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: isFlipped)
    }
}

// MARK: - Preview

#Preview {
    TarotView()
}
