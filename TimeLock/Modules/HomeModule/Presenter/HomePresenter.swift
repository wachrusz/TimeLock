//
//  HomePresenter.swift
//  TimeLock
//
//  Created by Misha Vakhrushin on 16.04.2025.
//

import Foundation

protocol HomeViewInput: AnyObject {
    func displayEntities(_ entities: [HomeEntity])
}

protocol HomeViewOutput {
    func loadEntities()
    func addEntity(source: String, secret: Data)
    func deleteAllEntities()
}


final class HomePresenter: HomeViewOutput, HomeInteractorOutput {
    private weak var view: HomeViewInput?
    private let interactor: HomeInteractorInput
    private var timer: Timer?
    private var currentEntities: [HomeEntity] = []

    init(view: HomeViewInput, interactor: HomeInteractorInput) {
        self.view = view
        self.interactor = interactor
        startTimer()
    }

    func loadEntities() {
        let entities = interactor.fetchEntities()
        didFetchEntities(entities)
    }
    
    func deleteAllEntities() {
        RealmManager.shared.deleteAll()
        KeychainStorage.shared.clearAll()
        loadEntities()
    }

    func addEntity(source: String, secret: Data) {
        interactor.addEntity(source: source, secret: secret)
        let entities = interactor.fetchEntities()
        didFetchEntities(entities)
    }
    
    func didFetchEntities(_ entities: [HomeEntity]) {
        currentEntities = entities
        view?.displayEntities(entities)
    }

    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.view?.displayEntities(self.currentEntities)
        }
    }
}
