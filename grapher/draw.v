module grapher

import json
import math

const margin_top = 1

const margin_bottom_labels = 1

const margin_bottom = 2

fn (mut me Grapher[T]) draw[T]() {
	legend_sig, title := rlock me.config {
		me.config.legend_sig, '${me.config.title} (${json.encode(me.config.data)})'
	}

	me.tui.clear()
	me.tui.draw_text(me.tui.window_width / 2 - title.len / 2, 1, title)
	me.tui.set_cursor_position(0, 0)

	rlock me.cached_result {
		result := me.cached_result
		match result {
			None {
				me.draw_centered_text(me.tui.window_width / 2, me.tui.window_height / 2,
					'No data')
			}
			// FIXME: VBUG, it's bad at guessing the type of else, this whole condition is frustrating
			Generation {
				mut values_x := result.data.keys()
				if values_x.len < 2 {
					me.draw_centered_text(me.tui.window_width / 2, me.tui.window_height / 2,
						'Not enough data')
				} else {
					values_x.sort()
					min_x, max_x := values_x[0], values_x[values_x.len - 1]
					span_x := max_x - min_x
					mid_x := span_x / 2

					labels_start := 1
					labels_end := me.tui.window_width

					me.tui.draw_text(labels_start, me.tui.window_height - margin_bottom_labels,
						math.round_sig(min_x, legend_sig).str())
					me.draw_centered_text(me.tui.window_width / 2, me.tui.window_height - margin_bottom_labels,
						math.round_sig(mid_x, legend_sig).str())
					me.draw_right_text(me.tui.window_width, me.tui.window_height - margin_bottom_labels,
						math.round_sig(max_x, legend_sig).str())

					span_map_x := labels_end - labels_start
					step_map_x := span_x / span_map_x

					me.tui.set_bg_color(r: 63, g: 81, b: 181)
					me.tui.set_color(r: 255, g: 255, b: 255)
					me.tui.draw_rect(1, 1 + margin_top, me.tui.window_width, me.tui.window_height - margin_bottom)

					mut last_index := 0
					mut values := map[f64]f64{}
					for x := min_x; x <= max_x; x += step_map_x {
						pivot := x + step_map_x / 2
						for i := last_index; i < values_x.len; i += 1 {
							if values_x[i] > pivot {
								last_index = i
								break
							}
							values[x] += result.data[values_x[i]]
						}
					}

					mut values_y := values.values()
					values_y.sort()
					min_y, max_y := values_y[0], values_y[values_y.len - 1]
					span_y := max_y - min_y
					span_map_y := me.tui.window_height - (margin_top + margin_bottom + 1)

					for x, y in values {
						mapped_x := 1 + int((x - min_x) * span_map_x / span_x)
						mapped_y := 1 + int(span_map_y - ((y - min_y) * span_map_y / span_y)) +
							margin_top
						me.tui.draw_text(mapped_x, mapped_y, 'x')
					}
				}
			}
		}
	}

	rlock me.calculating {
		match me.calculating {
			None {}
			else {
				me.draw_right_text(me.tui.window_width, me.tui.window_height, 'Calculating...')
			}
		}
	}

	me.tui.reset()
	me.tui.flush()
}

fn (mut me Grapher[T]) draw_centered_text[T](x int, y int, text string) {
	me.tui.draw_text(x - text.len / 2, y, text)
}

fn (mut me Grapher[T]) draw_right_text[T](x int, y int, text string) {
	me.tui.draw_text(x - text.len, y, text)
}
