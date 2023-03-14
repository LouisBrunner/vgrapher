module grapher

fn (mut me Grapher[T]) recalculate[T]() {
	lock me.calculating, me.queued_calculation {
		if me.calculating is thread {
			me.queued_calculation = true
			return
		}

		me.queued_calculation = false
		me.calculating = spawn me.calculate()
	}
}

fn (mut me Grapher[T]) calculate[T]() {
	result := rlock me.config {
		me.config.generator(me.config.data)
	}

	lock me.cached_result {
		me.cached_result = Generation{
			data: result
		}
	}

	mut enqueue := lock me.calculating, me.queued_calculation {
		me.calculating = None{}

		me.queued_calculation
	}

	if enqueue {
		me.recalculate()
	}
}
