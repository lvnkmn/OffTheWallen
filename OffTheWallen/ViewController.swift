//
//  ViewController.swift
//  OffTheWallen
//
//  Created by Menno Lovink on 20/02/16.
//  Copyright © 2016 Menno Lovink. All rights reserved.
//

import UIKit
import CoreMotion

let timerInterval : Double = 0.01

class ViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var textView: UITextField!
    var fallingTime : Double = 0.0

    let manager = CMMotionManager()
    var rotationX : Double = 0
    var rotationY : Double = 0
    var rotationZ : Double = 0

    var rotationSpeedX : Double = 0
    var rotationSpeedY : Double = 0
    var rotationSpeedZ : Double = 0

    var state : ViewControllerState! {

        didSet {

            state.configure()
            debugPrint("State changed to \(state)")
        }
    }

    required init?(coder aDecoder: NSCoder) {

        super.init(coder: aDecoder)
        state = StartingState(owner: self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        state.configure()

        textView.delegate = self

        if manager.accelerometerAvailable {
            manager.accelerometerUpdateInterval = Double(timerInterval)
            manager.startAccelerometerUpdatesToQueue(NSOperationQueue.mainQueue(), withHandler: didReceiveAccelometerData)
        }

        if manager.gyroAvailable {

            manager.gyroUpdateInterval = Double(timerInterval)
            manager.startGyroUpdatesToQueue(NSOperationQueue.mainQueue(), withHandler: didReceiveGyroData)
        }
    }

    @IBAction func didPressButton(sender: UIButton) {

        state.didPressButton()
    }

    func didReceiveGyroData(data : CMGyroData?, error : NSError?) {

        guard let data = data else {

            return
        }

        rotationSpeedX = data.rotationRate.x;
        rotationSpeedY = data.rotationRate.y;
        rotationSpeedZ = data.rotationRate.z;

        state.didReceiveGyroData(data)
    }

    func didReceiveAccelometerData(data : CMAccelerometerData?, error : NSError?) {

        guard let data = data else {

            return
        }

        if isRotating() {

            state.didDetectFall()

        } else if !isRotating() {

            state.didDetectLand()
        }
    }

    func isFalling(data : CMAccelerometerData) -> Bool {

        return  isInsideFallingThreshold(data.acceleration.x) &&
                isInsideFallingThreshold(data.acceleration.y) &&
                isInsideFallingThreshold(data.acceleration.z)
    }

    func isRotating() -> Bool {


        let isRotating =    isInsideRotatingThreshold(rotationSpeedX) ||
                            isInsideRotatingThreshold(rotationSpeedY) ||
                            isInsideRotatingThreshold(rotationSpeedZ)

        return isRotating
    }

    func isInsideFallingThreshold(value : Double) -> Bool {

        let threshold : Double = 0.1

        return value > -threshold && value < threshold
    }

    func isInsideRotatingThreshold(value : Double) -> Bool {


        let threshold : Double = 10

        return value > threshold || value < -threshold
    }

    func isUniqueThrow() -> Bool {

        return nameForCurrentThrow() == nil
    }

    func storeNameForCurrentThrow(name : String) {

        NSUserDefaults.standardUserDefaults().setValue(name, forKey: hashForScore())
    }

    func nameForCurrentThrow() -> String? {

        return NSUserDefaults.standardUserDefaults().valueForKey(hashForScore()) as? String
    }

    func hashForScore() -> String {

        return "\(rotationX + rotationY * 10 + rotationZ * 100)"
    }

    func synthesizedThowName() -> String {

        return "\(rotationX) degrees forwards 'X'\n\(rotationY) length 'Y'\n\(rotationZ) degrees sideways 'Z'"
    }

    func textFieldShouldReturn(textField: UITextField) -> Bool {

        textView.resignFirstResponder()

        return true
    }
}

protocol ViewControllerState {

    var owner : ViewController { get }
    func configure()
    func didReceiveGyroData(data : CMGyroData)
    func didDetectFall()
    func didDetectLand()
    func didPressButton()
}

