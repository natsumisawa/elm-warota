window.onload = () => {
	const app = Elm.Main.init()

	app.ports.drawImage.subscribe(function(json) {
	  let canvas = document.getElementById('generate-canvas');
	  if ( ! canvas || ! canvas.getContext ) { return false; }
	  let ctx = canvas.getContext('2d');
	  /* 背景色セット */
	  ctx.beginPath();
	  ctx.fillStyle = "hsla(" + json.hue + ", 94%, 49%, 1.0)";
	  ctx.fillRect(0, 0, canvas.width - 10, canvas.height -60);
	  /* PartsのImageオブジェクトを生成して描画 */
	  ctx.beginPath();
	  let faceImg = new Image();
	  let eyeImg = new Image();
	  let mouthImg = new Image();
	  faceImg.addEventListener("load", function() {
	    ctx.drawImage(faceImg, 0, 0);
	  }, false);
	  eyeImg.addEventListener("load", function() {
	    ctx.drawImage(eyeImg, 60, 20);
	  }, false);
	  mouthImg.addEventListener("load", function() {
	    ctx.drawImage(mouthImg, 120, 110);
	  }, false);
	  faceImg.src = "assets/images/" + json.face + ".PNG";
	  eyeImg.src = "assets/images/eye" + json.eye + ".PNG";
	  mouthImg.src = "assets/images/mouth" + json.mouth + ".PNG";
	  ctx.font = "bold 32px Source Sans Pro";
	  ctx.fillStyle = "white";
	  ctx.fillRect(0, canvas.height - 60, canvas.width, canvas.height);
	  ctx.fillStyle = "black";
	  // ctx.textAlign = "center";
	  ctx.fillText(json.phrase, 50, canvas.height - 10, canvas.width - 100);
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
}
