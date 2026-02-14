import SwiftUI

struct SelectWebsitesSheet: View {
    @ObservedObject var blockList: BlockList
    var onDismiss: () -> Void
    @State private var newKeyword = ""

    var body: some View {
        VStack(spacing: 0) {
            header
            Divider()

            VStack(spacing: 8) {
                HStack {
                    TextField("Type any website to add...", text: $newKeyword)
                        .textFieldStyle(.roundedBorder)
                        .onSubmit { addKeyword() }
                    Button(action: addKeyword) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                    }
                    .buttonStyle(.plain)
                    .disabled(newKeyword.trimmingCharacters(in: .whitespaces).isEmpty)
                }
                .padding(.horizontal)
                .padding(.top, 8)
            }

            if blockList.urlKeywords.isEmpty {
                Spacer()
                Text("No websites blocked yet")
                    .foregroundStyle(.tertiary)
                Spacer()
            } else {
                List {
                    ForEach(blockList.urlKeywords, id: \.self) { keyword in
                        HStack(spacing: 10) {
                            LetterAvatar(text: keyword, size: 28)
                            VStack(alignment: .leading) {
                                Text(keyword)
                                    .lineLimit(1)
                            }
                            Spacer()
                            Button {
                                blockList.removeKeyword(keyword)
                            } label: {
                                Image(systemName: "minus.circle.fill")
                                    .foregroundStyle(.red)
                                    .font(.title3)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }

            Divider()
            footer
        }
    }

    private var header: some View {
        HStack {
            Button(action: onDismiss) {
                Image(systemName: "chevron.left")
                    .font(.body)
            }
            .buttonStyle(.plain)
            Text("Select Websites")
                .font(.headline)
            Spacer()
            Text("\(blockList.urlKeywords.count) keywords")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
    }

    private var footer: some View {
        HStack {
            Button("Clear All") {
                let keywords = blockList.urlKeywords
                for keyword in keywords {
                    blockList.removeKeyword(keyword)
                }
            }
            .buttonStyle(.plain)
            .foregroundStyle(.red)
            .disabled(blockList.urlKeywords.isEmpty)

            Spacer()

            Button("Done", action: onDismiss)
                .buttonStyle(.borderedProminent)
                .controlSize(.small)
        }
        .padding()
    }

    private func addKeyword() {
        blockList.addKeyword(newKeyword)
        newKeyword = ""
    }
}
