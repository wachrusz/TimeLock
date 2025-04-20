//
//  HomeViewController.swift
//  TimeLock
//
//  Created by Misha Vakhrushin on 16.04.2025.
//

import UIKit
import CryptoKit

class HomeViewController: UIViewController {
    var presenter: HomeViewOutput?
    private var entities: [HomeEntity] = []

    private let tableView = UITableView()
    private let navbar = CustomNavbar()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavbar()
        setupUI()
        presenter?.loadEntities()
    }

    private func setupNavbar() {
        navigationController?.setNavigationBarHidden(true, animated: false) // ВАЖНО
        view.addSubview(navbar)
        navbar.translatesAutoresizingMaskIntoConstraints = false
        navbar.addButton.addTarget(self, action: #selector(showAddOptions), for: .touchUpInside)

        NSLayoutConstraint.activate([
            navbar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            navbar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            navbar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            navbar.heightAnchor.constraint(equalToConstant: 80)
        ])
        
    }

    private func setupUI() {
        //view.backgroundColor = UIColor(named: "hover")

        tableView.dataSource = self
        tableView.register(HomeCell.self, forCellReuseIdentifier: "cell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: navbar.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }

    @objc private func showAddOptions() {
        let addVC = ManualEntryViewController()
        addVC.onAdd = { [weak self] name, secret in
            guard let self else { return }

            let hashID = SHA256.hash(data: secret)
            let hex = hashID.prefix(16).map { String(format: "%02x", $0) }.joined()
            let id = UUID(uuidString: hex) ?? UUID()

            if self.entities.contains(where: { $0.id == id }) {
                let alert = UIAlertController(title: "Уже добавлен", message: "Этот ключ уже существует в списке.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ок", style: .default))
                self.present(alert, animated: true)
                return
            }

            self.presenter?.addEntity(source: name, secret: secret)
        }

        let nav = UINavigationController(rootViewController: addVC)
        present(nav, animated: true)
    }

    @objc private func clearAll() {
        presenter?.deleteAllEntities()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
}

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
        return cell
    }
}

extension HomeViewController: HomeViewInput {
    func displayEntities(_ entities: [HomeEntity]) {
        self.entities = entities
        tableView.reloadData()
    }
} 

