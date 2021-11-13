module anim

import sim.img

fn pixels_worker(mut app App) {
	for {
		select {
			result := <-app.result_chan {
				// find the closest magnet
				pixel_color := img.compute_pixel(result)

				x, y := get_pixel_coords(app, result)
				app.pixels[y][x] = pixel_color
			}
		}
	}
}
