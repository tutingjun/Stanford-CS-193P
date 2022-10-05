//
//  EmojiArtDocument.swift
//  Shared
//
//  Created by 涂庭鋆 on 2022/9/20.
//

import SwiftUI
import Combine
import UniformTypeIdentifiers

extension UTType{
    static let emojiart = UTType(exportedAs: "edu.carleton.petertu.EmojiArt")
}

class EmojiArtDocument: ReferenceFileDocument {
    static var readableContentTypes = [UTType.emojiart]
    static var writableContentTypes = [UTType.emojiart]
    
    required init(configuration: ReadConfiguration) throws {
        if let data = configuration.file.regularFileContents {
            emojiArt = try EmojiArtModel(json: data)
            fetchBackgroundImageData()
        } else {
            throw CocoaError(.fileReadCorruptFile)
        }
    }
    
    func snapshot(contentType: UTType) throws -> Data {
        try emojiArt.json()
    }
    
    func fileWrapper(snapshot: Data, configuration: WriteConfiguration) throws -> FileWrapper {
        FileWrapper(regularFileWithContents: snapshot)
    }
    
    @Published private(set) var emojiArt: EmojiArtModel{
        didSet{
            if emojiArt.background != oldValue.background {
                fetchBackgroundImageData()
            }
        }
    }
    
    
    init(){
        emojiArt = EmojiArtModel()
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
    
    private var backgroundImageFetchCancellable: AnyCancellable?
    
    private func fetchBackgroundImageData(){
        switch emojiArt.background{
        case .url(let url):
//            let data: Data?
            backgroundImageFetchStatus = .fetching
            backgroundImageFetchCancellable?.cancel()
            let session = URLSession.shared
            let publisher = session.dataTaskPublisher(for: url)
                .map{ (data, urlResponse) in UIImage(data: data)}
                .replaceError(with: nil)
                .receive(on: DispatchQueue.main)
            
            backgroundImageFetchCancellable = publisher
                .sink { [weak self] image in
                    self?.backgroundImage = image
                    self?.backgroundImageFetchStatus = image != nil ? .idle : .failed(url)
                }
//            await MainActor.run {
//                backgroundImageFetchStatus = .fetching
//            }
//            do{
//                (data, _) = try await URLSession.shared.data(from: url)
//            } catch {
//                data = nil
//            }
//            if emojiArt.background == EmojiArtModel.Background.url(url){
//                await MainActor.run {
//                    backgroundImageFetchStatus = .idle
//                    if data != nil{
//                        backgroundImage = UIImage(data: data!)
//                    }
//                    if backgroundImage == nil {
//                        backgroundImageFetchStatus = .failed(url)
//                    }
//                }
//            }
            
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
            backgroundImage = UIImage(data: data)
//            await MainActor.run {
//                backgroundImage = UIImage(data: data)
//            }
        case .blank:
            break
        }
    }
    
    //MARK: - Intents
    
    func setBackground(_ background: EmojiArtModel.Background, undoManager: UndoManager?){
        undoablyPerform(operation: "Set Background", with: undoManager) {
            emojiArt.background = background
        }
    }
    
    func addEmoji(_ emoji: String, at location: (x:Int, y:Int), size: CGFloat, undoManager: UndoManager?){
        undoablyPerform(operation: "Add \(emoji)", with: undoManager) {
            emojiArt.addEmoji(emoji, at: location, size: Int(size))
        }
    }
    
    func moveEmoji(_ emoji: EmojiArtModel.Emoji, by offset: CGSize, undoManager: UndoManager?){
        if let index = emojiArt.emojis.index(matching: emoji){
            undoablyPerform(operation: "Move", with: undoManager) {
                emojiArt.emojis[index].x += Int(offset.width)
                emojiArt.emojis[index].y += Int(offset.height)
            }
        }
    }
    
    func scaleEmoji(_ emoji: EmojiArtModel.Emoji, by scale: CGFloat, undoManager: UndoManager?){
        if let index = emojiArt.emojis.index(matching: emoji){
            undoablyPerform(operation: "Scale", with: undoManager) {
                emojiArt.emojis[index].size = Int( (CGFloat(emojiArt.emojis[index].size) * scale).rounded(.toNearestOrAwayFromZero) )
            }
        }
    }
    
    func removeEmoji(_ emoji: EmojiArtModel.Emoji, undoManager: UndoManager?){
        if let index = emojiArt.emojis.index(matching: emoji){
            undoablyPerform(operation: "Remove", with: undoManager) {
                emojiArt.emojis.remove(at: index)
            }
        }
    }
    
    
    
    // MARK: - Undo
    
    private func undoablyPerform(operation: String, with undoManager: UndoManager? = nil, doit: () -> Void){
        let oldEmojiArt = emojiArt
        doit()
        undoManager?.registerUndo(withTarget: self){ myself in
            myself.undoablyPerform(operation: operation, with: undoManager){
                myself.emojiArt = oldEmojiArt
            }
        }
        undoManager?.setActionName(operation)
    }
}

