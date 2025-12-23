import SwiftUI

struct LuckyItemsView: View {
    @StateObject private var dataManager = WatchDataManager.shared

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                Text("행운의 아이템")
                    .font(.headline)

                if hasAnyLuckyItem {
                    VStack(spacing: 12) {
                        // Lucky Color
                        if !dataManager.luckyColor.isEmpty {
                            LuckyItemRow(
                                icon: "paintpalette.fill",
                                iconColor: .purple,
                                label: "색상",
                                value: dataManager.luckyColor
                            )
                        }

                        // Lucky Number
                        if !dataManager.luckyNumber.isEmpty {
                            LuckyItemRow(
                                icon: "number.circle.fill",
                                iconColor: .blue,
                                label: "숫자",
                                value: dataManager.luckyNumber
                            )
                        }

                        // Lucky Direction
                        if !dataManager.luckyDirection.isEmpty {
                            LuckyItemRow(
                                icon: "safari.fill",
                                iconColor: .green,
                                label: "방향",
                                value: dataManager.luckyDirection
                            )
                        }

                        // Lucky Time
                        if !dataManager.luckyTime.isEmpty {
                            LuckyItemRow(
                                icon: "clock.fill",
                                iconColor: .orange,
                                label: "시간",
                                value: dataManager.luckyTime
                            )
                        }

                        // Lucky Item
                        if !dataManager.luckyItem.isEmpty {
                            LuckyItemRow(
                                icon: "sparkles",
                                iconColor: .yellow,
                                label: "아이템",
                                value: dataManager.luckyItem
                            )
                        }
                    }
                } else {
                    // No Data State
                    VStack(spacing: 12) {
                        Image(systemName: "sparkles")
                            .font(.title)
                            .foregroundColor(.gray)

                        Text("행운 아이템 정보가\n없습니다")
                            .font(.footnote)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 20)
                }
            }
            .padding()
        }
    }

    private var hasAnyLuckyItem: Bool {
        !dataManager.luckyColor.isEmpty ||
        !dataManager.luckyNumber.isEmpty ||
        !dataManager.luckyDirection.isEmpty ||
        !dataManager.luckyTime.isEmpty ||
        !dataManager.luckyItem.isEmpty
    }
}

// MARK: - Lucky Item Row Component

struct LuckyItemRow: View {
    let icon: String
    let iconColor: Color
    let label: String
    let value: String

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.footnote)
                .foregroundColor(iconColor)
                .frame(width: 24)

            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
                .frame(width: 40, alignment: .leading)

            Text(value)
                .font(.caption)
                .fontWeight(.medium)
                .lineLimit(1)

            Spacer()
        }
        .padding(.vertical, 4)
        .padding(.horizontal, 8)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
    }
}

#Preview {
    LuckyItemsView()
}
