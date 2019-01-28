//
//  ViewController.swift
//  OpenQuizz
//
//  Created by Svetlana Lesik on 08/11/2018.
//  Copyright © 2018 Svetlana Lesik. All rights reserved.
//

import UIKit
import SpriteKit

class ViewController: UIViewController {

    @IBOutlet weak var countdown: UILabel!
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var numerationLabel: UILabel!
    @IBOutlet weak var newGameButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var questionView: QuestionView!
    @IBOutlet weak var gameLabel: UILabel!
    @IBOutlet weak var finalScore: UILabel!
    @IBOutlet weak var commentAnswer: UILabel!
    @IBOutlet var background: UIView!
    @IBOutlet weak var startLogo: UILabel!
    @IBOutlet weak var rules: UILabel!
    @IBOutlet weak var logo: UILabel!
    
    var game = Game()
    var newGame: Bool = false
    
    let gradientLayerWhiteRadial = CAGradientLayer()
    let gradientLayerColorLinear = CAGradientLayer()
    var question = 0
    var progressBarTimer: Timer!
    var isAnswered = false
    var secondsLeft = 10
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let name = Notification.Name(rawValue: "QuestionsLoaded")
        NotificationCenter.default.addObserver(
            self, selector: #selector(questionsLoaded),
            name: name, object: nil)
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(dragQuestionView(_:)))
        questionView.addGestureRecognizer(panGestureRecognizer)
        if (newGame) {
            startNewGame() // On lance une partie tout de suite
        } else {
            entryPage()
             newGame = true
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Update layers size
        gradientLayerWhiteRadial.frame = view.bounds
        gradientLayerColorLinear.frame = view.bounds
        
        // Update ratio and size gradient radial
        let ratio = self.view.frame.size.width / self.view.frame.size.height
        gradientLayerWhiteRadial.endPoint = CGPoint(x: 1.0, y: (1.0 + 0.5 * ratio))
    }
    
    
    private func entryPage() {
        questionView.isHidden = true
        scoreLabel.isHidden = true
        gameLabel.isHidden = true
        logo.isHidden = true
        countdown.isHidden = true
        progressBar.isHidden = true
        
        newGameButton.isHidden = false
        setGradientBackground(colorGradientRadialOne: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1), colorGradientRadialTwo: #colorLiteral(red: 0.9999018312, green: 1, blue: 0.9998798966, alpha: 0), colorGradientLinearOne: #colorLiteral(red: 0.3921568627, green: 0.5568627451, blue: 0.7647058824, alpha: 1), colorGradientLinearTwo: #colorLiteral(red: 0.7062962651, green: 0.8440232277, blue: 1, alpha: 1))
        customButton()
    }
    
    private func customButton() {
        newGameButton.clipsToBounds = true
        newGameButton.layer.shadowColor = UIColor.black.cgColor
        newGameButton.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        newGameButton.layer.shadowRadius = 1.0
        newGameButton.layer.shadowOpacity = 0.5
        newGameButton.layer.cornerRadius = newGameButton.frame.size.width / 17
    }
    
    private func customProgressBar() {
        progressBar.layer.cornerRadius = 10
        progressBar.clipsToBounds = true
    }
    
    private func setGradientBackground (colorGradientRadialOne: UIColor, colorGradientRadialTwo: UIColor, colorGradientLinearOne: UIColor, colorGradientLinearTwo: UIColor){
        // Create Gradien layer Radial White
        gradientLayerWhiteRadial.frame = self.view.layer.bounds
        gradientLayerWhiteRadial.colors = [colorGradientRadialOne.cgColor, colorGradientRadialTwo.cgColor]
        gradientLayerWhiteRadial.locations = [0.0, 0.8]
        gradientLayerWhiteRadial.startPoint = CGPoint(x: 0.5, y: 1.0)
        let ratio = self.view.frame.size.width / self.view.frame.size.height
        gradientLayerWhiteRadial.endPoint = CGPoint(x: 1.0, y: (1.0 + 0.5 * ratio))
        gradientLayerWhiteRadial.type = .radial
        
        // Create Gradient layer Colored Linear
        gradientLayerColorLinear.frame = self.view.layer.bounds
        gradientLayerColorLinear.colors = [colorGradientLinearOne.cgColor, colorGradientLinearTwo.cgColor]
        gradientLayerColorLinear.locations = [0.0, 1.0]
        gradientLayerColorLinear.startPoint = CGPoint(x: 0.0, y: 0.0)
        gradientLayerColorLinear.endPoint = CGPoint(x: 1.0, y: 0.0)
        
        // Add Gradient Layers
        self.view.layer.insertSublayer(gradientLayerWhiteRadial, at: 0)
        self.view.layer.insertSublayer(gradientLayerColorLinear, at: 0)
    }
    
    @objc func updateProgressView() {
        commentAnswer.isHidden = true
        countdown.isHidden = false
        customProgressBar()
        progressBar.progress -= 0.1
        secondsLeft -= 1
        if (isAnswered) {
            progressBarTimer.invalidate()
            isAnswered = false
            timeCondition()
        }
        else if (progressBar.progress == 0.0){
            progressBarTimer.invalidate()
            question += 1
            comment(goodAnswer: false)
            scoreLabel.text = "\(game.score) / 10"
            numerationLabel.text = "Question \(question) / 10"
            game.noAnswer()
            showQuestionView()
            if (game.state == .over) {
                    gameOver()
            } else {timeCondition()
           }
        } else if (progressBar.progress <= 0.3) {
            progressBar.progressTintColor = #colorLiteral(red: 0.9019607843, green: 0.5529411765, blue: 0.5843137255, alpha: 1)
        }
        if (progressBar.progress == 0.0) { progressBar.tintColor = #colorLiteral(red: 0.7882352941, green: 0.8901960784, blue: 0.6392156863, alpha: 1) }
        countdown.text = "\(secondsLeft)"
        progressBar.setProgress(progressBar.progress, animated: true)
    }
    
    @objc func questionsLoaded() {
        activityIndicator.isHidden = true
        newGameButton.isHidden = true
        questionView.title = game.currentQuestion.title
    }

    @IBAction func didTapeNewGameButton() {
        startNewGame()
    }
    
    private func startNewGame(){
        startLogo.isHidden = true
        rules.isHidden = true
        newGameButton.isHidden = true
        
        activityIndicator.isHidden = false
        questionView.isHidden = false
        scoreLabel.isHidden = false
        gameLabel.isHidden = false
        logo.isHidden = false
        countdown.isHidden = false
        progressBar.isHidden = false
        
        questionView.title = "Loading..."
        questionView.style = .standard
        questionView.isHidden = false
        
        scoreLabel.text = "0 / 10"
        scoreLabel.isHidden = false
        
        gameLabel.text = "Score"
        finalScore.text = ""
        commentAnswer.isHidden = true
        
        question = 1
        numerationLabel.text = "Question \(question) / 10"
        
        timeCondition()
 
        chooseBackgroundColor(_: "standart")

        game.refresh()
    }
    
    @objc func dragQuestionView(_ sender: UIPanGestureRecognizer) {
        if game.state == .ongoing {
            switch sender.state {
            case .began, .changed:
                transformQuestionWith(gesture: sender)
            case .cancelled, .ended:
                    answerQuestion()
            default:
                break
            }
        }
    }
    
    private func timeCondition(){
        progressBar.isHidden = false
        progressBar.progressTintColor = #colorLiteral(red: 0.6624628901, green: 0.7545422316, blue: 0.5452731252, alpha: 1)
        progressBar.progressViewStyle = .bar
        progressBar.progress = 1.0
        secondsLeft = 10
        self.progressBarTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(ViewController.updateProgressView), userInfo: nil, repeats: true)
    }
    
    private func transformQuestionWith(gesture: UIPanGestureRecognizer){
        let translation = gesture.translation(in: questionView) //renvoie un CGPoint
        let translationTransform = CGAffineTransform(translationX: translation.x, y: translation.y)
        let screenWidth = UIScreen.main.bounds.width
        let translationPercent = translation.x/(screenWidth/2)
        let rotationAngle = (CGFloat.pi/6) * translationPercent
        let rotationTransform = CGAffineTransform(rotationAngle: rotationAngle)
        let transform = translationTransform.concatenating(rotationTransform)
        
        questionView.transform = transform
        
        if translation.x > 0 {
            questionView.style = .correct
        } else {
            questionView.style = .incorrect
        }
    }
    
    private func answerQuestion(){
        switch questionView.style {
        case .correct:
            game.answerCurrentQuestion(with: true)
            isAnswered = true
        case .incorrect:
            game.answerCurrentQuestion(with: false)
            isAnswered = true
        case .standard:
            break
        }
        
        question += 1
        comment(goodAnswer: game.goodAnswer)
        scoreLabel.text = "\(game.score) / 10"
        numerationLabel.text = "Question \(question) / 10"
        
        let screenWidth = UIScreen.main.bounds.width
        var translationTransform: CGAffineTransform
        if questionView.style == .correct {
            translationTransform = CGAffineTransform(translationX: screenWidth, y: 0)
        } else {
            translationTransform = CGAffineTransform(translationX: -screenWidth, y: 0)
        }
        
        UIView.animate(withDuration: 0.3, animations: {
            self.questionView.transform = translationTransform
        }) { (succes) in
            if succes {
                self.showQuestionView()
            }
        }
    }
    
   private func comment(goodAnswer: Bool){
        commentAnswer.isHidden = false
        if goodAnswer == true {
            commentAnswer.text = "Great ! \nYou've a good one !"
            commentAnswer.textColor = #colorLiteral(red: 0.5438766479, green: 0.6194549203, blue: 0.4477145672, alpha: 1)
        } else if goodAnswer == false {
            commentAnswer.text = "Ouch ... \nTry another one !"
            commentAnswer.textColor = #colorLiteral(red: 0.7148553133, green: 0.444589138, blue: 0.4723124504, alpha: 1)
        }
    }
    
    
    private func showQuestionView(){
        questionView.transform = .identity
        questionView.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
        questionView.style = .standard
        
        switch game.state {
        case .ongoing:
            questionView.title = game.currentQuestion.title
        case .over:
            //questionView.title = "Game Over !"
            gameOver()
        }
        
        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: [], animations: {
            self.questionView.transform = .identity
        }, completion: nil)

         commentAnswer.text = ""
    }
    
    private func gameOver(){
        progressBarTimer.invalidate()
        progressBar.isHidden = true
        countdown.isHidden = true
        questionView.isHidden = true
        gameLabel.text = "Your Score"
        gameLabel.isHidden = false
        commentAnswer.isHidden = true
        
        if game.score == 10 {
             chooseBackgroundColor(_: "winner")
        } else if game.score <= 3 {
          chooseBackgroundColor(_: "bad")
        } else if (4 <= game.score) && (game.score <= 6) {
            chooseBackgroundColor(_: "medium")
        } else if (7 <= game.score) && (game.score <= 9) {
          chooseBackgroundColor(_: "good")
        }
    }
    
    private func chooseBackgroundColor(_ result: String) {
        customButton()
        switch result {
        case "standart":
            setGradientBackground(colorGradientRadialOne: #colorLiteral(red: 0.9662205577, green: 1, blue: 0.8375923038, alpha: 1), colorGradientRadialTwo: #colorLiteral(red: 0.9999018312, green: 1, blue: 0.9998798966, alpha: 0), colorGradientLinearOne: #colorLiteral(red: 0.9568627477, green: 0.6588235497, blue: 0.5450980663, alpha: 1), colorGradientLinearTwo: #colorLiteral(red: 0.5843137503, green: 0.8235294223, blue: 0.4196078479, alpha: 1))
        case "winner":
            finalScore.text = "Yeah man !!! \nYou won 🏆"
            finalScore.textColor = #colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1)
            setGradientBackground(colorGradientRadialOne: #colorLiteral(red: 0.8039215686, green: 0.6274509804, blue: 0.3254901961, alpha: 0.5), colorGradientRadialTwo: #colorLiteral(red: 0.9999018312, green: 1, blue: 0.9998798966, alpha: 0), colorGradientLinearOne:  #colorLiteral(red: 0.04705882353, green: 0.01176470588, blue: 0.1843137255, alpha: 1), colorGradientLinearTwo: #colorLiteral(red: 0.1730485857, green: 0.1453145742, blue: 0.9921516776, alpha: 0.7728756421))
            newGameButton.backgroundColor = #colorLiteral(red: 0.8309881091, green: 0.6250680685, blue: 0.260245949, alpha: 1)
            newGameButton.setTitle("I want another One", for: .normal)
            newGameButton.setTitleColor(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1), for: .normal)
            newGameButton.isHidden = false
            newGameButton.flash()
        case "good":
            finalScore.text = "Great score ! \nKeep on 🔥🔥🔥 "
            finalScore.textColor = #colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1)
            setGradientBackground(colorGradientRadialOne: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1), colorGradientRadialTwo: #colorLiteral(red: 0.9999018312, green: 1, blue: 0.9998798966, alpha: 0), colorGradientLinearOne: #colorLiteral(red: 0.7568627451, green: 0.4196078431, blue: 0.1960784314, alpha: 1), colorGradientLinearTwo: #colorLiteral(red: 1, green: 0.6778883338, blue: 0.4406858981, alpha: 1))
            newGameButton.setTitle("I want to win !", for: .normal)
            newGameButton.setTitleColor(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1), for: .normal)
            newGameButton.backgroundColor = #colorLiteral(red: 0.8283365369, green: 0.3310188353, blue: 0.1848546863, alpha: 1)
            newGameButton.isHidden = false
            newGameButton.pulsate()
        case "medium":
            finalScore.text = "Not bad \nGo ahead !!! "
            finalScore.textColor = #colorLiteral(red: 0.09254281968, green: 0.2676765621, blue: 0.3948867023, alpha: 1)
            setGradientBackground(colorGradientRadialOne: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1), colorGradientRadialTwo: #colorLiteral(red: 0.9999018312, green: 1, blue: 0.9998798966, alpha: 0), colorGradientLinearOne: #colorLiteral(red: 0.1702605784, green: 0.2118574679, blue: 0.4848735929, alpha: 1), colorGradientLinearTwo: #colorLiteral(red: 0.6862745098, green: 0.7215686275, blue: 0.9411764706, alpha: 1))
            newGameButton.setTitle("I won't stop !", for: .normal)
            newGameButton.backgroundColor = #colorLiteral(red: 0.2465366125, green: 0.3236538768, blue: 0.7030329704, alpha: 1)
            newGameButton.setTitleColor(#colorLiteral(red: 0.6862745098, green: 0.7254901961, blue: 0.9254901961, alpha: 1), for: .normal)
            newGameButton.isHidden = false
            newGameButton.shake()
        case "bad":
            finalScore.text = "Oh-la-la ... \nYou've to try better"
            finalScore.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            setGradientBackground(colorGradientRadialOne: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1), colorGradientRadialTwo: #colorLiteral(red: 0.9999018312, green: 1, blue: 0.9998798966, alpha: 0), colorGradientLinearOne: #colorLiteral(red: 0.7293143868, green: 0.03247346729, blue: 0.19967556, alpha: 1), colorGradientLinearTwo:#colorLiteral(red: 0.9618609548, green: 0.2233514488, blue: 0.3233472109, alpha: 0.8810734161) )
            newGameButton.setTitle("Wait... I can better !", for: .normal)
            newGameButton.backgroundColor = #colorLiteral(red: 1, green: 0.6823483109, blue: 0.6800804734, alpha: 1)
            newGameButton.setTitleColor(#colorLiteral(red: 0.1459798813, green: 0.1460116506, blue: 0.1459756494, alpha: 1), for: .normal)
            newGameButton.isHidden = false
            newGameButton.shake()
        default:
            break
        }
    }
}

