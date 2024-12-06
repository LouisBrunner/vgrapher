import rand
import grapher

struct Data {
mut:
	rate   f64
	points f64
}

fn main() {
	grapher.run(
		title:     'Exponential Random Distribution'
		data:      Data{
			rate:   1.0
			points: 1000.0
		}
		generator: fn (data Data) map[f64]f64 {
			mut result := map[f64]f64{}
			for n := 0; n < data.points; n += 1 {
				result[rand.exponential(data.rate)] += 1
			}
			return result
		}
		handler:   fn (e grapher.Event, mut config grapher.Config[Data]) bool {
			match e.code {
				.up {
					config.data.rate += 0.1
				}
				.down {
					config.data.rate -= 0.1
					if config.data.rate < 0.1 {
						config.data.rate = 0.1
					}
				}
				.right {
					config.data.points += 100
				}
				.left {
					config.data.points -= 100
					if config.data.points < 100 {
						config.data.points = 100
					}
				}
				else {
					return false
				}
			}
			return true
		}
	)!
}
