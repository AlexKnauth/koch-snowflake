use std::path::Path;
pub use image::RgbaImage;
use image::Rgba;
use image::imageops::overlay;
use image::error::ImageResult;
use imageproc::drawing::draw_antialiased_line_segment_mut;
use imageproc::pixelops::interpolate;
use super::pos::*;

pub type Color = Rgba<u8>;

pub const TRANSPARENT: Color = Rgba([0, 0, 0, 0]);
pub const WHITE: Color = Rgba([255u8, 255u8, 255u8, 255u8]);
pub const BLACK: Color = Rgba([0u8, 0u8, 0u8, 255u8]);
pub const RED: Color = Rgba([255u8, 0u8, 0u8, 255u8]);
pub const ORANGE: Color = Rgba([255u8, 127u8, 0u8, 255u8]);
pub const YELLOW: Color = Rgba([255u8, 255u8, 0u8, 255u8]);
pub const GREEN: Color = Rgba([0u8, 255u8, 0u8, 255u8]);
pub const BLUE: Color = Rgba([0u8, 0u8, 255u8, 255u8]);
pub const PURPLE: Color = Rgba([128u8, 0u8, 128u8, 255u8]);
pub const GOLD: Color = Rgba([255u8, 215, 0u8, 255u8]);

pub fn draw_line_segment_mut(img: &mut RgbaImage, a: Pos, b: Pos, c: Color) {
    draw_antialiased_line_segment_mut(img,
        pos_round_i32(a),
        pos_round_i32(b),
        c,
        interpolate);
}

pub struct LayeredImage {
    width: u32,
    height: u32,
    layers: Vec<RgbaImage>
}
impl LayeredImage {
    pub fn from_pixels(w: u32, h: u32, ps: Vec<Color>) -> LayeredImage {
        LayeredImage {
            width: w,
            height: h,
            layers: ps.into_iter().map(|p| RgbaImage::from_pixel(w, h, p)).collect()
        }
    }
    pub fn on_layer<F>(&mut self, i: usize, f: F) where F: FnOnce(&mut RgbaImage) {
        f(self.layers.get_mut(i).unwrap());
    }
    pub fn save<Q>(&self, path: Q) -> ImageResult<()> where Q: AsRef<Path> {
        let mut img = RgbaImage::from_pixel(self.width, self.height, TRANSPARENT);
        for l in self.layers.iter().rev() {
          overlay(&mut img, l, 0, 0);
        }
        img.save(path)
    }
}
