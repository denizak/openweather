//
//  SearchTableDataSourceDelegateTests.swift
//  weatherappTests
//
//  Created by deni zakya on 30/08/23.
//

import XCTest
@testable import weatherapp

final class SearchTableDataSourceDelegateTests: XCTestCase {

    private let tableView = UITableView(frame: .zero)

    func testNumberOfSections() {
        let sut = makeSUT()

        let actualNumberOfSections = sut.numberOfSections(in: tableView)

        XCTAssertEqual(actualNumberOfSections, 1)
    }

    func testNumberOfRows() {
        let sut = makeSUT()

        let actualNumberOfRows = sut.tableView(tableView, numberOfRowsInSection: 0)

        XCTAssertEqual(actualNumberOfRows, 1)
    }

    func testCellForRowAtIndexPath() {
        let cellIdentifier = "Cell"
        let sut = makeSUT()
        sut.cellIdentifier = cellIdentifier

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        let cell = sut.tableView(tableView, cellForRowAt: .init(row: 0, section: 0))

        XCTAssertEqual(cell.textLabel?.text, "any-city, any-country")
    }

    func testDidSelectRow() {
        let sut = makeSUT()
        var actualSelectedRow = -1
        sut.selectedRow = { actualSelectedRow = $0 }

        sut.tableView(tableView, didSelectRowAt: .init(row: 0, section: 0))

        XCTAssertEqual(actualSelectedRow, 0)
    }

    func testLeak() {
        let sut = makeSUT()

        testMemoryLeak(sut)
    }

    private func makeSUT() -> SearchTableDataSourceDelegate {
        SearchTableDataSourceDelegate(getLocations: {
            [
                .init(city: "any-city",
                      state: nil,
                      country: "any-country",
                      coordinate: .init(lat: 1, long: 1))
            ]
        })
    }
}
