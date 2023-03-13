module grapher

import sync

struct None {}

// FIXME: VBUG, option is basically unusable at the moment, especially with shared
type MyOption[T] = None | T

fn locker(mut mutex sync.Mutex, f fn ()) {
	mutex.@lock()
	defer {
		mutex.unlock()
	}
	f()
}
