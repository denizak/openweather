//
//  ViewController.swift
//  weatherapp
//
//  Created by Deni Zakya on 27/08/23.
//

import UIKit
import Combine

class ViewController: UIViewController {

    private var subscribers: [AnyCancellable] = []
    private let viewModel = MainViewModel.make()

    private let mainStack: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.spacing = 10
        return stackView
    }()

    private let city: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 27)
        label.textAlignment = .center
        return label
    }()

    private let temperature: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 58)
        label.textAlignment = .center
        return label
    }()

    private let unitSelector: UISegmentedControl = {
        let segmentedControl = UISegmentedControl(items: ["C", "F"])
        segmentedControl.selectedSegmentIndex = 0
        return segmentedControl
    }()
    
    private let enableUserLocation: UIView = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17)
        label.textAlignment = .center
        label.text = "Please enable location services"

        let view = UIView()
        view.backgroundColor = .white

        view.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        label.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        label.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        label.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true

        return view
    }()
    
    private let weatherUnavailable: UIView = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17)
        label.textAlignment = .center
        label.text = "Weather data is not available, please check later."
        
        let view = UIView()
        view.backgroundColor = .white
        
        view.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        label.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        label.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        label.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        return view
    }()
    
    private let loading: UIView = {
        let activity = UIActivityIndicatorView(style: .large)
        activity.startAnimating()
        let view = UIView()
        view.backgroundColor = .white

        view.addSubview(activity)
        activity.translatesAutoresizingMaskIntoConstraints = false
        activity.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        activity.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true

        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .white
        appearance.titleTextAttributes = [.font: UIFont.boldSystemFont(ofSize: 20.0),
                                          .foregroundColor: UIColor.white]

        navigationController?.navigationBar.tintColor = .systemBlue
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance

        setUpView()
        bindViewModel()

        viewModel.viewLoad()
    }
    
    private func setUpView() {
        let showSearchBar = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(showSeachView))
        navigationItem.rightBarButtonItem = showSearchBar

        unitSelector.addTarget(self, action: #selector(unitValueChanged), for: .valueChanged)
        mainStack.addArrangedSubview(unitSelector)
        mainStack.addArrangedSubview(city)
        mainStack.addArrangedSubview(temperature)

        view.addSubview(mainStack)
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        mainStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10).isActive = true
        mainStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10).isActive = true
        mainStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10).isActive = true
        
        view.addSubview(enableUserLocation)
        enableUserLocation.translatesAutoresizingMaskIntoConstraints = false
        enableUserLocation.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        enableUserLocation.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        enableUserLocation.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        enableUserLocation.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        view.addSubview(weatherUnavailable)
        weatherUnavailable.translatesAutoresizingMaskIntoConstraints = false
        weatherUnavailable.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        weatherUnavailable.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        weatherUnavailable.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        weatherUnavailable.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        view.addSubview(loading)
        loading.translatesAutoresizingMaskIntoConstraints = false
        loading.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        loading.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        loading.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        loading.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
    
    private func bindViewModel() {
        viewModel.city.receive(on: DispatchQueue.main)
            .map { Optional($0) }
            .assign(to: \.text, on: city)
            .store(in: &subscribers)
        viewModel.temperature.receive(on: DispatchQueue.main)
            .map { Optional($0) }
            .assign(to: \.text, on: temperature)
            .store(in: &subscribers)
        viewModel.showEnableLocationPermission.receive(on: DispatchQueue.main)
            .map { !$0 }
            .assign(to: \.isHidden, on: enableUserLocation)
            .store(in: &subscribers)
        viewModel.showWeatherUnavailable.receive(on: DispatchQueue.main)
            .map { !$0 }
            .assign(to: \.isHidden, on: weatherUnavailable)
            .store(in: &subscribers)
        viewModel.showLoading.receive(on: DispatchQueue.main)
            .map { !$0 }
            .assign(to: \.isHidden, on: loading)
            .store(in: &subscribers)
    }

    @objc
    private func unitValueChanged(_ sender: UISegmentedControl) {
        viewModel.update(unit: sender.selectedUnit)
    }

    @objc
    private func showSeachView(_ sender: UIBarButtonItem) {
        let viewController = SearchViewController()
        viewController.onSelectLocation = { [unowned self] location in
            self.navigationController?.popViewController(animated: true)
            self.viewModel.update(location: location, unit: unitSelector.selectedUnit)
        }
        navigationController?.pushViewController(viewController, animated: true)
    }
}

private extension UISegmentedControl {
    var selectedUnit: Units {
        selectedSegmentIndex == 0 ? .metric : .imperial
    }
}

