import SwiftUI

// MARK: - Time Slot View

/// Redesigned time slot fortune view
struct TimeSlotView: View {
    @StateObject private var viewModel: TimeSlotViewModel

    init(viewModel: TimeSlotViewModel? = nil) {
        _viewModel = StateObject(wrappedValue: viewModel ?? Container.shared.makeTimeSlotViewModel())
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                if viewModel.isLoading {
                    FortuneLoadingView()
                } else if viewModel.timeSlots.isEmpty {
                    emptyStateView
                } else {
                    contentView
                }
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 12)
        }
        .navigationTitle("시간대 운세")
        .refreshable {
            await viewModel.refresh()
        }
    }

    // MARK: - Content View

    private var contentView: some View {
        VStack(spacing: 16) {
            // Current Time Slot Highlight
            if let current = viewModel.currentTimeSlot {
                currentTimeSlotCard(current)
            }

            Divider()
                .padding(.horizontal)

            // All Time Slots
            ForEach(viewModel.timeSlots) { slot in
                TimeSlotCard(slot: slot)
            }
        }
    }

    // MARK: - Current Time Slot Card

    private func currentTimeSlotCard(_ slot: TimeSlotData) -> some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: slot.icon)
                    .font(.system(size: 20))
                    .foregroundStyle(FortuneColors.timeSlotColor(for: slot.name))

                Text("지금은 \(slot.name)")
                    .font(FortuneTypography.title2)
            }

            Text("\(slot.score)")
                .font(FortuneTypography.scoreHero)
                .foregroundStyle(FortuneColors.scoreColor(for: slot.score))

            if !slot.message.isEmpty {
                Text(slot.message)
                    .font(FortuneTypography.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(FortuneColors.surfaceElevated)
        )
    }

    // MARK: - Empty State

    private var emptyStateView: some View {
        FortuneEmptyStateView(
            icon: "clock.badge.questionmark",
            title: "시간대 운세 없음",
            message: "iPhone 앱에서\n운세를 조회해주세요"
        ) {
            Task {
                await viewModel.refresh()
            }
        }
    }
}

// MARK: - Time Slot Card

struct TimeSlotCard: View {
    let slot: TimeSlotData

    var body: some View {
        HStack(spacing: 12) {
            // Icon
            Image(systemName: slot.icon)
                .font(.system(size: 16))
                .foregroundStyle(FortuneColors.timeSlotColor(for: slot.name))
                .frame(width: 24)

            // Name
            Text(slot.name)
                .font(FortuneTypography.body)

            Spacer()

            // Score
            Text("\(slot.score)점")
                .font(FortuneTypography.bodyBold)
                .foregroundStyle(FortuneColors.scoreColor(for: slot.score))

            // Current indicator
            if slot.isCurrent {
                Circle()
                    .fill(FortuneColors.primary)
                    .frame(width: 8, height: 8)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(slot.isCurrent ? FortuneColors.surface : Color.clear)
        )
    }
}

// MARK: - Preview

#Preview {
    TimeSlotView()
}
