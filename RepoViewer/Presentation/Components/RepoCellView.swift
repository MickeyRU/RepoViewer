import SwiftUI

struct RepoCellView: View {
    let viewModel: RepoCellViewModel
    @State private var showActionsMenu: Bool = false
    
    var body: some View {
        ZStack {
            if showActionsMenu {
                RepoCellActions(viewModel: viewModel, isShowingActions: $showActionsMenu)
            } else {
                RepoCellContent(viewModel: viewModel, toggleActions: { showActionsMenu = true })
            }
        }
        .animation(.bouncy, value: showActionsMenu)
        .padding(.horizontal, 5)
    }
}

/// Контент ячейки
struct RepoCellContent: View {
    let viewModel: RepoCellViewModel
    let toggleActions: () -> Void
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            HStack(alignment: .top, spacing: 16) {
                AvatarView(avatarUrl: viewModel.repo.owner.avatarUrl)
                
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(viewModel.repo.name)
                                .font(.headline)
                                .lineLimit(2)
                            
                            if let description = viewModel.repo.description {
                                Text(description)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                    .lineLimit(5)
                            }
                        }
                        Spacer()
                        
                        VStack {
                            Button(action: toggleActions) {
                                Image(systemName: "ellipsis.circle")
                                    .font(.title2)
                                    .foregroundColor(.gray)
                            }
                            Spacer()
                        }
                    }
                    
                    RepoStatsView(repo: viewModel.repo)
                }
            }
            .padding()
            .background(Color(uiColor: .secondarySystemBackground))
            .cornerRadius(10)
            
            if viewModel.repo.isHighlighted {
                BottomLeftCornerShape()
                    .fill(Color.yellow)
                    .shadow(color: .yellow.opacity(0.5), radius: 3, x: 0, y: 2)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
    }
}

/// Рисуем через Shape отображение избранного
struct BottomLeftCornerShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY - 30))
        path.addLine(to: CGPoint(x: rect.minX + 30, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

/// Меню действий
struct RepoCellActions: View {
    let viewModel: RepoCellViewModel
    @Binding var isShowingActions: Bool
    
    var body: some View {
        HStack {
            Spacer()
            ActionButton(text: "Highlight", color: .yellow, action: {
                viewModel.highlight()
                hideActions()
            })
            ActionButton(text: "Delete", color: .red, action: {
                viewModel.delete()
                hideActions()
            })
            ActionButton(text: "Cancel", color: .gray, action: hideActions)
        }
        .padding(.trailing, 10)
        .transition(.opacity.combined(with: .move(edge: .trailing)))
    }
    
    private func hideActions() {
        withAnimation(.bouncy) {
            isShowingActions = false
        }
    }
}

/// Аватар
struct AvatarView: View {
    let avatarUrl: String
    
    var body: some View {
        Group {
            if let url = URL(string: avatarUrl) {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    placeholderView
                }
            } else {
                placeholderView
            }
        }
        .frame(width: 50, height: 50)
        .clipShape(Circle())
    }
    
    private var placeholderView: some View {
        Circle()
            .fill(Color.gray.opacity(0.3))
    }
}

/// Статистика
struct RepoStatsView: View {
    let repo: Repo
    
    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            StatView(icon: "star.fill", value: "\(repo.stars)", iconColor: .yellow)
            StatView(icon: "tuningfork", value: "\(repo.forks)", iconColor: .blue)
            StatView(icon: "calendar", value: DateFormatter.mediumDateFormatter.string(from: repo.updatedAt), iconColor: .gray)
        }
    }
}

/// Вспомогательная кнопка действия
struct ActionButton: View {
    let text: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(text)
                .font(.subheadline)
                .foregroundColor(.black)
                .padding()
                .background(color)
                .cornerRadius(8)
                .shadow(radius: 3)
        }
        .padding(.trailing, 5)
    }
}

struct StatView: View {
    let icon: String
    let value: String
    let iconColor: Color
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .foregroundColor(iconColor)
                .font(.caption)
            Text(value)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

