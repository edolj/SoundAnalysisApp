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

class PlayerViewController: UIViewController {

    public var position: Int = 0
    public var songs: [Song] = []
    public var songType: String = "mp3"

    @IBOutlet var holder: UIView!
    @IBOutlet weak var songNameLabel: UILabel!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var table: UITableView!
    
    var player: AVAudioPlayer?
    var inputFormat: AVAudioFormat!
    var streamAnalyzer: SNAudioStreamAnalyzer!
    let analysisQueue = DispatchQueue(label: "com.asndigital.MyMusic")
    var request: SNClassifySoundRequest?
    var results: [(label: String, startTime: String)] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        songNameLabel.textColor = .textColor()
        songNameLabel.font = UIFont(name: "Helvetica-Bold", size: 18)
        songNameLabel.textAlignment = .center
        songNameLabel.numberOfLines = 0
        
        slider.addTarget(self, action: #selector(didSlideSlider(_:)), for: .valueChanged)
        
        playPauseButton.setTitle("", for: .normal)
        backButton.setTitle("", for: .normal)
        nextButton.setTitle("", for: .normal)
        
        playPauseButton.setImage(UIImage(named: "pauseButton"), for: .normal)
        backButton.setImage(UIImage(named: "backButton"), for: .normal)
        nextButton.setImage(UIImage(named: "nextButton"), for: .normal)
        
        playPauseButton.addTarget(self, action: #selector(didTapPlayPauseButton), for: .touchUpInside)
        backButton.addTarget(self, action: #selector(didTapBackButton), for: .touchUpInside)
        nextButton.addTarget(self, action: #selector(didTapNextButton), for: .touchUpInside)
        
        view.backgroundColor = .backgroundColor()
        holder.backgroundColor = .backgroundColor()
        
        table.delegate = self
        table.dataSource = self
        table.backgroundColor = .clear
        table.register(withClass: PlaylistCell.self)
        table.hideExtraSeparators()
        
        resetPlayer()
    }
    
    func startProcessing() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.startSoundClassification()
        }
    }
    
    func startSoundClassification() {
        let song = songs[position-1]
        do {
            // Use a default model configuration.
            let defaultConfig = MLModelConfiguration()
            
            // Create an instance of the sound classifier's wrapper class.
            let soundClassifier = try SoundClassifier(configuration: defaultConfig)
            
            // Create a classify sound request that uses the custom sound classifier.
            request = try SNClassifySoundRequest(mlModel: soundClassifier.model)
            
            guard let url = Bundle.main.url(forResource: song.trackName, withExtension: songType) else {
                print("Wrong url")
                return
            }
            //print(url)
            let audioFileAnalyzer = createAnalyzer(audioFileURL: url)!
            // Prepare a new request for the trained model.
            try audioFileAnalyzer.add(request!, withObserver: self)
            
            DispatchQueue.global(qos: .userInitiated).async {
                // Analyze the audio data.
                audioFileAnalyzer.analyze()
            }
            
        } catch let err {
            print(err)
        }
    }
    
    func createAnalyzer(audioFileURL: URL) -> SNAudioFileAnalyzer? {
        return try? SNAudioFileAnalyzer(url: audioFileURL)
    }

    func configurePlayer() {
        let song = songs[position-1]

        guard let urlString = Bundle.main.path(forResource: song.trackName, ofType: songType) else {
            print("Track not found")
            return
        }

        do {
            try AVAudioSession.sharedInstance().setMode(.default)
            try AVAudioSession.sharedInstance().setActive(true, options: .notifyOthersOnDeactivation)

            player = try AVAudioPlayer(contentsOf: URL(string: urlString)!)

            guard let player = player else {
                print("Player is nil")
                return
            }
            
            player.volume = 0.5
            player.play()
        } catch {
            print("Error occurred")
        }
    }
    
    // set up user interface elements
    func setupViews() {
        songNameLabel.text = songs[position-1].songName
        slider.value = 0.5
        playPauseButton.setImage(UIImage(named: "pauseButton"), for: .normal)
    }

    @objc func didTapPlayPauseButton() {
        if player?.isPlaying == true {
            // pause
            player?.pause()
            // show play button
            playPauseButton.setImage(UIImage(named: "playButton"), for: .normal)
        } else {
            // play
            player?.play()
            // show pause button
            playPauseButton.setImage(UIImage(named: "pauseButton"), for: .normal)
        }
    }
    
    @objc func didTapBackButton() {
        if position > 1 {
            position = position - 1
            player?.stop()
            resetPlayer()
        }
    }
    
    @objc func didTapNextButton() {
        if position < songs.count {
            position = position + 1
            player?.stop()
            resetPlayer()
        }
    }

    func resetPlayer() {
        setupViews()
        configurePlayer()
        clearTable()
        startProcessing()
    }
    
    func clearTable() {
        results = []
        table.reloadData()
    }
    
    @objc func didSlideSlider(_ slider: UISlider) {
        let value = slider.value
        player?.volume = value
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        player?.stop()
    }

    deinit {
        print("Deinit player view controller!")
    }
}

extension PlayerViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withClass: PlaylistCell.self, for: indexPath)
        let result = results[indexPath.row]
        let label = convert(id: result.label)
        cell.setupData(dataText: "\(result.startTime)s: \(label)")
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

extension PlayerViewController: SNResultsObserving {
    // Notifies the observer when a request generates a prediction.
    func request(_ request: SNRequest, didProduce result: SNResult) {
        // Downcast the result to a classification result.
        guard let result = result as? SNClassificationResult else  { return }
        
        // Get the prediction with the highest confidence.
        guard let classification = result.classifications.first else { return }
        
        // Get the starting time.
        let timeInSeconds = result.timeRange.start.seconds
        
        // Convert the time to a human-readable string.
        let formattedTime = String(format: "%.2f", timeInSeconds)
//        print("Analysis result for audio at time: \(formattedTime)")
//
//        // Convert the confidence to a percentage string.
//        let percent = classification.confidence * 100.0
//        let percentString = String(format: "%.2f%%", percent)
//
//        // Print the classification's name (label) with its confidence.
//        print("\(classification.identifier): \(percentString) confidence.\n")
        
        // save information
//        var temp = [(label: String, confidence: Float)]()
//        let sorted = result.classifications.sorted { (first, second) -> Bool in
//            return first.confidence > second.confidence
//        }
//        for classification in sorted {
            let confidence = classification.confidence * 100
//            print(confidence)
            if confidence > 50, timeInSeconds > 0 {
                results.append((label: classification.identifier, startTime: formattedTime))
            }
//        }
//        results = temp
    }

    // Notifies the observer when a request generates an error.
    func request(_ request: SNRequest, didFailWithError error: Error) {
        print("The analysis failed: \(error.localizedDescription)")
    }

    // Notifies the observer when a request is complete.
    func requestDidComplete(_ request: SNRequest) {
        print("The request completed successfully!")
        
        DispatchQueue.main.async {
            self.table.reloadData()
        }
    }
}
