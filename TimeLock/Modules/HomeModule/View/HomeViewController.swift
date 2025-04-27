//
//  HomeViewController.swift
//  TimeLock
//
//  Created by Misha Vakhrushin on 16.04.2025.
//

import UIKit
import CryptoKit

class HomeViewController: UIViewController {
    private var displayLink: CADisplayLink?
    var presenter: HomeViewOutput?
    private var entities: [HomeEntity] = []

    private let tableView = UITableView()
    private let navbar = CustomNavbar()
    private var dismissTapGesture: UITapGestureRecognizer?
    private let settingsView = SettingsView()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        presenter?.loadEntities()

        let tap = UITapGestureRecognizer(target: self, action: #selector(handleNavbarTapOutside(_:)))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        dismissTapGesture = tap

        startProgressSync()
    }
    
    #if DEBUG
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        Logger.shared.log("\(settingsView.frame)")
        Logger.shared.log("\(tableView.frame)")
        Logger.shared.log("\(navbar.frame)")
    }
    #endif

    private func startProgressSync() {
        displayLink = CADisplayLink(target: self, selector: #selector(updateProgress))
        displayLink?.add(to: .main, forMode: .common)
    }

    @objc private func updateProgress() {
        let interval = 30.0
        let now = Date().timeIntervalSince1970
        let nextSlot = ceil(now / interval) * interval
        let remaining = nextSlot - now
        let ratio = CGFloat(remaining / interval)
        GlobalProgressIndicatorManager.shared.update(ratio: ratio)
    }

    private func setupUI() {
        view.backgroundColor = UIColor(named: "hover")
        
        view.addSubview(tableView)
        view.addSubview(settingsView)
        view.addSubview(navbar)

        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(HomeCell.self, forCellReuseIdentifier: "cell")
        tableView.backgroundColor = UIColor(named: "bg")
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableView.automaticDimension

        settingsView.translatesAutoresizingMaskIntoConstraints = false
        settingsView.backgroundColor = UIColor(named: "bg")
        settingsView.isHidden = true

        navbar.translatesAutoresizingMaskIntoConstraints = false
        navigationController?.setNavigationBarHidden(true, animated: false)
        navbar.manualButton.addTarget(self, action: #selector(presentManualEntry), for: .touchUpInside)
        navbar.qrButton.addTarget(self, action: #selector(presentQRScanner), for: .touchUpInside)
        navbar.onSettingsToggle = { [weak self] isSettings in
            self?.tableView.isHidden = isSettings
            self?.settingsView.isHidden = !isSettings
        }

        NSLayoutConstraint.activate([
            // Navbar
            navbar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            navbar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            navbar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            navbar.heightAnchor.constraint(equalToConstant: 80),

            // TableView
            tableView.topAnchor.constraint(equalTo: navbar.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            // SettingsView
            settingsView.topAnchor.constraint(equalTo: navbar.bottomAnchor),
            settingsView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            settingsView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            settingsView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = .always
        }
    }

    @objc private func presentManualEntry() {
        let addVC = ManualEntryViewController()
        addVC.onAdd = { [weak self] name, secret in
            guard let self else { return }
            let hashID = SHA256.hash(data: secret)
            let hex = hashID.prefix(16).map { String(format: "%02x", $0) }.joined()
            let id = UUID(uuidString: hex) ?? UUID()

            if self.entities.contains(where: { $0.id == id }) {
                let alert = UIAlertController(title: "Уже добавлен", message: "Этот ключ уже существует.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ок", style: .default))
                self.present(alert, animated: true)
                return
            }

            self.presenter?.addEntity(source: name, secret: secret)
        }

        let nav = UINavigationController(rootViewController: addVC)
        present(nav, animated: true)
    }
    
    @objc private func presentQRScanner() {
        let scannerVC = QRScannerViewController()
        scannerVC.modalPresentationStyle = .fullScreen
        scannerVC.onQRCodeScanned = { [weak self] name, secret in
            guard let self else { return }
            let hashID = SHA256.hash(data: secret)
            let hex = hashID.prefix(16).map { String(format: "%02x", $0) }.joined()
            let id = UUID(uuidString: hex) ?? UUID()

            if self.entities.contains(where: { $0.id == id }) {
                let alert = UIAlertController(title: "Уже добавлен", message: "Этот ключ уже существует.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ок", style: .default))
                self.present(alert, animated: true)
                return
            }
            
            self.presenter?.addEntity(source: name, secret: secret)
        }
        
        scannerVC.onShowError = { [weak self] text in
            guard let self else { return }
            self.showError(text)
            
        }
        present(scannerVC, animated: true)
    }
    
    @objc private func clearAll() {
        presenter?.deleteAllEntities()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    @objc private func handleNavbarTapOutside(_ gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: navbar)
        let insideManual = navbar.manualButton.frame.contains(location)
        let insideQR = navbar.qrButton.frame.contains(location)
        let insideAdd = navbar.addButton.frame.contains(location)
        if navbar.isExpanded && !(insideManual || insideQR || insideAdd) {
            navbar.toggleButtons()
        }
    }

    deinit {
        displayLink?.invalidate()
    }
    
    private func showCopyPopup() {
        let popup = UILabel()
        popup.text = "Код скопирован"
        popup.textColor = .white
        popup.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        popup.textAlignment = .center
        popup.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        popup.layer.cornerRadius = 12
        popup.clipsToBounds = true
        popup.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(popup)

        NSLayoutConstraint.activate([
            popup.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            popup.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -40),
            popup.widthAnchor.constraint(greaterThanOrEqualToConstant: 150),
            popup.heightAnchor.constraint(equalToConstant: 36)
        ])
        
        popup.alpha = 0
        UIView.animate(withDuration: 0.3, animations: {
            popup.alpha = 1
        }) { _ in
            UIView.animate(withDuration: 0.3, delay: 1.0, options: [], animations: {
                popup.alpha = 0
            }) { _ in
                popup.removeFromSuperview()
            }
        }
    }
    
    private func showError(_ text: String) {
        let alert = UIAlertController(
            title: "Wow! An error...",
            message: text,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            self.dismiss(animated: true)
        })
        present(alert, animated: true)
    }
}

extension HomeViewController: UITableViewDelegate {}

extension HomeViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        entities.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? HomeCell else {
            return UITableViewCell()
        }
        let entity = entities[indexPath.row]
        cell.configure(with: entity)
        cell.resetTransform()
        cell.onCopy = { [weak self] in
            self?.showCopyPopup()
        }
        cell.onDelete = { [weak self] in
            guard let self else { return }
            let alert = UIAlertController(
                title: "Удалить токен?",
                message: "Ты точно хочешь удалить токен для \(entity.source)? Это действие необратимо.",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "Отмена", style: .cancel) { _ in
                if let cell = tableView.cellForRow(at: indexPath) as? HomeCell {
                    UIView.animate(withDuration: 0.2) {
                        cell.resetPosition()
                    }
                }
            })
            alert.addAction(UIAlertAction(title: "Удалить", style: .destructive) { _ in
                self.presenter?.deleteEntity(entity)
            })
            self.present(alert, animated: true)
        }
        return cell
    }
}

extension HomeViewController: HomeViewInput {
    func displayEntities(_ entities: [HomeEntity]) {
        self.entities = entities
        tableView.reloadData()
    }

    func removeEntity(_ entity: HomeEntity) {
        guard let index = entities.firstIndex(where: { $0.id == entity.id }) else { return }
        entities.remove(at: index)
        
        tableView.performBatchUpdates({
            tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
        }, completion: nil)
    }
}
