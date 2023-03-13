module grapher

import term.ui as tui

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

struct None {}

// FIXME: VBUG, option is basically unusable at the moment, especially with shared
type MyOption[T] = None | T

struct Grapher[T] {
mut:
	// user
	config shared Config[T]
	// internal
	tui &tui.Context = unsafe { nil }
	// calculation
	calculating        shared MyOption[thread]
	queued_calculation shared bool
	cached_result      shared MyOption[Generation]
}

pub fn run[T](config Config[T]) ? {
	mut app := &Grapher[T]{
		config: config
	}
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
