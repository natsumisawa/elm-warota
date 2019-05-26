require('./main.scss');

const { Elm } = require('./Main.elm');
const mountNode = document.getElementById('main');

var app = Elm.Main.init({
  node: document.getElementById('main')
});

app.ports.cache.subscribe(function(data) {
  console.log(data);
  var canvas = document.getElementById('generate-canvas');
  if ( ! canvas || ! canvas.getContext ) { return false; }
  var ctx = canvas.getContext('2d');
  /* Imageオブジェクトを生成 */
  var img = new Image();
  img.src = "../public/eye.PNG";
  /* 画像を描画 */
  ctx.drawImage(img, 0, 0);

  var png = canvas.toDataURL();
  document.getElementById("new-img").src = png;
})
