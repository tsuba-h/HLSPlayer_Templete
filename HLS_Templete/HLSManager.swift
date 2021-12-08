//
//  HLSManager.swift
//  HLS_Templete
//
//  Created by hattori tsubasa on 2021/12/01.
//

import Foundation
import AVFoundation
import MediaPlayer


protocol HLSManagerDelegate: AnyObject {
    /// 再生可能状態
    func readyToPlay()
    /// トータル再生時間
    func totalTime(time: Float)
    /// 現在時間更新
    func updateTime(time: Float)
    /// Control Centerのシークバーを動かした時にアプリ内のスライダーの値を更新するためのもの
    func changePlaybackPosition(time: Float)
}


final class HLSManager {

    static let shared = HLSManager()

    private var playerObservation: NSKeyValueObservation?
    private var playerItem: AVPlayerItem?
    private var avPlayerLayer: AVPlayerLayer?
    private var timeObserverToken: Any?

    @objc var avPlayer: AVPlayer?

    weak var delegate: HLSManagerDelegate?


    /// avplayerのセット、状態監視とlayerを返す
    /// - Parameter url: url
    /// - Returns: AVPlayerLayer
    func setupPlayer(url: String, shouldAutoPlay: Bool = true) -> AVPlayerLayer? {
        avPlayer = AVPlayer()

        guard let url = URL(string: url),
              let avPlayer = self.avPlayer else {return nil}

        playerItem = AVPlayerItem(url: url)
        avPlayer.replaceCurrentItem(with: playerItem)

        avPlayerLayer = AVPlayerLayer(player: avPlayer)

        if shouldAutoPlay {
            play()
        }

        /// playerの状態をKVOで監視
        self.playerObservation = playerItem!.observe(\.status, options: [.new], changeHandler: {[weak self] (playerItem, value) in
            guard let self = self else {return}
            switch playerItem.status {
            case .readyToPlay:
                print("ready To Play")

                self.delegate?.readyToPlay()
                self.addPeriodicTimeObserver()
                self.playerObservation = nil

                if let totalTime = avPlayer.currentItem?.asset.duration {
                    let seconds = CMTimeGetSeconds(totalTime) as Double
                    self.delegate?.totalTime(time: Float(seconds))
                }
            case .failed:
                break
            case .unknown:
                print("unknown")
            @unknown default:
                fatalError()
            }
        })

        return avPlayerLayer
    }


    /// 再生
    func play() {
        avPlayer?.play()
    }


    /// 一時停止
    func pause() {
        avPlayer?.pause()
    }

    /// 再生終了
    func stop() {
        avPlayer?.pause()
        avPlayer = nil
        avPlayerLayer = nil
        removePeriodicTimeObserver()
    }

    /// シークバーを動かした時の挙動
    /// - Parameter value: 時間(シークバーを動かした時の値)
    func timeJump(value: Float, shouldAutoPlay: Bool = true) {
        let time = CMTime(value: Int64(value), timescale: 1)
        avPlayer?.seek(to: time, toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero)

        if shouldAutoPlay {
            avPlayer?.play()
        }
    }
}

extension HLSManager {

    /// playerが現在再生している時間 1秒ごとにplayreの再生時間を監視
    /// https://developer.apple.com/documentation/avfoundation/avplayer/1385829-addperiodictimeobserverforinterv?language=objc
    private func addPeriodicTimeObserver() {
        let timeScale = CMTimeScale(NSEC_PER_SEC)
        let time = CMTime(seconds: 1, preferredTimescale: timeScale)

        timeObserverToken = avPlayer?.addPeriodicTimeObserver(forInterval: time, queue: .main) { [weak self] time in
            guard let self = self else {return}

            let seconds = CMTimeGetSeconds(time)
            let nowTime = floor(Float(seconds))

            self.delegate?.updateTime(time: nowTime)
        }
    }

    /// 登録されたオブザーバーを削除
    /// https://developer.apple.com/documentation/avfoundation/avplayer/1387552-removetimeobserver?language=objc
    private func removePeriodicTimeObserver() {
        guard let timeObserverToken = timeObserverToken else {return}
        avPlayer?.removeTimeObserver(timeObserverToken)
        self.timeObserverToken = nil
    }

}

extension HLSManager {
    /// フォアグラウンドになった時
    func enterForeground() {
        avPlayerLayer?.player = avPlayer
    }
    /// バックグラウンドになった時
    func enterBackground() {
        avPlayerLayer?.player = nil
    }
}

extension HLSManager {

    /// Control Center
    /// https://developer.apple.com/documentation/mediaplayer/mpremotecommandcenter
    func addRemoteCommandEvent() {
        let commandCenter = MPRemoteCommandCenter.shared()

        /// ポーズボタン
        commandCenter.pauseCommand.addTarget(handler: {[weak self] commandEvent -> MPRemoteCommandHandlerStatus in
            self?.pause()
            return MPRemoteCommandHandlerStatus.success
        })

        /// 再生ボタン
        commandCenter.playCommand.addTarget(handler: {[weak self] commandEvent -> MPRemoteCommandHandlerStatus in
            self?.play()
            return MPRemoteCommandHandlerStatus.success
        })

        /// シークバー
        commandCenter.changePlaybackPositionCommand.addTarget{ [weak self] commandEvent -> MPRemoteCommandHandlerStatus in
            self?.remoteChangePlaybackPosition(commandEvent)
            return MPRemoteCommandHandlerStatus.success
        }
    }

    /// Control Centerでシークバー（プログレスバー）の位置を変更した時の処理
    private func remoteChangePlaybackPosition(_ event: MPRemoteCommandEvent) {
        if let evt = event as? MPChangePlaybackPositionCommandEvent {
            let time: Float  = floor(Float(evt.positionTime))
            timeJump(value: time)
            delegate?.changePlaybackPosition(time: time)
        }
    }


    /// Control Centerでアイテムの情報表示
    /// 現在再生中のアイテムをControl Centerに表示
    /*
     MPNowPlayingInfoCenterの更新(MPNowPlayingInfoPropertyElapsedPlaybackTime(経過秒数))は頻繁にしない
     そのため基本的にはバックグラウンド、通知センター・コントロールセンター表示になったタイミングで更新するのが良さそう
     またControl Center内での再生・停止などでも更新する必要がある
    */
    func updatePlaying(title: String) {
        guard let avPlayer = self.avPlayer else {return}
        // Define Now Playing Info
        var nowPlayingInfo = [String : Any]()

        nowPlayingInfo[MPMediaItemPropertyTitle] = title

        switch avPlayer.timeControlStatus {
        case .playing:
            nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = 1
        case .paused:
            nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = 0
        default: break
        }

        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = floor(CMTimeGetSeconds(avPlayer.currentTime()))
        if let duration = avPlayer.currentItem?.duration {
            nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = CMTimeGetSeconds(duration)
        }

        // Set the metadata
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
}


extension Float {

    enum TimeDisplay {
        case hour
        case minutes
        case seconds
    }

    /// 00:00:00の時間表示
    /// - Parameter timeDisplay: どこまで時間を表示させるか
    /// - Returns: String
    func toDurationString(timeDisplay: TimeDisplay) -> String {
        let t = Int64(self)
        let h = t / 60 / 60
        let m = t / 60 % 60
        let s = t % 60

        switch timeDisplay {
        case .hour:
            return String(format: "%02d:%02d:%02d", h, m, s)
        case .minutes:
            return String(format: "%02d:%02d", m, s)
        case .seconds:
            return String(format: "%02d", s)
        }
    }
}
