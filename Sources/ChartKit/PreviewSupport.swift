#if DEBUG
import Foundation

/// Shared sample data for `#Preview` blocks and the README screenshot
/// generator (`ScreenshotGenTests`), so both render the same content.
/// DEBUG-only: never compiled into release builds of the library.
enum ChartKitSamples {
    private static let reference = Date(timeIntervalSince1970: 1_700_000_000)

    private static func series(_ values: [Double], step: Calendar.Component) -> [ChartPoint] {
        let cal = Calendar(identifier: .gregorian)
        return values.enumerated().map { index, value in
            ChartPoint(start: cal.date(byAdding: step, value: index, to: reference) ?? reference,
                       value: value)
        }
    }

    static let weekly = series([182, 181, 180.4, 179.8, 180.1, 179.2], step: .weekOfYear)
    static let monthly = series([184, 182.5, 181, 180.2, 179.5, 178.9], step: .month)

    static var weightData: PeriodBarChart.DataSet {
        .init(week: weekly, month: monthly)
    }
}
#endif
