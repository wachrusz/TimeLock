//
//  HomeRouter.swift
//  TimeLock
//
//  Created by Misha Vakhrushin on 16.04.2025.
//

import UIKit

class HomeRouter {
    static func createModule() -> UIViewController {
        let view = HomeViewController()
        let interactor = HomeInteractor()
        let presenter = HomePresenter(view: view, interactor: interactor)

        view.presenter = presenter
        interactor.output = presenter

        return view
    }
}
