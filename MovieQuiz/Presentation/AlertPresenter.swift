//
//  AlertPresenter.swift
//  MovieQuiz
//
//  Created by Sergei Biryukov on 11.06.2025.
//

// AlertPresenter.swift
import UIKit

final class AlertPresenter {
    func show(alertModel: AlertModel, on viewController: UIViewController) {
        let alert = UIAlertController(
            title: alertModel.title,
            message: alertModel.message,
            preferredStyle: .alert
        )

        let action = UIAlertAction(title: alertModel.buttonText, style: .default) { _ in
            alertModel.completion()
        }

        alert.addAction(action)
        viewController.present(alert, animated: true)
    }
}
