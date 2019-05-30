require('./main.scss');

const { Elm } = require('./Main.elm');
const mountNode = document.getElementById('main');

var app = Elm.Main.init({
  node: document.getElementById('main')
});

app.ports.toImg.subscribe(function(data) {
  console.log(JSON.stringify(data));
  var canvas = document.getElementById('generate-canvas');
  if ( ! canvas || ! canvas.getContext ) { return false; }
  var ctx = canvas.getContext('2d');
  /* Imageオブジェクトを生成 */
  var faceImg = new Image();
  var eyeImg = new Image();
  var mouthImg = new Image();
  faceImg.addEventListener("load", function() {
    faceImg.src = "../public/" + data[1] + data[2] + ".PNG";
  }, false);
  eyeImg.addEventListener("load", function() {
    eyeImg.src = "../public/eye.PNG";
  }, false);
  mouthImg.addEventListener("load", function() {
    mouthImg.src = "../public/mouth" + data[3] + ".PNG";
  }, false);
  ctx.drawImage(faceImg, 0, 0);
  ctx.drawImage(eyeImg, 120, 10);
  ctx.drawImage(mouthImg, 120, 80);
  ctx.font = "32px Source Sans Pro";
  ctx.fillText(data[0], 120, 380);

  var png = canvas.toDataURL();
  document.getElementById("new-img").src = png;
  document.getElementById("download").href = png;
})

app.ports.resetImg.subscribe(function(data) {
  var canvas = document.getElementById('generate-canvas');
  if ( ! canvas || ! canvas.getContext ) { return false; }
  var ctx = canvas.getContext('2d');
  ctx.clearRect(0, 0, canvas.width, canvas.height);
});
