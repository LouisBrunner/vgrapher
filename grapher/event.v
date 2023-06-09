module grapher

import term.ui as tui

// FIXME: VBUG, issue in the compiler
// pub type Event = &tui.Event

fn (mut me Grapher[T]) on_event[T](e &tui.Event) {
	match e.typ {
		.key_down {
			match true {
				me.user_handler(e) {
					me.recalculate()
				}
				else {
					match e.code {
						.r {
							me.recalculate()
						}
						.escape, .q {
							exit(0)
						}
						else {}
					}
				}
			}
		}
		else {}
	}
}

fn (mut me Grapher[T]) user_handler[T](e &tui.Event) bool {
	mut result := false
	locker(mut me.config_mutex, fn [mut me, e, mut result] [T]() {
		result = me.config.handler(e, mut &me.config)
	})
	return result
}
