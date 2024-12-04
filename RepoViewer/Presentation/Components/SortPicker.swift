import SwiftUI

struct SortPicker: View {
    @Binding var selectedSortOption: SortOption
    
    var body: some View {
        Picker("Sort by", selection: $selectedSortOption) {
            ForEach(SortOption.allCases, id: \.self) { sortOption in
                Text(sortOption.displayName).tag(sortOption)
            }
        }
        .pickerStyle(SegmentedPickerStyle())
    }
}

