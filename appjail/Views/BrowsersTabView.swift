import SwiftUI

struct BrowsersTabView: View {
    @ObservedObject var blockList: BlockList
    @State private var newKeyword = ""

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                TextField("Add URL keyword...", text: $newKeyword)
                    .textFieldStyle(.roundedBorder)
                    .onSubmit { addKeyword() }
                Button(action: addKeyword) {
                    Image(systemName: "plus.circle.fill")
                }
                .disabled(newKeyword.trimmingCharacters(in: .whitespaces).isEmpty)
            }
            .padding(8)

            Text("Tabs matching these keywords will be closed when you switch to a browser.")
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 8)
                .padding(.bottom, 4)

            if blockList.urlKeywords.isEmpty {
                Spacer()
                Text("No keywords added")
                    .foregroundStyle(.tertiary)
                Spacer()
            } else {
                List {
                    ForEach(blockList.urlKeywords, id: \.self) { keyword in
                        KeywordRowView(keyword: keyword) {
                            blockList.removeKeyword(keyword)
                        }
                    }
                }
            }
        }
    }

    private func addKeyword() {
        blockList.addKeyword(newKeyword)
        newKeyword = ""
    }
}
