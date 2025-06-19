import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    
    private var questionsAmount: Int = 10
    private var questionFactory: QuestionFactoryProtocol = QuestionFactory()
    private var currentQuestion: QuizQuestion?
    private var currentQuestionIndex = 0
    private var correctAnswers = 0
    private var isButtonsEnabled = true
    private let statisticService: StatisticServiceProtocol = StatisticServiceImplementation()
    
    private var alertPresenter = AlertPresenter()
    
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var counterLabel: UILabel!
    @IBOutlet private var yesButton: UIButton!
    @IBOutlet private var noButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.layer.cornerRadius = 20
        
        if let factory = questionFactory as? QuestionFactory {
            factory.delegate = self
        }
        questionFactory.requestNextQuestion()
    }
    
    @IBAction private func yesButtonClicked(_ sender: Any) {
        guard isButtonsEnabled, let currentQuestion = currentQuestion else { return }
        showAnswerResult(isCorrect: true == currentQuestion.correctAnswer)
    }
    
    @IBAction private func noButtonClicked(_ sender: Any) {
        guard isButtonsEnabled, let currentQuestion = currentQuestion else { return }
        showAnswerResult(isCorrect: false == currentQuestion.correctAnswer)
    }
    
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(
            image: UIImage(named: model.image) ?? UIImage(systemName: "xmark.octagon")!,
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)"
        )
    }
    
    private func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
        imageView.layer.borderWidth = 0
        enableButtons(true)
    }
    
    private func show(quiz result: QuizResultsViewModel) {
        let alert = UIAlertController(
            title: result.title,
            message: result.text,
            preferredStyle: .alert
        )
        
        let action = UIAlertAction(title: result.buttonText, style: .default) { [weak self] _ in
            guard let self = self else { return }
            self.currentQuestionIndex = 0
            self.correctAnswers = 0
            self.questionFactory.requestNextQuestion()
        }
        
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
    private func showAlert(result: QuizResultsViewModel) {
            let alertModel = AlertModel(
                title: result.title,
                message: result.text,
                buttonText: result.buttonText,
                completion: { [weak self] in
                    guard let self = self else { return }
                    self.currentQuestionIndex = 0
                    self.correctAnswers = 0
                    self.questionFactory.requestNextQuestion()
                }
            )
            alertPresenter.show(alertModel: alertModel, on: self)
    }
    
    private func showAnswerResult(isCorrect: Bool) {
        isButtonsEnabled = false

        if isCorrect {
            correctAnswers += 1
        }

        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        imageView.layer.borderWidth = 8
        imageView.layer.cornerRadius = 20
        imageView.layer.masksToBounds = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            if self.currentQuestionIndex == self.questionsAmount - 1 {
                // ✅ Сохраняем СРАЗУ после ответа на последний вопрос
                self.statisticService.store(correct: self.correctAnswers, total: self.questionsAmount)
            }
            self.showNewQuestionOrResult()
        }
    }

    
    private func showNewQuestionOrResult() {
        if currentQuestionIndex == questionsAmount - 1 {
            statisticService.store(correct: correctAnswers, total: questionsAmount)
            
            let best = statisticService.bestGame
            let accuracy = String(format: "%.2f", statisticService.totalAccuracy)

            let message = """
            Ваш результат: \(correctAnswers)/\(questionsAmount)
            Кол-во сыгранных квизов: \(statisticService.gamesCount)
            Рекорд: \(best.correct)/\(best.total) (\(format(date: best.date)))
            Средняя точность: \(accuracy)%
            """

            let viewModel = QuizResultsViewModel(
                title: "Этот раунд окончен!",
                text: message,
                buttonText: "Сыграть ещё раз"
            )

            showAlert(result: viewModel)
        } else {
            currentQuestionIndex += 1
            questionFactory.requestNextQuestion()
        }
    }
    
    private func format(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy HH:mm"
        return formatter.string(from: date)
    }

    
    // MARK: - QuestionFactoryDelegate
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else { return }
        currentQuestion = question
        let viewModel = convert(model: question)
        
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
    }
    
    // MARK: - Helpers
    
    private func enableButtons(_ isEnabled: Bool) {
        yesButton.isEnabled = isEnabled
        noButton.isEnabled = isEnabled
        isButtonsEnabled = isEnabled
    }
}
