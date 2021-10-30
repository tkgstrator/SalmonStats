import XCTest
import CombineExpectations
@testable import SalmonStats

final class SalmonStatsTests: XCTestCase {
    func testGetPlayerLink() {
        do {
            guard let json = Bundle.module.url(forResource: "coop", withExtension: "json") else { throw APIError.fatal }

            let publisher = SalmonStats.shared.getResult(resultId: 100000)
            let recorder = publisher.record()
            let elements = try wait(for: recorder.elements, timeout: 10, description: "GET RECORD FROM SPLATNET2")
            dump(elements)
        } catch {
            print(error)
        }
    }

    func testGetShiftStats() {
        do {
            let publisher = SalmonStats.shared.getShiftStats(startTime: 2021041300)
            let recorder = publisher.record()
            let elements = try wait(for: recorder.elements, timeout: 10, description: "GET RECORD FROM SPLATNET2")
            dump(elements)
        } catch {
            print(error)
        }
    }
    
    func testGetShiftRecord() {
        do {
            let publisher = SalmonStats.shared.getShiftRecord(startTime: 2021041300)
            let recorder = publisher.record()
            let elements = try wait(for: recorder.elements, timeout: 10, description: "GET RECORD FROM SPLATNET2")
            dump(elements)
        } catch {
            print(error)
        }
    }

    func testGetResultsCoop() {
        do {
            let publisher = SalmonStats.shared.getResults(nsaid: "91d160aa84e88da6", pageId: 1)
            let recorder = publisher.record()
            let elements = try wait(for: recorder.elements, timeout: 30, description: "GET RECORD FROM SPLATNET2")
            dump(elements)
        } catch {
            print(error)
        }
    }

    func testGetMetadata() {
        do {
            let publisher = SalmonStats.shared.getMetadata(nsaid: "91d160aa84e88da6")
            let recorder = publisher.record()
            let elements = try wait(for: recorder.elements, timeout: 10, description: "GET RECORD FROM SPLATNET2")
            dump(elements)
        } catch {
            print(error)
        }
    }

    static var allTests = [
        ("testGetPlayerLink", testGetPlayerLink),
        ("testGetShiftStats", testGetShiftStats),
        ("testGetShiftRecord", testGetShiftRecord),
        ("testGetResultsCoop", testGetResultsCoop),
        ("testGetMetadata", testGetMetadata),
    ]
}
