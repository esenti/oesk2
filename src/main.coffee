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

fpsHistory = []

setDelta = ->
	now = Date.now()
	delta = (now - before) / 1000
	before = now;

obj = ({x: Math.random() * 500, y: Math.random() * 500, dx: (Math.random() - 0.5) * 8, dy: (Math.random() - 0.5) * 8, color: "rgb(#{Math.round(Math.random() * 255)}, 100, #{Math.round(Math.random() * 255)})"} for _ in [1..100])

toNext = 5
toEnd = 10
lastOK = 0

update = ->
	setDelta()

	sec += delta
	frames += 1

	if sec >= 1
		fps = frames
		frames = 0
		sec = 0
		fpsHistory.push(fps)
		if fpsHistory.length > 5
			fpsHistory.shift()

		console.log fpsHistory.join(', ')
		avg = fpsHistory.reduce((a, b) -> a + b) / fpsHistory.length

		console.log avg
		console.log toNext

		if avg >= 45
			toNext -= 1
		else
			toNext = 5
			toEnd -= 1

		if toNext == 0
			toNext = 5
			toEnd = 10
			console.log 'Boom!'
			lastOK = obj.length
			f = avg - 44
			console.log "f = #{f}"
			obj = obj.concat(({x: Math.random() * 500, y: Math.random() * 500, dx: (Math.random() - 0.5) * 8, dy: (Math.random() - 0.5) * 8, color: "rgb(#{Math.round(Math.random() * 255)}, 100, #{Math.round(Math.random() * 255)})"} for _ in [1..16 * f]))


	ctx.clearRect(0, 0, c.width, c.height)


	for o in obj
		newX = o.x + o.dx * delta * 10
		newY = o.y + o.dy * delta * 10

		if newX + 20 > c.width or newX < 0
			o.dx = -o.dx
		else
			o.x = newX

		if newY + 20 > c.height or newY < 0
			o.dy = -o.dy
		else
			o.y = newY

		ctx.fillStyle = o.color
		ctx.fillRect(o.x, o.y, 20, 20)


	ctx.fillText(fps, 10, 10)

	if toEnd > 0
		window.requestAnimationFrame(update)
	else
		console.log "The end, object count: #{lastOK}"

update()