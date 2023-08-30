import XCTest

final class weatherappUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testSearch() {
        let app = XCUIApplication()
        app.launch()
        
        let searchButton = app.navigationBars.buttons["search_city"]
        if searchButton.waitForExistence(timeout: 2) {
            searchButton.tap()
        }
        
        let searchBar = app.otherElements["search_field"].children(matching: .other)
            .element.children(matching: .searchField).element
        if searchBar.waitForExistence(timeout: 2) {
            searchBar.tap()
            searchBar.typeText("Denpasar")
        }
        
        let cell = app.tables/*@START_MENU_TOKEN@*/.staticTexts["Denpasar, Bali, ID"]/*[[".cells.staticTexts[\"Denpasar, Bali, ID\"]",".staticTexts[\"Denpasar, Bali, ID\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        if cell.waitForExistence(timeout: 2) {
            cell.tap()
        }
        
        let city = app.staticTexts["Denpasar"]
        XCTAssertTrue(city.exists)
    }
}
