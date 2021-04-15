pub use image::RgbImage;
use image::Rgb;
use imageproc::drawing::draw_antialiased_line_segment_mut;
use imageproc::pixelops::interpolate;
use super::pos::*;

pub type Color = Rgb<u8>;

pub const WHITE: Color = Rgb([255u8, 255u8, 255u8]);
pub const BLACK: Color = Rgb([0u8, 0u8, 0u8]);

pub fn draw_line_segment_mut(img: &mut RgbImage, a: Pos, b: Pos, c: Color) {
    draw_antialiased_line_segment_mut(img,
        pos_round_i32(a),
        pos_round_i32(b),
        c,
        interpolate);
}
