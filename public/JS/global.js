window.document.querySelectorAll('video').forEach(video => {
    video.addEventListener('play', () => {
        lowerMusic();
    });
    video.addEventListener('pause', () => {
        raiseMusic();
    });
    video.addEventListener('ended', () => {
        raiseMusic();
    });
});