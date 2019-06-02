require('./main.scss');

const { Elm } = require('./Main.elm');
const mountNode = document.getElementById('main');

let app = Elm.Main.init({
  node: document.getElementById('main')
});

app.ports.drawImage.subscribe(function(json) {
  console.log(json);
  let canvas = document.getElementById('generate-canvas');
  if ( ! canvas || ! canvas.getContext ) { return false; }
  let ctx = canvas.getContext('2d');
  /* 背景色セット */
  ctx.beginPath();
  ctx.fillStyle = "hsla(" + json.hue + ", 94%, 49%, 1.0)";
  ctx.fillRect(30, 0, canvas.width, canvas.height);
  /* PartsのImageオブジェクトを生成して描画 */
  ctx.beginPath();
  let faceImg = new Image();
  let eyeImg = new Image();
  let mouthImg = new Image();
  faceImg.addEventListener("load", function() {
    ctx.drawImage(faceImg, 30, 0);
  }, false);
  eyeImg.addEventListener("load", function() {
    ctx.drawImage(eyeImg, 100, 20);
  }, false);
  mouthImg.addEventListener("load", function() {
    ctx.drawImage(mouthImg, 120, 90);
  }, false);
  faceImg.src = "../public/" + json.face + ".PNG";
  eyeImg.src = "../public/eye" + json.eye + ".PNG";
  mouthImg.src = "../public/mouth" + json.mouth + ".PNG";
  ctx.font = "bold 32px Source Sans Pro";
  ctx.fillText(json.phrase, 120, 380);
  setImgAfterwait();
  async function setImgAfterwait() {
    try {
      await wait(1);
      let png = canvas.toDataURL();
      document.getElementById("new-img").src = png;
      document.getElementById("download").href = png;
    } catch (err) {
      console.error(err);
    }
  }
})

app.ports.resetImg.subscribe(function(data) {
  let canvas = document.getElementById('generate-canvas');
  if ( ! canvas || ! canvas.getContext ) { return false; }
  let ctx = canvas.getContext('2d');
  ctx.clearRect(0, 0, canvas.width, canvas.height);
  document.getElementById("new-img").src = "";
  document.getElementById("download").href = "";
});

const wait = (sec) => {
  return new Promise((resolve, reject) => {
    setTimeout(resolve, sec*1000);
  });
};
