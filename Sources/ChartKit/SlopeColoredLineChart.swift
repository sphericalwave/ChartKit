import SwiftUI
import Charts

/// A line chart over dated points whose segments are colored by trend — one
/// color where the line rises, another where it falls — so a run of good or bad
/// nights (or weeks, or sessions) reads at a glance without a legend.
///
/// The y-axis is caller-supplied on purpose: `yDomain` and `yAxisLabel` change
/// from instance to instance. A clock chart wants a domain a few minutes wider
/// than the recorded range and labels formatted as times; a percentage chart
/// wants a clamped 0…100-ish domain and `"%"` labels. Pass a domain padded
/// however the metric wants — values that cluster in a narrow band stay
/// distinct instead of flattening against a `0…max` axis.
///
/// Which direction is "good" is the caller's call too: pass `risingColor` and
/// `fallingColor` to suit the metric (more sleep is good; more weight may not
/// be).
///
/// Renders plain content — wrap it in your own `Section` or card.
public struct SlopeColoredLineChart: View {

    private let points: [ChartPoint]
    private let yDomain: ClosedRange<Double>
    private let yAxisLabel: (Double) -> String
    private let risingColor: Color
    private let fallingColor: Color
    private let height: CGFloat

    public init(
        points: [ChartPoint],
        yDomain: ClosedRange<Double>,
        yAxisLabel: @escaping (Double) -> String,
        risingColor: Color = .blue,
        fallingColor: Color = .red,
        height: CGFloat = 140
    ) {
        self.points = points
        self.yDomain = yDomain
        self.yAxisLabel = yAxisLabel
        self.risingColor = risingColor
        self.fallingColor = fallingColor
        self.height = height
    }

    /// One leg of the line: the pair of points it spans, and which way it went.
    /// A flat segment counts as rising, so a plateau doesn't read as a decline.
    struct Segment: Identifiable, Equatable {
        let id: Int
        let start: ChartPoint
        let end: ChartPoint

        var isRising: Bool { end.value >= start.value }
    }

    /// Consecutive pairs of `points`, in order. Pure so it's unit-testable.
    /// Fewer than two points means nothing to connect — no segments.
    static func segments(from points: [ChartPoint]) -> [Segment] {
        guard points.count > 1 else { return [] }
        return zip(points, points.dropFirst()).enumerated().map { index, pair in
            Segment(id: index, start: pair.0, end: pair.1)
        }
    }

    private func color(for segment: Segment) -> Color {
        segment.isRising ? risingColor : fallingColor
    }

    public var body: some View {
        Chart {
            // Each segment is its own series so it can carry its own color;
            // a single series would take one style for the whole line.
            ForEach(Self.segments(from: points)) { segment in
                LineMark(
                    x: .value("Date", segment.start.start, unit: .day),
                    y: .value("Value", segment.start.value),
                    series: .value("Segment", segment.id)
                )
                .foregroundStyle(color(for: segment))
                LineMark(
                    x: .value("Date", segment.end.start, unit: .day),
                    y: .value("Value", segment.end.value),
                    series: .value("Segment", segment.id)
                )
                .foregroundStyle(color(for: segment))
            }
            // Indexed rather than keyed by date: repeated dates are the
            // caller's business, and a duplicate id would drop a point.
            ForEach(Array(points.enumerated()), id: \.offset) { _, point in
                PointMark(
                    x: .value("Date", point.start, unit: .day),
                    y: .value("Value", point.value)
                )
                .foregroundStyle(.primary)
            }
        }
        .chartYScale(domain: yDomain)
        .chartYAxis {
            AxisMarks { value in
                AxisGridLine()
                AxisValueLabel {
                    if let value = value.as(Double.self) {
                        Text(yAxisLabel(value))
                    }
                }
            }
        }
        .frame(height: height)
    }
}

#if DEBUG
#Preview("SlopeColoredLineChart") {
    SlopeColoredLineChart(
        points: ChartKitSamples.weekly,
        yDomain: 178...183,
        yAxisLabel: { String(format: "%.1f", $0) }
    )
    .padding()
}
#endif
