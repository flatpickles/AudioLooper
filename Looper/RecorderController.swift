//
//  RecorderController.swift
//  Looper
//
//  Created by Matt Nichols on 10/22/16.
//  Copyright © 2016 Matt Nichols. All rights reserved.
//

import Foundation
import AVFoundation

typealias RecordingStopCompletionHandler = ((Bool) -> ())

private let kFileName = "loop.caf"

class RecorderController: NSObject, AVAudioRecorderDelegate, AVAudioPlayerDelegate  {
    static func newRecorder() -> RecorderController? {
        let fileURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(kFileName)
        do {
            return try RecorderController.init(fileURL: fileURL)
        } catch let error as NSError {
            print("Error initializing recorder: %@", error.localizedDescription)
            return nil
        }
    }

    private let recorder: AVAudioRecorder

    private var player: AVAudioPlayer?
    private var completion: RecordingStopCompletionHandler?
    private var previousFile: URL?

    init(fileURL: URL) throws {
        let settings: [String:Any] = [
            AVFormatIDKey : Int(kAudioFormatAppleIMA4),
            AVSampleRateKey : 44100,
            AVNumberOfChannelsKey : 1,
            AVEncoderBitDepthHintKey : 16,
            AVEncoderAudioQualityKey : AVAudioQuality.medium.rawValue
        ]

        try self.recorder = AVAudioRecorder(url: fileURL, settings: settings)

        super.init()

        self.recorder.delegate = self
        self.recorder.prepareToRecord()
    }

    // MARK: public

    func record() -> Bool {
        self.player?.stop()
        return self.recorder.record()
    }

    func stopRecording(completion: RecordingStopCompletionHandler?) {
        if (self.recorder.isRecording) {
            self.completion = completion
            self.recorder.stop()
        } else {
            completion?(true)
        }
    }

    func play() {
        self.stopRecording(completion: { [weak self] success in
            if (success) {
                self?.player?.play()
            }
        })
    }

    func stopPlaying() {
        self.player?.stop()
    }

    // MARK: private

    private func recordingFinished(file: URL) {
        // delete the previous file if it exists
        if let previousFile = self.previousFile {
            do {
                try FileManager.default.removeItem(at: previousFile)
            } catch let error as NSError {
                print("Error deleting old loop: %@", error.localizedDescription)
            }
        }

        // save elsewhere (AVAudioPlayer deadlocks mysteriously when using the same URL for recording & playing)
        let docsDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let randomName = String(format:"%@.caf", NSUUID().uuidString)
        let destURL = URL(fileURLWithPath: docsDirectory).appendingPathComponent(randomName)
        do {
            try FileManager.default.copyItem(at: file, to: destURL)
        } catch let error as NSError {
            print("Error saving new loop: %@", error.localizedDescription)
        }
        self.previousFile = destURL

        // configure player to play the recorded file
        self.player = try? AVAudioPlayer(contentsOf: destURL)
        self.player?.delegate = self
        self.player?.numberOfLoops = -1 // Loop forever
        self.player?.prepareToPlay()

        // prepare for next recording
        self.recorder.prepareToRecord()
    }

    // MARK: AVAudioRecorderDelegate

    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if (flag) {
            self.recordingFinished(file: recorder.url)
        } else {
            print("Error finishing recording")
        }
        self.completion?(flag)
    }

    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        print("Recorder encoding error: %@", error?.localizedDescription)
    }

    // MARK: AVAudioPlayerDelegate

    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        print("Player decoding error: %@", error?.localizedDescription)
    }

    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if (!flag) {
            print("Error finishing playback")
        }
    }
}
