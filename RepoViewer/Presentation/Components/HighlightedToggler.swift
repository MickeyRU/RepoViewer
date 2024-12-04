import SwiftUI

struct HighlightedToggler: View {
    @Binding var isOn: Bool

    var body: some View {
        Text(isOn ? "Highlighted" : "All")
            .font(.subheadline)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(isOn ? Color.yellow : Color.gray.opacity(0.2))
            .foregroundColor(isOn ? .black : .white)
            .cornerRadius(15)
            .shadow(radius: isOn ? 3 : 0)
            .onTapGesture {
                withAnimation(.spring()) {
                    isOn.toggle()
                }
            }
    }
}
