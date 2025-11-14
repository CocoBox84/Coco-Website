// Scripts/user.js
console.log('User.js started!');

function getFromServer(url) {
    // Basic GET request
    let data1;
    fetch(url)
        .then(response => {
            if (!response.ok) {
                throw new Error(`HTTP error! Status: ${response.status}`);
            }
            return response.json(); // Parse JSON response
        })
        .then(data => {
            console.log(data); // Handle the data
            data1 = data;
        })
        .catch(error => {
            console.error('There was a problem with the fetch operation:', error);
        });
    return data1;
}

async function followUser(username) {
    fetch(`/api/follow/${username}/`).then((res) => {
        console.log(res.body);
        return res.body;
    });
}

async function unfollowUser(username) {
    fetch(`/api/unfollow/${username}/`).then((res) => {
        console.log(res.body);
        return res.body;
    });
}

function updateProfile() {
  const descriptionDiv = document.getElementById("description");
  const CocoScriptCodeDiv = document.getElementById("Coco-Script-area");
  const description = descriptionDiv.value;
  const CocoScriptCode = CocoScriptCodeDiv.value;

  fetch("/api/set/description", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ description, CocoScriptCode })
  })
    .then((response) => response.json())
    .then((result) => {console.log("Success:", result); window.location.href = window.location.href;})
    .catch((error) => console.error("Error:", error));
}