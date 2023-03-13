module grapher

fn (mut me Grapher[T]) recalculate[T]() {
	locker(mut me.calculation_mutex, fn [mut me] [T]() {
		if me.calculating is thread {
			me.queued_calculation = true
			return
		}

		me.queued_calculation = false
		// FIXME: VBUG, builder issue
		me.calculating = spawn fn [mut me] [T]() {
			me.calculate()
		}()
	})
}

fn (mut me Grapher[T]) calculate[T]() {
	mut result := map[f64]f64{}
	locker(mut me.config_mutex, fn [mut me, mut result] [T]() {
		result = me.config.generator(me.config.data)
	})

	locker(mut me.result_mutex, fn [mut me, result] [T]() {
		me.cached_result = Generation{
			data: result
		}
	})

	// mut enqueue := fn [mut me] [T]() bool {
	// 	me.calculation_mutex.@lock()
	// 	defer {
	// 		me.calculation_mutex.unlock()
	// 	}

	// 	me.calculating = None{}

	// 	return me.queued_calculation
	// }()
	enqueue := me.clear_calc()

	if enqueue {
		me.recalculate()
	}
}

// FIXME: VBUG, builder issue
fn (mut me Grapher[T]) clear_calc[T]() bool {
	mut result := false
	locker(mut me.calculation_mutex, fn [mut me, mut result] [T]() {
		me.calculating = None{}

		result = me.queued_calculation
	})
	return result
}
