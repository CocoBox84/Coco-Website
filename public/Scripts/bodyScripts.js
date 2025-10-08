//import dayjs from "https://unpkg.com/dayjs@1.11.10/esm/index.js";
import { products } from "/Data/Home Page Data/Products.js";
import { newStuff } from "/Data/Home Page Data/Newstuff.js";

//1 =



//if () {}

const errorMessageContainer = document.getElementById("error-container");

function clearError() {
  errorMessageContainer.classList.remove("error-container-show");
  errorMessageContainer.classList.add("error-container-hide");
  document.getElementById("e").innerHTML = ``;
  var errorContainer = document.getElementById("error-container");
  errorContainer.classList.remove("error-container-show");
  errorContainer.classList.add("error-container-hide");
};

let productsHTML = '';

products.forEach((product) => {
  //console.log(product);
  if (!product.data.video.hasVideo) {
    productsHTML += `
      <div class="box-product">
        <div class="product-info">
          <h1 class="product-name" limit-text-to-2-lines">${product.id}</h1>
          <img class="product-img" src="${product.image}">
          <p class="product-text" limit-text-to-2-lines">${product.text}</p>
          <br>
          <a href="${product.link}">
            <button class="Download-Button">Download ${product.id}</button>
          </a>
        </div>
        <div class="product-video">
          
        </div>
      </div>
    `;
  }
});

function cocoSound() {
  var Coco = new Audio("Coco.wav");
  Coco.play();
}

document.addEventListener('DOMContentLoaded', function() {
    //console.log(productsHTML);
    document.getElementById('products1').innerHTML = productsHTML;
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
</select>*/

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

signInButton.innerText = `Sign In`;

document.addEventListener("DOMContentLoaded", () => {
  clearError();
  const Nav = document.getElementById("main-nav-box");
  const NavButtons = document.getElementById("sidebar-buttons");
  Nav.classList.remove("navigation-box-closed");
  NavButtons.addEventListener("click", function() {
    if (Nav.classList.contains("navigation-box-closed")) {
      Nav.classList.remove("navigation-box-closed");
    } else {
      Nav.classList.add("navigation-box-closed");
    }
  });
})