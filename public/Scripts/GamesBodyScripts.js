import dayjs from "https://unpkg.com/dayjs@1.11.10/esm/index.js";
import { games, announcement1, games2, announcement2, games3 } from "http://127.0.0.1:5500/Data/Home Page Data/Games.js";
import { newStuff } from "http://127.0.0.1:5500/Data/Home Page Data/Newstuff.js";

//1 =

const errorMessageContainer = document.getElementById("error-container");
const eventHeader = document.getElementById("event-header");

function clearError() {
  errorMessageContainer.classList.remove("error-container-show");
  errorMessageContainer.classList.add("error-container-hide");
  document.getElementById("e").innerHTML = ``;
  var errorContainer = document.getElementById("error-container");
  errorContainer.classList.remove("error-container-show");
  errorContainer.classList.add("error-container-hide");
};

let gamesHTML = '';
let announcement1HTML = '';
let gamesHTML2 = '';
let announcement2HTML = '';
let gamesHTML3 = '';

games.forEach((product) => {
    gamesHTML += `
      <div class="box-product">
                      <p class="product-name" limit-text-to-2-lines">${product.id}</p>
                    <a class="product-a" href="${product.link}">
                    <img class="product-img" src="${product.image}">
                    </a>
                <p class="product-text" limit-text-to-2-lines">${product.text}</p>
            </div>
    `;
});

announcement1.forEach((news) => {
  announcement1HTML += `
    <div class="box-announcement">
                    <p class="product-name" limit-text-to-2-lines">${news.headerText}</p>
                  <a class="product-a" href="${news.link}">
                  <img class="product-img" src="${news.image}">
                  </a>
              <p class="product-text" limit-text-to-2-lines">${news.text}</p>
          </div>
  `;
});

announcement2.forEach((news) => {
  announcement2HTML += `
    <div class="box-announcement">
                    <p class="product-name" limit-text-to-2-lines">${news.headerText}</p>
                  <a class="product-a" href="${news.link}">
                  <img class="product-img" src="${news.image}">
                  </a>
              <p class="product-text" limit-text-to-2-lines">${news.text}</p>
          </div>
  `;
});
games2.forEach((product) => {
  gamesHTML2 += `
    <div class="box-product">
                    <p class="product-name" limit-text-to-2-lines">${product.id}</p>
                  <a class="product-a" href="${product.link}">
                  <img class="product-img" src="${product.image}">
                  </a>
              <p class="product-text" limit-text-to-2-lines">${product.text}</p>
          </div>
  `;
});
games3.forEach((product) => {
  gamesHTML3 += `
    <div class="box-product">
                    <p class="product-name" limit-text-to-2-lines">${product.id}</p>
                  <a class="product-a" href="${product.link}">
                  <img class="product-img" src="${product.image}">
                  </a>
              <p class="product-text" limit-text-to-2-lines">${product.text}</p>
          </div>
  `;
});

function cocoSound() {
  var Coco = new Audio("Coco.wav");
  audio.play();
}

document.addEventListener('DOMContentLoaded', function() {
    console.log(announcement1HTML);
    document.getElementById('games1').innerHTML = gamesHTML;
    document.getElementById('Announcement1').innerHTML = announcement1HTML;
  });

/*<select>
<option selected value="1">1</option>
<option value="2">2</option>
<option value="3">3</option>
<option value="4">4</option>
<option value="5">5</option>
<option value="6">6</option>
<option value="7">7</option>
<option value="8">8</option>
<option value="9">9</option>
<option value="10">10</option>
</select>*

const signInButton = document.getElementById("sign-in");
signInButton.addEventListener("mouseenter", () => {
  setTimeout(() => {
    signInButton.innerText = `Sign In >`;
  }, 50);

  setTimeout(() => {
    signInButton.innerHTML = `Sign In >>`;
  }, 70);

  setTimeout(() => {
    signInButton.innerHTML = `Sign In >> C`;
  }, 87);

  setTimeout(() => {
    signInButton.innerHTML = `Sign In >> Cl`;
  }, 90);

  setTimeout(() => {
    signInButton.innerHTML = `Sign In >> Clic`;
  }, 100);

  setTimeout(() => {
    signInButton.innerHTML = `Sign In >> Click`;
  }, 110);

  setTimeout(() => {
    signInButton.innerHTML = `Sign In >> Click `;
  }, 120);

  setTimeout(() => {
    signInButton.innerHTML = `Sign In >> Click H`;
  }, 200);

  setTimeout(() => {
    signInButton.innerHTML = `Sign In >> Click He`;
  }, 250);

  setTimeout(() => {
    signInButton.innerHTML = `Sign In >> Click Her`;
  }, 300);

  setTimeout(() => {
    signInButton.innerHTML = `Sign In >> Click Here`;
  }, 350);

  setTimeout(() => {
    signInButton.innerHTML = `Sign In >> Click Here `;
  }, 400);

  setTimeout(() => {
    signInButton.innerHTML = `Sign In >> Click Here T`;
  }, 450);

  setTimeout(() => {
    signInButton.innerHTML = `Sign In >> Click Here To`;
  }, 500);

  setTimeout(() => {
    signInButton.innerHTML = `Sign In >> Click Here To `;
  }, 550);

  setTimeout(() => {
    signInButton.innerHTML = `Sign In >> Click Here To S`;
  }, 590);

  setTimeout(() => {
    signInButton.innerHTML = `Sign In >> Click Here To Si`;
  }, 700);

  setTimeout(() => {
    signInButton.innerHTML = `Sign In >> Click Here To Sig`;
  }, 750);

  setTimeout(() => {
    signInButton.innerHTML = `Sign In >> Click Here To Sign`;
  }, 950);

  setTimeout(() => {
    signInButton.innerHTML = `Sign In >> Click Here To Sign `;
  }, 1000);

  setTimeout(() => {
    signInButton.innerHTML = `Sign In >> Click Here To Sign I`;
  }, 1050);

  setTimeout(() => {
    signInButton.innerHTML = `Sign In >> Click Here To Sign In`;
  }, 1100);

  setTimeout(() => {
    signInButton.innerHTML = `Sign In >> Click Here To Sign In.`;
  }, 1150);

});

signInButton.addEventListener("mouseleave", () => {

  setTimeout(() => {
    signInButton.innerHTML = `Sign In`;
  });

});

signInButton.innerText = `Sign In`;*/

document.addEventListener("DOMContentLoaded", () => {
  clearError();
  console.log("Error Cleared");
})