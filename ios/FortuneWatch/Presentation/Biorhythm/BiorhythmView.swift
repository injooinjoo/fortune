import SwiftUI

// MARK: - Biorhythm View

/// Redesigned biorhythm view with three circular gauges
struct BiorhythmView: View {
    @StateObject private var viewModel: BiorhythmViewModel

    init(viewModel: BiorhythmViewModel? = nil) {
        _viewModel = StateObject(wrappedValue: viewModel ?? Container.shared.makeBiorhythmViewModel())
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                if viewModel.isLoading {
                    FortuneLoadingView()
                } else {
                    contentView
                }
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 12)
        }
        .navigationTitle("바이오리듬")
        .refreshable {
            await viewModel.refresh()
        }
    }

    // MARK: - Content View

    private var contentView: some View {
        VStack(spacing: 20) {
            // Three biorhythm gauges
            HStack(spacing: 8) {
                BiorhythmGauge(
                    type: .physical,
                    score: viewModel.physicalScore,
                    color: FortuneColors.bioPhysical
                )

                BiorhythmGauge(
                    type: .emotional,
                    score: viewModel.emotionalScore,
                    color: FortuneColors.bioEmotional
                )

                BiorhythmGauge(
                    type: .intellectual,
                    score: viewModel.intellectualScore,
                    color: FortuneColors.bioIntellectual
                )
            }

            Divider()
                .padding(.horizontal)

            // Overall Score
            VStack(spacing: 4) {
                Text("종합")
                    .font(FortuneTypography.caption)
                    .foregroundStyle(.secondary)

                Text("\(viewModel.overallScore)")
                    .font(FortuneTypography.scoreLarge)
                    .foregroundStyle(FortuneColors.scoreColor(for: viewModel.overallScore))
            }

            // Status Message
            if !viewModel.statusMessage.isEmpty {
                Text(viewModel.statusMessage)
                    .font(FortuneTypography.callout)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
                    .padding(.horizontal, 8)
            }

            // Status Details
            statusDetailView
        }
    }

    // MARK: - Status Detail

    private var statusDetailView: some View {
        VStack(spacing: 8) {
            if !viewModel.physicalStatus.isEmpty {
                statusRow(
                    icon: "figure.run",
                    label: "신체",
                    status: viewModel.physicalStatus,
                    color: FortuneColors.bioPhysical
                )
            }

            if !viewModel.emotionalStatus.isEmpty {
                statusRow(
                    icon: "heart.fill",
                    label: "감정",
                    status: viewModel.emotionalStatus,
                    color: FortuneColors.bioEmotional
                )
            }

            if !viewModel.intellectualStatus.isEmpty {
                statusRow(
                    icon: "brain",
                    label: "지성",
                    status: viewModel.intellectualStatus,
                    color: FortuneColors.bioIntellectual
                )
            }
        }
        .padding(.horizontal, 4)
    }

    private func statusRow(icon: String, label: String, status: String, color: Color) -> some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 12))
                .foregroundStyle(color)
                .frame(width: 20)

            Text(status)
                .font(FortuneTypography.caption)
                .foregroundStyle(.secondary)
                .lineLimit(1)

            Spacer()
        }
    }
}

// MARK: - Preview

#Preview {
    BiorhythmView()
}
