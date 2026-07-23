import SwiftUI
import Charts

/// A `Section`-ready normal curve fitted to (μ, σ) of some sample — no
/// per-sample marker, just an at-a-glance view of how values are
/// distributed. `RuleMark` at μ labeled "avg N · σ N". Renders nothing if
/// `stddev <= 0` or `count < 2` (no shape to show).
public struct NormalDistributionChart: View {
    private let mean: Double
    private let stddev: Double
    private let count: Int
    private let title: String

    public init(mean: Double, stddev: Double, count: Int, title: String = "Distribution") {
        self.mean = mean
        self.stddev = stddev
        self.count = count
        self.title = title
    }

    public var body: some View {
        if stddev > 0, count >= 2 {
            let curve = NormalCurve.points(mean: mean, stddev: stddev)
            let ticks = NormalCurve.ticks(mean: mean, stddev: stddev)
            Section(title) {
                Chart {
                    ForEach(curve, id: \.x) { pt in
                        AreaMark(
                            x: .value("Value", pt.x),
                            y: .value("Density", pt.y)
                        )
                        .foregroundStyle(.tint.opacity(0.25))
                    }
                    RuleMark(x: .value("avg", mean))
                        .foregroundStyle(.tint)
                        .lineStyle(StrokeStyle(lineWidth: 2))
                        .annotation(position: .top, alignment: .center) {
                            Text("avg \(Int(mean.rounded())) · σ \(Int(stddev.rounded()))")
                                .font(.caption2.monospacedDigit())
                                .foregroundStyle(.tint)
                        }
                }
                .frame(height: 140)
                .chartXAxis {
                    AxisMarks(values: ticks) { value in
                        AxisGridLine()
                        AxisTick()
                        AxisValueLabel {
                            if let v = value.as(Double.self) {
                                Text("\(Int(v.rounded()))")
                                    .font(.caption2.monospacedDigit())
                            }
                        }
                    }
                }
                .chartYAxis(.hidden)
            }
        }
    }
}
