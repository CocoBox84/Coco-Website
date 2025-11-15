const Sidebar = `
        <div id="sidebar-buttons">
          <button class="sidebar-button"><img src="/Coco Icon/Old Coco Icon.png"><br>Coco</button>
          <button class="sidebar-button"><img src="/.png">Code</button>
        </div>
        <div id="sidebar-content">

          <!-- Page 1 Of Sidebar Navigation -->
          <div id="sidebar-content-page-1" style="sidebar-page show">
            <img src="/Coco Icon/Coco The Coconut.png">
            <h3 class="cool-text">Hello! And Welcome To Coco!</h3>
          </div>


        </div>
`;

function navBoxClick() {
    sidebar.classList.toggle("navigation-box-closed");
    sidebar.classList.toggle("navigation-box-open");
}

function navBoxOpen() {
    sidebar.classList.remove("navigation-box-closed");
    sidebar.classList.add("navigation-box-open");
}

function navBoxClose() {
    sidebar.classList.add("navigation-box-closed");
    sidebar.classList.remove("navigation-box-open");
}