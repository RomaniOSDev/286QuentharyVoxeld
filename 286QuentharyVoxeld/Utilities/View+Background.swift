import SwiftUI
import UIKit

enum AccentTheme: String, CaseIterable, Identifiable {
    case ember
    case ocean
    case forest
    case violet

    var id: String { rawValue }

    var title: String {
        switch self {
        case .ember: return "Ember"
        case .ocean: return "Ocean"
        case .forest: return "Forest"
        case .violet: return "Violet"
        }
    }

    var primary: Color {
        switch self {
        case .ember: return Color("AppPrimary")
        case .ocean: return Color(red: 0.18, green: 0.58, blue: 0.86)
        case .forest: return Color(red: 0.22, green: 0.72, blue: 0.45)
        case .violet: return Color(red: 0.62, green: 0.42, blue: 0.92)
        }
    }

    var accent: Color {
        switch self {
        case .ember: return Color("AppAccent")
        case .ocean: return Color(red: 0.35, green: 0.78, blue: 0.92)
        case .forest: return Color(red: 0.55, green: 0.88, blue: 0.40)
        case .violet: return Color(red: 0.90, green: 0.55, blue: 0.85)
        }
    }

    static var current: AccentTheme = .ember
}

extension Color {
    static var brandPrimary: Color { AccentTheme.current.primary }
    static var brandAccent: Color { AccentTheme.current.accent }
}

struct TipBanner: View {
    let text: String
    let onDismiss: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "lightbulb.fill")
                .foregroundStyle(Color.brandAccent)
            Text(text)
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundStyle(Color("AppTextPrimary"))
                .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: 0)
            Button {
                HapticsService.light()
                onDismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(Color("AppTextSecondary"))
                    .padding(6)
            }
            .buttonStyle(.plain)
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color("AppSurface").opacity(0.92))
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(Color.brandPrimary.opacity(0.35), lineWidth: 1)
                )
        )
        .padding(.horizontal, 16)
    }
}

struct ActivityHeatmapView: View {
    let days: [HeatmapDay]

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 4), count: 7)

    var body: some View {
        LazyVGrid(columns: columns, spacing: 4) {
            ForEach(days) { day in
                RoundedRectangle(cornerRadius: 3, style: .continuous)
                    .fill(color(for: day.count))
                    .aspectRatio(1, contentMode: .fit)
                    .accessibilityLabel("\(day.count) sessions")
            }
        }
        .frame(maxWidth: .infinity)
    }

    private func color(for count: Int) -> Color {
        switch count {
        case 0: return Color("AppTextSecondary").opacity(0.15)
        case 1: return Color.brandPrimary.opacity(0.35)
        case 2: return Color.brandPrimary.opacity(0.6)
        default: return Color.brandPrimary
        }
    }
}

struct HeatmapDay: Identifiable, Equatable {
    let id: String
    let date: Date
    let count: Int
}

extension View {
    func appScreenBackground() -> some View {
        self
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background {
                Color("AppBackground")
                    .overlay {
                        Image("img_bg")
                            .resizable()
                            .scaledToFill()
                            .opacity(0.3)
                    }
                    .clipped()
                    .ignoresSafeArea()
            }
    }

}

enum Keyboard {
    static func hide() {
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil,
            from: nil,
            for: nil
        )
    }
}
