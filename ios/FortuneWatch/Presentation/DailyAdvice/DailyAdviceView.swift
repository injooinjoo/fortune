import SwiftUI

// MARK: - Daily Advice View

/// Daily advice view with Do/Don't recommendations
struct DailyAdviceView: View {
    @StateObject private var viewModel: DailyAdviceViewModel

    init(viewModel: DailyAdviceViewModel? = nil) {
        _viewModel = StateObject(wrappedValue: viewModel ?? Container.shared.makeDailyAdviceViewModel())
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                if viewModel.isLoading {
                    FortuneLoadingView()
                } else if !viewModel.hasAdvice {
                    emptyStateView
                } else {
                    contentView
                }
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 12)
        }
        .navigationTitle("오늘의 조언")
        .refreshable {
            await viewModel.refresh()
        }
    }

    // MARK: - Content View

    private var contentView: some View {
        VStack(spacing: 16) {
            // Focus Area
            if !viewModel.focusArea.isEmpty {
                HStack(spacing: 6) {
                    Image(systemName: "target")
                        .foregroundStyle(FortuneColors.primary)

                    Text("오늘의 포커스")
                        .font(FortuneTypography.caption)
                        .foregroundStyle(.secondary)
                }

                Text(viewModel.focusArea)
                    .font(FortuneTypography.title2)
                    .multilineTextAlignment(.center)
            }

            Divider()
                .padding(.horizontal)

            // Do Advice
            if !viewModel.doAdvice.isEmpty {
                AdviceCard(
                    type: .do,
                    advice: viewModel.doAdvice
                )
            }

            // Don't Advice
            if !viewModel.dontAdvice.isEmpty {
                AdviceCard(
                    type: .dont,
                    advice: viewModel.dontAdvice
                )
            }

            // Motivational Quote
            if !viewModel.motivationalQuote.isEmpty {
                VStack(spacing: 8) {
                    Divider()
                        .padding(.horizontal)

                    Text("\"")
                        .font(FortuneTypography.title)
                        .foregroundStyle(FortuneColors.accent)

                    Text(viewModel.motivationalQuote)
                        .font(FortuneTypography.caption)
                        .foregroundStyle(.secondary)
                        .italic()
                        .multilineTextAlignment(.center)
                        .lineLimit(3)
                        .padding(.horizontal, 8)
                }
            }
        }
    }

    // MARK: - Empty State

    private var emptyStateView: some View {
        FortuneEmptyStateView(
            icon: "lightbulb.slash",
            title: "조언 없음",
            message: "iPhone 앱에서\n운세를 조회해주세요"
        ) {
            Task {
                await viewModel.refresh()
            }
        }
    }
}

// MARK: - Advice Card

struct AdviceCard: View {
    enum AdviceType {
        case `do`
        case dont

        var icon: String {
            switch self {
            case .do: return "checkmark.circle.fill"
            case .dont: return "xmark.circle.fill"
            }
        }

        var color: Color {
            switch self {
            case .do: return .green
            case .dont: return .red
            }
        }

        var label: String {
            switch self {
            case .do: return "DO"
            case .dont: return "DON'T"
            }
        }
    }

    let type: AdviceType
    let advice: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header
            HStack(spacing: 6) {
                Image(systemName: type.icon)
                    .foregroundStyle(type.color)

                Text(type.label)
                    .font(FortuneTypography.captionBold)
                    .foregroundStyle(type.color)
            }

            // Advice text
            Text(advice)
                .font(FortuneTypography.callout)
                .foregroundStyle(.primary)
                .lineLimit(3)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(type.color.opacity(0.1))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(type.color.opacity(0.3), lineWidth: 1)
        )
    }
}

// MARK: - Preview

#Preview {
    DailyAdviceView()
}
