//
//  ViewController.swift
//  Music App
//
//  Created by 簡吟真 on 2021/4/28.
//

import UIKit
import AVFoundation
import MediaPlayer //多媒體播放



class ViewController: UIViewController{


    @IBOutlet weak var albumImage: UIImageView! //專輯照片
    @IBOutlet weak var songName: UILabel!
    @IBOutlet weak var singerName: UILabel!
    @IBOutlet weak var songSlider: UISlider!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var volumeSlider: UISlider!
    
    
    //播放
    let PlayItem = UIImage(systemName:"play.fill")
    //暫停
    let PauseItem = UIImage(systemName:"pause.fill")
    
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var nowTime: UILabel!
    @IBOutlet weak var allTime: UILabel!
    
    //新增SongListSwift檔案
    //播放清單
    var PlayList : [SongList]! = [SongList]()
    var index = 0
    var CurrectSong:SongList?
    //音樂播放
    let player = AVQueuePlayer()
    //音樂循環播放
    var looper: AVPlayerLooper?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        songSlider.setThumbImage(UIImage(named: "sliderImage"), for: .normal)
        volumeSlider.setThumbImage(UIImage(named: "sliderImage1"), for: .normal)
        
        
        
   
        //  音樂資料庫
        PlayList.append(SongList(Name:"Meant To Be",Singer:"Bebe Rexha(ft.Florida)",AlbumImage:"Meant To Be"))
        PlayList.append(SongList(Name:"Beautiful Mistakes", Singer:"Maroon5", AlbumImage:"Beautiful Mistakes"))
        PlayList.append(SongList(Name:"In The Name Of Love", Singer:"Martin Garrix & Bebe Rexha", AlbumImage:"In The Name Of Love"))
        PlayList.append(SongList(Name:"So Far Away", Singer:"Martin Garrix & David Guetta", AlbumImage:"So Far Away"))
        PlayList.append(SongList(Name:"Used To Love", Singer:"Martin Garrix & Dean Lewis", AlbumImage:"Used To Love"))
        PlayList.append(SongList(Name:"Scared To Be Lonely", Singer:"Martin Garrix & Dua Lipa", AlbumImage:"Scared To Be Lonely"))
        PlayList.append(SongList(Name:"High On Lif", Singer:"Martin Garrix & Bonn", AlbumImage:"High On Lif"))
        PlayList.append(SongList(Name:"No Sleep", Singer:"Martin Garrix & Bonn", AlbumImage:"No Sleep"))
        PlayList.append(SongList(Name:"There For You", Singer:"Martin Garrix & Troye Sivan", AlbumImage:"There For You"))
        PlayList.append(SongList(Name:"Travesuras(Remix)", Singer:"Nicky Jam", AlbumImage:"Travesuras(Remix)"))
        PlayList.append(SongList(Name:"Way Back Home", Singer:"SHAUN & Conor Maynard", AlbumImage:"Way Back Home"))
        PlayList.append(SongList(Name:"Young", Singer:"The Chainsmokers", AlbumImage:"Young"))
            
        
        //  播放音樂
        PlaySong()
        //執行現在播放的秒數
        CurrentTime()
  
        
        //  播完後，繼續播下一首
        NotificationCenter.default.addObserver(forName: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil, queue: .main) { (_) in
         
            self.index = self.index + 1
            self.index %= self.PlayList.count
            self.PlaySong()
    }


}

    //播放音樂
    func PlaySong()
    {
        if index < PlayList.count
        {
            if index  < 0
            {
                index = PlayList.count - 1
       
            }
            let AlbumObj = PlayList[index]
            CurrectSong = AlbumObj
            if AlbumObj != nil
            {
                let SongName:String = AlbumObj.Name
                let SingerName:String = AlbumObj.Singer
                let ImageName :String = AlbumObj.AlbumImage
                
                //  設定歌手歌曲Label顯示
                self.songName.text = SongName
                self.singerName.text = SingerName
                
                //  設定Image圖片顯示
                albumImage.image = UIImage(named: ImageName)
                
                //  載入歌曲檔案
                let FileUrl = Bundle.main.url(forResource: SongName, withExtension: "mp3")!
                let PlayerItem = AVPlayerItem(url: FileUrl)
               player.replaceCurrentItem(with: PlayerItem)
                player.volume = 0.5
               looper = AVPlayerLooper(player: player, templateItem: PlayerItem)
                
                
                //總時間顯示
                let duration = CMTimeGetSeconds(PlayerItem.asset.duration)
                allTime.text = formatConversion(time: duration)
                
                
                //  重置slider和播放軌道
                songSlider.setValue(Float(0), animated: true)
                let TargetTime:CMTime = CMTimeMake(value: Int64(0), timescale: 1)
                player.seek(to: TargetTime)
                
                
                //  播放
                player.play()
                
                //  更新slider時間
               let Duration :CMTime = PlayerItem.asset.duration
              let Seconds:Float64 = CMTimeGetSeconds(Duration)
                songSlider.minimumValue = 0
                songSlider.maximumValue = Float(Seconds)
                
                
                //  設定播放按鈕圖案
                playButton.setImage(PauseItem, for: UIControl.State.normal)
                
                
                
                }
        }else{
             index = 0
            }
            
            
        
    }
   
    //  播放/暫停
    @IBAction func PlayActionButton(_ sender: UIButton)
    {
            if player.rate == 0
            {
                player.play()
                playButton.setImage(PauseItem, for: UIControl.State.normal)
            }
         else
            {
                
                    player.pause()
                    playButton.setImage(PlayItem, for: UIControl.State.normal)
                   
                }
                
            
        
    }
    //播放下一首
    @IBAction func NextSongAction(_ sender: UIButton)
    {
        index += 1
        print(index)
        print(PlayList.count)
        index %= PlayList.count
        print(index)
        PlaySong()
        print(index)
      
    }
    
    //播放前一首
    @IBAction func BackButtonAction(_ sender: UIButton)
    {
        index -= 1
        print(index)
        print(PlayList.count)
        index %= PlayList.count
        print(index)
        PlaySong()
        print(index)
      
          
        
    }


    

    //  拖曳slider進度，要設定player播放軌道
    @IBAction func SongSliderAction(_ sender: UISlider)
    {  //  slider移動的位置
        let Seconds : Int64 = Int64(songSlider.value)
        //  計算秒數
        let TargetTime :CMTime = CMTimeMake(value: Seconds, timescale: 1)
        //  設定player播放進度
        player.seek(to: TargetTime)
        
    
        //  如果player暫停，則繼續播放
        if player.rate == 0
        {
            player.play()
           playButton.setImage(PauseItem, for: UIControl.State.normal)
        }
    
        
    }
    //現在播放的秒數
    func CurrentTime() {
          player.addPeriodicTimeObserver(forInterval: CMTimeMake(value: 1, timescale: 1), queue: DispatchQueue.main, using: { (CMTime) in
                  if self.player.currentItem?.status == .readyToPlay {
                      let currentTime = CMTimeGetSeconds(self.player.currentTime())
                    //讓Slider跟著連動
                    self.songSlider.value = Float(currentTime)
                    //文字更改
                    self.nowTime.text = self.formatConversion(time: currentTime)
                    self.allTime.text = "\(self.formatConversion(time: Float64(self.songSlider.maximumValue - self.songSlider.value)))"
                  }
              })
          }
    
    //把秒數轉換成幾分幾秒的格式，最後輸出成一個 String 直接顯示在 Label 上
    func formatConversion(time:Float64) -> String {
        let songLength = Int(time)
        let minutes = Int(songLength / 60) //為分鐘數
        let seconds = Int(songLength % 60) //為秒數
        var time = ""
        if minutes < 10 {
          time = "0\(minutes):"
        } else {
          time = "\(minutes)"
        }
        if seconds < 10 {
          time += "0\(seconds)"
        } else {
          time += "\(seconds)"
        }
        return time
    }
    
    //音量slider
    @IBAction func changeVolume(_ sender: UISlider) {
        player.volume = sender.value
    }
    
}
    
    
