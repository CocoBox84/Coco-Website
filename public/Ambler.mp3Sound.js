/*
class Sound {
    audio;
    constructor(src) {
        this.audio = new Audio(src);
    }

    init() {
        this.audio.loop = true;
        this.audio.volume = 0.1;
    }

    startMusic() {
        const audioDisabled = localStorage.getItem('audioDisabled');
        if (!!audioDisabled) return;
        this.audio.play().catch(err => {
            //console.error("Playback failed:", err);
        });
    }

    fadeVolume(target, step = 0.005, interval = 50) {
        clearInterval(this.audio._fadeTimer);
        this.audio._fadeTimer = setInterval(() => {
            if (Math.abs(this.audio.volume - target) <= step) {
                this.audio.volume = target;
                clearInterval(this.audio._fadeTimer);
            } else if (this.audio.volume < target) {
                this.audio.volume = Math.min(this.audio.volume + step, target);
            } else {
                this.audio.volume = Math.max(this.audio.volume - step, target);
            }
        }, interval);
    }

    lowerMusic() {
        this.fadeVolume(0.005); // fade out
    }

    raiseMusic() {
        this.fadeVolume(0.1); // fade in
    }
}*/

const Ambler = new Audio("/Ambler.mp3");
Ambler.loop = true;
Ambler.volume = 0.1;

function startMusic() {
    const audioDisabled = localStorage.getItem('audioDisabled');
    if (!!audioDisabled) return;
    Ambler.play().catch(err => {
        //console.error("Playback failed:", err);
    });
    document.removeEventListener('click', startMusic);
}

// Wait for a real user click
document.addEventListener('click', startMusic);

// Smooth fade helpers
function fadeVolume(target, step = 0.005, interval = 50) {
    clearInterval(Ambler._fadeTimer);
    Ambler._fadeTimer = setInterval(() => {
        if (Math.abs(Ambler.volume - target) <= step) {
            Ambler.volume = target;
            clearInterval(Ambler._fadeTimer);
        } else if (Ambler.volume < target) {
            Ambler.volume = Math.min(Ambler.volume + step, target);
        } else {
            Ambler.volume = Math.max(Ambler.volume - step, target);
        }
    }, interval);
}

function lowerMusic() {
    fadeVolume(0.005); // fade out
}

function raiseMusic() {
    fadeVolume(0.1); // fade in
}

playbackFailed = false;
Ambler.addEventListener('error', (e) => {
    playbackFailed = true;
    console.error("Audio playback error:", e);
});