module anim

import sim
import sim.img

fn pixels_worker(mut app App) {
	for {
		result := <-app.result_chan or { break }
		// find the closest magnet
		pixel_color := img.compute_pixel(result)
		app.pixels[result.id] = u32(pixel_color.abgr8())
	}
}
