pub use image::RgbaImage;
use image::Rgba;
use imageproc::drawing::draw_antialiased_line_segment_mut;
use imageproc::pixelops::interpolate;
use super::pos::*;

pub type Color = Rgba<u8>;

// pub const TRANSPARENT: Color = Rgba([0, 0, 0, 0]);
pub const WHITE: Color = Rgba([255u8, 255u8, 255u8, 255u8]);
pub const BLACK: Color = Rgba([0u8, 0u8, 0u8, 255u8]);

pub fn draw_line_segment_mut(img: &mut RgbaImage, a: Pos, b: Pos, c: Color) {
    draw_antialiased_line_segment_mut(img,
        pos_round_i32(a),
        pos_round_i32(b),
        c,
        interpolate);
}
