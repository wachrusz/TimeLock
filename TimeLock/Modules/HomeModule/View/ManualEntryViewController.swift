//
//  ManualEntryViewController.swift
//  TimeLock
//
//  Created by Misha Vakhrushin on 18.04.2025.
//

import UIKit

final class ManualEntryViewController: UIViewController {

    var onAdd: ((_ name: String, _ secret: Data) -> Void)?

    private let nameField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Название аккаунта"
        tf.borderStyle = .roundedRect
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()

    private let secretField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Секрет (hex или base32)"
        tf.borderStyle = .roundedRect
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.autocapitalizationType = .allCharacters
        tf.autocorrectionType = .no
        return tf
    }()

    private let errorLabel: UILabel = {
        let label = UILabel()
        label.textColor = .systemRed
        label.font = .systemFont(ofSize: 13)
        label.numberOfLines = 0
        label.textAlignment = .center
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        configureSheetPresentation()
        setupUI()
    }

    private func configureSheetPresentation() {
        if let sheet = sheetPresentationController {
            sheet.detents = [.medium()]
            sheet.prefersGrabberVisible = true
        }
        title = "Новая запись"
        view.backgroundColor = .systemBackground
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Добавить", style: .done, target: self, action: #selector(handleAdd))
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(close))
    }

    private func setupUI() {
        let stack = UIStackView(arrangedSubviews: [nameField, secretField, errorLabel])
        stack.axis = .vertical
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            stack.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
    }

    private func parseSecret(_ input: String) -> Data? {
        let trimmed = input.trimmingCharacters(in: .whitespacesAndNewlines)

        if let hexData = Data(hexString: trimmed) {
            return hexData
        }

        if let b32Data = Data(base32Encoded: trimmed) {
            return b32Data
        }

        return trimmed.data(using: .utf8)
    }
    
    @objc private func handleAdd() {
        guard let name = nameField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !name.isEmpty else {
            showError("Введите название аккаунта")
            return
        }

        guard let rawSecret = secretField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !rawSecret.isEmpty else {
            showError("Введите секретный ключ")
            return
        }

        guard let secret = parseSecret(rawSecret) else {
            showError("Не удалось распознать формат ключа")
            return
        }
        print("🧬 Secret Bytes: \(secret.map { String(format: "%02x", $0) }.joined())")
        
        if TOTPGenerator.shared.contains(secret: secret) {
            showError("Такой ключ уже добавлен")
            return
        }

        let canonicalHex = secret.map { String(format: "%02hhx", $0) }.joined()
        print("🔑 Канонический HEX: \(canonicalHex)")

        dismiss(animated: true) {
            self.onAdd?(name, secret)
        }
    }
    
    @objc private func close() {
        dismiss(animated: true)
    }

    private func showError(_ text: String) {
        errorLabel.text = text
        errorLabel.isHidden = false
    }
}
