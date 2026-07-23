import Foundation

/// Gaussian PDF sampling for `NormalDistributionChart`, split out as pure
/// functions so it's unit-testable without SwiftUI.
enum NormalCurve {
    struct Point: Equatable {
        let x: Double
        let y: Double
    }

    /// `samples + 1` points spanning ±3σ around `mean`.
    static func points(mean: Double, stddev: Double, samples: Int = 60) -> [Point] {
        guard stddev > 0 else { return [] }
        let lo = mean - 3 * stddev
        let hi = mean + 3 * stddev
        let step = (hi - lo) / Double(samples)
        return (0...samples).map { i in
            let x = lo + Double(i) * step
            let d = (x - mean) / stddev
            let y = (1.0 / (stddev * (2.0 * .pi).squareRoot())) * exp(-0.5 * d * d)
            return Point(x: x, y: y)
        }
    }

    /// σ-multiple tick marks (-2σ…+2σ) that fall within ±3σ of `mean`.
    static func ticks(mean: Double, stddev: Double) -> [Double] {
        guard stddev > 0 else { return [] }
        let lo = mean - 3 * stddev
        let hi = mean + 3 * stddev
        return [-2, -1, 0, 1, 2]
            .map { mean + $0 * stddev }
            .filter { $0 >= lo && $0 <= hi }
    }
}
