//
//  CustomNavBarViewController.swift
//  TimeLock
//
//  Created by Misha Vakhrushin on 19.04.2025.
//

import UIKit

final class CustomNavbar: UIView {

    // MARK: - State

    private var expanded = false
    private var settings = false

    var isExpanded: Bool { expanded }
    var isSettings: Bool { settings }
    
    var onSettingsToggle: ((Bool) -> Void)?

    // MARK: - Constraints

    private var titleLeadingConstraint: NSLayoutConstraint?
    private var titleTrailingConstraint: NSLayoutConstraint?
    private var exitButtonLeadingConstraint: NSLayoutConstraint?
    private var exitButtonTrailingConstraint: NSLayoutConstraint?

    // MARK: - UI

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
        label.text = "Codes"
        label.font = UIFont.systemFont(ofSize: 48, weight: .semibold)
        label.textColor = UIColor(named: "text")
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        label.lineBreakMode = .byTruncatingTail
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let addButton = CustomNavbar.makeIconButton(named: "addButton")
    let settingsButton = CustomNavbar.makeIconButton(named: "settingsButton", color: "hover")
    let manualButton = CustomNavbar.makeIconButton(named: "manualButton", hidden: true)
    let qrButton = CustomNavbar.makeIconButton(named: "qrButton", hidden: true)

    let exitSettingsButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "chevron.backward"), for: .normal)
        button.tintColor = UIColor(named: "text")
        button.backgroundColor = UIColor(named: "hover")
        button.layer.cornerRadius = 12
        button.translatesAutoresizingMaskIntoConstraints = false
        button.alpha = 0
        button.isHidden = true
        return button
    }()

    private let buttonStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 20
        stack.alignment = .center
        stack.distribution = .equalSpacing
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor(named: "bg")
        setupView()
        setupActions()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setupView() {
        addSubview(backgroundView)
        backgroundView.addSubview(titleLabel)
        backgroundView.addSubview(buttonStack)
        backgroundView.addSubview(exitSettingsButton)

        [manualButton, qrButton, addButton, settingsButton].forEach {
            $0.widthAnchor.constraint(equalToConstant: 48).isActive = true
            $0.heightAnchor.constraint(equalToConstant: 48).isActive = true
            buttonStack.addArrangedSubview($0)
        }

        titleLeadingConstraint = titleLabel.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor, constant: 20)
        titleTrailingConstraint = titleLabel.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor, constant: -20)

        exitButtonLeadingConstraint = exitSettingsButton.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor, constant: 20)
        exitButtonTrailingConstraint = exitSettingsButton.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor, constant: -20)

        titleLeadingConstraint?.isActive = true
        titleTrailingConstraint?.isActive = false
        exitButtonTrailingConstraint?.isActive = true
        exitButtonLeadingConstraint?.isActive = false

        NSLayoutConstraint.activate([
            backgroundView.topAnchor.constraint(equalTo: topAnchor),
            backgroundView.leadingAnchor.constraint(equalTo: leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: trailingAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: bottomAnchor),
            heightAnchor.constraint(equalToConstant: 80),

            titleLabel.centerYAnchor.constraint(equalTo: backgroundView.centerYAnchor, constant: 4),

            buttonStack.centerYAnchor.constraint(equalTo: backgroundView.centerYAnchor, constant: 4),
            buttonStack.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor, constant: -20),

            exitSettingsButton.centerYAnchor.constraint(equalTo: backgroundView.centerYAnchor, constant: 4),
            exitSettingsButton.widthAnchor.constraint(equalToConstant: 48),
            exitSettingsButton.heightAnchor.constraint(equalToConstant: 48),
        ])
        
        titleLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        titleLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)

        titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: buttonStack.leadingAnchor, constant: -20).isActive = true

        titleLabel.leadingAnchor.constraint(greaterThanOrEqualTo: exitSettingsButton.trailingAnchor, constant: 20).isActive = true

    }

    private func setupActions() {
        addButton.addTarget(self, action: #selector(toggleButtons), for: .touchUpInside)
        settingsButton.addTarget(self, action: #selector(toggleSettings), for: .touchUpInside)
        exitSettingsButton.addTarget(self, action: #selector(toggleSettings), for: .touchUpInside)
    }

    // MARK: - Logic

    /// FIX Text Animation 'cause that's a huge bolted penis!
    @objc func toggleButtons() {
        expanded.toggle()

        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: []) {
            self.addButton.alpha = self.expanded ? 0 : 1
            self.manualButton.alpha = self.expanded ? 1 : 0
            self.qrButton.alpha = self.expanded ? 1 : 0

            self.manualButton.transform = self.expanded ? .identity : CGAffineTransform(scaleX: 0.1, y: 0.1)
            self.qrButton.transform = self.expanded ? .identity : CGAffineTransform(scaleX: 0.1, y: 0.1)

            self.layoutIfNeeded()
        } completion: { _ in
            self.addButton.isHidden = self.expanded
            self.manualButton.isHidden = !self.expanded
            self.qrButton.isHidden = !self.expanded
        }
    }

    @objc private func toggleSettings() {
        settings.toggle()

        titleLeadingConstraint?.isActive = !settings
        titleTrailingConstraint?.isActive = settings

        exitButtonLeadingConstraint?.isActive = settings
        exitButtonTrailingConstraint?.isActive = !settings

        UIView.animate(withDuration: 0.3) {
            self.titleLabel.textAlignment = self.settings ? .right : .left
            self.titleLabel.text = self.settings ? "Settings" : "Codes"

            self.buttonStack.isHidden = self.settings
            self.exitSettingsButton.alpha = self.settings ? 1 : 0
            self.exitSettingsButton.isHidden = !self.settings

            self.layoutIfNeeded()
        }
        
        self.onSettingsToggle?(isSettings)
    }

    // MARK: - Helpers
    static func makeIconButton(named: String, hidden: Bool = false, color: String = "button") -> UIButton {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: named), for: .normal)
        button.tintColor = UIColor(named: "text")
        button.backgroundColor = UIColor(named: color)
        button.layer.cornerRadius = 12
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isHidden = hidden
        return button
    }
}
