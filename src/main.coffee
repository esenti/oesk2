$ ->

	templates = {}

	$('script[type*=x-handlebars-template]').each((i, elem) ->

		name = elem.id.replace(/-([a-z])/g, (m, w) ->
			return w.toUpperCase()
		)

		templates[name] = Handlebars.compile(elem.text)
	)

	wrapper = $('#wrapper')

	results = ->

		$.get('api/results', (data) ->
			wrapper.html(templates.results({results: data.items}))
		)

	stats = ->

		wrapper.html(templates.stats())

		$.get('api/stats/browsers', (data) ->
			r = Raphael('browsers')

			r.piechart(200, 170, 160, v.count for v in data.items, {
				legend: "#{v.browser} — %%" for v in data.items
			})
		)

		$.get('api/stats/os', (data) ->
			r = Raphael('os')

			r.piechart(200, 170, 160, v.count for v in data.items, {
				legend: "#{v.os} — %%" for v in data.items
			})
		)

	test = ->

		wrapper.html(templates.test())

		c = $('#draw')[0]

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

		obj = ({x: Math.random() * (c.width - 20), y: Math.random() * (c.height - 20), dx: (Math.random() - 0.5) * 8, dy: (Math.random() - 0.5) * 8, color: "rgb(#{Math.round(Math.random() * 255)}, 100, #{Math.round(Math.random() * 255)})"} for _ in [1..50])

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

				if fps >= 45
					toNext -= 1
				else
					toNext = 5
					toEnd -= 1

				if toNext == 0
					toNext = 5
					toEnd = 10
					lastOK = obj.length
					f = fps - 44
					obj = obj.concat(({x: Math.random() * (c.width - 20), y: Math.random() * (c.height - 20), dx: (Math.random() - 0.5) * 8, dy: (Math.random() - 0.5) * 8, color: "rgb(#{Math.round(Math.random() * 255)}, 100, #{Math.round(Math.random() * 255)})"} for _ in [1..Math.round(16 * f / 10) * 10]))


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


			ctx.fillText("FPS: #{fps}", 10, 10)
			ctx.fillText("Objects: #{obj.length}", 10, 30)
			ctx.fillText("Last passed: #{lastOK}", 10, 50)

			if toEnd > 0
				window.requestAnimationFrame(update)
			else
				data = JSON.stringify({browser_name: platform.name, browser_version: platform.version, os: platform.os.family, score: lastOK})

				$.ajax({
					url: 'api/results',
					type: 'POST',
					data: data,
					contentType: 'application/json; charset=utf-8',
					dataType: 'json',
					success: (data) ->
						results = $('#results-popup')
						results.find('.platform').text("#{platform.name} #{platform.version} on #{platform.os.family}")
						results.find('.objects').text(lastOK)
						diff = lastOK - data.average_score
						results.find('.average').html("#{data.average_score} (#{"#{if diff > 0 then "<span class='better'>+#{diff}</span>" else if diff == 0 then "<span class='neutral'>#{diff}</span>" else "<span class='worse'>#{diff}</span>"}"})")
						results.css('left': (window.innerWidth - results.width()) / 2)
						results.animate({top: 200})
				})

		update()


	$('body').on('click', '.results-link', ->
		console.log 'results clicked'
		results()
		return false
	)

	$('body').on('click', '.test-link', ->
		test()
		return false
	)

	$('body').on('click', '.stats-link', ->
		stats()
		return false
	)

	results()
