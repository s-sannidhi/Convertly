import SwiftUI
import Charts

struct GraphCard: View {
    let points: [(x: Double, y: Double)]
    let backgroundColor: Color
    let accentGradient: LinearGradient
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Conversion Graph")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Chart(points, id: \.x) { point in
                LineMark(
                    x: .value("Input", point.x),
                    y: .value("Output", point.y)
                )
                .foregroundStyle(accentGradient)
            }
        }
        .frame(height: 220)
        .padding()
        .background(backgroundColor)
        .cornerRadius(16)
        .conditionalShadow()
    }
}

struct ConversionEquationCard: View {
    let equation: String
    let backgroundColor: Color
    
    var body: some View {
        Text(equation)
            .font(.system(.body, design: .monospaced))
            .padding()
            .frame(maxWidth: .infinity)
            .background(backgroundColor)
            .cornerRadius(12)
            .conditionalShadow()
    }
}

struct ConversionTableCard: View {
    let inputValue: Double
    let fromUnit: String
    let availableUnits: [String]
    let backgroundColor: Color
    let secondaryColor: Color
    let convertValue: (Double, String, String) -> Double?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("All Conversions")
                .font(.headline)
                .foregroundColor(.secondary)
            
            ScrollView {
                VStack(spacing: 8) {
                    ForEach(availableUnits.filter { $0 != fromUnit }, id: \.self) { unit in
                        HStack {
                            Text(unit)
                                .font(.system(.body, design: .rounded))
                                .frame(width: 120, alignment: .leading)
                            Spacer()
                            if let result = convertValue(inputValue, fromUnit, unit) {
                                Text(String(format: "%.2f", result))
                                    .font(.system(.body, design: .rounded))
                                    .frame(width: 100, alignment: .trailing)
                            } else {
                                Text("---")
                                    .frame(width: 100, alignment: .trailing)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(secondaryColor)
                        .cornerRadius(8)
                    }
                }
            }
            .frame(maxHeight: 300)
        }
        .padding()
        .background(backgroundColor)
        .cornerRadius(16)
        .conditionalShadow()
    }
} 