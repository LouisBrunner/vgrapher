module grapher

import term.ui as tui

pub type GeneratorF[T] = fn (data T) map[f64]f64

pub type HandlerF[T] = fn (e Event, mut config Config[T]) bool

pub struct Config[T] {
pub mut:
	title      string
	data       T
	generator  GeneratorF[T] @[required]
	handler    HandlerF[T]   @[required]
	legend_sig int = 2
}

struct Generation {
	data map[f64]f64
}

struct Grapher[T] {
mut:
	// user
	config shared Config[T]
	// internal
	tui &tui.Context = unsafe { nil }
	// calculation
	calculating        shared MyOption[thread] = &None{}
	queued_calculation shared bool
	cached_result      shared MyOption[Generation] = &None{}
}

pub fn run[T](config Config[T]) ! {
	mut app := &Grapher[T]{
		config: config
	}
	app.recalculate()
	app.tui = tui.init(
		// FIXME: VBUG, fairly sure those [T] are not needed (they are everywhere)
		event_fn:    fn [mut app] [T](e &tui.Event, userdata voidptr) {
			app.on_event(e)
		}
		frame_fn:    fn [mut app] [T](userdata voidptr) {
			app.draw()
		}
		hide_cursor: true
	)
	return app.tui.run()
}
