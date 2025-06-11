//
//  QuestionFactoryDelegate.swift
//  MovieQuiz
//
//  Created by Sergei Biryukov on 08.06.2025.
//

protocol QuestionFactoryDelegate: AnyObject {               // 1
    func didReceiveNextQuestion(question: QuizQuestion?)    // 2
}
