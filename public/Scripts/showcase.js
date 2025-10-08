var isFlash = false;

var flashButCanUseRuffle = false;

var isScratch = false;

var scratchVersions = [1.0, 2.0, 3.0];

var isCoco = false;

var CocoVersion = [];

var noRuffleWarning = "";

var isFullScreen = false;

var hasFlash = true;

var hasPlugins = false;

 document.addEventListener("DOMContentLoaded", function() {
    setTimeout(function() {
        const scratch = document.getElementById("player");
        scratch.classList.remove("scratch-fullscreen");
        scratch.classList.add("scratch-embedded");
    });
 });

function JSsetPresentationMode(p1) {
    console.log(p1);
    const object = document.getElementById("Player");
    const scratch = document.getElementById("scratch");
    console.log("I'm Interacting With A swf File!");
    if (isFullScreen) {
        isFullScreen = false;
        object.classList.remove("player-fullscreen");
        object.classList.add("player-embedded");

        scratch.classList.remove("scratch-fullscreen");
        scratch.classList.add("scratch-embedded");
    } else {
        isFullScreen = true;
        object.classList.add("player-fullscreen");
        object.classList.remove("player-embedded");

        scratch.classList.add("scratch-fullscreen");
        scratch.classList.remove("scratch-embedded");
    }
}