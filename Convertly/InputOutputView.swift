import SwiftUI

struct InputOutputView: View {
    @Binding var inputText: String
    @Binding var fromUnit: String
    @Binding var toUnit: String
    let availableUnits: [String]
    let backgroundColor: Color
    let isCurrency: Bool
    let isLoading: Bool
    let result: String
    
    var body: some View {
        VStack(spacing: 20) {
            HStack(spacing: 16) {
                TextField("Value", text: $inputText)
                    .keyboardType(.decimalPad)
                    .font(.system(.title2, design: .rounded))
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                
                Picker("From Unit", selection: $fromUnit) {
                    ForEach(availableUnits, id: \.self) { unit in
                        Text(unit).tag(unit)
                    }
                }
                .pickerStyle(.menu)
                .frame(width: 120)
                .frame(height: 56)
                .background(Color(.systemGray6))
                .cornerRadius(12)
            }
            
            HStack(spacing: 16) {
                Group {
                    if isCurrency && isLoading {
                        ProgressView()
                    } else {
                        Text(result)
                            .font(.system(.title, design: .rounded))
                            .fontWeight(.medium)
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(Color(.systemGray6))
                .cornerRadius(12)
                
                Picker("To Unit", selection: $toUnit) {
                    ForEach(availableUnits, id: \.self) { unit in
                        Text(unit).tag(unit)
                    }
                }
                .pickerStyle(.menu)
                .frame(width: 120)
                .frame(height: 56)
                .background(Color(.systemGray6))
                .cornerRadius(12)
            }
        }
        .padding()
        .background(backgroundColor)
        .cornerRadius(16)
        .conditionalShadow()
    }
} 