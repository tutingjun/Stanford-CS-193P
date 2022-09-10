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
            scheduleAutoSave()
            Task{
                if emojiArt.background != oldValue.background {
                    await fetchBackgroundImageData()
                }
            }
        }
    }
    
    private var autosaveTimer: Timer?
    
    private func scheduleAutoSave(){
        autosaveTimer?.invalidate()
        autosaveTimer = Timer.scheduledTimer(withTimeInterval: Autosave.coalescingInterval, repeats: false) { _ in
            self.autoSave()
        }
    }
    private struct Autosave {
        static let filename = "Autosave.emojiart"
        static var url: URL? {
            let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
            return documentDirectory?.appendingPathComponent(filename)
        }
        static let coalescingInterval = 5.0
    }
    
    private func autoSave() {
        if let url = Autosave.url {
            save(to: url)
        }
    }
    
    private func save(to url: URL){
        let thisfunc = "\(String(describing: self)).\(#function)"
        do {
            let data: Data = try emojiArt.json()
            print("\(thisfunc) json = \(String(data: data, encoding: .utf8) ?? "nil")")
            try data.write(to: url)
            print("\(thisfunc) success!")
        } catch let encodingError where encodingError is EncodingError {
            print("\(thisfunc) cannot encode EmojiArt as JSON because \(encodingError)")
        }
        catch {
            print("\(thisfunc) error = \(error)")
        }
    }
    
    init(){
        if let url = Autosave.url, let autosavedEmojiArt = try? EmojiArtModel(url: url) {
            emojiArt = autosavedEmojiArt
            Task{
                await fetchBackgroundImageData()
            }
        } else {
            emojiArt = EmojiArtModel()
        }
    }
    
    var emojis: [EmojiArtModel.Emoji]{ emojiArt.emojis }
    var background: EmojiArtModel.Background{ emojiArt.background }
    
    @Published var backgroundImage: UIImage? = nil
    @Published var backgroundImageFetchStatus = BackgroundImageFetchStatus.idle
    
    enum BackgroundImageFetchStatus: Equatable {
        case idle
        case fetching
        case failed(URL)
    }
    
    private func fetchBackgroundImageData() async{
        switch emojiArt.background{
        case .url(let url):
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
                    if backgroundImage == nil {
                        backgroundImageFetchStatus = .failed(url)
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
