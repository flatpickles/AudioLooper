//
//  ViewController.swift
//  Looper
//
//  Created by Matt Nichols on 10/22/16.
//  Copyright © 2016 Matt Nichols. All rights reserved.
//

import UIKit

private let kRecordColor: UIColor = UIColor.red
private let kPlayColor: UIColor = UIColor.green
private let kOtherColor: UIColor = UIColor.yellow

class ViewController: UIViewController {

    private let recorder: RecorderController?

    required init?(coder aDecoder: NSCoder) {
        self.recorder = RecorderController.newRecorder()
        super.init(coder: aDecoder)
    }

    @IBAction func touchDown(_ sender: AnyObject) {
        self.startRecording()
    }

    @IBAction func touchUpInside(_ sender: AnyObject) {
        self.stopRecording()
    }

    private func startRecording() {
        if let recorder = self.recorder, recorder.record() {
            self.view.backgroundColor = kRecordColor
        } else {
            self.view.backgroundColor = kOtherColor
        }
    }

    private func stopRecording() {
        self.recorder?.stopRecording(completion: { [weak self] success in
            if (success) {
                self?.recorder?.play()
                self?.view.backgroundColor = kPlayColor
            } else {
                self?.view.backgroundColor = kOtherColor
            }
        })
    }
}

