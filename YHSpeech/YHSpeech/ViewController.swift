//
//  ViewController.swift
//  YHSpeech
//
//  Created by HenryLee on 16/6/20.
//  Copyright © 2016年 HenryLee. All rights reserved.
//

import UIKit
import AVFoundation
import Speech

class ViewController: UIViewController {
    
    var recorder : AVAudioRecorder?
    var soundURL : URL!
    var session : AVAudioSession!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("\(NSHomeDirectory())")

        session = AVAudioSession.sharedInstance()
        
        do {
            try session.setCategory(AVAudioSessionCategoryPlayAndRecord, with: AVAudioSessionCategoryOptions.defaultToSpeaker)
            try session.overrideOutputAudioPort(AVAudioSessionPortOverride.speaker)
            try session.setActive(true)
        }catch {
            print("catch : \(error)")
        }
        
        session.requestRecordPermission { (success) in
            if(success) {
                print("会话成功")
            }else {
                print("会话失败")
            }
        }
        
        var settings = [String : AnyObject]()
        settings[AVFormatIDKey] = NSNumber(value:kAudioFormatMPEG4AAC)
        settings[AVSampleRateKey] = NSNumber(value:8000)
        settings[AVNumberOfChannelsKey] = NSNumber(value:1)
        
        let url = FileManager.default.urls(for: FileManager.SearchPathDirectory.documentDirectory, in: FileManager.SearchPathDomainMask.userDomainMask).last
        if let _ = url {
            soundURL = url!.appendingPathComponent("abc.aac")
            let audioFormat = AVAudioFormat(settings: settings)
            do {
                recorder = try AVAudioRecorder(url: soundURL, format: audioFormat)
            }catch {
                print("\(error)")
                return
            }
        }else {
            return
        }
        
        recorder?.prepareToRecord()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBOutlet weak var resultLabel: UILabel!
    
    @IBAction func startRecording() {
        print("\(soundURL.absoluteString)")
        recorder?.record()
    }
    
    @IBAction func pause() {
        recorder?.pause()
    }
    
    @IBAction func continueToRecord() {
        recorder?.record()
    }
    
    @IBAction func stopRecording() {
        recorder?.stop()
        print("exit : \(FileManager.default.fileExists(atPath: soundURL.absoluteString))")
    }
    
    @IBAction func speechRecognized() {
        
        print("\(SFSpeechRecognizer.supportedLocales())")
        
        SFSpeechRecognizer.requestAuthorization { (status) in
            switch status {
            case .authorized:
                print("授权")
            case .denied:
                print("拒绝")
            case .notDetermined:
                print("没确定")
            case .restricted:
                print("抵抗")
            }
        }
        
        if SFSpeechRecognizer.authorizationStatus() != .authorized {
            return
        }
        
        let recognizer = SFSpeechRecognizer(locale: Locale(identifier: "zh-CN"))
        let request = SFSpeechURLRecognitionRequest(url: soundURL)
        recognizer?.recognitionTask(with: request, resultHandler: { (result, error) in
            if let _ = error {
                print("\(error!)")
                return
            }
            
            self.resultLabel.text = result?.bestTranscription.formattedString
        })
  
    }
    
}

