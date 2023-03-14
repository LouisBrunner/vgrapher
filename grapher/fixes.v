module grapher

struct None {}

// FIXME: VBUG, option is basically unusable at the moment, especially with shared
type MyOption[T] = None | T
