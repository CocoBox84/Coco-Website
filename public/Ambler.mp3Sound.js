const Ambler = new Audio("http://127.0.0.1:5500/Ambler.mp3");
Ambler.loop = true;
Ambler.volume = 0.1;

function startMusic() {
    const audioDisabled = localStorage.getItem('audioDisabled');
    if (!!audioDisabled) return;
    Ambler.play().catch(err => {
        console.error("Playback failed:", err);
    });
    document.removeEventListener('click', startMusic);
}

// Wait for a real user click
document.addEventListener('click', startMusic);