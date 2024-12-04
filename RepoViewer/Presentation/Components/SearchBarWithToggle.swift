import SwiftUI

struct SearchBarWithToggle: View {
    @Binding var searchQuery: String
    @Binding var isHighlightedOnly: Bool
    
    var body: some View {
        HStack(spacing: 10) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                TextField("Search on GitHub…", text: $searchQuery)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.none)
                    .overlay(
                        HStack {
                            Spacer()
                            if !searchQuery.isEmpty {
                                Button(action: {
                                    searchQuery = ""
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.gray)
                                        .padding(.trailing, 8)
                                }
                            }
                        }
                    )
            }
            .padding(8)
            .background(Color(uiColor: .secondarySystemBackground))
            .cornerRadius(10)
            
            HighlightedToggler(isOn: $isHighlightedOnly)
        }
    }
}
