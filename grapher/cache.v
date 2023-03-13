module grapher

fn (mut me Grapher[T]) recalculate[T]() {
	lock me.calculating, me.queued_calculation {
		if me.calculating is thread {
			me.queued_calculation = true
			return
		}

		me.queued_calculation = false
		// FIXME: VBUG, builder issue
		me.calculating = spawn fn [mut me] [T]() {
			me.calculate()
		}()
	}
}

fn (mut me Grapher[T]) calculate[T]() {
	result := lock me.config {
		me.config.generator(me.config.data)
	}

	lock me.cached_result {
		me.cached_result = Generation{
			data: result
		}
	}

	mut enqueue := false
	lock me.calculating, me.queued_calculation {
		me.calculating = None{}

		if me.queued_calculation {
			enqueue = true
		}
	}

	if enqueue {
		me.recalculate()
	}
}
