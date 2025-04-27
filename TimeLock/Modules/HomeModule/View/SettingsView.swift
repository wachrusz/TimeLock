//
//  SettingsView.swift
//  TimeLock
//
//  Created by Misha Vakhrushin on 27.04.2025.
//

import UIKit

class SettingsView: UIView {

    private let actionButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Backup Codes from iCloud", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let bottomContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 12
        view.clipsToBounds = true
        return view
    }()

    private let bottomLabel: UILabel = {
        let label = UILabel()
        label.text = "Developed by Mikhail Vakhrushin as a showcase of technical and creative skills"
        label.font = UIFont.systemFont(ofSize: 24, weight: .ultraLight)
        label.numberOfLines = 0
        label.textAlignment = .center
        label.textColor = UIColor(named: "text")
        label.translatesAutoresizingMaskIntoConstraints = false
        label.layer.opacity = 0.5
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemPink.withAlphaComponent(0.3)
        setupLayout()
        setupActions()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        backgroundColor = .systemPink.withAlphaComponent(0.3)
        setupLayout()
        setupActions()
    }

    private func setupLayout() {
        addSubview(actionButton)
        addSubview(bottomContainer)
        bottomContainer.addSubview(bottomLabel)
        
        NSLayoutConstraint.activate([
            actionButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            actionButton.centerYAnchor.constraint(equalTo: centerYAnchor),

            bottomContainer.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 32),
            bottomContainer.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -32),
            bottomContainer.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -32),
            
            bottomLabel.leadingAnchor.constraint(equalTo: bottomContainer.leadingAnchor, constant: 16),
            bottomLabel.trailingAnchor.constraint(equalTo: bottomContainer.trailingAnchor, constant: -16),
            bottomLabel.topAnchor.constraint(equalTo: bottomContainer.topAnchor, constant: 8),
            bottomLabel.bottomAnchor.constraint(equalTo: bottomContainer.bottomAnchor, constant: -8)
        ])
    }

    private func setupActions() {
        actionButton.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
    }

    @objc private func buttonTapped() {
        Logger.shared.log("Staritng backup")
        #if DEBUG
        let _ = iCloudStorage.shared.loadEntitiesMetadata()
        #endif
    }
}
