module sim

import gx

struct ValidColor {
	gx.Color
mut:
	valid bool
}

pub fn image_worker(mut writer PPMWriter, result_chan chan SimResult, settings ImageSettings) {
	width := settings.width
	height := settings.height
	total_pixels := width * height

	// as new pixels come in, write them to the image file
	mut current_index := u64(0)
	mut pixel_buf := []ValidColor{len: total_pixels, init: ValidColor{
		valid: false
	}}
	for {
		result := <-result_chan or { break }

		// find the closest magnet
		pixel_buf[result.id].Color = compute_pixel(result)
		pixel_buf[result.id].valid = true

		for current_index < total_pixels && pixel_buf[current_index].valid {
			writer.handle_pixel(pixel_buf[current_index].Color) or {
				log(@MOD + '.' + @FN + ': pixel handler failed. Error $err')
				break
			}
			current_index++
		}

		if current_index >= total_pixels {
			break
		}
	}
	writer.write() or { panic('Could not write image') }
}

pub fn compute_pixel(result SimResult) gx.Color {
	closest_to_m1 := result.magnet1_distance < result.magnet2_distance
		&& result.magnet1_distance < result.magnet3_distance
	closest_to_m2 := result.magnet2_distance < result.magnet1_distance
		&& result.magnet2_distance < result.magnet3_distance

        if closest_to_m1 {
                return gx.red
        } else if closest_to_m2 {
                return gx.green
        } else {
                return gx.blue
        }
}
