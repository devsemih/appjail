import SwiftUI

struct WebsiteCategoriesSheet: View {
    @ObservedObject var blockList: BlockList
    var onDismiss: () -> Void
    @State private var expandedCategory: String?

    var body: some View {
        VStack(spacing: 0) {
            SheetHeader(title: "Categories")

            ScrollView {
                VStack(spacing: 12) {
                    // All categories in one glass grouped section
                    VStack(spacing: 0) {
                        ForEach(Array(WebsiteCategory.predefined.enumerated()), id: \.element.id) { index, category in
                            VStack(alignment: .leading, spacing: 8) {
                                HStack(spacing: 10) {
                                    Image(systemName: category.systemImage)
                                        .font(.title3)
                                        .foregroundStyle(.tint)
                                        .frame(width: 28)

                                    VStack(alignment: .leading) {
                                        Text(category.name)
                                        Text("\(category.keywords.count) websites")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }

                                    Spacer()

                                    Button {
                                        withAnimation {
                                            if expandedCategory == category.id {
                                                expandedCategory = nil
                                            } else {
                                                expandedCategory = category.id
                                            }
                                        }
                                    } label: {
                                        Image(systemName: expandedCategory == category.id ? "chevron.up" : "chevron.down")
                                            .foregroundStyle(.secondary)
                                            .font(.caption)
                                            .frame(width: 28, height: 28)
                                            .contentShape(Rectangle())
                                    }
                                    .buttonStyle(.plain)

                                    Toggle("", isOn: Binding(
                                        get: { blockList.enabledCategoryIDs.contains(category.id) },
                                        set: { _ in blockList.toggleCategory(category.id) }
                                    ))
                                    .toggleStyle(.switch)
                                    .labelsHidden()
                                    .controlSize(.small)
                                }

                                if expandedCategory == category.id {
                                    FlowLayout(spacing: 4) {
                                        ForEach(category.keywords, id: \.self) { keyword in
                                            Text(keyword)
                                                .font(.caption2)
                                                .padding(.horizontal, 8)
                                                .padding(.vertical, 3)
                                                .background(Color.gray.opacity(0.15), in: Capsule())
                                        }
                                    }
                                    .padding(.leading, 38)
                                }
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 10)
                            if index < WebsiteCategory.predefined.count - 1 {
                                Divider().padding(.leading, 12)
                            }
                        }
                    }
                    .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 12))
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
            }

            SheetFooter(
                trailingTitle: "Done",
                trailingAction: onDismiss
            )
        }
    }
}

private struct FlowLayout: Layout {
    var spacing: CGFloat = 4

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = computeLayout(proposal: proposal, subviews: subviews)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = computeLayout(proposal: proposal, subviews: subviews)
        for (index, position) in result.positions.enumerated() {
            subviews[index].place(at: CGPoint(x: bounds.minX + position.x, y: bounds.minY + position.y), proposal: .unspecified)
        }
    }

    private func computeLayout(proposal: ProposedViewSize, subviews: Subviews) -> (size: CGSize, positions: [CGPoint]) {
        let maxWidth = proposal.width ?? .infinity
        var positions: [CGPoint] = []
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0
        var maxX: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > maxWidth && x > 0 {
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }
            positions.append(CGPoint(x: x, y: y))
            rowHeight = max(rowHeight, size.height)
            x += size.width + spacing
            maxX = max(maxX, x)
        }

        return (CGSize(width: maxX, height: y + rowHeight), positions)
    }
}
