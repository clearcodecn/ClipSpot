import XCTest
@testable import ClipSpot

final class SearchModelTests: XCTestCase {
    private var dir: URL!
    private var store: ClipboardStore!
    private var model: SearchModel!

    override func setUpWithError() throws {
        dir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        store = ClipboardStore(directory: dir, monitor: false)
        store.clips = ["apple", "banana", "apricot", "pear"].enumerated().map { index, text in
            Clip(id: text, text: text, imageFile: nil, imageType: nil, lastUsed: Date(timeIntervalSince1970: Double(10 - index)), pasteCount: index)
        }
        model = SearchModel(store: store)
    }
    override func tearDownWithError() throws { try? FileManager.default.removeItem(at: dir) }

    func testSearchClearingRestoresAllAndResetsSelection() {
        model.select(2, extending: true)
        model.query = "ap"
        XCTAssertEqual(model.results.map(\.id), ["apple", "apricot"])
        XCTAssertEqual(model.selection, 0)
        XCTAssertTrue(model.selectedIDs.isEmpty)
        model.query = ""
        XCTAssertEqual(model.results.map(\.id), ["apple", "banana", "apricot", "pear"])
    }
    func testRangeSelectionAndJoinedPasteFollowListOrder() {
        model.select(1, extending: false)
        model.select(3, extending: true)
        XCTAssertEqual(model.selectedClips.map(\.id), ["banana", "apricot", "pear"])
        XCTAssertEqual(ClipboardStore.combinedText(model.selectedClips), "banana\napricot\npear")
        model.select(2, extending: true)
        XCTAssertEqual(model.selectedClips.map(\.id), ["banana", "apricot"])
        model.select(0, extending: false)
        XCTAssertEqual(model.selectedClips.map(\.id), ["apple"])
    }
    func testSwitchingFavoritesClearsRange() {
        model.select(2, extending: true)
        model.favorites = true
        XCTAssertTrue(model.selectedIDs.isEmpty)
        XCTAssertEqual(model.selectedClips.map(\.id), ["pear"])
    }
}
