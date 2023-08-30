//
//  SearchViewController.swift
//  weatherapp
//
//  Created by deni zakya on 29/08/23.
//

import UIKit
import Combine

final class SearchViewController: UIViewController {

    var onSelectLocation: (Location) -> Void = { _ in }

    private var cancellable: AnyCancellable?
    private let viewModel = SearchLocationViewModel.make()
    private let cellIdentifier = "Cell"

    private let mainStack: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fill
        return stackView
    }()

    private let tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .plain)
        return table
    }()

    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar(frame: .zero)
        return searchBar
    }()

    private lazy var tableDataSourceDelegate: SearchTableDataSourceDelegate = {
        SearchTableDataSourceDelegate { [weak self] in
            self?.viewModel.currentLocations ?? []
        }
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        mainStack.addArrangedSubview(searchBar)
        mainStack.addArrangedSubview(tableView)

        view.backgroundColor = .white
        view.addSubview(mainStack)
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        mainStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        mainStack.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        mainStack.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        mainStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        tableView.dataSource = tableDataSourceDelegate
        tableView.delegate = tableDataSourceDelegate

        tableDataSourceDelegate.cellIdentifier = cellIdentifier
        tableDataSourceDelegate.selectedRow = { [unowned self] row in
            let selectedLocation = self.viewModel.currentLocations[row]
            self.onSelectLocation(selectedLocation)
        }
        cancellable = viewModel.reloadData.receive(on: DispatchQueue.main).sink { [unowned self] _ in
            self.tableView.reloadData()
        }

        searchBar.delegate = self
        updateBackgroundColor()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        updateBackgroundColor()
    }
    
    private func updateBackgroundColor() {
        let backgroundColor: UIColor = UITraitCollection.current.userInterfaceStyle == .dark ? .black : .white
        self.navigationController?.navigationBar.backgroundColor = backgroundColor
        self.view.backgroundColor = backgroundColor
    }
}

extension SearchViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        viewModel.search(searchText)
    }
}

final class SearchTableDataSourceDelegate: NSObject, UITableViewDataSource, UITableViewDelegate {

    var selectedRow: (Int) -> Void = { _ in }
    var cellIdentifier = ""

    private var getLocations: () -> [Location]
    init(getLocations: @escaping () -> [Location]) {
        self.getLocations = getLocations
    }

    func numberOfSections(in tableView: UITableView) -> Int { 1 }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        getLocations().count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)

        cell.textLabel?.text = getLocations()[indexPath.row].label

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedRow(indexPath.row)
    }
}

private extension Location {
    var label: String {
        if let state = state {
            return "\(city), \(state), \(country)"
        } else {
            return "\(city), \(country)"
        }
    }
}
