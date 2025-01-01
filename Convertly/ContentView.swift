//
//  ContentView.swift
//  UnitConverter
//
//  Created by Srujan Sannidhi on 12/29/24.
//

import SwiftUI
import Charts

struct ConditionalShadowModifier: ViewModifier {
    @Environment(\.colorScheme) var colorScheme
    
    func body(content: Content) -> some View {
        if colorScheme == .dark {
            content
        } else {
            content
                .shadow(color: .black.opacity(0.1), radius: 2, y: 1)
        }
    }
}

extension View {
    func conditionalShadow() -> some View {
        modifier(ConditionalShadowModifier())
    }
}

struct ContentView: View {
    @Environment(\.colorScheme) var colorScheme
    
    // State variables for persistence
    @AppStorage("selectedUnitType") private var selectedUnitType = "Length"
    @AppStorage("fromUnit") private var fromUnit = "meters"
    @AppStorage("toUnit") private var toUnit = "feet"
    @AppStorage("inputValue") private var inputText = ""
    
    // Available unit types
    private let unitTypes = [
        "Length",
        "Area",
        "Volume",
        "Mass",
        "Temperature",
        "Currency",
        "Speed",
        "Time",
        "Energy",
        "Pressure"
    ]
    
    // Add these conversion factors after the unitTypes array
    private let lengthConversionFactors: [String: Double] = [
        "meters": 1.0,
        "feet": 3.28084,
        "inches": 39.3701,
        "kilometers": 0.001,
        "miles": 0.000621371,
        "yards": 1.09361
    ]
    
    // Add these conversion factors after the lengthConversionFactors
    private let areaConversionFactors: [String: Double] = [
        "square meters": 1.0,
        "square feet": 10.7639,
        "square inches": 1550.0,
        "square kilometers": 0.000001,
        "square miles": 3.861e-7,
        "acres": 0.000247105,
        "hectares": 0.0001
    ]
    
    private let volumeConversionFactors: [String: Double] = [
        "cubic meters": 1.0,
        "cubic feet": 35.3147,
        "liters": 1000.0,
        "gallons": 264.172,
        "milliliters": 1000000.0
    ]
    
    private let massConversionFactors: [String: Double] = [
        "kilograms": 1.0,
        "pounds": 2.20462,
        "grams": 1000.0,
        "ounces": 35.274,
        "tons": 0.001
    ]
    
    // Add these conversion factors after the existing ones
    private let speedConversionFactors: [String: Double] = [
        "meters per second": 1.0,
        "kilometers per hour": 3.6,
        "miles per hour": 2.23694,
        "knots": 1.94384,
        "feet per second": 3.28084
    ]
    
    private let timeConversionFactors: [String: Double] = [
        "seconds": 1.0,
        "minutes": 0.0166667,
        "hours": 0.000277778,
        "days": 0.0000115741,
        "weeks": 0.00000165344,
        "months": 3.8052e-7,
        "years": 3.171e-8
    ]
    
    private let energyConversionFactors: [String: Double] = [
        "joules": 1.0,
        "calories": 0.239006,
        "kilocalories": 0.000239006,
        "watt hours": 0.000277778,
        "kilowatt hours": 2.778e-7,
        "electron volts": 6.242e+18,
        "BTU": 0.000947817
    ]
    
    private let pressureConversionFactors: [String: Double] = [
        "pascals": 1.0,
        "atmospheres": 9.869e-6,
        "bars": 0.00001,
        "psi": 0.000145038,
        "torr": 0.00750062,
        "millimeters of mercury": 0.00750062
    ]
    
    // Computed properties for unit management
    private var availableUnits: [String] {
        switch selectedUnitType {
        case "Length":
            return ["meters", "feet", "inches", "kilometers", "miles", "yards"]
        case "Area":
            return ["square meters", "square feet", "square inches", "square kilometers", "square miles", "acres", "hectares"]
        case "Volume":
            return ["cubic meters", "cubic feet", "liters", "gallons", "milliliters"]
        case "Mass":
            return ["kilograms", "pounds", "grams", "ounces", "tons"]
        case "Temperature":
            return ["Celsius", "Fahrenheit", "Kelvin"]
        case "Speed":
            return ["meters per second", "kilometers per hour", "miles per hour", "knots", "feet per second"]
        case "Time":
            return ["seconds", "minutes", "hours", "days", "weeks", "months", "years"]
        case "Energy":
            return ["joules", "calories", "kilocalories", "watt hours", "kilowatt hours", "electron volts", "BTU"]
        case "Pressure":
            return ["pascals", "atmospheres", "bars", "psi", "torr", "millimeters of mercury"]
        case "Currency":
            return ["USD", "EUR", "GBP", "JPY", "CAD", "AUD"]
        default:
            return []
        }
    }
    
    // Computed property for the conversion result
    private var result: Double? {
        guard let inputValue = Double(inputText) else { return nil }
        return convertValue(inputValue)
    }
    
    // Graph data points
    private var graphPoints: [(x: Double, y: Double)] {
        guard let baseValue = Double(inputText),
              baseValue > 0 else { return [] }
        
        let points = stride(from: 0.0, through: baseValue * 2, by: baseValue / 10).map { x in
            (x: x, y: convertValue(x) ?? 0)
        }
        return points
    }
    
    @StateObject private var currencyAPI = CurrencyAPI()
    @State private var isLoadingCurrency = false
    @State private var showingErrorAlert = false
    
    // Replace the existing color definitions with these
    private var accentGradient: LinearGradient {
        LinearGradient(
            colors: [.blue, .cyan],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    @StateObject private var themeManager = ThemeManager()
    
    @State private var isLoading = true
    
    @GestureState private var dragOffset: CGFloat = 0
    
    var body: some View {
        Group {
            if isLoading {
                LoadingView()
                    .onAppear {
                        // Simulate loading time and/or perform initialization
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            withAnimation {
                                isLoading = false
                            }
                        }
                    }
            } else {
                mainView
            }
        }
    }
    
    private var mainView: some View {
        NavigationStack {
            ZStack {
                backgroundView
                ScrollView {
                    VStack(spacing: 24) {
                        unitTypePickerView
                        
                        VStack(spacing: 24) {
                            graphSection
                            equationSection
                            inputOutputSection
                            currencyInfoSection
                            conversionTableSection
                        }
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)
                        ))
                        .animation(.smooth(duration: 0.3), value: selectedUnitType)
                        .id(selectedUnitType)
                    }
                    .padding()
                }
            }
            .gesture(
                DragGesture()
                    .updating($dragOffset) { value, state, _ in
                        state = value.translation.width
                    }
                    .onEnded { value in
                        let threshold: CGFloat = 50
                        if value.translation.width > threshold {
                            // Swipe right - go to previous
                            cycleUnitType(forward: false)
                        } else if value.translation.width < -threshold {
                            // Swipe left - go to next
                            cycleUnitType(forward: true)
                        }
                    }
            )
            .navigationTitle("Convertly")
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
            .task {
                if currencyAPI.rates.isEmpty {
                    isLoadingCurrency = true
                    await currencyAPI.fetchExchangeRates()
                    isLoadingCurrency = false
                }
            }
            .alert("Currency Error", isPresented: $showingErrorAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(currencyAPI.error ?? "Unknown error occurred")
            }
            .preferredColorScheme(.none)
            .onAppear {
                themeManager.updateTheme(isDark: colorScheme == .dark)
            }
            .onChange(of: colorScheme) { newValue in
                themeManager.updateTheme(isDark: newValue == .dark)
            }
        }
    }
    
    private var backgroundView: some View {
        LinearGradient(
            colors: themeManager.backgroundGradientColors,
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }
    
    private var unitTypePickerView: some View {
        UnitTypePicker(
            selectedType: $selectedUnitType.animation(.smooth(duration: 0.3)),
            unitTypes: unitTypes,
            accentGradient: accentGradient
        )
    }
    
    private var graphSection: some View {
        Group {
            if !graphPoints.isEmpty {
                GraphCard(
                    points: graphPoints,
                    backgroundColor: themeManager.cardBackgroundColor,
                    accentGradient: accentGradient
                )
            }
        }
    }
    
    private var equationSection: some View {
        Group {
            if let equation = getConversionEquation() {
                ConversionEquationCard(
                    equation: equation,
                    backgroundColor: themeManager.cardBackgroundColor
                )
            }
        }
    }
    
    private var inputOutputSection: some View {
        InputOutputView(
            inputText: $inputText,
            fromUnit: $fromUnit,
            toUnit: $toUnit,
            availableUnits: availableUnits,
            backgroundColor: themeManager.cardBackgroundColor,
            isCurrency: selectedUnitType == "Currency",
            isLoading: isLoadingCurrency,
            result: formatResult()
        )
    }
    
    private var currencyInfoSection: some View {
        Group {
            if selectedUnitType == "Currency" {
                VStack(spacing: 8) {
                    if let error = currencyAPI.error {
                        Text(error)
                            .foregroundColor(.red)
                            .font(.callout)
                    }
                    
                    Text(currencyAPI.getLastUpdateTimeString())
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(themeManager.cardBackgroundColor)
                .cornerRadius(12)
            }
        }
    }
    
    private var conversionTableSection: some View {
        Group {
            if !inputText.isEmpty, let inputValue = Double(inputText) {
                ConversionTableCard(
                    inputValue: inputValue,
                    fromUnit: fromUnit,
                    availableUnits: availableUnits,
                    backgroundColor: themeManager.cardBackgroundColor,
                    secondaryColor: themeManager.secondaryBackgroundColor,
                    convertValue: convertValue
                )
            }
        }
    }
    
    // Helper functions
    private func convertValue(_ value: Double) -> Double? {
        switch selectedUnitType {
        case "Length":
            return convertLength(value, from: fromUnit, to: toUnit)
        case "Area":
            return convertArea(value, from: fromUnit, to: toUnit)
        case "Volume":
            return convertVolume(value, from: fromUnit, to: toUnit)
        case "Mass":
            return convertMass(value, from: fromUnit, to: toUnit)
        case "Temperature":
            return convertTemperature(value, from: fromUnit, to: toUnit)
        case "Speed":
            return convertSpeed(value, from: fromUnit, to: toUnit)
        case "Time":
            return convertTime(value, from: fromUnit, to: toUnit)
        case "Energy":
            return convertEnergy(value, from: fromUnit, to: toUnit)
        case "Pressure":
            return convertPressure(value, from: fromUnit, to: toUnit)
        case "Currency":
            return convertCurrency(value, from: fromUnit, to: toUnit)
        default:
            return nil
        }
    }
    
    private func convertValue(_ value: Double, from: String, to: String) -> Double? {
        switch selectedUnitType {
        case "Length":
            return convertLength(value, from: from, to: to)
        case "Area":
            return convertArea(value, from: from, to: to)
        case "Volume":
            return convertVolume(value, from: from, to: to)
        case "Mass":
            return convertMass(value, from: from, to: to)
        case "Temperature":
            return convertTemperature(value, from: from, to: to)
        case "Speed":
            return convertSpeed(value, from: from, to: to)
        case "Time":
            return convertTime(value, from: from, to: to)
        case "Energy":
            return convertEnergy(value, from: from, to: to)
        case "Pressure":
            return convertPressure(value, from: from, to: to)
        case "Currency":
            return convertCurrency(value, from: from, to: to)
        default:
            return nil
        }
    }
    
    private func convertLength(_ value: Double, from: String, to: String) -> Double? {
        guard let fromFactor = lengthConversionFactors[from],
              let toFactor = lengthConversionFactors[to] else {
            return nil
        }
        
        // First convert to meters (base unit), then to target unit
        let inMeters = value / fromFactor
        return inMeters * toFactor
    }
    
    private func convertTemperature(_ value: Double, from: String, to: String) -> Double? {
        // First convert to Celsius as base unit, then to target
        let inCelsius: Double
        
        // Convert input to Celsius
        switch from {
        case "Celsius":
            inCelsius = value
        case "Fahrenheit":
            inCelsius = (value - 32) * 5/9
        case "Kelvin":
            inCelsius = value - 273.15
        default:
            return nil
        }
        
        // Convert Celsius to target unit
        switch to {
        case "Celsius":
            return inCelsius
        case "Fahrenheit":
            return (inCelsius * 9/5) + 32
        case "Kelvin":
            return inCelsius + 273.15
        default:
            return nil
        }
    }
    
    private func convertArea(_ value: Double, from: String, to: String) -> Double? {
        guard let fromFactor = areaConversionFactors[from],
              let toFactor = areaConversionFactors[to] else {
            return nil
        }
        let inSquareMeters = value / fromFactor
        return inSquareMeters * toFactor
    }
    
    private func convertVolume(_ value: Double, from: String, to: String) -> Double? {
        guard let fromFactor = volumeConversionFactors[from],
              let toFactor = volumeConversionFactors[to] else {
            return nil
        }
        let inCubicMeters = value / fromFactor
        return inCubicMeters * toFactor
    }
    
    private func convertMass(_ value: Double, from: String, to: String) -> Double? {
        guard let fromFactor = massConversionFactors[from],
              let toFactor = massConversionFactors[to] else {
            return nil
        }
        let inKilograms = value / fromFactor
        return inKilograms * toFactor
    }
    
    private func convertSpeed(_ value: Double, from: String, to: String) -> Double? {
        guard let fromFactor = speedConversionFactors[from],
              let toFactor = speedConversionFactors[to] else {
            return nil
        }
        let inMetersPerSecond = value / fromFactor
        return inMetersPerSecond * toFactor
    }
    
    private func convertTime(_ value: Double, from: String, to: String) -> Double? {
        guard let fromFactor = timeConversionFactors[from],
              let toFactor = timeConversionFactors[to] else {
            return nil
        }
        let inSeconds = value / fromFactor
        return inSeconds * toFactor
    }
    
    private func convertEnergy(_ value: Double, from: String, to: String) -> Double? {
        guard let fromFactor = energyConversionFactors[from],
              let toFactor = energyConversionFactors[to] else {
            return nil
        }
        let inJoules = value / fromFactor
        return inJoules * toFactor
    }
    
    private func convertPressure(_ value: Double, from: String, to: String) -> Double? {
        guard let fromFactor = pressureConversionFactors[from],
              let toFactor = pressureConversionFactors[to] else {
            return nil
        }
        let inPascals = value / fromFactor
        return inPascals * toFactor
    }
    
    private func convertCurrency(_ value: Double, from: String, to: String) -> Double? {
        guard let fromRate = currencyAPI.rates[from],
              let toRate = currencyAPI.rates[to],
              fromRate > 0 else {
            return nil
        }
        
        // Convert to USD first (base currency), then to target currency
        let inUSD = value / fromRate
        return inUSD * toRate
    }
    
    private func getConversionEquation() -> String? {
        switch selectedUnitType {
        case "Length":
            guard let fromFactor = lengthConversionFactors[fromUnit],
                  let toFactor = lengthConversionFactors[toUnit] else {
                return nil
            }
            let factor = toFactor / fromFactor
            return "y = \(String(format: "%.4f", factor))x (\(fromUnit) to \(toUnit))"
        
        case "Area":
            guard let fromFactor = areaConversionFactors[fromUnit],
                  let toFactor = areaConversionFactors[toUnit] else {
                return nil
            }
            let factor = toFactor / fromFactor
            return "y = \(String(format: "%.4f", factor))x (\(fromUnit) to \(toUnit))"
        
        case "Volume":
            guard let fromFactor = volumeConversionFactors[fromUnit],
                  let toFactor = volumeConversionFactors[toUnit] else {
                return nil
            }
            let factor = toFactor / fromFactor
            return "y = \(String(format: "%.4f", factor))x (\(fromUnit) to \(toUnit))"
        
        case "Mass":
            guard let fromFactor = massConversionFactors[fromUnit],
                  let toFactor = massConversionFactors[toUnit] else {
                return nil
            }
            let factor = toFactor / fromFactor
            return "y = \(String(format: "%.4f", factor))x (\(fromUnit) to \(toUnit))"
        
        case "Temperature":
            switch (fromUnit, toUnit) {
            case ("Celsius", "Fahrenheit"):
                return "°F = (°C × 9/5) + 32"
            case ("Fahrenheit", "Celsius"):
                return "°C = (°F - 32) × 5/9"
            case ("Celsius", "Kelvin"):
                return "K = °C + 273.15"
            case ("Kelvin", "Celsius"):
                return "°C = K - 273.15"
            case ("Fahrenheit", "Kelvin"):
                return "K = (°F - 32) × 5/9 + 273.15"
            case ("Kelvin", "Fahrenheit"):
                return "°F = (K - 273.15) × 9/5 + 32"
            case (let from, let to) where from == to:
                return "y = x (no conversion needed)"
            default:
                return nil
            }
        
        case "Speed":
            guard let fromFactor = speedConversionFactors[fromUnit],
                  let toFactor = speedConversionFactors[toUnit] else {
                return nil
            }
            let factor = toFactor / fromFactor
            return "y = \(String(format: "%.4f", factor))x (\(fromUnit) to \(toUnit))"
        
        case "Time":
            guard let fromFactor = timeConversionFactors[fromUnit],
                  let toFactor = timeConversionFactors[toUnit] else {
                return nil
            }
            let factor = toFactor / fromFactor
            return "y = \(String(format: "%.4f", factor))x (\(fromUnit) to \(toUnit))"
        
        case "Energy":
            guard let fromFactor = energyConversionFactors[fromUnit],
                  let toFactor = energyConversionFactors[toUnit] else {
                return nil
            }
            let factor = toFactor / fromFactor
            return "y = \(String(format: "%.4f", factor))x (\(fromUnit) to \(toUnit))"
        
        case "Pressure":
            guard let fromFactor = pressureConversionFactors[fromUnit],
                  let toFactor = pressureConversionFactors[toUnit] else {
                return nil
            }
            let factor = toFactor / fromFactor
            return "y = \(String(format: "%.4f", factor))x (\(fromUnit) to \(toUnit))"
        
        case "Currency":
            guard let fromRate = currencyAPI.rates[fromUnit],
                  let toRate = currencyAPI.rates[toUnit],
                  fromRate > 0 else {
                return "Loading exchange rates..."
            }
            let rate = toRate / fromRate
            return "y = \(String(format: "%.4f", rate))x (\(fromUnit) to \(toUnit))"
        
        default:
            return nil
        }
    }
    
    private func formatResult() -> String {
        if let result = result {
            return String(format: "%.2f", result)
        }
        return "---"
    }
    
    private func cycleUnitType(forward: Bool) {
        guard let currentIndex = unitTypes.firstIndex(of: selectedUnitType) else { return }
        
        let newIndex: Int
        if forward {
            newIndex = (currentIndex + 1) % unitTypes.count
        } else {
            newIndex = (currentIndex - 1 + unitTypes.count) % unitTypes.count
        }
        
        withAnimation(.smooth(duration: 0.3)) {
            selectedUnitType = unitTypes[newIndex]
        }
    }
}

#Preview {
    ContentView()
}
