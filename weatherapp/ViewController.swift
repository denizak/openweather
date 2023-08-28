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
        return stackView
    }()

    private let name: UILabel = {
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

        setUpView()
        bindViewModel()
    }
    
    private func setUpView() {
        mainStack.addArrangedSubview(name)
        mainStack.addArrangedSubview(temperature)

        view.addSubview(mainStack)
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        mainStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        mainStack.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        mainStack.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
        view.addSubview(enableUserLocation)
        enableUserLocation.translatesAutoresizingMaskIntoConstraints = false
        enableUserLocation.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        enableUserLocation.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        enableUserLocation.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
        view.addSubview(weatherUnavailable)
        weatherUnavailable.translatesAutoresizingMaskIntoConstraints = false
        weatherUnavailable.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        weatherUnavailable.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        weatherUnavailable.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
        view.addSubview(loading)
        loading.translatesAutoresizingMaskIntoConstraints = false
        loading.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        loading.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        loading.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        loading.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
    
    private func bindViewModel() {
        viewModel.name.receive(on: DispatchQueue.main)
            .map { Optional($0) }
            .assign(to: \.text, on: name)
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

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        viewModel.viewAppear()
    }
}

