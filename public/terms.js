// An older file. I tried doing security on the front end.
const warning = "Trying To Bypass The Terms Means You Agree! I Recommend You Read Are Terms And Agree To Them Or Decline!";

function warn(warning) {
    console.warn(warning);
    alert(warning);
}


function agree() {
    let a = true;
    localStorage.setItem("hasReadTerms", JSON.stringify(a));
    let hasReadTerms = JSON.parse(localStorage.getItem("hasReadTerms"));
    console.log(hasReadTerms);
}