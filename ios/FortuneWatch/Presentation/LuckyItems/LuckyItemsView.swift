import SwiftUI

// MARK: - Lucky Items View

/// Redesigned lucky items view with card-style display
struct LuckyItemsView: View {
    @StateObject private var viewModel: LuckyItemsViewModel

    init(viewModel: LuckyItemsViewModel? = nil) {
        _viewModel = StateObject(wrappedValue: viewModel ?? Container.shared.makeLuckyItemsViewModel())
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                if viewModel.isLoading {
                    FortuneLoadingView()
                } else if viewModel.items.isEmpty {
                    emptyStateView
                } else {
                    contentView
                }
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 12)
        }
        .navigationTitle("행운 아이템")
        .refreshable {
            await viewModel.refresh()
        }
    }

    // MARK: - Content View

    private var contentView: some View {
        VStack(spacing: 10) {
            ForEach(viewModel.items) { item in
                LuckyItemCard(item: item)
            }
        }
    }

    // MARK: - Empty State

    private var emptyStateView: some View {
        FortuneEmptyStateView(
            icon: "star.slash",
            title: "행운 아이템 없음",
            message: "iPhone 앱에서\n운세를 조회해주세요"
        ) {
            Task {
                await viewModel.refresh()
            }
        }
    }
}

// MARK: - Lucky Item Card

struct LuckyItemCard: View {
    let item: LuckyItemDisplay

    var body: some View {
        HStack(spacing: 12) {
            // Icon
            ZStack {
                Circle()
                    .fill(item.color.opacity(0.2))
                    .frame(width: 36, height: 36)

                Image(systemName: item.icon)
                    .font(.system(size: 14))
                    .foregroundStyle(item.color)
            }

            // Content
            VStack(alignment: .leading, spacing: 2) {
                Text(item.label)
                    .font(FortuneTypography.caption)
                    .foregroundStyle(.secondary)

                Text(item.value)
                    .font(FortuneTypography.bodyBold)
                    .foregroundStyle(.primary)
                    .lineLimit(1)
            }

            Spacer()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(FortuneColors.surface)
        )
    }
}

// MARK: - Preview

#Preview {
    LuckyItemsView()
}
