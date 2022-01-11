//
//  MicrophoneViewController.swift
//  MyMusic
//
//  Created by Edo Ljubijankic on 12/11/2021.
//  Copyright © 2021 ASN GROUP LLC. All rights reserved.
//

import AVFoundation
import AVKit
import SoundAnalysis
import UIKit

class MicrophoneViewController: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var tableLabel: UILabel!
    @IBOutlet weak var table: UITableView!
    
    private let audioEngine = AVAudioEngine()
    var inputFormat: AVAudioFormat!
    var streamAnalyzer: SNAudioStreamAnalyzer!
    let analysisQueue = DispatchQueue(label: "com.asndigital.MyMusic")
    var request: SNClassifySoundRequest?
    var results = [(label: String, confidence: Float)]() {
        didSet {
            DispatchQueue.main.async { [weak self] in
                self?.table.reloadData()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleLabel.text = "Recording..."
        titleLabel.textColor = .textColor()
        titleLabel.font = UIFont(name: "Helvetica-Bold", size: 18)
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        
        tableLabel.text = "Detected instruments (and confidence %)"
        tableLabel.textColor = .textColor()
        tableLabel.font = UIFont(name: "Helvetica", size: 18)
        tableLabel.textAlignment = .left
        tableLabel.numberOfLines = 0
        view.backgroundColor = .backgroundColor()
        
        table.delegate = self
        table.dataSource = self
        table.backgroundColor = .clear
        table.register(withClass: PlaylistCell.self)
        table.hideExtraSeparators()
        
        startProcessing()
    }
    
    func startProcessing() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.prepareForRecording()
            self.createClassificationRequest()
        }
    }
    
    private func prepareForRecording() {
        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        streamAnalyzer = SNAudioStreamAnalyzer(format: recordingFormat)
        inputNode.installTap(onBus: 0, bufferSize: 8192, format: recordingFormat) {
            (buffer, time) in
            self.analysisQueue.async {
                self.streamAnalyzer.analyze(buffer,
                                            atAudioFramePosition: time.sampleTime)
            }
        }
        startAudioEngine()
    }
    
    private func createClassificationRequest() {
        do {
            let defaultConfig = MLModelConfiguration()
            let soundClassifier = try SoundClassifier(configuration: defaultConfig)
            let request = try SNClassifySoundRequest(mlModel: soundClassifier.model)
            try streamAnalyzer.add(request, withObserver: self)
        } catch {
            fatalError("Error adding the classification request")
        }
    }
    
    private func startAudioEngine() {
        audioEngine.prepare()
        do {
            try audioEngine.start()
        } catch {
            showAudioError()
        }
    }
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
    func showAudioError() {
        let errorTitle = "Audio Error"
        let errorMessage = "Recording is not possible at the moment."
        self.showAlert(title: errorTitle, message: errorMessage)
    }
    
    deinit {
        audioEngine.stop()
        streamAnalyzer.removeAllRequests()
        print("Deinit microphone view controller!")
    }
}

extension MicrophoneViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withClass: PlaylistCell.self, for: indexPath)
        let result = results[indexPath.row]
        let label = convert(id: result.label)
        //cell.setupData(dataText: "\(label): \(result.confidence)")
        cell.setupData(dataText: "\(label): \(String(format: "%.3f%%", result.confidence))")
        return cell
    }
    
    private func convert(id: String) -> String {
        let mapping = ["cel" : "Drum",
                       "cla" : "Clarinet",
                       "flu" : "Flute",
                       "gac" : "Acoustic guitar",
                       "gel" : "🎸 Electric guitar",
                       "org" : "Organ",
                       "pia" : "🎹 Piano",
                       "sax" : "🎷 Saxophone",
                       "tru" : "🎺 Trumpet",
                       "vio" : "🎻 Violin"]
        return mapping[id] ?? id
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension MicrophoneViewController: SNResultsObserving {
    func request(_ request: SNRequest, didProduce result: SNResult) {
        guard let result = result as? SNClassificationResult else { return }
        
        var temp = [(label: String, confidence: Float)]()
        let sorted = result.classifications.sorted { (first, second) -> Bool in
            return first.confidence > second.confidence
        }
        for classification in sorted {
            let confidence = classification.confidence * 100
            if confidence > 10 {
                temp.append((label: classification.identifier, confidence: Float(confidence)))
            }
        }
        results = temp
    }
    
    // Notifies the observer when a request generates an error.
    func request(_ request: SNRequest, didFailWithError error: Error) {
        print("The analysis failed: \(error.localizedDescription)")
    }

    // Notifies the observer when a request is complete.
    func requestDidComplete(_ request: SNRequest) {
        print("The request completed successfully!")
    }
}
