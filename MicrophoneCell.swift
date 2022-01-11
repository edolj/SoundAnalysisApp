//
//  MicrophoneCell.swift
//  MyMusic
//
//  Created by Edo Ljubijankic on 10/11/2021.

import UIKit

class MicrophoneCell: UITableViewCell {
    
    @IBOutlet weak var backgroundColorView: UIView!
    @IBOutlet weak var microphoneImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        backgroundColor = .clear
        backgroundColorView.backgroundColor = .red
        backgroundColorView.layer.cornerRadius = 50
    }
    
    func setupData(image: UIImage?) {
        microphoneImageView.image = image
        microphoneImageView.contentMode = .scaleAspectFit
    }
}
