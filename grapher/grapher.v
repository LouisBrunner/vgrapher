module grapher

import term.ui as tui
import sync

pub type GeneratorF = fn (data T) map[f64]f64

pub type HandlerF = fn (e &tui.Event, mut config Config[T]) bool

pub struct Config[T] {
pub mut:
	title      string
	data       T
	generator  GeneratorF[T]
	handler    HandlerF[T]
	legend_sig int = 2
}

struct Generation {
	data map[f64]f64
}

// FIXME: VBUG, can't have shared in a struct
struct Grapher[T] {
mut:
	// user
	config_mutex sync.Mutex
	config       Config[T]
	// internal
	tui &tui.Context = unsafe { nil }
	// calculation
	calculation_mutex  sync.Mutex
	calculating        MyOption[thread] = None{}
	queued_calculation bool
	result_mutex       sync.Mutex
	cached_result      MyOption[Generation] = None{}
}

pub fn run[T](config Config[T]) ? {
	mut app := &Grapher[T]{
		config: config
	}
	app.config_mutex.init()
	app.calculation_mutex.init()
	app.result_mutex.init()
	app.recalculate()
	app.tui = tui.init(
		// FIXME: VBUG, fairly sure those [T] are not needed (they are everywhere)
		event_fn: fn [mut app] [T](e &tui.Event, userdata voidptr) {
			app.on_event(e)
		}
		frame_fn: fn [mut app] [T](userdata voidptr) {
			app.draw()
		}
		hide_cursor: true
	)
	return app.tui.run()
}
