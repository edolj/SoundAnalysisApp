//
//  MicrophoneCell.swift
//  MyMusic
//
//  Created by Edo Ljubijankic on 10/11/2021.

import UIKit

class PlaylistCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        titleLabel.textColor = .textColor()
        titleLabel.text = ""
        backgroundColor = .white
    }
    
    func setupData(song: Song) {
        titleLabel.text = song.songName
        titleLabel.font = UIFont(name: "Helvetica-Bold", size: 18)
        accessoryType = .disclosureIndicator
    }
    
    func setupData(dataText: String) {
        titleLabel.text = dataText
    }
}
