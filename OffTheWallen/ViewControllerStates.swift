//
//  ViewControllerStates.swift
//  OffTheWallen
//
//  Created by Menno Lovink on 23/02/16.
//  Copyright © 2016 Menno Lovink. All rights reserved.
//

import Foundation
import CoreMotion

struct StartingState : ViewControllerState {

    let owner : ViewController

    func configure() {

        owner.label.text = "This drugged up tourist is disrespecting your ho's. Throw him off the wallen!"
        owner.button.hidden = true
        owner.textView.hidden = true

        owner.rotationX = 0
        owner.rotationY = 0
        owner.rotationZ = 0
    }

    func didDetectFall() {

        owner.state = FallingState(owner: owner)
    }

    func didDetectLand() {}
    func didPressButton() {}
    func didReceiveGyroData(data : CMGyroData) {}
}

struct FallingState : ViewControllerState {

    let owner : ViewController

    func configure() {

        owner.label.text = "Tourist is falling!"
        owner.button.hidden = true
        owner.fallingTime = 0
    }

    func didDetectFall() {

        debugPrint("Falling")
        owner.fallingTime += timerInterval
        owner.label.text = "Tourist is falling for \(owner.fallingTime) seconds"
    }

    func didDetectLand() {

        owner.state = EndOfThrowState(owner: owner)
    }

    func didPressButton() {}

    func didReceiveGyroData(data : CMGyroData) {

        owner.rotationX += (data.rotationRate.x * timerInterval) * (180.0 / M_PI)
        owner.rotationY += (data.rotationRate.y * timerInterval) * (180.0 / M_PI)
        owner.rotationZ += (data.rotationRate.z * timerInterval) * (180.0 / M_PI)
    }
}

struct EndOfThrowState : ViewControllerState {

    let owner : ViewController

    func configure() {

        owner.rotationX = roundOff(owner.rotationX)
        owner.rotationY = roundOff(owner.rotationY)
        owner.rotationZ = roundOff(owner.rotationZ)

        if owner.isUniqueThrow() {

            owner.state = EnterNewThrowNameState(owner: owner)
        } else {

            owner.state = EndOfRoundState(owner: owner)
        }
    }

    func didPressButton() {

        owner.state = StartingState(owner: owner)
    }

    func roundOff(value : Double) -> Double {

        return round(value / 90) * 90
    }

    func didDetectFall() {}
    func didDetectLand() {}
    func didReceiveGyroData(data : CMGyroData) {}
}

struct EnterNewThrowNameState : ViewControllerState {

    let owner : ViewController

    func configure() {

        owner.label.text = "OMG!!1 You've just throwed a throw.. \n\n\(owner.synthesizedThowName())\n\n..that's never been thrown before! You may give it a name:"
        owner.button.hidden = false
        owner.textView.hidden = false
        owner.button.setTitle("Good enough throw name👌🏻", forState: .Normal)
    }

    func didReceiveGyroData(data : CMGyroData) {}
    func didDetectFall() {}
    func didDetectLand() {}
    func didPressButton() {

        owner.storeNameForCurrentThrow(owner.textView.text!)
        owner.textView.resignFirstResponder()
        owner.textView.text = nil
        owner.state = EndOfRoundState(owner: owner)
    }
}

struct EndOfRoundState : ViewControllerState {

    let owner : ViewController

    func configure() {

        owner.label.text = createDescription()
        owner.button.hidden = false
        owner.textView.hidden = true
        owner.button.setTitle("Try Again?", forState: .Normal)
    }

    func didReceiveGyroData(data : CMGyroData) {}
    func didDetectFall() {}
    func didDetectLand() {}
    func didPressButton() {

        owner.state = StartingState(owner: owner)
    }
    
    func createDescription() -> String {
        
        return "You just performed a '\(owner.nameForCurrentThrow()!)' or in other words..\n\n\(owner.synthesizedThowName())\n\n..on him. That'll teach him!"
    }
}
