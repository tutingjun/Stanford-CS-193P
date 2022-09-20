//
//  EmojiArtDocumentView.swift
//  EmojiArt
//
//  Created by 涂庭鋆 on 2022/9/5.
//

import SwiftUI

struct EmojiArtDocumentView: View {
    @ObservedObject var document: EmojiArtDocument
    @Environment(\.undoManager) var undoManager
    @State var selectedEmojis = Set<EmojiArtModel.Emoji>()
    
    @ScaledMetric var defaultEmojiFontSize: CGFloat = 40
    
    var body: some View {
        VStack(spacing: 0){
            documentBody
            PaletteChooser(emojiFontSize: defaultEmojiFontSize)
        }
    }
    
    var documentBody: some View{
        GeometryReader { geometry in
            ZStack{
                Color.white
                OptionalImage(uiImage: document.backgroundImage)
                    .scaleEffect(zoomScale)
                    .position(convertFromEmojiCoordinates((0,0), in: geometry))
                .gesture(doubleTapToZoom(in: geometry.size).exclusively(before: singleTapToUnselect()))
                if document.backgroundImageFetchStatus == .fetching {
                    ProgressView().scaleEffect(2)
                } else {
                    ForEach(document.emojis) { emoji in
                            Text(emoji.text)
                                .border(.black, width: selectedEmojis.index(matching: emoji) != nil ? 2:0)
                                .animatableFontSize(size: fontSize(for: emoji) * getEmojiZoomScale(for: emoji))
                                .position(position(for: emoji, in: geometry))
                                .gesture( emojiPanGesture(of: emoji)
                                    .simultaneously(with:
                                                        doubleTapToDelete(of: emoji).exclusively(before: singleTapToSelect(of: emoji))))
                                    
                        }
                        
                    }
                
            }
            .clipped()
            .onDrop(of: [.plainText, .url, .image], isTargeted: nil) { providers, location in
                drop(providers: providers, at: location, in: geometry)
            }
            .gesture(panGesture().simultaneously(with: zoomGesture()))
            .alert(item: $alertToShow) { alertToShow in
                alertToShow.alert()
            }
            .onChange(of: document.backgroundImageFetchStatus) { status in
                switch status {
                case .failed(let url):
                    showBackgroundImageFetchFailedAlert(url)
                default:
                    break
                }
                
            }
            .onReceive(document.$backgroundImage) { image in
                if autoZoom{
                    zoomToFit(image, in: geometry.size)
                }
            }
            .compactToolBar{
                AnimatedActionButton(title: "Paste Background", systemImage: "doc.on.clipboard") {
                    pasteBackground()
                }
                if Camera.isAvailable {
                    AnimatedActionButton(title: "Take Photo", systemImage: "camera") {
                        backgroundPicker = .camera
                    }
                }
                if PhotoLibrary.isAvailable {
                    AnimatedActionButton(title: "Choose Photo", systemImage: "photo") {
                        backgroundPicker = .library
                    }
                }
                if let undoManager = undoManager {
                    if undoManager.canUndo {
                        AnimatedActionButton(title: undoManager.undoActionName, systemImage: "arrow.uturn.backward"){
                            undoManager.undo()
                        }
                    }
                    if undoManager.canRedo {
                        AnimatedActionButton(title: undoManager.redoActionName, systemImage: "arrow.uturn.forward"){
                            undoManager.redo()
                        }
                    }
                }
            }
            .sheet(item: $backgroundPicker) { pickerType in
                switch pickerType {
                case .camera: Camera(handlePickedImage: { image in handlePickedBackgroundImage(image) })
                case .library: PhotoLibrary(handlePickedImage: { image in handlePickedBackgroundImage(image) })
                }
            }
        }
    }
    
    private func handlePickedBackgroundImage(_ image: UIImage?){
        autoZoom = true
        if let imageData = image?.jpegData(compressionQuality: 1.0) {
            document.setBackground(.imageData(imageData), undoManager: undoManager)
        }
        backgroundPicker = nil
    }
    
    @State private var backgroundPicker: BackgroundPickerType?
    
    enum BackgroundPickerType: Identifiable {
        case camera
        case library
        var id: BackgroundPickerType { self }
    }
    
    private func pasteBackground(){
        autoZoom = true
        if let imageData = UIPasteboard.general.image?.jpegData(compressionQuality: 1.0) {
            document.setBackground(.imageData(imageData), undoManager: undoManager)
        } else if let url = UIPasteboard.general.url?.imageURL {
            document.setBackground(.url(url), undoManager: undoManager)
        } else {
            alertToShow = IdentifiableAlert(
                title: "Paste Background",
                message: "There is no image currently on the pasteboard")
        }
    }
    
    @State private var autoZoom = false
    
    @State private var alertToShow: IdentifiableAlert?
    
    private func showBackgroundImageFetchFailedAlert(_ url: URL) {
        alertToShow = IdentifiableAlert(id : "fetch failed: " + url.absoluteString, alert: {
            Alert(
                title: Text("Background Image Fetch"),
                message: Text("Couldn't load image from \(url)."),
                dismissButton:  .default(Text("OK"))
            )
        })
    }
    
    private func drop(providers: [NSItemProvider], at location: CGPoint, in geometry: GeometryProxy) -> Bool{
        var found = providers.loadObjects(ofType: URL.self){ url in
            autoZoom = true
            document.setBackground(.url(url.imageURL), undoManager: undoManager)
        }
        
        if !found{
            found = providers.loadObjects(ofType: UIImage.self){ image in
                if let data = image.jpegData(compressionQuality: 1.0) {
                    autoZoom = true
                    document.setBackground(.imageData(data), undoManager: undoManager)
                }
            }
        }
        
        if !found{
            found = providers.loadObjects(ofType: String.self) { string in
                if let emoji = string.first, emoji.isEmoji{
                    document.addEmoji(
                        String(emoji),
                        at: convertToEmojiCoordinates(location, in: geometry),
                        size: defaultEmojiFontSize / zoomScale,
                        undoManager: undoManager
                    )
                }
            }
        }
        return found
    }
    
    //MARK: - Position & Coordinates Conversion
    
    private func convertToEmojiCoordinates(_ location: CGPoint, in geometry: GeometryProxy) -> (x:Int, y:Int){
        let center = geometry.frame(in: .local).center
        let location = CGPoint(
            x: (location.x - center.x - panOffset.width) / zoomScale,
            y: (location.y - center.y - panOffset.height) / zoomScale
        )
        return (Int(location.x), Int(location.y))
    }
    
    private func fontSize(for emoji: EmojiArtModel.Emoji) -> CGFloat{
        CGFloat(emoji.size)
    }
    
    private func position(for emoji: EmojiArtModel.Emoji, in geometry: GeometryProxy) -> CGPoint{
        convertFromEmojiCoordinates((emoji.x, emoji.y), in: geometry, for: emoji)
    }
    
    private func convertFromEmojiCoordinates(_ location: (x: Int, y: Int), in geometry: GeometryProxy, for emoji: EmojiArtModel.Emoji? = nil) -> CGPoint {
        let center = geometry.frame(in: .local).center
        
        if let saveEmoji = emoji {
            if let saveUnselectedEmoji = unselectedEmoji{
                if saveEmoji.id == saveUnselectedEmoji.id{
                    return CGPoint(
                        x: center.x + CGFloat(location.x) * zoomScale + panOffset.width + gesturePanOffsetEmoji.width,
                        y: center.y + CGFloat(location.y) * zoomScale + panOffset.height + gesturePanOffsetEmoji.height
                    )
                }
            } else if selectedEmojis.containEmoji(saveEmoji){
                return CGPoint(
                    x: center.x + CGFloat(location.x) * zoomScale + panOffset.width + gesturePanOffsetEmoji.width,
                    y: center.y + CGFloat(location.y) * zoomScale + panOffset.height + gesturePanOffsetEmoji.height
                )
            }
        }

        
        return CGPoint(
            x: center.x + CGFloat(location.x) * zoomScale + panOffset.width,
            y: center.y + CGFloat(location.y) * zoomScale + panOffset.height
        )

        
    }
    
    //MARK: - Drag Event
    @SceneStorage("EmojiArtDocumentView.steadyStatePanOffset")
    private var steadyStatePanOffset: CGSize = CGSize.zero
    
    @GestureState private var gesturePanOffset: CGSize = CGSize.zero
    
    
    private var panOffset: CGSize {
        (steadyStatePanOffset + gesturePanOffset) * zoomScale
    }
    
    
    private func panGesture() -> some Gesture{
        DragGesture()
            .updating($gesturePanOffset){ latestDragGestureValue, gesturePanOffset, _ in
                gesturePanOffset = latestDragGestureValue.translation / zoomScale
            }
            .onEnded{ finalDragGestureValue in
                steadyStatePanOffset = steadyStatePanOffset + (finalDragGestureValue.translation / zoomScale)
                withAnimation(Animation.easeOut(duration: 0.2)){
                    steadyStatePanOffset = steadyStatePanOffset + ((finalDragGestureValue.predictedEndTranslation - finalDragGestureValue.translation) / zoomScale / 8)
                }
                
            }
    }
    
    @State private var unselectedEmoji: EmojiArtModel.Emoji? = nil
    @GestureState private var gesturePanOffsetEmoji: CGSize = CGSize.zero
    
    private func emojiPanGesture(of emoji: EmojiArtModel.Emoji) -> some Gesture{
        DragGesture()
            .onChanged{ _ in
                unselectedEmoji = selectedEmojis.containEmoji(emoji) ? nil: emoji
            }
            .updating($gesturePanOffsetEmoji){ latestDragGestureValue, gesturePanOffsetEmoji, _ in
                gesturePanOffsetEmoji = latestDragGestureValue.translation
            }
            .onEnded{ finalDragGestureValue in
                if selectedEmojis.containEmoji(emoji){
                    for emoji in selectedEmojis{
                        document.moveEmoji(emoji, by: finalDragGestureValue.translation / zoomScale, undoManager: undoManager)
                    }
                } else {
                    document.moveEmoji(emoji, by: finalDragGestureValue.translation / zoomScale, undoManager: undoManager)
                    unselectedEmoji = nil
                }
                
            }
    }
    
    
    
    //MARK: - Zoom Event
    @SceneStorage("EmojiArtDocumentView.steadyZoomScale")
    private var steadyZoomScale: CGFloat = 1
    @GestureState private var gestureZoomScale: CGFloat = 1
    
    private var zoomScale: CGFloat {
        if selectedEmojis.count == 0{
            return steadyZoomScale * gestureZoomScale
        } else {
            return steadyZoomScale
        }
        
    }
    
    private var zoomScaleEmoji: CGFloat {
        steadyZoomScale * gestureZoomScale
    }
    
    private func getEmojiZoomScale(for emoji: EmojiArtModel.Emoji) -> CGFloat{
        return selectedEmojis.count == 0 ? zoomScale: selectedEmojis.containEmoji(emoji) ? zoomScaleEmoji : steadyZoomScale
    }
    
    
    private func zoomGesture() -> some Gesture{
        MagnificationGesture()
            .updating($gestureZoomScale){ latestGestureScale, gestureZoomScale, _ in
                gestureZoomScale = latestGestureScale
            }
            .onEnded{ gestureScaleAtEnd in
                if selectedEmojis.count == 0{
                    steadyZoomScale *= gestureScaleAtEnd
                } else {
                    for emoji in selectedEmojis {
                        document.scaleEmoji(emoji, by: gestureScaleAtEnd, undoManager: undoManager)
                    }
                }
                
            }
    }
    
    //MARK: - Tap to zoom / unselect (on canvas)
    private func doubleTapToZoom(in size: CGSize) -> some Gesture{
        TapGesture(count: 2)
            .onEnded{
                withAnimation{
                    zoomToFit(document.backgroundImage, in: size)
                }
            }
    }
    
    private func singleTapToUnselect() -> some Gesture{
        TapGesture(count: 1)
            .onEnded{
                selectedEmojis = Set<EmojiArtModel.Emoji>()
            }
    }
    
    //MARK: - Tap to select / delete (on emoji)
    private func singleTapToSelect(of emoji: EmojiArtModel.Emoji) -> some Gesture{
        TapGesture(count: 1)
            .onEnded{
                selectedEmojis.toggleMembership(of: emoji)
            }
    }
    
    private func doubleTapToDelete(of emoji: EmojiArtModel.Emoji) -> some Gesture{
        TapGesture(count: 2)
            .onEnded{
                withAnimation(Animation.easeOut){
                    selectedEmojis.toggleMembership(of: emoji)
                    document.removeEmoji(emoji, undoManager: undoManager)
                }
            }
    }
    
    private func zoomToFit(_ image: UIImage?, in size: CGSize){
        if let image = image, image.size.width > 0, image.size.height > 0, size.height > 0, size.width > 0 {
            let hZoom = size.width / image.size.width
            let vZoom = size.height / image.size.height
            steadyStatePanOffset = .zero
            steadyZoomScale = min(hZoom, vZoom)
        }
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        EmojiArtDocumentView(document: EmojiArtDocument())
    }
}
