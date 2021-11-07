module sim

// log is a helper function to print debug info
[inline]
pub fn log<T>(info T) {
	$if verbose ? {
		println(info)
	}
}
