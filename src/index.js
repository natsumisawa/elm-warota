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
  var img1 = new Image();
  var img2 = new Image();
  var img3 = new Image();
  img1.src = "../public/" + data[1] + data[2] + ".PNG";
  img2.src = "../public/eye.PNG";
  img3.src = "../public/mouth" + data[3] + ".PNG";
  ctx.drawImage(img1, 0, 0);
  ctx.drawImage(img2, 0, 10);
  ctx.drawImage(img3, 0, 20);
  ctx.fillText(data[0], 0, 0);

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
