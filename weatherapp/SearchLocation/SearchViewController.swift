//
//  SearchViewController.swift
//  weatherapp
//
//  Created by deni zakya on 29/08/23.
//

import UIKit

final class SearchViewController: UIViewController {

    var onSelectLocation: (Location) -> Void = { _ in }

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
    }

}
