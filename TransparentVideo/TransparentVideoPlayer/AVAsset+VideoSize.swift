//
//  AVAsset+VideoSize.swift
//  MyTransparentVideoExample
//
//  Created by Quentin Fasquel on 22/03/2020.
//  Copyright © 2020 Quentin Fasquel. All rights reserved.
//

import AVFoundation

extension AVAsset {
    var videoSize: CGSize {
        let videoTracks = tracks(withMediaType: AVMediaType.video)
		return videoTracks.first?.naturalSize ?? .zero
	}
}
