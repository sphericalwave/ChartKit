import SwiftUI

/// The D/W/M segmented control for a `PeriodChartView`. Made for the
/// navigation bar's principal slot:
///
/// ```swift
/// @AppStorage("nutritionChartPeriod") private var period: ChartPeriod = .week
///
/// .toolbar {
///     ToolbarItem(placement: .principal) { PeriodPicker(selection: $period) }
/// }
/// ```
public struct PeriodPicker: View {
    @Binding private var selection: ChartPeriod

    public init(selection: Binding<ChartPeriod>) {
        self._selection = selection
    }

    public var body: some View {
        Picker("Period", selection: $selection) {
            ForEach(ChartPeriod.allCases) { period in
                Text(period.short)
                    .accessibilityLabel(period.rawValue.capitalized)
                    .tag(period)
            }
        }
        .pickerStyle(.segmented)
        .fixedSize()
    }
}

#if DEBUG
#Preview("PeriodPicker") {
    PeriodPicker(selection: .constant(.week))
        .padding()
}
#endif
