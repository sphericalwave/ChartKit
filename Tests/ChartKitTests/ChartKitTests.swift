import XCTest
@testable import ChartKit

final class ChartKitTests: XCTestCase {

    // MARK: - ChartTimeframe

    func testShortLabels() {
        XCTAssertEqual(ChartTimeframe.day.short, "D")
        XCTAssertEqual(ChartTimeframe.week.short, "W")
        XCTAssertEqual(ChartTimeframe.month.short, "M")
        XCTAssertEqual(ChartTimeframe.quarter.short, "Q")
        XCTAssertEqual(ChartTimeframe.year.short, "Y")
    }

    // MARK: - PeriodBarChart.DataSet

    func testDataSetPointsForScale() {
        let day = [ChartPoint(start: .now, value: 1)]
        let week = [ChartPoint(start: .now, value: 2), ChartPoint(start: .now, value: 3)]
        let data = PeriodBarChart.DataSet(day: day, week: week)
        XCTAssertEqual(data.points(for: .day), day)
        XCTAssertEqual(data.points(for: .week), week)
        XCTAssertEqual(data.points(for: .month), [])
    }

    // MARK: - PeriodBarLabeler

    func testWeekLabelsAreOrdinalFromOldest() {
        let cal = Calendar(identifier: .gregorian)
        let points = (0..<3).map { i in
            ChartPoint(start: cal.date(byAdding: .weekOfYear, value: i, to: .now)!, value: Double(i))
        }
        let labels = points.enumerated().map { PeriodBarLabeler.label(for: $0.element, index: $0.offset, scale: .week) }
        XCTAssertEqual(labels, ["W1", "W2", "W3"])
    }

    func testMonthLabelFormatsAsMonthYear() {
        var comps = DateComponents()
        comps.year = 2026; comps.month = 7; comps.day = 1
        let date = Calendar(identifier: .gregorian).date(from: comps)!
        let label = PeriodBarLabeler.label(for: ChartPoint(start: date, value: 0), index: 0, scale: .month)
        XCTAssertEqual(label, "Jul '26")
    }

    func testQuarterLabelFormatsAsQuarterYear() {
        var comps = DateComponents()
        comps.year = 2026; comps.month = 8; comps.day = 15
        let date = Calendar(identifier: .gregorian).date(from: comps)!
        let label = PeriodBarLabeler.label(for: ChartPoint(start: date, value: 0), index: 0, scale: .quarter)
        XCTAssertEqual(label, "Q3 2026")
    }

    // MARK: - PeriodGoalBarChart.paddedDomain

    func testPaddedDomainEmptyIsUnitRange() {
        let d = PeriodGoalBarChart.paddedDomain(points: [], goal: nil)
        XCTAssertEqual(d.lowerBound, 0)
        XCTAssertEqual(d.upperBound, 1)
    }

    func testPaddedDomainSingleValuePadsTenPercent() {
        let d = PeriodGoalBarChart.paddedDomain(
            points: [ChartPoint(start: .now, value: 190)], goal: nil)
        // pad = max(1, 190 * 0.1) = 19
        XCTAssertEqual(d.lowerBound, 171, accuracy: 0.0001)
        XCTAssertEqual(d.upperBound, 209, accuracy: 0.0001)
    }

    func testPaddedDomainIncludesGoalAndPadsFifteenPercent() {
        let points = [ChartPoint(start: .now, value: 190), ChartPoint(start: .now, value: 195)]
        let d = PeriodGoalBarChart.paddedDomain(points: points, goal: 180)
        // lo=180, hi=195, pad = max(1, 15 * 0.15) = 2.25
        XCTAssertEqual(d.lowerBound, 177.75, accuracy: 0.0001)
        XCTAssertEqual(d.upperBound, 197.25, accuracy: 0.0001)
    }

    func testPaddedDomainClampsLowerBoundAtZero() {
        let points = [ChartPoint(start: .now, value: 2), ChartPoint(start: .now, value: 30)]
        let d = PeriodGoalBarChart.paddedDomain(points: points, goal: nil)
        // lo=2, pad = max(1, 28 * 0.15) = 4.2 → 2 - 4.2 = -2.2, clamped to 0
        XCTAssertEqual(d.lowerBound, 0, accuracy: 0.0001)
    }

    func testPaddedDomainDayLabelIsShortDate() {
        var comps = DateComponents()
        comps.year = 2026; comps.month = 8; comps.day = 5
        let date = Calendar(identifier: .gregorian).date(from: comps)!
        let label = PeriodGoalBarChart.label(
            for: ChartPoint(start: date, value: 0), index: 0, scale: .day)
        XCTAssertEqual(label, "8/5")
    }

    // MARK: - NormalCurve

    func testNormalCurveDegenerateStddevReturnsEmpty() {
        XCTAssertEqual(NormalCurve.points(mean: 5, stddev: 0), [])
        XCTAssertEqual(NormalCurve.ticks(mean: 5, stddev: 0), [])
    }

    func testNormalCurvePeaksAtMean() {
        let points = NormalCurve.points(mean: 10, stddev: 2, samples: 60)
        XCTAssertEqual(points.count, 61)
        let peak = points.max { $0.y < $1.y }!
        XCTAssertEqual(peak.x, 10, accuracy: 0.2)
    }

    func testNormalCurveTicksAreSigmaMultiplesWithinRange() {
        let ticks = NormalCurve.ticks(mean: 0, stddev: 1)
        XCTAssertEqual(ticks, [-2, -1, 0, 1, 2])
    }
}
