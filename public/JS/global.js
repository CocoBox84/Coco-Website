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

let sidebar = document.getElementById("main-nav-box");

document.addEventListener("DOMContentLoaded", onPageLoad);

const Sidebar = `
  <div id="sidebar-buttons">
    <button class="sidebar-button" id="sidebar-about-button"><img src="/Stickers/Old Coco Icon.stikr"><br>Coco</button>
    <button class="sidebar-button" id="sidebar-help-button"><img src="/Stickers/Question Mark.stikr"><br>Help</button>
    <button class="sidebar-button" id="sidebar-messages-button"><img src="/Stickers/Mail.stikr"><br>Mailbox</button>
    <button class="sidebar-button" id="sidebar-close-button"><img src="/Stickers/Close.stikr"><br>Close</button>
  </div>
  <iframe id="sidebar-content" src="/">
  </iframe>
`;

function navBoxClick() {
    console.log("Sidebar clicked!");
    sidebar.classList.toggle("open");
    sidebar.classList.toggle("closed");
}

function navBoxOpen(page) {
    sidebar.classList.remove("closed");
    sidebar.classList.add("open");
    switch (page) {
        case "about": {
            document.getElementById("sidebar-content").src = "/sidebar/help/screens/about/";
        } break;
        case "help": {
            document.getElementById("sidebar-content").src = "/sidebar/help/screens/help/";
        } break;
        case "messages": {
            document.getElementById("sidebar-content").src = "/sidebar/help/screens/mailbox/";
        } break;
        case "close": {
            document.getElementById("sidebar-content").src = "about:blank";
            navBoxClose();
        } break;
        default: {
            document.getElementById("sidebar-content").src = "about:blank";
            navBoxClose();
        } break;
    }
}

function navBoxClose() {
    sidebar.classList.add("closed");
    sidebar.classList.remove("open");
}

function onPageLoad() {
    sidebar = document.getElementById("main-nav-box");
    // Reset classes
    sidebar.classList.remove("navigation-box-closed", "navigation-box-open");

    // Inject sidebar HTML first
    sidebar.innerHTML = Sidebar;

    document.getElementById("sidebar-about-button").addEventListener("click", function () {navBoxOpen("about");});
    
    document.getElementById("sidebar-help-button").addEventListener("click", function () {navBoxOpen("help");});

    document.getElementById("sidebar-messages-button").addEventListener("click", function () {navBoxOpen("messages");});

    document.getElementById("sidebar-close-button").addEventListener("click", function () {navBoxOpen("close");});

    // Remove both closed and open, this will push it offscreen
    sidebar.style.transition = "none";
    sidebar.classList.remove("closed");
    sidebar.classList.remove("open");

    // Add the show class, it will automatically close because the parameter is blank
    setTimeout(function() {sidebar.style.transition = ""; navBoxOpen("");}, 1000);
    
}
