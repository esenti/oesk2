c = document.getElementById('draw')
ctx = c.getContext('2d')

delta = 0
now = 0
before = Date.now()

sec = 0
frames = 0
fps = 0

c.width = window.innerWidth
c.height = window.innerHeight

setDelta = ->
	now = Date.now()
	delta = (now - before) / 1000
	before = now;

obj = ({x: Math.random() * 500, y: Math.random() * 500, dx: (Math.random() - 0.5) * 8, dy: (Math.random() - 0.5) * 8, color: "rgb(#{Math.round(Math.random() * 255)}, 100, #{Math.round(Math.random() * 255)})"} for _ in [0..3000])

update = ->
	setDelta()

	sec += delta
	frames += 1

	if sec >= 1
		fps = frames
		frames = 0
		sec = 0

	ctx.clearRect(0, 0, c.width, c.height)


	for o in obj
		o.x += o.dx * delta * 10
		o.y += o.dy * delta * 10

		if o.x + 20 >= c.width or o.x <= 0
			o.dx = -o.dx
		if o.y + 20 >= c.height or o.y <= 0
			o.dy = -o.dy

		ctx.fillStyle = o.color
		ctx.fillRect(o.x, o.y, 20, 20)

	ctx.fillText(fps, 10, 10)


	window.requestAnimationFrame(update)

update()