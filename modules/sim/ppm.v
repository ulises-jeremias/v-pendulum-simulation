module sim

import os

pub const (
	default_width  = 600
	default_height = 600
)

[params]
pub struct ImageSettings {
pub:
	width  int = sim.default_width
	height int = sim.default_height
}

pub struct Pixel {
	r byte
	g byte
	b byte
}

pub struct PPMWriter {
mut:
	file  os.File
	cache []byte
}

pub fn ppm_writer_for_fname(fname string, settings ImageSettings) ?PPMWriter {
	mut writer := PPMWriter{}
	writer.start_for_file(fname, settings) ?
	return writer
}

pub fn (mut writer PPMWriter) start_for_file(fname string, settings ImageSettings) ? {
	writer.file = os.create(fname) ?
	writer.file.writeln('P6 $settings.width $settings.height 255') ?
}

pub fn (mut writer PPMWriter) handle_pixel(p Pixel) {
	writer.cache << [p.r, p.g, p.b]
}

pub fn (mut writer PPMWriter) write() ? {
	writer.file.write(writer.cache) ?
}

pub fn (mut writer PPMWriter) close() {
	writer.file.close()
}
