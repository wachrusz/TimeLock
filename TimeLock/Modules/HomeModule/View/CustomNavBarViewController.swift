//
//  CustomNavBarViewController.swift
//  TimeLock
//
//  Created by Misha Vakhrushin on 19.04.2025.
//

import UIKit

final class CustomNavbar: UIView {

    private let backgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(named: "hover")
        view.translatesAutoresizingMaskIntoConstraints = false

        view.layer.cornerRadius = 24
        view.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        view.layer.masksToBounds = true
        return view
    }()

    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "TimeLock"
        label.font = UIFont.systemFont(ofSize: 36, weight: .semibold)
        label.textColor = UIColor(named: "text")
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let addButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor(named: "button")
        button.setImage(UIImage(systemName: "plus"), for: .normal)
        button.tintColor = .white
        button.layer.cornerRadius = 12
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        addSubview(backgroundView)
        backgroundView.addSubview(titleLabel)
        backgroundView.addSubview(addButton)

        NSLayoutConstraint.activate([
            backgroundView.topAnchor.constraint(equalTo: topAnchor),
            backgroundView.leadingAnchor.constraint(equalTo: leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: trailingAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: bottomAnchor),

            heightAnchor.constraint(equalToConstant: 80),
            titleLabel.centerYAnchor.constraint(equalTo: backgroundView.centerYAnchor, constant: 4),
            titleLabel.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor, constant: 20),
            addButton.centerYAnchor.constraint(equalTo: backgroundView.centerYAnchor, constant: 4),
            addButton.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor, constant: -20),
            addButton.widthAnchor.constraint(equalToConstant: 48),
            addButton.heightAnchor.constraint(equalToConstant: 48)
        ])
    }
}
