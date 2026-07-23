import Foundation

/// Bar-axis label formatting for `PeriodBarChart`'s non-day scales, split out
/// as pure functions so it's unit-testable without SwiftUI.
enum PeriodBarLabeler {
    /// `.day` isn't handled here — its bars key off the real `Date` and get
    /// their axis labels from `chartXAxis`, not this categorical label.
    ///
    /// `.week` uses an ordinal "W1, W2, …" (counting from the oldest point)
    /// instead of a date, since a date string is too dense to stay readable
    /// at typical week-chart widths.
    static func label(for point: ChartPoint, index: Int, scale: ChartTimeframe) -> String {
        switch scale {
        case .day:
            return ""
        case .week:
            return "W\(index + 1)"
        case .month:
            let f = DateFormatter()
            f.dateFormat = "MMM ''yy"
            return f.string(from: point.start)
        case .quarter:
            let cal = Calendar.current
            let q = (cal.component(.month, from: point.start) - 1) / 3 + 1
            return "Q\(q) \(cal.component(.year, from: point.start))"
        case .year:
            let f = DateFormatter()
            f.dateFormat = "yyyy"
            return f.string(from: point.start)
        }
    }
}
