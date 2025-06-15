//
//  StatisticServiceProtocol.swift
//  MovieQuiz
//
//  Created by Sergei Biryukov on 15.06.2025.
//
import UIKit

protocol StatisticServiceProtocol {
    var gamesCount: Int { get }
    var bestGame: GameResult { get }
    var totalAccuracy: Double { get }
    
    func store(correct count: Int, total amount: Int)
}

struct GameResult {
    let correct: Int
    let total: Int
    let date: Date
    
    func isBetterThan(_ another: GameResult) -> Bool {
            correct > another.correct
    }
}
