//
//  SpeechController.swift
//  SpeechTranslate
//
//  Created by NATON on 2017/6/1.
//  Copyright © 2017年 NATON. All rights reserved.
//

import UIKit
import Speech
import AVFoundation

class SpeechController: UIViewController, SFSpeechRecognizerDelegate, AVSpeechSynthesizerDelegate{

    @IBOutlet weak var microphoneButton: UIButton!
    @IBOutlet weak var speechButton: UIButton!
    @IBOutlet weak var translateButton: UIButton!
    @IBOutlet weak var speechLanguageTextView: UITextView!
    @IBOutlet weak var translateLanguageTextview: UITextView!
    
    
    //录音
    private var speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "zh-cn"))!
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    private let av = AVSpeechSynthesizer()
    
    var language = Language()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        microphoneButton.isEnabled = false
        speechRecognizer.delegate = self
        av.delegate = self
        // Do any additional setup after loading the view.
        SFSpeechRecognizer.requestAuthorization { (authStatus) in
            
            var isButtonEnabled = false
            
            switch authStatus {
            case .authorized:
                isButtonEnabled = true
                
            case .denied:
                isButtonEnabled = false
                print("User denied access to speech recognition")
                
            case .restricted:
                isButtonEnabled = false
                print("Speech recognition restricted on this device")
                
            case .notDetermined:
                isButtonEnabled = false
                print("Speech recognition not yet authorized")
            }
            
            OperationQueue.main.addOperation() {
                self.microphoneButton.isEnabled = isButtonEnabled
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    //说话语言被按下
    @IBAction func speechLangugateClick(_ sender: UIButton) {
        self.speechLanguageTextView.text = ""
        let sb = UIStoryboard(name: "Main", bundle:nil)
        
        let vc = sb.instantiateViewController(withIdentifier: "LanguageListController") as! LanguageListController
        //VC为该界面storyboardID，Main.storyboard中选中该界面View，Identifier inspector中修改
        vc.languageStr = sender.currentTitle!
        vc.selectBlock = {(titleStr) in
            sender.setTitle(titleStr, for: .normal)
            let codeStr = self.language.languageCodeByTitle(titleStr: titleStr)
            self.speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: codeStr))!
            self.speechRecognizer.delegate = self
        }
        self.present(vc, animated: true, completion: nil)
    }
    
    //翻译语言被按下
    @IBAction func tranlatorLanguageClick(_ sender: UIButton) {
        let sb = UIStoryboard(name: "Main", bundle:nil)
        
        let vc = sb.instantiateViewController(withIdentifier: "LanguageListController") as! LanguageListController
        vc.languageStr = sender.currentTitle!
        //VC为该界面storyboardID，Main.storyboard中选中该界面View，Identifier inspector中修改
        vc.selectBlock = {(titleStr) in
            sender.setTitle(titleStr, for: .normal)
        }
        self.present(vc, animated: true, completion: nil)
    }

    //翻译按钮被按下
    @IBAction func translateButtonClick(_ sender: UIButton) {
        let transelateStr = speechLanguageTextView.text!
        let appid = "20170522000048682"
        let salt = "858585858"
        let sercet = "QFaDv625Kk7ocCnT8xlv"
        
        let baseUrl = "http://api.fanyi.baidu.com/api/trans/vip/translate"
        let sign = appid+transelateStr+salt+sercet
        
        let speechCode = language.baiduLanguageCodeByTitle(titleStr: speechButton.currentTitle!)
        let tranlateCode = language.baiduLanguageCodeByTitle(titleStr: translateButton.currentTitle!)
        let signMd5 = MD5(sign)
        
        let params = ["q":transelateStr,
                      "from":speechCode,
                      "to":tranlateCode,
                      "appid":appid,
                      "salt":salt,
                      "sign":signMd5]
        
        HttpRequest.instanceRequst.request(method: .Get, usrString: baseUrl, params: params as AnyObject, resultBlock: { (responseObject, error) in
            if error != nil {
                print(error)
                return
            }
            
            guard (responseObject as [String : AnyObject]?) != nil else{
                
                return
            }
            
            let re = responseObject?["trans_result"] as! Array<Dictionary<String,AnyObject>>
            let dst = re[0]
            self.translateLanguageTextview.text = dst["dst"] as! String
        })
    }
    
    //播放按钮被按下
    @IBAction func playButtonClick(_ sender: UIButton) {
        if(sender.isSelected == false) {
            
            if(av.isPaused) {
                //如果暂停则恢复，会从暂停的地方继续
                
                av.continueSpeaking()
                
                sender.isSelected = !sender.isSelected;
                
            }else{
                
                //AVSpeechUtterance*utterance = [[AVSpeechUtterance alloc]initWithString:"];//需要转换的文字
                let str: String = self.translateLanguageTextview.text
                //let utterance = AVSpeechUtterance(string: str)
                let utterance = AVSpeechUtterance.init(string: "Hello")
                
                utterance.rate=0.4;// 设置语速，范围0-1，注意0最慢，1最快；AVSpeechUtteranceMinimumSpeechRate最慢，AVSpeechUtteranceMaximumSpeechRate最快
                
                //AVSpeechSynthesisVoice*voice = [AVSpeechSynthesisVoice voiceWithLanguage:@"en-us"];//设置发音，这是中文普通话
                //let voice = AVSpeechSynthesisVoice(language: "en-us")
                let voice = AVSpeechSynthesisVoice(language: language.languageCodeByTitle(titleStr: translateButton.currentTitle!))
                utterance.voice = voice
                
                //[_av speakUtteran ce:utterance];//开始
                av.speak(utterance)
                
                sender.isSelected = !sender.isSelected
                
            }
            
        }else{
            
            //[av stopSpeakingAtBoundary:AVSpeechBoundaryWord];//感觉效果一样，对应代理>>>取消
            
            //[_av pauseSpeakingAtBoundary:AVSpeechBoundaryWord];//暂停
            av.pauseSpeaking(at: .word)
            
            sender.isSelected = !sender.isSelected;
            
        }

    }
    
    //录音按钮被按下
    @IBAction func recodeButtonClick(_ sender: UIButton) {
        if audioEngine.isRunning {
            audioEngine.stop()
            recognitionRequest?.endAudio()
            sender.isEnabled = false
            sender.setTitle("开始录音", for: .normal)
        } else {
            startRecording()
            sender.setTitle("结束录音", for: .normal)
        }
    }
    
    func startRecording() {
        
        if recognitionTask != nil {  //1
            recognitionTask?.cancel()
            recognitionTask = nil
        }
        
        let audioSession = AVAudioSession.sharedInstance()  //2
        do {
            try audioSession.setCategory(AVAudioSessionCategoryRecord)
            try audioSession.setMode(AVAudioSessionModeMeasurement)
            try audioSession.setActive(true, with: .notifyOthersOnDeactivation)
        } catch {
            print("audioSession properties weren't set because of an error.")
        }
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()  //3
        
        guard let inputNode = audioEngine.inputNode else {
            fatalError("Audio engine has no input node")
        }  //4
        
        guard let recognitionRequest = recognitionRequest else {
            fatalError("Unable to create an SFSpeechAudioBufferRecognitionRequest object")
        } //5
        
        recognitionRequest.shouldReportPartialResults = true  //6
        
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest, resultHandler: { (result, error) in  //7
            
            var isFinal = false  //8
            
            if result != nil {
                
                self.speechLanguageTextView.text = result?.bestTranscription.formattedString  //9
                isFinal = (result?.isFinal)!
            }
            
            if error != nil || isFinal {  //10
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                
                self.recognitionRequest = nil
                self.recognitionTask = nil
                
                self.microphoneButton.isEnabled = true
            }
        })
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)  //11
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, when) in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()  //12
        
        do {
            try audioEngine.start()
        } catch {
            print("audioEngine couldn't start because of an error.")
        }
        
        speechLanguageTextView.text = "Say something, I'm listening!"
        
    }
    
    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        if available {
            microphoneButton.isEnabled = true
        } else {
            microphoneButton.isEnabled = false
        }
    }
    
    func MD5(_ string: String) -> String? {
        let length = Int(CC_MD5_DIGEST_LENGTH)
        var digest = [UInt8](repeating: 0, count: length)
        
        if let d = string.data(using: String.Encoding.utf8) {
            _ = d.withUnsafeBytes { (body: UnsafePointer<UInt8>) in
                CC_MD5(body, CC_LONG(d.count), &digest)
            }
        }
        
        return (0..<length).reduce("") {
            $0 + String(format: "%02x", digest[$1])
        }
    }
    
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
        print("Speaker class started")
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        print("Speaker class finished")
    }
}
