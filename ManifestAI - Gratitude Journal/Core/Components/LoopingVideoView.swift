// LoopingVideoView.swift
// Plays a bundled transparent (HEVC + alpha) video on a seamless loop with a
// clear background, so the subject composites directly over the SwiftUI
// content behind it. Used for the Elevate "thinking" owl, which walks and
// ponders over the user's centred entry text.
//
// Mirrors LottieView's teardown-safe UIViewRepresentable structure: the
// player/looper are torn down in dismantleUIView so no AVPlayer keeps
// decoding after the overlay disappears.

import SwiftUI
import UIKit
import AVFoundation

struct LoopingVideoView: UIViewRepresentable {
    let resourceName: String
    var fileExtension: String = "mov"
    /// Pauses/resumes without tearing down (e.g. when the phase leaves .thinking).
    var isPlaying: Bool = true

    func makeUIView(context: Context) -> PlayerContainerView {
        let view = PlayerContainerView()
        view.backgroundColor = .clear
        // Without this the view composites as opaque and the transparent
        // areas of the alpha video read as a black box.
        view.isOpaque = false
        view.playerLayer.videoGravity = .resizeAspect
        view.playerLayer.isOpaque = false
        // Ask the decoder for a BGRA buffer so the alpha channel is preserved.
        view.playerLayer.pixelBufferAttributes = [
            (kCVPixelBufferPixelFormatTypeKey as String): kCVPixelFormatType_32BGRA
        ]

        guard let url = Bundle.main.url(forResource: resourceName, withExtension: fileExtension) else {
            dlog("LoopingVideoView: missing resource \(resourceName).\(fileExtension)")
            return view
        }

        let queue = AVQueuePlayer()
        queue.isMuted = true
        queue.actionAtItemEnd = .advance
        let item = AVPlayerItem(url: url)
        context.coordinator.looper = AVPlayerLooper(player: queue, templateItem: item)
        context.coordinator.player = queue
        view.playerLayer.player = queue
        if isPlaying { queue.play() }
        return view
    }

    func updateUIView(_ uiView: PlayerContainerView, context: Context) {
        guard let player = context.coordinator.player else { return }
        if isPlaying {
            if player.timeControlStatus != .playing { player.play() }
        } else {
            player.pause()
        }
    }

    static func dismantleUIView(_ uiView: PlayerContainerView, coordinator: Coordinator) {
        coordinator.player?.pause()
        coordinator.looper?.disableLooping()
        coordinator.looper = nil
        coordinator.player = nil
        uiView.playerLayer.player = nil
    }

    func makeCoordinator() -> Coordinator { Coordinator() }

    final class Coordinator {
        var player: AVQueuePlayer?
        var looper: AVPlayerLooper?
    }

    /// A UIView whose backing layer is an AVPlayerLayer, so the video renders
    /// (with its alpha) directly without an extra sublayer to keep in sync.
    final class PlayerContainerView: UIView {
        override static var layerClass: AnyClass { AVPlayerLayer.self }
        var playerLayer: AVPlayerLayer { layer as! AVPlayerLayer }
    }
}
