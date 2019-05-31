require('./main.scss');

const { Elm } = require('./Main.elm');
const mountNode = document.getElementById('main');

var app = Elm.Main.init({
  node: document.getElementById('main')
});

app.ports.drawImage.subscribe(function(data) {
  console.log(JSON.stringify(data));
  var canvas = document.getElementById('generate-canvas');
  if ( ! canvas || ! canvas.getContext ) { return false; }
  var ctx = canvas.getContext('2d');
  /* Imageオブジェクトを生成 */
  var faceImg = new Image();
  var eyeImg = new Image();
  var mouthImg = new Image();
  faceImg.addEventListener("load", function() {
    ctx.drawImage(faceImg, 0, 0);
  }, false);
  eyeImg.addEventListener("load", function() {
    ctx.drawImage(eyeImg, 120, 10);
  }, false);
  mouthImg.addEventListener("load", function() {
    ctx.drawImage(mouthImg, 120, 80);
  }, false);
  faceImg.src = "../public/" + data[1] + data[2] + ".PNG";
  eyeImg.src = "../public/eye.PNG";
  mouthImg.src = "../public/mouth" + data[3] + ".PNG";

  ctx.font = "bold 32px Source Sans Pro";
  ctx.fillText(data[0], 120, 380);
  wait2s();
  async function wait2s() {
    try {
      await wait(2);
      var png = canvas.toDataURL();
      document.getElementById("new-img").src = png;
      document.getElementById("download").href = png;
    } catch (err) {
      console.error(err);
    }
  }
})

app.ports.resetImg.subscribe(function(data) {
  var canvas = document.getElementById('generate-canvas');
  if ( ! canvas || ! canvas.getContext ) { return false; }
  var ctx = canvas.getContext('2d');
  ctx.clearRect(0, 0, canvas.width, canvas.height);
  document.getElementById("new-img").src = "";
  document.getElementById("download").href = "";
});

const wait = (sec) => {
  return new Promise((resolve, reject) => {
    setTimeout(resolve, sec*1000);
  });
};
