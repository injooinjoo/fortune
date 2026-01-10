import SwiftUI

// MARK: - Daily Fortune View

/// Redesigned daily fortune view with animated gauge and modern UI
struct DailyFortuneView: View {
    @StateObject private var viewModel: DailyFortuneViewModel
    @State private var crownValue: Double = 0

    init(viewModel: DailyFortuneViewModel? = nil) {
        _viewModel = StateObject(wrappedValue: viewModel ?? Container.shared.makeDailyFortuneViewModel())
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                if viewModel.isLoading {
                    FortuneLoadingView()
                } else if !viewModel.isValid {
                    emptyStateView
                } else {
                    contentView
                }
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 12)
        }
        .navigationTitle("오늘의 운세")
        .refreshable {
            await viewModel.refresh()
        }
    }

    // MARK: - Content View

    private var contentView: some View {
        VStack(spacing: 16) {
            // Score Gauge
            FortuneScoreGauge(
                score: viewModel.score,
                grade: viewModel.grade,
                size: 110
            )
            .focusable()
            .digitalCrownRotation($crownValue, from: 0, through: 100)

            // Grade Badge
            GradeBadge(grade: viewModel.grade)

            Divider()
                .padding(.horizontal)

            // Message
            Text(viewModel.message)
                .font(FortuneTypography.callout)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .lineLimit(4)
                .padding(.horizontal, 4)

            // Current Time Slot Preview
            if let currentSlot = viewModel.currentTimeSlot {
                timeSlotPreview(currentSlot)
            }
        }
    }

    // MARK: - Time Slot Preview

    private func timeSlotPreview(_ slot: TimeSlotData) -> some View {
        VStack(spacing: 8) {
            Divider()
                .padding(.horizontal)

            HStack {
                Image(systemName: slot.icon)
                    .foregroundStyle(FortuneColors.timeSlotColor(for: slot.name))

                Text(slot.name)
                    .font(FortuneTypography.captionBold)

                Spacer()

                Text("\(slot.score)점")
                    .font(FortuneTypography.caption)
                    .foregroundStyle(FortuneColors.scoreColor(for: slot.score))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(FortuneColors.surface)
            )
        }
    }

    // MARK: - Empty State

    private var emptyStateView: some View {
        FortuneEmptyStateView(
            icon: "iphone.slash",
            title: "데이터 없음",
            message: "iPhone 앱에서\n오늘의 운세를 조회해주세요"
        ) {
            Task {
                await viewModel.refresh()
            }
        }
    }
}

// MARK: - Preview

#Preview {
    DailyFortuneView()
}
