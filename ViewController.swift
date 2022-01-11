//
//  MicrophoneCell.swift
//  MyMusic
//
//  Created by Edo Ljubijankic on 10/11/2021.

import UIKit

class ViewController: UIViewController {

    @IBOutlet var table: UITableView!

    var songs = [Song]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .backgroundColor()
        table.backgroundColor = .clear
        
        configureSongs()
        table.delegate = self
        table.dataSource = self
        table.register(withClass: PlaylistCell.self)
        table.register(withClass: MicrophoneCell.self)
        table.hideExtraSeparators()
    }

    // add songs
    func configureSongs() {
        songs.append(Song(songName: "Mixtape1", trackName: "song1"))
        songs.append(Song(songName: "Mixtape2", trackName: "song2"))
        songs.append(Song(songName: "Mixtape3", trackName: "song3"))
        songs.append(Song(songName: "Mixtape4", trackName: "song4"))
        songs.append(Song(songName: "Mixtape5", trackName: "song5"))
        songs.append(Song(songName: "Mixtape6", trackName: "song6"))
        songs.append(Song(songName: "Mixtape7", trackName: "song7"))
        songs.append(Song(songName: "Mixtape8", trackName: "song8"))
        songs.append(Song(songName: "Mixtape9", trackName: "song9"))
        songs.append(Song(songName: "Mixtape10", trackName: "song10"))
        songs.append(Song(songName: "Mixtape11", trackName: "song11"))
        songs.append(Song(songName: "Mixtape12", trackName: "song12"))
    }
}
 
extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return songs.count + 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withClass: MicrophoneCell.self, for: indexPath)
            cell.setupData(image: UIImage(named: "microphoneLogo"))
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withClass: PlaylistCell.self, for: indexPath)
            let song = songs[indexPath.row - 1]
            cell.setupData(song: song)
            return cell
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let position = indexPath.row
        if position == 0 {
            // microphone
            guard let vc = storyboard?.instantiateViewController(withIdentifier: "microphoneVC") as? MicrophoneViewController else { return }
            present(vc, animated: true)
        } else {
            // present the player
            guard let vc = storyboard?.instantiateViewController(identifier: "playerVC") as? PlayerViewController else { return }
            vc.songs = songs
            vc.position = position
            present(vc, animated: true)
        }
    }
}
