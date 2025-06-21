//
//  StatisticService.swift
//  MovieQuiz
//
//  Created by Sergei Biryukov on 15.06.2025.
//
import Foundation

final class StatisticServiceImplementation: StatisticServiceProtocol {

    private let userDefaults = UserDefaults.standard

    private enum Keys {
        static let gamesCount = "gamesCount"
        static let bestGameCorrect = "bestGameCorrect"
        static let bestGameTotal = "bestGameTotal"
        static let bestGameDate = "bestGameDate"
        static let totalCorrect = "totalCorrect"
        static let totalQuestions = "totalQuestions"
    }

    var gamesCount: Int {
        get { userDefaults.integer(forKey: Keys.gamesCount) }
        set { userDefaults.set(newValue, forKey: Keys.gamesCount) }
    }

    var bestGame: GameResult {
        get {
            let correct = userDefaults.integer(forKey: Keys.bestGameCorrect)
            let total = userDefaults.integer(forKey: Keys.bestGameTotal)
            let date = userDefaults.object(forKey: Keys.bestGameDate) as? Date ?? Date()
            return GameResult(correct: correct, total: total, date: date)
        }
        set {
            userDefaults.set(newValue.correct, forKey: Keys.bestGameCorrect)
            userDefaults.set(newValue.total, forKey: Keys.bestGameTotal)
            userDefaults.set(newValue.date, forKey: Keys.bestGameDate)
        }
    }

    var totalAccuracy: Double {
        let correct = userDefaults.integer(forKey: Keys.totalCorrect)
        let total = userDefaults.integer(forKey: Keys.totalQuestions)
        guard total > 0 else { return 0 }
        return (Double(correct) / Double(total)) * 100
    }

    func store(correct count: Int, total amount: Int) {
        guard amount > 0 else { return }

        gamesCount += 1

        let current = GameResult(correct: count, total: amount, date: Date())
        if current.isBetterThan(bestGame) {
            bestGame = current
        }

        let previousCorrect = userDefaults.integer(forKey: Keys.totalCorrect)
        let previousTotal = userDefaults.integer(forKey: Keys.totalQuestions)

        userDefaults.set(previousCorrect + count, forKey: Keys.totalCorrect)
        userDefaults.set(previousTotal + amount, forKey: Keys.totalQuestions)
    }
}
