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
        settings[AVLinearPCMBitDepthKey] = NSNumber(value: 16)
        settings[AVEncoderAudioQualityKey] = NSNumber(value: AVAudioQuality.high.rawValue)
        
        let url = FileManager.default.urls(for: FileManager.SearchPathDirectory.documentDirectory, in: FileManager.SearchPathDomainMask.userDomainMask) .last
        if let _ = url {
            soundURL = url!.appendingPathComponent("abc.aac")
            let audioFormat = AVAudioFormat(settings: settings)
            do {
                recorder = try AVAudioRecorder(url: soundURL, format: audioFormat)
                recorder?.delegate = self
            }catch {
                print("\(error)")
                return
            }
        }else {
            return
        }
        
        print("Begin Record")
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
        
        var string : String = String()
        
        let recognizer = SFSpeechRecognizer(locale: Locale(identifier: "zh-CN"))
        let request = SFSpeechURLRecognitionRequest(url: soundURL)
        recognizer?.recognitionTask(with: request, resultHandler: { (result, error) in
            if let _ = error {
                print("\(error!)")
                return
            }
            
            string += (result?.bestTranscription.formattedString)!
            self.resultLabel.text = string
        })
  
    }
    
}

extension ViewController : AVAudioRecorderDelegate{
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        print("audioRecorderDidFinishRecording : \(flag)")
        print("exists : \(FileManager.default.fileExists(atPath: soundURL.absoluteString))")
    }
    
    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        print("audioRecorderDidFinishRecording : \(error)")
    }
}

