import SwiftUI

struct SheetFooter: View {
    let leadingTitle: String?
    let leadingAction: (() -> Void)?
    let trailingTitle: String
    let trailingAction: () -> Void
    var leadingDisabled: Bool = false
    var leadingDestructive: Bool = false

    init(
        leadingTitle: String? = nil,
        leadingAction: (() -> Void)? = nil,
        leadingDisabled: Bool = false,
        leadingDestructive: Bool = false,
        trailingTitle: String,
        trailingAction: @escaping () -> Void
    ) {
        self.leadingTitle = leadingTitle
        self.leadingAction = leadingAction
        self.leadingDisabled = leadingDisabled
        self.leadingDestructive = leadingDestructive
        self.trailingTitle = trailingTitle
        self.trailingAction = trailingAction
    }

    var body: some View {
        HStack {
            if let title = leadingTitle, let action = leadingAction {
                Button(title, action: action)
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                    .tint(leadingDestructive ? .red : nil)
                    .disabled(leadingDisabled)
            }
            Spacer()
            Button(trailingTitle, action: trailingAction)
                .buttonStyle(.borderedProminent)
                .controlSize(.small)
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
    }
}
