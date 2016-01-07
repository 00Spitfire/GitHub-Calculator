//
//  ViewController.swift
//  Calculator
//
//  Created by Andrea Rumley on 1/7/16.
//  Copyright © 2016 Andrea Rumley. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    //    @IBOutlet weak var display: UILabel!
    
    @IBOutlet weak var display: UILabel!
    @IBOutlet weak var history: UILabel!
    
    private struct DefaultDisplayResult {
        static let Startup: Double = 0
        static let Error = "Error!"
    }
    
    private let defaultHistoryText = " "
    
    var userIsInTheMiddleOfTypingANumber = false
    var brain = CalculatorBrain()
    
    
    @IBAction func appendDigit(sender: UIButton) {
        let digit = sender.currentTitle!
        if userIsInTheMiddleOfTypingANumber {
            if digit != "." || display.text!.rangeOfString(".") == nil {
                display.text = display.text! + digit
            }
        } else {
            display.text = digit
            userIsInTheMiddleOfTypingANumber = true
        }
    }
    
    @IBAction func backspace() {
        if userIsInTheMiddleOfTypingANumber == true {
            if display.text!.characters.count > 1 {
                display.text = String(display.text!.characters.dropLast())
            } else {
                displayResult = CalculatorBrainEvaluationResult.Success(DefaultDisplayResult.Startup)
            }
        } else {
            brain.removeLastOpFromStack()
            displayResult = brain.evaluateAndReportErrors()
        }
    }
    
    
    @IBAction func changeSign() {
        if userIsInTheMiddleOfTypingANumber {
            if displayValue != nil {
                displayResult = CalculatorBrainEvaluationResult.Success(displayValue! * -1)
                
                // set userIsInTheMiddleOfTypingANumber back to true as displayResult will set it to false
                userIsInTheMiddleOfTypingANumber = true
            }
        } else {
            displayResult = brain.performOperation("ᐩ/-")
        }
    }
    
    @IBAction func pi() {
        if userIsInTheMiddleOfTypingANumber {
            enter()
        }
        displayResult = brain.pushConstant("π")
    }


    @IBAction func setM() {
    userIsInTheMiddleOfTypingANumber = false
    if displayValue != nil {
        brain.variableValues["M"] = displayValue!
    }
    displayResult = brain.evaluateAndReportErrors()
}

    @IBAction func getM() {

    if userIsInTheMiddleOfTypingANumber {
        enter()
    }
    displayResult = brain.pushOperand("M")
}

    @IBAction func clear() {
        brain.clearStack()
        brain.variableValues.removeAll()
        displayResult = CalculatorBrainEvaluationResult.Success(DefaultDisplayResult.Startup)
        history.text = defaultHistoryText
    }
    
    @IBAction func operate(sender: UIButton) {
        if userIsInTheMiddleOfTypingANumber {
            enter()
        }
        if let operation = sender.currentTitle {
            displayResult = brain.performOperation(operation)
        }
    }
    // Because displayValue is now an Optional Double the task of showing a suitable (result, zero, error)
    // display text can be safely handed over to the setter of displayValue. Additionally history is also
    // now assigned in the setter
    
    private var displayValue: Double? {
        if let displayValue = NSNumberFormatter().numberFromString(display.text!) {
            return displayValue.doubleValue
        }
        return nil
    }
    
    var displayResult: CalculatorBrainEvaluationResult? {
        get {
            if let displayValue = displayValue {
                return .Success(displayValue)
            }
            if display.text != nil {
                return .Failure(display.text!)
            }
            return .Failure("Error")
        }
        set {
            if newValue != nil {
                switch newValue! {
                case let .Success(displayValue):
                    display.text = "\(displayValue)"
                case let .Failure(error):
                    display.text = error
                }
            } else {
                display.text = DefaultDisplayResult.Error
            }
            userIsInTheMiddleOfTypingANumber = false
            
            if !brain.description.isEmpty {
                history.text = " \(brain.description) ="
            } else {
                history.text = defaultHistoryText
            }
        }
    }
    
    //Homework is make DisplayValue an optional
    //Homework push operands that are variables
    //Homework print ie: (4x(5+6))
    
    @IBAction func enter() {
        userIsInTheMiddleOfTypingANumber = false
        if displayValue != nil {
            displayResult = brain.pushOperand(displayValue!)
        }
    }
    
}
