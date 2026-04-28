import SwiftUI

struct StoryViewerView: View {
    let startIndex: Int
    let stories: [Story]
    let onStorySeen: (Story) -> Void

    @Environment(\.dismiss) private var dismiss

    @State private var selectedStoryIndex: Int = 0
    @State private var selectedPageIndex: Int = 0

    private let storyCornerRadius: CGFloat = 40
    private let progressTopInset: CGFloat = 35
    private let progressHorizontalInset: CGFloat = 12
    private let closeTopSpacing: CGFloat = 16
    private let closeButtonSize: CGFloat = 30
    private let textHorizontalInset: CGFloat = 16
    private let textBottomInset: CGFloat = 98

    var body: some View {
        ZStack {
            Color("YPBlackUniversal")
                .ignoresSafeArea()

            GeometryReader { geometry in
                let canvasSize = geometry.size
                let safeTop = geometry.safeAreaInsets.top
                let safeBottom = geometry.safeAreaInsets.bottom

                if stories.indices.contains(selectedStoryIndex) {
                    let story = stories[selectedStoryIndex]
                    let frame = storyFrame(in: canvasSize, safeTop: safeTop, safeBottom: safeBottom)

                    ZStack {
                        storyCard(story: story, frame: frame)
                            .id(story.id)
                            .transition(.move(edge: .trailing))
                    }
                    .overlay(alignment: .top) {
                        topOverlay(pagesCount: story.pages.count)
                    }
                    .frame(width: canvasSize.width, height: canvasSize.height)
                }
            }
        }
        .onAppear {
            let safeIndex = min(max(0, startIndex), max(0, stories.count - 1))
            selectedStoryIndex = safeIndex
            selectedPageIndex = 0

            if stories.indices.contains(safeIndex) {
                onStorySeen(stories[safeIndex])
            }
        }
        .gesture(
            DragGesture(minimumDistance: 20)
                .onEnded { value in
                    if value.translation.width < -40 {
                        showNextPageOrStory()
                    } else if value.translation.width > 40 {
                        showPreviousPageOrStory()
                    }
                }
        )
    }

    private func storyCard(story: Story, frame: CGRect) -> some View {
        let currentImageName = story.pages[selectedPageIndex]

        return ZStack(alignment: .bottomLeading) {
            storyImage(named: currentImageName, frame: frame)

            HStack(spacing: 0) {
                Color.clear
                    .contentShape(Rectangle())
                    .onTapGesture {
                        showPreviousPageOrStory()
                    }

                Color.clear
                    .contentShape(Rectangle())
                    .onTapGesture {
                        showNextPageOrStory()
                    }
            }
            .frame(width: frame.width, height: frame.height)

            VStack(alignment: .leading, spacing: 12) {
                Text(story.title)
                    .font(.system(size: 34, weight: .bold))
                    .foregroundStyle(.white)
                    .lineLimit(2)

                Text(story.subtitle)
                    .font(.system(size: 20, weight: .regular))
                    .foregroundStyle(.white)
                    .lineLimit(3)
            }
            .padding(.horizontal, textHorizontalInset)
            .padding(.bottom, textBottomInset)
            .frame(width: frame.width, alignment: .leading)
        }
        .frame(width: frame.width, height: frame.height)
        .clipShape(RoundedRectangle(cornerRadius: storyCornerRadius, style: .continuous))
        .position(x: frame.midX, y: frame.midY)
    }

    private func storyImage(named imageName: String, frame: CGRect) -> some View {
        ZStack {
            Image(imageName)
                .resizable()
                .scaledToFill()
                .scaleEffect(x: imageName == "story_1" ? -1 : 1, y: 1)
                .frame(width: frame.width, height: frame.height)
                .clipped()

            LinearGradient(
                colors: [
                    .clear,
                    .black.opacity(0.15),
                    .black.opacity(0.75)
                ],
                startPoint: .center,
                endPoint: .bottom
            )
            .frame(width: frame.width, height: frame.height)
        }
        .transaction { transaction in
            transaction.animation = nil
        }
    }

    private func topOverlay(pagesCount: Int) -> some View {
        VStack(spacing: closeTopSpacing) {
            HStack(spacing: 6) {
                ForEach(0..<pagesCount, id: \.self) { index in
                    Capsule()
                        .fill(index <= selectedPageIndex ? Color("YPBlueUniversal") : .white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 6)
                }
            }

            HStack {
                Spacer()

                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: closeButtonSize, height: closeButtonSize)
                        .background(Color.black.opacity(0.5))
                        .clipShape(Circle())
                }
            }
        }
        .padding(.top, progressTopInset)
        .padding(.horizontal, progressHorizontalInset)
        .transaction { transaction in
            transaction.animation = nil
        }
    }

    private func storyFrame(in canvas: CGSize, safeTop: CGFloat, safeBottom: CGFloat) -> CGRect {
        let topInset: CGFloat = 7
        let bottomInset: CGFloat = 17
        let targetAspectRatio: CGFloat = 9.0 / 16.0

        let height = canvas.height - topInset - bottomInset
        let width = min(canvas.width, height * targetAspectRatio)

        let originX = (canvas.width - width) / 2
        let originY = topInset

        return CGRect(
            x: originX,
            y: originY,
            width: width,
            height: height
        )
    }

    private func showNextPageOrStory() {
        guard stories.indices.contains(selectedStoryIndex) else { return }
        let pagesCount = stories[selectedStoryIndex].pages.count

        if selectedPageIndex < pagesCount - 1 {
            var transaction = Transaction()
            transaction.animation = nil

            withTransaction(transaction) {
                selectedPageIndex += 1
            }
        } else {
            showNextStory()
        }
    }

    private func showPreviousPageOrStory() {
        guard stories.indices.contains(selectedStoryIndex) else { return }

        if selectedPageIndex > 0 {
            var transaction = Transaction()
            transaction.animation = nil

            withTransaction(transaction) {
                selectedPageIndex -= 1
            }
        } else if selectedStoryIndex > 0 {
            let previousStoryIndex = selectedStoryIndex - 1
            let previousLastPageIndex = max(stories[previousStoryIndex].pages.count - 1, 0)

            withAnimation(.easeInOut(duration: 0.25)) {
                selectedStoryIndex = previousStoryIndex
                selectedPageIndex = previousLastPageIndex
            }

            onStorySeen(stories[previousStoryIndex])
        }
    }

    private func showNextStory() {
        let nextStoryIndex = selectedStoryIndex + 1
        guard stories.indices.contains(nextStoryIndex) else {
            dismiss()
            return
        }

        withAnimation(.easeInOut(duration: 0.25)) {
            selectedStoryIndex = nextStoryIndex
            selectedPageIndex = 0
        }

        onStorySeen(stories[nextStoryIndex])
    }
}

#Preview {
    StoryViewerView(startIndex: 0, stories: Story.mock) { _ in }
}
