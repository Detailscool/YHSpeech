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

    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("\(NSHomeDirectory())")
        
        let session = AVAudioSession.sharedInstance()
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
        
        var url = FileManager.default().urlsForDirectory(FileManager.SearchPathDirectory.cachesDirectory, inDomains: FileManager.SearchPathDomainMask.userDomainMask).last
        do {
            try url?.appendPathComponent("abc.aac")
            let audioFormat = AVAudioFormat(settings: settings)
            try recorder = AVAudioRecorder(url: url!, format: audioFormat)
        }catch {
            print("catch : \(error)")
        }
        
        
        recorder?.prepareToRecord()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBOutlet weak var resultLabel: UILabel!
    
    @IBAction func startRecording() {
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
        
        var url = FileManager.default().urlsForDirectory(FileManager.SearchPathDirectory.cachesDirectory, inDomains: FileManager.SearchPathDomainMask.userDomainMask).last
        do {
            try url?.appendPathComponent("abc.aac")
            let recognizer = SFSpeechRecognizer(locale: Locale(localeIdentifier: "zh-CN"))
            let request = SFSpeechURLRecognitionRequest(url: url!)
            recognizer?.recognitionTask(with: request, resultHandler: { (result, error) in
                if let _ = error {
                    print("\(error!)")
                    return
                }
                
                self.resultLabel.text = result?.bestTranscription.formattedString
            })
        }catch {
            print("catch : \(error)")
        }
       
        
    }

}

