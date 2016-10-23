//
//  AppDelegate.swift
//  Looper
//
//  Created by Matt Nichols on 10/22/16.
//  Copyright © 2016 Matt Nichols. All rights reserved.
//

import UIKit
import AVFoundation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(AVAudioSessionCategoryPlayAndRecord, with: AVAudioSessionCategoryOptions.defaultToSpeaker)
            try session.setActive(true)
        } catch let error as NSError {
            print("Error initializing audio session: %@", error.localizedDescription)
        }

        return true
    }

}

