//
//  Game.swift
//  OpenQuizz
//
//  Created by Svetlana Lesik on 09/11/2018.
//  Copyright © 2018 Svetlana Lesik. All rights reserved.
//

import Foundation

class Game {
    var score = 0
    
    private var questions = [Question]()
    private var currentIndex = 0
    public var goodAnswer = false
    
    enum State { case ongoing, over }
    
    var state: State = .ongoing
   
    public var currentQuestion: Question{
        return questions[currentIndex]
    }
    

    func refresh() {
        currentIndex = 0
        score = 0
        finishGame()
    
        QuestionManager.shared.get { (questions) in
            self.questions = questions
            self.state = .ongoing
            let name = Notification.Name(rawValue: "QuestionsLoaded")
            let notification = Notification(name: name)
            NotificationCenter.default.post(notification)
        }
    }
    
    private func goToNextRound() {
        if currentIndex < questions.count - 1 {
            currentIndex += 1
        } else {
            finishGame()
        }
    }
    
    func answerCurrentQuestion(with answer: Bool) {
        if (answer && currentQuestion.isCorrect) || (!answer && !currentQuestion.isCorrect) {
            score += 1
            goodAnswer = true
        }
        else { goodAnswer = false }
        goToNextRound()
    }
    
    func noAnswer() {
        goToNextRound()
    }
    
    private func finishGame() {
        state = .over
    }
}

