module sim

import gx
import os

pub const (
	default_width  = 600
	default_height = 600
)

[params]
pub struct ImageSettings {
pub:
	width      int = sim.default_width
	height     int = sim.default_height
	cache_size int = 200
}

pub fn new_image_settings(settings ImageSettings) ImageSettings {
	return ImageSettings{
		...settings
	}
}

pub struct PPMWriter {
mut:
	file       os.File
	cache      []byte
	cache_size int
}

pub fn ppm_writer_for_fname(fname string, settings ImageSettings) ?&PPMWriter {
	mut writer := &PPMWriter{
		cache_size: settings.cache_size
		cache: []byte{cap: settings.cache_size}
	}
	writer.start_for_file(fname, settings) ?
	return writer
}

pub fn (mut writer PPMWriter) start_for_file(fname string, settings ImageSettings) ? {
	writer.file = os.create(fname) ?
	writer.file.writeln('P6 $settings.width $settings.height 255') ?
}

pub fn (mut writer PPMWriter) handle_pixel(p gx.Color) ? {
	if writer.cache.len >= writer.cache_size {
		writer.write() ?
		writer.flush() ?
	}
	writer.cache << [p.r, p.g, p.b]
}

pub fn (mut writer PPMWriter) flush() ? {
	writer.cache = []byte{cap: writer.cache_size}
}

pub fn (mut writer PPMWriter) write() ? {
	// log(@MOD + '.' + @STRUCT + '.' + @FN + ': writing ${writer.cache.len} bytes')
	writer.file.write(writer.cache) ?
}

pub fn (mut writer PPMWriter) close() {
	writer.file.close()
}
