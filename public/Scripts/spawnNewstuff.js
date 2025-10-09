/* Aa */ import { newStuff } from "/Data/Home Page Data/Newstuff.js"; /* Aa */
/* Aa * export /* Aa */ function drawNewstuff() {
    /*const newStuff = `
        <div class="big-box">
            <div class="big-box-header">
                <img class="Coco-logo" src="Coco.svg">
                <p class="Welcome-text">Welcome To The Coco Website! Create An Account Or Sign In!</p>
            </div>
        <!----<dialog>Hello</dialog>-->
            <div class="cool-stuff">
    
                <div class="inner-big-box-object">
                </div>
    
                <div class="cool-text">Hello! Welcome To The Coco Website!
                    Find Any Applications You Would Like, Then Sign In Or Create An Account To
                    Purchase Them! (You Can Also Find Links To External Websites).
                </div>
    
                <div class="cool-description">A Quick Video For The Website!</div>
                <div class="cool-image">
                    <img src="Coco Icon/Old Coco Icon.svg">
                </div>
    
            </div>
        </div>
    `;*/

    let newCoolStuff = document.getElementById("intro").innerHTML;
    const newsObject = document.getElementById("intro");
    newStuff.forEach((newCoolThing) => {
        if (newCoolThing.id == "skippable-intro") {
            newCoolStuff += `${newCoolThing.dataIf}`;
        } else {
            newCoolStuff += `
            <div class="big-box">
            <div class="big-box-header">
                <img class="Coco-logo" src="/Coco.svg">
                <p class="Welcome-text">Welcome To The Coco Website! Create An Account Or Sign In!</p>
            </div>
        <!----<dialog>Hello</dialog>-->
            <div class="cool-stuff">
    
                <div class="inner-big-box-object">
                <object class="media-object">${newCoolThing.media}</object>
                </div>
    
                <div class="cool-text">Hello! Welcome To The Coco Website!
                    Find Any Applications You Would Like, Then Sign In Or Create An Account To
                    Purchase Them! (You Can Also Find Links To External Websites).
                </div>
    
                <div class="cool-description">A Quick Video For The Website!</div>
                <div class="cool-image">
                    <img src="/Coco Icon/Old Coco Icon.svg">
                </div>
    
            </div>
        </div>
            `;
        }

        //console.log(newCoolStuff);
    });

    const html = newCoolStuff;
    newsObject.innerHTML = html + ``;
}

//console.log("Hello");

drawNewstuff(); /* Aa */