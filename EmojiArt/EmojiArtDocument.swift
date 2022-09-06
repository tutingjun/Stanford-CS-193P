//
//  EmojiArtDocument.swift
//  EmojiArt
//
//  Created by 涂庭鋆 on 2022/9/5.
//

import SwiftUI

class EmojiArtDocument: ObservableObject {
    @Published private(set) var emojiArt: EmojiArtModel{
        didSet{
            Task{
                if emojiArt.background != oldValue.background {
                    await fetchBackgroundImageData()
                }
            }
        }
    }
    
    init(){
        emojiArt = EmojiArtModel()
        emojiArt.addEmoji("🏀", at: (-200, -100), size: 80)
        emojiArt.addEmoji("🐼", at: (50, 100), size: 40)
    }
    
    var emojis: [EmojiArtModel.Emoji]{ emojiArt.emojis }
    var background: EmojiArtModel.Background{ emojiArt.background }
    
    @Published var backgroundImage: UIImage? = nil
    @Published var backgroundImageFetchStatus = BackgroundImageFetchStatus.idle
    
    enum BackgroundImageFetchStatus {
        case idle
        case fetching
    }
    
    private func fetchBackgroundImageData() async{
        switch emojiArt.background{
        case .url(let url):
            print(url)
            let data: Data?
            await MainActor.run {
                backgroundImageFetchStatus = .fetching
            }
            do{
                (data, _) = try await URLSession.shared.data(from: url)
            } catch {
                data = nil
            }
            if emojiArt.background == EmojiArtModel.Background.url(url){
                await MainActor.run {
                    backgroundImageFetchStatus = .idle
                    if data != nil{
                        backgroundImage = UIImage(data: data!)
                    }
                }
            }
//            DispatchQueue.global(qos: .userInitiated).async {
//                let imageData = try? Data(contentsOf: url)
//                DispatchQueue.main.async { [weak self] in
//                    if self?.emojiArt.background == EmojiArtModel.Background.url(url){
//                        self?.backgroundImageFetchStatus = .idle
//                        if imageData != nil{
//                            self?.backgroundImage = UIImage(data: imageData!)
//                        }
//                    }
//                }
//            }
            
        case .imageData(let data):
            await MainActor.run {
                backgroundImage = UIImage(data: data)
            }
        case .blank:
            break
        }
    }
    //MARK: - Intents
    
    func setBackground(_ background: EmojiArtModel.Background){
        emojiArt.background = background
    }
    
    func addEmoji(_ emoji: String, at location: (x:Int, y:Int), size: CGFloat){
        emojiArt.addEmoji(emoji, at: location, size: Int(size))
    }
    
    func moveEmoji(_ emoji: EmojiArtModel.Emoji, by offset: CGSize){
        if let index = emojiArt.emojis.index(matching: emoji){
            emojiArt.emojis[index].x += Int(offset.width)
            emojiArt.emojis[index].y += Int(offset.height)
        }
    }
    
    func scaleEmoji(_ emoji: EmojiArtModel.Emoji, by scale: CGFloat){
        if let index = emojiArt.emojis.index(matching: emoji){
            emojiArt.emojis[index].size = Int( (CGFloat(emojiArt.emojis[index].size) * scale).rounded(.toNearestOrAwayFromZero) )
        }
    }
    
    func removeEmoji(_ emoji: EmojiArtModel.Emoji){
        if let index = emojiArt.emojis.index(matching: emoji){
            emojiArt.emojis.remove(at: index)
        }
    }
}
