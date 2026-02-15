import SwiftUI

struct SelectWebsitesSheet: View {
    @ObservedObject var blockList: BlockList
    var onDismiss: () -> Void
    @State private var newKeyword = ""

    var body: some View {
        VStack(spacing: 0) {
            SheetHeader(
                title: "Websites",
                trailingText: blockList.urlKeywords.isEmpty ? nil : "\(blockList.urlKeywords.count) keywords"
            )

            ScrollView {
                VStack(spacing: 12) {
                    // Input field in glass section
                    HStack {
                        TextField("Type any website to add...", text: $newKeyword)
                            .textFieldStyle(.roundedBorder)
                            .onSubmit { addKeyword() }
                        Button(action: addKeyword) {
                            Image(systemName: "plus.circle.fill")
                                .font(.title3)
                                .frame(width: 32, height: 32)
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        .disabled(newKeyword.trimmingCharacters(in: .whitespaces).isEmpty)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 12))

                    if blockList.urlKeywords.isEmpty {
                        VStack(spacing: 8) {
                            Text("No websites blocked yet")
                                .foregroundStyle(.tertiary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 40)
                    } else {
                        // Keywords in glass grouped section
                        VStack(spacing: 0) {
                            ForEach(Array(blockList.urlKeywords.enumerated()), id: \.element) { index, keyword in
                                HStack(spacing: 10) {
                                    LetterAvatar(text: keyword, size: 28)
                                    Text(keyword)
                                        .lineLimit(1)
                                    Spacer()
                                    Button {
                                        blockList.removeKeyword(keyword)
                                    } label: {
                                        Image(systemName: "minus.circle.fill")
                                            .foregroundStyle(.red)
                                            .font(.title3)
                                            .frame(width: 32, height: 32)
                                            .contentShape(Rectangle())
                                    }
                                    .buttonStyle(.plain)
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 10)
                                if index < blockList.urlKeywords.count - 1 {
                                    Divider().padding(.leading, 12)
                                }
                            }
                        }
                        .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 12))
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
            }

            SheetFooter(
                leadingTitle: "Clear All",
                leadingAction: {
                    let keywords = blockList.urlKeywords
                    for keyword in keywords {
                        blockList.removeKeyword(keyword)
                    }
                },
                leadingDisabled: blockList.urlKeywords.isEmpty,
                leadingDestructive: true,
                trailingTitle: "Done",
                trailingAction: onDismiss
            )
        }
    }

    private func addKeyword() {
        blockList.addKeyword(newKeyword)
        newKeyword = ""
    }
}
