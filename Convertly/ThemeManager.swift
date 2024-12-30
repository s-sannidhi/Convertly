import SwiftUI

class ThemeManager: ObservableObject {
    @Published var isDarkMode: Bool = false
    
    var backgroundGradientColors: [Color] {
        isDarkMode ? [Color(.systemGray6), Color(.black)] : [Color(.systemBackground), Color(.systemGray6)]
    }
    
    var cardBackgroundColor: Color {
        isDarkMode ? Color(.systemGray6) : Color(.systemBackground)
    }
    
    var secondaryBackgroundColor: Color {
        isDarkMode ? Color(.systemGray5) : Color(.systemGray6)
    }
    
    func updateTheme(isDark: Bool) {
        isDarkMode = isDark
    }
} 