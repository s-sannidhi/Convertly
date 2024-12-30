import SwiftUI

struct UnitTypePicker: View {
    @Binding var selectedType: String
    let unitTypes: [String]
    let accentGradient: LinearGradient
    @State private var isChanging = false
    @State private var offset = CGSize.zero
    
    var body: some View {
        Menu {
            Picker("Unit Type", selection: $selectedType) {
                ForEach(unitTypes, id: \.self) { type in
                    Text(type).tag(type)
                }
            }
        } label: {
            HStack {
                Text(selectedType)
                    .font(.title2)
                    .fontWeight(.semibold)
                Image(systemName: "chevron.down.circle.fill")
                    .font(.title2)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(accentGradient)
            .cornerRadius(16)
            .scaleEffect(isChanging ? 0.95 : 1.0)
            .offset(x: offset.width, y: 0)
            .animation(.spring(response: 0.3), value: isChanging)
            .gesture(
                DragGesture()
                    .onChanged { gesture in
                        offset = gesture.translation
                    }
                    .onEnded { gesture in
                        let width = gesture.translation.width
                        if abs(width) > 50 {  // Minimum swipe distance
                            isChanging = true
                            
                            // Find current index and calculate next index
                            if let currentIndex = unitTypes.firstIndex(of: selectedType) {
                                var nextIndex: Int
                                
                                if width > 0 {  // Swipe right
                                    nextIndex = (currentIndex - 1 + unitTypes.count) % unitTypes.count
                                } else {  // Swipe left
                                    nextIndex = (currentIndex + 1) % unitTypes.count
                                }
                                
                                // Animate the transition
                                withAnimation(.spring(response: 0.3)) {
                                    selectedType = unitTypes[nextIndex]
                                    offset = .zero
                                }
                                
                                // Reset the scale after a short delay
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    isChanging = false
                                }
                            }
                        } else {
                            // If swipe wasn't far enough, reset position
                            withAnimation(.spring(response: 0.3)) {
                                offset = .zero
                            }
                        }
                    }
            )
        }
        .onChange(of: selectedType) { _ in
            isChanging = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isChanging = false
            }
        }
    }
} 